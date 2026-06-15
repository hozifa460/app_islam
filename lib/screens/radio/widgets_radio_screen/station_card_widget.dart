// lib/screens/radio/widgets_radio_screen/station_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/live_badge_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';
import 'package:provider/provider.dart';
import '../widgets/radio_image_widget.dart';
import 'mini_equalizer_widget.dart';

class StationCardWidget extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final bool isTablet;
  final AnimationController equalizerController;
  final VoidCallback onPlayed;

  const StationCardWidget({
    super.key,
    required this.station,
    required this.primary,
    required this.isTablet,
    required this.equalizerController,
    required this.onPlayed,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imgH = RadioSizes.stationImageHeight(screenH);

    return Selector<RadioIntillegence, _StationCardState>(
      selector: (_, radio) {
        final isCurrent = radio.currentStation?.id == station.id;
        return _StationCardState(
          isCurrent: isCurrent,
          isPlaying: isCurrent && radio.isPlaying,
          isBuffering: isCurrent && radio.isBuffering,
          isFav: radio.isFavorite(station.id),
        );
      },
      builder: (_, state, __) {
        // âœ… ط­ط³ط§ط¨ ط§ظ„ط¹ط±ط¶ ظ…ظ† ط§ظ„طµظˆط±ط© ط¨ط´ظƒظ„ ط«ط§ط¨طھ
        final contentW = imgH * (16 / 9);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(context, state),
          child: Container(
            margin: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageStack(
                  context: context,
                  imgH: imgH,
                  state: state,
                ),
                const SizedBox(height: 7),
                _buildTextContent(context, contentW),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, _StationCardState state) {
    HapticFeedback.lightImpact();
    final coordinator = context.read<AudioCoordinator>();
    final radio = context.read<RadioIntillegence>();

    if (state.isCurrent && state.isPlaying) {
      radio.pause();
    } else if (state.isCurrent && !state.isPlaying) {
      radio.resume();
    } else {
      coordinator.playOnlineRadio(station);
      onPlayed();
    }
  }

  Widget _buildImageStack({
    required BuildContext context,
    required double imgH,
    required _StationCardState state,
  }) {
    final contentW = imgH * (16 / 9);

    return SizedBox(
      width: contentW,
      height: imgH,
      child: Stack(
        children: [
          // âœ… ط§ط³طھط®ط¯ط§ظ… RadioImageWidget
          Positioned.fill(
            child: ClipRRect(
              borderRadius: RadioShapes.borderRadiusMedium,
              child: RadioImageWidget(
                imageUrl: station.imageUrl,
                imageAsset: station.imageAsset,
                emoji: station.iconEmoji,
                primary: primary,
                size: imgH,
                fit: BoxFit.cover,
                isActive: state.isPlaying,
              ),
            ),
          ),

          // طھط¯ط±ط¬ ط³ظپظ„ظٹ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                height: imgH * 0.45,
                decoration: BoxDecoration(
                  gradient: RadioColors.darkOverlayGradient(
                    topOpacity: 0.0,
                    bottomOpacity: 0.65,
                  ),
                ),
              ),
            ),
          ),

          // ط²ط± ط§ظ„طھط´ط؛ظٹظ„
          Positioned(
            bottom: 7,
            right: 7,
            child: _buildPlayButton(state),
          ),

          // Equalizer
          if (state.isPlaying && !state.isBuffering)
            Positioned(
              bottom: 10,
              left: 8,
              child: MiniEqualizerWidget(
                controller: equalizerController,
                color: RadioColors.gold,
              ),
            ),

          // ط§ظ„ظ…ظپط¶ظ„ط©
          Positioned(
            top: 7,
            right: 7,
            child: _buildFavoriteButton(context, state.isFav),
          ),

          // âœ… ط§ط³طھط®ط¯ط§ظ… LiveBadgeWidget
          Positioned(
            top: 7,
            left: 7,
            child: LiveBadgeWidget(isPlaying: state.isPlaying),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(_StationCardState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: RadioSizes.smallPlayButtonSize,
      height: RadioSizes.smallPlayButtonSize,
      decoration: state.isPlaying
          ? BoxDecoration(
        gradient: RadioColors.primaryGradient(primary),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      )
          : RadioShapes.playButtonDecoration(
        isPlaying: false,
        gold: RadioColors.gold,
      ),
      child: state.isBuffering
          ? Padding(
        padding: const EdgeInsets.all(6),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: primary,
        ),
      )
          : Icon(
        state.isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        size: 17,
        color: state.isPlaying ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, bool isFav) {
    return GestureDetector(
      onTap: () => context
          .read<RadioIntillegence>()
          .toggleFavorite(station.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: RadioSizes.favoriteButtonSizeStation,
        height: RadioSizes.favoriteButtonSizeStation,
        decoration: RadioShapes.favoriteButtonDecoration(
          opacity: isFav ? 0.6 : 0.35,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isFav
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            key: ValueKey(isFav),
            color: isFav
                ? Colors.red.shade400
                : RadioColors.whiteWithOpacity(0.7),
            size: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, double contentW) {
    return SizedBox(
      width: contentW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            station.name,
            style: GoogleFonts.cairo(
              fontSize: (contentW * 0.09).clamp(9.0, 14.0),
              fontWeight: FontWeight.w700,
              color: RadioColors.textPrimary(context),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            station.description,
            style: GoogleFonts.cairo(
              fontSize: (contentW * 0.075).clamp(8.0, 11.0),
              color: RadioColors.textSecondary(context),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _CategoryBadge(
            label: station.category,
            primary: primary,
            contentW: contentW,
          ),
        ],
      ),
    );
  }
}

class _StationCardState {
  final bool isCurrent;
  final bool isPlaying;
  final bool isBuffering;
  final bool isFav;

  const _StationCardState({
    required this.isCurrent,
    required this.isPlaying,
    required this.isBuffering,
    required this.isFav,
  });

  @override
  bool operator ==(Object other) {
    return other is _StationCardState &&
        other.isCurrent == isCurrent &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.isFav == isFav;
  }

  @override
  int get hashCode =>
      Object.hash(isCurrent, isPlaying, isBuffering, isFav);
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color primary;
  final double contentW;

  const _CategoryBadge({
    required this.label,
    required this.primary,
    required this.contentW,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: RadioColors.cardBackgroundActive(context, primary),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: RadioColors.cardBorderActive(context, primary),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: (contentW * 0.07).clamp(8.0, 10.0),
          fontWeight: FontWeight.w700,
          color: RadioColors.textPrimary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}