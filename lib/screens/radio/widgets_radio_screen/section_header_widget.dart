// lib/screens/radio/widgets/section_header_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/widgets/category_stations_screen.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// عنوان القسم مع زر "See all"
/// ══════════════════════════════════════════════════════════════
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final bool isTablet;
  final List<IslamicRadioStation>? stations;
  final String? category;
  final String? categoryIcon;
  final Color? primary;
  final bool showSeeAll;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.isTablet,
    this.stations,
    this.category,
    this.categoryIcon,
    this.primary,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: RadioSizes.sectionTitleSize(isTablet),
                fontWeight: FontWeight.w800,
                color: RadioColors.textPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showSeeAll && stations != null && stations!.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryStationsScreen(
                      category: category ?? title,
                      categoryIcon: categoryIcon ?? '🎵',
                      stations: stations!,
                      primaryColor: primary ?? const Color(0xFF2E7D52),
                    ),
                  ),
                );
              },
              child: Text(
                'See all',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: RadioColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}