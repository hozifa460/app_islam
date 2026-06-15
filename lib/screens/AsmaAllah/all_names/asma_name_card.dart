// lib/screens/asma_allah/all_names/asma_name_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/asma_theme.dart';

class AsmaNameCard extends StatelessWidget {
  final String name;
  final String displayName;
  final String arabicName;
  final String meaning;
  final int order;
  final bool isDark;
  final bool isSmall;
  final Color primaryColor;
  final VoidCallback onTap;

  const AsmaNameCard({
    super.key,
    required this.name,
    required this.displayName,
    required this.arabicName,
    required this.meaning,
    required this.order,
    required this.isDark,
    required this.isSmall,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool showArabic = arabicName.isNotEmpty && arabicName != displayName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1A2438).withOpacity(0.9),
              const Color(0xFF0F1628).withOpacity(0.9),
            ]
                : [
              Colors.white,
              const Color(0xFFFFF8E8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AsmaTheme.gold.withOpacity(isDark ? 0.3 : 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : AsmaTheme.gold.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 10 : 14,
                vertical: isSmall ? 12 : 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ═══════════ الدائرة الذهبية مع Hero ═══════════
                  Hero(
                    tag: 'asma_name_$order',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: isSmall ? 52 : 60,
                        height: isSmall ? 52 : 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [
                              const Color(0xFF1E2A4A),
                              const Color(0xFF0F1628),
                            ]
                                : [
                              Colors.white,
                              const Color(0xFFFFF3D6),
                            ],
                          ),
                          border: Border.all(
                            color: AsmaTheme.gold
                                .withOpacity(isDark ? 0.6 : 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AsmaTheme.gold
                                  .withOpacity(isDark ? 0.2 : 0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AsmaTheme.gold,
                          size: isSmall ? 22 : 26,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmall ? 10 : 14),

                  // ═══════════ الاسم المترجم ═══════════
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: isSmall ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                      ),
                    ),
                  ),

                  // ═══════════ الاسم العربي ═══════════
                  if (showArabic) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '($arabicName)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: isSmall ? 13 : 15,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : AsmaTheme.brownSub.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: isSmall ? 6 : 10),

                  // ═══════════ المعنى ═══════════
                  Expanded(
                    child: Text(
                      _truncateMeaning(meaning),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: isSmall ? 11 : 13,
                        color: isDark
                            ? Colors.white.withOpacity(0.55)
                            : AsmaTheme.brownSub,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════ رقم الترتيب ═══════════
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AsmaTheme.gold, AsmaTheme.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AsmaTheme.gold.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$order',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ═══════════ سهم الانتقال ═══════════
            Positioned(
              bottom: 10,
              right: 10,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: isSmall ? 12 : 14,
                color: AsmaTheme.gold.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateMeaning(String text) {
    if (text.contains(' - ')) {
      text = text.split(' - ').first.trim();
    }
    if (text.length > 50) {
      return '${text.substring(0, 47)}...';
    }
    return text;
  }
}