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
              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              // 1. ط§ظ„ط®ظ„ظپظٹط© ط§ظ„ط£ط³ط§ط³ظٹط©
              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              Positioned.fill(
                child: _buildBase(),
              ),

              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              // 2. ط¹ظ†ط§طµط± ط²ط®ط±ظپظٹط© ط®ظپظٹظپط© ط¬ط¯ط§ظ‹
              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              Opacity(
                opacity: fadeOpacity,
                child: Stack(
                  children: [
                    // ط§ظ„ظ‡ظ„ط§ظ„ - ط£ط¹ظ„ظ‰ ط§ظ„ظٹط³ط§ط±
                    Positioned(
                      top: -20 + scrollShift,
                      left: -30,
                      child: _buildCrescent(),
                    ),

                    // ط¯ط§ط¦ط±ط© ط¶ظˆط¦ظٹط© - ط£ط¹ظ„ظ‰ ط§ظ„ظٹظ…ظٹظ†
                    Positioned(
                      top: -30 + scrollShift,
                      right: -50,
                      child: _buildGlowCircle(
                        size: 180,
                        color: widget.primary,
                        opacity: widget.isDark ? 0.06 : 0.04,
                      ),
                    ),

                    // ط¯ط§ط¦ط±ط© ط¶ظˆط¦ظٹط© - ط§ظ„ظ…ظ†طھطµظپ ط§ظ„ظٹط³ط§ط±
                    Positioned(
                      top: 300 + scrollShift * 0.5,
                      left: -60,
                      child: _buildGlowCircle(
                        size: 160,
                        color: widget.gold,
                        opacity: widget.isDark ? 0.05 : 0.03,
                      ),
                    ),

                    // ط¯ط§ط¦ط±ط© ط¶ظˆط¦ظٹط© - ط§ظ„ط£ط³ظپظ„ ط§ظ„ظٹظ…ظٹظ†
                    Positioned(
                      bottom: 200,
                      right: -40,
                      child: _buildGlowCircle(
                        size: 140,
                        color: widget.primary,
                        opacity: widget.isDark ? 0.04 : 0.03,
                      ),
                    ),

                    // ظ†ط¬ظˆظ… طµط؛ظٹط±ط© - Dark ظپظ‚ط·
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

                    // ظ†ط¬ظٹظ…ط§طھ ط£ظٹظ‚ظˆظ†ط© - ط®ظپظٹظپط© ط¬ط¯ط§ظ‹
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط®ظ„ظپظٹط© ط§ظ„ط£ط³ط§ط³ظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildBase() {
    if (widget.isDark) {
      // Dark: طھط¯ط±ط¬ ظ…ظ† ط£ط®ط¶ط± ط؛ط§ظ…ظ‚ ط¬ط¯ط§ظ‹ ظپظٹ ط§ظ„ط£ط¹ظ„ظ‰
      // ط¥ظ„ظ‰ ط£ط®ط¶ط± ط؛ط§ظ…ظ‚ ط£ظƒط«ط± ظپظٹ ط§ظ„ط£ط³ظپظ„
      // â†گ ظ‡ط°ط§ ظٹط¬ط¹ظ„ ط§ظ„ط¨ط·ط§ظ‚ط§طھ ط§ظ„ط®ط¶ط±ط§ط، ط§ظ„ط؛ط§ظ…ظ‚ط© طھظ†ط¯ظ…ط¬ ط¨ط³ظ„ط§ط³ط©
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
            colors: [
              const Color(0xFF0A1210), // ط£ط®ط¶ط± ط؛ط§ظ…ظ‚ ط¬ط¯ط§ظ‹ ظپظٹ ط§ظ„ط£ط¹ظ„ظ‰
              const Color(0xFF0E1714), // ط§ظ„ظ„ظˆظ† ط§ظ„ط£ط³ط§ط³ظٹ ظ„ظ„ط®ظ„ظپظٹط©
              const Color(0xFF0B1411), // ط£ط؛ظ…ظ‚ ظ‚ظ„ظٹظ„ط§ظ‹ ظپظٹ ط§ظ„ط£ط³ظپظ„
            ],
          ),
        ),
      );
    } else {
      // Light: ط£ط¨ظٹط¶ ظ†ظ‚ظٹ ظپظٹ ط§ظ„ط£ط¹ظ„ظ‰ â†گ ظٹطھظˆط§ظپظ‚ ظ…ط¹ ط§ظ„ط¨ط·ط§ظ‚ط§طھ ط§ظ„ط¨ظٹط¶ط§ط،
      // طھط¯ط±ط¬ ط®ظپظٹظپ ط¬ط¯ط§ظ‹ ظ†ط­ظˆ ط§ظ„ظƒط±ظٹظ…ظٹ ظپظٹ ط§ظ„ط£ط³ظپظ„
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 1.0],
            colors: [
              const Color(0xFFFAF8F4), // ط´ط¨ظ‡ ط£ط¨ظٹط¶ ظپظٹ ط§ظ„ط£ط¹ظ„ظ‰
              const Color(0xFFF5F1E8), // ظƒط±ظٹظ…ظٹ ط®ظپظٹظپ ظپظٹ ط§ظ„ظ…ظ†طھطµظپ
              const Color(0xFFF0EBE0), // ظƒط±ظٹظ…ظٹ ظپظٹ ط§ظ„ط£ط³ظپظ„
            ],
          ),
        ),
      );
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ‡ظ„ط§ظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildCrescent() {
    // ط§ظ„ظ‡ظ„ط§ظ„ ط¨ط³ظٹط· ظˆط®ظپظٹظپ ط¬ط¯ط§ظ‹ ظ„ط§ ظٹط²ط¹ط¬ ط§ظ„ط¹ظٹظ†
    const outerSize = 150.0;
    const innerSize = 122.0;
    const innerLeft = 34.0;
    const innerTop = 10.0;

    final outerOpacity = widget.isDark ? 0.08 : 0.05;

    // ظ„ظˆظ† ط§ظ„ظ‡ظ„ط§ظ„ ظٹطھظˆط§ظپظ‚ ظ…ط¹ ط§ظ„ط®ظ„ظپظٹط© ظ„ط¥ط®ظپط§ط، ط§ظ„ط¬ط²ط، ط§ظ„ط¯ط§ط®ظ„ظٹ
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
              color: widget.gold.withValues(alpha: outerOpacity),
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط¯ط§ط¦ط±ط© ط¶ظˆط¦ظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildGlowCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    // ظ†ط¨ط¶ ط®ظپظٹظپ ط¬ط¯ط§ظ‹
    final pulsedOpacity =
        opacity * (0.7 + 0.3 * sin(_anim.value * pi));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: pulsedOpacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ†ط¬ظٹظ…ط§طھ ط£ظٹظ‚ظˆظ†ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  List<Widget> _buildIconStars(
      double scrollShift, double fadeOpacity) {
    // opacity ط®ظپظٹظپط© ط¬ط¯ط§ظ‹ ظپظٹ ظƒظ„ط§ ط§ظ„ظˆط¶ط¹ظٹظ†
    final baseOpacity = widget.isDark ? 0.10 : 0.06;

    // طھظ„ط£ظ„ط¤ ط¨ط·ظٹط،
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
          color: widget.gold.withValues(alpha: twinkled),
        ),
      );
    }).toList();
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط¨ظٹط§ظ†ط§طھ ظ…ط³ط§ط¹ط¯ط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

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

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط³ط§ظ… ط§ظ„ظ†ط¬ظˆظ… (Dark ظپظ‚ط·)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

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
          ..color = color.withValues(alpha: opacity)
          ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, s.size * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.twinkle != twinkle || old.scrollShift != scrollShift;
}