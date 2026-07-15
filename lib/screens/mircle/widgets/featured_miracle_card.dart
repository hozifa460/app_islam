import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color_control/miracle_theme.dart';
import 'miracle_helpers.dart';
import 'section_title.dart';

class FeaturedMiracleCard extends StatelessWidget {
  final Map<String, dynamic> miracle;
  final MiracleThemeColors   t;
  final VoidCallback         onTap;

  const FeaturedMiracleCard({
    super.key,
    required this.miracle,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = (miracle['category'] ?? '').toString();
    final catColor = MiracleHelpers.getCategoryColor(category);
    final catIcon  = MiracleHelpers.getCategoryIcon(category);
    final emoji    = MiracleHelpers.getCategoryEmoji(category);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title:       'معجزة مميزة',
            subtitle:    'Featured Miracle',
            accentColor: MiracleTheme.neonGold,
            t:           t,
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: catColor.withValues(alpha: 0.3), width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:  catColor.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Gradient BG
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:  Alignment.topLeft,
                            end:    Alignment.bottomRight,
                            colors: [
                              catColor.withValues(alpha: 0.25),
                              t.bg3,
                              MiracleTheme.neonPurple.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Emoji watermark
                    Positioned(
                      top: -10, left: -10,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 110)),
                    ),
                    // Fade over emoji
                    Positioned(
                      top: -10, left: -10,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              t.bg3.withValues(alpha: 0.75),
                            ],
                            center: Alignment.topLeft,
                            radius: 1.3,
                          ),
                        ),
                      ),
                    ),

                    // Glow orb top-right
                    Positioned(
                      top: -20, right: -20,
                      child: Container(
                        width: 130, height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            catColor.withValues(alpha: 0.12),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: icon + badge + arrow
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category icon
                              Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: catColor.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: catColor.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Icon(catIcon, color: catColor, size: 22),
                              ),
                              const SizedBox(width: 10),

                              // Badges
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: MiracleTheme.neonGold
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: Border.all(
                                              color: MiracleTheme.neonGold
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            '⭐ معجزة مميزة',
                                            style: GoogleFonts.cairo(
                                              color: MiracleTheme.neonGold,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category,
                                      style: GoogleFonts.cairo(
                                        color: catColor.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow button
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color:  t.glass,
                                  shape:  BoxShape.circle,
                                  border: Border.all(color: t.glassBorder),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: t.subText,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Title
                          Text(
                            miracle['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color:      Colors.white,
                              fontSize:   17,
                              fontWeight: FontWeight.bold,
                              height:     1.3,
                              shadows: [
                                Shadow(
                                  color:     Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Subtitle
                          Text(
                            miracle['subtitle'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color:    Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}