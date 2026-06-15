// lib/screens/radio/widgets_radio_screen/mini_equalizer_widget.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_animations.dart';

class MiniEqualizerWidget extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final int barCount;
  final double barWidth;
  final double barSpacing;
  final double minHeight;
  final double maxAdditionalHeight;

  const MiniEqualizerWidget({
    super.key,
    required this.controller,
    required this.color,
    this.barCount = 4,
    this.barWidth = 2.5,
    this.barSpacing = 0.8,
    this.minHeight = 3.0,
    this.maxAdditionalHeight = 9.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(barCount, (i) {
              final h = RadioEqualizerBar.calculateHeight(
                animationValue: controller.value,
                barIndex: i,
                minHeight: minHeight,
                maxAdditionalHeight: maxAdditionalHeight,
              );
              return Container(
                width: barWidth,
                height: h,
                margin: EdgeInsets.symmetric(horizontal: barSpacing),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}