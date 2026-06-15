import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import '../models/deed_model.dart';

class HasanatDeedCard extends StatelessWidget {
  final int index;
  final DeedModel deed;
  final bool isDark;
  final bool isSmall;
  final Color textColor;
  final Color subColor;
  final Map<String, int> progressCounters;
  final Function(int) onAddDeed;

  const HasanatDeedCard({
    super.key,
    required this.index,
    required this.deed,
    required this.isDark,
    required this.isSmall,
    required this.textColor,
    required this.subColor,
    required this.progressCounters,
    required this.onAddDeed,
  });

  @override
  Widget build(BuildContext context) {
    final type = deed.type;
    final target = deed.target;
    final currentProgress = progressCounters[type] ?? 0;
    final progressValue = target > 1 ? (currentProgress / target) : 0.0;
    final accentColor = Color(deed.color);

    final bgCard = isDark ? const Color(0xFF151B26) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : accentColor.withValues(alpha: 0.15);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRewardHeader(accentColor),
            _buildContent(
              context,
              accentColor,
              type,
              target,
              currentProgress,
              progressValue,
            ),
          ],
        ),
      ),
    );
  }

  // âœ… ظ‡ظٹط¯ط± ط§ظ„ط¬ط§ط¦ط²ط©
  Widget _buildRewardHeader(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isSmall ? 8 : 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border(
          bottom: BorderSide(color: accentColor.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          FittedBox(
            child: Text(
              deed.icon,
              style: TextStyle(fontSize: isSmall ? 18 : 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              deed.reward,
              style: GoogleFonts.cairo(
                fontSize: isSmall ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // âœ… ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط±ط¦ظٹط³ظٹ
  Widget _buildContent(
      BuildContext context,
    Color accentColor,
    String type,
    int target,
    int currentProgress,
    double progressValue,
  ) {
    return Padding(
      padding: EdgeInsets.all(isSmall ? 14 : 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ط§ظ„ط°ظƒط±
          Text(
            deed.title,
            style: GoogleFonts.amiri(
              fontSize: isSmall ? 18 : 22,
              height: 1.8,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // ط§ظ„ط­ط¯ظٹط«
          _buildHadithBox(accentColor),
          const SizedBox(height: 16),

          // ط§ظ„طھظ‚ط¯ظ… ظˆط§ظ„ط²ط±
          _buildProgressAndButton(
            context,         // ًں‘ˆ ظ†ظ…ط±ط± ط§ظ„ظ€ context ظ‡ظ†ط§ ظپظٹ ط§ظ„ط¨ط¯ط§ظٹط©
            accentColor,
            target,
            currentProgress,
            progressValue,
          ),
        ],
      ),
    );
  }

  // âœ… طµظ†ط¯ظˆظ‚ ط§ظ„ط­ط¯ظٹط«
  Widget _buildHadithBox(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.04)
                : accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : accentColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            deed.hadith,
            style: GoogleFonts.cairo(
              fontSize: isSmall ? 11 : 12,
              color: subColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 12,
                color: accentColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  deed.source,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 10 : 11,
                    color: accentColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // âœ… ط§ظ„طھظ‚ط¯ظ… ظˆط²ط± ط§ظ„ط¥ط¶ط§ظپط©
  Widget _buildProgressAndButton(
      BuildContext context, // ًں‘ˆ طھظ… ط¥ط¶ط§ظپط© context ظ‡ظ†ط§
      Color accentColor,
      int target,
      int currentProgress,
      double progressValue,
      ) {
    return Row(
      children: [
        if (target > 1) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr.progressLabel, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 10 : 11,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 7,
                    backgroundColor:
                    isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$currentProgress / $target',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: () => onAddDeed(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: target > 1 ? 16 : 24,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: accentColor,
                  size: 20,
                ),
                if (target <= 1) ...[
                  const SizedBox(width: 6),
                  FittedBox(
                    child: Text(
                      context.tr.addButton, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                      style: GoogleFonts.cairo(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 12 : 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
