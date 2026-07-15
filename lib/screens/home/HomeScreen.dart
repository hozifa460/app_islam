import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:islamic_app/screens/home/services/home_cards_order_service.dart';
import 'package:islamic_app/screens/home/widget/home_azkar_card.dart';
import 'package:islamic_app/screens/home/widget/home_background.dart';
import 'package:islamic_app/screens/home/widget/home_channels_preview_card.dart';
import 'package:islamic_app/screens/home/widget/home_drawer.dart';
import 'package:islamic_app/screens/home/widget/home_hadith_card.dart';
import 'package:islamic_app/screens/home/widget/home_header_slider.dart';
import 'package:islamic_app/screens/home/widget/home_miracle_card.dart';
import 'package:islamic_app/screens/home/widget/home_prayer_card.dart';
import 'package:islamic_app/screens/home/widget/home_quick_grid.dart';
import 'package:islamic_app/screens/home/widget/home_radio_card.dart';
import 'package:islamic_app/screens/home/widget/home_reorder_sheet.dart';
import 'package:islamic_app/screens/home/widget/home_sunnah_card.dart';
import 'package:islamic_app/screens/home/widget/home_verse_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../hijri/data/hijri_data.dart';
import '../hijri/hijri_calendar_screen.dart';
import '../prayer/more/controllers/prayer_times_controller.dart';
import '../prayer/core/prayer_time_core.dart';
import '../../languages/app_localizations.dart';
import '../../services/great_muslims_service.dart';
import '../../services/native_adhan_bridge.dart';

import '../GreatMuslim/great_muslims_screen.dart';
import '../prayer/muzzin_settings/muzzin_settings.dart';
import '../prayer/prayer_times_screen/prayer_time_screen.dart';
import '../books/books_screen.dart';
import '../hadith/hadith_screen.dart';
import '../qibla/qibla_splash_screen.dart';
import '../quran/quran_screen.dart';
import '../Azkar/azkar_screen.dart';
import '../radio/radio_screen.dart';
import '../sunnah/sunnah_tracker_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../qibla/qibla_screen.dart';
import '../dua/dua_screen.dart';
import '../settings/settings_screen.dart';
import '../hasanat/hasanat_screen.dart';
import '../khatma/khatma_screen.dart';
import '../channels/channels_screen.dart';
import '../AsmaAllah/asma_allah_screen.dart';
import '../mircle/miracles_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(int) onColorChanged;
  final bool isDarkMode;
  final int selectedColorIndex;
  final List<Color> appColors;
  final List<String> colorNames;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.selectedColorIndex,
    required this.appColors,
    required this.colorNames,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Color get _primary => widget.appColors[widget.selectedColorIndex];
  static const Color _gold = Color(0xFFC8A44D);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _homeScrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );

  // â•گâ•گ FIX #1: طھظ‚ظ„ظٹظ„ AnimationControllers â€” ط¯ظ…ط¬ ط§ظ„ط£ظ†ظٹظ…ظٹط´ظ†ط§طھ â•گâ•گ
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _prayerPulseController;
  late Animation<double> _prayerPulseAnim;

  late Animation<double> _fadeHeader;
  late Animation<double> _fadePrayer;
  late Animation<double> _fadeVerse;
  late Animation<double> _fadeAzkar;
  late Animation<double> _fadeGrid;
  late Animation<double> _fadeHadith;
  late Animation<double> _fadeSunnah;
  late Animation<double> _fadeMiracle;

  late Animation<Offset> _slideHeader;
  late Animation<Offset> _slidePrayer;
  late Animation<Offset> _slideVerse;
  late Animation<Offset> _slideAzkar;
  late Animation<Offset> _slideGrid;
  late Animation<Offset> _slideHadith;
  late Animation<Offset> _slideSunnah;
  late Animation<Offset> _slideMiracle;

  String _currentTime = '';
  Timer? _timer;
  String _cityName = '';

  List<Map<String, dynamic>> _azkarCategories = [];
  bool _azkarLoaded = false;

  // â•گâ•گ FIX #2: ط¥ط²ط§ظ„ط© طھظƒط±ط§ط± ط§ظ„ط¨ظٹط§ظ†ط§طھ â€” ط§ط³طھط®ط¯ط§ظ… Provider ظ…ط¨ط§ط´ط±ط© â•گâ•گ
  String _nextPrayerName = '...';
  String _timeLeft = '';
  bool _isSchedulingNotifications = false;

  late PageController _heroPageController;
  // â•گâ•گ FIX #11: ط§ط³طھط®ط¯ط§ظ… ValueNotifier ط¨ط¯ظ„ setState ظ„ظ„ظ€ PageView â•گâ•گ
  final ValueNotifier<int> _currentHeroNotifier = ValueNotifier<int>(0);
  Timer? _heroTimer;

  List<GreatMuslim> _greatMuslims = [];
  bool _greatMuslimsLoaded = false;
  bool _hijriDataLoaded = false;

  List<Map<String, dynamic>> _allMiracles = [];
  bool _miraclesLoaded = false;
  Map<String, dynamic>? _dailyMiracle;

  List<HomeCard> _cardsOrder = [];
  bool _cardsOrderLoaded = false;

  Map<String, String> currentVerseOfDay = {'verse': '', 'surah': ''};
  Map<String, String> currentHadithOfDay = {'text': '', 'source': ''};

  // â•گâ•گ FIX #12: ظƒط§ط´ ظ„ظ„ظ‚ظˆط§ط¦ظ… ط§ظ„ظ…طھظƒط±ط±ط© â•گâ•گ
  List<Map<String, dynamic>>? _cachedFeatures;
  List<Map<String, dynamic>>? _cachedPrayerInfo;
  String? _lastFeaturesLocale;
  String? _lastPrayerInfoLocale;

  static const List<Map<String, dynamic>> _featureIcons = [
    {'icon': Icons.menu_book_rounded, 'badge': '📖'},
    {'icon': Icons.access_time_filled_rounded, 'badge': '🕌'},
    {'icon': Icons.auto_awesome_rounded, 'badge': '✨'},
    {'icon': Icons.touch_app_rounded, 'badge': '📿'},
    {'icon': Icons.format_quote_rounded, 'badge': '📜'},
    {'icon': Icons.emoji_events_rounded, 'badge': '🏰'},
    {'icon': Icons.track_changes, 'badge': '🎯'},
    {'icon': Icons.live_tv_rounded, 'badge': '🔴'},
    {'icon': Icons.explore_rounded, 'badge': '🧭'},
    {'icon': Icons.favorite_rounded, 'badge': '🤲'},
    {'icon': Icons.local_library_rounded, 'badge': '📚'},
    {'icon': Icons.volume_up_rounded, 'badge': '🎙️'},
    {'icon': Icons.volume_up_rounded, 'badge': '📜'},
    {'icon': Icons.volume_up_rounded, 'badge': '📜'},
    {'icon': Icons.military_tech_rounded, 'badge': '🏛️'},
    {'icon': Icons.settings_rounded, 'badge': '⚙️'},
  ];

  final List<Map<String, dynamic>> _prayerInfo = [
    {'key': 'Fajr', 'icon': Icons.nightlight_round},
    {'key': 'Sunrise', 'icon': Icons.wb_sunny_outlined},
    {'key': 'Dhuhr', 'icon': Icons.wb_sunny},
    {'key': 'Asr', 'icon': Icons.sunny_snowing},
    {'key': 'Maghrib', 'icon': Icons.wb_twilight},
    {'key': 'Isha', 'icon': Icons.nights_stay},
  ];

  final List<Map<String, String>> dailyVerses = const [
    {
      'verse': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'surah': 'الطلاق - ٢',
    },
    {'verse': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح - ٥'},
    {
      'verse': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'surah': 'البقرة - ٢٨٦',
    },
    {'verse': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'surah': 'طه - ١١٤'},
    {
      'verse': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'surah': 'الرعد - ٢٨',
    },
  ];

  final List<Map<String, String>> dailyHadiths = const [
    {
      'text': '« إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ »',
      'source': 'رواه البخاري',
    },
    {'text': '« الدِّينُ النَّصِيحَةُ »', 'source': 'رواه مسلم'},
    {'text': '« الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ »', 'source': 'رواه البخاري'},
    {
      'text': '« تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ »',
      'source': 'رواه الترمذي',
    },
    {
      'text': '« خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ »',
      'source': 'رواه البخاري',
    },
  ];

  // â•گâ•گ FIX #12: ظƒط§ط´ Features ظˆ PrayerInfo â•گâ•گ
  List<Map<String, dynamic>> _buildFeatures(AppLocalizations tr) {
    final locale = "tr.localeName";
    if (_cachedFeatures != null && _lastFeaturesLocale == locale) {
      return _cachedFeatures!;
    }
    final titles = tr.featuresList;
    _cachedFeatures = List.generate(
      titles.length,
      (i) => {
        'title': titles[i]['title'],
        'subtitle': titles[i]['subtitle'],
        'icon': _featureIcons[i]['icon'],
        'badge': _featureIcons[i]['badge'],
      },
    );
    _lastFeaturesLocale = locale;
    return _cachedFeatures!;
  }

  List<Map<String, dynamic>> _buildPrayerInfo(AppLocalizations tr) {
    final locale = "tr.localeName";
    if (_cachedPrayerInfo != null && _lastPrayerInfoLocale == locale) {
      return _cachedPrayerInfo!;
    }
    final names = [tr.fajr, tr.sunrise, tr.dhuhr, tr.asr, tr.maghrib, tr.isha];
    _cachedPrayerInfo = List.generate(
      _prayerInfo.length,
      (i) => {
        'name': names[i],
        'key': _prayerInfo[i]['key'],
        'icon': _prayerInfo[i]['icon'],
      },
    );
    _lastPrayerInfoLocale = locale;
    return _cachedPrayerInfo!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScrollListener();
    _initHeroController();
    _initAnimations();
    _initData();
  }

  void _initScrollListener() {
    _homeScrollController.addListener(() {
      _scrollOffsetNotifier.value = _homeScrollController.offset;
    });
  }

  void _initHeroController() {
    _heroPageController = PageController(viewportFraction: 0.90);
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted ||
          !_heroPageController.hasClients ||
          _greatMuslims.isEmpty) {
        return;
      }
      final nextPage = (_currentHeroNotifier.value + 1) % _greatMuslims.length;
      _heroPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _prayerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _prayerPulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _prayerPulseController, curve: Curves.easeInOut),
    );

    // â•گâ•گ FIX #9: ط¥ظٹظ‚ط§ظپ ط§ظ„ط£ظ†ظٹظ…ظٹط´ظ†ط§طھ ط§ظ„ظ…طھظƒط±ط±ط© ط¹ظ†ط¯ظ…ط§ طھظƒطھظ…ظ„ ط§ظ„ط¯ط®ظˆظ„ â•گâ•گ
    // _pulseController ظˆ _prayerPulseController ظٹط¨ظ‚ظˆظ† ظ„ط£ظ†ظ‡ظ… visual feedback
    // ظ„ظƒظ† _animController ظٹطھظˆظ‚ظپ ط¨ط¹ط¯ ط§ظ†طھظ‡ط§ط، ط§ظ„ط¯ط®ظˆظ„ (forward ظپظ‚ط·)

    _fadeMiracle = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.42, 0.70, curve: Curves.easeOut),
    );
    _slideMiracle = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.42, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _fadeHeader = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
    );
    _fadePrayer = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.10, 0.38, curve: Curves.easeOut),
    );
    _fadeVerse = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.22, 0.50, curve: Curves.easeOut),
    );
    _fadeAzkar = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.34, 0.62, curve: Curves.easeOut),
    );
    _fadeGrid = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.46, 0.78, curve: Curves.easeOut),
    );
    _fadeHadith = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.60, 1.00, curve: Curves.easeOut),
    );
    _fadeSunnah = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
    );

    _slideHeader = _buildSlide(0.00, 0.25);
    _slidePrayer = _buildSlide(0.10, 0.38);
    _slideVerse = _buildSlide(0.22, 0.50);
    _slideAzkar = _buildSlide(0.34, 0.62);
    _slideGrid = _buildSlide(0.46, 0.78);
    _slideHadith = _buildSlide(0.60, 1.00);
    _slideSunnah = _buildSlide(0.38, 0.65);
  }

  // â•گâ•گ FIX: طھظ‚ظ„ظٹظ„ ط§ظ„طھظƒط±ط§ط± ظپظٹ ط¨ظ†ط§ط، ط§ظ„ط£ظ†ظٹظ…ظٹط´ظ†ط§طھ â•گâ•گ
  Animation<Offset> _buildSlide(double begin, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _initData() {
    _checkRescheduleAfterBoot();
    _setDailyContent();
    _loadAzkarJson();
    _updateTime();
    _loadGreatMuslims();
    _loadDailyMiracle();
    _loadCardsOrder();

    Future.microtask(() async {
      if (!mounted) return;
      await context
          .read<PrayerTimesController>()
          .refreshLocationAndPrayerTimes();
    });

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      _initLocationAndPrayersSafe();
    });

    // â•گâ•گ FIX #1: Timer ط£ط°ظƒظ‰ â€” ظپظ‚ط· ظٹط­ط¯ظ‘ط« ط¥ط°ط§ طھط؛ظٹط± ط´ظٹط، â•گâ•گ
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final prayerController = context.read<PrayerTimesController>();
      final newPrayerTimes = prayerController.prayerTimes;

      _updateTime();

      if (newPrayerTimes.isNotEmpty) {
        final oldNext = _nextPrayerName;
        final oldLeft = _timeLeft;
        _calculateNextPrayer(newPrayerTimes);

        // â•گâ•گ FIX: ظپظ‚ط· setState ط¥ط°ط§ طھط؛ظٹط± ط´ظٹط، ظپط¹ظ„ط§ظ‹ â•گâ•گ
        if (oldNext != _nextPrayerName || oldLeft != _timeLeft) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _heroTimer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    _heroPageController.dispose();
    _homeScrollController.dispose();
    _scrollOffsetNotifier.dispose();
    _prayerPulseController.dispose();
    _currentHeroNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<PrayerTimesController>().refreshLocationAndPrayerTimes();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hijriDataLoaded) {
      _loadHijriDataSafe();
    }
  }

  Future<void> _loadHijriDataSafe() async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      await HijriData.loadData(langCode);
      if (mounted) setState(() => _hijriDataLoaded = true);
    } catch (e) {
      debugPrint('خطأ تحميل الهجري: $e');
      if (mounted) setState(() => _hijriDataLoaded = true);
    }
  }

  Future<void> _loadDailyMiracle() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/mircle/miracles.json',
      );
      final List<dynamic> data = json.decode(jsonString);
      final miracles = data.map((e) => Map<String, dynamic>.from(e)).toList();
      if (miracles.isEmpty) return;

      final now = DateTime.now();
      final daySeed = now.year * 10000 + now.month * 100 + now.day;
      final miracleIndex = daySeed % miracles.length;

      if (mounted) {
        setState(() {
          _allMiracles = miracles;
          _dailyMiracle = miracles[miracleIndex];
          _miraclesLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ تحميل معجزة اليوم: $e');
    }
  }

  Future<void> _loadCardsOrder() async {
    final order = await HomeCardsOrderService.loadOrder();
    if (mounted) {
      setState(() {
        _cardsOrder = order;
        _cardsOrderLoaded = true;
      });
    }
  }

  Future<void> _openReorderSheet() async {
    final result = await HomeReorderSheet.show(
      context,
      cards: _cardsOrder,
      primary: _primary,
      isDark: widget.isDarkMode,
    );

    if (result != null && mounted) {
      setState(() => _cardsOrder = result);
      await HomeCardsOrderService.saveOrder(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ ترتيب البطاقات ✓',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCardById(
    String id,
    Color cardColor,
    bool isDark,
    List<Map<String, dynamic>> features,
    List<Map<String, dynamic>> prayerInfoTranslated,
    Map<String, String> prayerTimes,
    String cityName,
    bool isPrayerLoading,
  ) {
    switch (id) {
      case 'header_slider':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeHeader,
            slide: _slideHeader,
            // â•گâ•گ FIX #11: ValueListenableBuilder ط¨ط¯ظ„ setState â•گâ•گ
            child: ValueListenableBuilder<int>(
              valueListenable: _currentHeroNotifier,
              builder: (_, currentIndex, __) {
                return HomeHeaderSlider(
                  primary: _primary,
                  gold: _gold,
                  greatMuslims: _greatMuslims,
                  isLoaded: _greatMuslimsLoaded,
                  pageController: _heroPageController,
                  currentIndex: currentIndex,
                  onPageChanged: (i) {
                    _currentHeroNotifier.value = i;
                  },
                );
              },
            ),
          ),
        );

      case 'prayer':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadePrayer,
            slide: _slidePrayer,
            child: HomePrayerCard(
              primary: _primary,
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
              prayerTimes: prayerTimes,
              cityName: cityName,
              isPrayerLoading: isPrayerLoading,
              nextPrayerName: _nextPrayerName,
              timeLeft: _timeLeft,
              prayerInfo: prayerInfoTranslated,
              prayerPulseAnim: _prayerPulseAnim,
              onTap: () => _navigateToScreen(1),
            ),
          ),
        );

      case 'miracle':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeMiracle,
            slide: _slideMiracle,
            child: HomeMiracleCard(
              primary: _primary,
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
              miracle: _dailyMiracle,
              isLoaded: _miraclesLoaded,
            ),
          ),
        );

      case 'channels':
        return RepaintBoundary(
          child: HomeChannelsPreviewCard(
            primary: _primary,
            gold: _gold,
            isDark: isDark,
            cardColor: cardColor,
          ),
        );

      case 'sunnah':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeSunnah,
            slide: _slideSunnah,
            child: HomeSunnahCard(
              primaryColor: _primary,
              gold: _gold,
              isDark: isDark,
              onNavigateToTracker: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => SunnahTrackerScreen(
                          isDarkMode: isDark,
                          onToggleTheme:
                              () => widget.onThemeChanged(!widget.isDarkMode),
                        ),
                  ),
                );
              },
            ),
          ),
        );

      case 'radio':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeSunnah,
            slide: _slideSunnah,
            child: HomeRadioCard(
              primary: _primary,
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
            ),
          ),
        );

      case 'verse':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeVerse,
            slide: _slideVerse,
            child: HomeVerseCard(
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
              verse: currentVerseOfDay,
            ),
          ),
        );

      case 'azkar':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeAzkar,
            slide: _slideAzkar,
            child: HomeAzkarCard(
              primary: _primary,
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
              currentTitle: _getCurrentAzkarTitle(),
              currentIcon: _getCurrentAzkarIcon(),
              currentCategory: _getCurrentAzkarCategoryFromJson(),
              isMorning: _isMorningAzkarTime(),
            ),
          ),
        );

      case 'quick_grid':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeGrid,
            slide: _slideGrid,
            child: HomeQuickGrid(
              primary: _primary,
              gold: _gold,
              cardColor: cardColor,
              isDark: isDark,
              onItemTap: _navigateToScreen,
            ),
          ),
        );

      case 'hadith':
        return RepaintBoundary(
          child: _animatedSection(
            fade: _fadeHadith,
            slide: _slideHadith,
            child: HomeHadithCard(
              primary: _primary,
              isDark: isDark,
              hadith: currentHadithOfDay,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // â•گâ•گ FIX #8: ط¥ط²ط§ظ„ط© clearCache ط§ظ„ط؛ظٹط± ط¶ط±ظˆط±ظٹ â•گâ•گ
  Future<void> _loadGreatMuslims() async {
    try {
      final data = await GreatMuslimsService.load();
      if (mounted) {
        setState(() {
          _greatMuslims = data;
          _greatMuslimsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ HomeScreen خطأ: $e');
    }
  }

  Future<void> _loadAzkarJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/azkar/azkar.json');
      final List<dynamic> data = json.decode(jsonString);
      if (!mounted) return;
      setState(() {
        _azkarCategories =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
        _azkarLoaded = true;
      });
    } catch (e) {
      debugPrint('Home azkar load error: $e');
    }
  }

  // â•گâ•گ FIX #7: ظƒط§ط´ ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ظٹظˆظ…ظٹ â•گâ•گ
  void _setDailyContent() async {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final verseIndex = daySeed % dailyVerses.length;
    final hadithIndex = daySeed % dailyHadiths.length;

    // طھط¹ظٹظٹظ† ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ظپظˆط±ط§ظ‹ ط¨ط¯ظˆظ† setState ظ„ط£ظ†ظ‡ ظ‚ط¨ظ„ ط£ظˆظ„ build
    currentVerseOfDay = dailyVerses[verseIndex];
    currentHadithOfDay = dailyHadiths[hadithIndex];

    try {
      final dir = await getApplicationDocumentsDirectory();
      final quranFile = File('${dir.path}/quran_uthmani_v1.json');
      if (await quranFile.exists()) {
        final quranData = json.decode(await quranFile.readAsString());
        final surahs = quranData['data']['surahs'] as List;
        final surah = surahs[daySeed % 114];
        final ayahs = surah['ayahs'] as List;
        final ayah = ayahs[daySeed % ayahs.length];

        if (mounted) {
          setState(() {
            currentVerseOfDay = {
              'verse':
                  ayah['text']
                      .toString()
                      .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
                      .trim(),
              'surah': '${surah['name']} - آية ${ayah['numberInSurah']}',
            };
          });
        }
      }

      final hadithFile = File('${dir.path}/hadith_forty_v1.json');
      if (await hadithFile.exists()) {
        final hadithData = json.decode(await hadithFile.readAsString());
        final hadithsList = hadithData['hadiths'] as List;
        final hadith = hadithsList[daySeed % hadithsList.length];

        if (mounted) {
          setState(() {
            currentHadithOfDay = {
              'text':
                  hadith['text']
                      .toString()
                      .replaceAll(RegExp(r'<[^>]*>'), '')
                      .trim(),
              'source': 'رقم الحديث: ${hadith['hadithnumber']}',
            };
          });
        }
      }
    } catch (_) {}
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    _currentTime = '$hour:${now.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _initLocationAndPrayersSafe() async {
    final prayerController = context.read<PrayerTimesController>();
    final prayerTimes = prayerController.prayerTimes;
    _calculateNextPrayer(prayerTimes);
    setState(() {});
    await _schedulePrayerNotifications();
  }

  Future<void> _checkRescheduleAfterBoot() async {
    final prefs = await SharedPreferences.getInstance();
    final needsReschedule =
        prefs.getBool('needs_reschedule_after_boot') ?? false;
    if (!needsReschedule) return;

    await _schedulePrayerNotifications();
    await prefs.setBool('needs_reschedule_after_boot', false);

    if (mounted) {
      final tr = context.tr;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.adhanRescheduled, style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (!mounted || _isSchedulingNotifications) return;
    _isSchedulingNotifications = true;
    try {
      // الجدولة الوحيدة أصبحت NativePrayerScheduler للجدول ذي 14 يومًا.
      // هذا يمنع تكرار أذان الصفحة الرئيسية مع أذان شاشة المواقيت.
      await NativeAdhanBridge.rescheduleSavedPrayerSchedule();
    } catch (e) {
      debugPrint('❌ تعذر إعادة جدولة جدول الصلاة المحفوظ: $e');
    } finally {
      _isSchedulingNotifications = false;
    }
  }

  void _calculateNextPrayer(Map<String, String> prayerTimes) {
    if (prayerTimes.isEmpty || !mounted) return;

    final tr = context.tr;
    final controller = context.read<PrayerTimesController>();
    final now = PrayerClock.nowAt(controller.timeZoneId);
    DateTime? nextPrayerTime;
    String nextName = '';

    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayerNames = {
      'Fajr': tr.fajr,
      'Sunrise': tr.sunrise,
      'Dhuhr': tr.dhuhr,
      'Asr': tr.asr,
      'Maghrib': tr.maghrib,
      'Isha': tr.isha,
    };

    for (final key in prayerOrder) {
      final timeStr = prayerTimes[key];
      if (timeStr == null) continue;
      final time = _parseTime(timeStr);
      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextName = prayerNames[key]!;
        break;
      }
    }

    if (nextPrayerTime == null) {
      nextName = tr.fajr;
      final fajrStr = prayerTimes['Fajr'];
      if (fajrStr != null) {
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        nextPrayerTime = PrayerClock.wallTime(
          date: tomorrow,
          time: controller.tomorrowPrayerTimes['Fajr'] ?? fajrStr,
          timeZoneId: controller.timeZoneId,
        );
      } else {
        nextPrayerTime = now.add(const Duration(hours: 1));
      }
    }

    final diff = nextPrayerTime.difference(now);
    final timeLeftString =
        diff.inHours > 0
            ? '${diff.inHours}${tr.hoursAnd} ${diff.inMinutes % 60}${tr.minuteShort}'
            : '${diff.inMinutes} ${tr.minuteWord}';

    _nextPrayerName = nextName;
    _timeLeft = timeLeftString;
  }

  DateTime _parseTime(String timeStr) {
    final controller = context.read<PrayerTimesController>();
    final now = PrayerClock.nowAt(controller.timeZoneId);
    try {
      return PrayerClock.wallTime(
        date: now,
        time: timeStr,
        timeZoneId: controller.timeZoneId,
      );
    } catch (_) {
      return now;
    }
  }

  Future<void> _refreshLocationAndPrayerTimes() async {
    await context.read<PrayerTimesController>().refreshLocationAndPrayerTimes(
      forceLocation: true,
    );
    if (!mounted) return;

    final tr = context.tr;
    final prayerController = context.read<PrayerTimesController>();
    _calculateNextPrayer(prayerController.prayerTimes);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr.locationUpdated, style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<Map<String, String>?> _applyCalculationMethod(String methodKey) async {
    final result = await context
        .read<PrayerTimesController>()
        .applyCalculationMethod(methodKey);

    if (!mounted) return result;
    final prayerController = context.read<PrayerTimesController>();
    _calculateNextPrayer(prayerController.prayerTimes);
    setState(() {});

    return result;
  }

  Future<void> _applyReminderOffset(int offset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_offset', offset);
      await prefs.setBool('reminder_enabled', offset > 0);
      await _schedulePrayerNotifications();
    } catch (e) {
      debugPrint('❌ apply reminder offset error: $e');
    }
  }

  void _navigateToScreen(int index) async {
    if (!mounted) return;

    final primaryColor = _primary;
    final prayerController = context.read<PrayerTimesController>();
    Widget? screen;

    switch (index) {
      case 0:
        screen = const QuranScreen();
        break;
      case 1:
        screen = PrayerTimesScreen(
          primaryColor: primaryColor,
          prayerTimes:
              prayerController.prayerTimes.isNotEmpty
                  ? prayerController.prayerTimes
                  : null,
          cityName:
              prayerController.cityName.isNotEmpty
                  ? prayerController.cityName
                  : null,
          onRefreshLocation: _refreshLocationAndPrayerTimes,
          onApplyCalculationMethod: _applyCalculationMethod,
          onReminderOffsetChanged: _applyReminderOffset,
        );
        break;
      case 2:
        screen = const AzkarScreen();
        break;
      case 3:
        screen = const TasbihScreen();
        break;
      case 4:
        screen = HadithScreen(primaryColor: primaryColor);
        break;
      case 5:
        screen = const HasanatScreen();
        break;
      case 6:
        screen = KhatmaScreen(primaryColor: primaryColor);
        break;
      case 7:
        screen = ChannelsScreen(primaryColor: primaryColor);
        break;
      case 8:
        final splashResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const QiblaSplashScreen()),
        );
        if (splashResult == true && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          );
        }
        break;
      case 9:
        screen = const DuaScreen();
        break;
      case 10:
        screen = BooksScreen(primaryColor: primaryColor);
        break;
      case 11:
        screen = MuezzinSettingsScreen(primaryColor: primaryColor);
        break;
      case 12:
        screen = AsmaAllahScreen(primaryColor: primaryColor);
        break;
      case 13:
        screen = MiraclesScreen(primaryColor: primaryColor);
        break;
      case 14:
        screen = GreatMuslimsScreen(primaryColor: primaryColor);
        break;
      case 15:
        screen = RadioScreen(primaryColor: primaryColor);
        break;
      case 16:
        screen = SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onColorChanged: widget.onColorChanged,
          isDarkMode: widget.isDarkMode,
          selectedColorIndex: widget.selectedColorIndex,
          appColors: widget.appColors,
          colorNames: widget.colorNames,
          primaryColor: primaryColor,
        );
        break;
    }

    if (screen != null && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
      if (mounted && (index == 1 || index == 12)) {
        await _refreshLocationAndPrayerTimes();
      }
    }
  }

  bool _isMorningAzkarTime() {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 17;
  }

  String _getCurrentAzkarTitle() {
    final tr = context.tr;
    return _isMorningAzkarTime() ? tr.morningAzkarShort : tr.eveningAzkarShort;
  }

  IconData _getCurrentAzkarIcon() {
    return _isMorningAzkarTime()
        ? Icons.wb_sunny_outlined
        : Icons.nights_stay_rounded;
  }

  Map<String, dynamic>? _getCurrentAzkarCategoryFromJson() {
    final targetTitle = _isMorningAzkarTime() ? 'أذكار الصباح' : 'أذكار المساء';
    try {
      return _azkarCategories.firstWhere((c) => c['title'] == targetTitle);
    } catch (_) {
      return null;
    }
  }

  Widget _animatedSection({
    required Animation<double> fade,
    required Animation<Offset> slide,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);
    final cardColor = isDark ? const Color(0xFF13211D) : Colors.white;

    final features = _buildFeatures(tr);
    final prayerInfoTranslated = _buildPrayerInfo(tr);

    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(
        primary: _primary,
        isDark: isDark,
        features: features,
        onFeatureTap: _navigateToScreen,
      ),
      backgroundColor: bg,
      body: Directionality(
        textDirection: tr.textDirection,
        child: Stack(
          children: [
            // ط§ظ„ط®ظ„ظپظٹط©
            Positioned.fill(
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollOffsetNotifier,
                builder: (context, offset, _) {
                  return HomeBackground(
                    primary: _primary,
                    gold: _gold,
                    scrollOffset: offset,
                    isDark: isDark,
                  );
                },
              ),
            ),

            // ط§ظ„ظ…ط­طھظˆظ‰
            SafeArea(
              child: Selector<PrayerTimesController, _PrayerSnapshot>(
                selector:
                    (_, ctrl) => _PrayerSnapshot(
                      prayerTimes: ctrl.prayerTimes,
                      cityName: ctrl.cityName,
                      isLoading: ctrl.isLoading,
                    ),
                builder: (context, snapshot, _) {
                  final prayerTimes = snapshot.prayerTimes;
                  final cityName =
                      snapshot.cityName.isEmpty
                          ? tr.locating
                          : snapshot.cityName;
                  final isPrayerLoading = snapshot.isLoading;

                  if (prayerTimes.isNotEmpty) {
                    _calculateNextPrayer(prayerTimes);
                  }

                  final rawCards =
                      _cardsOrderLoaded
                          ? _cardsOrder
                          : HomeCardsOrderService.defaultCards;

                  final visibleCards =
                      rawCards.where((c) => c.isVisible).toList();

                  // fallback ط£ظ…ط§ظ†: ط¥ط°ط§ ط£طµط¨ط­طھ ظƒظ„ ط§ظ„ط¨ط·ط§ظ‚ط§طھ ظ…ط®ظپظٹط© ظ„ط£ظٹ ط³ط¨ط¨
                  final orderedCards =
                      visibleCards.isNotEmpty
                          ? visibleCards
                          : HomeCardsOrderService.defaultCards
                              .map(
                                (e) => HomeCard(
                                  id: e.id,
                                  title: e.title,
                                  icon: e.icon,
                                  isVisible: true,
                                ),
                              )
                              .toList();

                  return ListView(
                    key: const PageStorageKey('home-main-scroll'),
                    controller: _homeScrollController,
                    cacheExtent: 1400,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      // ط§ظ„ط´ط±ظٹط· ط§ظ„ط¹ظ„ظˆظٹ
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ValueListenableBuilder<double>(
                          valueListenable: _scrollOffsetNotifier,
                          builder: (_, offset, __) {
                            final elevated = offset > 6;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    elevated
                                        ? (isDark
                                            ? const Color(
                                              0xFF0E1714,
                                            ).withValues(alpha: 0.30)
                                            : Colors.white.withValues(
                                              alpha: 0.35,
                                            ))
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow:
                                    elevated
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: isDark ? 0.18 : 0.06,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Row(
                                children: [
                                  _buildTopBarButton(
                                    icon: Icons.menu_rounded,
                                    cardColor: cardColor,
                                    isDark: isDark,
                                    onTap:
                                        () =>
                                            _scaffoldKey.currentState
                                                ?.openDrawer(),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildHijriDateCenter(
                                      cardColor,
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTopBarButton(
                                    icon: Icons.dashboard_customize_rounded,
                                    cardColor: cardColor,
                                    isDark: isDark,
                                    onTap: _openReorderSheet,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ط§ظ„ط¨ط·ط§ظ‚ط§طھ
                      ...orderedCards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final card = entry.value;

                        return _StaggeredCard(
                          index: index,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: index < orderedCards.length - 1 ? 14 : 0,
                            ),
                            child: _buildCardById(
                              card.id,
                              cardColor,
                              isDark,
                              features,
                              prayerInfoTranslated,
                              prayerTimes,
                              cityName,
                              isPrayerLoading,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriDateCenter(Color cardColor, bool isDark) {
    final hijri = HijriCalendar.fromDate(DateTime.now());

    String monthName;
    if (_hijriDataLoaded && HijriData.hijriMonths.isNotEmpty) {
      monthName = HijriData.hijriMonths[hijri.hMonth - 1];
    } else {
      const fallbackMonths = [
        'محرم',
        'صفر',
        'ربيع الأول',
        'ربيع الآخر',
        'جمادى الأولى',
        'جمادى الآخرة',
        'رجب',
        'شعبان',
        'رمضان',
        'شوال',
        'ذو القعدة',
        'ذو الحجة',
      ];
      monthName = fallbackMonths[hijri.hMonth - 1];
    }

    Map<String, String>? todayEvent;
    if (_hijriDataLoaded && HijriData.hijriEvents.isNotEmpty) {
      todayEvent = HijriData.hijriEvents['${hijri.hMonth}-${hijri.hDay}'];
    }

    final dateText = '${hijri.hDay} $monthName ${hijri.hYear}';

    // â•گâ•گ FIX #13: ظƒط§ط´ ط£ظ„ظˆط§ظ† ط¨ط¯ظ„ withOpacity ظ…طھظƒط±ط± â•گâ•گ
    final borderColor =
        todayEvent != null
            ? _gold.withValues(alpha: 0.5)
            : _primary.withValues(alpha: 0.12);
    final borderWidth = todayEvent != null ? 1.2 : 0.8;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HijriCalendarScreen(primaryColor: _primary),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.brightness_3_rounded, size: 11, color: _gold),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    dateText,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.brightness_3_rounded, size: 11, color: _gold),
              ],
            ),
            if (todayEvent != null) ...[
              const SizedBox(height: 1),
              Flexible(
                child: Text(
                  '✨ ${todayEvent['title'] ?? ''}',
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _gold.withValues(alpha: 0.9),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required Color cardColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cardColor.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
    );
  }
}

// â•گâ•گ FIX #2: Snapshot class ظ„ظ€ Selector â•گâ•گ
class _PrayerSnapshot {
  final Map<String, String> prayerTimes;
  final String cityName;
  final bool isLoading;

  const _PrayerSnapshot({
    required this.prayerTimes,
    required this.cityName,
    required this.isLoading,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PrayerSnapshot) return false;
    if (prayerTimes.length != other.prayerTimes.length) return false;
    if (cityName != other.cityName) return false;
    if (isLoading != other.isLoading) return false;
    for (final key in prayerTimes.keys) {
      if (prayerTimes[key] != other.prayerTimes[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(prayerTimes.entries.map((e) => Object.hash(e.key, e.value))),
    cityName,
    isLoading,
  );
}

/// â•گâ•گ ط¨ط·ط§ظ‚ط© طھط¯ط®ظ„ ط¨ط´ظƒظ„ ظ…طھط¯ط±ط¬ â•گâ•گ
/// â•گâ•گ ط¨ط·ط§ظ‚ط© طھطھط­ط±ظƒ ظپظ‚ط· ط¹ظ†ط¯ظ…ط§ طھط¸ظ‡ط± ط¹ظ„ظ‰ ط§ظ„ط´ط§ط´ط© â•گâ•گ
class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredCard({required this.index, required this.child});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // ط§ظ„ط¨ط·ط§ظ‚ط§طھ ط§ظ„ط£ظˆظ„ظ‰ (0-3) طھط¨ط¯ط£ ظ…ط¨ط§ط´ط±ط© ظ„ط£ظ†ظ‡ط§ ظ…ط±ط¦ظٹط©
    if (widget.index < 4) {
      Future.delayed(Duration(milliseconds: widget.index * 80), () {
        if (mounted && !_hasAnimated) {
          _hasAnimated = true;
          _ctrl.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onVisible() {
    if (!_hasAnimated && mounted) {
      _hasAnimated = true;
      // طھط£ط®ظٹط± ط¨ط³ظٹط· ظ„ط¥ط­ط³ط§ط³ ط·ط¨ظٹط¹ظٹ
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _VisibilityTrigger(
      onVisible: _onVisible,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

/// â•گâ•گ ظٹظƒط´ظپ ظ…طھظ‰ ظٹط¸ظ‡ط± ط§ظ„ظˆظٹط¯ط¬طھ ط¹ظ„ظ‰ ط§ظ„ط´ط§ط´ط© â€” ط¨ط¯ظˆظ† ظ…ظƒطھط¨ط§طھ ط®ط§ط±ط¬ظٹط© â•گâ•گ
class _VisibilityTrigger extends StatefulWidget {
  final VoidCallback onVisible;
  final Widget child;

  const _VisibilityTrigger({required this.onVisible, required this.child});

  @override
  State<_VisibilityTrigger> createState() => _VisibilityTriggerState();
}

class _VisibilityTriggerState extends State<_VisibilityTrigger> {
  final GlobalKey _key = GlobalKey();
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    // ظ†ظپط­طµ ط¨ط¹ط¯ ط£ظˆظ„ frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_triggered) return;

    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      // ظ†ط¹ظٹط¯ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظپظٹ ط§ظ„ظپط±ظٹظ… ط§ظ„طھط§ظ„ظٹ
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return;
    }

    // ظ†طھط­ظ‚ظ‚ ظ‡ظ„ ط§ظ„ظˆظٹط¯ط¬طھ ظ…ط±ط¦ظٹ ظپظٹ ط§ظ„ظ€ viewport
    final viewport = RenderAbstractViewport.of(renderObject);
    final offset = viewport.getOffsetToReveal(renderObject, 0.0);
    final scrollableState = Scrollable.maybeOf(_key.currentContext!);

    if (scrollableState != null) {
      final scrollPosition = scrollableState.position;
      final viewportHeight = scrollPosition.viewportDimension;
      final scrollOffset = scrollPosition.pixels;

      // ط§ظ„ظˆظٹط¯ط¬طھ ظ…ط±ط¦ظٹ ط¥ط°ط§ ظƒط§ظ† offset ط¯ط§ط®ظ„ ظ†ط·ط§ظ‚ ط§ظ„ط´ط§ط´ط©
      if (offset.offset < scrollOffset + viewportHeight + 50) {
        _triggered = true;
        widget.onVisible();
        return;
      }
    }

    // ط¥ط°ط§ ظ„ظ… ظٹط¸ظ‡ط± ط¨ط¹ط¯ â€” ظ†ط±ط§ظ‚ط¨ ط§ظ„ط³ظƒط±ظˆظ„
    _listenToScroll();
  }

  void _listenToScroll() {
    final scrollable = Scrollable.maybeOf(_key.currentContext!);
    if (scrollable == null) return;

    void listener() {
      if (_triggered) {
        scrollable.position.removeListener(listener);
        return;
      }

      final renderObject = _key.currentContext?.findRenderObject();
      if (renderObject == null || !renderObject.attached) return;

      final viewport = RenderAbstractViewport.of(renderObject);
      final revealOffset = viewport.getOffsetToReveal(renderObject, 0.0);
      final scrollPosition = scrollable.position;
      final viewportHeight = scrollPosition.viewportDimension;
      final currentScroll = scrollPosition.pixels;

      if (revealOffset.offset < currentScroll + viewportHeight + 80) {
        _triggered = true;
        scrollable.position.removeListener(listener);
        widget.onVisible();
      }
    }

    scrollable.position.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
