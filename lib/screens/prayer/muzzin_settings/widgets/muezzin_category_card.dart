import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../more/data/muezzin_catalog.dart';

// استدعاء ملف الترجمة (تأكد من المسار الخاص بك)
import '../../../../languages/app_localizations.dart';

class MuezzinCategoryCard extends StatelessWidget {
  final MuezzinCategory category;
  final Color gold;
  final bool isDark;
  final VoidCallback onTap;

  const MuezzinCategoryCard({
    super.key,
    required this.category,
    required this.gold,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSheikhs = category.id == 'sheikhs';
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final shadowColor =
    isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (context, v, child) => Transform.translate(
        offset: Offset(0, 18 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSheikhs
                  ? [gold.withOpacity(0.2), gold.withOpacity(0.05)]
                  : cardGradient,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSheikhs ? gold.withOpacity(0.5) : borderColor,
              width: isSheikhs ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: category.imageAsset != null
                          ? AssetImage(category.imageAsset!)
                          : NetworkImage(category.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr.t(category.name), // يعتمد على مصدر البيانات
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr.t(category.description), // يعتمد على مصدر البيانات
                              style: GoogleFonts.cairo(
                                color: subTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSheikhs)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: gold.withOpacity(0.4)),
                          ),
                          child: Text(
                            context.tr.sheikhsBadge, // تمت الترجمة هنا
                            style: GoogleFonts.cairo(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}