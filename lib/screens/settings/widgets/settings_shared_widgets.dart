import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_theme.dart';

class SettingsCard extends StatelessWidget {
  final SettingsTheme theme;
  final double w;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.theme,
    required this.w,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        border: Border.all(color: theme.cardBorder),
        boxShadow: theme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        child: child,
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final double w;
  final SettingsTheme theme;

  const SettingsSectionLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.w,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: (w * 0.07).clamp(24.0, 32.0),
          height: (w * 0.07).clamp(24.0, 32.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.currentPrimary.withValues(alpha: 0.12),
            border: Border.all(color: theme.currentPrimary.withValues(alpha: 0.25)),
          ),
          child: Icon(icon,
              color: theme.currentPrimary,
              size: (w * 0.035).clamp(12.0, 16.0)),
        ),
        SizedBox(width: (w * 0.025).clamp(8.0, 14.0)),
        Text(label, style: theme.sectionLabelStyle(w)),
        SizedBox(width: (w * 0.025).clamp(8.0, 14.0)),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.currentPrimary.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsDivider extends StatelessWidget {
  final SettingsTheme theme;
  const SettingsDivider({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.dividerColor,
    );
  }
}

class SettingsInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final double w;
  final SettingsTheme theme;

  const SettingsInfoRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.w,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = (w * 0.1).clamp(34.0, 44.0);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (w * 0.04).clamp(12.0, 20.0),
        vertical: (w * 0.035).clamp(10.0, 16.0),
      ),
      child: Row(
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon,
                color: color, size: (w * 0.048).clamp(16.0, 22.0)),
          ),
          SizedBox(width: (w * 0.035).clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.036).clamp(12.0, 15.0),
                      fontWeight: FontWeight.w700,
                      color: theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(sub,
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.028).clamp(10.0, 12.5),
                      color: theme.textColor.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final bool showArrow;
  final double w;
  final SettingsTheme theme;

  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.onTap,
    this.showArrow = true,
    required this.w,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = (w * 0.1).clamp(34.0, 44.0);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (w * 0.04).clamp(12.0, 20.0),
          vertical: (w * 0.035).clamp(10.0, 16.0),
        ),
        child: Row(
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(icon,
                  color: color, size: (w * 0.048).clamp(16.0, 22.0)),
            ),
            SizedBox(width: (w * 0.035).clamp(10.0, 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.036).clamp(12.0, 15.0),
                        fontWeight: FontWeight.w700,
                        color: theme.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(sub,
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.028).clamp(10.0, 12.5),
                        color: theme.textColor.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: (w * 0.035).clamp(12.0, 16.0),
                  color: theme.textColor.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class SettingsCustomSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final SettingsTheme theme;

  const SettingsCustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? theme.currentPrimary
              : (theme.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.25)),
          boxShadow: value
              ? [
            BoxShadow(
              color: theme.currentPrimary.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              value ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
              size: 13,
              color: value ? theme.currentPrimary : Colors.orange.shade300,
            ),
          ),
        ),
      ),
    );
  }
}