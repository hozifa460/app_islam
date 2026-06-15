import 'package:flutter/material.dart';

class SunnahTheme {
  final bool isDark;
  SunnahTheme({required this.isDark});

  // ==============================
  // 🎨 Dark Mode Colors
  // ==============================
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkDivider = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ==============================
  // 🎨 Light Mode Colors
  // ==============================
  static const Color lightBg = Color(0xFFF0F4F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ==============================
  // 🎨 Shared Accent Colors
  // ==============================
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color gold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color purple = Color(0xFF7C3AED);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFF3B82F6);

  // ==============================
  // 🎯 Dynamic Getters
  // ==============================
  Color get bg => isDark ? darkBg : lightBg;
  Color get card => isDark ? darkCard : lightCard;
  Color get divider => isDark ? darkDivider : lightDivider;
  Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;

  // ==============================
  // 📐 Dimensions
  // ==============================
  static const double cardRadius = 18.0;
  static const double headerRadius = 0.0;
  static const double tabBarRadius = 16.0;
  static const double chipRadius = 20.0;
  static const double badgeRadius = 8.0;
  static const double detailSheetRadius = 28.0;
  static const double progressHeight = 8.0;
  static const double accentLineWidth = 3.0;

  // ==============================
  // 🎭 Header Gradients
  // ==============================
  List<Color> get headerGradient => isDark
      ? [const Color(0xFF0D2818), const Color(0xFF0A1520), const Color(0xFF0A0E1A)]
      : [const Color(0xFF064E3B), const Color(0xFF065F46), const Color(0xFF047857)];

  List<Color> get splashGradient => isDark
      ? [const Color(0xFF0A0E1A), const Color(0xFF0D1F17)]
      : [const Color(0xFFE8F5E9), const Color(0xFFF0F4F8)];

  List<Color> get overallStatsGradient => isDark
      ? [const Color(0xFF0D2818), const Color(0xFF0A1520)]
      : [const Color(0xFF064E3B), const Color(0xFF065F46)];

  // ==============================
  // 🎭 Tab Bar
  // ==============================
  static const LinearGradient tabIndicatorGradient = LinearGradient(
    colors: [emerald, emeraldDark],
  );

  // ==============================
  // 🎭 Emerald Gradients
  // ==============================
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [emerald, emeraldDark],
  );

  static const LinearGradient emeraldLightGradient = LinearGradient(
    colors: [emeraldLight, emeraldDark],
  );

  // ==============================
  // 🎭 Importance Gradients
  // ==============================
  static const LinearGradient highImportanceGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
  );

  static const LinearGradient normalImportanceGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
  );

  // ==============================
  // 📦 Shadows
  // ==============================
  List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: emerald.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  BoxShadow cardShadow(Color color) => BoxShadow(
    color: color.withOpacity(isDark ? 0.08 : 0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  BoxShadow get cardShadow2 => BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
    blurRadius: 6,
    offset: const Offset(0, 2),
  );

  // ==============================
  // 🎯 Complete Button Styles
  // ==============================
  LinearGradient completedBtnGradient() => LinearGradient(
  colors: isDark
  ? [const Color(0xFF374151), const Color(0xFF1F2937)]
      : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
  );

  // ==============================
  // 🔧 Category Icons
  // ==============================
  static const Map<String, String> categoryIcons = {
  'fajr': '🌙',
  'morning_adhkar': '🌅',
  'duha': '☀️',
  'dhuhr': '🌞',
  'asr': '🌤️',
  'evening_adhkar': '🌆',
  'maghrib': '🌇',
  'isha': '🌃',
  'witr': '⭐',
  'tahajjud': '🌟',
  'sleep': '😴',
  'always': '♾️',
  'weekly_fast': '📅',
  'monthly_fast': '🌕',
  'friday': '🕌',
  'yearly_fast': '🗓️',
  'yearly_prayer': '🎊',
  };

  // ==============================
  // 🔧 Day Names
  // ==============================
  static const Map<int, String> dayNames = {
  1: 'الاثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
  6: 'السبت',
  7: 'الأحد',
  };

  // ==============================
  // 🔧 Helpers
  // ==============================
  static Color hexToColor(String hex) =>
  Color(int.parse(hex.replaceFirst('#', '0xFF')));

  static String getDayName(int weekday) => dayNames[weekday] ?? '';
}