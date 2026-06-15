import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';
import 'decorative_elements.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ويدجت الهيدر
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarSliverHeader extends StatelessWidget {
  final bool isDark;
  final bool innerBoxIsScrolled;
  final Animation<double> headerAnimation;
  final int categoriesCount;

  const AzkarSliverHeader({
    super.key,
    required this.isDark,
    required this.innerBoxIsScrolled,
    required this.headerAnimation,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final expandedHeight = (size.height * 0.24).clamp(160.0, 240.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      floating: false,
      snap: false,
      stretch: false,
      backgroundColor: isDark
          ? const Color(0xFF0D1420)
          : const Color(0xFF1A2744),
      elevation: innerBoxIsScrolled ? 4 : 0,
      shadowColor: Colors.black.withOpacity(0.3),
      leading: _buildBackButton(context),
      title: _buildCollapsedTitle(context),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.parallax,
        background: AzkarHeaderBackground(
          isDark: isDark,
          headerAnimation: headerAnimation,
          categoriesCount: categoriesCount,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: AzkarTheme.getBackButtonDecoration(isDark),
      child: TapScaleAnimationWidget(
        onTap: () => Navigator.pop(context),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedTitle(BuildContext context) { // 👈 تمرير context
    return AnimatedOpacity(
      opacity: innerBoxIsScrolled ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        context.tr.azkarTitle, // 👈 تمت الترجمة
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

}

/// ═══════════════════════════════════════════════════════════════════════════
/// خلفية الهيدر
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarHeaderBackground extends StatelessWidget {
  final bool isDark;
  final Animation<double> headerAnimation;
  final int categoriesCount;

  const AzkarHeaderBackground({
    super.key,
    required this.isDark,
    required this.headerAnimation,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: AzkarTheme.getHeaderGradient(isDark),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الدوائر الزخرفية المتحركة
          FloatingDecorativeCircles(
            size: size,
            baseColor: AzkarTheme.gold,
          ),

          // المحتوى الرئيسي
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight - 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الأيقونة المتحركة
                  AnimatedHeaderIcon(
                    size: (size.width * 0.16).clamp(52.0, 80.0),
                    animation: headerAnimation,
                  ),
                  const SizedBox(height: 10),
                  // الآية
                  _buildQuranVerse(context, size),
                  const SizedBox(height: 8),
                  // عدد التصنيفات
                  _buildCategoriesCount(context, size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranVerse(BuildContext context, Size size) { // 👈 تمرير context
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideInAnimationWidget(
        index: 0,
        duration: const Duration(milliseconds: 600),
        beginOffset: const Offset(0, 20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Text(
            context.tr.azkarQuranVerse, // 👈 تمت الترجمة
            style: GoogleFonts.amiri(
              color: AzkarTheme.gold.withOpacity(0.95),
              fontSize: (size.width * 0.044).clamp(14.0, 20.0),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCount(BuildContext context, Size size) { // 👈 تمرير context
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideInAnimationWidget(
        index: 1,
        duration: const Duration(milliseconds: 700),
        beginOffset: const Offset(0, 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            context.tr.azkarCategoriesCount(categoriesCount), // 👈 تمت الترجمة
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.85),
              fontSize: (size.width * 0.032).clamp(10.0, 13.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}