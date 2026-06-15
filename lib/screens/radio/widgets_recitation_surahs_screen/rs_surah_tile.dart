// lib/screens/radio/widgets_surahs/rs_surah_tile.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/surah_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';
import 'package:provider/provider.dart';

import '../services/Radio_Intillegence.dart';
import '../widgets_recitations_screen/models/downloadable_item.dart';

class RsSurahTile extends StatelessWidget {
  final SurahModel surah;
  final IslamicRadioStation station;
  final bool isDownloaded;
  final bool isDark;
  final Color cardColor;
  final Color primary;
  final Future<void> Function(BuildContext, AudioCoordinator, int) onPlayOnline;

  const RsSurahTile({
    super.key,
    required this.surah,
    required this.station,
    required this.isDownloaded,
    required this.isDark,
    required this.cardColor,
    required this.primary,
    required this.onPlayOnline,
  });

  @override
  Widget build(BuildContext context) {
    final surahUrl = station.surahStreamUrl(surah.number);

    String? itemId;
    if (surahUrl != null && surahUrl.isNotEmpty) {
      final tempItem = RecitationItem(
        title: surah.name,
        subtitle: station.name,
        emoji: station.iconEmoji,
        audioUrl: surahUrl,
        imageUrl: station.imageUrl,
      );
      itemId = ItemDownloadService.itemIdFromRecitationItem(tempItem);
    }

    return Selector<ItemDownloadService, _RsDownloadState>(
      selector: (_, service) {
        if (itemId == null) {
          return const _RsDownloadState(
            isDownloaded: false,
            isDownloading: false,
            localPath: null,
          );
        }

        return _RsDownloadState(
          isDownloaded: service.isDownloaded(itemId),
          isDownloading:
          service.getStatus(itemId) == ItemDownloadStatus.downloading,
          localPath: service.getLocalPath(itemId),
        );
      },
      builder: (_, downloadState, __) {
        final actuallyDownloaded =
            isDownloaded || downloadState.isDownloaded;
        final expectedUrl = actuallyDownloaded
            ? (downloadState.localPath ?? '')
            : (surahUrl ?? '');

        return Selector<RadioIntillegence, _RsPlaybackState>(
          selector: (_, radio) {
            final isCurrent =
                expectedUrl.isNotEmpty &&
                    radio.currentStation?.url == expectedUrl;

            return _RsPlaybackState(
              isCurrent: isCurrent,
              isPlaying: isCurrent && radio.isPlaying,
              isBuffering: isCurrent && radio.isBuffering,
            );
          },
          builder: (_, playbackState, __) {
            return GestureDetector(
              onTap: () async {
                final coordinator = context.read<AudioCoordinator>();

                // ✅ شغّل أولاً (فوري الآن بعد إصلاح _runSwitch)
                unawaited(
                  coordinator.playSurahTrack(
                    station: station,
                    surahNumber: surah.number,
                    isLocal: actuallyDownloaded,
                    localPath: downloadState.localPath,
                  ),
                );

                if (!context.mounted) return;

                // ✅ ثم افتح الشاشة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahPlayerScreen(
                      station: station,
                      surahNumber: surah.number,
                      primary: primary,
                      isOnline: !actuallyDownloaded,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: RsShapes.surahTile(
                  isCurrentSurah: playbackState.isCurrent,
                  isDownloaded: actuallyDownloaded,
                  isDark: isDark,
                  cardColor: cardColor,
                  primary: primary,
                ),
                child: Row(
                  children: [
                    _buildSurahNumber(context, playbackState.isCurrent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSurahInfo(
                        context,
                        playbackState.isCurrent,
                      ),
                    ),
                    _buildActions(
                      context: context,
                      playbackState: playbackState,
                      isActuallyDownloaded: actuallyDownloaded,
                      localPath: downloadState.localPath,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahNumber(BuildContext context, bool isCurrentSurah) {
    return SizedBox(
      width: 32,
      child: Text(
        '${surah.number}',
        style: GoogleFonts.cairo(
          fontSize: RsSizes.surahNumSize,
          fontWeight: FontWeight.w700,
          color: isCurrentSurah
              ? primary
              : RsColors.textSecondary(context),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSurahInfo(BuildContext context, bool isCurrentSurah) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          surah.name,
          style: GoogleFonts.cairo(
            fontSize: RsSizes.surahNameSize,
            fontWeight: FontWeight.w700,
            color: isCurrentSurah
                ? primary
                : RsColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${surah.versesCount} آية • ${surah.isMakki ? 'مكية' : 'مدنية'} • الجزء ${surah.juzNumber}',
          style: GoogleFonts.cairo(
            fontSize: RsSizes.surahDetailSize,
            color: RsColors.textMuted(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActions({
    required BuildContext context,
    required _RsPlaybackState playbackState,
    required bool isActuallyDownloaded,
    required String? localPath,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isActuallyDownloaded)
          GestureDetector(
            onTap: () => _downloadSurah(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: RsShapes.surahDownloadBtn(primary),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_rounded,
                    size: RsSizes.downloadIconSize,
                    color: primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'تحميل',
                    style: GoogleFonts.cairo(
                      fontSize: RsSizes.downloadBtnLabelSize,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(width: 8),

        GestureDetector(
          onTap: () async {
            final radio = context.read<RadioIntillegence>();
            final coordinator = context.read<AudioCoordinator>();

            if (playbackState.isCurrent && playbackState.isPlaying) {
              await radio.pause();
            } else if (playbackState.isCurrent && !playbackState.isPlaying) {
              await radio.resume();
            } else {
              await coordinator.playSurahTrack(
                station: station,
                surahNumber: surah.number,
                isLocal: isActuallyDownloaded,
                localPath: localPath,
              );
            }
          },
          child: Container(
            width: RsSizes.surahPlayBtnSize,
            height: RsSizes.surahPlayBtnSize,
            decoration: RsShapes.surahPlayBtn(
              isCurrentSurah: playbackState.isCurrent,
              primary: primary,
            ),
            child: playbackState.isBuffering
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(
              playbackState.isCurrent && playbackState.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 20,
              color: playbackState.isCurrent
                  ? Colors.white
                  : primary,
            ),
          ),
        ),
      ],
    );
  }

  void _downloadSurah(BuildContext context) {
    final surahUrl = station.surahStreamUrl(surah.number);

    if (surahUrl == null || surahUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'رابط السورة غير متاح',
            style: GoogleFonts.cairo(),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final stationDirName = station.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    final surahFileName = surah.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    final tempItem = RecitationItem(
      title: surah.name,
      subtitle: station.name,
      emoji: station.iconEmoji,
      audioUrl: surahUrl,
      imageUrl: station.imageUrl,
    );

    context.read<ItemDownloadService>().downloadItem(
      tempItem,
      customDir: stationDirName,
      customFileName: surahFileName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري تحميل سورة ${surah.name}...',
          style: GoogleFonts.cairo(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _RsDownloadState {
  final bool isDownloaded;
  final bool isDownloading;
  final String? localPath;

  const _RsDownloadState({
    required this.isDownloaded,
    required this.isDownloading,
    required this.localPath,
  });

  @override
  bool operator ==(Object other) {
    return other is _RsDownloadState &&
        other.isDownloaded == isDownloaded &&
        other.isDownloading == isDownloading &&
        other.localPath == localPath;
  }

  @override
  int get hashCode => Object.hash(isDownloaded, isDownloading, localPath);
}

class _RsPlaybackState {
  final bool isCurrent;
  final bool isPlaying;
  final bool isBuffering;

  const _RsPlaybackState({
    required this.isCurrent,
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  bool operator ==(Object other) {
    return other is _RsPlaybackState &&
        other.isCurrent == isCurrent &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering;
  }

  @override
  int get hashCode => Object.hash(isCurrent, isPlaying, isBuffering);
}