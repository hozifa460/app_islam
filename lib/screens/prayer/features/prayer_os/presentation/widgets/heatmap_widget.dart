import 'package:flutter/material.dart';

class PrayerHeatmap extends StatelessWidget {
  const PrayerHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(30, (i) {
        return Container(
          width: 14,
          height: 14,
          color: Colors.green.withOpacity((i % 5) / 5),
        );
      }),
    );
  }
}