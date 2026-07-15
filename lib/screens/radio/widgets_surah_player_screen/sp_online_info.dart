// lib/screens/radio/widgets_surah_player/sp_online_info.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط§ط³طھظ…ط§ط¹ ط§ظ„ط£ظˆظ†ظ„ط§ظٹظ†
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class SpOnlineInfo extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const SpOnlineInfo({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SpSizes.playlistMargin(isTablet),
      ),
      padding: const EdgeInsets.all(14),
      decoration: SpShapes.onlineInfoBox(isDark),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: SpSizes.onlineIconSize(isTablet),
            color: Colors.blue.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تستمع للسورة بدون تحميل. اضغط "تحميل" للاستماع بدون إنترنت لاحقاً.',
              style: GoogleFonts.cairo(
                fontSize: SpSizes.onlineInfoSize(isTablet),
                color: SpColors.textSecondary(isDark),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}