import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';
import 'decorative_elements.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ظˆظٹط¯ط¬طھ ط§ظ„ظ‡ظٹط¯ط±
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
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
      shadowColor: Colors.black.withValues(alpha: 0.3),
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

  Widget _buildCollapsedTitle(BuildContext context) { // ًں‘ˆ طھظ…ط±ظٹط± context
    return AnimatedOpacity(
      opacity: innerBoxIsScrolled ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        context.tr.azkarTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

}

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط®ظ„ظپظٹط© ط§ظ„ظ‡ظٹط¯ط±
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
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
          // ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط²ط®ط±ظپظٹط© ط§ظ„ظ…طھط­ط±ظƒط©
          FloatingDecorativeCircles(
            size: size,
            baseColor: AzkarTheme.gold,
          ),

          // ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط±ط¦ظٹط³ظٹ
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight - 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ط§ظ„ط£ظٹظ‚ظˆظ†ط© ط§ظ„ظ…طھط­ط±ظƒط©
                  AnimatedHeaderIcon(
                    size: (size.width * 0.16).clamp(52.0, 80.0),
                    animation: headerAnimation,
                  ),
                  const SizedBox(height: 10),
                  // ط§ظ„ط¢ظٹط©
                  _buildQuranVerse(context, size),
                  const SizedBox(height: 8),
                  // ط¹ط¯ط¯ ط§ظ„طھطµظ†ظٹظپط§طھ
                  _buildCategoriesCount(context, size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranVerse(BuildContext context, Size size) { // ًں‘ˆ طھظ…ط±ظٹط± context
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideInAnimationWidget(
        index: 0,
        duration: const Duration(milliseconds: 600),
        beginOffset: const Offset(0, 20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Text(
            context.tr.azkarQuranVerse, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
            style: GoogleFonts.amiri(
              color: AzkarTheme.gold.withValues(alpha: 0.95),
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

  Widget _buildCategoriesCount(BuildContext context, Size size) { // ًں‘ˆ طھظ…ط±ظٹط± context
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideInAnimationWidget(
        index: 1,
        duration: const Duration(milliseconds: 700),
        beginOffset: const Offset(0, 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            context.tr.azkarCategoriesCount(categoriesCount), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: (size.width * 0.032).clamp(10.0, 13.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}