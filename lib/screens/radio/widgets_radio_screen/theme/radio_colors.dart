// lib/screens/radio/widgets_radio_screen/theme/radio_colors.dart

import 'package:flutter/material.dart';

class RadioColors {
  RadioColors._();

  // â•گâ•گ ط§ظ„ط£ظ„ظˆط§ظ† ط§ظ„ط«ط§ط¨طھط© â•گâ•گ
  static const Color gold = Color(0xFFC8A44D);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط­ط³ط¨ ط§ظ„ظˆط¶ط¹ â•گâ•گ

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

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظ†طµظˆطµ â•گâ•گ

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.55)
          : Colors.black.withValues(alpha: 0.5);

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.35);

  static Color textInverted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A1A2E) : Colors.white;

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ط¨ط·ط§ظ‚ط§طھ â•گâ•گ

  static Color cardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.9);

  static Color cardBackgroundActive(BuildContext context, Color primary) =>
      _isDark(context)
          ? primary.withValues(alpha: 0.12)
          : primary.withValues(alpha: 0.07);

  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);

  static Color cardBorderActive(BuildContext context, Color primary) =>
      primary.withValues(alpha: _isDark(context) ? 0.35 : 0.25);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ط£ظٹظ‚ظˆظ†ط§طھ ظˆط§ظ„ط£ط²ط±ط§ط± â•گâ•گ

  static Color iconBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06);

  static Color iconBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.1);

  static Color iconColor(BuildContext context) =>
      _isDark(context) ? Colors.white70 : Colors.black54;

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط´ط±ظٹط· ط§ظ„ط¨ط­ط« â•گâ•گ

  static Color searchBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05);

  static Color searchBorder(BuildContext context, Color primary) =>
      primary.withValues(alpha: _isDark(context) ? 0.2 : 0.15);

  static Color searchText(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black87;

  static Color searchHint(BuildContext context) =>
      _isDark(context) ? Colors.white38 : Colors.black38;

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظ…ط´ط؛ظ„ ط§ظ„ط³ظپظ„ظٹ â•گâ•گ

  static List<Color> playerGradient(BuildContext context, Color primary) =>
      _isDark(context)
          ? [primary.withValues(alpha: 0.25), const Color(0xFF0D1520)]
          : [primary.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.97)];

  static Color playerBorderTop(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);

  static Color playerShadow(BuildContext context) =>
      Colors.black.withValues(alpha: _isDark(context) ? 0.7 : 0.1);

  static Color playerText(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color playerSubText(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.45)
          : Colors.black.withValues(alpha: 0.4);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„طھط¨ظˆظٹط¨ط§طھ â•گâ•گ

  static Color tabBarBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.06);

  static Color tabUnselectedColor(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.45);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظ€ Header â•گâ•گ

  static Color headerTitle(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color headerSubtitle(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.45);

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„ظ†ط¬ظˆظ… ظپظٹ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ

  static Color starColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black.withValues(alpha: 0.3);

  // â•گâ•گ ظ…ط³ط§ط¹ط¯ ط§ظ„طھط­ظ‚ظ‚ â•گâ•گ

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط§ظ„طھطµظ†ظٹظپط§طھ (ط«ط§ط¨طھط©) â•گâ•گ

  static const Map<String, List<Color>> categoryColors = {
    'ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…': [Color(0xFF2D1B69), Color(0xFF7C3AED)],
    'ط§ظ„ط­ط±ظ…ظٹظ† ط§ظ„ط´ط±ظٹظپظٹظ†': [Color(0xFF1A3A2A), Color(0xFF16A34A)],
    'ط¥ط°ط§ط¹ط§طھ ط±ط³ظ…ظٹط©': [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    'طھظپط³ظٹط± ظˆط¹ظ„ظˆظ…': [Color(0xFF3B1F00), Color(0xFFC2700C)],
    'ط±ظ‚ظٹط© ظˆط£ط¯ط¹ظٹط©': [Color(0xFF2D1A3A), Color(0xFF9333EA)],
    'طھظ„ط§ظˆط§طھ ط®ط§ط´ط¹ط©': [Color(0xFF1A1A2E), Color(0xFF6366F1)],
    'طھط±ط¬ظ…ط§طھ ط§ظ„ظ‚ط±ط¢ظ†': [Color(0xFF064E3B), Color(0xFF059669)],
  };

  static const List<Color> defaultCategoryColors = [
    Color(0xFF1A1A2E),
    Color(0xFF6366F1),
  ];

  static const Map<String, String> categoryIcons = {
    'ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…': 'ًں“–',
    'ط§ظ„ط­ط±ظ…ظٹظ† ط§ظ„ط´ط±ظٹظپظٹظ†': 'ًں•‹',
    'ط¥ط°ط§ط¹ط§طھ ط±ط³ظ…ظٹط©': 'ًں“،',
    'طھظپط³ظٹط± ظˆط¹ظ„ظˆظ…': 'ًں“ڑ',
    'ط±ظ‚ظٹط© ظˆط£ط¯ط¹ظٹط©': 'ًں¤²',
    'طھظ„ط§ظˆط§طھ ط®ط§ط´ط¹ط©': 'ًں’§',
    'طھط±ط¬ظ…ط§طھ ط§ظ„ظ‚ط±ط¢ظ†': 'ًںŒچ',
  };

  static List<Color> getColorsForCategory(String category) =>
      categoryColors[category] ?? defaultCategoryColors;

  static String getIconForCategory(String category) =>
      categoryIcons[category] ?? 'ًںژµ';

  // â•گâ•گ ط£ظ„ظˆط§ظ† ظ…ط³ط§ط¹ط¯ط© ط«ط§ط¨طھط© â•گâ•گ

  static Color whiteWithOpacity(double opacity) =>
      Colors.white.withValues(alpha: opacity);

  static Color blackWithOpacity(double opacity) =>
      Colors.black.withValues(alpha: opacity);

  static Color goldWithOpacity(double opacity) =>
      gold.withValues(alpha: opacity);

  // â•گâ•گ طھط¯ط±ط¬ط§طھ â•گâ•گ

  static LinearGradient darkOverlayGradient({
    double topOpacity = 0.1,
    double bottomOpacity = 0.75,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: topOpacity),
        Colors.black.withValues(alpha: bottomOpacity),
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
      colors: [primary, primary.withValues(alpha: 0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}