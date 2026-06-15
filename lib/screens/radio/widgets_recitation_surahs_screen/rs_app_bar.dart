// lib/screens/radio/widgets_surahs/rs_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// AppBar شاشة السور
/// ══════════════════════════════════════════════════════════════
class RsAppBar extends StatelessWidget {
  final String stationName;
  final VoidCallback onBack;

  const RsAppBar({
    super.key,
    required this.stationName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          // ══ زر الرجوع ══
          _buildBackButton(context),
          const SizedBox(width: 12),

          // ══ العنوان ══
          Expanded(child: _buildTitle(context)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // زر الرجوع
  // ══════════════════════════════════════════════════════════════
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: RsSizes.appBarBtnSize,
        height: RsSizes.appBarBtnSize,
        decoration: RsShapes.appBarBtn(context),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: RsColors.iconColor(context), // ✅ من RsColors
          size: 17,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // العنوان والعنوان الفرعي
  // ══════════════════════════════════════════════════════════════
  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ══ اسم المحطة ══
        Text(
          stationName,
          style: GoogleFonts.cairo(
            fontSize: RsSizes.appBarTitleSize,
            fontWeight: FontWeight.w900,
            color: RsColors.textPrimary(context), // ✅ من RsColors
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // ══ العنوان الفرعي ══
        Text(
          'اختر سورة للاستماع',
          style: GoogleFonts.cairo(
            fontSize: RsSizes.appBarSubtitleSize,
            color: RsColors.textHint(context), // ✅ من RsColors
          ),
        ),
      ],
    );
  }
}