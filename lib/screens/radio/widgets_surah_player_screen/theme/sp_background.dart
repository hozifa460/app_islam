// lib/screens/radio/widgets_surah_player/sp_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'sp_colors.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط§ظ„ط®ظ„ظپظٹط© ط§ظ„ظ…طھط­ط±ظƒط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class SpBackground extends StatelessWidget {
  final AnimationController controller;
  final Color primary;
  final bool isDark;

  const SpBackground({
    super.key,
    required this.controller,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: SpColors.bgColors(primary, isDark),
          ),
        ),
        child: CustomPaint(
          size: size,
          painter: _BgPainter(
            progress: controller.value,
            primary: primary,
            gold: SpColors.gold,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double progress;
  final Color primary, gold;
  final bool isDark;

  _BgPainter({
    required this.progress,
    required this.primary,
    required this.gold,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final phase = (progress + i * 0.25) % 1.0;
      final x = size.width * (0.1 + 0.8 * sin(phase * 2 * pi + i * 1.3));
      final y = size.height * (0.05 + 0.4 * cos(phase * 2 * pi + i * 1.7));
      final r = 100.0 + 60.0 * sin(phase * pi + i);
      paint.shader = RadialGradient(
        colors: [
          (i.isEven ? primary : gold).withValues(alpha: isDark ? 0.06 : 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.progress != progress;
}