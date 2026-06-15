import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QiblaTheme {
  final bool isDark;
  QiblaTheme({required this.isDark});

  // ==============================
  // ًںژ¨ Colors
  // ==============================
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color gold = Color(0xFFE6B325);
  static const Color green = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF1A6B3A);
  static const Color red = Color(0xFFE74C3C);
  static const Color blue = Color(0xFF3498DB);
  static const Color orange = Colors.orange;

  Color get bg => isDark ? bgDark : bgLight;
  Color get textColor => isDark ? Colors.white : const Color(0xFF1A1A2E);

  // ==============================
  // ًںژ¨ Card & Surface Colors
  // ==============================
  Color get cardBg => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.9);

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : gold.withValues(alpha: 0.16);

  Color get backBtnBg => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.9);

  Color get backBtnBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : gold.withValues(alpha: 0.25);

  // ==============================
  // ًںژ¨ Background Gradients
  // ==============================
  List<Color> facingGradient(bool isFacing) => isDark
      ? [
    isFacing ? const Color(0xFF0D2016) : const Color(0xFF0D1520),
    bgDark,
  ]
      : [
    isFacing ? const Color(0xFFE8F8EF) : const Color(0xFFEEF3FF),
    bgLight,
  ];

  // ==============================
  // ًں“گ Dimensions
  // ==============================
  static const double cardRadius = 18.0;
  static const double bannerRadius = 20.0;
  static const double accuracyBarRadius = 18.0;
  static const double howToUseRadius = 18.0;
  static const double calibrationRadius = 13.0;
  static const double backBtnRadius = 12.0;

  static const double compassMinSize = 210.0;
  static const double compassMaxSize = 310.0;
  static const double compassSizeFactor = 0.74;

  static const double needleWidth = 26.0;
  static const double centerDotSize = 38.0;

  // ==============================
  // ًں“¦ Shadows
  // ==============================
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.04),
      blurRadius: 7,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get accuracyShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ==============================
  // ًں”¤ Text Styles
  // ==============================
  TextStyle get titleStyle => GoogleFonts.cairo(
  fontSize: 20,
  fontWeight: FontWeight.w800,
  color: textColor,
  );

  TextStyle get subtitleStyle => GoogleFonts.cairo(
  fontSize: 10,
  color: textColor.withValues(alpha: 0.45),
  );

  TextStyle labelStyle(double fontSize) => GoogleFonts.cairo(
  fontSize: fontSize,
  color: isDark ? Colors.white60 : Colors.black54,
  );

  TextStyle boldStyle(double fontSize, Color color) => GoogleFonts.cairo(
  fontSize: fontSize,
  fontWeight: FontWeight.w800,
  color: color,
  );

  // ==============================
  // ًں”§ Guidance Helpers
  // ==============================
  static Color getGuidanceColor(double deviation) {
  final abs = deviation.abs();
  if (abs < 5) return green;
  if (abs < 25) return const Color(0xFFF39C12);
  return red;
  }

  static String getDirectionLabel(double deviation) {
  final d = deviation;
  final abs = d.abs();
  if (abs < 5) return 'âœ“  ط§ظ„ظ‚ط¨ظ„ط© ط£ظ…ط§ظ…ظƒ ظ…ط¨ط§ط´ط±ط©';
  if (abs < 20) return d > 0 ? 'ط¯ظˆظ‘ط± ظ‚ظ„ظٹظ„ط§ظ‹ ظ„ظ„ظٹط³ط§ط±' : 'ط¯ظˆظ‘ط± ظ‚ظ„ظٹظ„ط§ظ‹ ظ„ظ„ظٹظ…ظٹظ†';
  if (abs < 60) return d > 0 ? 'ط¯ظˆظ‘ط± ظ„ظ„ظٹط³ط§ط±' : 'ط¯ظˆظ‘ط± ظ„ظ„ظٹظ…ظٹظ†';
  if (abs < 120) return d > 0 ? 'ط§ظ„ظ‚ط¨ظ„ط© ط¹ظ„ظ‰ ظٹط³ط§ط±ظƒ' : 'ط§ظ„ظ‚ط¨ظ„ط© ط¹ظ„ظ‰ ظٹظ…ظٹظ†ظƒ';
  return 'ط§ظ„ظ‚ط¨ظ„ط© ط®ظ„ظپظƒطŒ ط§ط³طھط¯ط±';
  }

  static IconData getDirectionIcon(double deviation) {
  final d = deviation;
  final abs = d.abs();
  if (abs < 5) return Icons.check_circle_rounded;
  if (abs < 20) return d > 0 ? Icons.rotate_left : Icons.rotate_right;
  if (abs < 120) return d > 0 ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded;
  return Icons.sync_rounded;
  }

  static String getAccuracyText(int accuracy) {
  if (accuracy >= 95) return 'âœ“ ظ…ظ…طھط§ط² â€” ط£ظ†طھ طھظˆط§ط¬ظ‡ ط§ظ„ظ‚ط¨ظ„ط© ط¨ط¯ظ‚ط© ط¹ط§ظ„ظٹط©';
  if (accuracy >= 70) return 'ظ‚ط±ظٹط¨ â€” ط§ط³طھظ…ط± ظپظٹ ط§ظ„ط¯ظˆط±ط§ظ† ظ‚ظ„ظٹظ„ط§ظ‹';
  if (accuracy >= 40) return 'ظ…طھظˆط³ط· â€” ط¯ظˆظ‘ط± ظ†ط­ظˆ ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط،';
  return 'ط¨ط¹ظٹط¯ â€” ط¯ظˆظ‘ط± ظ‡ط§طھظپظƒ ظ†ط­ظˆ ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط،';
  }
}