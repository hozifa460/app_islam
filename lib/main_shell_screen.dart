import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/AsmaAllah/asma_allah_screen.dart';
import 'package:islamic_app/screens/Azkar/azkar_screen.dart';
import 'package:islamic_app/screens/GreatMuslim/great_muslims_screen.dart';
import 'package:islamic_app/screens/books/books_screen.dart';
import 'package:islamic_app/screens/channels/cache/image_cache_config.dart';
import 'package:islamic_app/screens/channels/channels_screen.dart';
import 'package:islamic_app/screens/channels/services/channels_prefetch_service.dart';
import 'package:islamic_app/screens/channels/services/feed_cache_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/dua/dua_screen.dart';
import 'package:islamic_app/screens/fatwa/fatwa_chat_screen.dart';
import 'package:islamic_app/screens/fatwa/fatwa_search_screen.dart';
import 'package:islamic_app/screens/hadith/hadith_screen.dart';
import 'package:islamic_app/screens/hasanat/hasanat_screen.dart';
import 'package:islamic_app/screens/hijri/hijri_calendar_screen.dart';
import 'package:islamic_app/screens/home/HomeScreen.dart';
import 'package:islamic_app/screens/inheritance/inheritance_screen.dart';
import 'package:islamic_app/screens/khatma/khatma_screen.dart';
import 'package:islamic_app/screens/mircle/miracles_screen.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_times_screen/prayer_time_screen.dart';
import 'package:islamic_app/screens/profile/profile_screen.dart';
import 'package:islamic_app/screens/profile/providers/profile_image_provider.dart';
import 'package:islamic_app/screens/prophet_sunnah/prophet_sunnah_screen.dart';
import 'package:islamic_app/screens/qibla/qibla_splash_screen.dart';
import 'package:islamic_app/screens/qibla/qibla_screen.dart';
import 'package:islamic_app/screens/quran/quran_screen.dart';
import 'package:islamic_app/screens/radio/radio_screen.dart';
import 'package:islamic_app/screens/salawat/salawat_reminder_screen.dart';
import 'package:islamic_app/screens/settings/settings_screen.dart';
import 'package:islamic_app/screens/sunnah/sunnah_tracker_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'languages/app_localizations.dart';

class MainShellScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(int) onColorChanged;
  final bool isDarkMode;
  final int selectedColorIndex;
  final List<Color> appColors;
  final List<String> colorNames;
  final Map<String, String>? prayerTimes;
  final String? cityName;
  final Future<void> Function()? onRefreshLocation;
  final Future<Map<String, String>?> Function(String methodKey)?
  onApplyCalculationMethod;
  final Future<void> Function(int offset)? onReminderOffsetChanged;

  const MainShellScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.selectedColorIndex,
    required this.appColors,
    required this.colorNames,
    this.prayerTimes,
    this.cityName,
    this.onRefreshLocation,
    this.onApplyCalculationMethod,
    this.onReminderOffsetChanged,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  static const _gold = Color(0xFFC8A44D);

  String? _profileImage;

  bool _channelsTabWarmed = false;

  Color get _primary => widget.appColors[widget.selectedColorIndex];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      unawaited(() async {
        await ChannelsPrefetchService.warmupBeforeOpen();
        if (!mounted) return;
        await _precacheChannelsFeedImages();
      }());
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted || _channelsTabWarmed) return;

      setState(() {
        _visitedTabs.add(3); // طھط¨ظˆظٹط¨ ط§ظ„ظ‚ظ†ظˆط§طھ
        _channelsTabWarmed = true;
      });
    });
  }

  Future<void> _precacheChannelsFeedImages() async {
    try {
      final cached = await FeedCacheService.loadFeed();
      if (cached == null) return;
      if (!mounted) return;

      final items = <YoutubeVideo>[
        ...cached.videos.take(8),
        ...cached.shorts.take(4),
      ];

      for (final video in items) {
        if (video.thumbnail.trim().isEmpty) continue;

        try {
          await precacheImage(
            CachedNetworkImageProvider(
              video.thumbnail,
              cacheManager: ImageCacheConfig.customCacheManager,
            ),
            context,
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('❌ _precacheChannelsFeedImages error: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    final p = await SharedPreferences.getInstance();
    final path = p.getString('profile_local_image');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => _profileImage = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);

    return Scaffold(
      backgroundColor: bg,
      // âœ… ط£ط¶ظپ ط§ظ„ط²ط± ط§ظ„ط¹ط§ط¦ظ… ظ‡ظ†ط§
      floatingActionButton: _buildFatwaFAB(context, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Stack(
        children: [
          Positioned.fill(
            left: 0,
            right: 0,
            bottom: 0,
            child: _LazyIndexedStack(
              index: _currentIndex,
              visitedTabs: _visitedTabs,
              backgroundColor: bg,
              children: _buildTabs(isDark),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassNavBar(
              currentIndex: _currentIndex,
              isDark: isDark,
              primary: _primary,
              bg: bg,
              onTap: (index) {
                if (_currentIndex == index) return;
                HapticFeedback.lightImpact();
                setState(() {
                  _currentIndex = index;
                  _visitedTabs.add(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFatwaFAB(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gap(10),
        // â•گâ•گâ•گ ط²ط± ط§ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظپطھط§ظˆظ‰ â•گâ•گâ•گ
        _FatwaFABButton(
          icon: Icons.search_rounded,
          tooltip: 'البحث في الفتاوى',
          color: const Color(0xFF2E7D32),
          isDark: isDark,
          onTap: () => _openScreen(context, const FatwaSearchScreen()),
        ),

        const SizedBox(height: 10),

        // â•گâ•گâ•گ ط²ط± ط§ظ„ظ…ط³ط§ط¹ط¯ ط§ظ„ط°ظƒظٹ â•گâ•گâ•گ
        _FatwaFABButton(
          icon: Icons.auto_awesome_rounded,
          tooltip: 'مساعد الفتاوى',
          color: const Color(0xFF1565C0),
          isDark: isDark,
          onTap: () => _openScreen(context, const FatwaChatScreen()),
        ),
        Gap(80),
      ],
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTabs(bool isDark) {
    return [
      HomeScreen(
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        isDarkMode: widget.isDarkMode,
        selectedColorIndex: widget.selectedColorIndex,
        appColors: widget.appColors,
        colorNames: widget.colorNames,
      ),
      KhatmaScreen(primaryColor: _primary),
      PrayerTimesScreen(
        primaryColor: _primary,
        prayerTimes: widget.prayerTimes,
        cityName: widget.cityName,
        onRefreshLocation: widget.onRefreshLocation,
        onApplyCalculationMethod: widget.onApplyCalculationMethod,
        onReminderOffsetChanged: widget.onReminderOffsetChanged,
      ),
      ChannelsScreen(primaryColor: _primary),
      _buildMoreTab(context, _primary, isDark),
    ];
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  طھط¨ظˆظٹط¨ ط§ظ„ظ…ط²ظٹط¯ â€” ظ…طھط±ط¬ظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildMoreTab(BuildContext context, Color primary, bool isDark) {
    final tr = context.tr;
    final textColor = isDark ? Colors.white : const Color(0xFF221B16);

    final items = [
      {
        'title': tr.moreQuran,
        'icon': Icons.menu_book_rounded,
        'screen': const QuranScreen(),
      },
      {
        'title': tr.moreAzkar,
        'icon': Icons.auto_awesome_rounded,
        'screen': const AzkarScreen(),
      },
      {
        'title': tr.moreHasanat,
        'icon': Icons.emoji_events_rounded,
        'screen': const HasanatScreen(),
      },
      {
        'title': tr.moreSalawat,
        'icon': Icons.access_time_filled_rounded,
        'screen': SalawatReminderScreen(primaryColor: primary),
      },
      {
        'title': tr.moreDua,
        'icon': Icons.favorite_rounded,
        'screen': const DuaScreen(),
      },
      {
        'title': tr.moreKhatma,
        'icon': Icons.track_changes,
        'screen': KhatmaScreen(primaryColor: primary),
      },
      {
        'title': tr.moreQibla,
        'icon': Icons.location_on_rounded,
        'screen': const QiblaSplashScreen(),
      },
      {
        'title': tr.moreHadith,
        'icon': Icons.format_quote_rounded,
        'screen': HadithScreen(primaryColor: primary),
      },
      {
        'title': tr.moreHijri,
        'icon': Icons.calendar_month_rounded,
        'screen': HijriCalendarScreen(primaryColor: primary),
      },
      {
        'title': tr.moreAsmaAllah,
        'icon': Icons.numbers_rounded,
        'screen': AsmaAllahScreen(primaryColor: primary),
      },
      {
        'title': tr.moreSettings,
        'icon': Icons.settings_rounded,
        'screen': SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onColorChanged: widget.onColorChanged,
          isDarkMode: widget.isDarkMode,
          selectedColorIndex: widget.selectedColorIndex,
          appColors: widget.appColors,
          colorNames: widget.colorNames,
          primaryColor: primary,
        ),
      },
      {
        'title': tr.moreBooks,
        'icon': Icons.local_library_rounded,
        'screen': BooksScreen(primaryColor: primary),
      },
      {
        'title': tr.moreMiracles,
        'icon': Icons.grade,
        'screen': MiraclesScreen(primaryColor: primary),
      },
      {
        'title': tr.moreProphetSunnah,
        'icon': Icons.data_exploration,
        'screen': ProphetSunnahScreen(),
      },
      {
        'title': tr.moreInheritance,
        'icon': Icons.calculate_rounded,
        'screen': InheritanceScreen(
          selectedColorIndex: widget.selectedColorIndex,
          appColors: widget.appColors,
          isDarkMode: widget.isDarkMode,
        ),
      },
      {
        'title': tr.moreChannels,
        'icon': Icons.live_tv,
        'screen': ChannelsScreen(primaryColor: primary),
      },
      {
        'title': tr.moreGreatMuslims,
        'icon': Icons.person_4,
        'screen': GreatMuslimsScreen(primaryColor: primary),
      },
      {
        'title': tr.moreSunnahTracker,
        'icon': Icons.handyman_rounded,
        'screen': SunnahTrackerScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: () {},
        ),
      },
      {
        'title': tr.moreradio,
        'icon': Icons.radio,
        'screen': RadioScreen(primaryColor: primary),
      },
    ];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final small = width < 360;
          const outerHorizontalPadding = 16.0;
          const itemHorizontalPadding = 6.0;
          final contentWidth = width - (outerHorizontalPadding * 2);
          final maxThreeItemCircle =
              ((contentWidth - (itemHorizontalPadding * 2 * 3)) / 3 - 10)
                  .clamp(60.0, 92.0)
                  .toDouble();
          final smallCircle =
              math.min(small ? 76.0 : 92.0, maxThreeItemCircle).toDouble();
          final largeCircle =
              math.min(small ? 94.0 : 112.0, contentWidth - 10).toDouble();

          Color iconColorFor(IconData icon) {
            if (icon == Icons.menu_book_rounded) return const Color(0xFF244C3C);
            if (icon == Icons.auto_awesome_rounded)
              return const Color(0xFF9A7A35);
            if (icon == Icons.emoji_events_rounded)
              return const Color(0xFF98723C);
            if (icon == Icons.access_time_filled_rounded)
              return const Color(0xFF536843);
            if (icon == Icons.favorite_rounded) return const Color(0xFFB18B70);
            if (icon == Icons.location_on_rounded)
              return const Color(0xFF1D6554);
            if (icon == Icons.grade) return const Color(0xFF8B7040);
            return isDark ? const Color(0xFFE1D4AD) : const Color(0xFF5E573D);
          }

          Widget buildSymbol(IconData icon, Color color, double size) {
            if (icon == Icons.menu_book_rounded) {
              return Container(
                width: size * 0.42,
                height: size * 0.52,
                decoration: BoxDecoration(
                  color: const Color(0xFF254A39),
                  borderRadius: BorderRadius.circular(size * 0.035),
                  border: Border.all(color: _gold, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: _gold,
                  size: size * 0.25,
                ),
              );
            }

            if (icon == Icons.location_on_rounded) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.explore_rounded, color: _gold, size: size * 0.48),
                  Icon(
                    Icons.location_on_rounded,
                    color: color,
                    size: size * 0.27,
                  ),
                ],
              );
            }

            if (icon == Icons.auto_awesome_rounded) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: color, size: size * 0.36),
                  Positioned(
                    top: size * 0.12,
                    right: size * 0.13,
                    child: Icon(
                      Icons.star_rounded,
                      color: _gold,
                      size: size * 0.14,
                    ),
                  ),
                  Positioned(
                    bottom: size * 0.14,
                    left: size * 0.14,
                    child: Icon(
                      Icons.star_rounded,
                      color: _gold,
                      size: size * 0.11,
                    ),
                  ),
                ],
              );
            }

            if (icon == Icons.grade) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.star_rounded, color: _gold, size: size * 0.48),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFF4E6549),
                    size: size * 0.22,
                  ),
                ],
              );
            }

            return Icon(icon, color: color, size: size * 0.39);
          }

          Widget buildCircleItem(
            Map<String, dynamic> item, {
            required double size,
          }) {
            final icon = item['icon'] as IconData;
            final iconColor = iconColorFor(icon);
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: size + 10,
                maxWidth: size + 22,
              ),
              child: GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();

                  final screen = item['screen'];
                  if (screen is ChannelsScreen) {
                    unawaited(() async {
                      await ChannelsPrefetchService.warmupBeforeOpen();
                      if (!mounted) return;
                      await _precacheChannelsFeedImages();
                    }());
                  }

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 300,
                      ),
                      pageBuilder:
                          (_, animation, __) => item['screen'] as Widget,
                      transitionsBuilder: (_, animation, __, child) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.03),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.28, -0.34),
                          radius: 0.95,
                          colors:
                              isDark
                                  ? [
                                    const Color(0xFF34413A),
                                    const Color(0xFF17221D),
                                  ]
                                  : [
                                    const Color(0xFFFFFEFA),
                                    const Color(0xFFE9DFC9),
                                  ],
                        ),
                        border: Border.all(
                          color: _gold.withValues(alpha: isDark ? 0.75 : 0.68),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.16,
                            ),
                            blurRadius: 13,
                            offset: const Offset(0, 7),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(
                              alpha: isDark ? 0.04 : 0.82,
                            ),
                            blurRadius: 4,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: size * 0.12,
                            left: size * 0.18,
                            right: size * 0.18,
                            child: Container(
                              height: size * 0.12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size),
                                color: Colors.white.withValues(
                                  alpha: isDark ? 0.06 : 0.55,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size * 0.68,
                            height: size * 0.68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDark
                                      ? Colors.black.withValues(alpha: 0.10)
                                      : Colors.white.withValues(alpha: 0.24),
                              border: Border.all(
                                color: _gold.withValues(
                                  alpha: isDark ? 0.18 : 0.24,
                                ),
                              ),
                            ),
                            child: Center(
                              child: buildSymbol(icon, iconColor, size),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: size + 16,
                      child: Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: small ? 11.5 : 13,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget buildRow(List<Widget> children) => Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 14,
            children: children,
          );

          return Stack(
            children: [
              Positioned.fill(
                child: _buildMoreSoftBackground(_primary, isDark),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  children: [
                    // â•گâ•گâ•گ ط§ظ„ظ‡ظٹط¯ط± â•گâ•گâ•گ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Consumer<ProfileImageProvider>(
                            builder: (context, imgProvider, _) {
                              final path = imgProvider.imagePath;
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (_, anim, __) => ProfileScreen(
                                            isDarkMode: isDark,
                                            onThemeChanged:
                                                widget.onThemeChanged,
                                          ),
                                      transitionsBuilder:
                                          (_, anim, __, child) =>
                                              FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              ),
                                      transitionDuration: const Duration(
                                        milliseconds: 350,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFFC8A44D,
                                      ).withValues(alpha: 0.76),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.16,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFFC8A44D,
                                        ).withValues(alpha: 0.18),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child:
                                        path != null && File(path).existsSync()
                                            ? Image.file(
                                              File(path),
                                              fit: BoxFit.cover,
                                              key: ValueKey(path),
                                            )
                                            : Container(
                                              color:
                                                  isDark
                                                      ? Colors.white.withValues(
                                                        alpha: 0.08,
                                                      )
                                                      : _primary.withValues(
                                                        alpha: 0.08,
                                                      ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                size: 30,
                                                color:
                                                    isDark
                                                        ? Colors.white70
                                                        : _primary,
                                              ),
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          Text(
                            tr.more, // â†گ ظ…طھط±ط¬ظ…
                            style: GoogleFonts.cairo(
                              fontSize: small ? 32 : 38,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // â•گâ•گâ•گ ط§ظ„ط´ط¨ظƒط© â•گâ•گâ•گ
                    buildRow([buildCircleItem(items[12], size: largeCircle)]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[0], size: smallCircle),
                      buildCircleItem(items[1], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[2], size: smallCircle),
                      buildCircleItem(items[3], size: largeCircle),
                      buildCircleItem(items[4], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[13], size: smallCircle),
                      buildCircleItem(items[6], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([buildCircleItem(items[14], size: largeCircle)]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[7], size: smallCircle),
                      buildCircleItem(items[8], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[9], size: smallCircle),
                      buildCircleItem(items[10], size: largeCircle),
                      buildCircleItem(items[11], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([
                      buildCircleItem(items[17], size: smallCircle),
                      buildCircleItem(items[16], size: smallCircle),
                    ]),
                    const SizedBox(height: 15),
                    buildRow([buildCircleItem(items[18], size: largeCircle)]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoreSoftBackground(Color primary, bool isDark) {
    final patternColor =
        isDark
            ? const Color(0xFFE7D8B4).withValues(alpha: 0.07)
            : const Color(0xFF9D8661).withValues(alpha: 0.20);
    final moonColor =
        isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFE5D8B7).withValues(alpha: 0.78);
    final starColor =
        isDark
            ? const Color(0xFFE6D6A8).withValues(alpha: 0.20)
            : const Color(0xFFAC936A).withValues(alpha: 0.55);
    final bgColor = isDark ? const Color(0xFF101914) : const Color(0xFFF8F1E1);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: bgColor)),
          Positioned.fill(
            child: CustomPaint(painter: _MorePatternPainter(patternColor)),
          ),
          Positioned(
            top: 78,
            left: 22,
            child: SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: moonColor,
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: isDark ? 0.04 : 0.13),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 5,
                    child: Container(
                      width: 84,
                      height: 84,
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
          Positioned(
            top: 92,
            left: 134,
            child: Icon(Icons.star_rounded, size: 14, color: starColor),
          ),
          Positioned(
            top: 124,
            left: 154,
            child: Icon(
              Icons.star_rounded,
              size: 9,
              color: starColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  Glass Floating NavBar â€” ظ…طھط±ط¬ظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _GlassNavBar extends StatefulWidget {
  final int currentIndex;
  final bool isDark;
  final Color primary;
  final Color bg;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.primary,
    required this.bg,
    required this.onTap,
  });

  @override
  State<_GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<_GlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;

  // â•گâ•گâ•گ ط§ظ„ط£ظٹظ‚ظˆظ†ط§طھ ط«ط§ط¨طھط©طŒ ط§ظ„ظ†طµظˆطµ طھط£طھظٹ ظ…ظ† ط§ظ„طھط±ط¬ظ…ط© â•گâ•گâ•گ
  static const _tabIcons = [
    _TabIcons(Icons.home_outlined, Icons.home_rounded),
    _TabIcons(Icons.track_changes_outlined, Icons.track_changes),
    _TabIcons(Icons.mosque_outlined, Icons.mosque_rounded),
    _TabIcons(Icons.live_tv, Icons.live_tv_rounded),
    _TabIcons(Icons.grid_view_outlined, Icons.grid_view_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final bottomSafe = mq.padding.bottom;
    final compact = w < 360;

    final barH = compact ? 64.0 : 70.0;
    final margin = compact ? 20.0 : 25.0;
    final bottomPad = bottomSafe > 0 ? bottomSafe + 4 : 16.0;
    final radius = compact ? 24.0 : 28.0;

    // â•گâ•گâ•گ ط§ظ„ظ†طµظˆطµ ط§ظ„ظ…طھط±ط¬ظ…ط© â•گâ•گâ•گ
    final tabLabels = [
      tr.navHome,
      tr.navKhatma,
      tr.navPrayer,
      tr.navLibrary,
      tr.navMore,
    ];

    return AnimatedBuilder(
      animation: _enterCtrl,
      builder: (context, child) {
        final t =
            CurvedAnimation(
              parent: _enterCtrl,
              curve: Curves.easeOutCubic,
            ).value;
        return Transform.translate(
          offset: Offset(0, barH * (1 - t)),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: margin,
              right: margin,
              bottom: bottomPad,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: barH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color:
                        widget.isDark
                            ? const Color(0xFF1C2520).withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: widget.isDark ? 0.3 : 0.06,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_tabIcons.length, (i) {
                      return Expanded(
                        child: _GlassTab(
                          tab: _Tab(
                            _tabIcons[i].icon,
                            _tabIcons[i].activeIcon,
                            tabLabels[i],
                          ),
                          isActive: widget.currentIndex == i,
                          isDark: widget.isDark,
                          primary: widget.primary,
                          compact: compact,
                          onTap: () => widget.onTap(i),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گ ط£ظٹظ‚ظˆظ†ط§طھ ط§ظ„طھط¨ظˆظٹط¨ (ط¨ط¯ظˆظ† ظ†طµ) â•گâ•گâ•گ
class _TabIcons {
  final IconData icon;
  final IconData activeIcon;
  const _TabIcons(this.icon, this.activeIcon);
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ط¹ظ†طµط± ط§ظ„طھط¨ظˆظٹط¨ (ط¨ط¯ظˆظ† طھط؛ظٹظٹط± â€” ظٹط£ط®ط° label ظ…ظ† _Tab)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _GlassTab extends StatefulWidget {
  final _Tab tab;
  final bool isActive;
  final bool isDark;
  final Color primary;
  final bool compact;
  final VoidCallback onTap;

  const _GlassTab({
    required this.tab,
    required this.isActive,
    required this.isDark,
    required this.primary,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_GlassTab> createState() => _GlassTabState();
}

class _GlassTabState extends State<_GlassTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconScale;
  late Animation<double> _iconLift;
  late Animation<double> _labelOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _iconLift = Tween<double>(
      begin: 0,
      end: -3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _labelOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isActive) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_GlassTab old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive)
      _ctrl.forward(from: 0);
    else if (!widget.isActive && old.isActive)
      _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final primary = widget.primary;
    final isDark = widget.isDark;
    final compact = widget.compact;

    final iconSz = compact ? 22.0 : 24.0;
    final labelSz = compact ? 9.0 : 10.0;

    final activeClr = primary;
    final inactiveClr =
        isDark ? const Color(0xFF7A8A82) : const Color(0xFF8E9E96);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, active ? _iconLift.value : 0),
                child: Transform.scale(
                  scale: active ? _iconScale.value : 1.0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder:
                        (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.6, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                    child: Icon(
                      active ? widget.tab.activeIcon : widget.tab.icon,
                      key: ValueKey('${widget.tab.label}_$active'),
                      size: iconSz,
                      color: active ? activeClr : inactiveClr,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 3 : 4),
              Opacity(
                opacity: active ? _labelOpacity.value : 0.6,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.tab.label,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      fontSize: labelSz,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? activeClr : inactiveClr,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 2 : 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: active ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: activeClr,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â•گâ•گâ•گ ط¨ظٹط§ظ†ط§طھ ط§ظ„طھط¨ظˆظٹط¨ â•گâ•گâ•گ
class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab(this.icon, this.activeIcon, this.label);
}

// â•گâ•گâ•گ LazyIndexedStack (ط¨ط¯ظˆظ† طھط؛ظٹظٹط±) â•گâ•گâ•گ
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final Set<int> visitedTabs;
  final List<Widget> children;
  final Color backgroundColor;

  const _LazyIndexedStack({
    required this.index,
    required this.visitedTabs,
    required this.children,
    required this.backgroundColor,
  });

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final Set<int> _built;

  @override
  void initState() {
    super.initState();
    _built = {0};
  }

  @override
  void didUpdateWidget(_LazyIndexedStack old) {
    super.didUpdateWidget(old);
    if (widget.index != old.index && !_built.contains(widget.index)) {
      setState(() => _built.add(widget.index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        if (!_built.contains(i)) {
          return ColoredBox(
            color: widget.backgroundColor,
            child: const SizedBox.expand(),
          );
        }
        return widget.children[i];
      }),
    );
  }
}

// â•گâ•گâ•گ Pattern Painter (ط¨ط¯ظˆظ† طھط؛ظٹظٹط±) â•گâ•گâ•گ
class _MorePatternPainter extends CustomPainter {
  final Color color;
  const _MorePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const step = 92.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;
        final tile = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, y + 5, step - 10, step - 10),
          const Radius.circular(18),
        );
        canvas.drawRRect(tile, paint);

        final path =
            Path()
              ..moveTo(cx, y + 8)
              ..lineTo(cx + step * 0.18, cy - step * 0.18)
              ..lineTo(x + step - 8, cy)
              ..lineTo(cx + step * 0.18, cy + step * 0.18)
              ..lineTo(cx, y + step - 8)
              ..lineTo(cx - step * 0.18, cy + step * 0.18)
              ..lineTo(x + 8, cy)
              ..lineTo(cx - step * 0.18, cy - step * 0.18)
              ..close();
        canvas.drawPath(path, paint);

        canvas.drawCircle(Offset(cx, cy), step * 0.12, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MorePatternPainter old) => old.color != color;
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط²ط± ط§ظ„ظپطھط§ظˆظ‰ ط§ظ„ط¹ط§ط¦ظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _FatwaFABButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FatwaFABButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_FatwaFABButton> createState() => _FatwaFABButtonState();
}

class _FatwaFABButtonState extends State<_FatwaFABButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder:
              (context, child) =>
                  Transform.scale(scale: _scale.value, child: child),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
