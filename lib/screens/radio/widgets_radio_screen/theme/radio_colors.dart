// lib/screens/radio/widgets_radio_screen/theme/radio_colors.dart

import 'package:flutter/material.dart';

class RadioColors {
  RadioColors._();

  // ══ الألوان الثابتة ══
  static const Color gold = Color(0xFFC8A44D);

  // ══ ألوان حسب الوضع ══

  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF080C18) : const Color(0xFFFAF8F4);

  static Color playerBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : Colors.white;

  static Color skyTop(BuildContext context) =>
      _isDark(context) ? const Color(0xFF060A14) : const Color(0xFFF5F1E8);

  static Color skyMiddle(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0A0E1A) : const Color(0xFFF0EBE0);

  static Color skyBottom(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0C1220) : const Color(0xFFF0EBE0);

  // ══ ألوان النصوص ══

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.55)
          : Colors.black.withOpacity(0.5);

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.35)
          : Colors.black.withOpacity(0.35);

  static Color textInverted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A1A2E) : Colors.white;

  // ══ ألوان البطاقات ══

  static Color cardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.06)
          : Colors.white.withOpacity(0.9);

  static Color cardBackgroundActive(BuildContext context, Color primary) =>
      _isDark(context)
          ? primary.withOpacity(0.12)
          : primary.withOpacity(0.07);

  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.07);

  static Color cardBorderActive(BuildContext context, Color primary) =>
      primary.withOpacity(_isDark(context) ? 0.35 : 0.25);

  // ══ ألوان الأيقونات والأزرار ══

  static Color iconBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.06);

  static Color iconBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.15)
          : Colors.black.withOpacity(0.1);

  static Color iconColor(BuildContext context) =>
      _isDark(context) ? Colors.white70 : Colors.black54;

  // ══ ألوان شريط البحث ══

  static Color searchBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.05);

  static Color searchBorder(BuildContext context, Color primary) =>
      primary.withOpacity(_isDark(context) ? 0.2 : 0.15);

  static Color searchText(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black87;

  static Color searchHint(BuildContext context) =>
      _isDark(context) ? Colors.white38 : Colors.black38;

  // ══ ألوان المشغل السفلي ══

  static List<Color> playerGradient(BuildContext context, Color primary) =>
      _isDark(context)
          ? [primary.withOpacity(0.25), const Color(0xFF0D1520)]
          : [primary.withOpacity(0.1), Colors.white.withOpacity(0.97)];

  static Color playerBorderTop(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.07);

  static Color playerShadow(BuildContext context) =>
      Colors.black.withOpacity(_isDark(context) ? 0.7 : 0.1);

  static Color playerText(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color playerSubText(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.45)
          : Colors.black.withOpacity(0.4);

  // ══ ألوان التبويبات ══

  static Color tabBarBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.06);

  static Color tabUnselectedColor(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.5)
          : Colors.black.withOpacity(0.45);

  // ══ ألوان الـ Header ══

  static Color headerTitle(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color headerSubtitle(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.5)
          : Colors.black.withOpacity(0.45);

  // ══ ألوان النجوم في الخلفية ══

  static Color starColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black.withOpacity(0.3);

  // ══ مساعد التحقق ══

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ══ ألوان التصنيفات (ثابتة) ══

  static const Map<String, List<Color>> categoryColors = {
    'القرآن الكريم': [Color(0xFF2D1B69), Color(0xFF7C3AED)],
    'الحرمين الشريفين': [Color(0xFF1A3A2A), Color(0xFF16A34A)],
    'إذاعات رسمية': [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    'تفسير وعلوم': [Color(0xFF3B1F00), Color(0xFFC2700C)],
    'رقية وأدعية': [Color(0xFF2D1A3A), Color(0xFF9333EA)],
    'تلاوات خاشعة': [Color(0xFF1A1A2E), Color(0xFF6366F1)],
    'ترجمات القرآن': [Color(0xFF064E3B), Color(0xFF059669)],
  };

  static const List<Color> defaultCategoryColors = [
    Color(0xFF1A1A2E),
    Color(0xFF6366F1),
  ];

  static const Map<String, String> categoryIcons = {
    'القرآن الكريم': '📖',
    'الحرمين الشريفين': '🕋',
    'إذاعات رسمية': '📡',
    'تفسير وعلوم': '📚',
    'رقية وأدعية': '🤲',
    'تلاوات خاشعة': '💧',
    'ترجمات القرآن': '🌍',
  };

  static List<Color> getColorsForCategory(String category) =>
      categoryColors[category] ?? defaultCategoryColors;

  static String getIconForCategory(String category) =>
      categoryIcons[category] ?? '🎵';

  // ══ ألوان مساعدة ثابتة ══

  static Color whiteWithOpacity(double opacity) =>
      Colors.white.withOpacity(opacity);

  static Color blackWithOpacity(double opacity) =>
      Colors.black.withOpacity(opacity);

  static Color goldWithOpacity(double opacity) =>
      gold.withOpacity(opacity);

  // ══ تدرجات ══

  static LinearGradient darkOverlayGradient({
    double topOpacity = 0.1,
    double bottomOpacity = 0.75,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(topOpacity),
        Colors.black.withOpacity(bottomOpacity),
      ],
      stops: const [0.3, 1.0],
    );
  }

  static LinearGradient categoryGradient(String category) {
    final colors = getColorsForCategory(category);
    return LinearGradient(
      colors: colors,
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  static LinearGradient primaryGradient(Color primary) {
    return LinearGradient(
      colors: [primary, primary.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}