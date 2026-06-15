// lib/screens/radio/widgets_recitations/rec_reciters_list.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/download_screen.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/recitation_surahs_screen.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_download_button.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_sub_items_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';
import 'package:provider/provider.dart';
import '../helpers/playback_helper.dart';
import '../services/Radio_Intillegence.dart';
import '../widgets/cached_image_widget.dart';
import 'duration_text.dart';
import 'services/item_download_service.dart';
import 'rec_empty_state.dart';

class RecRecitersList extends StatelessWidget {
  final List<RecitationItem> items;
  final Color primary;
  final List<Color> gradientColors;
  final bool isTablet;
  final String categoryId;

  const RecRecitersList({
    super.key,
    required this.items,
    required this.primary,
    required this.gradientColors,
    required this.isTablet,
    this.categoryId = 'reciters',
  });

  bool get _isReciters => categoryId == 'reciters';

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const RecEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];

        // ══ القراء: لديهم station ══
        if (item.station != null) {
          return Selector<RadioDownloadService, _ReciterDownloadState>(
            selector: (_, download) {
              final downloaded = download.getDownloadedSurahs(item.station!.id);
              return _ReciterDownloadState(
                downloadedCount: downloaded.length,
                hasDownloads: downloaded.isNotEmpty,
                isDownloading:
                download.getStatus(item.station!.id) == DownloadStatus.downloading,
                progress: download.getProgress(item.station!.id),
              );
            },
            builder: (_, state, __) {
              return _UnifiedItem(
                item: item,
                primary: primary,
                gradientColors: gradientColors,
                isTablet: isTablet,
                downloadedCount: state.downloadedCount,
                hasDownloads: state.hasDownloads,
                isDownloading: state.isDownloading,
                downloadProgress: state.progress,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecitationSurahsScreen(
                      station: item.station!,
                      primary: primary,
                    ),
                  ),
                ),
                onDownloadTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DownloadScreen(
                      station: item.station!,
                      primary: primary,
                    ),
                  ),
                ),
                onCancelDownload: () =>
                    context.read<RadioDownloadService>().cancelDownload(item.station!.id),
              );
            },
          );
        }

        // ══ الأقسام الأخرى: audioUrl ══
        return _UnifiedItem(
          item: item,
          primary: primary,
          gradientColors: gradientColors,
          isTablet: isTablet,
          downloadedCount: 0,
          hasDownloads: false,
          isDownloading: false,
          downloadProgress: 0,
          onTap: () => _handleNonStationTap(context, item),
        );
      },
    );
  }

  void _handleNonStationTap(BuildContext context, RecitationItem item) {
    if (item.hasSubItems) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecSubItemsScreen(
            parentItem: item,
            primary: primary,
          ),
        ),
      );
      return;
    }

    final downloadService = context.read<ItemDownloadService>();

    PlaybackHelper.playAuto(
      context: context,
      item: item,
      primary: primary,
      downloadService: downloadService,
    );
  }

}

// ══════════════════════════════════════════════════════════════
// عنصر موحّد للقراء والأقسام الأخرى
// ══════════════════════════════════════════════════════════════

class _UnifiedItem extends StatelessWidget {
  final RecitationItem item;
  final Color primary;
  final List<Color> gradientColors;
  final bool isTablet;
  final int downloadedCount;
  final bool hasDownloads;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onTap;
  final VoidCallback? onDownloadTap;
  final VoidCallback? onCancelDownload;

  const _UnifiedItem({
    required this.item,
    required this.primary,
    required this.gradientColors,
    required this.isTablet,
    required this.downloadedCount,
    required this.hasDownloads,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onTap,
    this.onDownloadTap,
    this.onCancelDownload,
  });

  bool get _isStation => item.station != null;
  bool get _hasAudio => item.audioUrl != null && item.audioUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final imgSize = RecSizes.reciterImageSize(isTablet);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: RecShapes.reciterItem(
          hasDownloads: hasDownloads || (!_isStation && _hasAudio),
          primary: primary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // ══ الصورة ══
                _buildImage(imgSize),
                const SizedBox(width: 12),

                // ══ المعلومات ══
                Expanded(child: _buildInfo(context)),

                const SizedBox(width: 8),

                // ══ الأزرار ══
                _buildActions(context),
              ],
            ),

            // ══ شريط تقدم التحميل ══
            if (isDownloading) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: downloadProgress,
                        backgroundColor: RecColors.primary(primary, 0.1),
                        valueColor: AlwaysStoppedAnimation(primary),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(downloadProgress * 100).toInt()}%',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onCancelDownload,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    return ClipRRect(
      borderRadius: RecShapes.radiusCategory,
      child: SizedBox(
        width: size,
        height: size,
        child: _buildImageContent(),
      ),
    );
  }


  Widget _buildImageContent() {
    if (item.imageUrl != null &&
        item.imageUrl!.isNotEmpty &&
        Uri.tryParse(item.imageUrl!)?.hasScheme == true) {
      return SizedBox.expand(
        child: CachedImageWidget(
          imageUrl: item.imageUrl,
          fit: BoxFit.cover,
          errorWidget: _buildFallback(),
        ),
      );
    }

    if (item.imageAsset != null && item.imageAsset!.isNotEmpty) {
      return SizedBox.expand(
        child: CachedImageWidget(
          imageAsset: item.imageAsset,
          fit: BoxFit.cover,
          errorWidget: _buildFallback(),
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: RecColors.fallbackGradient(gradientColors),
      ),
      child: Center(
        child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ══ العنوان ══
        Text(
          item.title,
          style: GoogleFonts.cairo(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: RecColors.textPrimary(context),
            height: 1.35,
          ),
        ),

        const SizedBox(height: 3),

        if (_isStation && hasDownloads)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.download_done_rounded,
                size: 11,
                color: Colors.green,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  '$downloadedCount سورة محملة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: RecColors.textGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        else if (_isStation && isDownloading)
          Text(
            'جاري التحميل...',
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          )
        else if (!_isStation && _hasAudio)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_rounded,
                  size: 11,
                  color: RecColors.gold,
                ),
                const SizedBox(width: 3),
                Text(
                  'بث مباشر متاح',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: RecColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              item.subtitle,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: RecColors.textSecondary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

        if (!_isStation && _hasAudio) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 10,
                color: RecColors.textHint(context),
              ),
              const SizedBox(width: 3),
              DurationText(
                audioUrl: item.audioUrl!,
                fontSize: 10,
                color: RecColors.textHint(context),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_isStation) {
      // ══ القراء ══
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDownloading && onDownloadTap != null)
            GestureDetector(
              onTap: onDownloadTap,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RecColors.downloadBadgeBackground(
                      context, hasDownloads, primary),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: RecColors.downloadBadgeBorder(
                        context, hasDownloads, primary),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasDownloads
                          ? Icons.download_done_rounded
                          : Icons.download_rounded,
                      size: 12,
                      color: hasDownloads ? Colors.green : primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      hasDownloads ? 'محمّل' : 'تحميل',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: hasDownloads ? Colors.green : primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isDownloading && onDownloadTap != null)
            const SizedBox(width: 8),
          Container(
            width: RecSizes.reciterArrowSize,
            height: RecSizes.reciterArrowSize,
            decoration: RecShapes.reciterArrow(primary),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: primary,
            ),
          ),
        ],
      );
    }

    // ══ الأقسام الأخرى: زر تحميل + زر تشغيل ══
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر التحميل الخاص بالعناصر
        if (_hasAudio)
          RecItemDownloadButton(
            item: item,
            primary: primary,
            isTablet: isTablet,
          ),

        if (_hasAudio) const SizedBox(width: 8),

        // زر التشغيل
        Container(
          width: RecSizes.reciterArrowSize,
          height: RecSizes.reciterArrowSize,
          decoration: BoxDecoration(
            color: _hasAudio
                ? RecColors.primary(primary, 0.15)
                : RecColors.iconBackground(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: _hasAudio
                  ? RecColors.primary(primary, 0.3)
                  : RecColors.iconBorder(context),
            ),
          ),
          child: Icon(
            _hasAudio
                ? Icons.play_arrow_rounded
                : Icons.lock_outline_rounded,
            size: 16,
            color: _hasAudio ? primary : RecColors.textHint(context),
          ),
        ),
      ],
    );
  }
}

class _ReciterDownloadState {
  final int downloadedCount;
  final bool hasDownloads;
  final bool isDownloading;
  final double progress;

  const _ReciterDownloadState({
    required this.downloadedCount,
    required this.hasDownloads,
    required this.isDownloading,
    required this.progress,
  });

  @override
  bool operator ==(Object other) {
    return other is _ReciterDownloadState &&
        other.downloadedCount == downloadedCount &&
        other.hasDownloads == hasDownloads &&
        other.isDownloading == isDownloading &&
        other.progress == progress;
  }

  @override
  int get hashCode =>
      Object.hash(downloadedCount, hasDownloads, isDownloading, progress);
}