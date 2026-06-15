// lib/screens/radio/widgets/category_section_widge.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'section_header_widget.dart';
import 'station_card_widget.dart';

/// ══════════════════════════════════════════════════════════════
/// قسم تصنيف (بطاقات صغيرة أفقية)
/// ══════════════════════════════════════════════════════════════
class CategorySectionWidge extends StatelessWidget {
  final String category;
  final List<IslamicRadioStation> stations;
  final Color primary;
  final bool isTablet;
  final AnimationController equalizerController;
  final VoidCallback onStationPlayed;

  const CategorySectionWidge({
    super.key,
    required this.category,
    required this.stations,
    required this.primary,
    required this.isTablet,
    required this.equalizerController,
    required this.onStationPlayed,
  });

  @override
  Widget build(BuildContext context) {
    final icon = RadioColors.getIconForCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 22),
        SectionHeaderWidget(
          title: '$icon $category',
          isTablet: isTablet,
          stations: stations,
          category: category,
          categoryIcon: icon,
          primary: primary,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(right: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stations
                .map(
                  (station) => StationCardWidget(
                station: station,
                primary: primary,
                isTablet: isTablet,
                equalizerController: equalizerController,
                onPlayed: onStationPlayed,
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}