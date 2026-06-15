// lib/screens/radio/widgets/radio_animations.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// أنيميشن الراديو المخصصة
/// ══════════════════════════════════════════════════════════════

/// مدد الأنيميشن المستخدمة
class RadioAnimationDurations {
  RadioAnimationDurations._();

  static const Duration equalizer = Duration(milliseconds: 1200);
  static const Duration background = Duration(seconds: 14);
  static const Duration playerSlide = Duration(milliseconds: 400);
  static const Duration headerFade = Duration(milliseconds: 900);
  static const Duration cardTransition = Duration(milliseconds: 250);
}

/// منحنيات الأنيميشن
class RadioAnimationCurves {
  RadioAnimationCurves._();

  static const Curve playerSlide = Curves.easeOutCubic;
  static const Curve headerFade = Curves.easeOut;
}

/// ويدجت الـ Fade + Slide للهيدر
class RadioFadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;

  const RadioFadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
    this.beginOffset = const Offset(0, -0.3),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// ويدجت لتوليد قيم أنيميشن بسيطة (Pulsing)
class RadioPulseBuilder extends StatelessWidget {
  final AnimationController controller;
  final Widget Function(BuildContext context, double pulseValue) builder;
  final double frequency;
  final double minValue;
  final double maxValue;

  const RadioPulseBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.frequency = 1.0,
    this.minValue = 0.0,
    this.maxValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final raw = (sin(controller.value * 2 * pi * frequency) + 1) / 2;
        final value = minValue + (maxValue - minValue) * raw;
        return builder(context, value);
      },
    );
  }
}

/// ويدجت الـ Twinkle (وميض النجوم)
class RadioTwinkleValue {
  static double calculate({
    required double progress,
    required int starIndex,
    double baseFrequency = 1.2,
    double frequencyStep = 0.15,
    double phaseStep = 1.3,
    double minBrightness = 0.25,
  }) {
    final freq = baseFrequency + starIndex * frequencyStep;
    final phase = starIndex * phaseStep;
    final raw = (sin(progress * 2 * pi * freq + phase) + 1) / 2;
    return minBrightness + (1.0 - minBrightness) * raw;
  }
}

/// ويدجت Equalizer Bar واحد
class RadioEqualizerBar {
  static double calculateHeight({
    required double animationValue,
    required int barIndex,
    double minHeight = 3.0,
    double maxAdditionalHeight = 9.0,
    double phaseStep = 0.9,
  }) {
    final phase = animationValue * 2 * pi + barIndex * phaseStep;
    return minHeight + maxAdditionalHeight * ((sin(phase) + 1) / 2);
  }
}