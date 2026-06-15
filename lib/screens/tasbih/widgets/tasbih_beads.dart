import 'package:flutter/material.dart';
import 'tasbih_theme.dart';

/// ✅ خرز مسبحة فخم (يعبّر عن النسبة)
class CurvedBeadsProgress extends StatelessWidget {
  final double progress;
  final int beadCount;
  final Color color;

  const CurvedBeadsProgress({
    super.key,
    required this.progress,
    this.beadCount = 16,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return SizedBox(
          height: TasbihTheme.beadAreaHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _CurvedBeadsPainter(
              progress: value,
              beadCount: beadCount,
              beadColor: color,
            ),
          ),
        );
      },
    );
  }
}

class _CurvedBeadsPainter extends CustomPainter {
  final double progress;
  final int beadCount;
  final Color beadColor;

  _CurvedBeadsPainter({
    required this.progress,
    required this.beadCount,
    required this.beadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = beadCount.clamp(6, 40);
    final filled = (progress * count).round().clamp(0, count);

    final start = Offset(size.width * 0.05, size.height * 0.75);
    final end = Offset(size.width * 0.95, size.height * 0.25);
    final c1 = Offset(size.width * 0.35, size.height * 0.95);
    final c2 = Offset(size.width * 0.65, size.height * 0.05);

    // خيط المسبحة
    final stringPaint = Paint()
      ..color = TasbihTheme.stringColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    canvas.drawPath(path, stringPaint);

    Offset pointOnCubic(double t) {
      final mt = (1 - t);
      final a = mt * mt * mt;
      final b = 3 * mt * mt * t;
      final c = 3 * mt * t * t;
      final d = t * t * t;

      return Offset(
        a * start.dx + b * c1.dx + c * c2.dx + d * end.dx,
        a * start.dy + b * c1.dy + c * c2.dy + d * end.dy,
      );
    }

    for (int i = 0; i < count; i++) {
      final t = (count == 1) ? 0.0 : i / (count - 1);
      final p = pointOnCubic(t);

      final active = i < filled;
      final r = active ? TasbihTheme.beadSize : TasbihTheme.beadSize - 1;

      if (active) {
        final shadowPaint = Paint()
          ..color = beadColor.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(p.translate(0, 4), r, shadowPaint);
      }

      final base = active ? beadColor : TasbihTheme.beadInactive;
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [
          Colors.white.withOpacity(active ? 0.65 : 0.40),
          base.withOpacity(active ? 0.95 : 0.85),
          base.withOpacity(active ? 0.70 : 0.65),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

      final beadPaint = Paint()
        ..shader =
        gradient.createShader(Rect.fromCircle(center: p, radius: r));

      canvas.drawCircle(p, r, beadPaint);

      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(active ? 0.55 : 0.35);
      canvas.drawCircle(
          p.translate(-r * 0.35, -r * 0.35), r * 0.20, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedBeadsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.beadCount != beadCount ||
        oldDelegate.beadColor != beadColor;
  }
}