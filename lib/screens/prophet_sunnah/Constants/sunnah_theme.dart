import 'package:flutter/material.dart';

class SunnahTheme {
  // ألوان الوضع الداكن
  static const darkBackground = Color(0xFF0A0E1A);
  static const darkSurface = Color(0xFF111827);
  static const darkCard = Color(0xFF1A2540);
  static const darkBorder = Color(0xFF2A3550);

  // ألوان الوضع الفاتح
  static const lightBackground = Color(0xFFF5F0E8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFAF7F0);
  static const lightBorder = Color(0xFFE8DFC8);

  // ألوان مشتركة
  static const gold = Color(0xFFD4AF37);
  static const goldDark = Color(0xFF8B6914);
  static const goldLight = Color(0xFFE8C96A);

  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : lightBackground;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : lightCard;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : const Color(0xFF5A5A7A);

  static Color textHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white30
          : const Color(0xFF9A9AB0);

  static List<Color> headerGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? [const Color(0xFF1A2540), const Color(0xFF0A0E1A)]
          : [const Color(0xFF2C4A7C), const Color(0xFF1A2D52)];
}