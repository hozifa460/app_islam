// lib/screens/radio/widgets/modern_bottom_player.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';
import 'package:provider/provider.dart';

import '../widgets_radio_screen/player_control_button.dart';
import '../widgets_radio_screen/player_image_widget.dart';

enum _BottomPlayerSource {
  online,
  onlineSurah,
  offline,
}

class ModernBottomPlayer extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final EdgeInsets safePadding;
  final AnimationController equalizerController;

  // âœ… ط£ط¨ظ‚ظٹظ†ط§ظ‡ط§ ط§ط®طھظٹط§ط±ظٹط© ظ„ظ„طھظˆط§ظپظ‚ ظ…ط¹ ط§ظ„ط§ط³طھط¯ط¹ط§ط،ط§طھ ط§ظ„ظ‚ط¯ظٹظ…ط©
  final RadioIntillegence? onlineService;
  final OfflineRadioService? offlineService;
  final OnlineSurahService? onlineSurahService;

  const ModernBottomPlayer({
    super.key,
    required this.primary,
    required this.isTablet,
    required this.safePadding,
    required this.equalizerController,
    this.onlineService,
    this.offlineService,
    this.onlineSurahService,
  });

  @override
  Widget build(BuildContext context) {
    return Selector3<RadioIntillegence, OfflineRadioService, OnlineSurahService,
        _BottomPlayerState?>(
      selector: (_, online, offline, onlineSurah) {
        // âœ… ط§ظ„ط£ظˆظ„ظˆظٹط©: online radio ط«ظ… online surah ط«ظ… offline
        if (online.currentStation != null) {
          return _BottomPlayerState(
            source: _BottomPlayerSource.online,
            name: online.currentStation!.name,
            emoji: online.currentStation!.iconEmoji,
            subtitle: online.currentStation!.category,
            imageUrl: online.currentStation!.imageUrl,
            imageAsset: online.currentStation!.imageAsset,
            isPlaying: online.isPlaying,
            isBuffering: online.isBuffering,
            isOnline: true,
          );
        }

        if (onlineSurah.currentStation != null) {
          return _BottomPlayerState(
            source: _BottomPlayerSource.onlineSurah,
            name: onlineSurah.currentSurahName,
            emoji: onlineSurah.currentStation?.iconEmoji ?? 'ًںژµ',
            subtitle: onlineSurah.currentStation?.name ?? '',
            imageUrl: onlineSurah.currentStation?.imageUrl,
            imageAsset: onlineSurah.currentStation?.imageAsset,
            isPlaying: onlineSurah.isPlaying,
            isBuffering: onlineSurah.isBuffering,
            isOnline: true,
          );
        }

        if (offline.currentStation != null) {
          return _BottomPlayerState(
            source: _BottomPlayerSource.offline,
            name: offline.currentSurahName.isNotEmpty
                ? offline.currentSurahName
                : offline.currentStation?.name ?? '',
            emoji: offline.currentStation?.iconEmoji ?? 'ًںژµ',
            subtitle: offline.currentStation?.name ?? '',
            imageUrl: offline.currentStation?.imageUrl,
            imageAsset: offline.currentStation?.imageAsset,
            isPlaying: offline.isPlaying,
            isBuffering: false,
            isOnline: false,
          );
        }

        return null;
      },
      builder: (_, state, __) {
        if (state == null) return const SizedBox.shrink();

        final imgSize = RadioSizes.playerImageSize(isTablet);
        final playBtnSize = RadioSizes.mainPlayButtonSize(isTablet);
        final ctrlBtnSize = RadioSizes.controlButtonSize(isTablet);

        final onPlayPause = _resolvePlayPause(context, state.source);
        final onNext = _resolveNext(context, state.source);
        final onPrevious = _resolvePrevious(context, state.source);

        return RepaintBoundary(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safePadding.bottom),
            decoration: RadioShapes.bottomPlayerDecoration(context),
            child: Row(
              children: [
                // â•گâ•گ طµظˆط±ط© ط§ظ„ظ…ط´ط؛ظ„ â•گâ•گ
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: imgSize,
                    height: imgSize,
                    child: PlayerImageWidget(
                      imageUrl: state.imageUrl,
                      imageAsset: state.imageAsset,
                      emoji: state.emoji,
                      primary: primary,
                      isPlaying: state.isPlaying,
                      equalizerController: equalizerController,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // â•گâ•گ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ â•گâ•گ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LiveIndicator(
                        controller: equalizerController,
                        isOnline: state.isOnline,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.name,
                        style: GoogleFonts.cairo(
                          fontSize: RadioSizes.playerNameSize(isTablet),
                          fontWeight: FontWeight.w700,
                          color: RadioColors.playerText(context),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        state.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: RadioColors.playerSubText(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // â•گâ•گ ط§ظ„ط£ط²ط±ط§ط± â•گâ•گ
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerControlButton(
                      icon: Icons.skip_previous_rounded,
                      size: ctrlBtnSize,
                      onTap: onPrevious,
                    ),
                    const SizedBox(width: 6),
                    _MainPlayButton(
                      isPlaying: state.isPlaying,
                      isBuffering: state.isBuffering,
                      primary: primary,
                      size: playBtnSize,
                      onTap: state.isBuffering ? null : onPlayPause,
                    ),
                    const SizedBox(width: 6),
                    PlayerControlButton(
                      icon: Icons.skip_next_rounded,
                      size: ctrlBtnSize,
                      onTap: onNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  VoidCallback _resolvePlayPause(
      BuildContext context,
      _BottomPlayerSource source,
      ) {
    switch (source) {
      case _BottomPlayerSource.online:
        return context.read<RadioIntillegence>().togglePlayPause;
      case _BottomPlayerSource.onlineSurah:
        return context.read<OnlineSurahService>().togglePlayPause;
      case _BottomPlayerSource.offline:
        return context.read<OfflineRadioService>().togglePlayPause;
    }
  }

  VoidCallback _resolveNext(
      BuildContext context,
      _BottomPlayerSource source,
      ) {
    switch (source) {
      case _BottomPlayerSource.online:
        return context.read<RadioIntillegence>().playNext;
      case _BottomPlayerSource.onlineSurah:
        return context.read<OnlineSurahService>().playNext;
      case _BottomPlayerSource.offline:
        return context.read<OfflineRadioService>().playNext;
    }
  }

  VoidCallback _resolvePrevious(
      BuildContext context,
      _BottomPlayerSource source,
      ) {
    switch (source) {
      case _BottomPlayerSource.online:
        return context.read<RadioIntillegence>().playPrevious;
      case _BottomPlayerSource.onlineSurah:
        return context.read<OnlineSurahService>().playPrevious;
      case _BottomPlayerSource.offline:
        return context.read<OfflineRadioService>().playPrevious;
    }
  }
}

class _BottomPlayerState {
  final _BottomPlayerSource source;
  final String name;
  final String emoji;
  final String subtitle;
  final String? imageUrl;
  final String? imageAsset;
  final bool isPlaying;
  final bool isBuffering;
  final bool isOnline;

  const _BottomPlayerState({
    required this.source,
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.imageUrl,
    required this.imageAsset,
    required this.isPlaying,
    required this.isBuffering,
    required this.isOnline,
  });

  @override
  bool operator ==(Object other) {
    return other is _BottomPlayerState &&
        other.source == source &&
        other.name == name &&
        other.emoji == emoji &&
        other.subtitle == subtitle &&
        other.imageUrl == imageUrl &&
        other.imageAsset == imageAsset &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(
    source,
    name,
    emoji,
    subtitle,
    imageUrl,
    imageAsset,
    isPlaying,
    isBuffering,
    isOnline,
  );
}

/// â•گâ•گ ظ…ط¤ط´ط± ط§ظ„ط¨ط« ط§ظ„ظ…ط¨ط§ط´ط± â•گâ•گ
class _LiveIndicator extends StatelessWidget {
  final AnimationController controller;
  final bool isOnline;

  const _LiveIndicator({
    required this.controller,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final op = isOnline
            ? 0.5 + 0.5 * sin(controller.value * 2 * pi)
            : 1.0;

        final liveColor = isOnline ? RadioColors.gold : Colors.green;

        return Text(
          isOnline ? 'â—ڈ LIVE' : 'â—‰ ط£ظˆظپظ„ط§ظٹظ†',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: liveColor.withValues(alpha: op),
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}

/// â•گâ•گ ط²ط± ط§ظ„طھط´ط؛ظٹظ„ ط§ظ„ط±ط¦ظٹط³ظٹ â•گâ•گ
class _MainPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final Color primary;
  final double size;
  final VoidCallback? onTap;

  const _MainPlayButton({
    required this.isPlaying,
    required this.isBuffering,
    required this.primary,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: RadioShapes.mainPlayButtonDecoration(primary),
        child: isBuffering
            ? Padding(
          padding: EdgeInsets.all(size * 0.26),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}