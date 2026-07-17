import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../../../services/great_muslims_service.dart';
import '../../GreatMuslim/great_person_detail_screen.dart';
import 'home_card_skeleton.dart';

class HomeHeaderSlider extends StatelessWidget {
  final Color primary;
  final Color gold;
  final List<GreatMuslim> greatMuslims;
  final bool isLoaded;
  final PageController pageController;
  final int currentIndex;
  final Function(int) onPageChanged;

  const HomeHeaderSlider({
    super.key,
    required this.primary,
    required this.gold,
    required this.greatMuslims,
    required this.isLoaded,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor =
        isDark ? const Color(0xFFD8E1DD) : const Color(0xFF23323B);

    if (!isLoaded) {
      return HomeCardSkeleton(
        isDark: isDark,
        height: 200,
        borderRadius: BorderRadius.circular(24),
      );
    }

    if (greatMuslims.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(tr.noData, style: GoogleFonts.cairo(color: gold)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;
        final sliderHeight = small ? 194.0 : 214.0;
        final titleSize = small ? 21.0 : 25.0;
        final roleSize = small ? 11.0 : 13.0;
        final descSize = small ? 10.0 : 11.5;

        return Column(
          children: [
            SizedBox(
              height: sliderHeight,
              child: PageView.builder(
                controller: pageController,
                itemCount: greatMuslims.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final person = greatMuslims[index];
                  final heroTag = 'great_person_${person.id}';
                  final isActive = index == currentIndex;

                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.96,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 650,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 420,
                              ),
                              opaque: false,
                              pageBuilder:
                                  (_, __, ___) => GreatPersonDetailScreen(
                                    person: person,
                                    allPersons: greatMuslims,
                                    primaryColor: primary,
                                    heroTag: heroTag,
                                  ),
                              transitionsBuilder: (_, animation, __, child) {
                                final curved = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                  reverseCurve: Curves.easeInCubic,
                                );
                                return FadeTransition(
                                  opacity: curved,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.03),
                                      end: Offset.zero,
                                    ).animate(curved),
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.985,
                                        end: 1.0,
                                      ).animate(curved),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      child: _PersonCard(
                        person: person,
                        heroTag: heroTag,
                        isActive: isActive,
                        isDark: isDark,
                        subtitleColor: subtitleColor,
                        gold: gold,
                        primary: primary,
                        titleSize: titleSize,
                        roleSize: roleSize,
                        descSize: descSize,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(greatMuslims.length, (index) {
                final active = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        active ? primary : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// Single person card — white card with medallion on top, portrait on right (RTL) + text on left
class _PersonCard extends StatelessWidget {
  final GreatMuslim person;
  final String heroTag;
  final bool isActive;
  final bool isDark;
  final Color subtitleColor;
  final Color gold;
  final Color primary;
  final double titleSize;
  final double roleSize;
  final double descSize;

  const _PersonCard({
    required this.person,
    required this.heroTag,
    required this.isActive,
    required this.isDark,
    required this.subtitleColor,
    required this.gold,
    required this.primary,
    required this.titleSize,
    required this.roleSize,
    required this.descSize,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 20, bottom: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Card body ──
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDark
                                ? [
                                  const Color(
                                    0xFF183B45,
                                  ).withValues(alpha: 0.72),
                                  const Color(
                                    0xFF0B1E29,
                                  ).withValues(alpha: 0.56),
                                ]
                                : [
                                  Colors.white.withValues(alpha: 0.48),
                                  const Color(
                                    0xFFDCE9E4,
                                  ).withValues(alpha: 0.34),
                                ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isActive
                                  ? Colors.black.withValues(alpha: 0.24)
                                  : Colors.black.withValues(alpha: 0.10),
                          blurRadius: isActive ? 18 : 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.22 : 0.50,
                        ),
                        width: 1.1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 36, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildPortrait(),
                          const SizedBox(width: 14),
                          Expanded(child: _buildTextBlock()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Medallion badge at top-center ──
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Center(child: _buildMedallion()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedallion() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [gold.withValues(alpha: 0.95), gold.withValues(alpha: 0.65)],
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  Icon(Icons.star_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildPortrait() {
    return Container(
      width: 110,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: gold.withValues(alpha: 0.35), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          person.image,
          fit: BoxFit.cover,
          width: 110,
          height: 120,
          errorBuilder:
              (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary.withValues(alpha: 0.7), primary],
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildTextBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name — large, bold
        Text(
          person.name,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            color: gold,
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        // Role/title
        Text(
          person.title,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white : primary,
            fontSize: roleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        // Description
        Text(
          person.desc,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            color: subtitleColor,
            fontSize: descSize,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Parallax image widget (kept for backward compat but unused in new design)
class _ParallaxImage extends StatefulWidget {
  final PageController pageController;
  final int index;
  final String imagePath;

  const _ParallaxImage({
    required this.pageController,
    required this.index,
    required this.imagePath,
  });

  @override
  State<_ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<_ParallaxImage> {
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.pageController.hasClients) return;
    final page = widget.pageController.page ?? 0;
    final diff = (page - widget.index);
    final newOffset = diff * 30;
    if ((newOffset - _offset).abs() > 0.5) {
      setState(() => _offset = newOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.translate(
        offset: Offset(_offset, 0),
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder:
              (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF123C33), Color(0xFF1D5B4F)],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
