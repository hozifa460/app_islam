// lib/screens/radio/widgets_recitations_screen/theme/rec_colors.dart

import 'package:flutter/material.dart';

class RecColors {
  RecColors._();

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط«ط§ط¨طھط© â•گâ•گ
  static const Color gold = Color(0xFFC8A44D);

  // â•گâ•گ ط®ظ„ظپظٹط§طھ â•گâ•گ
  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF080C18) : const Color(0xFFF5F0E8);

  static Color skyTop(BuildContext context) =>
      _isDark(context) ? const Color(0xFF060A14) : const Color(0xFFE8F4FD);

  static Color skyBottom(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0A0E1A) : const Color(0xFFF5F8FA);

  static Color cardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.92);

  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06);

  // â•گâ•گ ط§ظ„ظ†طµظˆطµ â•گâ•گ
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.54)
          : Colors.black.withValues(alpha: 0.5);

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.38)
          : Colors.black.withValues(alpha: 0.35);

  // â•گâ•گ ط«ظˆط§ط¨طھ ظ„ظ„طھظˆط§ظپظ‚ ظ…ط¹ ط§ظ„ظƒظˆط¯ ط§ظ„ظ‚ط¯ظٹظ… â•گâ•گ
  static const Color textWhite = Colors.white;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  static const Color textGreen = Colors.green;

  // â•گâ•گ ط£ظٹظ‚ظˆظ†ط§طھ ظˆط£ط²ط±ط§ط± â•گâ•گ
  static Color iconBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06);

  static Color iconBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.1);

  static Color iconColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black54;

  // â•گâ•گ ط´ط±ظٹط· ط§ظ„ط¨ط­ط« â•گâ•گ
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

  // â•گâ•گ ط§ظ„ظ…ط´ط؛ظ„ ط§ظ„ظ…طµط؛ط± â•گâ•گ
  static Color miniPlayerBorder(BuildContext context, Color primary) =>
      primary.withValues(alpha: _isDark(context) ? 0.3 : 0.2);

  // â•گâ•گ ط¹ظ†ط§طµط± ط§ظ„ظ‚ط§ط¦ظ…ط© â•گâ•گ
  static Color itemBackground(BuildContext context, {bool isActive = false, Color? primary}) {
    if (isActive && primary != null) {
      return primary.withValues(alpha: _isDark(context) ? 0.12 : 0.08);
    }
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.9);
  }

  static Color itemBorder(BuildContext context, {bool isActive = false, Color? primary}) {
    if (isActive && primary != null) {
      return primary.withValues(alpha: _isDark(context) ? 0.3 : 0.2);
    }
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
  }

  // â•گâ•گ ط´ط§ط±ط© ط§ظ„طھط­ظ…ظٹظ„ â•گâ•گ
  static Color downloadBadgeBackground(BuildContext context, bool hasDownloads, Color primary) {
    if (hasDownloads) return Colors.green.withValues(alpha: 0.1);
    return primary.withValues(alpha: _isDark(context) ? 0.1 : 0.08);
  }

  static Color downloadBadgeBorder(BuildContext context, bool hasDownloads, Color primary) {
    if (hasDownloads) return Colors.green.withValues(alpha: 0.25);
    return primary.withValues(alpha: _isDark(context) ? 0.2 : 0.15);
  }

  // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط§طھ ط§ظ„ظ…طھط­ط±ظƒط© â•گâ•گ
  static Color glowColor(BuildContext context, Color color) =>
      color.withValues(alpha: _isDark(context) ? 0.08 : 0.04);

  static Color starColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black.withValues(alpha: 0.2);

  // â•گâ•گ ط¯ظˆط§ظ„ ظ…ط³ط§ط¹ط¯ط© â•گâ•گ
  static Color white(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color black(double opacity) => Colors.black.withValues(alpha: opacity);
  static Color primary(Color c, double opacity) => c.withValues(alpha: opacity);
  static Color goldOpacity(double opacity) => gold.withValues(alpha: opacity);

  // â•گâ•گ طھط¯ط±ط¬ط§طھ â•گâ•گ
  static LinearGradient miniPlayerGradient(BuildContext context, Color primary) =>
      LinearGradient(
        colors: _isDark(context)
            ? [primary.withValues(alpha: 0.2), gold.withValues(alpha: 0.1)]
            : [primary.withValues(alpha: 0.1), gold.withValues(alpha: 0.05)],
      );

  static LinearGradient darkOverlay() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
  );

  static LinearGradient fallbackGradient(List<Color> colors) => LinearGradient(
    colors: colors,
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient categoryIconGradient(List<Color> colors) =>
      LinearGradient(
        colors: colors,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient bgGradient(BuildContext context) => LinearGradient(
    colors: [skyTop(context), skyBottom(context)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient reciterItemGradient(
      BuildContext context, Color primary, bool hasDownloads) =>
      LinearGradient(
        colors: hasDownloads
            ? [primary.withValues(alpha: 0.1), primary.withValues(alpha: 0.05)]
            : _isDark(context)
            ? [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.03)]
            : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.8)],
      );

  // â•گâ•گ ظ…ط³ط§ط¹ط¯ â•گâ•گ
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}