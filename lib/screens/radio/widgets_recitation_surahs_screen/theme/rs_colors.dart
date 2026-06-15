// lib/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart

import 'package:flutter/material.dart';

class RsColors {
  RsColors._();

  // â•گâ•گ ط£ظ„ظˆط§ظ† ط«ط§ط¨طھط© â•گâ•گ
  static const Color gold = Color(0xFFC8A44D);

  // â•گâ•گ ط®ظ„ظپظٹط§طھ ط­ط³ط¨ ط§ظ„ظˆط¶ط¹ â•گâ•گ
  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF080C18) : const Color(0xFFF5F0E8);

  static Color cardBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : Colors.white;

  static Color sheetBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A2820) : Colors.white;

  // â•گâ•گ ط³ظ…ط§ط، ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
  static Color skyTop(BuildContext context) =>
      _isDark(context) ? const Color(0xFF060A14) : const Color(0xFFE8F4FD);

  static Color skyMid(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0A0E1A) : const Color(0xFFF0F6FC);

  static Color skyBot(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0C1220) : const Color(0xFFF5F8FA);

  // â•گâ•گ ط§ظ„ظ†طµظˆطµ â•گâ•گ
  static Color textPrimary(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext) ? Colors.white : const Color(0xFF1A1A2E);
    }
    return (isDarkOrContext as bool) ? Colors.white : const Color(0xFF1A1A2E);
  }

  static Color textSecondary(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext)
          ? Colors.white.withValues(alpha: 0.38)
          : Colors.black.withValues(alpha: 0.38);
    }
    return (isDarkOrContext as bool)
        ? Colors.white.withValues(alpha: 0.38)
        : Colors.black.withValues(alpha: 0.38);
  }

  static Color textMuted(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext)
          ? Colors.white.withValues(alpha: 0.54)
          : Colors.black.withValues(alpha: 0.45);
    }
    return (isDarkOrContext as bool)
        ? Colors.white.withValues(alpha: 0.54)
        : Colors.black.withValues(alpha: 0.45);
  }

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3);

  // â•گâ•گ ط§ظ„ط£ظٹظ‚ظˆظ†ط§طھ ظˆط§ظ„ط£ط²ط±ط§ط± â•گâ•گ
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

  static Color appBarIconBg(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06);

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

  // â•گâ•گ ط§ظ„ط¨ط·ط§ظ‚ط§طھ â•گâ•گ
  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06);

  static Color cardBorderActive(BuildContext context, Color primary) =>
      primary.withValues(alpha: _isDark(context) ? 0.3 : 0.2);

  // â•گâ•گ ط­ط§ظˆظٹط© ط§ظ„ط¨ط·ط§ظ‚ط© ط­ط³ط¨ ط§ظ„ط­ط§ظ„ط© â•گâ•گ
  static Color surahTileBg({
    required bool isCurrentSurah,
    required bool isDownloaded,
    required bool isDark,
    required Color cardColor,
    required Color primary,
  }) {
    if (isCurrentSurah) {
      return primary.withValues(alpha: isDark ? 0.12 : 0.08);
    }
    if (isDownloaded) {
      return isDark ? cardColor : Colors.green.withValues(alpha: 0.04);
    }
    return isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.02);
  }

  static Color surahTileBorder({
    required bool isCurrentSurah,
    required bool isDownloaded,
    required bool isDark,
    required Color primary,
  }) {
    if (isCurrentSurah) {
      return primary.withValues(alpha: isDark ? 0.3 : 0.2);
    }
    if (isDownloaded) {
      return Colors.green.withValues(alpha: isDark ? 0.15 : 0.1);
    }
    return primary.withValues(alpha: isDark ? 0.06 : 0.04);
  }

  // â•گâ•گ ط¯ظˆط§ظ„ ظ…ط³ط§ط¹ط¯ط© ط¨ط¯ظˆظ† context (ظ„ظ„طھظˆط§ظپظ‚) â•گâ•گ
  static Color white(double v) => Colors.white.withValues(alpha: v);
  static Color black(double v) => Colors.black.withValues(alpha: v);
  static Color primary(Color c, double v) => c.withValues(alpha: v);
  static Color goldOp(double v) => gold.withValues(alpha: v);
  static Color grey(double v) => Colors.grey.withValues(alpha: v);

  // â•گâ•گ طھط¯ط±ط¬ط§طھ â•گâ•گ
  static LinearGradient reciterHeaderGradient(
      Color primary, dynamic isDarkOrContext) {
    final dark = isDarkOrContext is BuildContext
        ? _isDark(isDarkOrContext)
        : isDarkOrContext as bool;
    return LinearGradient(
      colors: [
        primary.withValues(alpha: dark ? 0.15 : 0.08),
        gold.withValues(alpha: dark ? 0.08 : 0.04),
      ],
    );
  }

  static LinearGradient reciterIconGradient(Color primary) =>
      LinearGradient(
        colors: [primary.withValues(alpha: 0.25), gold.withValues(alpha: 0.15)],
      );

  static LinearGradient radioPlayBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.8)],
      );

  static LinearGradient miniPlayerGradient(
      Color primary, dynamic isDarkOrContext) {
    final dark = isDarkOrContext is BuildContext
        ? _isDark(isDarkOrContext)
        : isDarkOrContext as bool;
    return LinearGradient(
      colors: [
        primary.withValues(alpha: dark ? 0.2 : 0.1),
        gold.withValues(alpha: dark ? 0.1 : 0.05),
      ],
    );
  }

  static LinearGradient fabGradient(Color primary) => LinearGradient(
    colors: [primary, primary.withValues(alpha: 0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient surahPlayBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.8)],
      );

  static LinearGradient downloadBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.8)],
      );

  static LinearGradient bgGradient(BuildContext context) => LinearGradient(
    colors: [skyTop(context), skyMid(context), skyBot(context)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // â•گâ•گ ظ…ط³ط§ط¹ط¯ â•گâ•گ
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}