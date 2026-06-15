import 'package:flutter/material.dart';

class HizbQuarterPainter extends CustomPainter {
  final int quarter;
  final Color activeColor;
  final Color inactiveColor;

  HizbQuarterPainter({
    required this.quarter,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.2;
    const gap = 0.18;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const fullQuarter = 1.57079632679;
    const startBase = -1.57079632679;
    final sweep = fullQuarter - gap;

    for (int i = 0; i < 4; i++) {
      final startAngle = startBase + (i * fullQuarter) + (gap / 2);
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        i < quarter ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HizbQuarterPainter oldDelegate) {
    return oldDelegate.quarter != quarter ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}