import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';
import 'qibla_compass_dial.dart';
import 'qibla_needle.dart';

class QiblaCompassSection extends StatelessWidget {
  final QiblaTheme theme;
  final double compassSize;
  final bool isFacing;
  final Color guidance;
  final double needleAngle;
  final double dialAngle;
  final double deviation;
  final Animation<double> pulseAnim;
  final Animation<double> glowAnim;

  const QiblaCompassSection({
    super.key,
    required this.theme,
    required this.compassSize,
    required this.isFacing,
    required this.guidance,
    required this.needleAngle,
    required this.dialAngle,
    required this.deviation,
    required this.pulseAnim,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // طھط¹ظ„ظٹظ…ط©
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: theme.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : QiblaTheme.gold.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 13,
                  color: theme.isDark ? Colors.white54 : Colors.black45),
              const SizedBox(width: 6),
              Text(
                'أمسك الهاتف أفقياً ودوّر حتى تشير الإبرة ▲ للأعلى',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: theme.isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ط§ظ„ط¨ظˆطµظ„ط©
        SizedBox(
          width: compassSize + 44,
          height: compassSize + 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // طھظˆظ‡ط¬
              if (glowAnim.value > 0)
                Container(
                  width: compassSize + 34,
                  height: compassSize + 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: QiblaTheme.green
                            .withValues(alpha: 0.38 * glowAnim.value),
                        blurRadius: 38,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

              // ط­ظ„ظ‚ط© ط®ط§ط±ط¬ظٹط©
              Transform.scale(
                scale: isFacing ? pulseAnim.value : 1.0,
                child: Container(
                  width: compassSize + 14,
                  height: compassSize + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        guidance.withValues(alpha: 0.85),
                        guidance.withValues(alpha: 0.08),
                        guidance.withValues(alpha: 0.85),
                        guidance.withValues(alpha: 0.08),
                        guidance.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // ط§ظ„ظ‚ط±طµ
              Transform.rotate(
                angle: dialAngle,
                child: QiblaCompassDial(
                  size: compassSize,
                  isDark: theme.isDark,
                ),
              ),

              // ط§ظ„ط¥ط¨ط±ط©
              Transform.rotate(
                angle: needleAngle,
                child: QiblaNeedle(
                  height: compassSize * 0.50,
                  isFacing: isFacing,
                ),
              ),

              // ط§ظ„ظ…ط±ظƒط²
              QiblaCenterDot(theme: theme, isFacing: isFacing),

              // ظ…ط¤ط´ط± ط§ظ„ظ‡ط§طھظپ
              Positioned(
                top: 0,
                child: QiblaPhoneIndicator(theme: theme, isFacing: isFacing),
              ),

              // ط³ظ‡ظ… ط§ظ„ط¯ظˆط±ط§ظ†
              if (!isFacing)
                Positioned(
                  bottom: 2,
                  child:
                  QiblaRotationHint(theme: theme, deviation: deviation),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ط§ظ„ط§ظ†ط­ط±ط§ظپ
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            key: ValueKey(isFacing),
            isFacing
                ? '🕋  أنت تواجه الكعبة المشرفة'
                : 'انحراف: ${deviation.abs().toStringAsFixed(1)}آ°'
                ' ${deviation > 0 ? "يساراً" : "يميناً"}',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isFacing
                  ? QiblaTheme.green
                  : (theme.isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}