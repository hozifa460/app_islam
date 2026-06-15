// lib/screens/radio/widgets_recitations_screen/theme/rec_detail_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'rec_colors.dart';

class RecDetailBackground extends StatelessWidget {
  final AnimationController controller;
  final List<Color> colors;

  const RecDetailBackground({
    super.key,
    required this.controller,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor = RecColors.skyTop(context);
    final bottomColor = RecColors.skyBottom(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _RecDetailBgPainter(
          progress: controller.value,
          colors: colors,
          topColor: topColor,
          bottomColor: bottomColor,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _RecDetailBgPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final Color topColor;
  final Color bottomColor;
  final bool isDark;

  _RecDetailBgPainter({
    required this.progress,
    required this.colors,
    required this.topColor,
    required this.bottomColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
    final bg = Paint();
    bg.shader = LinearGradient(
      colors: [topColor, bottomColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // â•گâ•گ ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط¶ظˆط¦ظٹط© â•گâ•گ
    final glow = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 2; i++) {
      final phase = (progress + i * 0.5) % 1.0;
      final x = size.width * (0.3 + 0.4 * sin(phase * 2 * pi + i));
      final y = size.height * (0.1 + 0.2 * cos(phase * 2 * pi + i));
      final r = 130.0 + 40.0 * sin(phase * pi);
      glow.shader = RadialGradient(
        colors: [
          colors[i % colors.length].withValues(alpha: isDark ? 0.1 : 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));
      canvas.drawCircle(Offset(x, y), r, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _RecDetailBgPainter old) =>
      old.progress != progress || old.isDark != isDark;
}