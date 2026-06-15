import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double lineWidth;

  IslamicPatternPainter({required this.color, this.lineWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    const step = 40.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;

        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i - math.pi / 8;
          final r = step * 0.35;
          final px = cx + r * math.cos(angle);
          final py = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        canvas.drawLine(
          Offset(cx - step * 0.2, cy),
          Offset(cx + step * 0.2, cy),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy - step * 0.2),
          Offset(cx, cy + step * 0.2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class StarPainter extends CustomPainter {
  final Color color;
  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = size.width / 4;

    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (math.pi / 5) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class GeometricDecorationPainter extends CustomPainter {
  final Color color;
  GeometricDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero, width: r * 1.4, height: r * 1.4),
      paint,
    );
    canvas.restore();

    canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.1, fillPaint);
  }

  @override
  bool shouldRepaint(covariant GeometricDecorationPainter oldDelegate) =>
      oldDelegate.color != color;
}