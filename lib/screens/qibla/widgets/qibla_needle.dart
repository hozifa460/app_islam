import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

// ── الإبرة ──
class QiblaNeedle extends StatelessWidget {
  final double height;
  final bool isFacing;

  const QiblaNeedle({
    super.key,
    required this.height,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    final top = isFacing ? QiblaTheme.green : const Color(0xFF27AE60);
    final bottom = isFacing
        ? QiblaTheme.green.withOpacity(0.3)
        : Colors.grey.withOpacity(0.38);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: QiblaTheme.needleWidth,
          height: height * 0.56,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomPaint(
                size: Size(QiblaTheme.needleWidth, height * 0.56),
                painter: TrianglePainter(color: top, pointUp: true),
              ),
              Positioned(
                top: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: top, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: top.withOpacity(0.3), blurRadius: 4),
                    ],
                  ),
                  child: Icon(Icons.mosque_rounded, size: 10, color: top),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: QiblaTheme.needleWidth,
          height: height * 0.44,
          child: CustomPaint(
            painter: TrianglePainter(color: bottom, pointUp: false),
          ),
        ),
      ],
    );
  }
}

// ── المركز ──
class QiblaCenterDot extends StatelessWidget {
  final QiblaTheme theme;
  final bool isFacing;

  const QiblaCenterDot({
    super.key,
    required this.theme,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: QiblaTheme.centerDotSize,
      height: QiblaTheme.centerDotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isFacing
              ? [QiblaTheme.green, QiblaTheme.darkGreen]
              : [
            theme.isDark
                ? const Color(0xFF1E2D3A)
                : Colors.white,
            theme.isDark
                ? const Color(0xFF0D1420)
                : const Color(0xFFEEF0F5),
          ],
        ),
        border: Border.all(
          color: isFacing ? QiblaTheme.green : QiblaTheme.gold,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFacing ? QiblaTheme.green : QiblaTheme.gold)
                .withOpacity(0.35),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.my_location_rounded,
        color: isFacing
            ? Colors.white
            : (theme.isDark ? QiblaTheme.gold : QiblaTheme.darkGreen),
        size: 17,
      ),
    );
  }
}

// ── مؤشر الهاتف ──
class QiblaPhoneIndicator extends StatelessWidget {
  final QiblaTheme theme;
  final bool isFacing;

  const QiblaPhoneIndicator({
    super.key,
    required this.theme,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isFacing
                ? QiblaTheme.green.withOpacity(0.13)
                : (theme.isDark
                ? Colors.white.withOpacity(0.09)
                : Colors.white.withOpacity(0.95)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFacing
                  ? QiblaTheme.green.withOpacity(0.45)
                  : QiblaTheme.gold.withOpacity(0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFacing
                    ? Icons.check_circle_rounded
                    : Icons.smartphone_rounded,
                size: 12,
                color: isFacing ? QiblaTheme.green : QiblaTheme.gold,
              ),
              const SizedBox(width: 4),
              Text(
                isFacing ? 'القبلة ✓' : 'موقعك',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isFacing
                      ? QiblaTheme.green
                      : (theme.isDark ? Colors.white70 : QiblaTheme.darkGreen),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          color: isFacing ? QiblaTheme.green : QiblaTheme.gold,
          size: 28,
        ),
      ],
    );
  }
}

// ── سهم الدوران ──
class QiblaRotationHint extends StatelessWidget {
  final QiblaTheme theme;
  final double deviation;

  const QiblaRotationHint({
    super.key,
    required this.theme,
    required this.deviation,
  });

  @override
  Widget build(BuildContext context) {
    final goLeft = deviation > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: theme.isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QiblaTheme.gold.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            goLeft
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_forward_ios_rounded,
            color: QiblaTheme.gold,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            goLeft ? 'دوّر لليسار' : 'دوّر لليمين',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.isDark ? Colors.white70 : QiblaTheme.darkGreen,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            goLeft
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_forward_ios_rounded,
            color: QiblaTheme.gold,
            size: 13,
          ),
        ],
      ),
    );
  }
}

// ── رسام المثلث ──
class TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointUp;
  const TrianglePainter({required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..color = color.withOpacity(0.22));

    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withOpacity(0.72),
              color,
              color.withOpacity(0.72),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(TrianglePainter o) =>
      o.color != color || o.pointUp != pointUp;
}