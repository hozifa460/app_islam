import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/books_screen.dart';
import 'package:islamic_app/screens/channels_screen.dart';
import 'package:islamic_app/screens/hadith/hadith_screen.dart';
import 'package:islamic_app/screens/hasanat_screen.dart';
import 'package:islamic_app/screens/home/screen/HomeScreen.dart';
import 'package:islamic_app/screens/khatma_screen.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_time_screen.dart';
import 'package:islamic_app/screens/qibla_screen.dart';
import 'package:islamic_app/screens/quran/quran_screen.dart';
import 'package:islamic_app/screens/settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(int) onColorChanged;
  final bool isDarkMode;
  final int selectedColorIndex;
  final List<Color> appColors;
  final List<String> colorNames;

  const MainShellScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.selectedColorIndex,
    required this.appColors,
    required this.colorNames,
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
       QuranScreen(),
       PrayerTimesScreen(primaryColor: deepGreen,),
       BooksScreen(primaryColor: deepGreen,),
      _buildMoreTab(context, deepGreen, isDark),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: tabs,
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
                colors: isDark
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
                color: isDark
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
                  icon: Icons.menu_book_rounded,
                  label: 'القرآن',
                  index: 1,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'الأذكار',
                  index: 2,
                  activeColor: deepGreen,
                  gold: gold,
                ),
                _floatingNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'الأدعية',
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
          padding: EdgeInsets.symmetric(
            vertical: small ? 7 : 8,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: active
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
    final items = [
      {
        'title': 'مواقيت الصلاة',
        'subtitle': ' مواقيت دقيقة',
        'icon': Icons.access_time_filled_rounded,
        'screen': PrayerTimesScreen(primaryColor: primary),
      },
      {
        'title': 'الأحاديث',
        'subtitle': 'مكتبة السنة',
        'icon': Icons.format_quote_rounded,
        'screen': HadithScreen(primaryColor: primary),
      },
      {
        'title': 'القبلة',
        'subtitle': 'اتجاه القبلة',
        'icon': Icons.explore_rounded,
        'screen':  QiblaScreen(),
      },
      {
        'title': 'حصاد الحسنات',
        'subtitle': 'أجور عظيمة',
        'icon': Icons.emoji_events_rounded,
        'screen':  HasanatScreen(),
      },
      {
        'title': 'ختمتي',
        'subtitle': 'وردك اليومي',
        'icon': Icons.track_changes,
        'screen': KhatmaScreen(primaryColor: primary),
      },
      {
        'title': 'البث المباشر',
        'subtitle': 'قنوات المشايخ',
        'icon': Icons.live_tv_rounded,
        'screen': ChannelsScreen(primaryColor: primary),
      },
      {
        'title': 'المكتبة',
        'subtitle': 'كتب إسلامية',
        'icon': Icons.local_library_rounded,
        'screen': BooksScreen(primaryColor: primary),
      },
      {
        'title': 'المؤذن',
        'subtitle': 'اختيار الصوت',
        'icon': Icons.volume_up_rounded,
        'screen': MuezzinSettingsScreen(primaryColor: primary),
      },
      {
        'title': 'الإعدادات',
        'subtitle': 'تخصيص التطبيق',
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
    ];

    return SafeArea(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13211D) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.12 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              minLeadingWidth: 20,
              leading: Icon(item['icon'] as IconData, color: primary),
              title: Text(
                item['title'] as String,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => item['screen'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}