// lib/screens/radio/widgets_surah_player/sp_colors.dart

import 'package:flutter/material.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط£ظ„ظˆط§ظ† ظ…ط´ط؛ظ„ ط§ظ„ط³ظˆط±ط© ط§ظ„ظ…ط®طµطµط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class SpColors {
  SpColors._();

  static const Color gold = Color(0xFFC8A44D);
  static const Color darkBgStart = Color(0xFF0D1A14);
  static const Color darkBgEnd = Color(0xFF0A0E0D);
  static const Color lightBgMid = Color(0xFFF5F1E8);
  static const Color darkSheet = Color(0xFF1A2820);

  // â•گâ•گ ط¯ظˆط§ظ„ ظ…ط³ط§ط¹ط¯ط© â•گâ•گ
  static Color white(double v) => Colors.white.withValues(alpha: v);
  static Color black(double v) => Colors.black.withValues(alpha: v);
  static Color goldOp(double v) => gold.withValues(alpha: v);
  static Color primaryOp(Color c, double v) => c.withValues(alpha: v);
  static Color grey(double v) => Colors.grey.withValues(alpha: v);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظ†طµ ط­ط³ط¨ ط§ظ„ط«ظٹظ… â•گâ•گ
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1A1A1A);

  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45;

  static Color textTertiary(bool isDark) =>
      isDark ? Colors.white54 : Colors.black38;

  static Color iconColor(bool isDark) =>
      isDark ? Colors.white70 : Colors.black54;

  static Color iconSecondary(bool isDark) =>
      isDark ? Colors.white54 : Colors.black38;

  // â•گâ•گ ط®ظ„ظپظٹط§طھ ط§ظ„ط£ط²ط±ط§ط± ط­ط³ط¨ ط§ظ„ط«ظٹظ… â•گâ•گ
  static Color btnBg(bool isDark) =>
      Colors.white.withValues(alpha: isDark ? 0.1 : 0.7);

  static Color controlBtnBg(bool isDark) =>
      Colors.white.withValues(alpha: isDark ? 0.09 : 0.7);

  static Color extraBtnBg(bool isDark) =>
      Colors.white.withValues(alpha: isDark ? 0.07 : 0.65);

  static Color cardBg(bool isDark) =>
      Colors.white.withValues(alpha: isDark ? 0.06 : 0.65);

  // â•گâ•گ طھط¯ط±ط¬ط§طھ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
  static List<Color> bgColors(Color primary, bool isDark) => isDark
      ? [darkBgStart, primary.withValues(alpha: 0.12), darkBgEnd]
      : [primary.withValues(alpha: 0.06), lightBgMid, gold.withValues(alpha: 0.04)];

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظˆط¶ط¹ (ط£ظˆظ†ظ„ط§ظٹظ†/ط£ظˆظپظ„ط§ظٹظ†) â•گâ•گ
  static Color modeBgColor(bool isOnline) =>
      (isOnline ? Colors.blue : Colors.green).withValues(alpha: 0.12);

  static Color modeBorderColor(bool isOnline) =>
      (isOnline ? Colors.blue : Colors.green).withValues(alpha: 0.25);

  static Color modeTextColor(bool isOnline) =>
      isOnline ? Colors.blue : Colors.green;
}