// lib/screens/radio/widgets_radio_screen/recent_listening_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/listening_history_service.dart';
import 'package:islamic_app/screens/radio/widgets/station_image_widget.dart';
import 'package:provider/provider.dart';

import '../data/radio_data.dart';

class RecentListeningWidget extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final AnimationController equalizerController;
  final VoidCallback onStationPlayed;

  const RecentListeningWidget({
    super.key,
    required this.primary,
    required this.isTablet,
    required this.equalizerController,
    required this.onStationPlayed,
  });

  static const Color _gold = Color(0xFFC8A44D);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Selector<ListeningHistoryService, List<ListeningHistoryItem>>(
      selector: (_, historyService) =>
      List<ListeningHistoryItem>.unmodifiable(
        historyService.history.take(8).toList(),
      ),
      builder: (_, items, __) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.25),
                          _gold.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('🕐', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'آخر ما استمعت إليه',
                          style: GoogleFonts.cairo(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${items.length} عنصر',
                          style: GoogleFonts.cairo(
                            fontSize: isTablet ? 11 : 10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showClearDialog(
                      context,
                      context.read<ListeningHistoryService>(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        'مسح',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: isTablet ? 160 : 140,
              child: RepaintBoundary(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _buildHistoryCard(
                    context,
                    items[i],
                    isDark,
                    i,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(
      BuildContext context,
      ListeningHistoryItem item,
      bool isDark,
      int index,
      ) {
    final cardW = isTablet ? 160.0 : 140.0;

    return GestureDetector(
      onTap: () => _playItem(context, item),
      onLongPress: () => _showItemOptions(context, item, index),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: StationImageWidget(
                        imageUrl: item.imageUrl,
                        imageAsset: item.imageAsset,
                        fallbackEmoji: item.emoji,
                        primaryColor: primary,
                        goldColor: _gold,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.typeLabel,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.timeAgo,
                    style: GoogleFonts.cairo(
                      fontSize: 9,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playItem(BuildContext context, ListeningHistoryItem item) {
    final coordinator = context.read<AudioCoordinator>();

    IslamicRadioStation? station;
    if (item.stationId != null) {
      station = RadioStationsData.byId(item.stationId!);
    }

    station ??= IslamicRadioStation(
      id: item.audioUrl.hashCode.abs(),
      name: item.title,
      nameEn: item.title,
      url: item.audioUrl,
      category: item.type == 'radio' ? 'راديو' : 'تلاوات',
      categoryEn: 'Recitations',
      description: item.subtitle,
      descriptionEn: item.subtitle,
      iconEmoji: item.emoji,
      imageUrl: item.imageUrl,
      imageAsset: item.imageAsset,
    );

    switch (item.type) {
      case 'radio':
        coordinator.playOnlineRadio(station);
        onStationPlayed();
        break;
      case 'surah':
        if (item.surahNumber != null) {
          coordinator.playOnlineSurah(
            station: station,
            surahNumber: item.surahNumber!,
          );
        }
        break;
      case 'local':
        coordinator.playLocalItem(station: station);
        break;
      default:
        coordinator.playOnlineRadio(station);
        onStationPlayed();
    }
  }

  void _showItemOptions(
      BuildContext context,
      ListeningHistoryItem item,
      int index,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyService = context.read<ListeningHistoryService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _playItem(context, item);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تشغيل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                historyService.removeItem(index);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'حذف من السجل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(
      BuildContext context,
      ListeningHistoryService service,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'مسح سجل الاستماع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد مسح كل سجل الاستماع؟',
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              service.clearHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'مسح',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}