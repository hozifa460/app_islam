// lib/screens/radio/widgets_surah_player/sp_colors.dart

import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// ألوان مشغل السورة المخصصة
/// ══════════════════════════════════════════════════════════════
class SpColors {
  SpColors._();

  static const Color gold = Color(0xFFC8A44D);
  static const Color darkBgStart = Color(0xFF0D1A14);
  static const Color darkBgEnd = Color(0xFF0A0E0D);
  static const Color lightBgMid = Color(0xFFF5F1E8);
  static const Color darkSheet = Color(0xFF1A2820);

  // ══ دوال مساعدة ══
  static Color white(double v) => Colors.white.withOpacity(v);
  static Color black(double v) => Colors.black.withOpacity(v);
  static Color goldOp(double v) => gold.withOpacity(v);
  static Color primaryOp(Color c, double v) => c.withOpacity(v);
  static Color grey(double v) => Colors.grey.withOpacity(v);

  // ══ ألوان النص حسب الثيم ══
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1A1A1A);

  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.5) : Colors.black45;

  static Color textTertiary(bool isDark) =>
      isDark ? Colors.white54 : Colors.black38;

  static Color iconColor(bool isDark) =>
      isDark ? Colors.white70 : Colors.black54;

  static Color iconSecondary(bool isDark) =>
      isDark ? Colors.white54 : Colors.black38;

  // ══ خلفيات الأزرار حسب الثيم ══
  static Color btnBg(bool isDark) =>
      Colors.white.withOpacity(isDark ? 0.1 : 0.7);

  static Color controlBtnBg(bool isDark) =>
      Colors.white.withOpacity(isDark ? 0.09 : 0.7);

  static Color extraBtnBg(bool isDark) =>
      Colors.white.withOpacity(isDark ? 0.07 : 0.65);

  static Color cardBg(bool isDark) =>
      Colors.white.withOpacity(isDark ? 0.06 : 0.65);

  // ══ تدرجات الخلفية ══
  static List<Color> bgColors(Color primary, bool isDark) => isDark
      ? [darkBgStart, primary.withOpacity(0.12), darkBgEnd]
      : [primary.withOpacity(0.06), lightBgMid, gold.withOpacity(0.04)];

  // ══ ألوان الوضع (أونلاين/أوفلاين) ══
  static Color modeBgColor(bool isOnline) =>
      (isOnline ? Colors.blue : Colors.green).withOpacity(0.12);

  static Color modeBorderColor(bool isOnline) =>
      (isOnline ? Colors.blue : Colors.green).withOpacity(0.25);

  static Color modeTextColor(bool isOnline) =>
      isOnline ? Colors.blue : Colors.green;
}