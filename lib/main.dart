import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:islamic_app/screens/auth/auth_screen.dart';
import 'package:islamic_app/screens/auth/services/auth_service.dart';
import 'package:islamic_app/screens/channels/cache/image_cache_config.dart';
import 'package:islamic_app/screens/channels/helpers/app_initializer.dart';
import 'package:islamic_app/screens/mircle/color_control/miracle_color_provider.dart';
import 'package:islamic_app/screens/prayer/features/prayer_os/domain/controllers/prayer_journey_controller.dart';
import 'package:islamic_app/screens/profile/providers/profile_image_provider.dart';
import 'package:islamic_app/screens/profile/services/stats_service.dart';
import 'package:islamic_app/screens/prayer/more/services/adhan_image_preload_service.dart';
import 'package:islamic_app/screens/prayer/more/services/radio_services.dart';
import 'package:islamic_app/screens/radio/data/radio_data.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/image_cache_service.dart';
import 'package:islamic_app/screens/radio/services/listening_history_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_download_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_watch_history_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/playlist_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import 'languages/app_localizations.dart';
import 'languages/locale_provider.dart';
import 'main_shell_screen.dart';
import 'screens/prayer/adhan_player_screen/adhan_player_screen.dart';
import 'screens/prayer/more/controllers/prayer_times_controller.dart';
import 'screens/prayer/more/services/adahn_notification.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ImageCacheConfig.configure();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AppBootstrap());
}

class AppStartupData {
  final AuthService authService;
  final StatsService statsService;
  final ProfileImageProvider profileImageProvider;
  final LocaleProvider localeProvider;

  const AppStartupData({
    required this.authService,
    required this.statsService,
    required this.profileImageProvider,
    required this.localeProvider,
  });
}

Future<AppStartupData> _initializeApp() async {
  debugPrint('🚀 App initialization started');

  final localeProvider = LocaleProvider();

  try {
    debugPrint('• Locale init start');
    await localeProvider.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () => debugPrint('⚠️ Locale init timeout'),
    );
    debugPrint('• Locale init done');
  } catch (e) {
    debugPrint('⚠️ Locale init error: $e');
  }

  try {
    debugPrint('• Date formatting start');
    await initializeDateFormatting('ar', null).timeout(
      const Duration(seconds: 5),
      onTimeout: () => debugPrint('⚠️ Date formatting timeout'),
    );
    debugPrint('• Date formatting done');
  } catch (e) {
    debugPrint('⚠️ Date formatting error: $e');
  }

  try {
    debugPrint('• Timezone start');
    tz_data.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone().timeout(
      const Duration(seconds: 5),
      onTimeout: () => 'UTC',
    );
    tz.setLocalLocation(tz.getLocation(tzName));
    debugPrint('• Timezone done: $tzName');
  } catch (e) {
    debugPrint('⚠️ Timezone error: $e');
    try {
      tz.setLocalLocation(tz.getLocation('UTC'));
    } catch (_) {}
  }

  try {
    debugPrint('• Firebase start');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Firebase init timeout'),
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('• Firebase done');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  final authService = AuthService();

  try {
    debugPrint('• Auth start');
    await authService.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('⚠️ Auth timeout');
      },
    );
    debugPrint('• Auth done');
  } catch (e) {
    debugPrint('⚠️ Auth error: $e');
  }

  final statsService = StatsService(authService);
  final profileImageProvider = ProfileImageProvider(authService);

  unawaited(
    _runDeferredStartupTasks(
      authService: authService,
      statsService: statsService,
      profileImageProvider: profileImageProvider,
    ),
  );

  debugPrint('✅ Essential app initialization completed');

  return AppStartupData(
    authService: authService,
    statsService: statsService,
    profileImageProvider: profileImageProvider,
    localeProvider: localeProvider,
  );
}

Future<void> _runDeferredStartupTasks({
  required AuthService authService,
  required StatsService statsService,
  required ProfileImageProvider profileImageProvider,
}) async {
  debugPrint('🟡 Deferred startup tasks started');

  VideoWatchHistoryService().init();

  await Future.wait([
    (() async {
      try {
        debugPrint('• AppInitializer start');
        await AppInitializer.initialize().timeout(
          const Duration(seconds: 8),
          onTimeout: () => debugPrint('⚠️ AppInitializer timeout'),
        );
        debugPrint('• AppInitializer done');
      } catch (e) {
        debugPrint('⚠️ AppInitializer error: $e');
      }
    })(),
    (() async {
      try {
        debugPrint('• RadioService start');
        await RadioService.initRadio().timeout(
          const Duration(seconds: 8),
          onTimeout: () => debugPrint('⚠️ RadioService timeout'),
        );
        debugPrint('• RadioService done');
      } catch (e) {
        debugPrint('⚠️ RadioService error: $e');
      }
    })(),
    (() async {
      try {
        debugPrint('• Notification init start');
        await AdahnNotification.instance.init().timeout(
          const Duration(seconds: 8),
          onTimeout: () => debugPrint('⚠️ Notification init timeout'),
        );
        debugPrint('• Notification init done');
      } catch (e) {
        debugPrint('⚠️ Notification init error: $e');
      }
    })(),
    (() async {
      try {
        debugPrint('• SharedPreferences start');
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('SharedPreferences timeout'),
        );
        await prefs.remove('adhan_images_preloaded');
        debugPrint('• SharedPreferences done');
      } catch (e) {
        debugPrint('⚠️ SharedPreferences error: $e');
      }
    })(),
    (() async {
      try {
        debugPrint('• Stats start');
        await statsService.init().timeout(
          const Duration(seconds: 5),
          onTimeout: () => debugPrint('⚠️ Stats timeout'),
        );
        debugPrint('• Stats done');
      } catch (e) {
        debugPrint('⚠️ Stats error: $e');
      }
    })(),
    (() async {
      try {
        debugPrint('• Profile image start');
        await profileImageProvider.initialize().timeout(
          const Duration(seconds: 3),
          onTimeout: () => debugPrint('⚠️ Profile image timeout'),
        );
        debugPrint('• Profile image done');
      } catch (e) {
        debugPrint('⚠️ Profile image error: $e');
      }
    })(),
  ]);

  debugPrint('🟢 Deferred startup tasks completed');
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final Future<AppStartupData> _startupFuture;
  AppStartupData? _startupData;
  Object? _startupError;
  bool _splashFinished = false;

  bool _isDarkMode = true;
  int _selectedColorIndex = 0;
  bool _prefsLoaded = false;

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

  @override
  void initState() {
    super.initState();
    _loadPrefs();

    _startupFuture = _initializeApp();
    _startupFuture
        .then((value) {
          if (!mounted) return;
          setState(() => _startupData = value);
          _setupNotificationListener();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preloadImages();
            _preloadRadioImages();
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() => _startupError = error);
        });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _selectedColorIndex = (prefs.getInt('colorIndex') ?? 0).clamp(
        0,
        appColors.length - 1,
      );
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

  Future<void> _preloadImages() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('adhan_images_preloaded') ?? false) return;
    final success = await AdhanImagePreloadService.preloadAllImages();
    if (success) {
      await prefs.setBool('adhan_images_preloaded', true);
    }
  }

  Future<void> _preloadRadioImages() async {
    try {
      await ImageCacheService().init();

      final imageUrls = <String>{};

      // ✅ صور القراء والمحطات
      for (final station in RadioStationsData.all) {
        if (station.imageUrl != null && station.imageUrl!.isNotEmpty) {
          imageUrls.add(station.imageUrl!);
        }
      }

      // ✅ صور التلاوات
      final categories = RecitationCategoriesData.build();
      for (final cat in categories) {
        for (final item in cat.items) {
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
            imageUrls.add(item.imageUrl!);
          }
          // صور العناصر الفرعية
          for (final sub in item.allSubItems) {
            if (sub.imageUrl != null && sub.imageUrl!.isNotEmpty) {
              imageUrls.add(sub.imageUrl!);
            }
          }
        }
      }

      debugPrint('📥 Preloading ${imageUrls.length} images...');

      unawaited(ImageCacheService().preloadImages(imageUrls.toList()));
    } catch (e) {
      debugPrint('⚠️ Image preload error: $e');
    }
  }

  void _setupNotificationListener() {
    if (_startupData == null) return;

    AdahnNotification.instance.onNotificationTap = (payload) {
      if (payload['type'] == 'adhan') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder:
                (_) => AdhanPlayerScreen(
                  primaryColor: appColors[_selectedColorIndex],
                  prayerName:
                      payload['prayerName'] ?? payload['prayer'] ?? 'الصلاة',
                  muezzinName: payload['muezzinName'] ?? 'مؤذن',
                  url: payload['muezzinUrl'] ?? '',
                  localPath:
                      (payload['localPath']?.toString().isNotEmpty ?? false)
                          ? payload['localPath']
                          : null,
                ),
          ),
        );
      }
    };
  }

  void _onSplashFinish() {
    if (!mounted) return;
    setState(() => _splashFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0A0E17);
    const bgLight = Color(0xFFF0F4FF);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'طريق الإسلام',
      debugShowCheckedModeBanner: false,
      locale: _startupData?.localeProvider.locale ?? const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      builder: (context, child) {
        final textDirection =
            _startupData?.localeProvider.textDirection ?? TextDirection.rtl;

        Widget wrappedChild = Directionality(
          textDirection: textDirection,
          child: child!,
        );

        if (_startupData != null) {
          wrappedChild = MultiProvider(
            providers: [
              ChangeNotifierProvider<MiracleColorProvider>(
                create: (_) => MiracleColorProvider(),
              ),
              // ── بقية الـ providers بدون أي تعديل ──
              ChangeNotifierProvider(
                create: (_) => PrayerTimesController()..initialize(),
              ),
              ChangeNotifierProvider(create: (_) => PrayerJourneyController()),
              ChangeNotifierProvider(create: (_) => AudioCoordinator()),
              ChangeNotifierProxyProvider<AudioCoordinator, RadioIntillegence>(
                create: (_) => AudioCoordinator().onlineRadio..init(),
                update: (_, coordinator, __) => coordinator.onlineRadio,
              ),
              ChangeNotifierProxyProvider<
                AudioCoordinator,
                OfflineRadioService
              >(
                create: (_) => AudioCoordinator().offlineRadio..init(),
                update: (_, coordinator, __) => coordinator.offlineRadio,
              ),
              ChangeNotifierProxyProvider<AudioCoordinator, OnlineSurahService>(
                create: (_) => AudioCoordinator().onlineSurah..init(),
                update: (_, coordinator, __) => coordinator.onlineSurah,
              ),
              ChangeNotifierProvider(
                create: (_) => RadioDownloadService()..init(),
              ),
              ChangeNotifierProvider(
                create: (_) => ItemDownloadService()..init(),
              ),
              ChangeNotifierProvider(create: (_) => PlaylistService()),
              ChangeNotifierProvider(
                create: (_) => ListeningHistoryService()..init(),
              ),
              ChangeNotifierProvider(
                create: (_) => VideoDownloadService()..init(),
              ),
              ChangeNotifierProvider.value(value: _startupData!.authService),
              ChangeNotifierProvider.value(value: _startupData!.statsService),
              ChangeNotifierProvider.value(
                value: _startupData!.profileImageProvider,
              ),
              ChangeNotifierProvider.value(value: _startupData!.localeProvider),
            ],
            child: wrappedChild,
          );
        }

        return ColoredBox(
          color: _isDarkMode ? bgDark : bgLight,
          child: wrappedChild,
        );
      },
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_startupError != null) {
      return Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'حدث خطأ أثناء تهيئة التطبيق:\n\n$_startupError',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    if (!_prefsLoaded || _startupData == null || !_splashFinished) {
      return SplashScreen(onFinish: _onSplashFinish);
    }

    return _AppRoot(
      splashDone: true,
      isDark: _isDarkMode,
      onFinish: _onSplashFinish,
      colorIndex: _selectedColorIndex,
      onThemeChanged: _changeTheme,
      onColorChanged: _changeColor,
      appColors: appColors,
    );
  }
}

// ══════════════════════════════════════════════
//  _AppRoot - بدون أي تعديل
// ══════════════════════════════════════════════
class _AppRoot extends StatefulWidget {
  final bool splashDone;
  final bool isDark;
  final VoidCallback onFinish;
  final int colorIndex;
  final void Function(bool) onThemeChanged;
  final void Function(int) onColorChanged;
  final List<Color> appColors;

  const _AppRoot({
    required this.splashDone,
    required this.isDark,
    required this.onFinish,
    required this.colorIndex,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.appColors,
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

    _splashFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _homeFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _splashGone = true);
      }
    });

    if (widget.splashDone) {
      _homeReady = true;
      _splashGone = true;
      _ctrl.value = 1.0;
    }
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
      if (mounted && !_ctrl.isAnimating) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.isDark ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_homeReady) ...[
            if (!_splashGone)
              AnimatedBuilder(
                animation: _homeFade,
                builder:
                    (_, child) => Opacity(
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
              builder:
                  (_, child) => Opacity(
                    opacity: _splashFade.value.clamp(0.0, 1.0),
                    child: child,
                  ),
              child: SplashScreen(
                key: const ValueKey('splash'),
                onFinish: widget.onFinish,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final tr = AppLocalizations.of(context);

    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final isLoggedIn = auth.status == AuthStatus.authenticated;

        final child =
            !isLoggedIn
                ? const AuthScreen(key: ValueKey('auth'))
                : MainShellScreen(
                  key: const ValueKey('home'),
                  onThemeChanged: widget.onThemeChanged,
                  onColorChanged: widget.onColorChanged,
                  isDarkMode: widget.isDark,
                  selectedColorIndex: widget.colorIndex,
                  appColors: widget.appColors,
                  colorNames: [
                    tr.t('colorIslamicGreen'),
                    tr.t('colorEmeraldGreen'),
                    tr.t('colorSkyBlue'),
                    tr.t('colorPurple'),
                    tr.t('colorDarkPink'),
                    tr.t('colorTeal'),
                    tr.t('colorOrange'),
                    tr.t('colorIndigo'),
                    tr.t('colorBrown'),
                    tr.t('colorCharcoal'),
                    tr.t('colorRed'),
                    tr.t('colorSeaGreen'),
                  ],
                );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child: ColoredBox(
            key: ValueKey(isLoggedIn ? 'home' : 'auth'),
            color:
                widget.isDark
                    ? const Color(0xFF0A0E17)
                    : const Color(0xFFF0F4FF),
            child: child,
          ),
        );
      },
    );
  }
}
