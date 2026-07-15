import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/models/player_snapshot.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/playlist_service.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/player_image_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';
import 'package:provider/provider.dart';

/// مشغل موحد: لا يقرأ حالة أي خدمة مباشرة، بل يعتمد فقط على المنسق.
class ModernBottomPlayer extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final EdgeInsets safePadding;
  final AnimationController equalizerController;

  const ModernBottomPlayer({
    super.key,
    required this.primary,
    required this.isTablet,
    required this.safePadding,
    required this.equalizerController,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AudioCoordinator, _PlayerViewState>(
      selector: (_, coordinator) => _PlayerViewState(
        snapshot: coordinator.snapshot,
        position: coordinator.position,
        duration: coordinator.duration,
      ),
      builder: (_, state, __) {
        final snapshot = state.snapshot;
        if (!snapshot.hasActivePlayer) return const SizedBox.shrink();

        final coordinator = context.read<AudioCoordinator>();
        final imageSize = RadioSizes.playerImageSize(isTablet);
        final controlSize = RadioSizes.controlButtonSize(isTablet);
        final playSize = RadioSizes.mainPlayButtonSize(isTablet);

        return RepaintBoundary(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + safePadding.bottom),
            decoration: RadioShapes.bottomPlayerDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: PlayerImageWidget(
                          imageUrl: snapshot.imageUrl,
                          imageAsset: snapshot.imageAsset,
                          emoji: snapshot.emoji,
                          primary: primary,
                          isPlaying: snapshot.isPlaying,
                          equalizerController: equalizerController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LiveIndicator(
                            controller: equalizerController,
                            isOnline: snapshot.isOnline,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            snapshot.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: RadioSizes.playerNameSize(isTablet),
                              fontWeight: FontWeight.w700,
                              color: RadioColors.playerText(context),
                            ),
                          ),
                          Text(
                            snapshot.error ?? snapshot.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: snapshot.error == null
                                  ? RadioColors.playerSubText(context)
                                  : Colors.red.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (snapshot.canGoPrevious)
                      _ControlButton(
                        icon: Icons.skip_previous_rounded,
                        size: controlSize,
                        onTap: coordinator.playPrevious,
                      ),
                    _PlayButton(
                      isPlaying: snapshot.isPlaying,
                      isBuffering: snapshot.isBuffering,
                      primary: primary,
                      size: playSize,
                      onTap: snapshot.isBuffering
                          ? null
                          : (snapshot.error == null
                              ? coordinator.togglePlayPause
                              : coordinator.retryCurrent),
                    ),
                    if (snapshot.canGoNext)
                      _ControlButton(
                        icon: Icons.skip_next_rounded,
                        size: controlSize,
                        onTap: coordinator.playNext,
                      ),
                    IconButton(
                      tooltip: 'يعمل الآن',
                      onPressed: () => _showNowPlaying(context),
                      icon: const Icon(Icons.open_in_full_rounded),
                    ),
                    IconButton(
                      tooltip: 'أدوات المشغل',
                      onPressed: () => _showTools(context, coordinator),
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                if (state.duration.inMilliseconds > 0) ...[
                  const SizedBox(height: 8),
                  _SeekBar(
                    position: state.position,
                    duration: state.duration,
                    primary: primary,
                    onSeek: coordinator.seek,
                  ),
                ],
                if (snapshot.error != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: coordinator.retryCurrent,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTools(BuildContext context, AudioCoordinator coordinator) {
    final playlist = context.read<PlaylistService>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('أدوات المشغل', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text('سرعة التشغيل'),
              Wrap(
                spacing: 8,
                children: [0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((speed) => ChoiceChip(
                          label: Text('${speed}x'),
                          selected: speed == 1.0,
                          onSelected: (_) => coordinator.setSpeed(speed),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Text('مؤقت النوم'),
              Wrap(
                spacing: 8,
                children: [15, 30, 45, 60]
                    .map((minutes) => ActionChip(
                          label: Text('$minutes دقيقة'),
                          onPressed: () {
                            coordinator.setSleepTimer(Duration(minutes: minutes));
                            Navigator.pop(sheetContext);
                          },
                        ))
                    .toList()
                  ..add(ActionChip(
                    label: const Text('إلغاء المؤقت'),
                    onPressed: () {
                      coordinator.setSleepTimer(null);
                      Navigator.pop(sheetContext);
                    },
                  )),
              ),
              if (playlist.hasPlaylist) ...[
                const SizedBox(height: 14),
                Text('قائمة التشغيل: ${playlist.playlistName}'),
                ...playlist.playlist.asMap().entries.map(
                  (entry) => ListTile(
                    dense: true,
                    selected: entry.key == playlist.currentIndex,
                    leading: Text('${entry.key + 1}'),
                    title: Text(entry.value.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(entry.value.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      final item = playlist.playAt(entry.key);
                      if (item != null) await coordinator.playPlaylistItem(item);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showNowPlaying(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .88,
        child: Consumer<AudioCoordinator>(
          builder: (context, coordinator, __) {
            final snapshot = coordinator.snapshot;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: PlayerImageWidget(
                        imageUrl: snapshot.imageUrl,
                        imageAsset: snapshot.imageAsset,
                        emoji: snapshot.emoji,
                        primary: primary,
                        isPlaying: snapshot.isPlaying,
                        equalizerController: equalizerController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(snapshot.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(snapshot.error ?? snapshot.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(color: snapshot.error == null ? null : Colors.red)),
                  const SizedBox(height: 16),
                  if (coordinator.duration.inMilliseconds > 0)
                    _SeekBar(
                      position: coordinator.position,
                      duration: coordinator.duration,
                      primary: primary,
                      onSeek: coordinator.seek,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (snapshot.canGoPrevious)
                        _ControlButton(icon: Icons.skip_previous_rounded, size: 42, onTap: coordinator.playPrevious),
                      _PlayButton(
                        isPlaying: snapshot.isPlaying,
                        isBuffering: snapshot.isBuffering,
                        primary: primary,
                        size: 62,
                        onTap: snapshot.error == null ? coordinator.togglePlayPause : coordinator.retryCurrent,
                      ),
                      if (snapshot.canGoNext)
                        _ControlButton(icon: Icons.skip_next_rounded, size: 42, onTap: coordinator.playNext),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlayerViewState {
  final PlayerSnapshot snapshot;
  final Duration position;
  final Duration duration;

  const _PlayerViewState({
    required this.snapshot,
    required this.position,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      other is _PlayerViewState &&
      other.snapshot == snapshot &&
      other.position == position &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(snapshot, position, duration);
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        iconSize: size * .8,
        color: RadioColors.playerText(context),
        splashRadius: size * .6,
      );
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final Color primary;
  final double size;
  final VoidCallback? onTap;

  const _PlayButton({
    required this.isPlaying,
    required this.isBuffering,
    required this.primary,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: isBuffering
            ? SizedBox(
                width: size * .45,
                height: size * .45,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
        color: Colors.white,
        iconSize: size * .6,
        splashRadius: size * .6,
        style: IconButton.styleFrom(
          backgroundColor: primary,
          minimumSize: Size.square(size),
        ),
      );
}

class _SeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Color primary;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.primary,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
    return Row(
      children: [
        Text(_format(position), style: const TextStyle(fontSize: 9)),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: max,
            activeColor: primary,
            onChanged: (value) => onSeek(Duration(milliseconds: value.round())),
          ),
        ),
        Text(_format(duration), style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  String _format(Duration value) =>
      '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

class _LiveIndicator extends StatelessWidget {
  final AnimationController controller;
  final bool isOnline;

  const _LiveIndicator({required this.controller, required this.isOnline});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final opacity = isOnline ? .5 + .5 * sin(controller.value * 2 * pi) : 1.0;
          return Text(
            isOnline ? '● LIVE' : '◉ أوفلاين',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: (isOnline ? RadioColors.gold : Colors.green).withValues(alpha: opacity),
            ),
          );
        },
      );
}
