import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:islamic_app/screens/quran/surah_detail/sheets/arabic_language_guide.dart';
import 'package:islamic_app/screens/quran/surah_detail/sheets/ayah_options_sheet.dart';
import 'package:islamic_app/screens/quran/surah_detail/sheets/download_status_dialog.dart';
import 'package:islamic_app/screens/quran/surah_detail/sheets/quran_menu_sheets.dart';
import 'package:islamic_app/screens/quran/surah_detail/widgets/advanced_index_sheet.dart';
import 'package:islamic_app/screens/quran/surah_detail/widgets/quran_loading_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/quran/audio_recitation_service.dart';
import '../../../services/quran/ayah_audio_services.dart';
import '../../../services/quran/quran_text_service.dart';
import '../../../utils/quran/quran_text_page_view.dart';
import '../../../utils/quran/recitation_result_widget.dart';
import '../quran_search_delegate.dart';

import 'constants/surah_constants.dart';
import 'widgets/hizb_quarter_painter.dart';
import 'widgets/sheet_widgets.dart';
import 'widgets/reader_top_bar_widget.dart';
import 'widgets/reader_bottom_bar_widget.dart';
import 'widgets/mushaf_page_widget.dart';

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

  final Map<int, List<dynamic>> _pageAyahsCache = {};
  final Map<int, int> _pageToHizbQuarter = {};

  bool _areAllPagesDownloaded = false;
  bool _showControls = false;
  bool _isPlaying = false;
  bool _isPreparingQuran = true;
  bool _isBackgroundPreparing = false;
  bool _isInitialPageReady = false;
  bool _isDownloadingAllPages = false;
  String _downloadStatusMessage = '';
  final Map<int, String> _localPagePaths = {};

  String _backgroundPrepareMessage = '';
  String _quranLoadingMessage = 'جاري إعداد القرآن...';
  double _quranLoadingProgress = 0.0;
  late int _currentPage;
  String _selectedReciter = 'ar.alafasy';
  String _selectedReciterName = 'مشاري العفاسي';

  String _viewMode = 'image';

  late AyahAudioService _ayahAudioService;
  late RecitationService _recitationService;

  int _highlightedSurahNumber = -1;
  int _highlightedAyahNumber = -1;

  int _hideLevel = 0;
  final Set<int> _revealedAyahs = {};

  bool _isMicActive = false;
  String _recitationSpokenText = '';
  RecitationResult? _lastRecitationResult;

  bool _isAyahPlaying = false;
  double _playbackSpeed = 1.0;

  bool _isQuranTextLoaded = false;

  int _selectedSurahForRecitation = 0;
  int _selectedAyahForRecitation = 0;

  double _textFontSize = 26.0;

  bool _isTextHidden = false;

  StreamSubscription? _playerSubscription;

  // ✅ جديد: لتتبع الصفحات الجاري تحميلها (منع التكرار)
  final Set<int> _pagesCurrentlyDownloading = {};

  // ✅ جديد: عدد الصفحات المحملة للشاشة
  int _downloadedPagesCount = 0;
  int _totalPagesToDownload = 604;

  @override
  void initState() {
    super.initState();

    _currentPage =
        widget.initialPage ?? SurahConstants.surahStartPages[widget.surahNumber - 1];
    _pageController = PageController(initialPage: _currentPage - 1);
    _audioPlayer = AudioPlayer();

    _saveLastReadingPosition();
    _initAudioListeners();
    _loadPagesDownloadedState();
    _fastPrepareIfPossible(); // ✅ معدّل: بدون تحميل كامل تلقائي
    _setupServices();
    _loadSelectedReciter();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _pageController.dispose();
    _audioPlayer.dispose();

    try {
      _ayahAudioService.dispose();
    } catch (_) {}

    try {
      _recitationService.dispose();
    } catch (_) {}

    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  Setup & Init
  // ══════════════════════════════════════════════════════════════

  void _setupServices() {
    _ayahAudioService = AyahAudioService(
      player: _audioPlayer,
      reciterId: _selectedReciter,
    );

    _ayahAudioService.onAyahStarted = (surah, ayah) {
      if (mounted) {
        setState(() {
          _highlightedSurahNumber = surah;
          _highlightedAyahNumber = ayah;
        });
      }
    };

    _ayahAudioService.onPlayStateChanged = (playing) {
      if (mounted) setState(() => _isAyahPlaying = playing);
    };

    _ayahAudioService.onSequenceComplete = () {
      if (mounted) {
        setState(() {
          _highlightedAyahNumber = -1;
          _highlightedSurahNumber = -1;
        });
      }
    };

    _recitationService = RecitationService();

    _recitationService.onStateChanged = (state) {
      debugPrint('📱 حالة: $state');
      if (mounted) {
        setState(() {
          if (state == RecitationState.recording) {
            _isMicActive = true;
          } else if (state == RecitationState.processing) {
            _isMicActive = true;
            _recitationSpokenText = 'جاري تحليل التلاوة...';
          } else if (state == RecitationState.idle) {
            _isMicActive = false;
            _recitationSpokenText = '';
          }
        });
      }
    };

    _recitationService.onRecordingTime = (seconds) {
      if (mounted) {
        setState(() {
          _recitationSpokenText = 'جاري التسجيل... ⏱️ $seconds ث — اضغط ■ عند الانتهاء';
        });
      }
    };

    _recitationService.onPartialResult = (text) {
      if (mounted) {
        setState(() => _recitationSpokenText = text);
      }
    };

    _recitationService.onWordRevealed = (count, matches) {
      if (mounted) setState(() {});
    };

    _recitationService.onResult = (result) {
      debugPrint('📱 نتيجة: ${(result.accuracy * 100).toInt()}%');
      if (mounted) {
        setState(() {
          _lastRecitationResult = result;
          _isMicActive = false;
        });
        _showRecitationResultSheet(result);
      }
    };

    _recitationService.onError = (error) {
      debugPrint('📱 خطأ: $error');
      if (mounted) {
        setState(() {
          _isMicActive = false;
          _recitationSpokenText = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.cairo(fontSize: 12)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    };

    // ✅ النص يُحمّل تلقائياً في الخلفية (~4 ميجابايت)
    _loadQuranText();
  }

  Future<void> _initAudioListeners() async {
    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(SurahConstants.kReciterIdKey);
    final name = prefs.getString(SurahConstants.kReciterNameKey);
    if (id != null && name != null && mounted) {
      setState(() {
        _selectedReciter = id;
        _selectedReciterName = name;
      });
    }
  }

  Future<void> _saveSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SurahConstants.kReciterIdKey, _selectedReciter);
    await prefs.setString(SurahConstants.kReciterNameKey, _selectedReciterName);
  }

  /// ✅ تحميل النص تلقائياً في الخلفية (بدون تدخل المستخدم)
  Future<void> _loadQuranText() async {
    if (_isQuranTextLoaded) return;

    final isReady = await QuranTextService.ensureLoaded();

    if (!isReady) {
      debugPrint('📖 جاري تحميل نص القرآن تلقائياً (~4 ميجابايت)...');
      await QuranTextService.downloadFullQuran(
        onProgress: (progress, msg) {
          debugPrint('📖 تحميل النص: ${(progress * 100).toInt()}% - $msg');
        },
      );
    }

    if (mounted) {
      setState(() => _isQuranTextLoaded = QuranTextService.isLoaded);
      if (_isQuranTextLoaded) {
        debugPrint('📖 ✅ تم تحميل نص القرآن بنجاح');
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  Download & Page Management (✅ معدّل)
  // ══════════════════════════════════════════════════════════════

  Future<void> _loadPagesDownloadedState() async {
    final prefs = await SharedPreferences.getInstance();
    final ready = prefs.getBool(SurahConstants.kQuranPagesFullyDownloadedKey) ?? false;

    if (mounted) {
      setState(() {
        _areAllPagesDownloaded = ready;
      });
    }
  }

  Future<void> _setPagesDownloadedState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SurahConstants.kQuranPagesFullyDownloadedKey, value);

    if (mounted) {
      setState(() {
        _areAllPagesDownloaded = value;
      });
    }
  }

  Future<File> _getLocalPageFile(int page) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/quran_pages/$page.png');
  }

  Future<String?> _getLocalPagePathIfExists(int page) async {
    if (_localPagePaths.containsKey(page)) {
      return _localPagePaths[page];
    }

    final file = await _getLocalPageFile(page);
    if (await file.exists()) {
      _localPagePaths[page] = file.path;
      return file.path;
    }

    return null;
  }

  Future<String?> _downloadPageAndSave(int page) async {
    try {
      final url = SurahConstants.getPageImageUrl(page);
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final file = await _getLocalPageFile(page);

        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes, flush: true);
        _localPagePaths[page] = file.path;
        return file.path;
      }
    } catch (e) {
      debugPrint('Download page $page error: $e');
    }

    return null;
  }

  /// ✅ معدّل: إعداد سريع - يحمّل الصفحة الحالية فقط + القريبة
  Future<void> _fastPrepareIfPossible() async {
    try {
      final localPath = await _getLocalPagePathIfExists(_currentPage);

      if (localPath != null) {
        final ayahs = await _getPageAyahs(_currentPage);

        if (ayahs.isNotEmpty) {
          final hizbQuarter = ayahs.first['hizbQuarter'];
          _pageToHizbQuarter[_currentPage] = hizbQuarter;
        }

        if (mounted) {
          setState(() {
            _isInitialPageReady = true;
            _isPreparingQuran = false;
          });
        }

        // ✅ تحميل الصفحات القريبة فقط (ليس الكل)
        _preloadNearbyPages(_currentPage);
        return;
      }

      await _prepareInitialSelectedPage();
    } catch (e) {
      debugPrint('fastPrepareIfPossible error: $e');
      await _prepareInitialSelectedPage();
    }
  }

  /// ✅ معدّل: إعداد الصفحة الأولى بدون تشغيل تحميل كامل
  Future<void> _prepareInitialSelectedPage() async {
    final localPath = await _getLocalPagePathIfExists(_currentPage);

    try {
      final ayahs = await _getPageAyahs(_currentPage);

      if (ayahs.isNotEmpty) {
        final hizbQuarter = ayahs.first['hizbQuarter'];
        _pageToHizbQuarter[_currentPage] = hizbQuarter;
      }
    } catch (e) {
      debugPrint('Initial page ayahs preload error: $e');
    }

    if (localPath != null) {
      if (mounted) {
        setState(() {
          _isInitialPageReady = true;
          _isPreparingQuran = false;
        });
      }
      // ✅ تحميل الصفحات القريبة
      _preloadNearbyPages(_currentPage);
      return;
    }

    await _downloadPageAndSave(_currentPage);

    if (mounted) {
      setState(() {
        _isInitialPageReady = true;
        _isPreparingQuran = false;
      });
    }

    // ✅ تحميل الصفحات القريبة بعد عرض الصفحة الحالية
    _preloadNearbyPages(_currentPage);
  }

  /// ✅ جديد: تحميل صورة صفحة إذا لم تكن محملة (مع منع التكرار)
  Future<void> _ensurePageImageCached(int page) async {
    if (page < 1 || page > 604) return;
    if (_localPagePaths.containsKey(page)) return;
    if (_pagesCurrentlyDownloading.contains(page)) return;

    _pagesCurrentlyDownloading.add(page);

    try {
      final localPath = await _getLocalPagePathIfExists(page);
      if (localPath == null) {
        await _downloadPageAndSave(page);
      }
    } finally {
      _pagesCurrentlyDownloading.remove(page);
    }
  }

  /// ✅ معدّل: تحميل الصفحات القريبة (نص + صور)
  void _preloadNearbyPages(int page) {
    // ترتيب الأولوية: التالية ثم السابقة ثم الأبعد
    final nearbyPages = [page + 1, page - 1, page + 2, page - 2, page + 3, page - 3];

    for (final p in nearbyPages) {
      if (p >= 1 && p <= 604) {
        // تحميل النص
        if (!_pageAyahsCache.containsKey(p)) {
          _getPageAyahs(p);
        }

        // ✅ جديد: تحميل الصورة
        _ensurePageImageCached(p);
      }
    }
  }

  /// ✅ يبقى كما هو لكن يُستدعى فقط عند طلب المستخدم
  Future<void> _downloadAllPagesInBackground() async {
    if (_isDownloadingAllPages || _areAllPagesDownloaded) return;

    if (mounted) {
      setState(() {
        _isDownloadingAllPages = true;
        _isBackgroundPreparing = true;
        _downloadedPagesCount = 0;
        _backgroundPrepareMessage = 'جاري تنزيل صفحات القرآن...';
      });
    }

    int failedCount = 0;
    int consecutiveFails = 0;
    int downloadedSoFar = 0;

    try {
      // أولاً: عد الصفحات المحملة مسبقاً
      for (int page = 1; page <= 604; page++) {
        final localPath = await _getLocalPagePathIfExists(page);
        if (localPath != null) downloadedSoFar++;
      }

      if (mounted) {
        setState(() => _downloadedPagesCount = downloadedSoFar);
      }

      for (int page = 1; page <= 604; page++) {
        if (!mounted) return;

        final localPath = await _getLocalPagePathIfExists(page);
        if (localPath == null) {
          final result = await _downloadPageAndSave(page);
          if (result == null) {
            failedCount++;
            consecutiveFails++;

            if (consecutiveFails >= 10) {
              debugPrint('⚠️ توقف التحميل: لا يوجد اتصال');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'توقف التحميل - تحقق من الاتصال بالإنترنت',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.orange,
                    action: SnackBarAction(
                      label: 'إعادة المحاولة',
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _isDownloadingAllPages = false;
                          _isBackgroundPreparing = false;
                        });
                        _downloadAllPagesInBackground();
                      },
                    ),
                  ),
                );
              }
              break;
            }
          } else {
            consecutiveFails = 0;
            downloadedSoFar++;
          }
        }

        if (mounted && page % 10 == 0) {
          setState(() {
            _downloadedPagesCount = downloadedSoFar;
            _backgroundPrepareMessage =
            'جاري تنزيل صفحات القرآن... (${SurahConstants.toArabicNum(downloadedSoFar)}/٦٠٤)';
          });
        }
      }

      if (failedCount == 0) {
        await _setPagesDownloadedState(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تم تنزيل القرآن بالكامل للعمل بدون إنترنت ✅',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isBackgroundPreparing = false;
          _isDownloadingAllPages = false;
          _backgroundPrepareMessage = '';
        });
      }
    } catch (e) {
      debugPrint('Download all pages error: $e');

      if (mounted) {
        setState(() {
          _isBackgroundPreparing = false;
          _isDownloadingAllPages = false;
          _backgroundPrepareMessage = '';
        });
      }
    }
  }

  Future<List<dynamic>> _getPageAyahs(int page) async {
    if (_pageAyahsCache.containsKey(page)) {
      return _pageAyahsCache[page]!;
    }

    if (QuranTextService.isLoaded) {
      final localAyahs = QuranTextService.getPageAyahs(page);
      if (localAyahs.isNotEmpty) {
        final converted = localAyahs
            .map((a) => <String, dynamic>{
          'text': a['text'],
          'numberInSurah': a['numberInSurah'],
          'number': a['number'],
          'hizbQuarter': a['hizbQuarter'],
          'juz': a['juz'],
          'surah': {
            'number': a['surahNumber'],
            'name': a['surahName'],
          },
        })
            .toList();

        _pageAyahsCache[page] = converted;

        if (converted.isNotEmpty) {
          final hizbQuarter = converted.first['hizbQuarter'];
          _pageToHizbQuarter.putIfAbsent(page, () => hizbQuarter);
        }

        return converted;
      }
    }

    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = List<dynamic>.from(data['data']['ayahs']);

        _pageAyahsCache[page] = ayahs;

        if (ayahs.isNotEmpty) {
          final hizbQuarter = ayahs.first['hizbQuarter'];
          _pageToHizbQuarter.putIfAbsent(page, () => hizbQuarter);
        }

        return ayahs;
      }
    } catch (e) {
      debugPrint('API page $page error: $e');
    }

    return [];
  }

  int _getCurrentPageHizbQuarterSync(int page) {
    final cached = _pageAyahsCache[page];
    if (cached != null && cached.isNotEmpty) {
      return cached.first['hizbQuarter'] ?? 1;
    }

    return _pageToHizbQuarter[page] ?? 1;
  }

  int _getCurrentQuarterInHizb() {
    final hizbQuarter = _getCurrentPageHizbQuarterSync(_currentPage);
    return ((hizbQuarter - 1) % 4) + 1;
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

  // ══════════════════════════════════════════════════════════════
  //  ✅ جديد: تأكيد تحميل جميع الصفحات
  // ══════════════════════════════════════════════════════════════

  /// ✅ جديد: حوار تأكيد تحميل القرآن كاملاً
  Future<void> _showDownloadAllConfirmation() async {
    if (_areAllPagesDownloaded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('القرآن محمّل بالكامل بالفعل ✅', style: GoogleFonts.cairo()),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    if (_isDownloadingAllPages) {
      _showQuranDownloadStatusDialog();
      return;
    }

    final downloadedCount = await _getDownloadedPagesCount();
    final remainingCount = 604 - downloadedCount;
    final estimatedSizeMB = (remainingCount * 0.3).toStringAsFixed(0);

    if (!mounted) return;

    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ═══ العنوان (ثابت) ═══
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.download_rounded, color: primary, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'تحميل القرآن كاملاً',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ═══ المحتوى (قابل للتمرير) ═══
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سيتم تحميل جميع صفحات المصحف لتتمكن من القراءة بدون إنترنت.',
                                  style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
                                ),
                                const SizedBox(height: 12),

                                // معلومات التحميل
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primary.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildInfoRow(
                                        Icons.pages_outlined,
                                        'المتبقية',
                                        '${SurahConstants.toArabicNum(remainingCount)} صفحة',
                                        primary,
                                      ),
                                      if (downloadedCount > 0) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.check_circle_outline,
                                          'المحمّل',
                                          '${SurahConstants.toArabicNum(downloadedCount)} صفحة',
                                          Colors.green,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        Icons.storage_outlined,
                                        'الحجم التقريبي',
                                        '~$estimatedSizeMB ميجابايت',
                                        Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // تنبيه WiFi
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.wifi, size: 16, color: Colors.orange.shade700),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'يُنصح بالاتصال بشبكة WiFi',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // شريط التقدم
                                if (downloadedCount > 0) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: downloadedCount / 604,
                                      backgroundColor: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(primary),
                                      minHeight: 5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(downloadedCount / 604 * 100).toInt()}% مكتمل',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // ═══ الأزرار (ثابتة في الأسفل) ═══
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'لاحقاً',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(ctx, true),
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: Text(
                                  'تحميل الآن',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _downloadAllPagesInBackground();
    }
  }

  /// ✅ جديد: صف معلومات في حوار التأكيد
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Navigation
  // ══════════════════════════════════════════════════════════════

  void _jumpToPage(int page) {
    if (page < 1 || page > 604) return;

    _pageController.jumpToPage(page - 1);

    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    _saveLastReadingPosition();
  }

  Future<void> _saveLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SurahConstants.kLastPageKey, _currentPage);
    await prefs.setString(SurahConstants.kLastSurahKey, widget.surahName);
  }

  Future<void> _saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SurahConstants.kBookmarkPageKey, _currentPage);
    await prefs.setString(SurahConstants.kBookmarkSurahKey, widget.surahName);

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
    final page = prefs.getInt(SurahConstants.kLastPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يوجد موضع محفوظ سابقًا', style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    await _saveLastReadingPosition();
  }

  Future<void> _goToBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(SurahConstants.kBookmarkPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد علامة محفوظة', style: GoogleFonts.cairo())),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    await _saveLastReadingPosition();
  }

  Future<Map<String, dynamic>> _getSavedReadingMeta() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'lastPage': prefs.getInt(SurahConstants.kLastPageKey),
      'lastSurah': prefs.getString(SurahConstants.kLastSurahKey),
      'bookmarkPage': prefs.getInt(SurahConstants.kBookmarkPageKey),
      'bookmarkSurah': prefs.getString(SurahConstants.kBookmarkSurahKey),
    };
  }

  // ══════════════════════════════════════════════════════════════
  //  Audio & Recitation
  // ══════════════════════════════════════════════════════════════

  void _switchViewMode(String mode) {
    if (mode == 'text' || mode == 'memorize') {
      if (!_isQuranTextLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'جاري تحميل نص القرآن، يرجى الانتظار...',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _viewMode = mode;
      if (mode != 'memorize') {
        _hideLevel = 0;
        _revealedAyahs.clear();
      }
    });
  }

  Future<void> _playCurrentPageAudio() async {
    if (_isAyahPlaying) {
      _ayahAudioService.pause();
      return;
    }

    if (_ayahAudioService.isPaused) {
      _ayahAudioService.resume();
      return;
    }

    if (!_isQuranTextLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'جاري تحميل نص القرآن، يرجى الانتظار...',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadQuranText();
      if (!_isQuranTextLoaded) return;
    }

    final ayahs = QuranTextService.getPageAyahs(_currentPage);
    if (ayahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد آيات في هذه الصفحة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_viewMode == 'image') {
      setState(() => _viewMode = 'text');
    }

    _ayahAudioService.reciterId = _selectedReciter;
    await _ayahAudioService.playPage(page: _currentPage);
  }

  void _stopAudio() {
    _ayahAudioService.stop();
    setState(() {
      _highlightedAyahNumber = -1;
      _highlightedSurahNumber = -1;
      _isAyahPlaying = false;
    });
  }

  Future<void> _handleMicTap() async {
    if (_recitationService.state == RecitationState.recording) {
      debugPrint('🎤 إيقاف التسجيل وبدء التحليل...');
      setState(() {
        _recitationSpokenText = 'جاري تحليل التلاوة...';
      });
      await _recitationService.stop();
      return;
    }

    if (_recitationService.state == RecitationState.processing) {
      debugPrint('🎤 جاري التحليل، انتظر...');
      return;
    }

    if (_recitationService.state != RecitationState.idle) {
      await _recitationService.cancel();
      setState(() {
        _isMicActive = false;
        _recitationSpokenText = '';
      });
      return;
    }

    if (!_isQuranTextLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري تحميل النص...', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadQuranText();
      if (!_isQuranTextLoaded) return;
    }

    final ready = await _recitationService.initialize();
    if (!ready) return;

    final ayahs = QuranTextService.getPageAyahs(_currentPage);
    if (ayahs.isEmpty) return;

    if (_viewMode == 'image') {
      setState(() => _viewMode = 'text');
      await Future.delayed(const Duration(milliseconds: 400));
    }

    setState(() {
      _isMicActive = true;
      _recitationSpokenText = 'اقرأ الآن... اضغط ■ عند الانتهاء';
      _isTextHidden = false;
    });

    await _recitationService.startForPage(page: _currentPage);
  }

  Future<void> _startRecitation() async {
    if (_isMicActive) {
      await _recitationService.stop();
      setState(() {
        _isMicActive = false;
        _recitationSpokenText = '';
      });
      return;
    }

    final ayahs = QuranTextService.getPageAyahs(_currentPage);
    if (ayahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لم يتم تحميل نص الصفحة بعد', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int targetAyahIndex = 0;
    if (_highlightedAyahNumber > 0) {
      targetAyahIndex = ayahs.indexWhere(
            (a) => a['numberInSurah'] == _highlightedAyahNumber + 1,
      );
      if (targetAyahIndex < 0) targetAyahIndex = 0;
    }

    final targetAyah = ayahs[targetAyahIndex];
    _selectedSurahForRecitation = targetAyah['surahNumber'];
    _selectedAyahForRecitation = targetAyah['numberInSurah'];

    setState(() {
      _isMicActive = true;
      _recitationSpokenText = '';
      _lastRecitationResult = null;
      _highlightedSurahNumber = _selectedSurahForRecitation;
      _highlightedAyahNumber = _selectedAyahForRecitation;
    });

    await _recitationService.startForAyah(
      surahNumber: _selectedSurahForRecitation,
      ayahNumber: _selectedAyahForRecitation,
    );
  }

  Future<void> _openGoogleSpeechSettings() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.language, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'العربية غير متوفرة، جاري فتح الإعدادات لتحميلها...',
                style: GoogleFonts.cairo(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (Platform.isAndroid) {
      try {
        final launched = await launchUrl(
          Uri.parse('market://details?id=com.google.android.googlequicksearchbox'),
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (e) {
        debugPrint('محاولة فشلت: $e');
      }

      _showArabicLanguageGuide();
    } else {
      await openAppSettings();
    }
  }

  void _showArabicLanguageGuide() {
    ArabicLanguageGuide.show(context);
  }

  void _showRecitationResultSheet(RecitationResult result) {
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return RecitationResultWidget(
          result: result,
          primaryColor: primary,
          onRetry: () {
            Navigator.pop(ctx);
            _startRecitation();
          },
          onNext: () {
            Navigator.pop(ctx);
            setState(() {
              _selectedAyahForRecitation++;
              _highlightedAyahNumber = _selectedAyahForRecitation;
            });
            _startRecitation();
          },
          onClose: () => Navigator.pop(ctx),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Download Status (✅ معدّل)
  // ══════════════════════════════════════════════════════════════

  Future<int> _getDownloadedPagesCount() async {
    int count = 0;
    for (int page = 1; page <= 604; page++) {
      final file = await _getLocalPageFile(page);
      if (await file.exists()) {
        count++;
      }
    }
    return count;
  }

  /// ✅ معدّل: نص الحالة أوضح
  String _getQuranDownloadStatusText() {
    if (_isDownloadingAllPages || _isBackgroundPreparing) {
      return 'جاري تنزيل صفحات القرآن...';
    }
    if (_areAllPagesDownloaded) {
      return 'القرآن محمّل بالكامل ✅';
    }
    return 'تحميل القرآن للقراءة بدون إنترنت';
  }

  /// ✅ معدّل: عند الضغط يعرض التأكيد أو حالة التحميل
  Future<void> _handleQuranDownloadStatusTap() async {
    if (_isDownloadingAllPages) {
      await _showQuranDownloadStatusDialog();
    } else if (_areAllPagesDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('القرآن محمّل بالكامل ✅', style: GoogleFonts.cairo()),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ✅ عرض حوار التأكيد بدلاً من التحميل المباشر
      await _showDownloadAllConfirmation();
    }
  }

  Future<void> _showQuranDownloadStatusDialog() async {
    final downloadedPages = await _getDownloadedPagesCount();
    if (!mounted) return;

    await DownloadStatusDialog.show(
      context: context,
      downloadedPages: downloadedPages,
      isDownloading: _isDownloadingAllPages,
      isBackgroundPreparing: _isBackgroundPreparing,
      areAllPagesDownloaded: _areAllPagesDownloaded,
      backgroundMessage: _backgroundPrepareMessage,
      onResumeDownload: _downloadAllPagesInBackground,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Sheets
  // ══════════════════════════════════════════════════════════════

  void _showReciterDialog(Color primary) {
    QuranMenuSheets.showReciterDialog(
      context: context,
      selectedReciterId: _selectedReciter,
      primary: primary,
      onReciterSelected: (id, name) {
        setState(() {
          _selectedReciter = id;
          _selectedReciterName = name;
        });
        _saveSelectedReciter();
      },
    );
  }

  void _showQuickJumpSheet() {
    QuranMenuSheets.showQuickJump(
      context: context,
      currentPage: _currentPage,
      primary: Theme.of(context).colorScheme.primary,
      onPageSelected: _jumpToPage,
    );
  }

  void _showViewModeSheet() {
    QuranMenuSheets.showViewMode(
      context: context,
      currentMode: _viewMode,
      primary: Theme.of(context).colorScheme.primary,
      onModeSelected: _switchViewMode,
    );
  }

  void _showAdvancedIndexSheet() async {
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
      builder: (ctx) => AdvancedIndexSheet(
        currentPage: _currentPage,
        savedMeta: saved,
        onPageSelected: _jumpToPage,
        onGoToLastPosition: _goToLastReadingPosition,
        onGoToBookmark: _goToBookmark,
        getPageForHizb: _getPageForHizb,
      ),
    );
  }

  void _showImageReaderMenu() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();
    if (!mounted) return;

    QuranMenuSheets.showMainMenu(
      context: context,
      surahName: widget.surahName,
      selectedReciterName: _selectedReciterName,
      savedMeta: saved,
      primary: primary,
      onIndexTap: _showAdvancedIndexSheet,
      onSearchTap: () {
        showSearch(
          context: context,
          delegate: QuranSearch(primaryColor: primary),
        ).then((result) {
          if (result != null) _jumpToPage(result['page']);
        });
      },
      onQuickJumpTap: _showQuickJumpSheet,
      onLastPositionTap: _goToLastReadingPosition,
      onBookmarkTap: _goToBookmark,
      onReciterTap: () => _showReciterDialog(primary),
    );
  }

  void _showAyahOptionsSheet(int surahNumber, int ayahNumber) {
    AyahOptionsSheet.show(
      context: context,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      primary: Theme.of(context).colorScheme.primary,
      onPlayTap: () {
        _ayahAudioService.reciterId = _selectedReciter;
        _ayahAudioService.playAyah(surahNumber, ayahNumber);
      },
      onRepeatTap: () {
        _ayahAudioService.reciterId = _selectedReciter;
        _ayahAudioService.repeatAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          times: 3,
        );
      },
      onRecitateTap: () async {
        final ready = await _recitationService.initialize();
        if (!ready) return;

        if (!_recitationService.isArabicAvailable) {
          await _openGoogleSpeechSettings();
          _recitationService.resetInit();
          return;
        }

        if (_viewMode == 'image') {
          setState(() => _viewMode = 'text');
          await Future.delayed(const Duration(milliseconds: 300));
        }

        _selectedSurahForRecitation = surahNumber;
        _selectedAyahForRecitation = ayahNumber;

        setState(() {
          _highlightedSurahNumber = surahNumber;
          _highlightedAyahNumber = ayahNumber;
          _isMicActive = true;
          _recitationSpokenText = '';
          _isTextHidden = false;
        });

        _recitationService.startForAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        );
      },
      onBookmarkTap: _saveBookmark,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Build Methods
  // ══════════════════════════════════════════════════════════════

  /// ✅ معدّل: شريط التحميل يظهر فقط عند طلب المستخدم
  Widget _buildBackgroundPreparingBanner(Color primary) {
    final progress = _downloadedPagesCount / 604;

    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _showQuranDownloadStatusDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _backgroundPrepareMessage,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // ✅ جديد: نسبة التقدم
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // ✅ جديد: شريط تقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMushafPage(
      int page, Color bg, Color text, Color primary, bool isDark) {
    final hizbQuarter = _getCurrentPageHizbQuarterSync(page);

    final currentPageAyahs = _pageAyahsCache[page];
    String currentSurahName;
    if (currentPageAyahs != null && currentPageAyahs.isNotEmpty) {
      final apiName =
          currentPageAyahs.first['surah']?['name']?.toString() ?? '';
      currentSurahName = apiName.replaceFirst(RegExp(r'^سورة\s*'), '');
      if (currentSurahName.isEmpty) {
        currentSurahName = widget.surahName;
      }
    } else {
      currentSurahName = widget.surahName;
    }

    return MushafPageWidget(
      page: page,
      bgColor: bg,
      textColor: text,
      primary: primary,
      isDark: isDark,
      surahName: currentSurahName,
      hizbQuarter: hizbQuarter,
      currentQuarterInHizb: _getCurrentQuarterInHizb(),
      getLocalPagePath: _getLocalPagePathIfExists,
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

    if (_isPreparingQuran && !_isInitialPageReady) {
      return QuranLoadingView(
        primary: primary,
        bgColor: pageBg,
        message: _quranLoadingMessage,
        progress: _quranLoadingProgress,
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
                  onPageChanged: (index) {
                    final page = index + 1;
                    setState(() {
                      _currentPage = page;
                    });
                    // ✅ تحميل الصفحات القريبة (نص + صور)
                    _preloadNearbyPages(page);
                    _saveLastReadingPosition();

                    if (_isAyahPlaying) {
                      _stopAudio();
                    }

                    if (_isMicActive) {
                      _recitationService.stop();
                      setState(() {
                        _isMicActive = false;
                        _recitationSpokenText = '';
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final page = index + 1;

                    if (_viewMode == 'image') {
                      return _buildMushafPage(
                        page, pageBg, textColor, primary, isDark,
                      );
                    }

                    return Container(
                      color: pageBg,
                      child: QuranTextPage(
                        page: page,
                        primaryColor: primary,
                        isDark: isDark,
                        fontSize: _textFontSize,
                        isHidden: _isTextHidden && !_isMicActive,
                        hideLevel: _viewMode == 'memorize' ? _hideLevel : 0,
                        isReciting: _isMicActive && page == _currentPage,
                        wordMatches: (page == _currentPage)
                            ? _recitationService.wordMatches
                            : [],
                        revealedWordCount: (page == _currentPage)
                            ? _recitationService.revealedWordCount
                            : 0,
                        highlightedSurah: _highlightedSurahNumber,
                        highlightedAyah: _highlightedAyahNumber,
                        onAyahTap: (surah, ayah) {
                          if (_viewMode == 'memorize') {
                            setState(() {
                              if (_revealedAyahs.contains(ayah)) {
                                _revealedAyahs.remove(ayah);
                              } else {
                                _revealedAyahs.add(ayah);
                              }
                            });
                          } else {
                            setState(() {
                              _highlightedSurahNumber = surah;
                              _highlightedAyahNumber = ayah;
                            });
                          }
                        },
                        onAyahLongPress: _showAyahOptionsSheet,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ✅ معدّل: يظهر فقط عند تحميل يدوي
          if (_isBackgroundPreparing && _backgroundPrepareMessage.isNotEmpty)
            _buildBackgroundPreparingBanner(primary),

          // Top Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -(topBarHeight + 10),
            left: 0,
            right: 0,
            height: topBarHeight,
            child: ReaderTopBarWidget(
              primary: primary,
              isDark: isDark,
              topPadding: topPadding,
              surahName: widget.surahName,
              currentPage: _currentPage,
              hizbQuarter: _getCurrentPageHizbQuarterSync(_currentPage),
              isDownloading: _isDownloadingAllPages,
              areAllPagesDownloaded: _areAllPagesDownloaded,
              isBackgroundPreparing: _isBackgroundPreparing,
              onMenuTap: _showImageReaderMenu,
              onSearchTap: () {
                showSearch(
                  context: context,
                  delegate: QuranSearch(primaryColor: primary),
                ).then((result) {
                  if (result != null) {
                    _jumpToPage(result['page']);
                  }
                });
              },
              // ✅ معدّل: يعرض التأكيد أو الحالة
              onDownloadStatusTap: _handleQuranDownloadStatusTap,
            ),
          ),

          // Bottom Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -200,
            left: 0,
            right: 0,
            child: ReaderBottomBarWidget(
              primary: primary,
              isDark: isDark,
              bottomPadding: bottomPadding,
              viewMode: _viewMode,
              isAyahPlaying: _isAyahPlaying,
              isMicActive: _isMicActive,
              isTextHidden: _isTextHidden,
              hideLevel: _hideLevel,
              recitationSpokenText: _recitationSpokenText,
              recitationState: _recitationService.state,
              onViewModeTap: _showViewModeSheet,
              onPlayPauseTap: () {
                if (_isAyahPlaying) {
                  _ayahAudioService.pause();
                } else if (_ayahAudioService.isPaused == true) {
                  _ayahAudioService.resume();
                } else {
                  _playCurrentPageAudio();
                }
              },
              onHideToggleTap: () {
                setState(() {
                  _isTextHidden = !_isTextHidden;
                  if (_isTextHidden && _viewMode == 'image') {
                    _viewMode = 'text';
                  }
                });
              },
              onMicTap: _handleMicTap,
              onHideLevelChanged: (level) {
                setState(() => _hideLevel = level);
              },
            ),
          ),
        ],
      ),
    );
  }
}