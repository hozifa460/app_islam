import 'package:flutter/material.dart';
import '../Constants/sunnah_theme.dart';

class SunnahAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final bool isDark;

  const SunnahAppBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = (screenHeight * 0.30).clamp(220.0, 300.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor:
      isDark ? const Color(0xFF0D1525) : const Color(0xFF1A2D52),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        _ThemeToggleButton(isDark: isDark),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _AppBarBackground(isDark: isDark),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _SearchBarWidget(
          controller: searchController,
          onSearch: onSearch,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ─── زر تبديل الثيم ────────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              RotationTransition(turns: anim, child: child),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          // يمكن ربطها بمزود الثيم في تطبيقك
        },
      ),
    );
  }
}

// ─── خلفية الهيدر ──────────────────────────────────────────────────────────

class _AppBarBackground extends StatefulWidget {
  final bool isDark;
  const _AppBarBackground({required this.isDark});

  @override
  State<_AppBarBackground> createState() => _AppBarBackgroundState();
}

class _AppBarBackgroundState extends State<_AppBarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isDark
              ? [const Color(0xFF1E3460), const Color(0xFF0D1525)]
              : [const Color(0xFF1A3A6B), const Color(0xFF0F2040)],
        ),
      ),
      child: Stack(
        children: [
          // نجوم متناثرة
          ..._Stars.build(size),
          // دائرة ذهبية خلفية
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SunnahTheme.gold.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SunnahTheme.gold.withOpacity(0.04),
              ),
            ),
          ),
          // المحتوى الرئيسي
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // أيقونة بها هالة
                  _GlowingIcon(),
                  const SizedBox(height: 16),
                  // العنوان
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'ماذا كان يفعل ﷺ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SunnahTheme.gold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: SunnahTheme.gold,
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // الوصف
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        'سنن نبوية موثقة من الصحاح والمسانيد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // خط ذهبي
                  _GoldenDivider(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── أيقونة متوهجة ─────────────────────────────────────────────────────────

class _GlowingIcon extends StatefulWidget {
  @override
  State<_GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<_GlowingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glow, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [SunnahTheme.goldLight, SunnahTheme.goldDark],
          ),
          boxShadow: [
            BoxShadow(
              color: SunnahTheme.gold
                  .withOpacity(0.3 + _glowAnim.value * 0.35),
              blurRadius: 16 + _glowAnim.value * 16,
              spreadRadius: 2 + _glowAnim.value * 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_stories_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}

// ─── خط ذهبي ───────────────────────────────────────────────────────────────

class _GoldenDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, SunnahTheme.gold],
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SunnahTheme.gold,
          ),
        ),
        Container(
          width: 30,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [SunnahTheme.gold, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── نجوم خلفية ────────────────────────────────────────────────────────────

class _Stars {
  static const _positions = [
    [0.05, 0.08, 2.5], [0.92, 0.12, 2.0], [0.2, 0.18, 1.5],
    [0.78, 0.22, 2.5], [0.45, 0.06, 1.8], [0.12, 0.45, 1.5],
    [0.88, 0.40, 2.0], [0.35, 0.65, 1.5], [0.65, 0.55, 2.0],
    [0.55, 0.30, 1.2], [0.25, 0.75, 1.8], [0.72, 0.70, 1.5],
  ];

  static List<Widget> build(Size size) {
    return _positions.asMap().entries.map((e) {
      final p = e.value;
      final opacity = 0.3 + (e.key % 3) * 0.15;
      return Positioned(
        left: p[0] * size.width,
        top: p[1] * size.height * 0.5,
        child: Container(
          width: p[2],
          height: p[2],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(opacity * 0.5),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ─── شريط البحث ─────────────────────────────────────────────────────────────

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool isDark;

  const _SearchBarWidget({
    required this.controller,
    required this.onSearch,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
    isDark ? const Color(0xFF0D1525) : const Color(0xFF0F2040);

    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: bgColor,
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن سنة نبوية...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: SunnahTheme.gold,
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close_rounded,
                  color: Colors.white.withOpacity(0.5), size: 18),
              onPressed: () {
                controller.clear();
                onSearch('');
              },
            )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: SunnahTheme.gold,
              width: 1.5,
            ),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          isDense: true,
        ),
      ),
    );
  }
}