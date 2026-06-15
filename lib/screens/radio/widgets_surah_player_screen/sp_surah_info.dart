// lib/screens/radio/widgets_surah_player/sp_surah_info.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_animations.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

class SpSurahInfo extends StatelessWidget {
  final SurahModel surah;
  final bool isDark;
  final bool isTablet;
  final bool isLooping;
  final Color primary;
  final VoidCallback onToggleLoop;

  const SpSurahInfo({
    super.key,
    required this.surah,
    required this.isDark,
    required this.isTablet,
    required this.isLooping,
    required this.primary,
    required this.onToggleLoop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SpSizes.horizontalPadding(isTablet),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTextInfo()),
          const SizedBox(width: 12),
          _buildLoopButton(),
        ],
      ),
    );
  }

  Widget _buildTextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'سورة ${surah.name}',
          style: GoogleFonts.cairo(
            fontSize: SpSizes.surahNameSize(isTablet),
            fontWeight: FontWeight.w900,
            color: SpColors.textPrimary(isDark),
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${surah.isMakki ? 'مكية' : 'مدنية'} • ${surah.versesCount} آية • الجزء ${surah.juzNumber}',
          style: GoogleFonts.cairo(
            fontSize: SpSizes.surahDetailSize(isTablet),
            color: SpColors.textSecondary(isDark),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLoopButton() {
    final size = SpSizes.loopBtnSize(isTablet);
    return GestureDetector(
      onTap: onToggleLoop,
      child: AnimatedContainer(
        duration: SpAnimationDurations.loopBtn,
        width: size,
        height: size,
        decoration: SpShapes.loopBtn(
          isLooping: isLooping,
          primary: primary,
          isDark: isDark,
        ),
        child: Icon(
          Icons.repeat_one_rounded,
          size: SpSizes.loopIconSize(isTablet),
          color: isLooping ? primary : SpColors.iconSecondary(isDark),
        ),
      ),
    );
  }
}