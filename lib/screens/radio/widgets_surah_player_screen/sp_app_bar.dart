// lib/screens/radio/widgets_surah_player/sp_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// AppBar المشغل
/// ══════════════════════════════════════════════════════════════
class SpAppBar extends StatelessWidget {
  final bool isDark;
  final bool isTablet;
  final bool isOnline;
  final String stationName;
  final VoidCallback onBack;
  final VoidCallback onOptions;

  const SpAppBar({
    super.key,
    required this.isDark,
    required this.isTablet,
    required this.isOnline,
    required this.stationName,
    required this.onBack,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final btnSize = SpSizes.appBarBtnSize(isTablet);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpSizes.appBarPadding(isTablet),
        SpSizes.appBarTopPadding(isTablet),
        SpSizes.appBarPadding(isTablet),
        0,
      ),
      child: Row(
        children: [
          // ══ زر الرجوع ══
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: SpShapes.appBarBtn(isDark),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: SpColors.iconColor(isDark),
                size: SpSizes.appBarIconSize(isTablet),
              ),
            ),
          ),

          const Spacer(),

          // ══ العنوان ══
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? '🌐 استماع مباشر' : '📱 تشغيل محلي',
                  style: GoogleFonts.cairo(
                    fontSize: SpSizes.appBarSubtitleSize(isTablet),
                    color: SpColors.textTertiary(isDark),
                  ),
                ),
                Text(
                  stationName,
                  style: GoogleFonts.cairo(
                    fontSize: SpSizes.appBarTitleSize(isTablet),
                    fontWeight: FontWeight.w700,
                    color: SpColors.textPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Spacer(),

          // ══ زر الخيارات ══
          GestureDetector(
            onTap: onOptions,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: SpShapes.appBarBtn(isDark),
              child: Icon(
                Icons.more_vert_rounded,
                color: SpColors.iconColor(isDark),
                size: isTablet ? 22 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}