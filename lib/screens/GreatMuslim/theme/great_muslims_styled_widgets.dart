import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/great_muslims_service.dart';

// ═══════════════════════════════════════════════════════════
//                    الألوان الثابتة
// ═══════════════════════════════════════════════════════════
class GreatMuslimsColors {
  static const gold = Color(0xFFC8A44D);
  static const parchment = Color(0xFFF5E6C8);
}

// ═══════════════════════════════════════════════════════════
//                   دائرة زخرفية
// ═══════════════════════════════════════════════════════════
class DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const DecorativeCircle({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                   شارة ذهبية
// ═══════════════════════════════════════════════════════════
class GoldBadge extends StatelessWidget {
  final String text;
  final bool small;

  const GoldBadge({
    super.key,
    required this.text,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: GreatMuslimsColors.gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(
          color: GreatMuslimsColors.gold,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  صندوق خطأ الصورة
// ═══════════════════════════════════════════════════════════
class ErrorImageBox extends StatelessWidget {
  final Color primary;

  const ErrorImageBox({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.5)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: Colors.white.withOpacity(0.25),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  رسام زخرفة الأركان
// ═══════════════════════════════════════════════════════════
class CornerPainter extends CustomPainter {
  final Color color;
  final bool topRight;

  CornerPainter({required this.color, required this.topRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (topRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.7);
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.3, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(0, size.height * 0.3);
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.7, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════
//                  زخرفة الأركان
// ═══════════════════════════════════════════════════════════
class CornerDecoration extends StatelessWidget {
  final bool topRight;

  const CornerDecoration({super.key, required this.topRight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: CornerPainter(
          color: GreatMuslimsColors.gold.withOpacity(0.15),
          topRight: topRight,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  الفاصل الزخرفي
// ═══════════════════════════════════════════════════════════
class OrnamentalDivider extends StatelessWidget {
  const OrnamentalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          color: GreatMuslimsColors.gold.withOpacity(0.3),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.auto_awesome,
            color: GreatMuslimsColors.gold,
            size: 16,
          ),
        ),
        Container(
          width: 40,
          height: 1,
          color: GreatMuslimsColors.gold.withOpacity(0.3),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//               زر أيقونة مع ضبابية
// ═══════════════════════════════════════════════════════════
class BlurredIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;

  const BlurredIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//            خلفية الهيدر للشاشة الرئيسية
// ═══════════════════════════════════════════════════════════
class MuseumAppBarBackground extends StatelessWidget {
  final Color primary;

  const MuseumAppBarBackground({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                primary.withOpacity(0.7),
                const Color(0xFF111111),
              ],
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -30,
          child: DecorativeCircle(
            size: 200,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -20,
          child: DecorativeCircle(
            size: 160,
            color: Colors.amber.withOpacity(0.05),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "متحف عظماء الإسلام",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "رحلة عبر أعظم الشخصيات في تاريخ الحضارة الإسلامية",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                     شريط البحث
// ═══════════════════════════════════════════════════════════
class MuslimSearchBar extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MuslimSearchBar({
    super.key,
    required this.primary,
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF152620) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن شخصية...',
            hintStyle: GoogleFonts.cairo(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: primary.withOpacity(0.5),
              size: 22,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: primary.withOpacity(0.5),
                size: 20,
              ),
              onPressed: onClear,
            )
                : null,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                    شرائح الفئات
// ═══════════════════════════════════════════════════════════
class CategoryChipsList extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChipsList({
    super.key,
    required this.primary,
    required this.isDark,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)])
                      : null,
                  color: selected
                      ? null
                      : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                      : null,
                ),
                child: Text(
                  categories[i],
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  عداد الشخصيات
// ═══════════════════════════════════════════════════════════
class PersonsCountHeader extends StatelessWidget {
  final int count;
  final Color primary;
  final bool isDark;

  const PersonsCountHeader({
    super.key,
    required this.count,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              "$count شخصية",
              key: ValueKey(count),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),
          Text(
            "الشخصيات",
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                   حالة الفراغ
// ═══════════════════════════════════════════════════════════
class EmptyStateWidget extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final bool isFiltered;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    super.key,
    required this.primary,
    required this.isDark,
    required this.isFiltered,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: GreatMuslimsColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.error_outline_rounded,
              size: 44,
              color: GreatMuslimsColors.gold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isFiltered ? 'لا توجد نتائج' : 'تعذّر تحميل البيانات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'جرب البحث باسم آخر أو تغيير الفئة'
                : 'تأكد من وجود ملف البيانات',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isFiltered && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  البطاقة المميزة
// ═══════════════════════════════════════════════════════════
class FeaturedPersonCard extends StatelessWidget {
  final GreatMuslim person;
  final Color primary;
  final bool isDark;
  final String heroTag;
  final VoidCallback onTap;

  const FeaturedPersonCard({
    super.key,
    required this.person,
    required this.primary,
    required this.isDark,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 260,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: GreatMuslimsColors.gold.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    person.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        ErrorImageBox(primary: primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.3, 0.6, 1],
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.88),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: GreatMuslimsColors.gold.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // شارة
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GreatMuslimsColors.gold,
                            GreatMuslimsColors.gold.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: GreatMuslimsColors.gold.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'شخصية مميزة',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // العصر
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        person.era,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // المعلومات
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.45),
                              ],
                            ),
                            border: Border(
                              top: BorderSide(
                                color: GreatMuslimsColors.gold.withOpacity(0.15),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                person.name,
                                style: GoogleFonts.amiri(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GoldBadge(text: person.title),
                              const SizedBox(height: 8),
                              Text(
                                person.desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  بطاقة الشبكة الحديثة
// ═══════════════════════════════════════════════════════════
class ModernGridCard extends StatelessWidget {
  final GreatMuslim person;
  final Color primary;
  final bool isDark;
  final String heroTag;
  final VoidCallback onTap;

  const ModernGridCard({
    super.key,
    required this.person,
    required this.primary,
    required this.isDark,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(person.image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          person.name,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          person.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//              الهيدر السينمائي (شاشة التفاصيل)
// ═══════════════════════════════════════════════════════════
class CinematicHeaderContent extends StatelessWidget {
  final GreatMuslim person;
  final Color primary;
  final Size screenSize;
  final double scrollOffset;
  final Widget pulsingBorder;
  final Widget animatedBadge;
  final double topPadding;

  const CinematicHeaderContent({
    super.key,
    required this.person,
    required this.primary,
    required this.screenSize,
    required this.scrollOffset,
    required this.pulsingBorder,
    required this.animatedBadge,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final parallax = scrollOffset * 0.5;

    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة مع Parallax
        Transform.translate(
          offset: Offset(0, parallax),
          child: Transform.scale(
            scale: 1 + (scrollOffset < 0 ? scrollOffset.abs() / 500 : 0),
            child: Image.asset(
              person.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, primary.withOpacity(0.6)],
                  ),
                ),
                child: Icon(Icons.person, size: 100, color: Colors.white24),
              ),
            ),
          ),
        ),

        // تدرج سينمائي
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.3, 0.6, 0.85, 1],
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.95),
              ],
            ),
          ),
        ),

        // Vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),

        // الإطار النابض
        pulsingBorder,

        // الشارة
        Positioned(
          top: topPadding + 60,
          right: 20,
          child: animatedBadge,
        ),

        // معلومات الشخصية
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: GreatMuslimsColors.gold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        person.name,
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GoldenTitleBox(title: person.title),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  صندوق اللقب الذهبي
// ═══════════════════════════════════════════════════════════
class GoldenTitleBox extends StatelessWidget {
  final String title;

  const GoldenTitleBox({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GreatMuslimsColors.gold.withOpacity(0.3),
            GreatMuslimsColors.gold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GreatMuslimsColors.gold.withOpacity(0.5),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: GreatMuslimsColors.parchment,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                شريط المعلومات العائم
// ═══════════════════════════════════════════════════════════
class FloatingInfoBar extends StatelessWidget {
  final GreatMuslim person;
  final bool isDark;

  const FloatingInfoBar({
    super.key,
    required this.person,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.category_rounded, 'value': person.category},
      {'icon': Icons.history_rounded, 'value': person.era},
      {
        'icon': Icons.date_range_rounded,
        'value': '${person.birthYear} - ${person.deathYear}'
      },
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color:
              (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GreatMuslimsColors.gold.withOpacity(0.2),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                        left: BorderSide(
                          color: GreatMuslimsColors.gold
                              .withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: GreatMuslimsColors.gold,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['value'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//              بطاقة المخطوطة للسيرة
// ═══════════════════════════════════════════════════════════
class ParchmentBioCard extends StatelessWidget {
  final GreatMuslim person;
  final Color cardBg;
  final bool isDark;
  final Color textColor;

  const ParchmentBioCard({
    super.key,
    required this.person,
    required this.cardBg,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? cardBg
            : GreatMuslimsColors.parchment.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: GreatMuslimsColors.gold.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: GreatMuslimsColors.gold.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: CornerDecoration(topRight: true),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            child: CornerDecoration(topRight: false),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'سيرته العطرة',
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: GreatMuslimsColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GreatMuslimsColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        color: GreatMuslimsColors.gold,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const OrnamentalDivider(),
                const SizedBox(height: 20),
                Text(
                  person.details,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 17,
                    height: 2.2,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xFF2D2416),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//               عنصر ميدالية الإنجاز
// ═══════════════════════════════════════════════════════════
class AchievementMedalItem extends StatelessWidget {
  final String achievement;
  final int index;
  final Color cardBg;
  final Color textColor;

  const AchievementMedalItem({
    super.key,
    required this.achievement,
    required this.index,
    required this.cardBg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GreatMuslimsColors.gold,
                  GreatMuslimsColors.gold.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: GreatMuslimsColors.gold.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white.withOpacity(0.3),
                  size: 40,
                ),
                Text(
                  '${index + 1}',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: GreatMuslimsColors.gold.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                achievement,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.85),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//               عنوان قسم الإنجازات
// ═══════════════════════════════════════════════════════════
class AchievementsSectionHeader extends StatelessWidget {
  const AchievementsSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'إنجازاته الخالدة',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GreatMuslimsColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GreatMuslimsColors.gold,
                  GreatMuslimsColors.gold.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: GreatMuslimsColors.gold.withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//               بطاقة المقولة المنقوشة
// ═══════════════════════════════════════════════════════════
class EngravedQuoteCard extends StatelessWidget {
  final GreatMuslim person;
  final bool isDark;

  const EngravedQuoteCard({
    super.key,
    required this.person,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF1A1510), const Color(0xFF0F0D0A)]
              : [
            const Color(0xFFF8F0E3),
            GreatMuslimsColors.parchment,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: GreatMuslimsColors.gold.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GreatMuslimsColors.gold.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 20,
            child: Icon(
              Icons.format_quote,
              size: 60,
              color: GreatMuslimsColors.gold.withOpacity(0.15),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Transform.rotate(
              angle: pi,
              child: Icon(
                Icons.format_quote,
                size: 60,
                color: GreatMuslimsColors.gold.withOpacity(0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GreatMuslimsColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GreatMuslimsColors.gold.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: GreatMuslimsColors.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'من حكمه ومواعظه',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: GreatMuslimsColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const OrnamentalDivider(),
                const SizedBox(height: 24),
                Text(
                  '❝ ${person.quote} ❞',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    height: 2.0,
                    fontWeight: FontWeight.bold,
                    color:
                    isDark ? Colors.white : const Color(0xFF2E2415),
                  ),
                ),
                const SizedBox(height: 24),
                const OrnamentalDivider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 1,
                      color: GreatMuslimsColors.gold.withOpacity(0.3),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        person.name,
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: GreatMuslimsColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 1,
                      color: GreatMuslimsColors.gold.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  بطاقة التنقل
// ═══════════════════════════════════════════════════════════
class NavigationPersonCard extends StatelessWidget {
  final GreatMuslim person;
  final String label;
  final Color cardBg;
  final bool isDark;
  final VoidCallback onTap;

  const NavigationPersonCard({
    super.key,
    required this.person,
    required this.label,
    required this.cardBg,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: GreatMuslimsColors.gold.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                person.image,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 55,
                  height: 55,
                  color: GreatMuslimsColors.gold.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: GreatMuslimsColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  الشريط السفلي
// ═══════════════════════════════════════════════════════════
class BlurredBottomBar extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  const BlurredBottomBar({
    super.key,
    required this.primary,
    required this.isDark,
    required this.onShare,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color:
            (isDark ? Colors.black : Colors.white).withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: GreatMuslimsColors.gold.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    'مشاركة السيرة',
                    style:
                    GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: GreatMuslimsColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: GreatMuslimsColors.gold.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  onPressed: onBookmark,
                  icon: Icon(
                    Icons.bookmark_outline,
                    color: GreatMuslimsColors.gold,
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