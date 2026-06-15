// star_field_widget.dart - الكامل المُصلح
import 'dart:math';
import 'package:flutter/material.dart';

class StarParticle {
  final double x, y, size, speed, opacity, twinkleOffset;

  const StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.twinkleOffset,
  });

  factory StarParticle.random(Random r) => StarParticle(
    x:             r.nextDouble(),
    y:             r.nextDouble(),
    size:          r.nextDouble() * 2.5 + 0.5,
    speed:         r.nextDouble() * 0.15 + 0.04,
    opacity:       r.nextDouble() * 0.6  + 0.3,
    twinkleOffset: r.nextDouble() * 2    * pi,
  );
}

class StarFieldWidget extends StatelessWidget {
  final List<StarParticle> particles;
  final double             animValue;
  final double             starOpacityFactor;
  final double             nebulaOpacityFactor;
  // ← اللون الأساسي من الـ provider
  final Color              primaryColor;
  final Color              bg1;

  const StarFieldWidget({
    super.key,
    required this.particles,
    required this.animValue,
    this.starOpacityFactor   = 1.0,
    this.nebulaOpacityFactor = 1.0,
    this.primaryColor        = const Color(0xFF00D4FF),
    this.bg1                 = const Color(0xFF020818),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarFieldPainter(
        particles:           particles,
        animValue:           animValue,
        starOpacityFactor:   starOpacityFactor,
        nebulaOpacityFactor: nebulaOpacityFactor,
        primaryColor:        primaryColor,
        bg1:                 bg1,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double             animValue;
  final double             starOpacityFactor;
  final double             nebulaOpacityFactor;
  final Color              primaryColor;
  final Color              bg1;

  const _StarFieldPainter({
    required this.particles,
    required this.animValue,
    required this.starOpacityFactor,
    required this.nebulaOpacityFactor,
    required this.primaryColor,
    required this.bg1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // ── رسم النجوم ──
    for (final p in particles) {
      final animY   = (p.y + animValue * p.speed) % 1.0;
      final twinkle =
          (sin(animValue * 2 * pi * 1.5 + p.twinkleOffset) + 1) / 2;
      final opacity = (p.opacity * starOpacityFactor *
          (0.3 + 0.7 * twinkle))
          .clamp(0.0, 1.0);

      final dx = p.x * size.width;
      final dy = animY * size.height;

      // نجمة أساسية
      canvas.drawCircle(
        Offset(dx, dy),
        p.size,
        Paint()
          ..color      = Colors.white.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5),
      );

      // توهج بلون الـ primary
      if (p.size > 1.5) {
        canvas.drawCircle(
          Offset(dx, dy),
          p.size * 3.0,
          Paint()
            ..color = primaryColor
                .withOpacity((opacity * 0.18).clamp(0.0, 1.0))
            ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, p.size * 5),
        );
      }
    }

    // ── رسم السدم بألوان الـ primary ──
    _paintNebulae(canvas, size);
  }

  void _paintNebulae(Canvas canvas, Size size) {
    final pulse = (sin(animValue * 2 * pi * 0.2) + 1) / 2;
    final f     = nebulaOpacityFactor;

    // نستخرج HSL من primaryColor لعمل ألوان مكملة
    final hsl        = HSLColor.fromColor(primaryColor);
    // لون مكمل (180 درجة)
    final complement = hsl
        .withHue((hsl.hue + 180) % 360)
        .withLightness(0.5)
        .toColor();
    // لون ثالث (120 درجة)
    final triadic = hsl
        .withHue((hsl.hue + 120) % 360)
        .withLightness(0.45)
        .toColor();
    // لون أفتح من الأصلي
    final lighter = hsl
        .withLightness((hsl.lightness + 0.2).clamp(0.2, 0.8))
        .toColor();

    // سديم أعلى اليمين - اللون الأساسي
    _drawNebula(
      canvas:  canvas,
      center:  Offset(size.width * 0.85, size.height * 0.10),
      radius:  size.width * 0.40,
      color:   primaryColor,
      opacity: (0.07 + 0.03 * pulse) * f,
      blur:    size.width * 0.32,
    );

    // سديم اليسار - اللون المكمل
    _drawNebula(
      canvas:  canvas,
      center:  Offset(size.width * 0.08, size.height * 0.40),
      radius:  size.width * 0.32,
      color:   complement,
      opacity: (0.055 + 0.025 * pulse) * f,
      blur:    size.width * 0.28,
    );

    // سديم أسفل المنتصف - اللون الثالث
    _drawNebula(
      canvas:  canvas,
      center:  Offset(size.width * 0.50, size.height * 0.90),
      radius:  size.width * 0.28,
      color:   triadic,
      opacity: (0.05 + 0.02 * pulse) * f,
      blur:    size.width * 0.24,
    );

    // سديم أسفل اليسار - الأفتح
    _drawNebula(
      canvas:  canvas,
      center:  Offset(size.width * 0.18, size.height * 0.80),
      radius:  size.width * 0.22,
      color:   lighter,
      opacity: (0.04 + 0.015 * pulse) * f,
      blur:    size.width * 0.20,
    );

    // سديم أعلى اليسار - Primary خفيف
    _drawNebula(
      canvas:  canvas,
      center:  Offset(size.width * 0.25, size.height * 0.05),
      radius:  size.width * 0.18,
      color:   primaryColor,
      opacity: (0.04 + 0.01 * pulse) * f,
      blur:    size.width * 0.16,
    );
  }

  void _drawNebula({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color  color,
    required double opacity,
    required double blur,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color      = color.withOpacity(opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) =>
      old.animValue    != animValue    ||
          old.primaryColor != primaryColor ||
          old.starOpacityFactor   != starOpacityFactor   ||
          old.nebulaOpacityFactor != nebulaOpacityFactor;
}