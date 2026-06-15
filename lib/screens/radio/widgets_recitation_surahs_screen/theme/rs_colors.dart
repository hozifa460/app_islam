// lib/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart

import 'package:flutter/material.dart';

class RsColors {
  RsColors._();

  // ══ ألوان ثابتة ══
  static const Color gold = Color(0xFFC8A44D);

  // ══ خلفيات حسب الوضع ══
  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF080C18) : const Color(0xFFF5F0E8);

  static Color cardBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : Colors.white;

  static Color sheetBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A2820) : Colors.white;

  // ══ سماء الخلفية ══
  static Color skyTop(BuildContext context) =>
      _isDark(context) ? const Color(0xFF060A14) : const Color(0xFFE8F4FD);

  static Color skyMid(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0A0E1A) : const Color(0xFFF0F6FC);

  static Color skyBot(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0C1220) : const Color(0xFFF5F8FA);

  // ══ النصوص ══
  static Color textPrimary(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext) ? Colors.white : const Color(0xFF1A1A2E);
    }
    return (isDarkOrContext as bool) ? Colors.white : const Color(0xFF1A1A2E);
  }

  static Color textSecondary(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext)
          ? Colors.white.withOpacity(0.38)
          : Colors.black.withOpacity(0.38);
    }
    return (isDarkOrContext as bool)
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.38);
  }

  static Color textMuted(dynamic isDarkOrContext) {
    if (isDarkOrContext is BuildContext) {
      return _isDark(isDarkOrContext)
          ? Colors.white.withOpacity(0.54)
          : Colors.black.withOpacity(0.45);
    }
    return (isDarkOrContext as bool)
        ? Colors.white.withOpacity(0.54)
        : Colors.black.withOpacity(0.45);
  }

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.3)
          : Colors.black.withOpacity(0.3);

  // ══ الأيقونات والأزرار ══
  static Color iconBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.06);

  static Color iconBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.15)
          : Colors.black.withOpacity(0.1);

  static Color iconColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black54;

  static Color appBarIconBg(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.06);

  // ══ شريط البحث ══
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

  // ══ البطاقات ══
  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06);

  static Color cardBorderActive(BuildContext context, Color primary) =>
      primary.withOpacity(_isDark(context) ? 0.3 : 0.2);

  // ══ حاوية البطاقة حسب الحالة ══
  static Color surahTileBg({
    required bool isCurrentSurah,
    required bool isDownloaded,
    required bool isDark,
    required Color cardColor,
    required Color primary,
  }) {
    if (isCurrentSurah) {
      return primary.withOpacity(isDark ? 0.12 : 0.08);
    }
    if (isDownloaded) {
      return isDark ? cardColor : Colors.green.withOpacity(0.04);
    }
    return isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.black.withOpacity(0.02);
  }

  static Color surahTileBorder({
    required bool isCurrentSurah,
    required bool isDownloaded,
    required bool isDark,
    required Color primary,
  }) {
    if (isCurrentSurah) {
      return primary.withOpacity(isDark ? 0.3 : 0.2);
    }
    if (isDownloaded) {
      return Colors.green.withOpacity(isDark ? 0.15 : 0.1);
    }
    return primary.withOpacity(isDark ? 0.06 : 0.04);
  }

  // ══ دوال مساعدة بدون context (للتوافق) ══
  static Color white(double v) => Colors.white.withOpacity(v);
  static Color black(double v) => Colors.black.withOpacity(v);
  static Color primary(Color c, double v) => c.withOpacity(v);
  static Color goldOp(double v) => gold.withOpacity(v);
  static Color grey(double v) => Colors.grey.withOpacity(v);

  // ══ تدرجات ══
  static LinearGradient reciterHeaderGradient(
      Color primary, dynamic isDarkOrContext) {
    final dark = isDarkOrContext is BuildContext
        ? _isDark(isDarkOrContext)
        : isDarkOrContext as bool;
    return LinearGradient(
      colors: [
        primary.withOpacity(dark ? 0.15 : 0.08),
        gold.withOpacity(dark ? 0.08 : 0.04),
      ],
    );
  }

  static LinearGradient reciterIconGradient(Color primary) =>
      LinearGradient(
        colors: [primary.withOpacity(0.25), gold.withOpacity(0.15)],
      );

  static LinearGradient radioPlayBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withOpacity(0.8)],
      );

  static LinearGradient miniPlayerGradient(
      Color primary, dynamic isDarkOrContext) {
    final dark = isDarkOrContext is BuildContext
        ? _isDark(isDarkOrContext)
        : isDarkOrContext as bool;
    return LinearGradient(
      colors: [
        primary.withOpacity(dark ? 0.2 : 0.1),
        gold.withOpacity(dark ? 0.1 : 0.05),
      ],
    );
  }

  static LinearGradient fabGradient(Color primary) => LinearGradient(
    colors: [primary, primary.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient surahPlayBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withOpacity(0.8)],
      );

  static LinearGradient downloadBtnGradient(Color primary) =>
      LinearGradient(
        colors: [primary, primary.withOpacity(0.8)],
      );

  static LinearGradient bgGradient(BuildContext context) => LinearGradient(
    colors: [skyTop(context), skyMid(context), skyBot(context)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ══ مساعد ══
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}