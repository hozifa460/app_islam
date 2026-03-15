import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
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

  final Map<int, List<dynamic>> _cachedPages = {};
  final Map<int, List<dynamic>> _cachedTafsir = {};

  bool _isLoading = true;
  bool _showTafsir = false;
  bool _isDownloadingQuran = false;
  bool _showControls = false; // 👈 الأشرطة مخفية افتراضياً
  late int _currentPage;

  int _currentPlayingAyah = -1;
  bool _isPlaying = false;
  int _selectedAyah = -1;
  int _revealedAyah = -1;

  bool _isListening = false;
  String _spokenText = "";
  bool _hideAyahs = false;
  int _currentAyahToRecite = -1;
  int _wordIndexExpected = 0;
  bool _isErrorState = false;
  bool _keepListening = false;

  int _lastTappedAyah = -1;
  DateTime _lastTapTime = DateTime.now();
  Timer? _longPressTimer;

  String _selectedReciter = 'ar.alafasy';
  String _selectedReciterName = 'مشاري العفاسي';
  String _selectedTafsir = 'ar.muyassar';

  final List<Map<String, String>> _reciters = [
    {'id': 'ar.alafasy', 'name': 'مشاري العفاسي'},
    {'id': 'ar.husary', 'name': 'محمود خليل الحصري'},
    {'id': 'ar.abdulbasitmurattal', 'name': 'عبدالباسط عبدالصمد'},
    {'id': 'ar.minshawi', 'name': 'محمد صديق المنشاوي'},
    {'id': 'ar.mahermuaiqly', 'name': 'ماهر المعيقلي'},
  ];

  final List<Map<String, String>> _tafsirSources = [
    {'id': 'ar.muyassar', 'name': 'التفسير الميسر'},
    {'id': 'ar.jalalayn', 'name': 'تفسير الجلالين'},
    {'id': 'ar.qurtubi', 'name': 'تفسير القرطبي'},
    {'id': 'ar.tabari', 'name': 'تفسير الطبري (قد يتأخر)'},
    {'id': 'ar.ibnkathir', 'name': 'تفسير ابن كثير (قد يتأخر)'},
  ];

  final List<int> _surahStartPages = [1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? _surahStartPages[widget.surahNumber - 1];
    _pageController = PageController(initialPage: _currentPage - 1);
    _audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();
    _initAudioListeners();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initOfflineQuran();
  }

  void _initAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _currentPlayingAyah = -1;
            _isPlaying = false;
            // قلب الصفحة تلقائياً مع مراعاة حصار الورد
            if (_currentPage < 604 && _selectedAyah == -1) {
              if (widget.targetPage != null && _currentPage >= widget.targetPage!) return; // 🛑 حصار الختمة
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut).then((_) => _playSequence());
            }
          }
        });
      }
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _cachedPages.containsKey(_currentPage) && mounted && _selectedAyah == -1) {
        final ayahs = _cachedPages[_currentPage]!;
        if (index < ayahs.length) {
          setState(() => _currentPlayingAyah = ayahs[index]['number']);
        }
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _initOfflineQuran() async {
    setState(() => _isDownloadingQuran = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);
        _processOfflineQuranData(data);
      } else {
        final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'));
        if (response.statusCode == 200) {
          await file.writeAsString(response.body);
          final data = json.decode(response.body);
          _processOfflineQuranData(data);
        } else {
          if (mounted) setState(() { _isDownloadingQuran = false; _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isDownloadingQuran = false; _isLoading = false; });
    }
  }

  void _processOfflineQuranData(Map<String, dynamic> data) {
    Map<int, List<dynamic>> pagesMap = {};
    for (var surah in data['data']['surahs']) {
      for (var ayah in surah['ayahs']) {
        int page = ayah['page'];
        ayah['surah'] = {'name': surah['name'], 'number': surah['number']};
        pagesMap.putIfAbsent(page, () => []).add(ayah);
      }
    }

    if (mounted) {
      setState(() {
        _cachedPages.addAll(pagesMap);
        _isDownloadingQuran = false;
        _isLoading = false;
      });
      _loadTafsirData(_currentPage);
    }
  }

  Future<void> _loadPageData(int page) async {
    _loadTafsirData(page);
  }

  Future<void> _loadTafsirData(int page) async {
    if (!_showTafsir) return;
    if (_cachedTafsir.containsKey(page)) return;
    try {
      final tafsirResp = await http.get(Uri.parse('https://api.alquran.cloud/v1/page/$page/$_selectedTafsir'));
      if (tafsirResp.statusCode == 200) {
        final tafsirData = json.decode(tafsirResp.body);
        if (mounted) setState(() => _cachedTafsir[page] = tafsirData['data']['ayahs']);
      }
    } catch (e) {}
  }

  Future<void> _playSequence() async {
    if (!_cachedPages.containsKey(_currentPage)) return;
    final ayahs = _cachedPages[_currentPage]!;
    int startIndex = _selectedAyah != -1 ? ayahs.indexWhere((a) => a['number'] == _selectedAyah) : 0;
    if (startIndex == -1) startIndex = 0;

    final playlist = ConcatenatingAudioSource(children: ayahs.map((a) => AudioSource.uri(Uri.parse("https://cdn.islamic.network/quran/audio/128/$_selectedReciter/${a['number']}.mp3"))).toList());
    try {
      await _audioPlayer.setAudioSource(playlist, initialIndex: startIndex);
      _audioPlayer.play();
    } catch (e) {}
  }

  // ==========================================
  // الميكروفون
  // ==========================================
  void _listen() async {
    if (_isListening) {
      _keepListening = false;
      setState(() => _isListening = false);
      await _speech.stop();
      return;
    }

    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) status = await Permission.microphone.request();

    if (status.isGranted) {
      _keepListening = true;
      _startSpeechRecognition();
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى تفعيل المايك من الإعدادات', style: GoogleFonts.cairo()), action: SnackBarAction(label: 'الإعدادات', onPressed: openAppSettings)));
    }
  }

  void _startSpeechRecognition() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_hideAyahs && _keepListening) _startSpeechRecognition();
            else if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) {
          if (val.errorMsg == 'error_permission') return;
          if (_hideAyahs && _keepListening) _startSpeechRecognition();
          else if (mounted) setState(() => _isListening = false);
        },
      );

      if (available) {
        if (mounted) {
          setState(() {
            _isListening = true;
            _isErrorState = false;
            if (_currentAyahToRecite == -1 && _cachedPages.containsKey(_currentPage)) {
              _currentAyahToRecite = _cachedPages[_currentPage]![0]['number'];
              _wordIndexExpected = 0;
            }
          });
        }
        await _speech.listen(
          onResult: (val) {
            if (mounted) setState(() { _spokenText = val.recognizedWords; _validateRecitationSmooth(_spokenText); });
          },
          localeId: 'ar_SA', cancelOnError: false, listenMode: stt.ListenMode.dictation, partialResults: true,
        );
      }
    } catch (e) { if (mounted) setState(() => _isListening = false); }
  }

  String _normalizeText(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '').replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا').replaceAll(RegExp(r'[يىئ]'), 'ي').replaceAll(RegExp(r'[ةه]'), 'ه').replaceAll('ؤ', 'و').replaceAll(' ', '').trim();
  }

  void _validateRecitationSmooth(String spokenSegment) {
    if (_currentAyahToRecite == -1 || !_cachedPages.containsKey(_currentPage)) return;
    final ayahs = _cachedPages[_currentPage]!;
    final targetAyah = ayahs.firstWhere((a) => a['number'] == _currentAyahToRecite, orElse: () => null);
    if (targetAyah == null) return;

    String rawAyah = targetAyah['text'];
    if (targetAyah['numberInSurah'] == 1 && targetAyah['surah']['number'] != 1 && targetAyah['surah']['number'] != 9) {
      rawAyah = rawAyah.replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '').trim();
    }

    List<String> targetWords = rawAyah.split(' ');

    if (_wordIndexExpected >= targetWords.length) {
      int currentIndex = ayahs.indexWhere((a) => a['number'] == _currentAyahToRecite);
      if (currentIndex != -1 && currentIndex + 1 < ayahs.length) {
        setState(() { _currentAyahToRecite = ayahs[currentIndex + 1]['number']; _wordIndexExpected = 0; _isErrorState = false; });
      }
      return;
    }

    String expectedWord = _normalizeText(targetWords[_wordIndexExpected]);
    List<String> spokenWordsList = spokenSegment.split(' ');
    int lookBack = spokenWordsList.length > 4 ? 4 : spokenWordsList.length;
    String lastSpokenPhrases = spokenWordsList.sublist(spokenWordsList.length - lookBack).join(' ');
    String normalizedSpoken = _normalizeText(lastSpokenPhrases);

    if (normalizedSpoken.contains(expectedWord)) {
      setState(() { _isErrorState = false; _wordIndexExpected++; });
    } else {
      if (spokenWordsList.length > 3 && !_isErrorState) {
        setState(() => _isErrorState = true);
        HapticFeedback.heavyImpact();
      }
    }
  }

  String _toArabicNum(int n) {
    const nums = {'0':'٠','1':'١','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  // ==========================================
  // القوائم المنبثقة
  // ==========================================
  void _showAyahOptionsDialog(dynamic ayah) {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الآية ${_toArabicNum(ayah['numberInSurah'])}', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
              const Divider(),
              ListTile(leading: Icon(Icons.play_circle_fill, color: primary), title: Text('تشغيل من هذه الآية', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(ctx); _playSequence(); }),
              ListTile(leading: Icon(Icons.menu_book, color: primary), title: Text('تفسير الآية', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(ctx); _showTafsirSelectionDialog(ayah['numberInSurah'], ayah['number']); }),
              ListTile(leading: Icon(Icons.copy, color: primary), title: Text('نسخ الآية', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(ctx); Clipboard.setData(ClipboardData(text: "﴿ ${ayah['text']} ﴾ [${widget.surahName}: ${ayah['numberInSurah']}]")); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ بنجاح'))); }),
              ListTile(leading: Icon(Icons.share, color: primary), title: Text('مشاركة', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(ctx); Share.share("﴿ ${ayah['text']} ﴾ [${widget.surahName}: ${ayah['numberInSurah']}]"); }),
            ],
          ),
        ),
      ),
    );
  }

  void _showTafsirSelectionDialog(int ayahNumberInSurah, int globalAyahNumber) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('اختر كتاب التفسير', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ..._tafsirSources.map((t) => ListTile(
                leading: Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                title: Text(t['name']!, style: GoogleFonts.cairo()),
                onTap: () { Navigator.pop(ctx); _fetchAndShowTafsir(globalAyahNumber, t['id']!, t['name']!); },
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAndShowTafsir(int globalAyahNumber, String tafsirId, String tafsirName) async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/ayah/$globalAyahNumber/$tafsirId')).timeout(const Duration(seconds: 15));
      Navigator.pop(context);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafsirText = data['data']['text'];
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
            builder: (_, controller) => Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: controller,
                  children: [
                    Text(tafsirName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(tafsirText, style: GoogleFonts.cairo(fontSize: 16, height: 1.8)),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('عذراً، هذا التفسير غير متاح حالياً', style: GoogleFonts.cairo())));
    }
  }

  void _showReciterDialog(Color primary) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('اختر القارئ', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ..._reciters.map((r) => ListTile(
                  title: Text(r['name']!, style: GoogleFonts.cairo()),
                  leading: Icon(Icons.person, color: _selectedReciter == r['id'] ? primary : Colors.grey),
                  trailing: _selectedReciter == r['id'] ? Icon(Icons.check_circle, color: primary) : null,
                  onTap: () {
                    setState(() { _selectedReciter = r['id']!; _selectedReciterName = r['name']!; });
                    Navigator.pop(ctx);
                  }
              ))
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
    // بدلاً من: final pageBg = isDark ? const Color(0xFF151515) : const Color(0xFFFAFAFA);
// استخدم ألوان المصحف الكريم:
    final pageBg = isDark
        ? const Color(0xFF1A1A1A) // وضع ليلي داكن
        : const Color(0xFFF5F0E6); // ✅ لون كريمي (بيج) مثل المصحف الحقيقي

    final textColor = isDark
        ? const Color(0xFFE0D5C1) // نص ذهبي فاتح في الوضع الليلي
        : const Color(0xFF2C2416); // ✅ بني داكن للنص (مثل الحبر)


    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double appBarHeight = 60.0 + topPadding;
    final double bottomBarHeight = 80.0 + bottomPadding;

    // ✅ التحقق هل نحن في صفحة الورد الأخيرة
    bool isEndOfWird = widget.targetPage != null && _currentPage == widget.targetPage;

    if (_isDownloadingQuran) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primary),
              const SizedBox(height: 20),
              Text(
                'جاري إعداد المصحف الشريف...\n(يتم التحميل لمرة واحدة فقط)',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: primary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      // ❌ لا يوجد زر عائم، الميكروفون في الأسفل
      body: Stack(
        children: [
          // ================= 1. المصحف =================
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _showControls = !_showControls;
                if (!_showControls) _selectedAyah = -1;
              });
            },
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: _showControls ? appBarHeight : topPadding,
                bottom: _showControls ? bottomBarHeight : bottomPadding,
              ),
              child: PageView.builder(
                key: const PageStorageKey<String>('QuranPageView'),
                controller: _pageController,
                itemCount: 604,
                reverse: true,
                // ✅ حصار الختمة
                physics: widget.targetPage != null ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  int newPage = index + 1;

                  // 🛑 حصار الختمة: لا يتجاوز الورد
                  if (widget.targetPage != null && newPage > widget.targetPage!) {
                    _pageController.jumpToPage(widget.targetPage! - 1);
                    return;
                  }
                  if (widget.initialPage != null && newPage < widget.initialPage!) {
                    _pageController.jumpToPage(widget.initialPage! - 1);
                    return;
                  }

                  setState(() {
                    _currentPage = newPage;
                    _selectedAyah = -1;
                    _revealedAyah = -1;
                    _currentAyahToRecite = -1;

                    // إظهار الأشرطة تلقائياً إذا وصل لآخر صفحة ليضغط إتمام
                    if (newPage == widget.targetPage) {
                      _showControls = true;
                    }
                  });
                  _loadPageData(newPage);
                  if (newPage < 604) _loadPageData(newPage + 1);
                },
                itemBuilder: (context, index) {
                  int page = index + 1;
                  if (!_cachedPages.containsKey(page)) {
                    return Center(child: CircularProgressIndicator(color: primary));
                  }
                  return _buildMushafPage(page, pageBg, textColor, primary, isDark);
                },
              ),
            ),
          ),

          // ================= 2. AppBar العلوي =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -appBarHeight,
            left: 0, right: 0,
            height: appBarHeight,
            child: Container(
              padding: EdgeInsets.only(top: topPadding, left: 10, right: 10),
              decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.arrow_forward_ios, color: primary), onPressed: () => Navigator.pop(context)),
                  Text('صفحة $_currentPage', style: GoogleFonts.cairo(color: primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      // ✅ زر إتمام القراءة للختمة
                      if (isEndOfWird)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12)),
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
                          label: Text('إتمام الورد', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      if (!isEndOfWird) ...[
                        IconButton(
                            icon: const Icon(Icons.search), color: primary,
                            onPressed: () {
                              showSearch(context: context, delegate: QuranSearch(primaryColor: primary)).then((result) {
                                if (result != null) {
                                  _pageController.jumpToPage(result['page'] - 1);
                                  setState(() { _currentPage = result['page']; _selectedAyah = result['number']; _showControls = true; });
                                }
                              });
                            }
                        ),
                        IconButton(icon: Icon(_hideAyahs ? Icons.visibility_off : Icons.visibility, color: _hideAyahs ? Colors.red : primary), onPressed: () => setState(() { _hideAyahs = !_hideAyahs; _revealedAyah = -1; })),
                        IconButton(icon: Icon(_showTafsir ? Icons.menu_book : Icons.menu_book_outlined, color: primary), onPressed: () { setState(() { _showTafsir = !_showTafsir; if (_showTafsir) _loadTafsirData(_currentPage); }); }),
                      ]
                    ],
                  )
                ],
              ),
            ),
          ),

          if (_spokenText.isNotEmpty && _showControls)
            Positioned(
              top: appBarHeight + 10, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: Text('سمعتك تقول: "$_spokenText"', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
              ),
            ),

          // ================= 3. المشغل السفلي =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -bottomBarHeight,
            left: 0, right: 0,
            height: bottomBarHeight,
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPadding),
              decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))], borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primary, radius: 24,
                    child: IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28), onPressed: () { if (_isPlaying) _audioPlayer.pause(); else _playSequence(); }),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedReciterName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(_selectedAyah != -1 ? 'تشغيل الآية المحددة' : 'تشغيل الصفحة', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.record_voice_over, color: primary), onPressed: () => _showReciterDialog(primary)),

                  // ✅ زر الميكروفون هنا
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _isListening ? Colors.red : primary.withOpacity(0.5), width: 2)),
                    child: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : primary, size: 24),
                      onPressed: _listen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ بناء المصحف مع التنسيق المتصل ومحاكاة الضغطة المزدوجة
  // ✅ بناء المصحف (بدون حواف جانبية + ضغطة مطولة 100% تعمل بدون أخطاء)
  Widget _buildMushafPage(int page, Color bg, Color text, Color primary, bool isDark) {
    final ayahs = _cachedPages[page]!;
    final juz = ayahs.isNotEmpty ? ayahs.first['juz'] : '';
    final surahName = ayahs.isNotEmpty ? ayahs.first['surah']['name'] : '';
    final hizbQuarter = ayahs.isNotEmpty ? ayahs.first['hizbQuarter'] : 0;
    final hizb = hizbQuarter != 0 ? ((hizbQuarter - 1) ~/ 4) + 1 : '';

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 510,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الترويسة الدائمة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الجزء ${_toArabicNum(juz)}', style: GoogleFonts.amiri(fontSize: 14, color: text.withOpacity(0.6), fontWeight: FontWeight.bold)),
                      Text(surahName, style: GoogleFonts.amiri(fontSize: 14, color: text.withOpacity(0.6), fontWeight: FontWeight.bold)),
                      Text('الحزب ${_toArabicNum(hizb)}', style: GoogleFonts.amiri(fontSize: 14, color: text.withOpacity(0.6), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(width: double.infinity, height: 1, margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), color: text.withOpacity(0.1)),

                if (_isFirstAyahInPage(ayahs))
                  _buildSurahHeader(ayahs[0]['surah']['name'], primary, text),

                RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: ayahs.expand<InlineSpan>((ayah) {
                      final isSelected = _selectedAyah == ayah['number'];
                      final isPlayingNow = _currentPlayingAyah == ayah['number'];
                      final isHighlighted = isSelected || isPlayingNow;
                      final isRevealed = _revealedAyah == ayah['number'];
                      final isTargetForRecitation = _currentAyahToRecite == ayah['number'];

                      String ayahText = ayah['text'];
                      if (ayah['numberInSurah'] == 1 && ayah['surah']['number'] != 1 && ayah['surah']['number'] != 9) {
                        ayahText = ayahText.replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '').trim();
                      }

                      List<InlineSpan> spans = [];
                      List<String> words = ayahText.split(' ');

                      for (int i = 0; i < words.length; i++) {
                        Color wordColor = text;
                        Color? bgColor;

                        if (widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty) {
                          String cleanWord = _normalizeText(words[i]);
                          String cleanQuery = _normalizeText(widget.searchQuery!);
                          if (cleanWord.contains(cleanQuery) || cleanQuery.contains(cleanWord)) bgColor = Colors.amber.withOpacity(0.4);
                        }

                        if (_hideAyahs) {
                          wordColor = Colors.transparent; bgColor = Colors.transparent;
                          if (isRevealed) wordColor = text;
                          else if (isTargetForRecitation) {
                            if (i < _wordIndexExpected) wordColor = primary;
                            else if (i == _wordIndexExpected && _isErrorState) wordColor = Colors.red;
                          }
                        } else {
                          if (isTargetForRecitation) {
                            if (i < _wordIndexExpected) wordColor = primary;
                            else if (i == _wordIndexExpected && _isErrorState) wordColor = Colors.red;
                          }
                        }

                        // ✅ 1. الضغطة العادية للتحديد (وتعويض الضغطة المزدوجة برمجياً)
                        final tapRecognizer = TapGestureRecognizer()
                          ..onTap = () {
                            final now = DateTime.now();
                            final diff = now.difference(_lastTapTime);
                            _lastTapTime = now;

                            if (diff.inMilliseconds < 400 && _lastTappedAyah == ayah['number']) {
                              // هذه ضغطة مزدوجة: تحديد وتظليل فقط
                              setState(() {
                                _selectedAyah = ayah['number'];
                                _showControls = true;
                              });
                            } else {
                              // هذه ضغطة عادية مفردة
                              _lastTappedAyah = ayah['number'];
                              if (_hideAyahs) {
                                if (!_isListening) setState(() => _revealedAyah = ayah['number']);
                                else setState(() { _currentAyahToRecite = ayah['number']; _wordIndexExpected = 0; _isErrorState = false; });
                              }
                            }
                          };

                        // ✅ 2. هذا هو المستشعر الرسمي والمدعوم للضغطة المطولة
                        final longPressRecognizer = LongPressGestureRecognizer()
                          ..onLongPress = () {
                            if (!_hideAyahs) {
                              setState(() {
                                _selectedAyah = ayah['number'];
                                _showControls = true;
                              });
                              _showAyahOptionsDialog(ayah); // تظهر النافذة المنبثقة هنا
                            }
                          };

                        spans.add(TextSpan(
                          text: '${words[i]} ',
                          style: GoogleFonts.amiri(
                            fontSize: 26, height: 2.2, color: wordColor,
                            backgroundColor: isHighlighted ? primary.withOpacity(0.2) : bgColor,
                          ),
                          // 🪄 في فلاتر، لا يمكنك إضافة مستشعرين مباشرة لـ TextSpan
                          // لكن الأفضل هو جعل الضغطة المطولة للرقم، أو أننا نعتمد على الضغطة المزدوجة التي تعمل بالفعل.
                          // لدمج الاثنين في TextSpan يجب استخدام WidgetSpan أو الاكتفاء بواحد.

                          // سنضع tapRecognizer هنا
                          recognizer: tapRecognizer,
                        ));
                      }

                      // ✅ نضع الضغطة المطولة على رقم الآية لسهولة الاستخدام دون كسر النص
                      final tapRecognizerNum = TapGestureRecognizer()
                        ..onTap = () {
                          // ضغطة عادية على الرقم للخيارات السريعة (اختياري)
                        };

                      final longPressRecognizerNum = LongPressGestureRecognizer()
                        ..onLongPress = () {
                          if (!_hideAyahs) {
                            setState(() { _selectedAyah = ayah['number']; _showControls = true; });
                            _showAyahOptionsDialog(ayah);
                          }
                        };

                      // نستخدم WidgetSpan لرقم الآية لنتمكن من إضافة GestureDetector يدعم كل أنواع الضغطات براحة تامة!
                      spans.add(WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            setState(() { _selectedAyah = ayah['number']; _showControls = true; });
                          },
                          // ✅ الضغطة المطولة تعمل هنا بامتياز 100%
                          onLongPress: () {
                            if (!_hideAyahs) {
                              setState(() { _selectedAyah = ayah['number']; _showControls = true; });
                              _showAyahOptionsDialog(ayah);
                            }
                          },
                          child: Text(
                              '\uFD3F${_toArabicNum(ayah['numberInSurah'])}\uFD3E ',
                              style: GoogleFonts.amiri(fontSize: 24, color: primary, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ));

                      return spans;
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),
                Container(width: double.infinity, height: 1, margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), color: text.withOpacity(0.1)),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(_toArabicNum(page), style: GoogleFonts.amiri(fontSize: 16, color: text.withOpacity(0.7), fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isFirstAyahInPage(List<dynamic> ayahs) => ayahs.any((a) => a['numberInSurah'] == 1);

  Widget _buildSurahHeader(String name, Color primary, Color text) {
    return Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 10, top: 5), padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: primary.withOpacity(0.05), border: Border.all(color: primary.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [Text(name, style: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: primary)), const SizedBox(height: 2), Text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', style: GoogleFonts.amiri(fontSize: 24, color: text))]),
    );
  }
}