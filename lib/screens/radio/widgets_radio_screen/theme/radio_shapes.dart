// lib/screens/radio/widgets/radio_shapes.dart

import 'package:flutter/material.dart';
import 'radio_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// أشكال وديكورات الراديو المخصصة
/// ══════════════════════════════════════════════════════════════
class RadioShapes {
  RadioShapes._();

  // ══ Border Radius ══
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 18.0;
  static const double radiusPlayer = 22.0;

  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXLarge =>
      BorderRadius.circular(radiusXLarge);
  static BorderRadius get borderRadiusPlayer =>
      const BorderRadius.vertical(top: Radius.circular(radiusPlayer));

  // ══ ديكور البطاقة المميزة ══
  static BoxDecoration featuredCardDecoration({
    required bool isPlaying,
    required Color gold,
    required List<Color> categoryColors,
  }) {
    return BoxDecoration(
      borderRadius: borderRadiusXLarge,
      border: Border.all(
        color:
        isPlaying ? gold : RadioColors.whiteWithOpacity(0.08),
        width: isPlaying ? 1.5 : 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: categoryColors.last.withOpacity(isPlaying ? 0.45 : 0.2),
          blurRadius: isPlaying ? 18 : 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // ══ ديكور زر التشغيل الدائري ══
  static BoxDecoration playButtonDecoration({
    required bool isPlaying,
    required Color gold,
  }) {
    final color = isPlaying ? gold : Colors.white;
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 8,
        ),
      ],
    );
  }

  // ══ ديكور زر التشغيل الرئيسي في المشغل السفلي ══
  static BoxDecoration mainPlayButtonDecoration(Color primary) {
    return BoxDecoration(
      color: primary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.5),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ══ ديكور زر الرجوع ══
  static BoxDecoration backButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? RadioColors.whiteWithOpacity(0.1)
          : RadioColors.blackWithOpacity(0.06),
      shape: BoxShape.circle,
      border: Border.all(
        color: isDark
            ? RadioColors.whiteWithOpacity(0.15)
            : RadioColors.blackWithOpacity(0.1),
      ),
    );
  }

  // ══ ديكور شارة البث المباشر ══
  static BoxDecoration liveBadgeDecoration() {
    return BoxDecoration(
      border: Border.all(color: RadioColors.goldWithOpacity(0.4)),
      borderRadius: BorderRadius.circular(20),
      color: RadioColors.goldWithOpacity(0.08),
    );
  }

  // ══ ديكور Tab Bar ══
  static BoxDecoration tabBarContainerDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? RadioColors.whiteWithOpacity(0.07)
          : RadioColors.blackWithOpacity(0.06),
      borderRadius: borderRadiusLarge,
    );
  }

  static BoxDecoration tabBarIndicatorDecoration(Color primary) {
    return BoxDecoration(
      gradient: RadioColors.primaryGradient(primary),
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.35),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ══ ديكور المشغل السفلي ══
  static BoxDecoration bottomPlayerDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: RadioColors.playerBackground(context),
      borderRadius: borderRadiusPlayer,
      border: Border(
        top: BorderSide(
          color: isDark
              ? RadioColors.whiteWithOpacity(0.08)
              : RadioColors.blackWithOpacity(0.08),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: RadioColors.blackWithOpacity(isDark ? 0.7 : 0.12),
          blurRadius: 30,
          offset: const Offset(0, -8),
        ),
      ],
    );
  }

  // ══ ديكور زر المفضلة ══
  static BoxDecoration favoriteButtonDecoration({double opacity = 0.35}) {
    return BoxDecoration(
      color: RadioColors.blackWithOpacity(opacity),
      shape: BoxShape.circle,
    );
  }

  // ══ ديكور شارة التصنيف ══
  static BoxDecoration categoryBadgeDecoration() {
    return BoxDecoration(
      color: RadioColors.blackWithOpacity(0.4),
      borderRadius: borderRadiusSmall,
    );
  }

  // ══ ديكور الصورة البديلة (Fallback) ══
  static BoxDecoration fallbackImageDecoration(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
  }

  // ══ ديكور Equalizer في المشغل ══
  static BoxDecoration equalizerOverlayDecoration() {
    return BoxDecoration(
      color: RadioColors.blackWithOpacity(0.5),
    );
  }
}

/// ══ أحجام متجاوبة ══
class RadioSizes {
  RadioSizes._();

  /// حجم بطاقة Featured
  static double featuredCardHeight(bool isTablet) => isTablet ? 200.0 : 175.0;
  static double featuredCardWidth(bool isTablet) => isTablet ? 160.0 : 140.0;

  /// حجم صورة المحطة
  static double stationImageHeight(double screenHeight) =>
      (screenHeight * 0.19).clamp(90.0, 300.0);

  /// حجم صورة المشغل
  static double playerImageSize(bool isTablet) => isTablet ? 52.0 : 46.0;

  /// حجم زر التشغيل الرئيسي
  static double mainPlayButtonSize(bool isTablet) => isTablet ? 50.0 : 44.0;

  /// حجم زر التحكم
  static double controlButtonSize(bool isTablet) => isTablet ? 36.0 : 32.0;

  /// حجم زر الرجوع
  static const double backButtonSize = 40.0;

  /// حجم زر المفضلة (Featured)
  static const double favoriteButtonSizeFeatured = 28.0;

  /// حجم زر المفضلة (Station)
  static const double favoriteButtonSizeStation = 27.0;

  /// حجم زر التشغيل الصغير
  static const double smallPlayButtonSize = 30.0;

  /// ارتفاع Tab Bar
  static double tabBarHeight(bool isTablet) => isTablet ? 50.0 : 44.0;

  /// خط الفونت المتجاوب
  static double headerFontSize(bool isTablet) => isTablet ? 36.0 : 30.0;
  static double subtitleFontSize(bool isTablet) => isTablet ? 14.0 : 12.0;
  static double sectionTitleSize(bool isTablet) => isTablet ? 17.0 : 15.0;
  static double tabFontSize(bool isTablet) => isTablet ? 13.0 : 11.0;
  static double playerNameSize(bool isTablet) => isTablet ? 13.0 : 12.0;
  static double featuredNameSize(bool isTablet) => isTablet ? 13.0 : 11.5;
}