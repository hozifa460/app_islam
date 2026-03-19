import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
  final Map<int, int> _pageToHizbQuarter = {};

  bool _isDownloadingQuran = false;
  bool _showControls = false;
  bool _isPlaying = false;
  bool _isListening = false;
  bool _recitationMode = false;
  bool _hideVerses = false;

  late int _currentPage;
  double _playbackProgress = 0.0;
  final TransformationController _zoomController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  Map<int, List<dynamic>> _pageAyahsCache = {};
  bool _isLoadingTextPage = false;

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

  final List<String> _surahNames = const [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
    'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون',
    'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص',
    'الزمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف',
    'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم', 'القمر',
    'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة', 'الصف',
    'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك', 'القلم',
    'الحاقة', 'المعارج', 'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس', 'التكوير', 'الإنفطار',
    'المطففين', 'الإنشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر',
    'البلد', 'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر',
    'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر', 'العصر', 'الهمزة',
    'الفيل', 'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر', 'المسد',
    'الإخلاص', 'الفلق', 'الناس'
  ];

  int _getPageForJuz(int juz) {
    const juzStartPages = [
      1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
      201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
      402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
    ];
    return juzStartPages[juz - 1];
  }

  int _getPageForHizb(int hizb) {
    final targetQuarter = ((hizb - 1) * 4) + 1;

    for (final entry in _pageToHizbQuarter.entries) {
      if (entry.value == targetQuarter) {
        return entry.key;
      }
    }

    return 1;
  }

  void _jumpToPage(int page) {
    if (page < 1 || page > 604) return;

    _zoomController.value = Matrix4.identity();
    _pageController.jumpToPage(page - 1);

    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _saveLastReadingPosition();
  }

  void _showAdvancedIndexSheet() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();

    if (!mounted) return;

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
        return DefaultTabController(
          length: 4,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.82,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'فهرس المصحف',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _quickJumpCard(
                                title: 'آخر موضع',
                                value: saved['lastPage'] != null
                                    ? 'صفحة ${_toArabicNum(saved['lastPage'])}'
                                    : 'غير متوفر',
                                icon: Icons.history_rounded,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _goToLastReadingPosition();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _quickJumpCard(
                                title: 'العلامة',
                                value: saved['bookmarkPage'] != null
                                    ? 'صفحة ${_toArabicNum(saved['bookmarkPage'])}'
                                    : 'غير متوفر',
                                icon: Icons.bookmark_rounded,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _goToBookmark();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    labelColor: primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primary,
                    labelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'صفحات'),
                      Tab(text: 'السور'),
                      Tab(text: 'الأجزاء'),
                      Tab(text: 'الأحزاب'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPagesTab(ctx),
                        _buildSurahsTab(ctx),
                        _buildJuzTab(ctx),
                        _buildHizbTab(ctx),
                      ],
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

  Widget _buildPagesTab(BuildContext ctx) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final page = index + 1;
        final selected = page == _currentPage;
        final primary = Theme.of(context).colorScheme.primary;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? primary.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _toArabicNum(page),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

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

  String _toArabicNum(int n) {
    const nums = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

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
    _prepareHizbQuarterMap();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<List<dynamic>> _getPageAyahs(int page) async {
    if (_pageAyahsCache.containsKey(page)) {
      return _pageAyahsCache[page]!;
    }

    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = List<dynamic>.from(data['data']['ayahs']);
      _pageAyahsCache[page] = ayahs;
      return ayahs;
    }

    throw Exception('تعذر تحميل آيات الصفحة');
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
    final fileIndex = (page - 0).toString().padLeft(3, '0');
    return 'assets/quran_pages/$fileIndex.png';
  }

  void _handleDoubleTap() {
    if (_zoomController.value != Matrix4.identity()) {
      _zoomController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? const Offset(200, 200);

      _zoomController.value = Matrix4.identity()
        ..translate(-position.dx * 1.2, -position.dy * 1.2)
        ..scale(2.2);
    }
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

  Future<int?> _getCurrentPageHizbQuarter() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

      for (final surah in data['data']['surahs']) {
        for (final ayah in surah['ayahs']) {
          if (ayah['page'] == _currentPage) {
            return ayah['hizbQuarter'];
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> _prepareHizbQuarterMap() async {
    if (_pageToHizbQuarter.isNotEmpty) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      if (!await file.exists()) return;

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

      for (final surah in data['data']['surahs']) {
        for (final ayah in surah['ayahs']) {
          final page = ayah['page'];
          final hizbQuarter = ayah['hizbQuarter'];

          _pageToHizbQuarter.putIfAbsent(page, () => hizbQuarter);
        }
      }
    } catch (_) {}
  }

  String _buildAyahNumber(int number) {
    return ' ﴿${_toArabicNum(number)}﴾ ';
  }

  int _getCurrentHizb() {
    final hizbQuarter = _pageToHizbQuarter[_currentPage] ?? 1;
    return ((hizbQuarter - 1) ~/ 4) + 1;
  }

  int _getCurrentQuarterInHizb() {
    final hizbQuarter = _pageToHizbQuarter[_currentPage] ?? 1;
    return ((hizbQuarter - 1) % 4) + 1;
  }

  double _getCurrentHizbProgress() {
    final quarter = _getCurrentQuarterInHizb();
    return quarter / 4.0;
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
    try {
      if (_isListening) {
        await _speech.stop();
        if (mounted) {
          setState(() {
            _isListening = false;
            _spokenText = '';
          });
        }
        return;
      }

      var permission = await Permission.microphone.status;
      if (!permission.isGranted) {
        permission = await Permission.microphone.request();
      }

      if (!permission.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لم يتم منح إذن الميكروفون',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');

          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');

          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطأ في الميكروفون: ${error.errorMsg}',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
      );

      debugPrint('Speech available: $available');

      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خدمة التعرف الصوتي غير متاحة على هذا الجهاز',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _isListening = true;
          _spokenText = '';
        });
      }

      await _speech.listen(
        localeId: 'ar_SA',
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        onResult: (result) {
          debugPrint('Recognized words: ${result.recognizedWords}');
          if (mounted) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Microphone exception: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تشغيل الميكروفون',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              _buildModernSheetTile(
                icon: Icons.list_alt_rounded,
                title: 'فهرس المصحف',
                subtitle: 'السور، الأجزاء، الأحزاب، الصفحات',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showAdvancedIndexSheet();
                },
              ),
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

  Widget _buildTextModePage(
      int page,
      Color bg,
      Color primary,
      bool isDark,
      ) {
    final hizbQuarter = _pageToHizbQuarter[page] ?? 1;
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return FutureBuilder<List<dynamic>>(
      future: _getPageAyahs(page),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: bg,
            child: Center(
              child: CircularProgressIndicator(color: primary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: bg,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذر تحميل نص الصفحة',
              style: GoogleFonts.cairo(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final ayahs = snapshot.data!;

        return Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.surahName,
                        style: GoogleFonts.cairo(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'جزء ${_toArabicNum(juz)}',
                        style: GoogleFonts.cairo(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildHizbProgressCircle(
                        primary: primary,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حزب ${_toArabicNum(hizb)}',
                        style: GoogleFonts.cairo(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            children: ayahs.map((ayah) {
                              final ayahNumber = ayah['numberInSurah'] as int;
                              final ayahText = ayah['text'].toString();

                              return TextSpan(
                                children: [
                                  if (!_hideVerses)
                                    TextSpan(
                                      text: '$ayahText ',
                                      style: GoogleFonts.amiriQuran(
                                        fontSize: 26,
                                        height: 2.0,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF222222),
                                      ),
                                    ),
                                  TextSpan(
                                    text: _buildAyahNumber(ayahNumber),
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      height: 2.0,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _toArabicNum(page),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
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

  Widget _buildMushafPage(
      int page,
      Color bg,
      Color text,
      Color primary,
      bool isDark,
      ) {
    if (_hideVerses) {
      return _buildTextModePage(page, bg, primary, isDark);
    }

    final imageAsset = _getPageImageAsset(page);

    final hizbQuarter = _pageToHizbQuarter[page] ?? 1;
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        return Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          child: GestureDetector(
            onDoubleTapDown: (details) {
              _doubleTapDetails = details;
            },
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _zoomController,
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: true,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(80),
              clipBehavior: Clip.none,
              child: ClipRect(
                child: SizedBox(
                  width: availableWidth,
                  height: availableHeight,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 1080,
                      height: 1760,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.topCenter,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: bg,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'تعذر تحميل الصفحة ${_toArabicNum(page)}',
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
                          Positioned(
                            top: 18,
                            left: 26,
                            right: 26,
                            child: Row(
                              children: [
                                Text(
                                  widget.surahName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'جزء ${_toArabicNum(juz)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildHizbProgressCircle(
                                  primary: primary,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'حزب ${_toArabicNum(hizb)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 34,
                            right: 28,
                            child: Text(
                              _toArabicNum(page),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    final boxColor = isDark ? const Color(0xFF232323) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    final hizbQuarter = _pageToHizbQuarter[_currentPage] ?? 1;
    final hizb = _getCurrentHizb();
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 2,
        left: 10,
        right: 10,
        bottom: 8,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          _readerTopSquareButton(
            icon: Icons.settings,
            onTap: _showImageReaderMenu,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _readerTopSquareButton(
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
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'صفحة $_currentPage | جزء $juz | حزب $hizb',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHizbProgressCircle(primary: primary, isDark: isDark),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _readerTopSquareButton(
            icon: Icons.menu,
            onTap: _showImageReaderMenu,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _readerTopSquareButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black87,
            size: 23,
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
    final barColor = isDark ? const Color(0xFF232323) : Colors.white;

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
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(28),
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
                  _bottomPillButton(
                    isHighlighted: true,
                    icon: Icons.error_outline_rounded,
                    label: 'أخطاء',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ميزة الأخطاء/التسميع ستُفعّل لاحقًا',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _bottomPillButton(
                    icon: Icons.menu_book_outlined,
                    label: 'تفسير',
                    isDark: isDark,
                    onTap: _showPageTafsir,
                  ),
                  const SizedBox(width: 4),
                  _bottomPillButton(
                    icon: _hideVerses
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    label: _hideVerses ? 'إظهار' : 'إخفاء',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _hideVerses = !_hideVerses;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Material(
            color: primary.withOpacity(0.14),
            shape: const CircleBorder(),
            elevation: 8,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ميزة الميكروفون ستُفعّل لاحقًا',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFC8F8D1),
                      Color(0xFF8AF0AB),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPillButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final iconColor = isHighlighted
        ? const Color(0xFFD6A300)
        : (isDark ? Colors.white70 : Colors.black87);

    final textColor = isHighlighted
        ? const Color(0xFFD6A300)
        : (isDark ? Colors.white70 : Colors.black87);

    final pillColor = isHighlighted
        ? const Color(0xFFFFF4D6)
        : isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFF7F7F7);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: iconColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
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
                  top: topPadding,
                  bottom: bottomPadding,
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

                    _zoomController.value = Matrix4.identity();

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

  Widget _buildHizbProgressCircle({
    required Color primary,
    required bool isDark,
  }) {
    final quarter = _getCurrentQuarterInHizb();

    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: HizbQuarterPainter(
          quarter: quarter,
          activeColor: primary,
          inactiveColor: isDark
              ? Colors.white.withOpacity(0.14)
              : Colors.black.withOpacity(0.10),
        ),
        child: Center(
          child: Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _surahNames.length,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final page = _surahStartPages[index];

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            _surahNames[index],
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'تبدأ من صفحة ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          trailing: Text(
            _toArabicNum(surahNumber),
            style: GoogleFonts.cairo(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _buildJuzTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final page = _getPageForJuz(juz);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'الجزء ${_toArabicNum(juz)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'يبدأ من صفحة ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _buildHizbTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 60,
      itemBuilder: (context, index) {
        final hizb = index + 1;
        final page = _getPageForHizb(hizb);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'الحزب ${_toArabicNum(hizb)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'يبدأ من صفحة ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _quickJumpCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class HizbQuarterPainter extends CustomPainter {
  final int quarter;
  final Color activeColor;
  final Color inactiveColor;

  HizbQuarterPainter({
    required this.quarter,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.2;
    const gap = 0.18; // فراغ صغير بين القطع

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const fullQuarter = 1.57079632679; // 90°
    const startBase = -1.57079632679; // من أعلى
    final sweep = fullQuarter - gap;

    for (int i = 0; i < 4; i++) {
      final startAngle = startBase + (i * fullQuarter) + (gap / 2);

      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        i < quarter ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HizbQuarterPainter oldDelegate) {
    return oldDelegate.quarter != quarter ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}