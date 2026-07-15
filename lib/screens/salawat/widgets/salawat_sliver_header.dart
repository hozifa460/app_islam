
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';
import 'islamic_pattern_painter.dart';

class SalawatSliverHeader extends StatelessWidget {
  final SalawatTheme theme;
  final bool enabled;
  final Animation<double> pulseAnimation;
  final Animation<double> glowAnimation;
  final Animation<double> floatAnimation;

  const SalawatSliverHeader({
    super.key,
    required this.theme,
    required this.enabled,
    required this.pulseAnimation,
    required this.glowAnimation,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.32,
      pinned: true,
      stretch: true,
      backgroundColor: theme.deepGreen,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            final headerHeight = constraints.maxHeight;
            final iconSize = (headerHeight * 0.28).clamp(50.0, 90.0);
            final calligraphyFontSize =
            (iconSize * 0.44).clamp(18.0, 40.0);
            final titleFontSize =
            (headerHeight * 0.08).clamp(14.0, 22.0);
            final subtitleFontSize =
            (headerHeight * 0.045).clamp(10.0, 12.0);
            final topPadding =
            (headerHeight * 0.12).clamp(30.0, 55.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(decoration: BoxDecoration(gradient: theme.headerGradient)),

                // Islamic geometric pattern overlay
                CustomPaint(
                  painter: IslamicPatternPainter(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),

                // Radial glow
                AnimatedBuilder(
                  animation: glowAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: topPadding - 15,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: iconSize * 2 + (glowAnimation.value * 30),
                          height: iconSize * 2 + (glowAnimation.value * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.accentGold
                                    .withValues(alpha: 0.12 * glowAnimation.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Floating calligraphy icon
                AnimatedBuilder(
                  animation: floatAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: topPadding + floatAnimation.value,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ornamental top
                          Text(
                            '﷽',
                            style: TextStyle(
                              fontSize: subtitleFontSize + 6,
                              color: theme.accentGold.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: headerHeight * 0.02),

                          // Main calligraphy circle
                          AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: enabled
                                    ? pulseAnimation.value
                                    : 1.0,
                                child: Container(
                                  width: iconSize,
                                  height: iconSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.accentGold
                                            .withValues(alpha: 0.3),
                                        theme.accentGold
                                            .withValues(alpha: 0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: theme.accentGold
                                          .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: enabled
                                        ? [
                                      BoxShadow(
                                        color: theme.accentGold
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ﷺ',
                                      style: TextStyle(
                                        fontSize: calligraphyFontSize,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: theme.accentGold
                                                .withValues(alpha: 0.6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: headerHeight * 0.03),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Text(
                                context.tr.prayingOnProphetTitle,
                                style: GoogleFonts.amiriQuran(
                                  fontSize: titleFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color:
                                      Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: headerHeight * 0.015),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                context.tr.ohAllahBlessProphet,
                                style: GoogleFonts.cairo(
                                  fontSize: subtitleFontSize,
                                  color: theme.accentGold
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Bottom curve
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: theme.bgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}