import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color_control/miracle_theme.dart';
import 'miracle_helpers.dart';

class MiracleCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final int                  index;
  final bool                 isFavorite;
  final MiracleThemeColors   t;
  final VoidCallback         onTap;
  final VoidCallback         onFavoriteToggle;

  const MiracleCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isFavorite,
    required this.t,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isQuran     = item['type'] == 'quran';
    final accentColor = isQuran
        ? const Color(0xFF4FC3F7)
        : MiracleTheme.neonGold;
    final category    = (item['category'] ?? '').toString();
    final catColor    = MiracleHelpers.getCategoryColor(category);
    final catIcon     = MiracleHelpers.getCategoryIcon(category);
    final emoji       = MiracleHelpers.getCategoryEmoji(category);
    final rating      = (item['rating'] ?? 0) as int;
    final scientist   = (item['scientist'] ?? '').toString();
    final year        = (item['discoveryYear'] ?? '').toString();
    final sources     = item['sources'];
    final srcCount    = (sources is List) ? sources.length : 0;

    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + (index * 70).clamp(0, 550)),
      curve:    Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child:  child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: catColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color:      catColor.withValues(alpha: 0.06),
              blurRadius: 18,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // BG gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:  Alignment.topRight,
                      end:    Alignment.bottomLeft,
                      colors: [
                        catColor.withValues(alpha: 0.07),
                        t.cardColor,
                      ],
                    ),
                  ),
                ),
              ),

              // Emoji watermark
              Positioned(
                bottom: -8, left: -8,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 60,
                    color:    Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Inkwell content
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:           onTap,
                  splashColor:     catColor.withValues(alpha: 0.08),
                  highlightColor:  catColor.withValues(alpha: 0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopRow(
                          item:            item,
                          catColor:        catColor,
                          catIcon:         catIcon,
                          isFavorite:      isFavorite,
                          t:               t,
                          onFavoriteToggle: onFavoriteToggle,
                        ),
                        const SizedBox(height: 10),
                        _SourcePreview(
                          source:      (item['source'] ?? '').toString(),
                          accentColor: accentColor,
                          t:           t,
                        ),
                        const SizedBox(height: 10),
                        _TagsRow(
                          rating:      rating,
                          srcCount:    srcCount,
                          scientist:   scientist,
                          year:        year,
                          category:    category,
                          catColor:    catColor,
                          accentColor: accentColor,
                          isQuran:     isQuran,
                          t:           t,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Top row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TopRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color catColor;
  final IconData catIcon;
  final bool isFavorite;
  final MiracleThemeColors t;
  final VoidCallback onFavoriteToggle;

  const _TopRow({
    required this.item,
    required this.catColor,
    required this.catIcon,
    required this.isFavorite,
    required this.t,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category icon
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
              colors: [
                catColor.withValues(alpha: 0.2),
                catColor.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: catColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color:     catColor.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(catIcon, color: catColor, size: 22),
        ),
        const SizedBox(width: 12),

        // Title + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      (item['title'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize:   14,
                        fontWeight: FontWeight.bold,
                        color:      Colors.white,
                        shadows: [
                          Shadow(
                            color:     Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Favourite button
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Container(
                        key:   ValueKey(isFavorite),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFavorite
                              ? MiracleTheme.neonRed.withValues(alpha: 0.15)
                              : t.glass,
                          border: Border.all(
                            color: isFavorite
                                ? MiracleTheme.neonRed.withValues(alpha: 0.4)
                                : t.glassBorder,
                          ),
                          boxShadow: isFavorite
                              ? [
                            BoxShadow(
                              color: MiracleTheme.neonRed
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ]
                              : [],
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? MiracleTheme.neonRed
                              : t.mutedText,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                (item['subtitle'] ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color:    t.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Source preview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SourcePreview extends StatelessWidget {
  final String             source;
  final Color              accentColor;
  final MiracleThemeColors t;

  const _SourcePreview({
    required this.source,
    required this.accentColor,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:        accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: accentColor.withValues(alpha: 0.1)),
      ),
      child: Text(
        source,
        maxLines:  2,
        overflow:  TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: GoogleFonts.amiri(
          fontSize:   13,
          height:     1.7,
          color:      Colors.white.withValues(alpha: 0.85),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// â”€â”€ Tags row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TagsRow extends StatelessWidget {
  final int    rating, srcCount;
  final String scientist, year, category;
  final Color  catColor, accentColor;
  final bool   isQuran;
  final MiracleThemeColors t;

  const _TagsRow({
    required this.rating,
    required this.srcCount,
    required this.scientist,
    required this.year,
    required this.category,
    required this.catColor,
    required this.accentColor,
    required this.isQuran,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing:          6,
      runSpacing:       6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) => Icon(
            i < rating
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: i < rating
                ? MiracleTheme.neonGold
                : Colors.white.withValues(alpha: 0.15),
            size: 13,
          )),
        ),

        if (srcCount > 0)
          _SmallTag(
            icon:  Icons.link_rounded,
            text:  '$srcCount مصدر',
            color: MiracleTheme.neonBlue,
            t:     t,
          ),

        if (year.isNotEmpty)
          _SmallTag(
            icon:  Icons.calendar_today_rounded,
            text:  year,
            color: t.mutedText,
            t:     t,
          )
        else if (scientist.isNotEmpty)
          _SmallTag(
            icon:  Icons.person_rounded,
            text:  scientist,
            color: t.mutedText,
            t:     t,
          ),

        _SmallTag(
          text:   category,
          color:  catColor,
          t:      t,
          filled: true,
        ),

        _SmallTag(
          icon:   isQuran
              ? Icons.menu_book_rounded
              : Icons.auto_awesome_rounded,
          text:   isQuran ? 'قرآن' : 'سنة',
          color:  accentColor,
          t:      t,
          filled: true,
        ),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  final IconData?          icon;
  final String             text;
  final Color              color;
  final MiracleThemeColors t;
  final bool               filled;

  const _SmallTag({
    this.icon,
    required this.text,
    required this.color,
    required this.t,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        filled ? color.withValues(alpha: 0.12) : t.glass,
        borderRadius: BorderRadius.circular(7),
        border:       Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize:   9.5,
                fontWeight: FontWeight.bold,
                color:      color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}