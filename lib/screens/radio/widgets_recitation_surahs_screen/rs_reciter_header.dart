// lib/screens/radio/widgets_surahs/rs_reciter_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';
import 'package:provider/provider.dart';
import 'rs_stat_chip.dart';

/// ══════════════════════════════════════════════════════════════
/// Header معلومات القارئ + إحصائيات + زر الراديو
/// ══════════════════════════════════════════════════════════════
class RsReciterHeader extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final bool isDark;

  const RsReciterHeader({
    super.key,
    required this.station,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioDownloadService>(
      builder: (_, download, __) {
        final downloaded = download.getDownloadedSurahs(station.id);
        final isDownloading =
            download.getStatus(station.id) == DownloadStatus.downloading;
        final progress = download.getProgress(station.id);
        final info = download.getInfo(station.id);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: RsShapes.reciterHeader(primary, context),
          child: Column(
            children: [
              _buildTopRow(context, downloaded.length),
              if (isDownloading)
                _buildDownloadProgress(
                  context,
                  download,
                  progress,
                  info,
                ),
              if (downloaded.isNotEmpty && !isDownloading)
                _buildRadioButton(context, downloaded.length),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // الصف العلوي: أيقونة + إحصائيات
  // ══════════════════════════════════════════════════════════════
  Widget _buildTopRow(BuildContext context, int downloadedCount) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        Expanded(child: _buildStats(context, downloadedCount)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // أيقونة القارئ
  // ══════════════════════════════════════════════════════════════
  Widget _buildIcon() {
    return Container(
      width: RsSizes.reciterIconSize,
      height: RsSizes.reciterIconSize,
      decoration: RsShapes.reciterIcon(primary),
      child: Center(
        child: Text(
          station.iconEmoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // شرائح الإحصائيات
  // ══════════════════════════════════════════════════════════════
  Widget _buildStats(BuildContext context, int downloadedCount) {
    final download = context.read<RadioDownloadService>();
    return Row(
      children: [
        // ✅ محملة
        RsStatChip(
          value: '$downloadedCount',
          label: 'محملة',
          color: Colors.green,
        ),
        const SizedBox(width: 6),

        // ✅ متبقية
        RsStatChip(
          value: '${114 - downloadedCount}',
          label: 'متبقية',
          color: primary,
        ),

        // ✅ المساحة المستخدمة
        if (downloadedCount > 0) ...[
          const SizedBox(width: 6),
          FutureBuilder<String>(
            future: download.getStorageSize(station.id),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return RsStatChip(
                value: snap.data!,
                label: 'مساحة',
                color: Colors.orange,
              );
            },
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // شريط تقدم التحميل
  // ══════════════════════════════════════════════════════════════
  Widget _buildDownloadProgress(
      BuildContext context,
      RadioDownloadService download,
      double progress,
      dynamic info,
      ) {
    return Column(
      children: [
        const SizedBox(height: 10),

        Row(
          children: [
            // ══ شريط التقدم ══
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: RsColors.primary(primary, 0.1), // ✅ من RsColors
                  valueColor: AlwaysStoppedAnimation(primary),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ══ زر الإلغاء ══
            GestureDetector(
              onTap: () => download.cancelDownload(station.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: RsShapes.cancelBtn(),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    fontSize: RsSizes.cancelBtnSize,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ══ نص التقدم ══
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'جاري تحميل ${info?.downloadedCount ?? 0} من ${info?.totalToDownload ?? 0}',
            style: GoogleFonts.cairo(
              fontSize: RsSizes.downloadProgressSize,
              color: RsColors.textMuted(context), // ✅ context بدلاً من isDark
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // زر تشغيل الراديو
  // ══════════════════════════════════════════════════════════════
  Widget _buildRadioButton(BuildContext context, int downloadedCount) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Consumer<OfflineRadioService>(
          builder: (_, offline, __) {
            final isCurrentStation =
                offline.currentStation?.id == station.id;
            final isRadioPlaying = isCurrentStation &&
                offline.isPlaying &&
                offline.playMode == OfflinePlayMode.radio;

            return GestureDetector(
              onTap: () {
                if (isRadioPlaying) {
                  offline.pause();
                } else if (isCurrentStation &&
                    offline.playMode == OfflinePlayMode.radio) {
                  offline.resume();
                } else {
                  context
                      .read<AudioCoordinator>()
                      .playOfflineRadio(station);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: RsShapes.radioPlayBtn(primary),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ══ أيقونة ══
                    Icon(
                      isRadioPlaying
                          ? Icons.pause_rounded
                          : Icons.shuffle_rounded,
                      color: Colors.white, // ✅ أبيض دائماً على خلفية primary
                      size: 18,
                    ),
                    const SizedBox(width: 8),

                    // ══ نص الزر ══
                    Flexible(
                      child: Text(
                        isRadioPlaying
                            ? 'إيقاف مؤقت'
                            : 'تشغيل كراديو ($downloadedCount سورة)',
                        style: GoogleFonts.cairo(
                          fontSize: RsSizes.radioPlayBtnSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // ✅ أبيض دائماً على خلفية primary
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}