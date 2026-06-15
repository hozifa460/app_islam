import 'package:flutter/material.dart';
import '../Constants/sunnah_theme.dart';

class SunnahStatsBar extends StatelessWidget {
  final int totalCategories;
  final int totalSunnahs;
  final bool isDark;

  const SunnahStatsBar({
    super.key,
    required this.totalCategories,
    required this.totalSunnahs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SunnahTheme.gold.withOpacity(isDark ? 0.15 : 0.12),
              SunnahTheme.gold.withOpacity(isDark ? 0.05 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SunnahTheme.gold.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                value: '$totalSunnahs',
                label: 'سنة نبوية',
                icon: Icons.format_list_bulleted_rounded,
                isDark: isDark,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: SunnahTheme.gold.withOpacity(0.3),
            ),
            Expanded(
              child: _StatItem(
                value: '$totalCategories',
                label: 'فئة',
                icon: Icons.category_rounded,
                isDark: isDark,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: SunnahTheme.gold.withOpacity(0.3),
            ),
            Expanded(
              child: _StatItem(
                value: '100%',
                label: 'موثقة',
                icon: Icons.verified_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: SunnahTheme.gold, size: 18),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF7A7A9A),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}