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

    if (!isLoaded) {
      return HomeCardSkeleton(
        isDark: isDark,
        height: 205,
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

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final small = width < 360;
      final sliderHeight = small ? 180.0 : 205.0;
      final titleSize = small ? 18.0 : 22.0;
      final roleSize = small ? 10.5 : 12.0;
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
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration:
                        const Duration(milliseconds: 650),
                        reverseTransitionDuration:
                        const Duration(milliseconds: 420),
                        opaque: false,
                        pageBuilder: (_, __, ___) =>
                            GreatPersonDetailScreen(
                              person: person,
                              allPersons: greatMuslims,
                              primaryColor: primary,
                              heroTag: heroTag,
                            ),
                        transitionsBuilder:
                            (_, animation, __, child) {
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
                                    begin: 0.985, end: 1.0)
                                    .animate(curved),
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    child: Hero(
                      tag: heroTag,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 8,
                            left: index == greatMuslims.length - 1
                                ? 0
                                : 4,
                            bottom: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(
                                    isActive ? 0.18 : 0.08),
                                blurRadius: isActive ? 16 : 10,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // ══ Parallax Effect ══
                                _ParallaxImage(
                                  pageController: pageController,
                                  index: index,
                                  imagePath: person.image,
                                ),

                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.08),
                                        Colors.black.withOpacity(0.18),
                                        Colors.black.withOpacity(0.78),
                                      ],
                                    ),
                                  ),
                                ),

                                // Badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: gold.withOpacity(0.18),
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      tr.greatOfIslam,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: small ? 9.5 : 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // معلومات الشخص
                                Positioned(
                                  left: 14,
                                  right: 14,
                                  bottom: 14,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.black.withOpacity(0.24),
                                      borderRadius:
                                      BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          person.name,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontSize: titleSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          person.title,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color:
                                            const Color(0xFFF4E7B2),
                                            fontSize: roleSize,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          person.desc,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color: Colors.white
                                                .withOpacity(0.92),
                                            fontSize: descSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                  color: active ? gold : gold.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

/// ══ Parallax Image Widget ══
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
    // ══ تحريك الصورة بشكل عكسي خفيف ══
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
          errorBuilder: (_, __, ___) => Container(
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