// lib/screens/radio/widgets_surahs/rs_background.dart

import 'package:flutter/material.dart';
import 'rs_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// خلفية شاشة السور الثابتة
/// ══════════════════════════════════════════════════════════════
class RsBackground extends StatelessWidget {
  final Color primary;

  const RsBackground({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    // ✅ نقرأ الألوان من RsColors هنا ونمررها للـ Painter
    return CustomPaint(
      painter: _SurahsBgPainter(
        primary: primary,
        skyTop: RsColors.skyTop(context),   // ✅ من RsColors
        skyMid: RsColors.skyMid(context),   // ✅ من RsColors
        skyBot: RsColors.skyBot(context),   // ✅ من RsColors
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════
/// رسام الخلفية
/// ══════════════════════════════════════════════════════════════
class _SurahsBgPainter extends CustomPainter {
  final Color primary;
  final Color skyTop;
  final Color skyMid;
  final Color skyBot;

  _SurahsBgPainter({
    required this.primary,
    required this.skyTop,
    required this.skyMid,
    required this.skyBot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // ══ الخلفية المتدرجة ══
    final bg = Paint()
      ..shader = LinearGradient(
        colors: [skyTop, skyMid, skyBot], // ✅ ألوان ديناميكية
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // ══ ضوء خافت أعلى الشاشة ══
    final glowCenter = Offset(size.width * 0.5, 0);
    final glowRadius = size.width * 0.7;

    final glow = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          RsColors.primary(primary, 0.1), // ✅ من RsColors
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: glowCenter,
          radius: glowRadius,
        ),
      );

    canvas.drawCircle(glowCenter, glowRadius, glow);
  }

  @override
  bool shouldRepaint(covariant _SurahsBgPainter old) =>
      old.primary != primary ||
          old.skyTop != skyTop ||   // ✅ إعادة رسم عند تغيير الوضع
          old.skyMid != skyMid ||
          old.skyBot != skyBot;
}