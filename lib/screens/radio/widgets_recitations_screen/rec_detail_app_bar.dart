// lib/screens/radio/widgets_recitations/rec_detail_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// AppBar شاشة تفاصيل التصنيف
/// ══════════════════════════════════════════════════════════════
class RecDetailAppBar extends StatelessWidget {
  final RecitationCategory category;
  final bool isTablet;
  final VoidCallback onBack;

  const RecDetailAppBar({
    super.key,
    required this.category,
    required this.isTablet,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 12),
          Expanded(child: _buildTitleColumn(context)),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: RecSizes.backBtnSize,
        height: RecSizes.backBtnSize,
        decoration: RecShapes.backButton(context),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: RecColors.iconColor(context),
          size: 17,
        ),
      ),
    );
  }

  Widget _buildTitleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${category.emoji} ${category.title}',
          style: GoogleFonts.cairo(
            fontSize: RecSizes.appBarTitleSize(isTablet),
            fontWeight: FontWeight.w900,
            color: RecColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${category.items.length} عنصر',
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: RecColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}