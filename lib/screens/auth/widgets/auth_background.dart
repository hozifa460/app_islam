import 'dart:math';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
              Color(0xFF0A0E1A),
              Color(0xFF152238),
              Color(0xFF0D1425),
              Color(0xFF060A14),
            ]
                : const [
              Color(0xFFFFFDF8),
              Color(0xFFFFF8E8),
              Color(0xFFFFFAEE),
              Color(0xFFFFF3D6),
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -s.height * 0.08,
              right: -s.width * 0.1,
              child: _Glow(
                d: s.width * 0.7,
                c: _gold.withValues(alpha: isDark ? 0.07 : 0.05),
              ),
            ),
            Positioned(
              bottom: -s.height * 0.06,
              left: -s.width * 0.15,
              child: _Glow(
                d: s.width * 0.55,
                c: _gold.withValues(alpha: isDark ? 0.05 : 0.04),
              ),
            ),
            Positioned(
              top: s.height * 0.4,
              left: -s.width * 0.08,
              child: _Glow(
                d: s.width * 0.35,
                c: _gold.withValues(alpha: isDark ? 0.04 : 0.03),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(
                  _gold.withValues(alpha: isDark ? 0.015 : 0.025),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double d;
  final Color c;
  const _Glow({required this.d, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [c, Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;
  _PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const step = 80.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2, cy = y + step / 2;
        final path = Path();
        for (int i = 0; i < 16; i++) {
          final a = (pi / 8) * i;
          final r = i.isEven ? step * 0.26 : step * 0.14;
          i == 0
              ? path.moveTo(cx + r * cos(a), cy + r * sin(a))
              : path.lineTo(cx + r * cos(a), cy + r * sin(a));
        }
        path.close();
        canvas.drawPath(path, p);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color;
}