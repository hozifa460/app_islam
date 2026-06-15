// lib/screens/asma_allah/circle/asma_name_circle.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/asma_theme.dart';

class AsmaNameCircleWidget extends StatelessWidget {
  final String displayName;
  final String meaning;
  final double size;
  final Color borderColor;
  final bool isDark;
  final Animation<double> glowAnimation;
  final String heroTag;
  final VoidCallback onTap;

  const AsmaNameCircleWidget({
    super.key,
    required this.displayName,
    required this.meaning,
    required this.size,
    required this.borderColor,
    required this.isDark,
    required this.glowAnimation,
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
          child: AnimatedBuilder(
            animation: glowAnimation,
            builder: (context, child) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [const Color(0xFF1A2438), const Color(0xFF0F1628)]
                        : [Colors.white, const Color(0xFFFFF8E8)],
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: size < 50 ? 1.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 
                        0.2 + glowAnimation.value * 0.3,
                      ),
                      blurRadius: 8 + glowAnimation.value * 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(size * 0.1),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: size * 0.30,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}