// lib/screens/radio/widgets_radio_screen/favorites_section_widget.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:provider/provider.dart';
import 'section_header_widget.dart';
import 'station_card_widget.dart';

class FavoritesSectionWidget extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final AnimationController equalizerController;
  final VoidCallback onStationPlayed;

  const FavoritesSectionWidget({
    super.key,
    required this.primary,
    required this.isTablet,
    required this.equalizerController,
    required this.onStationPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<RadioIntillegence, List<IslamicRadioStation>>(
      selector: (_, radio) => radio.favoriteStations,
      shouldRebuild: (prev, next) =>
      prev.length != next.length ||
          !prev.every((s) => next.any((n) => n.id == s.id)),
      builder: (_, favs, __) {
        if (favs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 22),
            SectionHeaderWidget(
              title: '❤️ المفضلة',
              isTablet: isTablet,
              stations: favs,
              category: 'المفضلة',
              categoryIcon: '❤️',
              primary: primary,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: favs
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
      },
    );
  }
}