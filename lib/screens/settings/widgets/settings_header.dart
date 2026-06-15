import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';

class SettingsHeader extends StatelessWidget {
  final SettingsTheme theme;
  final double w;
  final VoidCallback onBack;

  const SettingsHeader({
    super.key,
    required this.theme,
    required this.w,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (w * 0.045).clamp(14.0, 24.0),
        (w * 0.04).clamp(12.0, 22.0),
        (w * 0.045).clamp(14.0, 24.0),
        (w * 0.02).clamp(8.0, 16.0),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: (w * 0.1).clamp(36.0, 46.0),
              height: (w * 0.1).clamp(36.0, 46.0),
              decoration: BoxDecoration(
                color: theme.backBtnBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.backBtnBorder),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: theme.textColor,
                  size: (w * 0.045).clamp(14.0, 20.0)),
            ),
          ),
          SizedBox(width: (w * 0.035).clamp(10.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr.settingsTitle, style: theme.titleStyle(w)),
                Text(context.tr.settingsSubtitle, style: theme.subtitleStyle(w)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.11).clamp(38.0, 50.0),
            height: (w * 0.11).clamp(38.0, 50.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.currentPrimary.withOpacity(0.12),
              border: Border.all(color: theme.currentPrimary.withOpacity(0.3)),
            ),
            child: Icon(Icons.settings_rounded,
                color: theme.currentPrimary,
                size: (w * 0.055).clamp(18.0, 26.0)),
          ),
        ],
      ),
    );
  }
}