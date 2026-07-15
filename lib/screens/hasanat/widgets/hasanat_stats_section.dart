import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import '../models/deed_model.dart';

class HasanatStatsSection extends StatelessWidget {
  final bool isDark;
  final bool isSmall;
  final Color textColor;
  final Color gold;
  final Color bgCard;
  final int palmTrees;
  final int palaces;
  final int hasanat;
  final int jewels;
  final int lights;
  final int doors;
  final int shields;
  final int scales;
  final Animation<double> bounceAnim;
  final int lastTappedIndex;
  final List<DeedModel> deeds;

  const HasanatStatsSection({
    super.key,
    required this.isDark,
    required this.isSmall,
    required this.textColor,
    required this.gold,
    required this.bgCard,
    required this.palmTrees,
    required this.palaces,
    required this.hasanat,
    required this.jewels,
    required this.lights,
    required this.doors,
    required this.shields,
    required this.scales,
    required this.bounceAnim,
    required this.lastTappedIndex,
    required this.deeds,
  });

  String _getTypeFromTitle(BuildContext context, String title) { // ًں‘ˆ طھظ… ط¥ط¶ط§ظپط© context ظ‡ظ†ط§
    if (title.contains(context.tr.statPalmTrees)) return 'palm';     // ًں‘ˆ ظٹط¨ط­ط« ط¹ظ† ط§ظ„طھط±ط¬ظ…ط© ط§ظ„ط­ط§ظ„ظٹط©
    if (title.contains(context.tr.statPalaces)) return 'palace';
    if (title.contains(context.tr.statTreasures)) return 'jewel';    // ط§ط³طھط®ط¯ظ…ظ†ط§ ظƒظ†ظˆط² (Treasures)
    if (title.contains(context.tr.statLights)) return 'light';
    if (title.contains(context.tr.statDoors)) return 'door';
    if (title.contains(context.tr.statShields)) return 'shield';
    if (title.contains(context.tr.statScales)) return 'scale';
    return 'hasana';
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': context.tr.statPalmTrees, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': palmTrees,
        'icon': '🌴',
        'color': Colors.green
      },
      {
        'title': context.tr.statPalaces, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': palaces,
        'icon': '🏰',
        'color': gold
      },
      {
        'title': context.tr.statTreasures, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': jewels,
        'icon': '💎',
        'color': Colors.blue
      },
      {
        'title': context.tr.statLights, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': lights,
        'icon': '✨',
        'color': Colors.orange
      },
      {
        'title': context.tr.statDoors, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': doors,
        'icon': '🚪',
        'color': Colors.brown
      },
      {
        'title': context.tr.statShields, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': shields,
        'icon': '🛡️',
        'color': Colors.teal
      },
      {
        'title': context.tr.statScales, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': scales,
        'icon': '⚖️',
        'color': Colors.purple
      },
      {
        'title': context.tr.statHasanat, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        'count': hasanat,
        'icon': '📿',
        'color': Colors.cyan
      },
    ];

    final cardBg = isDark ? bgCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.08) : gold.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth < 280 ? 3 : 4;
          final spacing = isSmall ? 8.0 : 10.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (crossCount - 1)) /
                  crossCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: stats.map((stat) {
              final type =
              _getTypeFromTitle(context,stat['title'] as String);
              final isAnimating = lastTappedIndex != -1 &&
                  lastTappedIndex < deeds.length &&
                  deeds[lastTappedIndex].type == type;

              return _StatItem(
                stat: stat,
                itemWidth: itemWidth,
                isSmall: isSmall,
                isDark: isDark,
                textColor: textColor,
                isAnimating: isAnimating,
                bounceAnim: bounceAnim,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final Map<String, dynamic> stat;
  final double itemWidth;
  final bool isSmall;
  final bool isDark;
  final Color textColor;
  final bool isAnimating;
  final Animation<double> bounceAnim;

  const _StatItem({
    required this.stat,
    required this.itemWidth,
    required this.isSmall,
    required this.isDark,
    required this.textColor,
    required this.isAnimating,
    required this.bounceAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bounceAnim,
      builder: (context, child) => Transform.scale(
        scale: isAnimating ? bounceAnim.value : 1.0,
        child: child,
      ),
      child: SizedBox(
        width: itemWidth,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: isSmall ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: (stat['color'] as Color)
                .withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (stat['color'] as Color).withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat['icon'] as String,
                  style: TextStyle(fontSize: isSmall ? 18 : 22),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${stat['count']}',
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat['title'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}