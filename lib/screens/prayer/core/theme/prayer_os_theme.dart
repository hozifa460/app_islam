import 'package:flutter/material.dart';

class PrayerOSTheme {
  static const primary = Color(0xFF1F7A8C);
  static const accent = Color(0xFFE6B325);
  static const darkBg = Color(0xFF0F172A);
  static const lightBg = Color(0xFFF8FAFC);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [
      Color(0xFF1F7A8C),
      Color(0xFF2E8BC0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient goldGradient = const LinearGradient(
    colors: [
      Color(0xFFE6B325),
      Color(0xFFF4D03F),
    ],
  );
}