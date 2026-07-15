// lib/screens/radio/widgets_recitations/rec_category_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets/cached_image_widget.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_category_detail_screen.dart';

/// ══════════════════════════════════════════════════════════════
/// بطاقة التصنيف المربعة (Grid Card)
/// ══════════════════════════════════════════════════════════════
class RecCategorySection extends StatelessWidget {
  final RecitationCategory category;
  final Color primary;
  final bool isTablet;

  const RecCategorySection({
    super.key,
    required this.category,
    required this.primary,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final colors = category.gradientColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ══ نمط زخرفي خفيف ══
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              right: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // ══ المحتوى ══
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  // كل المسافات تعتمد على الارتفاع المتاح، لتظل البطاقة
                  // صالحة للشاشات الصغيرة والوضع الأفقي أيضاً.
                  final imageSize = (h * 0.26).clamp(36.0, 62.0);
                  final titleSize = (h * 0.10).clamp(12.0, 17.0);
                  final badgeSize = (h * 0.065).clamp(9.0, 12.0);
                  final gap1 = (h * 0.03).clamp(4.0, 7.0);
                  final gap2 = (h * 0.025).clamp(3.0, 6.0);

                  return Padding(
                    padding: EdgeInsets.all((h * 0.08).clamp(8.0, 14.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CategoryImage(
                          imageUrl: _categoryImageUrl(),
                          emoji: category.emoji,
                          primary: primary,
                          size: imageSize,
                        ),
                        SizedBox(height: gap1),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            category.title,
                            style: GoogleFonts.cairo(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: gap2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${category.items.length} عنصر',
                            style: GoogleFonts.cairo(
                              fontSize: badgeSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                RecCategoryDetailScreen(category: category, primary: primary),
      ),
    );
  }

  String? _categoryImageUrl() {
    final categoryImage = category.imageUrl?.trim();
    if (categoryImage?.isNotEmpty ?? false) return categoryImage;

    // حين لا تحمل الكاتيغوري صورة مستقلة، نستخدم أول thumbnail متاح
    // من محتواها (خصوصاً قنوات يوتيوب) بدلاً من الاكتفاء بالإيموجي.
    for (final item in category.items) {
      final itemImage = item.imageUrl?.trim();
      if (itemImage?.isNotEmpty ?? false) return itemImage;
      for (final subItem in item.allSubItems) {
        final thumbnail = subItem.imageUrl?.trim();
        if (thumbnail?.isNotEmpty ?? false) return thumbnail;
      }
    }
    return null;
  }
}

class _CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final String emoji;
  final Color primary;
  final double size;

  const _CategoryImage({
    required this.imageUrl,
    required this.emoji,
    required this.primary,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedImageWidget(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: fallback,
          errorWidget: fallback,
        ),
      ),
    );
  }
}
