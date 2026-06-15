// lib/screens/radio/widgets/hero_header_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/radio_data.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// هيدر الشاشة الرئيسي (العنوان + الوصف + شارة البث)
/// ══════════════════════════════════════════════════════════════
class HeroHeaderWidget extends StatelessWidget {
  final Color primary;
  final bool isTablet;

  const HeroHeaderWidget({
    super.key,
    required this.primary,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isTablet ? 18 : 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitle(context),
          const SizedBox(height: 6),
          _buildSubtitle(context),
          const SizedBox(height: 14),
          _buildLiveBadge(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final fontSize = RadioSizes.headerFontSize(isTablet);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'الراديو ',
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: RadioColors.headerTitle(context),
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'الإسلامي',
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: RadioColors.gold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'تلاوات خاشعة • أذكار • بث مباشر',
      textAlign: TextAlign.center,
      style: GoogleFonts.cairo(
        fontSize: RadioSizes.subtitleFontSize(isTablet),
        color: RadioColors.headerSubtitle(context),
      ),
    );
  }

  Widget _buildLiveBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: RadioShapes.liveBadgeDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${RadioStationsData.all.length} محطة • بث مباشر',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: RadioColors.gold,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}