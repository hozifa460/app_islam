// lib/screens/radio/widgets_surah_player/sp_shapes.dart

import 'package:flutter/material.dart';
import 'sp_colors.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط£ط´ظƒط§ظ„ ظˆط¯ظٹظƒظˆط±ط§طھ ظ…ط´ط؛ظ„ ط§ظ„ط³ظˆط±ط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class SpShapes {
  SpShapes._();

  // â•گâ•گ ط£ط²ط±ط§ط± ط¯ط§ط¦ط±ظٹط© â•گâ•گ
  static BoxDecoration circleBtn({
    required Color color,
    List<BoxShadow>? shadows,
    Border? border,
  }) =>
      BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shadows,
        border: border,
      );

  // â•گâ•گ ط²ط± AppBar â•گâ•گ
  static BoxDecoration appBarBtn(bool isDark) => circleBtn(
    color: SpColors.btnBg(isDark),
    shadows: [BoxShadow(color: SpColors.black(0.08), blurRadius: 8)],
  );

  // â•گâ•گ ط²ط± ط§ظ„طھط­ظƒظ… ط§ظ„طµط؛ظٹط± â•گâ•گ
  static BoxDecoration controlBtn(bool isDark) => circleBtn(
    color: SpColors.controlBtnBg(isDark),
    shadows: [BoxShadow(color: SpColors.black(0.07), blurRadius: 8)],
  );

  // â•گâ•گ ط²ط± ط§ظ„طھط´ط؛ظٹظ„ ط§ظ„ط±ط¦ظٹط³ظٹ â•گâ•گ
  static BoxDecoration mainPlayBtn(Color primary) => BoxDecoration(
    gradient: LinearGradient(
      colors: [primary, primary.withValues(alpha: 0.75)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.4),
        blurRadius: 22,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // â•گâ•گ ط²ط± ط§ظ„طھظƒط±ط§ط± â•گâ•گ
  static BoxDecoration loopBtn({
    required bool isLooping,
    required Color primary,
    required bool isDark,
  }) =>
      BoxDecoration(
        color: isLooping
            ? primary.withValues(alpha: 0.15)
            : SpColors.controlBtnBg(isDark),
        shape: BoxShape.circle,
        border:
        isLooping ? Border.all(color: primary.withValues(alpha: 0.3)) : null,
      );

  // â•گâ•گ ط²ط± ط¥ط¶ط§ظپظٹ â•گâ•گ
  static BoxDecoration extraBtn({
    required bool isActive,
    required Color primary,
    required bool isDark,
  }) =>
      BoxDecoration(
        color: isActive
            ? primary.withValues(alpha: 0.15)
            : SpColors.extraBtnBg(isDark),
        shape: BoxShape.circle,
        border:
        isActive ? Border.all(color: primary.withValues(alpha: 0.3)) : null,
      );

  // â•گâ•گ ط¨ط§ط¯ط¬ ط§ظ„ظˆط¶ط¹ â•گâ•گ
  static BoxDecoration modeBadge(bool isOnline) => BoxDecoration(
    color: SpColors.modeBgColor(isOnline),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: SpColors.modeBorderColor(isOnline)),
  );

  // â•گâ•گ ط²ط± طھط­ظ…ظٹظ„ ظپظٹ ط§ظ„ط¨ط§ط¯ط¬ â•گâ•گ
  static BoxDecoration downloadBadgeBtn(Color primary) => BoxDecoration(
    color: primary.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(10),
  );

  // â•گâ•گ ط؛ظ„ط§ظپ ط§ظ„ط£ظ„ط¨ظˆظ… â•گâ•گ
  static BoxDecoration albumArt({
    required Color primary,
    required bool isPlaying,
  }) =>
      BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primary.withValues(alpha: 0.25),
            primary.withValues(alpha: 0.12),
            SpColors.goldOp(0.08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isPlaying ? 0.3 : 0.15),
            blurRadius: isPlaying ? 50 : 30,
            spreadRadius: isPlaying ? 5 : 0,
          ),
          BoxShadow(
            color: SpColors.black(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      );

  // â•گâ•گ ط¯ط§ط¦ط±ط© ط²ط®ط±ظپظٹط© ط¯ط§ط®ظ„ ط§ظ„ط£ظ„ط¨ظˆظ… â•گâ•گ
  static BoxDecoration albumDecorCircle(Color primary, int index) =>
      BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primary.withValues(alpha: 0.07 - index * 0.02),
        ),
      );

  // â•گâ•گ ط­ط§ظˆظٹط© ظ‚ط§ط¦ظ…ط© ط§ظ„ط³ظˆط± â•گâ•گ
  static BoxDecoration playlistContainer({
    required Color primary,
    required bool isDark,
  }) =>
      BoxDecoration(
        color: SpColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      );

  // â•گâ•گ ط¹ظ†طµط± ط³ظˆط±ط© ظپظٹ ط§ظ„ظ‚ط§ط¦ظ…ط© â•گâ•گ
  static BoxDecoration playlistItem({
    required bool isCurrent,
    required Color primary,
  }) =>
      BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.8)],
        )
            : null,
        color: isCurrent ? null : primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? primary : primary.withValues(alpha: 0.12),
        ),
        boxShadow: isCurrent
            ? [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      );

  // â•گâ•گ ط­ط§ظˆظٹط© ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ ط£ظˆظ†ظ„ط§ظٹظ† â•گâ•گ
  static BoxDecoration onlineInfoBox(bool isDark) => BoxDecoration(
    color: Colors.blue.withValues(alpha: isDark ? 0.08 : 0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
  );

  // â•گâ•گ Options Sheet â•گâ•گ
  static BoxDecoration optionsSheet(bool isDark) => BoxDecoration(
    color: isDark ? SpColors.darkSheet : Colors.white,
    borderRadius:
    const BorderRadius.vertical(top: Radius.circular(24)),
  );

  // â•گâ•گ ط¹ظ†طµط± ط®ظٹط§ط± â•گâ•گ
  static BoxDecoration optionItem(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.07),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: color.withValues(alpha: 0.12)),
  );

  // â•گâ•گ ظ…ظ‚ط¨ط¶ ط§ظ„ظ€ Sheet â•گâ•گ
  static BoxDecoration sheetHandle() => BoxDecoration(
    color: SpColors.grey(0.3),
    borderRadius: BorderRadius.circular(2),
  );
}

/// â•گâ•گ ط£ط­ط¬ط§ظ… ظ…طھط¬ط§ظˆط¨ط© â•گâ•گ
class SpSizes {
  SpSizes._();

  // â•گâ•گ ط؛ظ„ط§ظپ ط§ظ„ط£ظ„ط¨ظˆظ… â•گâ•گ
  static double albumArtSize(double screenWidth, bool isTablet) =>
      isTablet ? screenWidth * 0.5 : screenWidth * 0.62;

  // â•گâ•گ ط£ط²ط±ط§ط± AppBar â•گâ•گ
  static double appBarBtnSize(bool isTablet) => isTablet ? 44.0 : 38.0;
  static double appBarIconSize(bool isTablet) => isTablet ? 26.0 : 22.0;

  // â•گâ•گ ط£ط²ط±ط§ط± ط§ظ„طھط­ظƒظ… â•گâ•گ
  static double mainPlayBtnSize(bool isTablet) => isTablet ? 72.0 : 64.0;
  static double mainPlayIconSize(bool isTablet) => isTablet ? 36.0 : 32.0;
  static double skipBtnSize(bool isTablet) => isTablet ? 50.0 : 44.0;
  static double skipIconSize(bool isTablet) => isTablet ? 26.0 : 22.0;
  static double seekBtnSize(bool isTablet) => isTablet ? 46.0 : 40.0;
  static double seekIconSize(bool isTablet) => isTablet ? 22.0 : 19.0;

  // â•گâ•گ ط²ط± ط§ظ„طھظƒط±ط§ط± â•گâ•گ
  static double loopBtnSize(bool isTablet) => isTablet ? 42.0 : 38.0;
  static double loopIconSize(bool isTablet) => isTablet ? 20.0 : 18.0;

  // â•گâ•گ ط£ط²ط±ط§ط± ط¥ط¶ط§ظپظٹط© â•گâ•گ
  static double extraBtnSize(bool isTablet) => isTablet ? 48.0 : 42.0;
  static double extraIconSize(bool isTablet) => isTablet ? 22.0 : 19.0;

  // â•گâ•گ ط§ط±طھظپط§ط¹ Playlist â•گâ•گ
  static double playlistHeight(bool isTablet) => isTablet ? 90.0 : 78.0;

  // â•گâ•گ ظپظˆظ†طھ â•گâ•گ
  static double surahNameSize(bool isTablet) => isTablet ? 24.0 : 20.0;
  static double surahDetailSize(bool isTablet) => isTablet ? 13.0 : 11.0;
  static double appBarTitleSize(bool isTablet) => isTablet ? 14.0 : 12.0;
  static double appBarSubtitleSize(bool isTablet) => isTablet ? 12.0 : 10.0;
  static double timeSize(bool isTablet) => isTablet ? 13.0 : 11.0;
  static double extraLabelSize(bool isTablet) => isTablet ? 11.0 : 10.0;
  static double playlistTitleSize(bool isTablet) => isTablet ? 12.0 : 11.0;
  static double playlistCountSize(bool isTablet) => isTablet ? 11.0 : 10.0;
  static double playlistItemSize(bool isTablet) => isTablet ? 13.0 : 12.0;
  static double onlineInfoSize(bool isTablet) => isTablet ? 12.0 : 11.0;
  static double onlineIconSize(bool isTablet) => isTablet ? 20.0 : 17.0;

  // â•گâ•گ Padding â•گâ•گ
  static double horizontalPadding(bool isTablet) => isTablet ? 32.0 : 24.0;
  static double controlsPadding(bool isTablet) => isTablet ? 28.0 : 20.0;
  static double progressPadding(bool isTablet) => isTablet ? 28.0 : 22.0;
  static double appBarPadding(bool isTablet) => isTablet ? 24.0 : 18.0;
  static double appBarTopPadding(bool isTablet) => isTablet ? 14.0 : 10.0;
  static double playlistMargin(bool isTablet) => isTablet ? 20.0 : 14.0;

  // â•گâ•گ Slider â•گâ•گ
  static double trackHeight(bool isTablet) => isTablet ? 5.0 : 4.0;
  static double thumbRadius(bool isTablet) => isTablet ? 7.0 : 6.0;
  static double overlayRadius(bool isTablet) => isTablet ? 16.0 : 14.0;
}