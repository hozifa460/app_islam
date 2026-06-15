// lib/screens/radio/widgets_surahs/rs_mini_player.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/surah_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// المشغل المصغر
/// ══════════════════════════════════════════════════════════════
class RsMiniPlayer extends StatelessWidget {
  final OfflineRadioService offline;
  final IslamicRadioStation station;
  final Color primary;
  final bool isDark;

  const RsMiniPlayer({
    super.key,
    required this.offline,
    required this.station,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (offline.currentSurah != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahPlayerScreen(
                station: station,
                surahNumber: offline.currentSurahNumber,
                primary: primary,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: RsShapes.miniPlayer(primary, context),
        child: Row(
          children: [
            // ══ أيقونة الموسيقى ══
            Icon(
              Icons.music_note_rounded,
              color: primary,
              size: RsSizes.miniPlayerMusicIconSize,
            ),
            const SizedBox(width: 10),

            // ══ معلومات السورة ══
            Expanded(child: _buildInfo(context)),

            // ══ زر التشغيل ══
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // معلومات السورة الحالية
  // ══════════════════════════════════════════════════════════════
  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ══ اسم السورة ══
        Text(
          offline.currentSurahName,
          style: GoogleFonts.cairo(
            fontSize: RsSizes.miniPlayerNameSize,
            fontWeight: FontWeight.w700,
            color: RsColors.textPrimary(context), // ✅ من RsColors
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // ══ الوقت الحالي ══
        Text(
          offline.formatDuration(offline.position),
          style: GoogleFonts.cairo(
            fontSize: RsSizes.miniPlayerTimeSize,
            color: RsColors.textSecondary(context), // ✅ من RsColors
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // زر التشغيل / الإيقاف
  // ══════════════════════════════════════════════════════════════
  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: offline.togglePlayPause,
      child: Container(
        width: RsSizes.miniPlayerPlayBtnSize,
        height: RsSizes.miniPlayerPlayBtnSize,
        decoration: RsShapes.miniPlayerPlayBtn(primary),
        child: Icon(
          offline.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white, // ✅ أبيض دائماً على خلفية primary
          size: 20,
        ),
      ),
    );
  }
}