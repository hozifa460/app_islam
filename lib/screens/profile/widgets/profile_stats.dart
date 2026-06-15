import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/stats_service.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // â•گâ•گâ•گ ط£ظٹط§ظ… ط§ظ„ط¯ط®ظˆظ„ ط§ظ„ظƒظ„ظٹط© â•گâ•گâ•گ
            _StatItem(
              icon: Icons.calendar_today_rounded,
              color: Colors.blue,
              value: '${stats.totalDays}',
              label: 'ظٹظˆظ… ط¯ط®ظ„طھ',
              isDark: isDark,
            ),

            _Divider(isDark: isDark),

            // â•گâ•گâ•گ ط§ظ„ط³ظ„ط³ظ„ط© â•گâ•گâ•گ
            _StatItem(
              icon: Icons.local_fire_department_rounded,
              color: stats.streak >= 3
                  ? Colors.deepOrange
                  : Colors.grey,
              value: '${stats.streak}',
              label: 'ظٹظˆظ… ظ…طھظˆط§طµظ„',
              isDark: isDark,
              badge: _streakBadge(stats.streak),
            ),
          ],
        ),
      ),
    );
  }

  String? _streakBadge(int streak) {
    if (streak >= 30) return 'ًںڈ†';
    if (streak >= 14) return 'ًں’ژ';
    if (streak >= 7) return 'ًں”¥';
    if (streak >= 3) return 'â­گ';
    return null;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool isDark;
  final String? badge;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.isDark,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ط§ظ„ط£ظٹظ‚ظˆظ†ط©
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(height: 8),

          // ط§ظ„ظ‚ظٹظ…ط© ظ…ط¹ ط§ظ„ط´ط§ط±ط©
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Text(badge!, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),

          // ط§ظ„طھط³ظ…ظٹط©
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.grey.shade200,
    );
  }
}