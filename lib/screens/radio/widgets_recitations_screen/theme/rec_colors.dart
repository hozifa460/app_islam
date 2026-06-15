// lib/screens/radio/widgets_recitations_screen/theme/rec_colors.dart

import 'package:flutter/material.dart';

class RecColors {
  RecColors._();

  // ══ ألوان ثابتة ══
  static const Color gold = Color(0xFFC8A44D);

  // ══ خلفيات ══
  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF080C18) : const Color(0xFFF5F0E8);

  static Color skyTop(BuildContext context) =>
      _isDark(context) ? const Color(0xFF060A14) : const Color(0xFFE8F4FD);

  static Color skyBottom(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0A0E1A) : const Color(0xFFF5F8FA);

  static Color cardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.92);

  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06);

  // ══ النصوص ══
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.54)
          : Colors.black.withOpacity(0.5);

  static Color textHint(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withOpacity(0.38)
          : Colors.black.withOpacity(0.35);

  // ══ ثوابت للتوافق مع الكود القديم ══
  static const Color textWhite = Colors.white;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  static const Color textGreen = Colors.green;

  // ══ أيقونات وأزرار ══
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

  // ══ المشغل المصغر ══
  static Color miniPlayerBorder(BuildContext context, Color primary) =>
      primary.withOpacity(_isDark(context) ? 0.3 : 0.2);

  // ══ عناصر القائمة ══
  static Color itemBackground(BuildContext context, {bool isActive = false, Color? primary}) {
    if (isActive && primary != null) {
      return primary.withOpacity(_isDark(context) ? 0.12 : 0.08);
    }
    return _isDark(context)
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.9);
  }

  static Color itemBorder(BuildContext context, {bool isActive = false, Color? primary}) {
    if (isActive && primary != null) {
      return primary.withOpacity(_isDark(context) ? 0.3 : 0.2);
    }
    return _isDark(context)
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);
  }

  // ══ شارة التحميل ══
  static Color downloadBadgeBackground(BuildContext context, bool hasDownloads, Color primary) {
    if (hasDownloads) return Colors.green.withOpacity(0.1);
    return primary.withOpacity(_isDark(context) ? 0.1 : 0.08);
  }

  static Color downloadBadgeBorder(BuildContext context, bool hasDownloads, Color primary) {
    if (hasDownloads) return Colors.green.withOpacity(0.25);
    return primary.withOpacity(_isDark(context) ? 0.2 : 0.15);
  }

  // ══ الخلفيات المتحركة ══
  static Color glowColor(BuildContext context, Color color) =>
      color.withOpacity(_isDark(context) ? 0.08 : 0.04);

  static Color starColor(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black.withOpacity(0.2);

  // ══ دوال مساعدة ══
  static Color white(double opacity) => Colors.white.withOpacity(opacity);
  static Color black(double opacity) => Colors.black.withOpacity(opacity);
  static Color primary(Color c, double opacity) => c.withOpacity(opacity);
  static Color goldOpacity(double opacity) => gold.withOpacity(opacity);

  // ══ تدرجات ══
  static LinearGradient miniPlayerGradient(BuildContext context, Color primary) =>
      LinearGradient(
        colors: _isDark(context)
            ? [primary.withOpacity(0.2), gold.withOpacity(0.1)]
            : [primary.withOpacity(0.1), gold.withOpacity(0.05)],
      );

  static LinearGradient darkOverlay() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
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
            ? [primary.withOpacity(0.1), primary.withOpacity(0.05)]
            : _isDark(context)
            ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.03)]
            : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.8)],
      );

  // ══ مساعد ══
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}