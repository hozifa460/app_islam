import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaGuidanceBanner extends StatelessWidget {
  final QiblaTheme theme;
  final bool isFacing;
  final Color guidance;
  final double deviation;
  final AnimationController successCtrl;
  final Animation<double> successAnim;

  const QiblaGuidanceBanner({
    super.key,
    required this.theme,
    required this.isFacing,
    required this.guidance,
    required this.deviation,
    required this.successCtrl,
    required this.successAnim,
  });

  @override
  Widget build(BuildContext context) {
    final label = QiblaTheme.getDirectionLabel(deviation);
    final icon = QiblaTheme.getDirectionIcon(deviation);

    return AnimatedBuilder(
      animation: successCtrl,
      builder: (_, __) => Transform.scale(
        scale: isFacing ? successAnim.value : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                guidance.withValues(alpha: theme.isDark ? 0.22 : 0.10),
                guidance.withValues(alpha: theme.isDark ? 0.06 : 0.03),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(QiblaTheme.bannerRadius),
            border: Border.all(color: guidance.withValues(alpha: 0.42), width: 2),
            boxShadow: [
              BoxShadow(
                color: guidance.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(icon),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: guidance.withValues(alpha: 0.14),
                    border: Border.all(color: guidance.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, color: guidance, size: 26),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        key: ValueKey(label),
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: guidance,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isFacing
                          ? 'يمكنك الآن أداء الصلاة في هذا الاتجاه'
                          : 'وجّه هاتفك حتى تشير الإبرة الخضراء للأعلى',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: theme.isDark
                            ? Colors.white.withValues(alpha: 0.58)
                            : Colors.black.withValues(alpha: 0.50),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}