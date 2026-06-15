// lib/screens/radio/widgets_recitations/rec_animations.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_animations.dart';

/// ══ Helper لشاشة التفاصيل (bg + equalizer) ══
class RecDetailAnimationHelper {
  late AnimationController bgController;
  late AnimationController equalizerController;

  void init(TickerProvider vsync) {
    equalizerController = AnimationController(
      vsync: vsync,
      duration: RadioAnimationDurations.equalizer,
    )..repeat();

    bgController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  void dispose() {
    equalizerController.dispose();
    bgController.dispose();
  }
}