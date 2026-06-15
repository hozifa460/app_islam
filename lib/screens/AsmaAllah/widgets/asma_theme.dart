import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AsmaTheme {
  final bool isDark;
  AsmaTheme({required this.isDark});

  // ==============================
  // 🎨 Colors
  // ==============================
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE6C866);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldDeep = Color(0xFFDAA520);
  static const Color brownText = Color(0xFF2C1810);
  static const Color brownSub = Color(0xFF5D4E37);

  Color get textColor => isDark ? Colors.white : brownText;
  Color get subTextColor => isDark ? Colors.white70 : brownSub;

  // ==============================
  // 🎭 Background Gradients
  // ==============================
  List<Color> get bgGradient => isDark
      ? [const Color(0xFF0A0E1A), const Color(0xFF0F1628), const Color(0xFF050810)]
      : [const Color(0xFFFFFEFA), const Color(0xFFFFF9EC), const Color(0xFFFFF5DE)];

  List<Color> get bgGradientAlt => isDark
      ? [const Color(0xFF0A0E1A), const Color(0xFF0F1628), const Color(0xFF050810)]
      : [const Color(0xFFFFFDF8), const Color(0xFFFFF9EC), const Color(0xFFFFF5DE)];

  // ==============================
  // 🎭 AppBar Gradients
  // ==============================
  List<Color> get circleAppBarGradient => isDark
      ? [const Color(0xFF1A2540).withOpacity(0.95), const Color(0xFF0F1628).withOpacity(0.85)]
      : [const Color(0xFFFFFDF5).withOpacity(0.95), const Color(0xFFFFF8E1).withOpacity(0.85)];

  List<Color> get allNamesAppBarGradient => isDark
      ? [const Color(0xFF1A2540), const Color(0xFF0F1628)]
      : [const Color(0xFF2C1810), const Color(0xFF1A0F08)];

  // ==============================
  // 🎨 Card Colors
  // ==============================
  List<Color> get cardGradient => isDark
      ? [const Color(0xFF1A2438).withOpacity(0.9), const Color(0xFF0F1628).withOpacity(0.9)]
      : [Colors.white, const Color(0xFFFFF8E8)];

  Color get cardBorder => gold.withOpacity(isDark ? 0.3 : 0.25);

  // ==============================
  // 📐 Dimensions
  // ==============================
  static const double appBarRadius = 24.0;
  static const double cardRadius = 24.0;
  static const double searchRadius = 20.0;
  static const double buttonRadius = 14.0;

  // ==============================
  // 📦 Shadows
  // ==============================
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.3) : gold.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ==============================
  // 🔤 Common Styles
  // ==============================
  TextStyle nameStyle(double fontSize) => GoogleFonts.amiri(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: isDark ? gold : goldDark,
  );

  TextStyle arabicTitle(double fontSize) => GoogleFonts.amiri(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white : brownText,
  );

  TextStyle bodyText(double fontSize) => GoogleFonts.cairo(
    fontSize: fontSize,
    height: 1.9,
    color: textColor,
  );
}