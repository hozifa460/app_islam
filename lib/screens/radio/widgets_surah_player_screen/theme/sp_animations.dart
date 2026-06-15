// lib/screens/radio/widgets_surah_player/sp_animations.dart

import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// أنيميشن مشغل السورة
/// ══════════════════════════════════════════════════════════════
class SpAnimationDurations {
  SpAnimationDurations._();

  static const Duration background = Duration(seconds: 8);
  static const Duration equalizer = Duration(milliseconds: 1200);
  static const Duration albumRotation = Duration(seconds: 12);
  static const Duration playlistItem = Duration(milliseconds: 200);
  static const Duration loopBtn = Duration(milliseconds: 200);
}

/// Helper Class لأنيميشن المشغل (بدل Mixin)
class SpAnimationHelper {
  late AnimationController bgController;
  late AnimationController equalizerController;
  late AnimationController albumArtController;

  void init(TickerProvider vsync) {
    bgController = AnimationController(
      vsync: vsync,
      duration: SpAnimationDurations.background,
    )..repeat();

    equalizerController = AnimationController(
      vsync: vsync,
      duration: SpAnimationDurations.equalizer,
    )..repeat();

    albumArtController = AnimationController(
      vsync: vsync,
      duration: SpAnimationDurations.albumRotation,
    )..repeat();
  }

  void dispose() {
    bgController.dispose();
    equalizerController.dispose();
    albumArtController.dispose();
  }
}