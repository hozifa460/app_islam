// lib/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart

import 'package:flutter/material.dart';
import 'rec_colors.dart';

class RecShapes {
  RecShapes._();

  // ══ Border Radius ══
  static BorderRadius get radiusSmall => BorderRadius.circular(10);
  static BorderRadius get radiusMedium => BorderRadius.circular(12);
  static BorderRadius get radiusLarge => BorderRadius.circular(14);
  static BorderRadius get radiusXLarge => BorderRadius.circular(16);
  static BorderRadius get radiusCategory => BorderRadius.circular(10);
  static BorderRadius get radiusCard => BorderRadius.circular(12);
  static BorderRadius get radiusSearch => BorderRadius.circular(12);
  static BorderRadius get radiusReciterItem => BorderRadius.circular(16);

  static BorderRadius get radiusCardBottom =>
      const BorderRadius.vertical(bottom: Radius.circular(12));

  // ══ Mini Player ══
  static BoxDecoration miniPlayer(BuildContext context, Color primary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: RecColors.miniPlayerGradient(context, primary),
      borderRadius: radiusLarge,
      border: Border.all(
        color: RecColors.miniPlayerBorder(context, primary),
      ),
    );
  }

  static BoxDecoration miniPlayerIcon(BuildContext context, Color primary) {
    return BoxDecoration(
      color: primary.withOpacity(
        _isDark(context) ? 0.2 : 0.12,
      ),
      borderRadius: radiusCategory,
    );
  }

  static BoxDecoration miniPlayerPlayBtn(Color primary) => BoxDecoration(
    color: primary,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ══ أيقونة التصنيف ══
  static BoxDecoration categoryIcon(List<Color> gradientColors) =>
      BoxDecoration(
        gradient: RecColors.categoryIconGradient(gradientColors),
        borderRadius: radiusCategory,
      );

  // ══ زر التشغيل على البطاقة ══
  static BoxDecoration cardPlayButton({
    required bool hasStation,
    required Color gold,
  }) =>
      BoxDecoration(
        color: hasStation ? gold : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      );

  // ══ زر الرجوع ══
  static BoxDecoration backButton(BuildContext context) {
    return BoxDecoration(
      color: _isDark(context)
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.06),
      shape: BoxShape.circle,
      border: Border.all(
        color: _isDark(context)
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.1),
      ),
    );
  }

  // ══ شريط البحث ══
  static BoxDecoration searchBar(BuildContext context, Color primary) {
    return BoxDecoration(
      color: RecColors.searchBackground(context),
      borderRadius: radiusSearch,
      border: Border.all(
        color: RecColors.searchBorder(context, primary),
      ),
    );
  }

  // ══ عنصر القارئ ══
  static BoxDecoration reciterItem({
    required bool hasDownloads,
    required Color primary,
    BuildContext? context,
  }) {
    if (context != null) {
      return BoxDecoration(
        color: RecColors.itemBackground(
          context,
          isActive: hasDownloads,
          primary: primary,
        ),
        borderRadius: radiusReciterItem,
        border: Border.all(
          color: RecColors.itemBorder(
            context,
            isActive: hasDownloads,
            primary: primary,
          ),
        ),
      );
    }

    // Fallback بدون context
    return BoxDecoration(
      color: hasDownloads
          ? primary.withOpacity(0.1)
          : Colors.white.withOpacity(0.06),
      borderRadius: radiusReciterItem,
      border: Border.all(
        color: hasDownloads
            ? primary.withOpacity(0.3)
            : Colors.white.withOpacity(0.08),
      ),
    );
  }

  // ══ سهم القارئ ══
  static BoxDecoration reciterArrow(Color primary) => BoxDecoration(
    color: primary.withOpacity(0.15),
    shape: BoxShape.circle,
  );

  // ══ مساعد ══
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

/// ══ أحجام متجاوبة ══
class RecSizes {
  RecSizes._();

  static double imageHeight(double screenH) =>
      (screenH * 0.22).clamp(90.0, 300.0);

  static double detailImageHeight(double screenH) =>
      (screenH * 0.27).clamp(90.0, 300.0);

  static const double miniPlayerIconSize = 38.0;
  static const double miniPlayerPlayBtnSize = 34.0;
  static const double categoryIconSize = 36.0;
  static const double cardPlayBtnSize = 32.0;
  static const double backBtnSize = 40.0;
  static const double reciterArrowSize = 32.0;

  static double reciterImageSize(bool isTablet) => isTablet ? 54.0 : 48.0;
  static int gridCrossCount(bool isTablet) => isTablet ? 3 : 2;
  static double sectionTitleSize(bool isTablet) => isTablet ? 16.0 : 14.0;
  static double sectionSubtitleSize(bool isTablet) => isTablet ? 11.0 : 10.0;
  static double appBarTitleSize(bool isTablet) => isTablet ? 20.0 : 17.0;
}