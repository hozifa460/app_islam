import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';

class SettingsAboutCard extends StatelessWidget {
  final SettingsTheme theme;
  final double w;

  const SettingsAboutCard({super.key, required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.05).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.currentPrimary.withValues(alpha: theme.isDark ? 0.15 : 0.08),
          theme.currentPrimary.withValues(alpha: theme.isDark ? 0.05 : 0.03),
        ], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        border: Border.all(color: theme.currentPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: (w * 0.18).clamp(60.0, 80.0),
          height: (w * 0.18).clamp(60.0, 80.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              theme.currentPrimary.withValues(alpha: 0.2),
              theme.currentPrimary.withValues(alpha: 0.05),
            ]),
            border: Border.all(color: theme.currentPrimary.withValues(alpha: 0.4), width: 2),
            boxShadow: [BoxShadow(color: theme.currentPrimary.withValues(alpha: 0.2), blurRadius: 16, spreadRadius: 2)],
          ),
          child: Icon(Icons.mosque_rounded, color: theme.currentPrimary, size: (w * 0.09).clamp(28.0, 40.0)),
        ),
        SizedBox(height: (w * 0.03).clamp(10.0, 16.0)),
        Text(
            context.tr.developerLabel,
            style: GoogleFonts.amiri(
            fontSize: (w * 0.055).clamp(18.0, 26.0), fontWeight: FontWeight.bold, color: theme.currentPrimary)),
        SizedBox(height: (w * 0.015).clamp(5.0, 10.0)),
        Text( context.tr.worshipCompanion, style: GoogleFonts.cairo(fontSize: (w * 0.032).clamp(11.0, 14.0), color: theme.textColor.withValues(alpha: 0.6)), textAlign: TextAlign.center),
        SizedBox(height: (w * 0.02).clamp(8.0, 14.0)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: EdgeInsets.symmetric(horizontal: (w * 0.04).clamp(12.0, 20.0), vertical: (w * 0.025).clamp(8.0, 14.0)),
          decoration: BoxDecoration(
            color: theme.currentPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.currentPrimary.withValues(alpha: 0.2)),
          ),
          child: Text( context.tr.verseRememberAllah,
              style: GoogleFonts.amiri(fontSize: (w * 0.038).clamp(13.0, 17.0), color: theme.currentPrimary.withValues(alpha: 0.85), height: 1.6), textAlign: TextAlign.center),
        ),
        SizedBox(height: (w * 0.025).clamp(8.0, 14.0)),
        Text(context.tr.allRightsReserved2026, style: GoogleFonts.cairo(fontSize: (w * 0.028).clamp(9.5, 12.0), color: theme.textColor.withValues(alpha: 0.35)), textAlign: TextAlign.center),
      ]),
    );
  }
}