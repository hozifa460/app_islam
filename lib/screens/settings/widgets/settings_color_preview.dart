import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';

class SettingsColorPreview extends StatelessWidget {
  final SettingsTheme theme;
  final double w;
  final List<Color> appColors;
  final List<String> colorNames;
  final int selectedColor;

  const SettingsColorPreview({
    super.key,
    required this.theme,
    required this.w,
    required this.appColors,
    required this.colorNames,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconIndex = selectedColor < SettingsTheme.colorIcons.length ? selectedColor : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.05).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.currentPrimary,
          Color.lerp(theme.currentPrimary, Colors.black, 0.35)!,
        ], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        boxShadow: [BoxShadow(color: theme.currentPrimary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.14).clamp(48.0, 62.0),
            height: (w * 0.14).clamp(48.0, 62.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
              child: Icon(SettingsTheme.colorIcons[iconIndex],
                  key: ValueKey('preview_$selectedColor'),
                  color: Colors.white, size: (w * 0.07).clamp(24.0, 32.0)),
            ),
          ),
          SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                context.tr.currentColorLabel, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                style: GoogleFonts.cairo(fontSize: (w * 0.03).clamp(10.0, 13.0), color: Colors.white70)
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                  colorNames[selectedColor], // ًں‘ˆ ظ‡ط°ط§ ط§ظ„ط§ط³ظ… ظٹظپطھط±ط¶ ط£ظ†ظ‡ ظٹط£طھظٹ ظ…طھط±ط¬ظ…ط§ظ‹ ظ…ظ† ط§ظ„ظ…طµط¯ط± ط§ظ„ط®ط§ط±ط¬ظٹ
                  key: ValueKey('name_$selectedColor'),
                  style: GoogleFonts.cairo(fontSize: (w * 0.05).clamp(17.0, 22.0), fontWeight: FontWeight.w800, color: Colors.white)
              ),
            ),
          ])),
        ]),
        SizedBox(height: (w * 0.04).clamp(12.0, 20.0)),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.04).clamp(12.0, 18.0),
                vertical: (w * 0.03).clamp(10.0, 14.0),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _previewElement(context.tr.previewButtons, Icons.touch_app_rounded), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  _previewElement(context.tr.previewCards, Icons.credit_card_rounded), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  _previewElement(context.tr.previewIcons, Icons.star_rounded), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  _previewElement(context.tr.previewBar, Icons.linear_scale_rounded), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: (w * 0.03).clamp(10.0, 16.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(appColors.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: i == selectedColor ? 20 : 8, height: 5,
            decoration: BoxDecoration(
              color: i == selectedColor ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ]),
    );
  }

  Widget _previewElement(String label, IconData icon) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: (w * 0.055).clamp(18.0, 24.0)),
      SizedBox(height: (w * 0.01).clamp(3.0, 6.0)),
      Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: (w * 0.025).clamp(8.5, 11.0))),
    ]);
  }
}