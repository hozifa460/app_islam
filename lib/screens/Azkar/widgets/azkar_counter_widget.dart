import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ويدجت العداد المتحرك
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarCounterWidget extends StatelessWidget {
  final int count;
  final int initialCount;
  final bool isDone;
  final bool isDark;
  final double screenWidth;

  const AzkarCounterWidget({
    super.key,
    required this.count,
    required this.initialCount,
    required this.isDone,
    required this.isDark,
    required this.screenWidth,
  });

  double get progress => initialCount > 0 ? 1.0 - (count / initialCount) : 1.0;

  @override
  Widget build(BuildContext context) {
    final size = (screenWidth * 0.22).clamp(60.0, 90.0);
    final strokeWidth = size * 0.08;

    if (isDone) {
      return _buildCompletedWidget(size);
    }

    return _buildCounterWidget(size, strokeWidth);
  }

  Widget _buildCompletedWidget(double size) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: SparkleAnimationWidget(
        sparkleColor: AzkarTheme.success,
        sparkleCount: 8,
        child: Container(
          key: const ValueKey('done'),
          padding: EdgeInsets.symmetric(
            horizontal: size * 0.3,
            vertical: size * 0.12,
          ),
          decoration: AzkarTheme.getCompletedBadgeDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseAnimationWidget(
                minScale: 0.9,
                maxScale: 1.1,
                duration: const Duration(milliseconds: 800),
                child: Icon(
                  Icons.check_circle,
                  color: AzkarTheme.success,
                  size: size * 0.35,
                ),
              ),
              SizedBox(width: size * 0.15),
              Text(
                'تم',
                style: GoogleFonts.cairo(
                  color: AzkarTheme.success,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterWidget(double size, double strokeWidth) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: child,
      ),
      child: GlowAnimationWidget(
        key: ValueKey(count),
        glowColor: AzkarTheme.gold,
        maxBlur: 15,
        minBlur: 5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الدائرة الخارجية مع التقدم
            SizedBox(
              width: size,
              height: size,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: AzkarTheme.gold.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(AzkarTheme.gold),
                ),
              ),
            ),
            // الدائرة الداخلية مع الرقم
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: AzkarTheme.getCounterDecoration(isDark),
              child: Center(
                child: CounterAnimationWidget(
                  count: count,
                  duration: const Duration(milliseconds: 300),
                  builder: (context, animatedCount) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.1),
                      child: Text(
                        '$count',
                        style: GoogleFonts.cairo(
                          fontSize: size * 0.45,
                          fontWeight: FontWeight.w800,
                          color: AzkarTheme.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// صندوق المعلومات (المصدر / الفائدة)
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarInfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;
  final double fontSize;
  final double padding;
  final bool isBenefit;

  const AzkarInfoBox({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
    required this.fontSize,
    required this.padding,
    this.isBenefit = false,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      index: isBenefit ? 1 : 0,
      beginOffset: const Offset(0, 10),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: padding * 0.5),
        padding: EdgeInsets.all(padding * 0.7),
        decoration: AzkarTheme.getInfoBoxDecoration(color, isDark),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PulseAnimationWidget(
              enabled: !isBenefit,
              minScale: 0.9,
              maxScale: 1.05,
              child: Icon(icon, color: color, size: fontSize * 1.4),
            ),
            SizedBox(width: padding * 0.4),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: fontSize,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: isBenefit ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}