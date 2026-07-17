import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/quran/ayah_audio_services.dart';
import '../../../services/quran/quran_text_service.dart';
import '../../../services/quran/quran_reading_service.dart';
import '../../../utils/quran/quran_text_page_view.dart';
import '../../../utils/quran/warsh_tajweed_annotations.dart';
import '../quran_search_delegate.dart';
import 'constants/surah_constants.dart';
import 'sheets/quran_menu_sheets.dart';
import 'widgets/advanced_index_sheet.dart';
import 'widgets/quran_loading_view.dart';
import 'widgets/reader_bottom_bar_widget.dart';
import 'widgets/reader_top_bar_widget.dart';

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
  late final PageController _pageController;
  late final AudioPlayer _audioPlayer;
  late final AyahAudioService _ayahAudioService;

  StreamSubscription<PlayerState>? _playerSubscription;
  late int _currentPage;
  bool _isPreparingQuran = false;
  bool _showControls = false;
  bool _showAudioPanel = false;
  bool _showWarshTajweedLegend = true;
  bool _isAyahPlaying = false;
  bool _isTextHidden = false;
  String _viewMode = 'text';
  int _hideLevel = 0;
  final double _textFontSize = 26;
  int _highlightedSurahNumber = -1;
  int _highlightedAyahNumber = -1;
  String _selectedReciter = 'ar.alafasy';
  String _selectedReciterName = 'مشاري العفاسي';
  QuranReading _selectedReading = QuranReading.hafs;

  static const _readingPreferenceKey = 'quran_selected_reading_v1';

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.initialPage ??
        SurahConstants.surahStartPages[widget.surahNumber - 1];
    _pageController = PageController(initialPage: _currentPage - 1);
    _audioPlayer = AudioPlayer();
    _ayahAudioService = AyahAudioService(
      player: _audioPlayer,
      reciterId: _selectedReciter,
    );
    _setupAudioCallbacks();
    _loadSelectedReciter();
    _prepareQuranText();
    _removeLegacyImageCache();
    _saveLastReadingPosition();
  }

  void _setupAudioCallbacks() {
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
    _ayahAudioService.onSequenceComplete = _clearAudioHighlight;
    _ayahAudioService.onError = (message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo()),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted &&
          !state.playing &&
          state.processingState == ProcessingState.completed) {
        _clearAudioHighlight();
      }
    });
  }

  void _clearAudioHighlight() {
    if (!mounted) return;
    setState(() {
      _isAyahPlaying = false;
      _highlightedSurahNumber = -1;
      _highlightedAyahNumber = -1;
    });
  }

  Future<void> _prepareQuranText() async {
    final prefs = await SharedPreferences.getInstance();
    final reading = QuranReadingInfo.fromId(
      prefs.getString(_readingPreferenceKey),
    );
    var ready = false;
    if (reading == QuranReading.hafs) {
      ready = await QuranTextService.ensureLoaded();
      if (!ready) {
        // Do not lock the reader for a network download.  The user must still
        // be able to open the menu and switch to an offline reading such as
        // Warsh, whose text is packaged with the app.
        _downloadHafsInBackground();
        ready = true;
      }
    } else {
      ready = await QuranReadingService.ensureLoaded(reading);
    }
    if (!mounted) return;
    if (ready && reading != QuranReading.hafs) {
      _pageController.jumpToPage(0);
    }
    setState(() {
      _selectedReading = reading;
      _currentPage = reading == QuranReading.hafs ? _currentPage : 1;
      _isPreparingQuran = false;
      if (reading == QuranReading.hafs && !QuranTextService.isLoaded) {
        _showControls = true;
      }
    });
    if (!ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل نص القرآن. تحقق من الاتصال ثم أعد فتح الصفحة.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _downloadHafsInBackground() {
    QuranTextService.downloadFullQuran().then((ready) {
      if (!mounted || ready) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تنزيل نص حفص الآن. يمكنك اختيار ورش من مصاحف القراءات.',
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  /// The image reader is retired. Remove its old 604-page cache on upgrade.
  Future<void> _removeLegacyImageCache() async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      final cache = Directory('${documents.path}/quran_pages');
      if (await cache.exists()) await cache.delete(recursive: true);
    } catch (_) {
      // A cleanup failure must never block the text reader.
    }
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(SurahConstants.kReciterIdKey);
    final name = prefs.getString(SurahConstants.kReciterNameKey);
    if (!mounted || id == null || name == null) return;
    if (!SurahConstants.isSupportedReciter(id)) {
      await prefs.remove(SurahConstants.kReciterIdKey);
      await prefs.remove(SurahConstants.kReciterNameKey);
      return;
    }
    setState(() {
      _selectedReciter = id;
      _selectedReciterName = name;
      _ayahAudioService.reciterId = id;
    });
  }

  Future<void> _saveSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SurahConstants.kReciterIdKey, _selectedReciter);
    await prefs.setString(SurahConstants.kReciterNameKey, _selectedReciterName);
  }

  Future<void> _saveLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_readingKey(SurahConstants.kLastPageKey), _currentPage);
    await prefs.setString(
      _readingKey(SurahConstants.kLastSurahKey),
      widget.surahName,
    );
  }

  String _readingKey(String key) => '${key}_${_selectedReading.id}';

  Future<Map<String, dynamic>> _getSavedReadingMeta() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lastPage': prefs.getInt(_readingKey(SurahConstants.kLastPageKey)),
      'lastSurah': prefs.getString(_readingKey(SurahConstants.kLastSurahKey)),
      'bookmarkPage': prefs.getInt(
        _readingKey(SurahConstants.kBookmarkPageKey),
      ),
      'bookmarkSurah': prefs.getString(
        _readingKey(SurahConstants.kBookmarkSurahKey),
      ),
    };
  }

  Future<void> _jumpToPage(int page) async {
    if (page < 1 || page > _selectedReading.pageCount) return;
    await _pageController.animateToPage(
      page - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    setState(() {
      _currentPage = page;
      _showControls = true;
    });
    await _saveLastReadingPosition();
  }

  Future<void> _goToLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await _jumpToPage(
      prefs.getInt(_readingKey(SurahConstants.kLastPageKey)) ?? _currentPage,
    );
  }

  Future<void> _goToBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_readingKey(SurahConstants.kBookmarkPageKey));
    if (page != null) await _jumpToPage(page);
  }

  int _getPageForHizb(int hizb) {
    final targetQuarter = (hizb - 1) * 4 + 1;
    for (var page = 1; page <= 604; page++) {
      final ayahs = QuranTextService.getPageAyahs(page);
      if (ayahs.isNotEmpty && ayahs.first['hizbQuarter'] == targetQuarter) {
        return page;
      }
    }
    return 1;
  }

  void _switchViewMode(String mode) {
    setState(() {
      _viewMode = mode;
      if (mode != 'memorize') _hideLevel = 0;
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
    _ayahAudioService.reciterId = _selectedReciter;
    await _ayahAudioService.playPage(page: _currentPage);
  }

  void _showQuickJumpSheet() {
    QuranMenuSheets.showQuickJump(
      context: context,
      currentPage: _currentPage,
      maxPage: _selectedReading.pageCount,
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

  Future<void> _showAdvancedIndexSheet() async {
    if (_selectedReading != QuranReading.hafs) {
      _showReadingScopeNotice();
      return;
    }
    final saved = await _getSavedReadingMeta();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF171A1E)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => AdvancedIndexSheet(
            currentPage: _currentPage,
            savedMeta: saved,
            onPageSelected: _jumpToPage,
            onGoToLastPosition: _goToLastReadingPosition,
            onGoToBookmark: _goToBookmark,
            getPageForHizb: _getPageForHizb,
          ),
    );
  }

  void _showReadingScopeNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'فهرس الأجزاء والبحث الصوتي سيُفعّلان بعد إتمام فهرس ورش المستقل.',
          style: GoogleFonts.cairo(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showReaderMenu() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();
    if (!mounted) return;
    QuranMenuSheets.showMainMenu(
      context: context,
      surahName: widget.surahName,
      readingLabel: _selectedReading.label,
      selectedReciterName: _selectedReciterName,
      isAudioAvailable: _selectedReading.supportsHafsAudio,
      savedMeta: saved,
      primary: primary,
      onIndexTap: _showAdvancedIndexSheet,
      onSearchTap: () => _openSearch(primary),
      onQuickJumpTap: _showQuickJumpSheet,
      onLastPositionTap: _goToLastReadingPosition,
      onBookmarkTap: _goToBookmark,
      onReciterTap: () {
        setState(() {
          _showControls = true;
          _showAudioPanel = true;
        });
      },
      onReadingTap: _showReadingPicker,
      onWarshTajweedTap:
          _selectedReading == QuranReading.warshAnNafiAzraq
              ? _showWarshTajweedSheet
              : null,
    );
  }

  void _showWarshTajweedSheet() {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF171A1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ألوان رواية ورش عن نافع',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final rule in WarshTajweedAnnotations.legendRules)
                    _WarshRuleTile(
                      color: rule.color,
                      title: rule.title,
                      subtitle: rule.subtitle,
                      isEnabled: rule.isEnabled,
                    ),
                  _WarshRuleTile(
                    color: Colors.grey,
                    title: 'قصر مد البدل',
                    subtitle: 'وجه صحيح بديل، لكنه غير مفعّل في هذا العرض.',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ألوان مد البدل والإدغام مفعّلة. أما الألوان الأخرى فهي محفوظة في المفتاح لحين ربطها بمواضع مراجَعة؛ حتى لا يُنسب حكم غير دقيق إلى الرواية.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      setState(() => _showWarshTajweedLegend = false);
                    },
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(
                      'إخفاء مفتاح الألوان',
                      style: GoogleFonts.cairo(),
                    ),
                    style: OutlinedButton.styleFrom(foregroundColor: primary),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showReadingPicker() async {
    final primary = Theme.of(context).colorScheme.primary;
    final selected = await showModalBottomSheet<QuranReading>(
      context: context,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF171A1E)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'مصاحف القراءات',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اختر النص وتخطيط صفحاته المطابقين للرواية',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  for (final reading in QuranReading.values)
                    ListTile(
                      leading: Icon(Icons.menu_book_rounded, color: primary),
                      title: Text(reading.label, style: GoogleFonts.cairo()),
                      subtitle: Text(
                        reading == QuranReading.hafs
                            ? '604 صفحات — الاستماع متاح'
                            : '603 صفحات — نص مستقل، والاستماع مؤجل للتوثيق',
                        style: GoogleFonts.cairo(fontSize: 11),
                      ),
                      trailing:
                          reading == _selectedReading
                              ? Icon(Icons.check_circle, color: primary)
                              : null,
                      onTap: () => Navigator.pop(sheetContext, reading),
                    ),
                ],
              ),
            ),
          ),
    );
    if (selected == null || selected == _selectedReading) return;
    await _selectReading(selected);
  }

  Future<void> _selectReading(QuranReading reading) async {
    final ready =
        reading == QuranReading.hafs
            ? await QuranTextService.ensureLoaded()
            : await QuranReadingService.ensureLoaded(reading);
    if (!mounted) return;
    if (!ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر التحقق من بيانات الرواية؛ لم يتم تغيير المصحف.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    _ayahAudioService.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingPreferenceKey, reading.id);
    _pageController.jumpToPage(0);
    setState(() {
      _selectedReading = reading;
      _currentPage = 1;
      _showAudioPanel = false;
    });
    await _saveLastReadingPosition();
  }

  void _openSearch(Color primary) {
    if (_selectedReading != QuranReading.hafs) {
      _showReadingScopeNotice();
      return;
    }
    showSearch(
      context: context,
      delegate: QuranSearch(primaryColor: primary),
    ).then((result) {
      if (result != null) _jumpToPage(result['page'] as int);
    });
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _ayahAudioService.dispose();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD);
    final media = MediaQuery.of(context);
    final topBarHeight = media.padding.top + 68.0;
    final currentPageAyahs =
        _selectedReading == QuranReading.hafs
            ? QuranTextService.getPageAyahs(_currentPage)
            : const <Map<String, dynamic>>[];
    final currentPageSurahName =
        _selectedReading != QuranReading.hafs
            ? _selectedReading.label
            : currentPageAyahs.isEmpty
            ? widget.surahName
            : (currentPageAyahs.first['surahName'] as String)
                .replaceFirst(RegExp(r'^سُ?و?رَ?ةُ?\s*'), '')
                .trim();
    final currentHizbQuarter =
        currentPageAyahs.isEmpty
            ? 1
            : currentPageAyahs.first['hizbQuarter'] as int;

    if (_isPreparingQuran) {
      return QuranLoadingView(
        primary: primary,
        bgColor: pageBg,
        message: 'جاري إعداد نص القرآن...',
        progress: 0.35,
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showControls = !_showControls),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _selectedReading.pageCount,
                onPageChanged: (index) {
                  setState(() => _currentPage = index + 1);
                  _ayahAudioService.stop();
                  _saveLastReadingPosition();
                },
                itemBuilder:
                    (_, index) =>
                        _selectedReading == QuranReading.hafs
                            ? QuranTextPage(
                              page: index + 1,
                              primaryColor: primary,
                              isDark: isDark,
                              fontSize: _textFontSize,
                              isHidden: _isTextHidden,
                              hideLevel:
                                  _viewMode == 'memorize' ? _hideLevel : 0,
                              bottomPadding: 18,
                              highlightedSurah: _highlightedSurahNumber,
                              highlightedAyah: _highlightedAyahNumber,
                            )
                            : WarshTextPage(
                              page: index + 1,
                              isDark: isDark,
                              bottomPadding:
                                  _showControls && _showWarshTajweedLegend
                                      ? 86
                                      : 18,
                              showTajweedColors: true,
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
            child: ReaderTopBarWidget(
              primary: primary,
              isDark: isDark,
              topPadding: media.padding.top,
              surahName: currentPageSurahName,
              currentPage: _currentPage,
              hizbQuarter: currentHizbQuarter,
              onMenuTap: _showReaderMenu,
              onSearchTap: () => _openSearch(primary),
            ),
          ),
          AnimatedPositionedDirectional(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            bottom:
                _selectedReading == QuranReading.warshAnNafiAzraq &&
                        _showControls &&
                        !_showWarshTajweedLegend
                    ? 14 + media.padding.bottom
                    : -64,
            end: 14,
            child: Material(
              color: primary,
              elevation: 4,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'إظهار مفتاح الألوان',
                color: Colors.white,
                onPressed: () => setState(() => _showWarshTajweedLegend = true),
                icon: const Icon(Icons.palette_outlined),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            bottom:
                _selectedReading == QuranReading.warshAnNafiAzraq &&
                        _showControls &&
                        _showWarshTajweedLegend
                    ? 0
                    : -96,
            left: 0,
            right: 0,
            height: 82 + media.padding.bottom,
            child: SafeArea(
              top: false,
              child: _WarshLegendBar(
                isDark: isDark,
                onTap: _showWarshTajweedSheet,
                onClose: () => setState(() => _showWarshTajweedLegend = false),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            bottom:
                _selectedReading.supportsHafsAudio && _showControls ? 0 : -520,
            left: 0,
            right: 0,
            child: ReaderBottomBarWidget(
              primary: primary,
              isDark: isDark,
              bottomPadding: media.padding.bottom,
              viewMode: _viewMode,
              showAudioPanel: _showAudioPanel,
              isAyahPlaying: _isAyahPlaying,
              isTextHidden: _isTextHidden,
              hideLevel: _hideLevel,
              currentAyah: _ayahAudioService.currentAyah,
              audioPlayer: _audioPlayer,
              reciters: SurahConstants.reciters,
              selectedReciterId: _selectedReciter,
              selectedReciterName: _selectedReciterName,
              onListenTap: () => setState(() => _showAudioPanel = true),
              onCloseAudioPanel: () => setState(() => _showAudioPanel = false),
              onViewModeTap: _showViewModeSheet,
              onPlayPauseTap: _playCurrentPageAudio,
              onHideToggleTap:
                  () => setState(() => _isTextHidden = !_isTextHidden),
              onHideLevelChanged: (level) => setState(() => _hideLevel = level),
              onReciterSelected: (id, name) {
                _ayahAudioService.stop();
                setState(() {
                  _selectedReciter = id;
                  _selectedReciterName = name;
                  _ayahAudioService.reciterId = id;
                });
                _saveSelectedReciter();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WarshLegendBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _WarshLegendBar({
    required this.isDark,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF1B1E21) : Colors.white;
    final shadow = isDark ? Colors.black54 : Colors.black12;
    return Material(
      color: surface,
      elevation: 8,
      shadowColor: shadow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 10, 8),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: WarshTajweedAnnotations.maddBadal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مد البدل والإدغام',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'التوسط ٤ حركات — قصره وجه بديل',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'إخفاء مفتاح الألوان',
                onPressed: onClose,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarshRuleTile extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool isEnabled;

  const _WarshRuleTile({
    required this.color,
    required this.title,
    required this.subtitle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: isEnabled ? 1 : .56,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.cairo(fontSize: 12)),
      trailing:
          isEnabled
              ? const Icon(Icons.check_circle_outline_rounded, size: 19)
              : const Icon(Icons.pending_outlined, size: 19),
    ),
  );
}
