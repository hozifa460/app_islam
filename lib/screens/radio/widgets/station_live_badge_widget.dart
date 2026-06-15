// lib/screens/radio/widgets/station_live_badge_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';

class StationLiveBadgeWidget extends StatelessWidget {
  final bool isActive;
  final bool alwaysShow;
  final AnimationController? controller;

  const StationLiveBadgeWidget({
    super.key,
    required this.isActive,
    this.alwaysShow = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!alwaysShow && !isActive) {
      return const SizedBox.shrink();
    }

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: RadioColors.blackWithOpacity(0.5),
        border: Border.all(
          color: RadioColors.goldWithOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(),
          const SizedBox(width: 3),
          Text(
            'LIVE',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: RadioColors.gold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (controller == null || !isActive) return child;

    return AnimatedBuilder(
      animation: controller!,
      builder: (_, __) => child,
    );
  }

  Widget _buildDot() {
    final opacity = controller == null || !isActive
        ? 1.0
        : 0.45 + 0.55 * sin(controller!.value * 2 * pi);

    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(opacity * 0.45),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}