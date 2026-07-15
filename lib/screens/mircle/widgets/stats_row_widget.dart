import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color_control/miracle_theme.dart';

class StatsRowWidget extends StatelessWidget {
  final int  quranCount, sunnahCount, favCount, totalCount;
  final bool showFavoritesOnly;
  final MiracleThemeColors t;
  final VoidCallback onFavoriteToggle;

  const StatsRowWidget({
    super.key,
    required this.quranCount,
    required this.sunnahCount,
    required this.favCount,
    required this.totalCount,
    required this.showFavoritesOnly,
    required this.t,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon:     Icons.menu_book_rounded,
              label:    'القرآن',
              sublabel: 'Quran',
              count:    quranCount,
              color:    const Color(0xFF4FC3F7),
              t:        t,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon:     Icons.auto_awesome_rounded,
              label:    'السنة',
              sublabel: 'Sunnah',
              count:    sunnahCount,
              color:    MiracleTheme.neonGold,
              t:        t,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: _StatCard(
                icon:        Icons.favorite_rounded,
                label:       'المفضلة',
                sublabel:    'Favorites',
                count:       favCount,
                color:       MiracleTheme.neonRed,
                t:           t,
                highlighted: showFavoritesOnly,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon:     Icons.library_books_rounded,
              label:    'الإجمالي',
              sublabel: 'Total',
              count:    totalCount,
              color:    MiracleTheme.neonGreen,
              t:        t,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   label, sublabel;
  final int      count;
  final Color    color;
  final MiracleThemeColors t;
  final bool     highlighted;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.count,
    required this.color,
    required this.t,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.15)
            : t.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.5)
              : t.glassBorder,
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: highlighted
            ? [
          BoxShadow(
            color:       color.withValues(alpha: 0.2),
            blurRadius:  14,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color:     color.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize:   17,
                fontWeight: FontWeight.bold,
                color:      color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize:   10,
                color:      Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              sublabel,
              style: GoogleFonts.poppins(
                fontSize: 8,
                color:    color.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}