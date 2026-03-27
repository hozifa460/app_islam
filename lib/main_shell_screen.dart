// main_shell_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/AsmaAllah/asma_allah_screen.dart';
import 'package:islamic_app/screens/Azkar/azkar_screen.dart';
import 'package:islamic_app/screens/GreatMuslim/great_muslims_screen.dart';
import 'package:islamic_app/screens/books/books_screen.dart';
import 'package:islamic_app/screens/channels_screen.dart';
import 'package:islamic_app/screens/dua/dua_screen.dart';
import 'package:islamic_app/screens/hadith/hadith_screen.dart';
import 'package:islamic_app/screens/hasanat_screen.dart';
import 'package:islamic_app/screens/hijri_calendar_screen.dart';
import 'package:islamic_app/screens/home/screen/HomeScreen.dart';
import 'package:islamic_app/screens/inheritance/inheritance_screen.dart';
import 'package:islamic_app/screens/khatma_screen.dart';
import 'package:islamic_app/screens/mircle/miracles_screen.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:islamic_app/screens/prayer/prayer_time_screen.dart';
import 'package:islamic_app/screens/qibla_screen.dart';
import 'package:islamic_app/screens/quran/quran_screen.dart';
import 'package:islamic_app/screens/salawat/salawat_reminder_screen.dart';
import 'package:islamic_app/screens/settings_screen.dart';
import 'package:islamic_app/screens/sunnah_tracker_screen.dart';

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

  /// اللون الرئيسي المختار - يستخدم في كل مكان
  Color get _primary => widget.appColors[widget.selectedColorIndex];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── المحتوى ──
          Positioned.fill(
            child: _LazyIndexedStack(
              index: _currentIndex,
              visitedTabs: _visitedTabs,
              backgroundColor: bg,
              children: _buildTabs(isDark),
            ),
          ),

          // ── البوتوم بار العائم ──
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

  List<Widget> _buildTabs(bool isDark) {
    return [
      // Tab 0: الرئيسية
      HomeScreen(
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        isDarkMode: widget.isDarkMode,
        selectedColorIndex: widget.selectedColorIndex,
        appColors: widget.appColors,
        colorNames: widget.colorNames,
      ),

      // Tab 1: الختمة
      KhatmaScreen(primaryColor: _primary),

      // Tab 2: الصلاة
      PrayerTimesScreen(
        primaryColor: _primary,
        prayerTimes: widget.prayerTimes,
        cityName: widget.cityName,
        onRefreshLocation: widget.onRefreshLocation,
        onApplyCalculationMethod: widget.onApplyCalculationMethod,
        onReminderOffsetChanged: widget.onReminderOffsetChanged,
      ),

      // Tab 3: المكتبة
      BooksScreen(primaryColor: _primary),

      // Tab 4: المزيد
      _buildMoreTab(context, _primary, isDark),
    ];
  }

  // ── تبويب المزيد ──
  Widget _buildMoreTab(
      BuildContext context, Color _primary, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    final items = [
      {
        'title': 'القرآن الكريم',
        'icon': Icons.menu_book_rounded,
        'screen': const QuranScreen()
      },
      {
        'title': 'أذكار المسلم',
        'icon': Icons.auto_awesome_rounded,
        'screen': const AzkarScreen()
      },
      {
        'title': 'حصاد الحسنات',
        'icon': Icons.emoji_events_rounded,
        'screen': const HasanatScreen()
      },
      {
        'title': 'صلي على النبي',
        'icon': Icons.access_time_filled_rounded,
        'screen': SalawatReminderScreen(primaryColor: _primary)
      },
      {
        'title': 'الأدعية',
        'icon': Icons.favorite_rounded,
        'screen': const DuaScreen()
      },
      {
        'title': 'الختمة',
        'icon': Icons.track_changes,
        'screen': KhatmaScreen(primaryColor: _primary)
      },
      {
        'title': 'القبلة',
        'icon': Icons.location_on_rounded,
        'screen': const QiblaScreen()
      },
      {
        'title': 'الاحاديث',
        'icon': Icons.format_quote_rounded,
        'screen': HadithScreen(primaryColor: _primary)
      },
      {
        'title': 'التقويم الهجري',
        'icon': Icons.calendar_month_rounded,
        'screen': HijriCalendarScreen(primaryColor: _primary)
      },
      {
        'title': 'أسماء الله الحسنى',
        'icon': Icons.numbers_rounded,
        'screen': AsmaAllahScreen(primaryColor: _primary)
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
          primaryColor: _primary,
        )
      },
      {
        'title': 'المكتبة',
        'icon': Icons.local_library_rounded,
        'screen': BooksScreen(primaryColor: _primary)
      },
      {
        'title': 'المعجزات',
        'icon': Icons.grade,
        'screen': MiraclesScreen(primaryColor: _primary)
      },
      {
        'title': 'المؤذن',
        'icon': Icons.volume_up_rounded,
        'screen': MuezzinSettingsScreen(primaryColor: _primary)
      },
      {
        'title': 'المواريث',
        'icon': Icons.calculate_rounded,
        'screen': InheritanceScreen(
          selectedColorIndex: widget.selectedColorIndex,
          appColors: widget.appColors,
          isDarkMode: widget.isDarkMode,
        )
      },
      {
        'title': 'شاشة البث',
        'icon': Icons.live_tv,
        'screen': ChannelsScreen(primaryColor: _primary)
      },
      {
        'title': 'العظماء',
        'icon': Icons.person_4,
        'screen': GreatMuslimsScreen(primaryColor: _primary)
      },
      {
        'title': 'سنن الرسول',
        'icon': Icons.handyman_rounded,
        'screen': SunnahTrackerScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: () {},
        )
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
                      transitionDuration:
                      const Duration(milliseconds: 400),
                      reverseTransitionDuration:
                      const Duration(milliseconds: 300),
                      pageBuilder: (_, animation, __) =>
                      item['screen'] as Widget,
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
                        color: isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.white,
                        border: Border.all(
                          // ★ حدود بلون التطبيق مع لمسة ذهبية ★
                          color: _gold,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        // ★ أيقونة بلون التطبيق ★
                        color: isDark ? Colors.white70 : _primary,
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

          Widget buildRow(List<Widget> children) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children
                .map((c) => Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 6),
              child: c,
            ))
                .toList(),
          );
          return Stack(
            children: [
              Positioned.fill(
                child:
                _buildMoreSoftBackground(_primary, isDark),
              ),
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
                    buildRow([
                      buildCircleItem(items[12], size: largeCircle)
                    ]),
                    const SizedBox(height: 18),
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
                      buildCircleItem(items[14], size: largeCircle)
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
                      buildCircleItem(items[17], size: smallCircle),
                      buildCircleItem(items[16], size: smallCircle),
                    ]),
                    const SizedBox(height: 18),
                    buildRow([
                      buildCircleItem(items[15], size: largeCircle)
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
        : _gold.withOpacity(0.10);
    final starColor = isDark
        ? Colors.white.withOpacity(0.10)
        : _gold.withOpacity(0.18);
    final bgColor =
    isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MorePatternPainter(patternColor),
            ),
          ),
          Positioned(
            top: 70,
            left: 18,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(children: [
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
              ]),
            ),
          ),
          Positioned(
            top: 84,
            left: 84,
            child: Icon(Icons.star_rounded,
                size: 10, color: starColor),
          ),
          Positioned(
            top: 108,
            left: 102,
            child: Icon(Icons.star_rounded,
                size: 7, color: starColor.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Glass Floating NavBar - iOS 17 (بدون حواف سميكة)
// ══════════════════════════════════════════════════════════════
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

  static const _icons = [
    _Tab(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
    _Tab(Icons.track_changes_outlined, Icons.track_changes, 'الختمة'),
    _Tab(Icons.mosque_outlined, Icons.mosque_rounded, 'الصلاة'),
    _Tab(Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'المكتبة'),
    _Tab(Icons.grid_view_outlined, Icons.grid_view_rounded, 'المزيد'),
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
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final bottomSafe = mq.padding.bottom;
    final compact = w < 360;

    final barH = compact ? 64.0 : 70.0;
    final margin = compact ? 20.0 : 25.0;
    final bottomPad = bottomSafe > 0 ? bottomSafe + 4 : 16.0;
    final radius = compact ? 24.0 : 28.0;

    return AnimatedBuilder(
      animation: _enterCtrl,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: _enterCtrl,
          curve: Curves.easeOutCubic,
        ).value;

        return Transform.translate(
          offset: Offset(0, barH * (1 - t)),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── البار ──
          Padding(
            padding: EdgeInsets.only(
              left: margin,
              right: margin,
              bottom: bottomPad ,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: barH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: widget.isDark
                        ? const Color(0xFF1C2520).withOpacity(0.85)
                        : Colors.white.withOpacity(0.75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            widget.isDark ? 0.3 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_icons.length, (i) {
                      return Expanded(
                        child: _GlassTab(
                          tab: _icons[i],
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

// ══════════════════════════════════════════════════════════════
//  عنصر التبويب
// ══════════════════════════════════════════════════════════════
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
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.15),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ));

    _iconLift = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

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
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.reverse();
    }
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
    final inactiveClr = isDark
        ? const Color(0xFF7A8A82)
        : const Color(0xFF8E9E96);

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
              // ── الأيقونة ──
              Transform.translate(
                offset: Offset(0, active ? _iconLift.value : 0),
                child: Transform.scale(
                  scale: active ? _iconScale.value : 1.0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, anim) => FadeTransition(
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

              // ── النص ──
              Opacity(
                opacity: active
                    ? _labelOpacity.value
                    : 0.6,
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

              // ── المؤشر ──
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

// ══════════════════════════════════════════════════════════════
//  بيانات التبويب
// ══════════════════════════════════════════════════════════════
class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab(this.icon, this.activeIcon, this.label);
}


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
          // ★ إصلاح الشاشة الحمراء ★
          // SizedBox.expand بدل SizedBox.shrink
          // + لون الخلفية لمنع الوميض
          return ColoredBox(color: widget.backgroundColor, child: const SizedBox.expand());
        }
        return widget.children[i];
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Pattern Painter
// ══════════════════════════════════════════════════════════════
class _MorePatternPainter extends CustomPainter {
  final Color color;
  const _MorePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 80.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 4)
          ..lineTo(x + step, y + step * 0.75)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step * 0.75)
          ..lineTo(x, y + step / 4)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MorePatternPainter old) => old.color != color;
}