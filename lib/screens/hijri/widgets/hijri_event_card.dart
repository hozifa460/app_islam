import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'hijri_theme.dart';
import 'hijri_shared_widgets.dart';

class HijriEventCard extends StatelessWidget {
  final Map<String, String> event;
  final HijriTheme theme;
  final bool compact;
  final AnimationController pulseController;
  final VoidCallback onShare;

  const HijriEventCard({
    super.key,
    required this.event,
    required this.theme,
    required this.compact,
    required this.pulseController,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.primaryColor.withValues(alpha: theme.isDark ? 0.15 : 0.08),
            HijriTheme.gold.withValues(alpha: theme.isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(HijriTheme.cardRadius),
        border: Border.all(color: HijriTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              HijriIconBtn(
                icon: Icons.share_rounded,
                color: theme.primaryColor,
                onTap: onShare,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HijriBadge(text: context.tr.todaysEvent, color: HijriTheme.gold), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          event['title']!,
                          style: GoogleFonts.cairo(
                            fontSize: compact ? 15 : 17,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, __) => Transform.scale(
                          scale: 1 + (pulseController.value * 0.12),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: HijriTheme.gold,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HijriDivider(color: HijriTheme.gold),
          const SizedBox(height: 12),
          Text(
            event['desc']!,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: compact ? 12 : 13,
              height: 1.8,
              color: theme.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}