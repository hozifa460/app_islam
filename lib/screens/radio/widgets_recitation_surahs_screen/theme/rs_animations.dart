// lib/screens/radio/widgets_surahs/rs_animations.dart

import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// أنيميشن شاشة السور - Helper Class بدل Mixin
/// ══════════════════════════════════════════════════════════════
class RsAnimationDurations {
  RsAnimationDurations._();

  static const Duration equalizer = Duration(milliseconds: 1200);
}

class RsAnimationHelper {
  late AnimationController equalizerController;

  void init(TickerProvider vsync) {
    equalizerController = AnimationController(
      vsync: vsync,
      duration: RsAnimationDurations.equalizer,
    )..repeat();
  }

  void dispose() {
    equalizerController.dispose();
  }
}