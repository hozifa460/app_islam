// lib/screens/radio/widgets_radio_screen/live_badge_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';

class LiveBadgeWidget extends StatefulWidget {
  final bool isPlaying;
  final bool showWhenStopped;

  const LiveBadgeWidget({
    super.key,
    required this.isPlaying,
    this.showWhenStopped = false,
  });

  @override
  State<LiveBadgeWidget> createState() => _LiveBadgeWidgetState();
}

class _LiveBadgeWidgetState extends State<LiveBadgeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && !widget.showWhenStopped) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final opacity = widget.isPlaying
            ? 0.4 + 0.6 * _controller.value
            : 1.0;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: RadioColors.blackWithOpacity(0.5),
            border: Border.all(
              color: RadioColors.goldWithOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(opacity),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(opacity * 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: RadioColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}