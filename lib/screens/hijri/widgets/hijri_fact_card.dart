import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'hijri_theme.dart';
import 'hijri_shared_widgets.dart';

class HijriFactCard extends StatelessWidget {
  final String fact;
  final HijriTheme theme;
  final bool compact;
  final VoidCallback onShare;
  final VoidCallback onRefresh;

  const HijriFactCard({
    super.key,
    required this.fact,
    required this.theme,
    required this.compact,
    required this.onShare,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HijriTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              HijriIconBtn(
                icon: Icons.share_rounded,
                color: HijriTheme.gold,
                onTap: onShare,
              ),
              const SizedBox(width: 8),
              HijriIconBtn(
                icon: Icons.refresh_rounded,
                color: HijriTheme.gold,
                onTap: onRefresh,
              ),
              const Spacer(),
              Text(
                context.tr.didYouKnow, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                style: GoogleFonts.cairo(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: HijriTheme.gold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: compact ? 36 : 42,
                height: compact ? 36 : 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    HijriTheme.gold.withValues(alpha: 0.12),
                    HijriTheme.gold.withValues(alpha: 0.04),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: HijriTheme.gold,
                  size: compact ? 16 : 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HijriDivider(color: HijriTheme.gold),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              fact,
              key: ValueKey(fact),
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: compact ? 12 : 13,
                height: 1.8,
                color: theme.isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}