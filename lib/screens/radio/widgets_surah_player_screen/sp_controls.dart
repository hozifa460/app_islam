// lib/screens/radio/widgets_surah_player_screen/sp_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

class SpControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool isDark;
  final bool isTablet;
  final Color primary;
  final Duration position;
  final Duration duration;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<Duration> onSeek;

  const SpControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.isDark,
    required this.isTablet,
    required this.primary,
    required this.position,
    required this.duration,
    required this.onTogglePlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SpSizes.controlsPadding(isTablet),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            isDark: isDark,
            size: SpSizes.skipBtnSize(isTablet),
            iconSize: SpSizes.skipIconSize(isTablet),
            onTap: () {
              HapticFeedback.lightImpact();
              onPrevious();
            },
          ),

          _ControlButton(
            icon: Icons.replay_10_rounded,
            isDark: isDark,
            size: SpSizes.seekBtnSize(isTablet),
            iconSize: SpSizes.seekIconSize(isTablet),
            onTap: () {
              HapticFeedback.selectionClick();
              final newPos = position - const Duration(seconds: 10);
              onSeek(newPos < Duration.zero ? Duration.zero : newPos);
            },
          ),

          _MainPlayButton(
            isPlaying: isPlaying,
            isLoading: isLoading,
            isTablet: isTablet,
            primary: primary,
            onTap: isLoading
                ? null
                : () {
              HapticFeedback.mediumImpact();
              onTogglePlayPause();
            },
          ),

          _ControlButton(
            icon: Icons.forward_10_rounded,
            isDark: isDark,
            size: SpSizes.seekBtnSize(isTablet),
            iconSize: SpSizes.seekIconSize(isTablet),
            onTap: () {
              HapticFeedback.selectionClick();
              final newPos = position + const Duration(seconds: 10);
              onSeek(newPos > duration ? duration : newPos);
            },
          ),

          _ControlButton(
            icon: Icons.skip_next_rounded,
            isDark: isDark,
            size: SpSizes.skipBtnSize(isTablet),
            iconSize: SpSizes.skipIconSize(isTablet),
            onTap: () {
              HapticFeedback.lightImpact();
              onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.isDark,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: SpShapes.controlBtn(isDark),
        child: Icon(
          icon,
          size: iconSize,
          color: SpColors.iconColor(isDark),
        ),
      ),
    );
  }
}

class _MainPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool isTablet;
  final Color primary;
  final VoidCallback? onTap;

  const _MainPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.isTablet,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = SpSizes.mainPlayBtnSize(isTablet);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: SpShapes.mainPlayBtn(primary),
        child: isLoading
            ? Padding(
          padding: EdgeInsets.all(size * 0.25),
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: Colors.white,
            size: SpSizes.mainPlayIconSize(isTablet),
          ),
        ),
      ),
    );
  }
}