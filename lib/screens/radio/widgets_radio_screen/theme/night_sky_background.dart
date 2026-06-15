// lib/screens/radio/widgets_radio_screen/theme/night_sky_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'radio_colors.dart';
import 'radio_animations.dart';

class NightSkyBackground extends StatelessWidget {
  final AnimationController controller;
  final Color primary;

  const NightSkyBackground({
    super.key,
    required this.controller,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // â•گâ•گ ط§ظ„ط£ظ„ظˆط§ظ† ط­ط³ط¨ ط§ظ„ظˆط¶ط¹ â•گâ•گ
    final skyTopColor = isDark
        ? const Color(0xFF060A14)
        : const Color(0xFFE8F4FD);
    final skyMiddleColor = isDark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF0F6FC);
    final skyBottomColor = isDark
        ? const Color(0xFF0C1220)
        : const Color(0xFFF5F8FA);
    final starColor = isDark
        ? Colors.white
        : Colors.black.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _NightSkyPainter(
          progress: controller.value,
          primary: primary,
          gold: RadioColors.gold,
          skyTopColor: skyTopColor,
          skyMiddleColor: skyMiddleColor,
          skyBottomColor: skyBottomColor,
          starColor: starColor,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  final double progress;
  final Color primary, gold;
  final Color skyTopColor, skyMiddleColor, skyBottomColor;
  final Color starColor;
  final bool isDark;

  _NightSkyPainter({
    required this.progress,
    required this.primary,
    required this.gold,
    required this.skyTopColor,
    required this.skyMiddleColor,
    required this.skyBottomColor,
    required this.starColor,
    required this.isDark,
  });

  static const List<List<double>> _stars = [
    [0.08, 0.05], [0.22, 0.12], [0.45, 0.03], [0.67, 0.08],
    [0.85, 0.04], [0.15, 0.18], [0.38, 0.15], [0.72, 0.19],
    [0.92, 0.13], [0.05, 0.28], [0.55, 0.22], [0.80, 0.30],
    [0.30, 0.35], [0.60, 0.38], [0.10, 0.42], [0.95, 0.25],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
    final bgPaint = Paint();
    bgPaint.shader = LinearGradient(
      colors: [skyTopColor, skyMiddleColor, skyBottomColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // â•گâ•گ ط§ظ„ظ†ط¬ظˆظ… (ظپظٹ ط§ظ„ط¯ط§ظƒ ظپظ‚ط·) ط£ظˆ ظ†ظ‚ط§ط· ط²ط®ط±ظپظٹط© ظپظٹ ط§ظ„ظپط§طھط­ â•گâ•گ
    for (int i = 0; i < _stars.length; i++) {
      final twinkle = RadioTwinkleValue.calculate(
        progress: progress,
        starIndex: i,
      );
      final starPaint = Paint()
        ..color = starColor.withValues(alpha: 
          isDark ? 0.5 * twinkle : 0.15 * twinkle,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(
          size.width * _stars[i][0],
          size.height * _stars[i][1] * 0.5,
        ),
        isDark ? 0.8 + 0.8 * twinkle : 0.5 + 0.5 * twinkle,
        starPaint,
      );
    }

    // â•گâ•گ ط¯ظˆط§ط¦ط± ط¶ظˆط¦ظٹط© ظ…طھط­ط±ظƒط© â•گâ•گ
    final glowPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final x = size.width * (0.2 + 0.6 * sin(phase * 2 * pi + i * 1.3));
      final y = size.height * (0.05 + 0.2 * cos(phase * 2 * pi + i * 1.8));
      final r = 100.0 + 50.0 * sin(phase * pi + i);
      glowPaint.shader = RadialGradient(
        colors: [
          (i.isEven ? primary : gold).withValues(alpha: 
            isDark ? 0.07 : 0.05,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(x, y), radius: r),
      );
      canvas.drawCircle(Offset(x, y), r, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter old) =>
      old.progress != progress || old.isDark != isDark;
}