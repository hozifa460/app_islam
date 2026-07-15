import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color_control/miracle_theme.dart';
import 'miracle_helpers.dart';

class FilterSectionWidget extends StatelessWidget {
  final String               selectedFilter;
  final String               selectedCategory;
  final List<String>         categories;
  final MiracleThemeColors   t;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onCategoryChanged;

  const FilterSectionWidget({
    super.key,
    required this.selectedFilter,
    required this.selectedCategory,
    required this.categories,
    required this.t,
    required this.onFilterChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // â”€â”€ Type filter (3 chips) â”€â”€
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label:    'الكل',
                  icon:     Icons.apps_rounded,
                  selected: selectedFilter == 'all',
                  color:    MiracleTheme.neonBlue,
                  t:        t,
                  onTap:    () => onFilterChanged('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label:    'القرآن',
                  icon:     Icons.menu_book_rounded,
                  selected: selectedFilter == 'quran',
                  color:    const Color(0xFF4FC3F7),
                  t:        t,
                  onTap:    () => onFilterChanged('quran'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label:    'السنة',
                  icon:     Icons.auto_awesome_rounded,
                  selected: selectedFilter == 'sunnah',
                  color:    MiracleTheme.neonGold,
                  t:        t,
                  onTap:    () => onFilterChanged('sunnah'),
                ),
              ),
            ],
          ),
        ),

        // â”€â”€ Category horizontal scroll â”€â”€
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection:  Axis.horizontal,
            physics:          const BouncingScrollPhysics(),
            padding:          const EdgeInsets.symmetric(horizontal: 16),
            itemCount:        categories.length + 1, // +1 for "all"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryPill(
                  label:    'الكل',
                  selected: selectedCategory == 'all',
                  color:    MiracleTheme.neonBlue,
                  t:        t,
                  onTap:    () => onCategoryChanged('all'),
                );
              }
              final cat = categories[index - 1];
              return _CategoryPill(
                label:    cat,
                selected: selectedCategory == cat,
                color:    MiracleHelpers.getCategoryColor(cat),
                t:        t,
                onTap:    () => onCategoryChanged(cat),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final bool         selected;
  final Color        color;
  final MiracleThemeColors t;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : t.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : t.glassBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size:  14,
                color: selected ? color : t.mutedText),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color:      selected ? color : t.mutedText,
                  fontWeight: FontWeight.bold,
                  fontSize:   12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String       label;
  final bool         selected;
  final Color        color;
  final MiracleThemeColors t;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.color,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : t.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : t.glassBorder,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color:      selected ? color : t.mutedText,
            fontWeight: FontWeight.bold,
            fontSize:   11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}