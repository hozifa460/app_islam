import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_time_screen.dart';
import 'package:islamic_app/screens/search/global_search_delegate_screen.dart';
import 'package:islamic_app/screens/quran/surah_deatil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/adahn_audio_services.dart';
import '../../../services/adahn_notification.dart';
import '../../../services/muazzin_store.dart';
import '../../../services/native_adhan_bridge.dart';

import '../../prayer/adhan_player_screen.dart';
import '../../books_screen.dart';
import '../../daily_challenges_screen.dart';
import '../../hadith/hadith_book_screen.dart';
import '../../quran/quran_screen.dart';
import '../../azkar_screen.dart';
import '../../tasbih_screen.dart';
import '../../hadith/hadith_screen.dart';
import '../../qibla_screen.dart';
import '../../dua_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  String _currentTime = '';
  Timer? _timer;
  String _cityName = 'جاري التحديد...';

  Map<String, String> _prayerTimes = {};
  String _nextPrayerName = '...';
  String _timeLeft = '';
  bool _isPrayerLoading = true;
  bool _isSchedulingNotifications = false;

  final Map<String, String> _fallbackTimes = {
    'Fajr': '04:30',
    'Sunrise': '05:45',
    'Dhuhr': '12:15',
    'Asr': '15:30',
    'Maghrib': '18:45',
    'Isha': '20:00'
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

  Map<String, String> currentVerseOfDay = {'verse': 'جاري التحميل...', 'surah': ''};
  Map<String, String> currentHadithOfDay = {'text': 'جاري التحميل...', 'source': ''};

  @override
  void initState() {
    super.initState();

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

    _setDailyContent();
    _updateTime();

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      final ok = await _ensureLocationPermission();
      _initLocationAndPrayersSafe();
    }

    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTime();
        _calculateNextPrayer();
      }
    });


    AdahnNotification.instance.onNotificationTap = (payload) {
      if (payload['type'] == 'adhan') {
        _showAdhanFromNotification(payload);
      }
    };

  }

  Future<void> _schedulePrayerNotifications() async {
    if (!mounted) return;
    if (_isSchedulingNotifications) return;

    if (_prayerTimes.isEmpty) {
      debugPrint('⚠️ لا يمكن الجدولة لأن أوقات الصلاة فارغة');
      return;
    }

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

      // إلغاء الأذان السابق + التنبيهات السابقة
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

        // 1) الأذان الحقيقي
        if (adhanEnabled) {
          final m = await MuezzinStore.getEffectiveForPrayer(key);

          final localPath = m.isBuiltIn
              ? null
              : await AdhanAudioService.instance.getLocalPath(m.id);

          final soundName =
          m.localSoundName.isNotEmpty ? m.localSoundName : 'makkah';

          await NativeAdhanBridge.scheduleAdhan(
            time: scheduledTime,
            prayerName: prayerName,
            requestCode: prayerId,
            soundName: soundName,
            localPath: localPath,
          );

          debugPrint(
            '✅ تم جدولة الأذان: $prayerName عند $scheduledTime | sound=$soundName | local=$localPath',
          );
        }

        // 2) التنبيه قبل الصلاة
        if (reminderEnabled && reminderOffset > 0) {
          final reminderTime =
          scheduledTime.subtract(Duration(minutes: reminderOffset));

          if (reminderTime.isAfter(DateTime.now())) {
            await NativeAdhanBridge.scheduleReminder(
              time: reminderTime,
              prayerName: prayerName,
              requestCode: prayerId + 1000,
              soundName: 'reminder_beep',
            );

            debugPrint(
              '🔔 تم جدولة التنبيه القبلي: $prayerName عند $reminderTime',
            );
          } else {
            debugPrint(
              '⏭️ تم تخطي التنبيه القبلي لـ $prayerName لأن وقته مر',
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
    if (!mounted) return;

    setState(() {
      _isPrayerLoading = true;
      _cityName = 'جاري تحديث الموقع...';
    });

    final ok = await _ensureLocationPermission();
    if (!ok) {
      setState(() {
        _isPrayerLoading = false;
      });
      return;
    }

    await _initLocationAndPrayersSafe();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الموقع والمواقيت', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى تشغيل خدمة الموقع', style: GoogleFonts.cairo()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض إذن الموقع', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _showAdhanFromNotification(Map<String, dynamic> payload) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdhanPlayerScreen(
            primaryColor: widget.appColors[widget.selectedColorIndex],
            prayerName: payload['prayerName'] ?? payload['prayer'] ?? 'الصلاة',
            muezzinName: payload['muezzinName'] ?? 'مؤذن',
            url: payload['muezzinUrl'] ?? '',
            localPath: (payload['localPath'] != null &&
                payload['localPath'].toString().isNotEmpty)
                ? payload['localPath']
                : null,
          ),
        ),
      );
    }
  }

  void _setDailyContent() async {
    DateTime now = DateTime.now();
    int daySeed = now.year * 10000 + now.month * 100 + now.day;

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
        var surah = surahs[daySeed % 114];
        List ayahs = surah['ayahs'];
        var ayah = ayahs[daySeed % ayahs.length];

        if (mounted) {
          setState(() {
            currentVerseOfDay = {
              'verse': ayah['text']
                  .toString()
                  .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
                  .trim(),
              'surah': '${surah['name']} - آية ${ayah['numberInSurah']}'
            };
          });
        }
      }

      final hadithFile = File('${dir.path}/hadith_forty_v1.json');
      if (await hadithFile.exists()) {
        final hadithData = json.decode(await hadithFile.readAsString());
        final hadithsList = hadithData['hadiths'] as List;
        var hadith = hadithsList[daySeed % hadithsList.length];

        if (mounted) {
          setState(() {
            currentHadithOfDay = {
              'text': hadith['text']
                  .toString()
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .trim(),
              'source': 'رقم الحديث: ${hadith['hadithnumber']}'
            };
          });
        }
      }
    } catch (e) {}
  }

  void _changeVerseManually() {
    setState(() {
      int currentIndex = dailyVerses.indexOf(currentVerseOfDay);
      if (currentIndex != -1) {
        int nextIndex = (currentIndex + 1) % dailyVerses.length;
        currentVerseOfDay = dailyVerses[nextIndex];
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    final newTime = '$hour:${now.minute.toString().padLeft(2, '0')} $period';

    if (_currentTime != newTime && mounted) {
      setState(() {
        _currentTime = newTime;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'طابت ليلتك 🌙';
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء النور 🌤';
    return 'مساء الخير 🌅';
  }

  Future<void> _initLocationAndPrayersSafe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLat = prefs.getDouble('last_lat');
    final savedLong = prefs.getDouble('last_long');
    final savedCity = prefs.getString('last_city');

    if (savedLat != null && savedLong != null && savedCity != null) {
      if (mounted) setState(() => _cityName = savedCity);
      _fetchPrayerTimesFromAPI(savedLat, savedLong);
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (savedCity == null) {
          _forceFallback('مكة المكرمة');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (savedCity == null) _forceFallback('مكة المكرمة');
          return;
        }
      }

      if (mounted) setState(() => _cityName = 'جاري التحديث...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));

      String accurateCityName =
      await _getAccurateCityName(position.latitude, position.longitude);

      if (mounted) setState(() => _cityName = accurateCityName);

      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_long', position.longitude);
      await prefs.setString('last_city', accurateCityName);

      await _fetchPrayerTimesFromAPI(position.latitude, position.longitude);
    } catch (e) {
      if (savedCity == null) {
        _forceFallback('مكة المكرمة');
      }
    }
  }

  Future<String> _getAccurateCityName(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long)
          .timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locality = place.subLocality ?? place.locality ?? '';
        String adminArea = place.administrativeArea ?? '';
        if (locality.isNotEmpty &&
            adminArea.isNotEmpty &&
            locality != adminArea) {
          return '$locality، $adminArea';
        } else if (locality.isNotEmpty) {
          return locality;
        } else if (adminArea.isNotEmpty) {
          return adminArea;
        } else {
          return place.country ?? 'موقعي';
        }
      }
    } catch (_) {}
    return 'موقعي';
  }

  Future<void> _fetchPrayerTimesFromAPI(double lat, double long) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodKey = prefs.getString('calc_method') ?? 'umm_al_qura';

      int method = 4;

      switch (methodKey) {
        case 'umm_al_qura':
          method = 4;
          break;
        case 'egyptian':
          method = 5;
          break;
        case 'mwl':
          method = 3;
          break;
        default:
          method = 4;
      }

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date?latitude=$lat&longitude=$long&method=$method',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);

        await prefs.setString('last_prayer_times', json.encode(timings));

        if (mounted) {
          setState(() {
            _prayerTimes = timings;
            _isPrayerLoading = false;
            _calculateNextPrayer();
          });
        }

        await _schedulePrayerNotifications();
      } else {
        await _loadLastSavedTimes();
      }
    } catch (e) {
      await _loadLastSavedTimes();
    }
  }

  Future<void> _loadLastSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = prefs.getString('last_prayer_times');

    if (savedTimes != null) {
      setState(() {
        _prayerTimes = Map<String, String>.from(json.decode(savedTimes));
        _isPrayerLoading = false;
        _calculateNextPrayer();
      });

      await _schedulePrayerNotifications();
    } else {
      _forceFallback('مكة المكرمة');
    }
  }

  void _forceFallback(String city) {
    if (mounted) {
      setState(() {
        _cityName = city;
        _prayerTimes = _fallbackTimes;
        _isPrayerLoading = false;
        _calculateNextPrayer();
      });

      _schedulePrayerNotifications();
    }
  }

  void _calculateNextPrayer() {
    if (_prayerTimes.isEmpty) return;
    DateTime now = DateTime.now();
    DateTime? nextPrayerTime;
    String nextName = '';

    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayerNames = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء'
    };

    for (var key in prayerOrder) {
      DateTime time = _parseTime(_prayerTimes[key]!);
      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextName = prayerNames[key]!;
        break;
      }
    }

    if (nextPrayerTime == null) {
      nextName = 'الفجر';
      DateTime fajr = _parseTime(_prayerTimes['Fajr']!);
      nextPrayerTime = fajr.add(const Duration(days: 1));
    }

    Duration diff = nextPrayerTime.difference(now);
    String timeLeftString = '';
    if (diff.inHours > 0) {
      timeLeftString = '${diff.inHours}س و ${diff.inMinutes % 60}د';
    } else {
      timeLeftString = '${diff.inMinutes} دقيقة';
    }

    if (mounted &&
        (_nextPrayerName != nextName || _timeLeft != timeLeftString)) {
      setState(() {
        _nextPrayerName = nextName;
        _timeLeft = timeLeftString;
      });
    }
  }

  DateTime _parseTime(String timeStr) {
    DateTime now = DateTime.now();
    try {
      final cleanTime = timeStr.split(' ')[0];
      List<String> parts = cleanTime.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calc_method', methodKey);

      final savedLat = prefs.getDouble('last_lat');
      final savedLong = prefs.getDouble('last_long');

      if (savedLat != null && savedLong != null) {
        await _fetchPrayerTimesFromAPI(savedLat, savedLong);
        return _prayerTimes;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));

      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_long', position.longitude);

      await _fetchPrayerTimesFromAPI(position.latitude, position.longitude);
      return _prayerTimes;
    } catch (e) {
      debugPrint('❌ apply calc method error: $e');
      return null;
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToScreen(int index) async {
    if (!mounted) return;

    final primaryColor = Theme.of(context).colorScheme.primary;
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

      if (mounted && index == 12) {
        await _refreshLocationAndPrayerTimes();
      }
    }
  }

  Future<void> applyCalculationMethodAndRefresh(String methodKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // حفظ طريقة الحساب الجديدة
      await prefs.setString('calc_method', methodKey);

      if (mounted) {
        setState(() {
          _isPrayerLoading = true;
        });
      }

      // استخدام آخر موقع محفوظ إن وجد
      final savedLat = prefs.getDouble('last_lat');
      final savedLong = prefs.getDouble('last_long');

      if (savedLat != null && savedLong != null) {
        await _fetchPrayerTimesFromAPI(savedLat, savedLong);
        return;
      }

      // لو لا يوجد موقع محفوظ نحاول جلب الموقع الحالي
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));

      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_long', position.longitude);

      await _fetchPrayerTimesFromAPI(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ خطأ أثناء تطبيق طريقة الحساب: $e');

      if (mounted) {
        setState(() {
          _isPrayerLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تحديث المواقيت بطريقة الحساب الجديدة',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(primary);
    final primaryDark = hsl.withLightness(0.2).toColor();
    final primaryMid = hsl.withLightness(0.35).toColor();
    final primaryLight = hsl.withLightness(0.5).toColor();

    return Scaffold(
      drawer: _buildDrawer(primary, isDark),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 310,
            floating: false,
            pinned: true,
            backgroundColor: primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                tooltip: 'تحديات اليوم',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyChallengesScreen(primaryColor: primary),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(primaryColor: primary),
                  ).then((result) {
                    if (result != null) {
                      if (result['type'] == 'quran') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailScreen(
                              surahName: result['surahName'],
                              surahNumber: result['surahNumber'],
                              initialPage: result['page'],
                              searchQuery: result['text'],
                            ),
                          ),
                        );
                      } else if (result['type'] == 'hadith') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HadithBookScreen(
                              bookId: result['bookId'] ?? 'riyad',
                              bookTitle: result['bookName'] ?? 'رياض الصالحين',
                              primaryColor: primary,
                            ),
                          ),
                        );
                      }
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_voice, color: Colors.white),
                tooltip: 'المؤذن',
                onPressed: () => _navigateToScreen(11),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _navigateToScreen(12),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(primaryDark, primaryMid, primaryLight),
            ),
          ),
          SliverToBoxAdapter(child: _buildPrayerCard(primary, isDark)),
          SliverToBoxAdapter(child: _buildQuickAccess(primary, isDark)),
          SliverToBoxAdapter(child: _buildDailyVerse(primary, isDark)),
          SliverToBoxAdapter(child: _buildSectionTitle(primary)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnimatedCard(index, primary, isDark),
                childCount: features.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildHadithCard(primary, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
            padding: const EdgeInsets.only(top: 60, bottom: 30, right: 20, left: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, HSLColor.fromColor(primary).withLightness(0.3).toColor()],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.transparent : Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    color: isDark ? primary : primary.withOpacity(0.99),
                  ),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 90,
                    errorBuilder: (c, e, s) =>
                    const Icon(Icons.mosque_rounded, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text('طريق الاسلام', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('رفيقك اليومي', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
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
                  leading: Icon(feature['icon'] as IconData, color: primary),
                  title: Text(feature['title'] as String, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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

  Widget _buildHeader(Color dark, Color mid, Color light) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dark, mid, light],
        ),
      ),
      child: Stack(
        children: [
          ..._buildDecorations(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _buildGreetingRow(),
                      const SizedBox(height: 20),
                      _buildMosqueIcon(),
                      const SizedBox(height: 16),
                      _buildBismillah(),
                      const SizedBox(height: 10),
                      _buildTagline(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorations() {
    final random = Random(42);
    return [
      Positioned(top: -60, right: -60, child: _circle(200, 0.06)),
      Positioned(top: 30, right: 30, child: _circle(80, 0.08)),
      Positioned(bottom: -40, left: -40, child: _circle(160, 0.05)),
      Positioned(top: 80, left: -30, child: _circle(100, 0.04)),
      Positioned(bottom: 60, right: 20, child: _circle(50, 0.07)),
      ...List.generate(8, (i) {
        return Positioned(
          top: 60.0 + random.nextDouble() * 220,
          left: random.nextDouble() * 350,
          child: Icon(
            Icons.star,
            size: 6 + random.nextDouble() * 8,
            color: Colors.white.withOpacity(0.1 + random.nextDouble() * 0.15),
          ),
        );
      }),
    ];
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildGreetingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _cityName,
                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(_currentTime, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildMosqueIcon() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
        ),
        child: Image.asset(
          'assets/icon/icon.png',
          width: 91,
          errorBuilder: (c, e, s) => const Icon(Icons.mosque_rounded, size: 55, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Text(
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      style: GoogleFonts.amiri(
        fontSize: 26,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(25)),
      child: Text('✨ تطبيقك الإسلامي الشامل ✨', style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildPrayerCard(Color primary, bool isDark) {
    double progress = 0.0;
    if (_prayerTimes.isNotEmpty && _nextPrayerName != '...') {
      try {
        DateTime now = DateTime.now();
        DateTime? previousPrayerTime;
        DateTime? nextPrayerTime;

        final prayerKeys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
        for (int i = 0; i < prayerKeys.length; i++) {
          DateTime time = _parseTime(_prayerTimes[prayerKeys[i]]!);
          if (time.isAfter(now)) {
            nextPrayerTime = time;
            if (i > 0) {
              previousPrayerTime = _parseTime(_prayerTimes[prayerKeys[i - 1]]!);
            } else {
              previousPrayerTime =
                  _parseTime(_prayerTimes['Isha']!).subtract(const Duration(days: 1));
            }
            break;
          }
        }
        if (nextPrayerTime == null) {
          nextPrayerTime = _parseTime(_prayerTimes['Fajr']!).add(const Duration(days: 1));
          previousPrayerTime = _parseTime(_prayerTimes['Isha']!);
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

    final gradientStart = isDark ? primary.withOpacity(0.7) : primary.withOpacity(0.9);
    final gradientEnd = isDark ? primary.withOpacity(0.7) : primary.withOpacity(0.9);
    const textColor = Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? primary.withOpacity(0.2) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? primary.withOpacity(0.5) : primary.withOpacity(0.9),
            blurRadius: isDark ? 7 : 18,
            offset: Offset(isDark ? 0 : 0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
            ),
            child: _isPrayerLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: textColor),
              ),
            )
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'الصلاة القادمة',
                            style: GoogleFonts.cairo(fontSize: 11, color: textColor.withOpacity(0.9)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nextPrayerName,
                          style: GoogleFonts.amiri(
                            color: Colors.amberAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'الوقت المتبقي',
                          style: GoogleFonts.cairo(fontSize: 11, color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timeLeft,
                          style: GoogleFonts.cairo(
                            color: Colors.amberAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.8) : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _prayerInfo.map((p) {
                  bool isNext = _nextPrayerName.contains(p['name']);
                  String time = _prayerTimes[p['key']] ?? '--:--';
                  String formattedTime = _formatTimeAMPM(time);
                  String timeNum = formattedTime.replaceAll(RegExp(r'[صم]'), '').trim();
                  String timePeriod =
                  formattedTime.contains('ص') ? 'ص' : (formattedTime.contains('م') ? 'م' : '');

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isNext ? primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isNext
                          ? Border.all(color: primary.withOpacity(0.3), width: 1.5)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p['name'],
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                            color: isNext ? primary : (isDark ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              timeNum,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isNext ? primary : (isDark ? primary : Colors.black87),
                              ),
                            ),
                            if (timePeriod.isNotEmpty) ...[
                              const SizedBox(width: 2),
                              Text(
                                timePeriod,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isNext ? primary : Colors.grey,
                                ),
                              )
                            ]
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(Color primary, bool isDark) {
    final items = [
      {'icon': Icons.menu_book, 'label': 'القرآن', 'index': 0},
      {'icon': Icons.track_changes, 'label': 'ختمتي', 'index': 6},
      {'icon': Icons.auto_awesome, 'label': 'الأذكار', 'index': 2},
      {'icon': Icons.emoji_events_rounded, 'label': 'حصاد الحسنات', 'index': 5},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? primary.withOpacity(0.5) : primary.withOpacity(0.7),
            blurRadius:isDark? 9 : 20,
            offset: Offset(isDark ? 0 : 0, 2),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items.map((item) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToScreen(item['index'] as int),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary.withOpacity(0.15), primary.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withOpacity(0.1)),
                      ),
                      child: Icon(item['icon'] as IconData, color: primary, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          item['label'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDailyVerse(Color primary, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(isDark ? 0.3 : 0.08),
            primary.withOpacity(isDark ? 0.15 : 0.03)
          ],
        ),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Stack(
        children: [
          Positioned(top: -15, left: -15, child: Icon(Icons.format_quote, size: 80, color: primary.withOpacity(0.06))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.auto_awesome, color: primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('آية اليوم', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _changeVerseManually,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.refresh, color: primary, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currentVerseOfDay['verse']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(fontSize: 22, height: 2.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (currentVerseOfDay['surah']!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentVerseOfDay['surah']!,
                      style: GoogleFonts.cairo(fontSize: 13, color: primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text('الأقسام الرئيسية', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${features.length} أقسام', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Color primary, bool isDark) {
    final delay = index * 0.08;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        double progress = ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        double curved = Curves.easeOutBack.transform(progress);
        return Transform.scale(scale: 0.5 + (0.5 * curved), child: Opacity(opacity: progress, child: child));
      },
      child: _buildFeatureCard(index, primary, isDark),
    );
  }

  Widget _buildFeatureCard(int index, Color primary, bool isDark) {
    final feature = features[index];
    final hsl = HSLColor.fromColor(primary);
    final color1 =isDark? hsl.withLightness((hsl.lightness - 0.24).clamp(0.0, 1.0)).toColor() :  hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();
    final color2 =isDark? hsl.withLightness((hsl.lightness + 0.03).clamp(0.0, 1.0)).toColor() : hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();

    return GestureDetector(
      onTap: () => _navigateToScreen(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color1, color2]),
          boxShadow: [BoxShadow(
              color:isDark? primary.withOpacity(0.3) : primary.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )],
        ),
        child: Stack(
          children: [
            Positioned(top: -25, left: -25, child: _circle(80, 0.1)),
            Positioned(bottom: -35, right: -35, child: _circle(110, 0.06)),
            Positioned(top: 10, left: 10, child: Text(feature['badge'] as String, style: const TextStyle(fontSize: 20))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Icon(feature['icon'] as IconData, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      feature['title'] as String,
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      feature['subtitle'] as String,
                      style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                      maxLines: 1,
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

  Widget _buildHadithCard(Color primary, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [primary.withOpacity(0.25), primary.withOpacity(0.1)]
              : [primary.withOpacity(0.06), primary.withOpacity(0.02)],
        ),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.lightbulb_outline, color: primary),
              ),
              const SizedBox(width: 10),
              Text('حديث اليوم', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 14),
          Text('قال رسول الله ﷺ:', style: GoogleFonts.cairo(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(currentHadithOfDay['text']!, textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 20, height: 1.8)),
          const SizedBox(height: 10),
          if (currentHadithOfDay['source']!.isNotEmpty)
            Text(
              currentHadithOfDay['source']!,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}