import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';

import 'quran_search_delegate.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? initialPage;
  final int? targetPage;
  final String? searchQuery;

  const SurahDetailScreen({
    super.key,
    required this.surahName,
    required this.surahNumber,
    this.initialPage,
    this.targetPage,
    this.searchQuery,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  late stt.SpeechToText _speech;

  bool _isDownloadingQuran = false;
  bool _showControls = false;
  bool _isPlaying = false;
  bool _isListening = false;
  bool _recitationMode = false;

  late int _currentPage;
  double _playbackProgress = 0.0;

  String _spokenText = '';
  String _selectedReciter = 'ar.alafasy';
  String _selectedReciterName = 'مشاري العفاسي';

  static const String _kLastPageKey = 'quran_last_page';
  static const String _kLastSurahKey = 'quran_last_surah_name';
  static const String _kBookmarkPageKey = 'quran_bookmark_page';
  static const String _kBookmarkSurahKey = 'quran_bookmark_surah_name';

  final List<Map<String, String>> _reciters = [
    {'id': 'ar.alafasy', 'name': 'مشاري العفاسي'},
    {'id': 'ar.husary', 'name': 'محمود خليل الحصري'},
    {'id': 'ar.abdulbasitmurattal', 'name': 'عبدالباسط عبدالصمد'},
    {'id': 'ar.minshawi', 'name': 'محمد صديق المنشاوي'},
    {'id': 'ar.mahermuaiqly', 'name': 'ماهر المعيقلي'},
  ];

  final List<int> _surahStartPages = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602,
    602, 602, 603, 603, 603, 604, 604, 604
  ];

  @override
  void initState() {
    super.initState();

    _currentPage =
        widget.initialPage ?? _surahStartPages[widget.surahNumber - 1];

    _pageController = PageController(initialPage: _currentPage - 1);
    _audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();

    _saveLastReadingPosition();
    _initAudioListeners();
    _initOfflineQuran();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initOfflineQuran() async {
    setState(() => _isDownloadingQuran = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isDownloadingQuran = false);
    }
  }

  void _initAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _playbackProgress = 0.0;
        }
      });
    });
  }

  String _getPageImageAsset(int page) {
    final fileIndex = (page - 1).toString().padLeft(3, '0');
    return 'assets/quran_pages/$fileIndex.png';
  }

  Future<void> _showPageTafsir() async {
    final primary = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/page/$_currentPage/ar.muyassar'))
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List;

        final tafsirText = ayahs
            .map((a) => a['text'].toString())
            .join('\n\n');

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF171A1E)
              : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => SafeArea(
              top: false,
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                children: [
                  _buildSheetHeader(
                    title: 'تفسير الصفحة',
                    subtitle: 'الصفحة $_currentPage • التفسير الميسر',
                    primary: primary,
                    icon: Icons.menu_book_rounded,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primary.withOpacity(0.10),
                      ),
                    ),
                    child: Text(
                      tafsirText,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        height: 1.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تحميل تفسير الصفحة',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تحميل التفسير',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
  }

  Future<void> _playSequence() async {
    try {
      final url =
          'https://cdn.islamic.network/quran/audio/128/$_selectedReciter/${widget.surahNumber}.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {}
  }

  Future<void> _listen() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _recitationMode = false;
      });
      await _speech.stop();
      return;
    }

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (!status.isGranted) return;

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
              _recitationMode = false;
            });
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _recitationMode = false;
          });
        }
      },
    );

    if (!available) return;

    setState(() {
      _isListening = true;
      _recitationMode = true;
      _spokenText = '';
    });

    await _speech.listen(
      localeId: 'ar_SA',
      partialResults: true,
      onResult: (result) {
        if (mounted) {
          setState(() {
            _spokenText = result.recognizedWords;
          });
        }
      },
    );
  }

  Future<void> _saveLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastPageKey, _currentPage);
    await prefs.setString(_kLastSurahKey, widget.surahName);
  }

  Future<void> _saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBookmarkPageKey, _currentPage);
    await prefs.setString(_kBookmarkSurahKey, widget.surahName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ علامة عند الصفحة $_currentPage',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _goToLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_kLastPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد موضع محفوظ سابقًا',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    await _saveLastReadingPosition();
  }

  Future<void> _goToBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_kBookmarkPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا توجد علامة محفوظة',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    await _saveLastReadingPosition();
  }

  Future<Map<String, dynamic>> _getSavedReadingMeta() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'lastPage': prefs.getInt(_kLastPageKey),
      'lastSurah': prefs.getString(_kLastSurahKey),
      'bookmarkPage': prefs.getInt(_kBookmarkPageKey),
      'bookmarkSurah': prefs.getString(_kBookmarkSurahKey),
    };
  }

  void _showQuickJumpSheet() {
    final primary = Theme.of(context).colorScheme.primary;
    final controller = TextEditingController(text: _currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHeader(
                    title: 'الانتقال السريع',
                    subtitle: 'اذهب إلى صفحة محددة',
                    primary: primary,
                    icon: Icons.swap_horiz_rounded,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الصفحة',
                      hintStyle: GoogleFonts.cairo(),
                      filled: true,
                      fillColor: primary.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: primary.withOpacity(0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: primary.withOpacity(0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final page = int.tryParse(controller.text.trim());

                        if (page == null || page < 1 || page > 604) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'أدخل رقم صفحة صحيح من 1 إلى 604',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        _pageController.jumpToPage(page - 1);
                        setState(() {
                          _currentPage = page;
                          _showControls = true;
                        });

                        await _saveLastReadingPosition();
                      },
                      child: Text(
                        'الانتقال إلى الصفحة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReciterDialog(Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(
                title: 'اختيار القارئ',
                subtitle: 'اختر قارئ التلاوة',
                primary: primary,
                icon: Icons.record_voice_over_rounded,
              ),
              ..._reciters.map(
                    (r) => _buildModernSheetTile(
                  icon: Icons.person_rounded,
                  title: r['name']!,
                  subtitle: _selectedReciter == r['id'] ? 'القارئ الحالي' : null,
                  primary: primary,
                  trailing: _selectedReciter == r['id']
                      ? Icon(Icons.check_circle, color: primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedReciter = r['id']!;
                      _selectedReciterName = r['name']!;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageReaderMenu() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(
                title: 'خيارات المصحف',
                subtitle: widget.surahName,
                primary: primary,
                icon: Icons.menu_book_rounded,
              ),
              _buildModernSheetTile(
                icon: Icons.search_rounded,
                title: 'البحث في القرآن',
                subtitle: 'ابحث عن كلمة أو آية',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  showSearch(
                    context: context,
                    delegate: QuranSearch(primaryColor: primary),
                  ).then((result) {
                    if (result != null) {
                      _pageController.jumpToPage(result['page'] - 1);
                      setState(() {
                        _currentPage = result['page'];
                        _showControls = true;
                      });
                      _saveLastReadingPosition();
                    }
                  });
                },
              ),
              _buildModernSheetTile(
                icon: Icons.swap_horiz_rounded,
                title: 'الانتقال السريع',
                subtitle: 'اذهب مباشرة إلى صفحة معينة',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showQuickJumpSheet();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.history_rounded,
                title: 'آخر موضع',
                subtitle: saved['lastPage'] != null
                    ? 'الصفحة ${saved['lastPage']}'
                    : 'لا يوجد موضع محفوظ',
                primary: primary,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToLastReadingPosition();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.bookmark_rounded,
                title: 'الذهاب إلى العلامة',
                subtitle: saved['bookmarkPage'] != null
                    ? 'الصفحة ${saved['bookmarkPage']}'
                    : 'لا توجد علامة محفوظة',
                primary: primary,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToBookmark();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.record_voice_over_rounded,
                title: 'اختيار القارئ',
                subtitle: _selectedReciterName,
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showReciterDialog(primary);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader({
    required String title,
    String? subtitle,
    required Color primary,
    IconData? icon,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 14),
        if (icon != null) Icon(icon, color: primary, size: 24),
        if (icon != null) const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildModernSheetTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color primary,
    VoidCallback? onTap,
    Widget? trailing,
    bool danger = false,
  }) {
    final color = danger ? Colors.red : primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: Colors.grey,
        ),
      )
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildMushafPage(
      int page,
      Color bg,
      Color text,
      Color primary,
      bool isDark,
      ) {
    final imageAsset = _getPageImageAsset(page);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 980,
                height: 1580,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 980,
                      height: 1580,
                      color: bg,
                      alignment: Alignment.center,
                      child: Text(
                        'تعذر تحميل الصفحة $page',
                        style: GoogleFonts.cairo(
                          color: primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReaderStyleTopBar({
    required Color primary,
    required bool isDark,
    required double topPadding,
  }) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 6,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.settings,
            onTap: _showImageReaderMenu,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _circleIconButton(
            icon: Icons.search,
            onTap: () {
              final primary = Theme.of(context).colorScheme.primary;
              showSearch(
                context: context,
                delegate: QuranSearch(primaryColor: primary),
              ).then((result) {
                if (result != null) {
                  _pageController.jumpToPage(result['page'] - 1);
                  setState(() {
                    _currentPage = result['page'];
                    _showControls = true;
                  });
                  _saveLastReadingPosition();
                }
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222222) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.surahName} | جزء ${(widget.surahNumber)} | صفحة $_currentPage',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _circleIconButton(
            icon: Icons.menu,
            onTap: _showImageReaderMenu,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF222222) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black87,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildReaderStyleBottomOverlay({
    required Color primary,
    required bool isDark,
    required double bottomPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222222) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _smallBottomButton(
                    icon: Icons.error_outline_rounded,
                    label: _recitationMode ? 'إيقاف' : 'أخطاء',
                    isDark: isDark,
                    onTap: _listen,
                  ),
                  _smallBottomButton(
                    icon: Icons.menu_book_outlined,
                    label: 'تفسير',
                    isDark: isDark,
                    onTap: _showPageTafsir,
                  ),
                  _smallBottomButton(
                    icon: _showControls
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    label: 'إخفاء',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Material(
            color: primary.withOpacity(0.15),
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _listen,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red.shade300, Colors.red.shade500]
                        : [
                      const Color(0xFFB7F5C2),
                      const Color(0xFF84F0A6),
                    ],
                  ),
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget _smallBottomButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageReaderTopBar({
    required Color primary,
    required Color textColor,
    required bool isDark,
    required double topPadding,
  }) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 6,
        right: 6,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0E1012).withOpacity(0.92)
            : Colors.white.withOpacity(0.92),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.04),
          ),
        ),
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.arrow_forward_ios_rounded, color: primary, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.surahName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '$_currentPage',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.more_horiz_rounded, color: primary, size: 22),
              onPressed: _showImageReaderMenu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageReaderBottomBar({
    required Color primary,
    required bool isDark,
    required double bottomPadding,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0E1012).withOpacity(0.93)
            : Colors.white.withOpacity(0.93),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.04),
          ),
        ),
      ),
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _playSequence();
                }
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedReciterName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _playbackProgress,
                      minHeight: 2.5,
                      backgroundColor: primary.withOpacity(0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.bookmark_add_outlined, color: primary, size: 20),
              onPressed: _saveBookmark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD);
    final textColor = isDark ? Colors.white : const Color(0xFF222222);

    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;

    final topBarHeight = topPadding + 68.0;
    final bottomOverlayHeight = bottomPadding + 88.0;

    if (_isDownloadingQuran) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primary),
              const SizedBox(height: 16),
              Text(
                'جاري إعداد المصحف...',
                style: GoogleFonts.cairo(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPadding + 6,
                  bottom: bottomPadding + 8,
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 604,
                  reverse: true,
                  physics: widget.targetPage != null
                      ? const ClampingScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    final newPage = index + 1;

                    if (widget.targetPage != null &&
                        newPage > widget.targetPage!) {
                      _pageController.jumpToPage(widget.targetPage! - 1);
                      return;
                    }

                    if (widget.initialPage != null &&
                        newPage < widget.initialPage!) {
                      _pageController.jumpToPage(widget.initialPage! - 1);
                      return;
                    }

                    setState(() {
                      _currentPage = newPage;
                    });

                    _saveLastReadingPosition();
                  },
                  itemBuilder: (context, index) {
                    final page = index + 1;
                    return _buildMushafPage(
                      page,
                      pageBg,
                      textColor,
                      primary,
                      isDark,
                    );
                  },
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -(topBarHeight + 10),
            left: 0,
            right: 0,
            height: topBarHeight,
            child: _buildReaderStyleTopBar(
              primary: primary,
              isDark: isDark,
              topPadding: topPadding,
            ),
          ),

          if (_spokenText.isNotEmpty && _isListening)
            Positioned(
              left: 16,
              right: 16,
              bottom: (bottomPadding > 0 ? bottomPadding : 8) + 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _spokenText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            bottom: _showControls ? 10 : -(bottomOverlayHeight + 20),
            left: 0,
            right: 0,
            height: bottomOverlayHeight,
            child: _buildReaderStyleBottomOverlay(
              primary: primary,
              isDark: isDark,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }
}