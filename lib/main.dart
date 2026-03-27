import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:islamic_app/services/adhan_image_preload_service.dart';
import 'package:islamic_app/services/radio_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'controllers/prayer_times_controller.dart';
import 'main_shell_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/prayer/adhan_player_screen.dart';
import 'services/adahn_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await RadioService.initRadio();
  await initializeDateFormatting('ar', null);
  tz_data.initializeTimeZones();
  final tzName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzName));

  await AdahnNotification.instance.init();

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('adhan_images_preloaded');

  runApp(
    ChangeNotifierProvider(
      create: (_) => PrayerTimesController()..initialize(),
      child: const MyApp(),
    ),
  );
}

// ═══ باقي الكود بدون أي تعديل ═══

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isDarkMode = true;
  bool _splashDone = false;
  bool _prefsLoaded = false;
  int _selectedColorIndex = 0;

  static const List<Color> appColors = [
    Color(0xFF123C33),
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
    Color(0xFF00695C),
  ];

  static const List<String> colorNames = [
    'أخضر إسلامي',
    'أخضر زمردي',
    'أزرق سماوي',
    'بنفسجي',
    'وردي غامق',
    'تيل',
    'برتقالي',
    'نيلي',
    'بني',
    'رمادي فحمي',
    'أحمر',
    'أخضر بحري',
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
    if (prefs.getBool('adhan_images_preloaded') ?? false) return;
    final success = await AdhanImagePreloadService.preloadAllImages();
    if (success) await prefs.setBool('adhan_images_preloaded', true);
  }

  void _setupNotificationListener() {
    AdahnNotification.instance.onNotificationTap = (payload) {
      if (payload['type'] == 'adhan') {
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => AdhanPlayerScreen(
            primaryColor: appColors[_selectedColorIndex],
            prayerName: payload['prayerName'] ?? payload['prayer'] ?? 'الصلاة',
            muezzinName: payload['muezzinName'] ?? 'مؤذن',
            url: payload['muezzinUrl'] ?? '',
            localPath: (payload['localPath']?.toString().isNotEmpty ?? false)
                ? payload['localPath']
                : null,
          ),
        ));
      }
    };
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _selectedColorIndex = (prefs.getInt('colorIndex') ?? 0)
          .clamp(0, appColors.length - 1);
      _prefsLoaded = true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('colorIndex', _selectedColorIndex);
  }

  void _changeTheme(bool value) {
    setState(() => _isDarkMode = value);
    _savePrefs();
  }

  void _changeColor(int index) {
    setState(() => _selectedColorIndex = index);
    _savePrefs();
  }

  void _goToHome() {
    if (mounted) setState(() => _splashDone = true);
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0A0E17);
    const bgLight = Color(0xFFF0F4FF);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'طريق الإسلام',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColors[_selectedColorIndex],
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgLight,
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColors[_selectedColorIndex],
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: bgDark,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: !_prefsLoaded
          ? Container(color: _isDarkMode ? bgDark : bgLight)
          : _AppRoot(
        splashDone: _splashDone,
        isDark: _isDarkMode,
        onFinish: _goToHome,
        colorIndex: _selectedColorIndex,
        onThemeChanged: _changeTheme,
        onColorChanged: _changeColor,
        appColors: appColors,
        colorNames: colorNames,
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  final bool splashDone;
  final bool isDark;
  final VoidCallback onFinish;
  final int colorIndex;
  final void Function(bool) onThemeChanged;
  final void Function(int) onColorChanged;
  final List<Color> appColors;
  final List<String> colorNames;

  const _AppRoot({
    required this.splashDone,
    required this.isDark,
    required this.onFinish,
    required this.colorIndex,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.appColors,
    required this.colorNames,
  });

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _splashFade;
  late Animation<double> _homeFade;

  bool _homeReady = false;
  bool _splashGone = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _splashFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _homeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _splashGone = true);
      }
    });
  }

  @override
  void didUpdateWidget(_AppRoot old) {
    super.didUpdateWidget(old);
    if (widget.splashDone && !old.splashDone) {
      _startTransition();
    }
  }

  void _startTransition() {
    setState(() => _homeReady = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_ctrl.isAnimating) {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: widget.isDark
              ? const Color(0xFF0A0E17)
              : const Color(0xFFF0F4FF),
        ),
        if (_homeReady) ...[
          if (!_splashGone)
            AnimatedBuilder(
              animation: _homeFade,
              builder: (_, child) => Opacity(
                opacity: _homeFade.value.clamp(0.0, 1.0),
                child: child,
              ),
              child: _buildHome(),
            )
          else
            _buildHome(),
        ],
        if (!_splashGone)
          AnimatedBuilder(
            animation: _splashFade,
            builder: (_, child) => Opacity(
              opacity: _splashFade.value.clamp(0.0, 1.0),
              child: child,
            ),
            child: SplashScreen(
              key: const ValueKey('splash'),
              onFinish: widget.onFinish,
            ),
          ),
      ],
    );
  }

  Widget _buildHome() {
    return MainShellScreen(
      key: const ValueKey('home'),
      onThemeChanged: widget.onThemeChanged,
      onColorChanged: widget.onColorChanged,
      isDarkMode: widget.isDark,
      selectedColorIndex: widget.colorIndex,
      appColors: widget.appColors,
      colorNames: widget.colorNames,
    );
  }
}