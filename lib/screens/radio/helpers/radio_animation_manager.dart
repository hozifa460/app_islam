// lib/screens/radio/helpers/radio_animation_manager.dart

import 'package:flutter/material.dart';

class RadioAnimationManager {
  RadioAnimationManager._();

  static const Duration _equalizerDuration =
  Duration(milliseconds: 1200);
  static const Duration _backgroundDuration = Duration(seconds: 14);
  static const Duration _albumDuration = Duration(seconds: 12);
  static const Duration _playerSlideDuration = Duration(milliseconds: 400);
  static const Duration _headerFadeDuration = Duration(milliseconds: 900);

  // ══════════════════════════════════════════════════════
  // Equalizer فقط
  // ══════════════════════════════════════════════════════
  static AnimationController createEqualizer(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: _equalizerDuration,
    )..repeat();
  }

  // ══════════════════════════════════════════════════════
  // خلفية متحركة
  // ══════════════════════════════════════════════════════
  static AnimationController createBackground(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: _backgroundDuration,
    )..repeat();
  }

  // ══════════════════════════════════════════════════════
  // دوران الألبوم
  // ══════════════════════════════════════════════════════
  static AnimationController createAlbumRotation(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: _albumDuration,
    )..repeat();
  }

  // ══════════════════════════════════════════════════════
  // Player Slide (للمشغل السفلي)
  // ══════════════════════════════════════════════════════
  static AnimationController createPlayerSlide(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: _playerSlideDuration,
    );
  }

  // ══════════════════════════════════════════════════════
  // Header Fade
  // ══════════════════════════════════════════════════════
  static AnimationController createHeaderFade(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: _headerFadeDuration,
    )..forward();
  }
}