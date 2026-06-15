import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../color_control/miracle_color_provider.dart';
import '../color_control/miracle_theme.dart';
import 'miracle_helpers.dart';
import 'section_title.dart';

class CategoriesGrid extends StatelessWidget {
  final List<String>               categories;
  final List<Map<String, dynamic>> miracles;
  final String                     selectedCategory;
  final MiracleThemeColors         t;
  final ValueChanged<String>       onCategorySelected;
  final void Function(String category)? onCategoryTapped;

  const CategoriesGrid({
    super.key,
    required this.categories,
    required this.miracles,
    required this.selectedCategory,
    required this.t,
    required this.onCategorySelected,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MiracleColorProvider>();
    final t = MiracleTheme.of(isDark, provider: provider);

    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title:       'ط§ط³طھظƒط´ظپ ط§ظ„ط£ظ‚ط³ط§ظ…',
            subtitle:    'Categories',
            accentColor: MiracleTheme.neonBlue,
            t:           t,
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final cols  = constraints.maxWidth < 360 ? 1 : 2;
              final itemW = (constraints.maxWidth - (cols - 1) * 12) / cols;
              const itemH = 110.0;

              return Wrap(
                spacing:    12,
                runSpacing: 12,
                children: List.generate(categories.length, (index) {
                  final cat = categories[index];
                  return SizedBox(
                    width:  itemW,
                    height: itemH,
                    child: _CategoryCard(
                      category:   cat,
                      count:      miracles
                          .where((m) => m['category'] == cat)
                          .length,
                      isSelected: selectedCategory == cat,
                      index:      index,
                      t:          t,
                      onTap: () {
                        onCategorySelected(
                          selectedCategory == cat ? 'all' : cat,
                        );
                      },
                      onNavigate: () {
                        if (onCategoryTapped != null) {
                          onCategoryTapped!(cat);
                        }
                      },
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String             category;
  final int                count;
  final bool               isSelected;
  final int                index;
  final MiracleThemeColors t;
  final VoidCallback       onTap;
  final VoidCallback       onNavigate;

  const _CategoryCard({
    required this.category,
    required this.count,
    required this.isSelected,
    required this.index,
    required this.t,
    required this.onTap,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = MiracleHelpers.getCategoryColor(category);
    final catIcon  = MiracleHelpers.getCategoryIcon(category);
    final emoji    = MiracleHelpers.getCategoryEmoji(category);
    final engName  = MiracleHelpers.getCategoryEnglish(category);

    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 700)),
      curve:    Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child:  child,
        ),
      ),
      child: GestureDetector(
        onTap:        onNavigate,
        onLongPress:  onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? catColor.withValues(alpha: 0.7)
                  : catColor.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color:        catColor.withValues(alpha: 0.25),
                blurRadius:   18,
                spreadRadius: 2,
              ),
            ]
                : [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // â”€â”€ Gradient background â”€â”€
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                        colors: [
                          catColor.withValues(alpha: isSelected ? 0.28 : 0.14),
                          t.bg3.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ),

                // â”€â”€ Emoji watermark â”€â”€
                Positioned(
                  bottom: -8, right: -4,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white
                          .withValues(alpha: isSelected ? 0.22 : 0.12),
                    ),
                  ),
                ),

                // â”€â”€ Glow orb â”€â”€
                Positioned(
                  top: -16, left: -16,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          catColor.withValues(alpha: isSelected ? 0.18 : 0.07),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // â”€â”€ Content â”€â”€
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon + count
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width:  34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: catColor.withValues(alpha: 0.3)),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color:     catColor.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                ),
                              ]
                                  : [],
                            ),
                            child: Icon(catIcon, color: catColor, size: 18),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: catColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.poppins(
                                color:      catColor,
                                fontSize:   11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Arabic name
                      Text(
                        category,
                        style: GoogleFonts.cairo(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color:     Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                      ),

                      // English name
                      Text(
                        engName,
                        style: GoogleFonts.poppins(
                          color:    catColor.withValues(alpha: 0.75),
                          fontSize: 9,
                        ),
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // â”€â”€ Selected checkmark â”€â”€
                if (isSelected)
                  Positioned(
                    top: 7, left: 7,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color:  catColor,
                        shape:  BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:     catColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 11),
                    ),
                  ),

                // â”€â”€ Arrow indicator (navigate hint) â”€â”€
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: catColor.withValues(alpha: 0.1),
                      border: Border.all(
                          color: catColor.withValues(alpha: 0.2)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size:  10,
                      color: catColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}