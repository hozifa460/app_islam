import 'package:flutter/material.dart';
import 'tasbih_theme.dart';

class TasbihHeader extends StatelessWidget {
  const TasbihHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasbih', style: TasbihTheme.headerTitle),
            Text(
              'Electronic tasbih and prayer beads',
              style: TasbihTheme.headerSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}