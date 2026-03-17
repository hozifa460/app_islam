import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:islamic_app/services/adhan_image_preload_service.dart';
import 'package:islamic_app/services/radio_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'screens/home/screen/HomeScreen.dart';
import 'screens/splash_screen.dart';
import 'screens/prayer/adhan_player_screen.dart';
import 'services/adahn_notification.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));


  await AndroidAlarmManager.initialize();
  await RadioService.initRadio();
  await initializeDateFormatting('ar', null);
  tz_data.initializeTimeZones();
  final tzName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzName));

  await AdahnNotification.instance.init();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('adhan_images_preloaded');


  runApp(const MyApp());

}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool isDarkMode = true;
  int selectedColorIndex = 0;

  static const List<Color> appColors = [
    Color(0xFF1B5E20),
    Color(0xFF0D47A1),
    Color(0xFF4A148C),
    Color(0xFF880E4F),
    Color(0xFF006064),
    Color(0xFFE65100),
    Color(0xFF1A237E),
    Color(0xFF3E2723),
    Color(0xFF263238),
    Color(0xFFB71C1C),
  ];

  static const List<String> colorNames = [
    'أخضر إسلامي',
    'أزرق سماوي',
    'بنفسجي',
    'وردي',
    'تيل',
    'برتقالي',
    'نيلي',
    'بني',
    'رمادي',
    'أحمر'
  ];


  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _setupNotificationListener();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('adhan_images_preloaded') ?? false;

    if (done) return;

    final success = await AdhanImagePreloadService.preloadAllImages();

    if (success) {
      await prefs.setBool('adhan_images_preloaded', true);
    } else {
      debugPrint('Some adhan images failed to preload. Will retry next launch.');
    }
  }


  void _setupNotificationListener() {
    AdahnNotification.instance.onNotificationTap = (payload) {
      if (payload['type'] == 'adhan') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AdhanPlayerScreen(
              primaryColor: appColors[selectedColorIndex],
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
      } else if (payload['type'] == 'reminder') {
        // التنبيه القبلي لا يحتاج فتح مشغل الأذان
        // يمكن لاحقاً فتح صفحة مواقيت الصلاة أو عدم فعل شيء
      }
    };
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      selectedColorIndex = prefs.getInt('colorIndex') ?? 0;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('colorIndex', selectedColorIndex);
  }

  void _changeTheme(bool value) {
    setState(() => isDarkMode = value);
    _savePrefs();
  }

  void _changeColor(int index) {
    setState(() => selectedColorIndex = index);
    _savePrefs();
  }

  void _goToHome() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          onThemeChanged: _changeTheme,
          onColorChanged: _changeColor,
          isDarkMode: isDarkMode,
          selectedColorIndex: selectedColorIndex,
          appColors: appColors,
          colorNames: colorNames,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = appColors[selectedColorIndex];

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'طريق الإسلام',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: SplashScreen(onFinish: _goToHome),
    );
  }
}