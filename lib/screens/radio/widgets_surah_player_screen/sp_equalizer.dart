// lib/screens/radio/widgets_surah_player/sp_equalizer.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// Equalizer المشغل (7 أشرطة)
/// ══════════════════════════════════════════════════════════════
class SpEqualizer extends StatelessWidget {
  final AnimationController controller;
  final Color primary;

  const SpEqualizer({
    super.key,
    required this.controller,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) {
            final phase = controller.value * 2 * pi + i * 0.5;
            final h = 4.0 + 14.0 * ((sin(phase) + 1) / 2);
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, SpColors.goldOp(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}