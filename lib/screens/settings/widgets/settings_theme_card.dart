import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';
import 'settings_shared_widgets.dart';

class SettingsThemeCard extends StatelessWidget {
  final SettingsTheme theme;
  final double w;
  final bool isDark;
  final Function(bool) onToggle;

  const SettingsThemeCard({
    super.key,
    required this.theme,
    required this.w,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      theme: theme,
      w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggle(context), // ًں‘ˆ طھظ…ط±ظٹط± context
          SettingsDivider(theme: theme),
          _buildPreview(context), // ًں‘ˆ طھظ…ط±ظٹط± context
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all((w * 0.04).clamp(12.0, 20.0)),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.12).clamp(42.0, 54.0),
            height: (w * 0.12).clamp(42.0, 54.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A2744), const Color(0xFF0D1420)]
                    : [const Color(0xFFFFF8E7), const Color(0xFFFFE082)],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : SettingsTheme.gold.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.blue : SettingsTheme.gold)
                      .withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                key: ValueKey(isDark),
                isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                color: isDark ? Colors.white : SettingsTheme.gold,
                size: (w * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
          SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey(isDark),
                    isDark ? context.tr.darkModeLabel : context.tr.lightModeLabel, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.038).clamp(13.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: theme.textColor,
                    ),
                  ),
                ),
                Text(
                  isDark
                      ? context.tr.darkModeDesc
                      : context.tr.lightModeDesc, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 12.5),
                    color: theme.textColor.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
          SettingsCustomSwitch(
              value: isDark, onChanged: onToggle, theme: theme),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (w * 0.04).clamp(12.0, 20.0), 0,
        (w * 0.04).clamp(12.0, 20.0), (w * 0.04).clamp(12.0, 20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr.previewCurrentMode, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                fontSize: (w * 0.03).clamp(10.0, 13.0),
                color: theme.textColor.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
              )),
          SizedBox(height: (w * 0.025).clamp(8.0, 14.0)),
          Row(children: [
            _previewBox(isDarkPreview: true, isActive: isDark, label: context.tr.darkLabel), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
            SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
            _previewBox(isDarkPreview: false, isActive: !isDark, label: context.tr.lightLabel), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
          ]),
        ],
      ),
    );
  }

  Widget _previewBox({
    required bool isDarkPreview,
    required bool isActive,
    required String label,
  }) {
    final boxH = (w * 0.22).clamp(70.0, 100.0);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onToggle(isDarkPreview);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: boxH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDarkPreview
                ? const Color(0xFF0A0E17)
                : const Color(0xFFF0F4FF),
            border: Border.all(
              color: isActive ? theme.currentPrimary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: theme.currentPrimary.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: boxH * 0.35,
                  color: isDarkPreview ? const Color(0xFF151B26) : Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: boxH * 0.15, height: boxH * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.currentPrimary.withValues(alpha: 0.3),
                          ),
                        ),
                        SizedBox(width: boxH * 0.06),
                        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: boxH * 0.4, height: 4, decoration: BoxDecoration(color: isDarkPreview ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 3),
                          Container(width: boxH * 0.25, height: 3, decoration: BoxDecoration(color: isDarkPreview ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
                        ]),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: isDarkPreview ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
                    padding: const EdgeInsets.all(6),
                    child: Row(children: List.generate(2, (_) => Expanded(
                      child: Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(
                        color: isDarkPreview ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      )),
                    ))),
                  ),
                ),
              ]),
              if (isActive)
                Positioned(top: 6, left: 6, child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.currentPrimary,
                    boxShadow: [BoxShadow(color: theme.currentPrimary.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                )),
            ]),
          ),
        ),
      ),
    );
  }
}