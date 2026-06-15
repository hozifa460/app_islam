// lib/screens/radio/widgets_recitations/rec_item_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/download_screen.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/recitation_surahs_screen.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_sub_items_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';
import 'package:provider/provider.dart';

import '../widgets/cached_image_widget.dart';
import 'models/downloadable_item.dart';

/// ══════════════════════════════════════════════════════════════
/// بطاقة العنصر الأفقية
/// ══════════════════════════════════════════════════════════════
class RecItemCard extends StatelessWidget {
  final RecitationItem item;
  final Color primary;
  final List<Color> gradientColors;
  final bool isTablet;

  const RecItemCard({
    super.key,
    required this.item,
    required this.primary,
    required this.gradientColors,
    required this.isTablet,
  });

  bool get _hasAudio => item.audioUrl != null && item.audioUrl!.isNotEmpty;
  bool get _isStation => item.station != null;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imgH = RecSizes.imageHeight(screenH);
    final cardW = imgH * (14 / 9);

    return Consumer<ItemDownloadService>(
      builder: (_, itemDownloadService, __) {
        final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
        final isDownloaded = itemDownloadService.isDownloaded(itemId);
        final isDownloading =
            itemDownloadService.getStatus(itemId) ==
            ItemDownloadStatus.downloading;
        final progress = itemDownloadService.getProgress(itemId);

        return GestureDetector(
          onTap: () => _handleTap(context, itemDownloadService),
          child: Container(
            width: cardW,
            margin: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageStack(
                  context,
                  cardW,
                  imgH,
                  isDownloaded,
                  isDownloading,
                  progress,
                ),
                const SizedBox(height: 7),
                _buildTextContent(context, cardW, isDownloaded, isDownloading),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // منطق الضغط
  // ══════════════════════════════════════════════════════

  void _handleTap(BuildContext context, ItemDownloadService downloadService) {
    // ══ 1. القارئ العادي ══
    if (_isStation) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => RecitationSurahsScreen(
                station: item.station!,
                primary: primary,
              ),
        ),
      );
      return;
    }

    // ══ 2. تلاوات متعددة ══
    if (item.hasSubItems) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecSubItemsScreen(parentItem: item, primary: primary),
        ),
      );
      return;
    }

    // ══ 3. تلاوة واحدة محمّلة ══
    final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
    final localPath = downloadService.getLocalPath(itemId);

    if (localPath != null) {
      _playLocalFile(context, localPath);
      return;
    }

    // ══ 4. تلاوة واحدة أونلاين ══
    if (_hasAudio) {
      _playOnline(context);
      return;
    }

    // ══ 5. لا يوجد رابط ══
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'الرابط غير متاح حالياً',
          style: GoogleFonts.cairo(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _playLocalFile(BuildContext context, String localPath) async {
    final file = File(localPath);

    if (!await file.exists()) {
      final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
      if (context.mounted) {
        context.read<ItemDownloadService>().deleteDownload(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الملف غير موجود، أعد تحميله',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      final coordinator = context.read<AudioCoordinator>();

      final tempStation = IslamicRadioStation(
        id: localPath.hashCode.abs(),
        name: item.title,
        nameEn: item.title,
        url: localPath,
        category: 'تلاوات',
        categoryEn: 'Recitations',
        description: '${item.subtitle} • أوفلاين',
        descriptionEn: item.subtitle,
        iconEmoji: item.emoji,
        imageUrl: item.imageUrl,
      );

      await coordinator.playLocalItem(station: tempStation);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => RecItemPlayerScreen(
                  item: item,
                  primary: primary,
                  station: tempStation,
                  isLocal: true,
                ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ تشغيل محلي من RecItemCard: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تشغيل الملف',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _playOnline(BuildContext context) {
    final coordinator = context.read<AudioCoordinator>();

    final tempStation = IslamicRadioStation(
      id: item.audioUrl!.hashCode.abs(),
      name: item.title,
      nameEn: item.title,
      url: item.audioUrl!,
      category: 'تلاوات',
      categoryEn: 'Recitations',
      description: item.subtitle,
      descriptionEn: item.subtitle,
      iconEmoji: item.emoji,
      imageUrl: item.imageUrl,
    );

    coordinator.playOnlineRadio(tempStation);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RecItemPlayerScreen(
              item: item,
              primary: primary,
              station: tempStation,
              isLocal: false,
            ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // الصورة
  // ══════════════════════════════════════════════════════

  Widget _buildImageStack(
    BuildContext context,
    double cardW,
    double imgH,
    bool isDownloaded,
    bool isDownloading,
    double progress,
  ) {
    return Stack(
      children: [
        // ══ الصورة ══
        ClipRRect(
          borderRadius: RecShapes.radiusCard,
          child: SizedBox(
            width: cardW,
            height: imgH,
            child: _buildImage(cardW, imgH),
          ),
        ),

        // ══ تدرج سفلي ══
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: RecShapes.radiusCardBottom,
            child: Container(
              height: 50,
              decoration: BoxDecoration(gradient: RecColors.darkOverlay()),
            ),
          ),
        ),

        // ══ زر التشغيل ══
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            width: RecSizes.cardPlayBtnSize,
            height: RecSizes.cardPlayBtnSize,
            decoration: RecShapes.cardPlayButton(
              hasStation: _isStation || isDownloaded || _hasAudio,
              gold: RecColors.gold,
            ),
            child: Icon(
              _isStation
                  ? Icons.headphones_rounded
                  : isDownloaded
                  ? Icons.play_arrow_rounded
                  : _hasAudio
                  ? Icons.play_arrow_rounded
                  : Icons.lock_outline_rounded,
              color:
                  (_isStation || isDownloaded || _hasAudio)
                      ? Colors.white
                      : RecColors.white(0.3),
              size: 17,
            ),
          ),
        ),

        // ══ زر التحميل للعناصر الأخرى ══
        if (!_isStation && _hasAudio)
          Positioned(
            top: 8,
            right: 8,
            child: _buildDownloadAction(
              context,
              isDownloaded,
              isDownloading,
              progress,
            ),
          ),

        // ══ شارة أوفلاين ══
        if (isDownloaded && !_isStation)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'أوفلاين',
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // ══ شارة عناصر متعددة ══
        if (item.hasSubItems)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: RecColors.primary(primary, 0.85),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: RecColors.primary(primary, 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.playlist_play_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${item.subItemsCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadAction(
    BuildContext context,
    bool isDownloaded,
    bool isDownloading,
    double progress,
  ) {
    final itemId = ItemDownloadService.itemIdFromRecitationItem(item);

    return GestureDetector(
      onTap: () async {
        final service = context.read<ItemDownloadService>();

        if (isDownloading) {
          service.cancelDownload(itemId);
          return;
        }

        if (isDownloaded) {
          await service.deleteDownload(itemId);
          return;
        }

        service.downloadItem(item);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: RecColors.black(0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isDownloaded
                    ? Colors.green.withOpacity(0.5)
                    : RecColors.primary(primary, 0.35),
          ),
        ),
        child:
            isDownloading
                ? Padding(
                  padding: const EdgeInsets.all(7),
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 1.6,
                    color: Colors.orange,
                  ),
                )
                : Icon(
                  isDownloaded
                      ? Icons.download_done_rounded
                      : Icons.download_rounded,
                  size: 14,
                  color: isDownloaded ? Colors.green : primary,
                ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // النص
  // ══════════════════════════════════════════════════════

  Widget _buildTextContent(
    BuildContext context,
    double cardW,
    bool isDownloaded,
    bool isDownloading,
  ) {
    return SizedBox(
      width: cardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            style: GoogleFonts.cairo(
              fontSize: (cardW * 0.09).clamp(9.0, 14.0),
              fontWeight: FontWeight.w700,
              color: RecColors.textPrimary(context),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            isDownloading
                ? 'جاري التحميل...'
                : isDownloaded
                ? 'محمّل على الجهاز'
                : item.subtitle,
            style: GoogleFonts.cairo(
              fontSize: (cardW * 0.075).clamp(8.0, 11.0),
              color:
                  isDownloaded
                      ? Colors.green
                      : isDownloading
                      ? Colors.orange
                      : RecColors.textSecondary(context),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // الصورة
  // ══════════════════════════════════════════════════════

  Widget _buildImage(double w, double h) {
    if (item.imageUrl != null &&
        item.imageUrl!.isNotEmpty &&
        Uri.tryParse(item.imageUrl!)?.hasScheme == true) {
      return CachedImageWidget(
        imageUrl: item.imageUrl,
        width: w,
        height: h,
        fit: BoxFit.cover,
        placeholder: _buildFallback(w, h),
        errorWidget: _buildFallback(w, h),
      );
    }

    if (item.imageAsset != null && item.imageAsset!.isNotEmpty) {
      return CachedImageWidget(
        imageAsset: item.imageAsset,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorWidget: _buildFallback(w, h),
      );
    }

    return _buildFallback(w, h);
  }

  Widget _buildFallback(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: RecColors.fallbackGradient(gradientColors),
      ),
      child: Center(
        child: Text(item.emoji, style: TextStyle(fontSize: h * 0.35)),
      ),
    );
  }
}
