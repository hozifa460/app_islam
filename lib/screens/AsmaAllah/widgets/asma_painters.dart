import 'dart:math' as math;
import 'package:flutter/material.dart';

class AsmaIslamicPatternPainter extends CustomPainter {
  final Color color;
  final double step;
  final int sides;

  AsmaIslamicPatternPainter({
    required this.color,
    this.step = 50,
    this.sides = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sides == 8 ? 0.8 : 0.5;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;

        final path = Path();
        for (int i = 0; i < sides; i++) {
          final angle = (math.pi * 2 / sides) * i - math.pi / sides;
          final px = cx + step * (sides == 6 ? 0.4 : 0.35) * math.cos(angle);
          final py = cy + step * (sides == 6 ? 0.4 : 0.35) * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        // ظ†ظ‚ط·ط©/ظ†ط¬ظ…ط© ظ…ط±ظƒط²ظٹط©
        if (sides == 6) {
          final starPaint = Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;
          final starPath = Path();
          for (int i = 0; i < 12; i++) {
            final angle = (math.pi / 6) * i - math.pi / 2;
            final r = i.isEven ? step * 0.08 : step * 0.04;
            final px = cx + r * math.cos(angle);
            final py = cy + r * math.sin(angle);
            if (i == 0) {
              starPath.moveTo(px, py);
            } else {
              starPath.lineTo(px, py);
            }
          }
          starPath.close();
          canvas.drawPath(starPath, starPaint);
        } else {
          final dotPaint = Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(cx, cy), step * 0.05, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant AsmaIslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class AsmaGlowRingsPainter extends CustomPainter {
  final Offset center;
  final List<double> radii;
  final Color gold;
  final double opacity;

  AsmaGlowRingsPainter({
    required this.center,
    required this.radii,
    required this.gold,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final radius in radii) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AsmaGlowRingsPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}