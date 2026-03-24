import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/AsmaAllah/asma_allah_screen.dart';
import 'package:islamic_app/screens/Azkar/azkar_screen.dart';
import 'package:islamic_app/screens/books/books_screen.dart';
import 'package:islamic_app/screens/channels_screen.dart';
import 'package:islamic_app/screens/dua_screen.dart';
import 'package:islamic_app/screens/hadith/hadith_screen.dart';
import 'package:islamic_app/screens/hasanat_screen.dart';
import 'package:islamic_app/screens/hijri_calendar_screen.dart';
import 'package:islamic_app/screens/home/screen/HomeScreen.dart';
import 'package:islamic_app/screens/khatma_screen.dart';
import 'package:islamic_app/screens/mircle/miracles_screen.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_time_screen.dart';
import 'package:islamic_app/screens/qibla_screen.dart';
import 'package:islamic_app/screens/quran/quran_screen.dart';
import 'package:islamic_app/screens/settings_screen.dart';
import 'package:islamic_app/screens/tasbih_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);
    const gold = Color(0xFFC8A44D);
    const deepGreen = Color(0xFF123C33);

    final tabs = [
      HomeScreen(
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        isDarkMode: widget.isDarkMode,
        selectedColorIndex: widget.selectedColorIndex,
        appColors: widget.appColors,
        colorNames: widget.colorNames,
      ),
      KhatmaScreen(primaryColor: deepGreen),
      PrayerTimesScreen(
        primaryColor: deepGreen,
        prayerTimes: widget.prayerTimes,
        cityName: widget.cityName,
        onRefreshLocation: widget.onRefreshLocation,
        onApplyCalculationMethod: widget.onApplyCalculationMethod,
        onReminderOffsetChanged: widget.onReminderOffsetChanged,
      ),
      BooksScreen(primaryColor: deepGreen),
      _buildMoreTab(context, deepGreen, isDark),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 76,
              ),
              child: IndexedStack(index: _currentIndex, children: tabs),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildFloatingBottomNav(
                key: ValueKey(_currentIndex),
                deepGreen: deepGreen,
                gold: gold,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav({
    Key? key,
    required Color deepGreen,
    required Color gold,
    required bool isDark,
  }) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final bottomInset = media.padding.bottom;

    final horizontalPadding = width < 360 ? 8.0 : 10.0;
    final verticalPadding = width < 360 ? 8.0 : 10.0;
    final radius = width < 360 ? 24.0 : 28.0;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            key: key,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding + (bottomInset > 0 ? 0 : 2),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDark
                        ? [
                          Colors.white.withOpacity(0.08),
                          const Color(0xCC13211D),
                        ]
                        : [
                          Colors.white.withOpacity(0.92),
                          Colors.white.withOpacity(0.78),
                        ],
              ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.26 : 0.10),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.02 : 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                _floatingNavItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  index: 0,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.track_changes,
                  label: 'الختمة',
                  index: 1,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.access_time_filled_rounded,
                  label: 'الصلاة',
                  index: 2,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.local_library_outlined,
                  label: 'المكتبة',
                  index: 3,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.widgets_rounded,
                  label: 'المزيد',
                  index: 4,
                  activeColor: deepGreen,
                  gold: gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatingNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color gold,
  }) {
    final active = _currentIndex == index;
    final width = MediaQuery.of(context).size.width;
    final small = width < 360;

    final iconSize = small ? 20.0 : 23.0;
    final textSize = small ? 9.5 : 10.5;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (_currentIndex == index) return;
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: small ? 7 : 8, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow:
                active
                    ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.10 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  color: active ? activeColor : Colors.grey,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: textSize,
                    fontWeight: active ? FontWeight.bold : FontWeight.w600,
                    color: active ? activeColor : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreTab(BuildContext context, Color primary, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    final items = [
      {
        'title': 'القرآن الكريم',
        'icon': Icons.menu_book_rounded,
        'screen': const QuranScreen(),
      },
      {
        'title': 'أذكار المسلم',
        'icon': Icons.auto_awesome_rounded,
        'screen': const AzkarScreen(),
      },
      {
        'title': 'حصاد الحسنات',
        'icon': Icons.emoji_events_rounded,
        'screen': const HasanatScreen(),
      },
      {
        'title': 'مواقيت الصلاة',
        'icon': Icons.access_time_filled_rounded,
        'screen': PrayerTimesScreen(primaryColor: primary),
      },
      {
        'title': 'الأدعية',
        'icon': Icons.favorite_rounded,
        'screen': const DuaScreen(),
      },
      {
        'title': 'الختمة',
        'icon': Icons.track_changes,
        'screen': KhatmaScreen(primaryColor: primary),
      },
      {
        'title': 'القبلة',
        'icon': Icons.location_on_rounded,
        'screen': const QiblaScreen(),
      },
      {
        'title': 'الاحاديث',
        'icon': Icons.format_quote_rounded,
        'screen': HadithScreen(primaryColor: primary),
      },
      {
        'title': 'التقويم الهجري',
        'icon': Icons.calendar_month_rounded,
        'screen': HijriCalendarScreen(primaryColor: primary),
      },
      {
        'title': 'أسماء الله الحسنى',
        'icon': Icons.numbers_rounded,
        'screen': AsmaAllahScreen(primaryColor: primary),
      },
      {
        'title': 'الاعدادات',
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
        'title': 'المكتبة',
        'icon': Icons.local_library_rounded,
        'screen': BooksScreen(primaryColor: primary),
      },
      {
        'title': 'المعجزات',
        'icon': Icons.grade,
        'screen': MiraclesScreen(primaryColor: primary,),
      },
      {
        'title': 'المؤذن',
        'icon': Icons.volume_up_rounded,
        'screen': MuezzinSettingsScreen(primaryColor: primary),
      },
    ];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final small = width < 360;

          final largeCircle = small ? 82.0 : 98.0;
          final smallCircle = small ? 68.0 : 84.0;

          Widget buildCircleItem(
            Map<String, dynamic> item, {
            required double size,
          }) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: size + 12,
                maxWidth: size + 26,
              ),
              child: GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 350,
                      ),
                      pageBuilder: (_, animation, secondaryAnimation) {
                        return item['screen'] as Widget;
                      },
                      transitionsBuilder: (
                        _,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );

                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
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
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.white,
                        border: Border.all(
                          color: const Color(0xFFC8A44D),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC8A44D).withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: primary,
                        size: size * 0.40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: size + 16,
                      child: Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: small ? 10.8 : 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget buildRow(List<Widget> children) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  children
                      .map(
                        (child) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: child,
                        ),
                      )
                      .toList(),
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: _buildMoreSoftBackground(primary, isDark)),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 120),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          'المزيد',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    buildRow([
                      buildCircleItem(items[0], size: smallCircle),
                      buildCircleItem(items[1], size: smallCircle),
                    ]),

                    const SizedBox(height: 18),

                    buildRow([
                      buildCircleItem(items[2], size: smallCircle),
                      buildCircleItem(items[3], size: largeCircle),
                      buildCircleItem(items[4], size: smallCircle),
                    ]),

                    const SizedBox(height: 18),

                    buildRow([
                      buildCircleItem(items[5], size: smallCircle),
                      buildCircleItem(items[6], size: smallCircle),
                    ]),

                    const SizedBox(height: 18),

                    buildRow([
                      buildCircleItem(items[7], size: smallCircle),
                      buildCircleItem(items[8], size: smallCircle),
                    ]),

                    const SizedBox(height: 18),

                    buildRow([
                      buildCircleItem(items[9], size: smallCircle),
                      buildCircleItem(items[10], size: largeCircle),
                      buildCircleItem(items[11], size: smallCircle),
                    ]),

                    const SizedBox(height: 18),

                    buildRow([
                      buildCircleItem(items[12], size: smallCircle),
                      buildCircleItem(items[13], size: smallCircle),
                    ]),
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
    final patternColor = isDark
        ? Colors.white.withOpacity(0.035)
        : primary.withOpacity(0.045);

    final moonColor = isDark
        ? Colors.white.withOpacity(0.04)
        : const Color(0xFFC8A44D).withOpacity(0.10);

    final starColor = isDark
        ? Colors.white.withOpacity(0.10)
        : const Color(0xFFC8A44D).withOpacity(0.18);

    final bgColor = isDark
        ? const Color(0xFF0E1714)
        : const Color(0xFFF7F3EA);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MorePatternPainter(patternColor),
              child: Container(),
            ),
          ),

          Positioned(
            top: 70,
            left: 18,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: moonColor,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 4,
                    child: Container(
                      width: 64,
                      height: 64,
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
            top: 84,
            left: 84,
            child: Icon(
              Icons.star_rounded,
              size: 10,
              color: starColor,
            ),
          ),
          Positioned(
            top: 108,
            left: 102,
            child: Icon(
              Icons.star_rounded,
              size: 7,
              color: starColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

}

class _MorePatternPainter extends CustomPainter {
  final Color color;

  _MorePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const step = 80.0;

    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final path = Path();
        path.moveTo(x + step / 2, y);
        path.lineTo(x + step, y + step / 4);
        path.lineTo(x + step, y + step * 0.75);
        path.lineTo(x + step / 2, y + step);
        path.lineTo(x, y + step * 0.75);
        path.lineTo(x, y + step / 4);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MorePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
