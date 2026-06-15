// lib/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart

import 'package:flutter/material.dart';
import 'rs_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// أشكال وديكورات شاشة السور
/// ══════════════════════════════════════════════════════════════
class RsShapes {
  RsShapes._();

  // ══ Border Radius ══
  static BorderRadius get radiusSmall => BorderRadius.circular(8);
  static BorderRadius get radiusMedium => BorderRadius.circular(12);
  static BorderRadius get radiusLarge => BorderRadius.circular(14);
  static BorderRadius get radiusXLarge => BorderRadius.circular(16);
  static BorderRadius get radiusCard => BorderRadius.circular(18);
  static BorderRadius get radiusSheet =>
      const BorderRadius.vertical(top: Radius.circular(24));

  // ══════════════════════════════════════════════════════════════
  // زر AppBar
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration appBarBtn(BuildContext context) => BoxDecoration(
    color: RsColors.appBarIconBg(context),       // ✅ من RsColors
    shape: BoxShape.circle,
    border: Border.all(
      color: RsColors.iconBorder(context),        // ✅ من RsColors
    ),
  );

  // ══════════════════════════════════════════════════════════════
  // Header القارئ
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration reciterHeader(
      Color primary,
      BuildContext context,       // ✅ context بدلاً من isDark
      ) =>
      BoxDecoration(
        gradient: RsColors.reciterHeaderGradient(primary, context),
        borderRadius: radiusCard,
        border: Border.all(
          color: RsColors.primary(primary, 0.12), // ✅ من RsColors
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // أيقونة القارئ
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration reciterIcon(Color primary) => BoxDecoration(
    gradient: RsColors.reciterIconGradient(primary),
    borderRadius: BorderRadius.circular(15),
  );

  // ══════════════════════════════════════════════════════════════
  // Stat Chip
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration statChip(Color color) => BoxDecoration(
    color: RsColors.primary(color, 0.1),         // ✅ من RsColors
    borderRadius: radiusSmall,
    border: Border.all(
      color: RsColors.primary(color, 0.2),       // ✅ من RsColors
    ),
  );

  // ══════════════════════════════════════════════════════════════
  // شريط تقدم التحميل
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration progressBar() => BoxDecoration(
    borderRadius: BorderRadius.circular(6),
  );

  // ══════════════════════════════════════════════════════════════
  // زر إلغاء التحميل
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration cancelBtn() => BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  );

  // ══════════════════════════════════════════════════════════════
  // زر تشغيل الراديو
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration radioPlayBtn(Color primary) => BoxDecoration(
    gradient: RsColors.radioPlayBtnGradient(primary),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: RsColors.primary(primary, 0.3),   // ✅ من RsColors
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  // ══════════════════════════════════════════════════════════════
  // Mini Player
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration miniPlayer(
      Color primary,
      BuildContext context,       // ✅ context بدلاً من isDark
      ) =>
      BoxDecoration(
        gradient: RsColors.miniPlayerGradient(primary, context),
        borderRadius: radiusLarge,
        border: Border.all(
          color: RsColors.primary(primary, 0.2),     // ✅ من RsColors
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // زر تشغيل Mini Player
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration miniPlayerPlayBtn(Color primary) => BoxDecoration(
    color: primary,
    shape: BoxShape.circle,
  );

  // ══════════════════════════════════════════════════════════════
  // شريط البحث
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration searchBar(
      Color primary,
      BuildContext context,       // ✅ context للتكيف مع الوضع
      ) =>
      BoxDecoration(
        color: RsColors.searchBackground(context),   // ✅ من RsColors
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RsColors.searchBorder(context, primary), // ✅ من RsColors
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // بطاقة السورة
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration surahTile({
    required bool isCurrentSurah,
    required bool isDownloaded,
    required bool isDark,
    required Color cardColor,
    required Color primary,
  }) =>
      BoxDecoration(
        color: RsColors.surahTileBg(
          isCurrentSurah: isCurrentSurah,
          isDownloaded: isDownloaded,
          isDark: isDark,
          cardColor: cardColor,
          primary: primary,
        ),
        borderRadius: radiusLarge,
        border: Border.all(
          color: RsColors.surahTileBorder(
            isCurrentSurah: isCurrentSurah,
            isDownloaded: isDownloaded,
            isDark: isDark,
            primary: primary,
          ),
          width: isCurrentSurah ? 1.2 : 0.5,
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // زر تحميل السورة
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration surahDownloadBtn(Color primary) => BoxDecoration(
    color: RsColors.primary(primary, 0.08),      // ✅ من RsColors
    borderRadius: radiusSmall,
    border: Border.all(
      color: RsColors.primary(primary, 0.15),    // ✅ من RsColors
    ),
  );

  // ══════════════════════════════════════════════════════════════
  // زر تشغيل السورة
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration surahPlayBtn({
    required bool isCurrentSurah,
    required Color primary,
  }) =>
      BoxDecoration(
        gradient: isCurrentSurah
            ? RsColors.surahPlayBtnGradient(primary)
            : null,
        color: isCurrentSurah
            ? null
            : RsColors.primary(primary, 0.1),       // ✅ من RsColors
        shape: BoxShape.circle,
        boxShadow: isCurrentSurah
            ? [
          BoxShadow(
            color: RsColors.primary(primary, 0.3), // ✅ من RsColors
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      );

  // ══════════════════════════════════════════════════════════════
  // FAB
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration fab(Color primary) => BoxDecoration(
    gradient: RsColors.fabGradient(primary),
    borderRadius: radiusXLarge,
    boxShadow: [
      BoxShadow(
        color: RsColors.primary(primary, 0.4),   // ✅ من RsColors
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ══════════════════════════════════════════════════════════════
  // Options Sheet
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration downloadSheet(BuildContext context) => BoxDecoration(
    color: RsColors.sheetBackground(context),    // ✅ من RsColors
    borderRadius: radiusSheet,
  );

  // ══════════════════════════════════════════════════════════════
  // زر تحميل في الـ Sheet
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration downloadSheetBtn(Color primary) => BoxDecoration(
    gradient: RsColors.downloadBtnGradient(primary),
    borderRadius: radiusLarge,
  );

  // ══════════════════════════════════════════════════════════════
  // مقبض الـ Sheet
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration sheetHandle() => BoxDecoration(
    color: RsColors.grey(0.3),
    borderRadius: BorderRadius.circular(2),
  );
}

/// ══════════════════════════════════════════════════════════════
/// أحجام متجاوبة
/// ══════════════════════════════════════════════════════════════
class RsSizes {
  RsSizes._();

  // ══ AppBar ══
  static const double appBarBtnSize = 40.0;

  // ══ أيقونة القارئ ══
  static const double reciterIconSize = 50.0;

  // ══ Mini Player ══
  static const double miniPlayerPlayBtnSize = 36.0;
  static const double miniPlayerMusicIconSize = 20.0;

  // ══ زر السورة ══
  static const double surahPlayBtnSize = 36.0;

  // ══ فونت ══
  static const double appBarTitleSize = 16.0;
  static const double appBarSubtitleSize = 11.0;
  static const double statChipSize = 11.0;
  static const double searchHintSize = 12.0;
  static const double surahNameSize = 14.0;
  static const double surahDetailSize = 10.0;
  static const double surahNumSize = 12.0;
  static const double downloadBtnLabelSize = 10.0;
  static const double downloadIconSize = 13.0;
  static const double fabLabelSize = 14.0;
  static const double miniPlayerNameSize = 13.0;
  static const double miniPlayerTimeSize = 10.0;
  static const double radioPlayBtnSize = 13.0;
  static const double cancelBtnSize = 11.0;
  static const double downloadProgressSize = 11.0;
}