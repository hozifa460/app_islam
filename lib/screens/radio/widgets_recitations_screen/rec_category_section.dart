// lib/screens/radio/widgets_recitations/rec_category_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_category_detail_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';
import 'rec_item_card.dart';

/// ══════════════════════════════════════════════════════════════
/// قسم التصنيف (Header + بطاقات أفقية)
/// ══════════════════════════════════════════════════════════════
class RecCategorySection extends StatelessWidget {
  final RecitationCategory category;
  final Color primary;
  final bool isTablet;

  const RecCategorySection({
    super.key,
    required this.category,
    required this.primary,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        _buildHeader(context),
        _buildHorizontalList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _buildCategoryIcon(),
          const SizedBox(width: 10),
          Expanded(child: _buildTitleColumn(context)),
          _buildSeeAllButton(context),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: RecSizes.categoryIconSize,
      height: RecSizes.categoryIconSize,
      decoration: RecShapes.categoryIcon(category.gradientColors),
      child: Center(
        child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildTitleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          category.title,
          style: GoogleFonts.cairo(
            fontSize: RecSizes.sectionTitleSize(isTablet),
            fontWeight: FontWeight.w800,
            color: RecColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          category.description,
          style: GoogleFonts.cairo(
            fontSize: RecSizes.sectionSubtitleSize(isTablet),
            color: RecColors.textSecondary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSeeAllButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecCategoryDetailScreen(
              category: category,
              primary: primary,
            ),
          ),
        );
      },
      child: Text(
        'See all',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: RecColors.gold,
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: category.items.take(6).map((item) => RecItemCard(
          item: item,
          primary: primary,
          gradientColors: category.gradientColors,
          isTablet: isTablet,
        )).toList(),
      ),
    );
  }
}