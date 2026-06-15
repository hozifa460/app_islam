// lib/screens/radio/widgets_recitations/rec_mini_player.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/recitation_surahs_screen.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// المشغل المصغر في أعلى شاشة التلاوات
/// ══════════════════════════════════════════════════════════════
class RecMiniPlayer extends StatelessWidget {
  final OfflineRadioService offline;
  final Color primary;

  const RecMiniPlayer({
    super.key,
    required this.offline,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (offline.currentStation != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecitationSurahsScreen(
                station: offline.currentStation!,
                primary: primary,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: RecShapes.miniPlayer(context,primary),
        child: Row(
          children: [
            _buildIcon(context),
            const SizedBox(width: 10),
            Expanded(child: _buildInfo(context)),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: RecSizes.miniPlayerIconSize,
      height: RecSizes.miniPlayerIconSize,
      decoration: RecShapes.miniPlayerIcon(context,primary),
      child: Center(
        child: Text(
          offline.currentStation?.iconEmoji ?? '🎵',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          offline.currentSurahName,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: RecColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          offline.currentStation?.name ?? '',
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: RecColors.textSecondary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: offline.togglePlayPause,
      child: Container(
        width: RecSizes.miniPlayerPlayBtnSize,
        height: RecSizes.miniPlayerPlayBtnSize,
        decoration: RecShapes.miniPlayerPlayBtn(primary),
        child: Icon(
          offline.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}