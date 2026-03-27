import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamic_app/screens/AsmaAllah/asma_allah_screen.dart';
import 'package:islamic_app/screens/mircle/miracles_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../controllers/prayer_times_controller.dart';

import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_time_screen.dart';
import 'package:islamic_app/screens/search/global_search_delegate_screen.dart';
import 'package:islamic_app/screens/quran/surah_deatil.dart';

import '../../../services/adahn_audio_services.dart';
import '../../../services/adahn_notification.dart';
import '../../../services/great_muslims_service.dart';
import '../../../services/location_services.dart';
import '../../../services/muazzin_store.dart';
import '../../../services/native_adhan_bridge.dart';

import '../../../utils/current_sunnah_card.dart';
import '../../GreatMuslim/great_muslims_screen.dart';
import '../../GreatMuslim/great_person_detail_screen.dart';
import '../../prayer/adhan_player_screen.dart';
import '../../books/books_screen.dart';
import '../../daily_challenges_screen.dart';
import '../../hadith/hadith_book_screen.dart';
import '../../quran/quran_screen.dart';
import '../../Azkar/azkar_screen.dart';
import '../../sunnah_tracker_screen.dart';
import '../../tasbih_screen.dart';
import '../../hadith/hadith_screen.dart';
import '../../qibla_screen.dart';
import '../../dua/dua_screen.dart';
import '../../settings_screen.dart';
import '../../hasanat_screen.dart';
import '../../khatma_screen.dart';
import '../../channels_screen.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  late Animation<Offset> _slideSunnah;

  late Animation<Offset> _slideHeader;
  late Animation<Offset> _slidePrayer;
  late Animation<Offset> _slideVerse;
  late Animation<Offset> _slideAzkar;
  late Animation<Offset> _slideGrid;
  late Animation<Offset> _slideHadith;

  String _currentTime = '';
  Timer? _timer;
  String _cityName = 'جاري التحديد...';


  List<Map<String, dynamic>> _azkarCategories = [];
  bool _azkarLoaded = false;
  final ScrollController _homeScrollController = ScrollController();
  double _scrollOffset = 0.0;
  Map<String, String> _prayerTimes = {};
  String _nextPrayerName = '...';
  String _timeLeft = '';
  bool _isPrayerLoading = true;
  bool _isSchedulingNotifications = false;
  late PageController _heroPageController;
  int _currentHeroIndex = 0;
  Timer? _heroTimer;

  final Map<String, String> _fallbackTimes = {
    'Fajr': '04:30',
    'Sunrise': '05:45',
    'Dhuhr': '12:15',
    'Asr': '15:30',
    'Maghrib': '18:45',
    'Isha': '20:00',
  };

  final List<Map<String, dynamic>> features = const [
    {'title': 'القرآن الكريم', 'subtitle': '١١٤ سورة', 'icon': Icons.menu_book_rounded, 'badge': '📖'},
    {'title': 'أوقات الصلاة', 'subtitle': 'مواقيت دقيقة', 'icon': Icons.access_time_filled_rounded, 'badge': '🕌'},
    {'title': 'الأذكار', 'subtitle': 'صباح ومساء', 'icon': Icons.auto_awesome_rounded, 'badge': '✨'},
    {'title': 'التسبيح', 'subtitle': 'عداد ذكي', 'icon': Icons.touch_app_rounded, 'badge': '📿'},
    {'title': 'الأحاديث', 'subtitle': 'مكتبة السنة', 'icon': Icons.format_quote_rounded, 'badge': '📜'},
    {'title': 'حصاد الحسنات', 'subtitle': 'أجور عظيمة', 'icon': Icons.emoji_events_rounded, 'badge': '🏰'},
    {'title': 'ختمتي', 'subtitle': 'وردك اليومي', 'icon': Icons.track_changes, 'badge': '🎯'},
    {'title': 'البث المباشر', 'subtitle': 'قنوات المشايخ', 'icon': Icons.live_tv_rounded, 'badge': '🔴'},
    {'title': 'القبلة', 'subtitle': 'اتجاه القبلة', 'icon': Icons.explore_rounded, 'badge': '🧭'},
    {'title': 'الأدعية', 'subtitle': 'أدعية مختارة', 'icon': Icons.favorite_rounded, 'badge': '🤲'},
    {'title': 'المكتبة', 'subtitle': 'كتب إسلامية', 'icon': Icons.local_library_rounded, 'badge': '📚'},
    {'title': 'المؤذن', 'subtitle': 'اختيار الصوت', 'icon': Icons.volume_up_rounded, 'badge': '🎙️'},
    {'title': 'اسماء الله الحسنى', 'subtitle': 'اسماء العظيم', 'icon': Icons.volume_up_rounded, 'badge': '📜'},
    {'title': 'المعجزات', 'subtitle': 'معجزات القران والسنة', 'icon': Icons.volume_up_rounded, 'badge': '📜'},
    {'title': 'عظماء الإسلام', 'subtitle': 'شخصيات خالدة', 'icon': Icons.military_tech_rounded, 'badge': '🏛️'},
    {'title': 'الإعدادات', 'subtitle': 'تخصيص التطبيق', 'icon': Icons.settings_rounded, 'badge': '⚙️'},
  ];

  final List<Map<String, dynamic>> _prayerInfo = [
    {'name': 'الفجر', 'key': 'Fajr', 'icon': Icons.nightlight_round},
    {'name': 'الشروق', 'key': 'Sunrise', 'icon': Icons.wb_sunny_outlined},
    {'name': 'الظهر', 'key': 'Dhuhr', 'icon': Icons.wb_sunny},
    {'name': 'العصر', 'key': 'Asr', 'icon': Icons.sunny_snowing},
    {'name': 'المغرب', 'key': 'Maghrib', 'icon': Icons.wb_twilight},
    {'name': 'العشاء', 'key': 'Isha', 'icon': Icons.nights_stay},
  ];

  final List<Map<String, String>> dailyVerses = const [
    {'verse': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', 'surah': 'الطلاق - ٢'},
    {'verse': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح - ٥'},
    {'verse': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا', 'surah': 'البقرة - ٢٨٦'},
    {'verse': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'surah': 'طه - ١١٤'},
    {'verse': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'surah': 'الرعد - ٢٨'},
  ];

  final List<Map<String, String>> dailyHadiths = const [
    {'text': '« إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ »', 'source': 'رواه البخاري'},
    {'text': '« الدِّينُ النَّصِيحَةُ »', 'source': 'رواه مسلم'},
    {'text': '« الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ »', 'source': 'رواه البخاري'},
    {'text': '« تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ »', 'source': 'رواه الترمذي'},
    {'text': '« خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ »', 'source': 'رواه البخاري'},
  ];

  List<GreatMuslim> _greatMuslims = [];
  bool _greatMuslimsLoaded = false;
  Map<String, String> currentVerseOfDay = {'verse': 'جاري التحميل...', 'surah': ''};
  Map<String, String> currentHadithOfDay = {'text': 'جاري التحميل...', 'source': ''};

  Future<void> _loadGreatMuslims() async {
    try {
      GreatMuslimsService.clearCache(); // إعادة تحميل نظيفة
      final data = await GreatMuslimsService.load();
      debugPrint('✅ HomeScreen: تم تحميل ${data.length} شخصية');
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _homeScrollController.addListener(() {
      if (!mounted) return;
      setState(() {
        _scrollOffset = _homeScrollController.offset;
      });
    });

    _heroPageController = PageController(
      viewportFraction: 0.90,
    );

    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroPageController.hasClients || _greatMuslims.isEmpty) {
        return;
      }

      final nextPage = (_currentHeroIndex + 1) % _greatMuslims.length;

      _heroPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

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

    _slideHeader = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _slidePrayer = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.10, 0.38, curve: Curves.easeOutCubic),
      ),
    );

    _slideVerse = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.22, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _slideAzkar = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.34, 0.62, curve: Curves.easeOutCubic),
      ),
    );

    _slideGrid = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.46, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _slideHadith = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.60, 1.00, curve: Curves.easeOutCubic),
      ),
    );

    _slideSunnah = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.38, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _checkRescheduleAfterBoot();
    _setDailyContent();
    _loadAzkarJson();
    _updateTime();
    // أضف هذا في نهاية initState
    _loadGreatMuslims();

    Future.microtask(() async {
      if (!mounted) return;
      await context.read<PrayerTimesController>().refreshLocationAndPrayerTimes();
    });

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      _initLocationAndPrayersSafe();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final prayerController = context.read<PrayerTimesController>();

      setState(() {
        _updateTime();
        _prayerTimes = prayerController.prayerTimes;
        _cityName = prayerController.cityName;
        _isPrayerLoading = prayerController.isLoading;
        _calculateNextPrayer(_prayerTimes);
      });
    });

    _prayerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _prayerPulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _prayerPulseController,
        curve: Curves.easeInOut,
      ),
    );

  }

  @override
  void dispose() {
    _timer?.cancel();
    _heroTimer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    _heroPageController.dispose();
    _homeScrollController.dispose();
    _prayerPulseController.dispose();
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

  Widget _animatedSection({
    required Animation<double> fade,
    required Animation<Offset> slide,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  bool _isMorningAzkarTime() {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 17;
  }

  String _getCurrentAzkarTitle() {
    return _isMorningAzkarTime() ? 'أذكار الصباح' : 'أذكار المساء';
  }

  IconData _getCurrentAzkarIcon() {
    return _isMorningAzkarTime()
        ? Icons.wb_sunny_outlined
        : Icons.nights_stay_rounded;
  }

  Map<String, dynamic>? _getCurrentAzkarCategoryFromJson() {
    final targetTitle = _getCurrentAzkarTitle();

    try {
      return _azkarCategories.firstWhere(
            (c) => c['title'] == targetTitle,
      );
    } catch (_) {
      return null;
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

  Future<void> _schedulePrayerNotifications() async {
    if (!mounted || _isSchedulingNotifications || _prayerTimes.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final adhanEnabled = prefs.getBool('adhan_enabled') ?? false;
    final reminderEnabled = prefs.getBool('reminder_enabled') ?? false;
    final reminderOffset = prefs.getInt('reminder_offset') ?? 10;

    _isSchedulingNotifications = true;

    try {
      final prayers = [
        {'key': 'Fajr', 'name': 'الفجر', 'id': 100},
        {'key': 'Dhuhr', 'name': 'الظهر', 'id': 101},
        {'key': 'Asr', 'name': 'العصر', 'id': 102},
        {'key': 'Maghrib', 'name': 'المغرب', 'id': 103},
        {'key': 'Isha', 'name': 'العشاء', 'id': 104},
      ];

      for (final prayer in prayers) {
        await NativeAdhanBridge.cancelAdhan(prayer['id'] as int);
        await NativeAdhanBridge.cancelAdhan((prayer['id'] as int) + 1000);
      }

      for (final prayer in prayers) {
        final key = prayer['key'] as String;
        final prayerName = prayer['name'] as String;
        final prayerId = prayer['id'] as int;

        final timeStr = _prayerTimes[key];
        if (timeStr == null || timeStr.isEmpty) continue;

        DateTime scheduledTime = _parseTime(timeStr);
        if (scheduledTime.isBefore(DateTime.now())) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        if (adhanEnabled) {
          final m = await MuezzinStore.getEffectiveForPrayer(key);
          final localPath = m.isBuiltIn ? null : await AdhanAudioService.instance.getLocalPath(m.id);
          final soundName = m.localSoundName.isNotEmpty ? m.localSoundName : 'makkah';

          await NativeAdhanBridge.scheduleAdhan(
            time: scheduledTime,
            prayerName: prayerName,
            requestCode: prayerId,
            soundName: soundName,
            localPath: localPath,
          );
        }

        if (reminderEnabled && reminderOffset > 0) {
          final reminderTime = scheduledTime.subtract(Duration(minutes: reminderOffset));
          if (reminderTime.isAfter(DateTime.now())) {
            await NativeAdhanBridge.scheduleReminder(
              time: reminderTime,
              prayerName: prayerName,
              requestCode: prayerId + 1000,
              soundName: 'reminder_beep',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ أثناء الجدولة: $e');
    } finally {
      _isSchedulingNotifications = false;
    }
  }

  Future<void> _refreshLocationAndPrayerTimes() async {
    await context.read<PrayerTimesController>().refreshLocationAndPrayerTimes();

    if (!mounted) return;

    setState(() {
      _prayerTimes = context.read<PrayerTimesController>().prayerTimes;
      _cityName = context.read<PrayerTimesController>().cityName;
      _isPrayerLoading = context.read<PrayerTimesController>().isLoading;
      _calculateNextPrayer(_prayerTimes);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث الموقع والمواقيت',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAdhanFromNotification(Map<String, dynamic> payload) {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdhanPlayerScreen(
          primaryColor: _primary,
          prayerName: payload['prayerName'] ?? payload['prayer'] ?? 'الصلاة',
          muezzinName: payload['muezzinName'] ?? 'مؤذن',
          url: payload['muezzinUrl'] ?? '',
          localPath: (payload['localPath'] != null && payload['localPath'].toString().isNotEmpty)
              ? payload['localPath']
              : null,
        ),
      ),
    );
  }

  void _setDailyContent() async {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;

    int verseIndex = daySeed % dailyVerses.length;
    int hadithIndex = daySeed % dailyHadiths.length;

    if (mounted) {
      setState(() {
        currentVerseOfDay = dailyVerses[verseIndex];
        currentHadithOfDay = dailyHadiths[hadithIndex];
      });
    }

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
              'verse': ayah['text']
                  .toString()
                  .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
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
              'text': hadith['text'].toString().replaceAll(RegExp(r'<[^>]*>'), '').trim(),
              'source': 'رقم الحديث: ${hadith['hadithnumber']}',
            };
          });
        }
      }
    } catch (_) {}
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    final newTime = '$hour:${now.minute.toString().padLeft(2, '0')} $period';

    if (_currentTime != newTime && mounted) {
      setState(() => _currentTime = newTime);
    }
  }

  Future<void> _initLocationAndPrayersSafe() async {
    final prayerController = context.read<PrayerTimesController>();

    setState(() {
      _prayerTimes = prayerController.prayerTimes;
      _cityName = prayerController.cityName;
      _isPrayerLoading = prayerController.isLoading;
      _calculateNextPrayer(_prayerTimes);
    });

    await _schedulePrayerNotifications();
  }

  Future<void> _checkRescheduleAfterBoot() async {
    final prefs = await SharedPreferences.getInstance();
    final needsReschedule = prefs.getBool('needs_reschedule_after_boot') ?? false;
    if (!needsReschedule) return;

    await _schedulePrayerNotifications();
    await prefs.setBool('needs_reschedule_after_boot', false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إعادة جدولة الأذان بعد إعادة تشغيل الهاتف', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _calculateNextPrayer(Map<String, String> prayerTimes) {
    if (prayerTimes.isEmpty) return;

    final now = DateTime.now();
    DateTime? nextPrayerTime;
    String nextName = '';

    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayerNames = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    for (final key in prayerOrder) {
      final time = _parseTime(prayerTimes[key]!);
      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextName = prayerNames[key]!;
        break;
      }
    }

    if (nextPrayerTime == null) {
      nextName = 'الفجر';
      final fajr = _parseTime(prayerTimes['Fajr']!);
      nextPrayerTime = fajr.add(const Duration(days: 1));
    }

    final diff = nextPrayerTime.difference(now);
    final timeLeftString = diff.inHours > 0
        ? '${diff.inHours}س و ${diff.inMinutes % 60}د'
        : '${diff.inMinutes} دقيقة';

    if (mounted &&
        (_nextPrayerName != nextName || _timeLeft != timeLeftString)) {
      setState(() {
        _nextPrayerName = nextName;
        _timeLeft = timeLeftString;
      });
    }
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    try {
      final cleanTime = timeStr.split(' ')[0];
      final parts = cleanTime.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return now;
    }
  }

  String _formatTimeAMPM(String time24) {
    if (time24.isEmpty || time24 == '--:--') return '--:--';
    try {
      final cleanTime = time24.split(' ')[0];
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      String period = 'ص';

      if (hour >= 12) {
        period = 'م';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }

  Future<Map<String, String>?> _applyCalculationMethod(String methodKey) async {
    final result =
    await context.read<PrayerTimesController>().applyCalculationMethod(methodKey);

    if (!mounted) return result;

    setState(() {
      _prayerTimes = context.read<PrayerTimesController>().prayerTimes;
      _cityName = context.read<PrayerTimesController>().cityName;
      _isPrayerLoading = context.read<PrayerTimesController>().isLoading;
      _calculateNextPrayer(_prayerTimes);
    });

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

    Widget? screen;

    switch (index) {
      case 0:
        screen = const QuranScreen();
        break;
      case 1:
        screen = PrayerTimesScreen(
          primaryColor: primaryColor,
          prayerTimes: _prayerTimes.isNotEmpty ? _prayerTimes : null,
          cityName: _cityName.isNotEmpty ? _cityName : null,
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
        screen = const QiblaScreen();
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
        screen = GreatMuslimsScreen(primaryColor: primaryColor,);
        break;
      case 15:
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
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );

      if (mounted && (index == 1 || index == 12)) {
        await _refreshLocationAndPrayerTimes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerController = context.watch<PrayerTimesController>();
    _calculateNextPrayer(prayerController.prayerTimes);

    _prayerTimes = prayerController.prayerTimes;
    _cityName = prayerController.cityName;
    _isPrayerLoading = prayerController.isLoading;
    _calculateNextPrayer(_prayerTimes);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);
    final cardColor = isDark ? const Color(0xFF13211D) : Colors.white;
    const gold = Color(0xFFC8A44D);
    // ★ استخدام اللون المختار بدلاً من الثابت ★
    final deepGreen = _primary;


    return Scaffold(
      drawer: _buildDrawer(deepGreen, isDark),
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildSoftBackground(deepGreen, gold, _scrollOffset),
          ),
          SafeArea(
            child: ListView(
              controller: _homeScrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              children: [
                _animatedSection(
                  fade: _fadeHeader,
                  slide: _slideHeader,
                  child: _buildScrollableHeader(deepGreen, gold),
                ),
                const SizedBox(height: 16),

                _animatedSection(
                  fade: _fadePrayer,
                  slide: _slidePrayer,
                  child: _buildResponsivePrayerCard(
                    deepGreen,
                    gold,
                    cardColor,
                    isDark,
                    prayerController.prayerTimes,
                    prayerController.cityName,
                    prayerController.isLoading,
                  ),
                ),
                const SizedBox(height: 16),

                _animatedSection(
                  fade: _fadeSunnah,
                  slide: _slideSunnah,
                  child: CurrentSunnahCard(
                    deepGreen: _primary,
                    gold: gold,
                    isDark: isDark,
                    onNavigateToTracker: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SunnahTrackerScreen(
                            isDarkMode: isDark,
                            onToggleTheme: () => widget.onThemeChanged(!widget.isDarkMode),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                _animatedSection(
                  fade: _fadeVerse,
                  slide: _slideVerse,
                  child: _buildModernVerseCard(gold, cardColor, isDark),
                ),
                const SizedBox(height: 14),

                _animatedSection(
                  fade: _fadeAzkar,
                  slide: _slideAzkar,
                  child: _buildModernMorningAzkarCard(deepGreen, gold, cardColor, isDark),
                ),
                const SizedBox(height: 14),

                _animatedSection(
                  fade: _fadeGrid,
                  slide: _slideGrid,
                  child: _buildModernQuickGrid(deepGreen, gold, cardColor, isDark),
                ),
                const SizedBox(height: 18),

                _animatedSection(
                  fade: _fadeHadith,
                  slide: _slideHadith,
                  child: _buildHadithCard(deepGreen, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(Color primary, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                top: 60, bottom: 30, right: 20, left: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // ★ gradient يتكيف مع اللون المختار ★
                colors: [
                  primary,
                  Color.lerp(primary, Colors.black, 0.25)!,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // ★ اللون المختار ★
                    color: primary.withOpacity(0.99),
                  ),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 90,
                    errorBuilder: (c, e, s) => const Icon(
                        Icons.mosque_rounded,
                        size: 50,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'طريق الاسلام',
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'رفيقك اليومي',
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return ListTile(
                  // ★ أيقونة بلون التطبيق المختار ★
                  leading: Icon(feature['icon'] as IconData,
                      color: primary),
                  title: Text(
                    feature['title'] as String,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToScreen(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableHeader(Color deepGreen, Color gold) {
    // حماية من القائمة الفارغة أثناء التحميل
    if (!_greatMuslimsLoaded) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            color: gold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_greatMuslims.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'لا توجد بيانات',
            style: GoogleFonts.cairo(color: gold),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        final sliderHeight = small ? 180.0 : 205.0;
        final titleSize = small ? 18.0 : 22.0;
        final roleSize = small ? 10.5 : 12.0;
        final descSize = small ? 10.0 : 11.5;

        return Column(
          children: [
            SizedBox(
              height: sliderHeight,
              child: PageView.builder(
                controller: _heroPageController,
                itemCount: _greatMuslims.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentHeroIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final person = _greatMuslims[index];
                  final heroTag = 'great_person_${person.id}';
                  final bool isActive = index == _currentHeroIndex;

                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.96,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 650),
                            reverseTransitionDuration: const Duration(milliseconds: 420),
                            opaque: false,
                            pageBuilder: (_, animation, secondaryAnimation) {
                              return GreatPersonDetailScreen(
                                person: person,
                                allPersons: _greatMuslims,
                                primaryColor: _primary,
                                heroTag: heroTag,
                              );
                            },
                            transitionsBuilder: (_, animation, secondaryAnimation, child) {
                              final curved = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                                reverseCurve: Curves.easeInCubic,
                              );

                              return FadeTransition(
                                opacity: curved,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.03),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.985,
                                      end: 1.0,
                                    ).animate(curved),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Hero(
                        tag: heroTag,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 8,
                              left: index == _greatMuslims.length - 1 ? 0 : 4,
                              bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _primary.withOpacity(isActive ? 0.18 : 0.08),
                                  blurRadius: isActive ? 16 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    person.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF123C33),
                                              Color(0xFF1D5B4F),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.08),
                                          Colors.black.withOpacity(0.18),
                                          Colors.black.withOpacity(0.78),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: gold.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        'عظيم الاسلام',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: small ? 9.5 : 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: 14,
                                    right: 14,
                                    bottom: 14,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.24),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            person.name,
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontSize: titleSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            person.title,
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.cairo(
                                              color: const Color(0xFFF4E7B2),
                                              fontSize: roleSize,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            person.desc,
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.cairo(
                                              color: Colors.white.withOpacity(0.92),
                                              fontSize: descSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_greatMuslims.length, (index) {
                final active = index == _currentHeroIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? gold : gold.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsivePrayerCard(
      Color primary,
      Color gold,
      Color cardColor,
      bool isDark,
      Map<String, String> prayerTimes,
      String cityName,
      bool isPrayerLoading,
      ) {
    double progress = 0.0;

    if (prayerTimes.isNotEmpty && _nextPrayerName != '...') {
      try {
        final now = DateTime.now();
        DateTime? previousPrayerTime;
        DateTime? nextPrayerTime;

        final prayerKeys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        for (int i = 0; i < prayerKeys.length; i++) {
          final time = _parseTime(prayerTimes[prayerKeys[i]]!);
          if (time.isAfter(now)) {
            nextPrayerTime = time;
            if (i > 0) {
              previousPrayerTime = _parseTime(prayerTimes[prayerKeys[i - 1]]!);
            } else {
              previousPrayerTime =
                  _parseTime(prayerTimes['Isha']!).subtract(const Duration(days: 1));
            }
            break;
          }
        }

        if (nextPrayerTime == null) {
          nextPrayerTime = _parseTime(prayerTimes['Fajr']!).add(const Duration(days: 1));
          previousPrayerTime = _parseTime(prayerTimes['Isha']!);
        }

        if (previousPrayerTime != null) {
          final totalDuration = nextPrayerTime.difference(previousPrayerTime).inMinutes;
          final elapsedDuration = now.difference(previousPrayerTime).inMinutes;
          progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        }
      } catch (_) {
        progress = 0.5;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        final nearPrayerFactor = progress > 0.7 ? ((progress - 0.7) / 0.3) : 0.0;
        final glowStrength = (0.08 + (nearPrayerFactor * 0.22)).clamp(0.08, 0.30);
        final glowBlur = (10 + (nearPrayerFactor * 18)).clamp(10, 28).toDouble();
        final ringOpacity =
        (0.12 + (nearPrayerFactor * 0.32) + ((_prayerPulseAnim.value - 1.0) * 2.2))
            .clamp(0.12, 0.42);

        final titleFont = small ? 15.0 : 17.0;
        final subtitleFont = small ? 10.5 : 11.5;
        final nextPrayerFont = small ? 26.0 : 32.0;
        final timeLeftFont = small ? 15.0 : 18.0;
        final itemNameFont = small ? 10.5 : 11.5;
        final itemTimeFont = small ? 10.5 : 11.5;

        return Container(
          padding: EdgeInsets.all(small ? 14 : 16),
          decoration: _unifiedCardDecoration(isDark, primary),
          child: isPrayerLoading
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            Icons.location_on_outlined,
                            color: isDark ? Colors.white70 : primary,
                            size: 15
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cityName,
                          style: GoogleFonts.cairo(
                            color: isDark ? Colors.white70 : primary,
                            fontSize: subtitleFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'مواقيت الصلاة',
                    style: GoogleFonts.cairo(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            GestureDetector(
                 onTap: () => _navigateToScreen(1),
                child: ScaleTransition(
                  scale: _prayerPulseAnim,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(small ? 14 : 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          primary,
                          primary.withOpacity(0.78),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(glowStrength),
                          blurRadius: glowBlur,
                          spreadRadius: progress > 0.75 ? 1.0 : 0.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: small ? 42 : 48,
                              height: small ? 42 : 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: _prayerPulseAnim,
                                    child: Container(
                                      width: small ? 42 : 48,
                                      height: small ? 42 : 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: gold.withOpacity(ringOpacity),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: gold.withOpacity(ringOpacity * 0.45),
                                            blurRadius: 10 + (nearPrayerFactor * 8),
                                            spreadRadius: nearPrayerFactor > 0.5 ? 0.5 : 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: small ? 42 : 48,
                                    height: small ? 42 : 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      color: gold,
                                      size: small ? 20 : 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'الصلاة القادمة',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: subtitleFont,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _nextPrayerName,
                                      style: GoogleFonts.amiri(
                                        color: Colors.white,
                                        fontSize: nextPrayerFont,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      minHeight: small ? 6 : 7,
                                      backgroundColor: Colors.white.withOpacity(0.14),
                                      valueColor: AlwaysStoppedAnimation<Color>(gold),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _timeLeft.isEmpty ? '--:--' : _timeLeft,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: timeLeftFont,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _prayerInfo.map((p) {
                    final bool isNext = _nextPrayerName.contains(p['name']);
                    final formattedTime = _formatTimeAMPM(prayerTimes[p['key']] ?? '--:--');

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: small ? 88 : 96,
                      margin: const EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(
                        vertical: small ? 10 : 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isNext
                            ? primary.withOpacity(0.08)
                            : (isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isNext
                              ? primary.withOpacity(0.25)
                              : Colors.transparent,
                          width: 1.3,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            p['icon'] as IconData,
                            size: small ? 17 : 18,
                            color: isNext ? primary : Colors.grey,
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              p['name'],
                              style: GoogleFonts.cairo(
                                fontSize: itemNameFont,
                                fontWeight: FontWeight.bold,
                                color: isNext
                                    ? primary
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formattedTime,
                              style: GoogleFonts.cairo(
                                fontSize: itemTimeFont,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernVerseCard(Color gold, Color cardColor, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        return _glassCard(
          isDark: isDark,
          borderColor: gold,
          child: Padding(
            padding: EdgeInsets.all(small ? 14 : 16),
            child: Stack(
              children: [
                Positioned(
                  top: -6,
                  left: -6,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 42,
                    color: gold.withOpacity(0.10),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _sectionHeader(
                      icon: Icons.auto_awesome,
                      title: 'آية اليوم',
                      color: gold,
                      size: small ? 15 : 16,
                    ),
                    const SizedBox(height: 12),
                    if (currentVerseOfDay['surah']!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          currentVerseOfDay['surah']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: small ? 11 : 12,
                            color: gold,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      currentVerseOfDay['verse']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: small ? 22 : 26,
                        height: small ? 1.9 : 2.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2E2415),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اقرأها بتدبر واجعلها رفيق يومك',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: small ? 11 : 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _glassCard({
    required Widget child,
    required bool isDark,
    required Color borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildModernMorningAzkarCard(
      Color _primary,
      Color gold,
      Color cardColor,
      bool isDark,
      ) {
    final currentTitle = _getCurrentAzkarTitle();
    final currentIcon = _getCurrentAzkarIcon();
    final currentCategory = _getCurrentAzkarCategoryFromJson();

    final List<dynamic> currentAzkarList =
        currentCategory?['azkar'] as List<dynamic>? ?? [];

    final String previewText = currentAzkarList.isNotEmpty
        ? (currentAzkarList.first['text']?.toString() ?? '')
        : 'جاري تحميل الأذكار...';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (currentCategory == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AzkarDetailScreen(
                  title: currentCategory['title'] as String,
                  azkar: List<Map<String, dynamic>>.from(currentAzkarList),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(small ? 12 : 14),
            decoration: _unifiedCardDecoration(isDark, _primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 14 : 18,
                          vertical: small ? 9 : 10,
                        ),
                      ),
                      onPressed: () {
                        if (currentCategory == null) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AzkarDetailScreen(
                              title: currentCategory['title'] as String,
                              azkar: List<Map<String, dynamic>>.from(currentAzkarList),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'قراءة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: small ? 12 : 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _sectionHeader(
                            icon: currentIcon,
                            title: currentTitle,
                            color: gold,
                            size: small ? 14 : 16,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            previewText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(
                              fontSize: small ? 11 : 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _isMorningAzkarTime() ? 0.55 : 0.75,
                              minHeight: small ? 5 : 6,
                              backgroundColor: gold.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(gold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernQuickGrid(
      Color _primary,
      Color gold,
      Color cardColor,
      bool isDark,
      ) {
    final homeItems = [
      {'title': 'القرآن', 'icon': Icons.menu_book_rounded, 'index': 0},
      {'title': 'الحديث', 'icon': Icons.format_quote_rounded, 'index': 4},
      {'title': 'الأذكار', 'icon': Icons.auto_awesome_rounded, 'index': 2},
      {'title': 'القبلة', 'icon': Icons.explore_rounded, 'index': 8},
      {'title': 'اسماء الله الحسنى', 'icon': Icons.numbers_rounded, 'index': 12},
      {'title': 'التسبيح', 'icon': Icons.touch_app_rounded, 'index': 3},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        final crossAxisCount = 3;
        final spacing = small ? 10.0 : 12.0;
        final itemWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final itemHeight = small ? itemWidth * 1.05 : itemWidth * 1.10;
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homeItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = homeItems[index];

            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _navigateToScreen(item['index'] as int),
              child: Container(
                decoration: _unifiedCardDecoration(isDark, _primary),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: small ? 6 : 8,
                    vertical: small ? 8 : 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: small ? 44 : 52,
                        height: small ? 44 : 52,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isDark ? Colors.white70 : _primary,
                          size: small ? 24 : 28,
                        ),
                      ),
                      SizedBox(height: small ? 8 : 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: GoogleFonts.cairo(
                            fontSize: small ? 11.5 : 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : _primary,
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
      },
    );
  }

  Widget _buildHadithCard(Color primary, bool isDark) {
    return _glassCard(
      isDark: isDark,
      borderColor: primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(
              top: -6,
              left: -6,
              child: Icon(
                Icons.format_quote_rounded,
                size: 44,
                color: isDark ? Colors.white70 : primary.withOpacity(0.10),
              ),
            ),
            Column(
              children: [
                _sectionHeader(
                  icon: Icons.lightbulb_outline,
                  title: 'حديث اليوم',
                  color: isDark ? Colors.white70 : primary,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'قال رسول الله ﷺ',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentHadithOfDay['text']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 21,
                    height: 1.9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E2415),
                  ),
                ),
                const SizedBox(height: 12),
                if (currentHadithOfDay['source']!.isNotEmpty)
                  Text(
                    currentHadithOfDay['source']!,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _unifiedCardDecoration(bool isDark, Color borderColor) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF13211D) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: borderColor.withOpacity(0.10)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.14 : 0.05),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    double size = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSoftBackground(Color primary, Color gold, double scrollOffset) {
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0E1714)
        : const Color(0xFFF7F3EA);

    final moonShift = scrollOffset * 0.08;
    final starShift = scrollOffset * 0.05;
    final circleShift = scrollOffset * 0.03;

    final fadeOpacity = (1 - (scrollOffset / 500)).clamp(0.35, 1.0);

    return IgnorePointer(
        child: Opacity(
          opacity: fadeOpacity,
          child: Stack(
        children: [
          Positioned(
            top: -60 + circleShift,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 220 + circleShift,
            left: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 180 - circleShift,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 40 - circleShift,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withOpacity(0.04),
              ),
            ),
          ),

          // الهلال الكبير
          Positioned(
            top: 20 + moonShift,
            left: -30,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gold.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    left: 42,
                    top: 10,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // النجوم
          Positioned(
            top: 115 + starShift,
            left: 110,
            child: Icon(
              Icons.star_rounded,
              size: 10,
              color: gold.withOpacity(0.10),
            ),
          ),
          Positioned(
            top: 160 + starShift,
            right: 60,
            child: Icon(
              Icons.star_rounded,
              size: 8,
              color: primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            top: 300 + starShift,
            left: 30,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: gold.withOpacity(0.08),
            ),
          ),
          Positioned(
            top: 420 + starShift,
            right: 32,
            child: Icon(
              Icons.star_rounded,
              size: 9,
              color: gold.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: 260 - starShift,
            left: 40,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 11,
              color: primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: 140 - starShift,
            right: 24,
            child: Icon(
              Icons.star_rounded,
              size: 10,
              color: gold.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: 80 - starShift,
            left: 90,
            child: Icon(
              Icons.star_rounded,
              size: 8,
              color: primary.withOpacity(0.07),
            ),
          ),
        ],
      ),
        )
    );
  }

}