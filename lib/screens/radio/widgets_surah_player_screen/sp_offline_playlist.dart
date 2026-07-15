// lib/screens/radio/widgets_surah_player_screen/sp_offline_playlist.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/quran_data.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';
import 'package:provider/provider.dart';

class SpOfflinePlaylist extends StatelessWidget {
  final bool isDark;
  final bool isTablet;
  final Color primary;
  final IslamicRadioStation station;
  final SurahModel currentSurah;
  final void Function(int surahNumber) onPlaySurah;

  const SpOfflinePlaylist({
    super.key,
    required this.isDark,
    required this.isTablet,
    required this.primary,
    required this.station,
    required this.currentSurah,
    required this.onPlaySurah,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<RadioDownloadService, List<int>>(
      selector: (_, download) =>
      download.getDownloadedSurahs(station.id).toList()..sort(),
      shouldRebuild: (prev, next) =>
      prev.length != next.length ||
          (prev.isNotEmpty && next.isNotEmpty && prev.first != next.first),
      builder: (_, downloadedNums, __) {
        if (downloadedNums.isEmpty) return const SizedBox.shrink();

        return Container(
          height: SpSizes.playlistHeight(isTablet),
          margin: EdgeInsets.symmetric(
            horizontal: SpSizes.playlistMargin(isTablet),
          ),
          decoration: SpShapes.playlistContainer(
            primary: primary,
            isDark: isDark,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(downloadedNums.length),
              Expanded(
                child: _buildList(downloadedNums),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          Text(
            'السور المحملة',
            style: GoogleFonts.cairo(
              fontSize: SpSizes.playlistTitleSize(isTablet),
              fontWeight: FontWeight.w700,
              color: SpColors.textTertiary(isDark),
            ),
          ),
          const Spacer(),
          Text(
            '$count سورة',
            style: GoogleFonts.cairo(
              fontSize: SpSizes.playlistCountSize(isTablet),
              color: primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<int> downloadedNums) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      itemCount: downloadedNums.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (_, i) {
        final num = downloadedNums[i];

        SurahModel surah;
        try {
          surah = QuranData.surahByNumber(num);
        } catch (_) {
          return const SizedBox.shrink();
        }

        final isCurrent = currentSurah.number == num;

        return GestureDetector(
          onTap: () => onPlaySurah(num),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 7),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: SpShapes.playlistItem(
              isCurrent: isCurrent,
              primary: primary,
            ),
            child: Text(
              surah.name,
              style: GoogleFonts.cairo(
                fontSize: SpSizes.playlistItemSize(isTablet),
                fontWeight:
                isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent
                    ? Colors.white
                    : SpColors.iconColor(isDark),
              ),
            ),
          ),
        );
      },
    );
  }
}