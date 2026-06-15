import 'package:flutter/material.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// العناصر الزخرفية المشتركة
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════
// الدائرة الزخرفية
// ═══════════════════════════════════════════
class DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  final bool animated;

  const DecorativeCircle({
    super.key,
    required this.size,
    required this.color,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );

    if (animated) {
      return SlowRotationWidget(
        duration: const Duration(seconds: 30),
        child: circle,
      );
    }

    return circle;
  }
}

// ═══════════════════════════════════════════
// الدوائر الزخرفية العائمة
// ═══════════════════════════════════════════
class FloatingDecorativeCircles extends StatelessWidget {
  final Size size;
  final Color baseColor;

  const FloatingDecorativeCircles({
    super.key,
    required this.size,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.12,
          left: -size.width * 0.12,
          child: WaveAnimationWidget(
            amplitude: 5,
            duration: const Duration(seconds: 4),
            child: DecorativeCircle(
              size: size.width * 0.5,
              color: baseColor.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.06,
          right: -size.width * 0.1,
          child: WaveAnimationWidget(
            amplitude: 8,
            duration: const Duration(seconds: 5),
            child: DecorativeCircle(
              size: size.width * 0.38,
              color: baseColor.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.06,
          right: size.width * 0.08,
          child: PulseAnimationWidget(
            minScale: 0.9,
            maxScale: 1.1,
            duration: const Duration(seconds: 2),
            child: DecorativeCircle(
              size: size.width * 0.12,
              color: baseColor.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// الشريط الجانبي الملون
// ═══════════════════════════════════════════
class ColoredSideStrip extends StatelessWidget {
  final Color color;
  final double height;

  const ColoredSideStrip({
    super.key,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 3.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// خلفية الدوائر للبطاقة
// ═══════════════════════════════════════════
class CardBackgroundCircles extends StatelessWidget {
  final double cardHeight;
  final Color accent;

  const CardBackgroundCircles({
    super.key,
    required this.cardHeight,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -cardHeight * 0.3,
          top: -cardHeight * 0.3,
          child: DecorativeCircle(
            size: cardHeight * 0.9,
            color: accent.withOpacity(0.06),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: DecorativeCircle(
            size: cardHeight * 0.55,
            color: accent.withOpacity(0.04),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// أيقونة الهيدر المتحركة
// ═══════════════════════════════════════════
class AnimatedHeaderIcon extends StatelessWidget {
  final double size;
  final Animation<double> animation;

  const AnimatedHeaderIcon({
    super.key,
    required this.size,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: GlowAnimationWidget(
        glowColor: AzkarTheme.gold,
        maxBlur: 20,
        minBlur: 8,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AzkarTheme.gold.withOpacity(0.12),
            border: Border.all(
              color: AzkarTheme.gold.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AzkarTheme.gold.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: PulseAnimationWidget(
              minScale: 0.9,
              maxScale: 1.1,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AzkarTheme.gold,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}