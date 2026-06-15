import 'package:flutter/material.dart';

import '../../../languages/app_localizations.dart';

class InheritanceHeaderWidget extends StatelessWidget {
  final Color primaryColor;
  final bool isDarkMode;
  final Animation<double>? animation;

  const InheritanceHeaderWidget({
    Key? key,
    required this.primaryColor,
    required this.isDarkMode,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4A847);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final baseFontSize = (maxWidth * 0.055).clamp(14.0, 24.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ornament Line
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOrnamentLine(gold, maxWidth * 0.1),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'ï·½',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 18,
                        color: gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildOrnamentLine(gold, maxWidth * 0.1),
                ],
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Bismillah
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.tr.bismillahFull,
                  style: TextStyle(
                    fontSize: baseFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Verse Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: gold.withValues(alpha: 0.6),
                      size: isSmallScreen ? 16 : 20,
                    ),
                    const SizedBox(height: 8),

                    // ط§ظ„ط¢ظٹط© ط§ظ„ط¬ط¯ظٹط¯ط© ط§ظ„ط´ط§ظ…ظ„ط©
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          context.tr.inheritanceVerse,
                          style: TextStyle(
                            fontSize: (baseFontSize * 0.65).clamp(11.0, 15.0),
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Reference
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.tr.inheritanceVerseRef,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 11,
                          color: gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 10 : 14),

              // Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: gold,
                      size: isSmallScreen ? 12 : 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.tr.distributionAccordingSharia,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrnamentLine(Color color, double width) {
    return Container(
      width: width.clamp(20.0, 40.0),
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, color, Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}