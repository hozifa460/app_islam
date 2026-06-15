import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsTheme {
  final bool isDark;
  final Color currentPrimary;

  SettingsTheme({required this.isDark, required this.currentPrimary});

  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color gold = Color(0xFFE6B325);
  static const Color cardDark = Color(0xFF151B26);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const List<IconData> colorIcons = [
    Icons.mosque_rounded,
    Icons.park_rounded,
    Icons.cloud_rounded,
    Icons.auto_awesome_rounded,
    Icons.favorite_rounded,
    Icons.water_rounded,
    Icons.wb_sunny_rounded,
    Icons.nights_stay_rounded,
    Icons.landscape_rounded,
    Icons.filter_drama_rounded,
    Icons.local_fire_department_rounded,
    Icons.sailing_rounded,
  ];

  Color get bg => isDark ? bgDark : bgLight;
  Color get textColor => isDark ? Colors.white : const Color(0xFF1A1A2E);
  Color get cardBg => isDark ? cardDark : Colors.white.withValues(alpha: 0.95);

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : currentPrimary.withValues(alpha: 0.14);

  Color get dividerColor => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.05);

  Color get backBtnBg => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.9);

  Color get backBtnBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : currentPrimary.withValues(alpha: 0.22);

  List<Color> get bgGradient => isDark
      ? [const Color(0xFF0D1520), bgDark, const Color(0xFF0A0E17)]
      : [const Color(0xFFEEF3FF), bgLight, const Color(0xFFE8F0FF)];

  static const double cardRadius = 18.0;

  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  TextStyle titleStyle(double w) => GoogleFonts.cairo(
    fontSize: (w * 0.055).clamp(18.0, 26.0),
    fontWeight: FontWeight.w800,
    color: textColor,
  );

  TextStyle subtitleStyle(double w) => GoogleFonts.cairo(
    fontSize: (w * 0.03).clamp(10.0, 13.0),
    color: textColor.withValues(alpha: 0.45),
  );

  TextStyle sectionLabelStyle(double w) => GoogleFonts.cairo(
    fontSize: (w * 0.04).clamp(13.0, 17.0),
    fontWeight: FontWeight.w800,
    color: textColor,
  );
}