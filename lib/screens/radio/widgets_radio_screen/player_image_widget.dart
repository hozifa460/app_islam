// lib/screens/radio/widgets_radio_screen/player_image_widget.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import '../widgets/radio_image_widget.dart';
import 'mini_equalizer_widget.dart';

class PlayerImageWidget extends StatelessWidget {
  final String? imageUrl, imageAsset;
  final String emoji;
  final Color primary;
  final bool isPlaying;
  final AnimationController equalizerController;

  const PlayerImageWidget({
    super.key,
    this.imageUrl,
    this.imageAsset,
    required this.emoji,
    required this.primary,
    required this.isPlaying,
    required this.equalizerController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RadioImageWidget(
            imageUrl: imageUrl,
            imageAsset: imageAsset,
            emoji: emoji,
            primary: primary,
            size: 46,
            fit: BoxFit.cover,
            isActive: isPlaying,
          ),
        ),
        if (isPlaying)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: RadioColors.blackWithOpacity(0.5),
              ),
              child: Center(
                child: MiniEqualizerWidget(
                  controller: equalizerController,
                  color: RadioColors.gold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}