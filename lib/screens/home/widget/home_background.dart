import 'dart:math';
import 'package:flutter/material.dart';

class HomeBackground extends StatefulWidget {
  final Color primary;
  final Color gold;
  final double scrollOffset;
  final bool isDark;

  const HomeBackground({
    super.key,
    required this.primary,
    required this.gold,
    required this.scrollOffset,
    required this.isDark,
  });

  @override
  State<HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<HomeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  late List<_BgStar> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final rng = Random(12);
    _stars = List.generate(12, (i) => _BgStar(
      x: rng.nextDouble(),
      y: rng.nextDouble() * 0.40,
      size: 1.0 + rng.nextDouble() * 2.0,
      phase: rng.nextDouble() * 2 * pi,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollShift = widget.scrollOffset * 0.04;
    final fadeOpacity =
    (1.0 - widget.scrollOffset / 700.0).clamp(0.0, 1.0);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          return Stack(
            children: [
              // ══════════════════════════════════════
              // 1. الخلفية الأساسية
              // ══════════════════════════════════════
              Positioned.fill(
                child: _buildBase(),
              ),

              // ══════════════════════════════════════
              // 2. عناصر زخرفية خفيفة جداً
              // ══════════════════════════════════════
              Opacity(
                opacity: fadeOpacity,
                child: Stack(
                  children: [
                    // الهلال - أعلى اليسار
                    Positioned(
                      top: -20 + scrollShift,
                      left: -30,
                      child: _buildCrescent(),
                    ),

                    // دائرة ضوئية - أعلى اليمين
                    Positioned(
                      top: -30 + scrollShift,
                      right: -50,
                      child: _buildGlowCircle(
                        size: 180,
                        color: widget.primary,
                        opacity: widget.isDark ? 0.06 : 0.04,
                      ),
                    ),

                    // دائرة ضوئية - المنتصف اليسار
                    Positioned(
                      top: 300 + scrollShift * 0.5,
                      left: -60,
                      child: _buildGlowCircle(
                        size: 160,
                        color: widget.gold,
                        opacity: widget.isDark ? 0.05 : 0.03,
                      ),
                    ),

                    // دائرة ضوئية - الأسفل اليمين
                    Positioned(
                      bottom: 200,
                      right: -40,
                      child: _buildGlowCircle(
                        size: 140,
                        color: widget.primary,
                        opacity: widget.isDark ? 0.04 : 0.03,
                      ),
                    ),

                    // نجوم صغيرة - Dark فقط
                    if (widget.isDark)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _StarsPainter(
                            stars: _stars,
                            twinkle: _anim.value,
                            color: widget.gold,
                            scrollShift: scrollShift,
                          ),
                        ),
                      ),

                    // نجيمات أيقونة - خفيفة جداً
                    ..._buildIconStars(scrollShift, fadeOpacity),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════
  // الخلفية الأساسية
  // ══════════════════════════════════════

  Widget _buildBase() {
    if (widget.isDark) {
      // Dark: تدرج من أخضر غامق جداً في الأعلى
      // إلى أخضر غامق أكثر في الأسفل
      // ← هذا يجعل البطاقات الخضراء الغامقة تندمج بسلاسة
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
            colors: [
              const Color(0xFF0A1210), // أخضر غامق جداً في الأعلى
              const Color(0xFF0E1714), // اللون الأساسي للخلفية
              const Color(0xFF0B1411), // أغمق قليلاً في الأسفل
            ],
          ),
        ),
      );
    } else {
      // Light: أبيض نقي في الأعلى ← يتوافق مع البطاقات البيضاء
      // تدرج خفيف جداً نحو الكريمي في الأسفل
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 1.0],
            colors: [
              const Color(0xFFFAF8F4), // شبه أبيض في الأعلى
              const Color(0xFFF5F1E8), // كريمي خفيف في المنتصف
              const Color(0xFFF0EBE0), // كريمي في الأسفل
            ],
          ),
        ),
      );
    }
  }

  // ══════════════════════════════════════
  // الهلال
  // ══════════════════════════════════════

  Widget _buildCrescent() {
    // الهلال بسيط وخفيف جداً لا يزعج العين
    const outerSize = 150.0;
    const innerSize = 122.0;
    const innerLeft = 34.0;
    const innerTop = 10.0;

    final outerOpacity = widget.isDark ? 0.08 : 0.05;

    // لون الهلال يتوافق مع الخلفية لإخفاء الجزء الداخلي
    final innerColor = widget.isDark
        ? const Color(0xFF0A1210)
        : const Color(0xFFFAF8F4);

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        children: [
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.gold.withOpacity(outerOpacity),
            ),
          ),
          Positioned(
            left: innerLeft,
            top: innerTop,
            child: Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: innerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // دائرة ضوئية
  // ══════════════════════════════════════

  Widget _buildGlowCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    // نبض خفيف جداً
    final pulsedOpacity =
        opacity * (0.7 + 0.3 * sin(_anim.value * pi));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(pulsedOpacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // نجيمات أيقونة
  // ══════════════════════════════════════

  List<Widget> _buildIconStars(
      double scrollShift, double fadeOpacity) {
    // opacity خفيفة جداً في كلا الوضعين
    final baseOpacity = widget.isDark ? 0.10 : 0.06;

    // تلألؤ بطيء
    final twinkled =
        baseOpacity * (0.5 + 0.5 * sin(_anim.value * pi));

    final stars = [
      _IconStar(top: 100 + scrollShift, left: 100,
          size: 9, isSparkle: false),
      _IconStar(top: 155 + scrollShift, right: 50,
          size: 7, isSparkle: true),
      _IconStar(top: 280 + scrollShift, left: 25,
          size: 11, isSparkle: true),
      _IconStar(top: 410 + scrollShift, right: 28,
          size: 8, isSparkle: false),
      _IconStar(bottom: 270, left: 35,
          size: 10, isSparkle: true),
      _IconStar(bottom: 140, right: 20,
          size: 9, isSparkle: false),
    ];

    return stars.map((s) {
      return Positioned(
        top: s.top,
        bottom: s.bottom,
        left: s.left,
        right: s.right,
        child: Icon(
          s.isSparkle
              ? Icons.auto_awesome_rounded
              : Icons.star_rounded,
          size: s.size,
          color: widget.gold.withOpacity(twinkled),
        ),
      );
    }).toList();
  }
}

// ══════════════════════════════════════
// بيانات مساعدة
// ══════════════════════════════════════

class _BgStar {
  final double x, y, size, phase;
  _BgStar({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });
}

class _IconStar {
  final double? top, bottom, left, right, size;
  final bool isSparkle;
  _IconStar({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.isSparkle,
  });
}

// ══════════════════════════════════════
// رسام النجوم (Dark فقط)
// ══════════════════════════════════════

class _StarsPainter extends CustomPainter {
  final List<_BgStar> stars;
  final double twinkle;
  final Color color;
  final double scrollShift;

  _StarsPainter({
    required this.stars,
    required this.twinkle,
    required this.color,
    required this.scrollShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final dy = (s.y * size.height * 0.5) - scrollShift;
      if (dy < 0 || dy > size.height) continue;

      final opacity =
      (0.04 + 0.06 * sin(s.phase + twinkle * pi * 2))
          .clamp(0.0, 0.12);

      canvas.drawCircle(
        Offset(s.x * size.width, dy),
        s.size,
        Paint()
          ..color = color.withOpacity(opacity)
          ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, s.size * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.twinkle != twinkle || old.scrollShift != scrollShift;
}