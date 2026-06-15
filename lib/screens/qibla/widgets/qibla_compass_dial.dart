import 'dart:math' show pi, sin, cos;
import 'package:flutter/material.dart';
import 'qibla_theme.dart';

class QiblaCompassDial extends StatelessWidget {
  final double size;
  final bool isDark;

  const QiblaCompassDial({
    super.key,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _DialPainter(isDark: isDark, gold: QiblaTheme.gold),
    ),
  );
}

class _DialPainter extends CustomPainter {
  final bool isDark;
  final Color gold;
  const _DialPainter({required this.isDark, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? [const Color(0xFF1C2A3A), const Color(0xFF0D1420)]
              : [Colors.white, const Color(0xFFF2F2F8)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    canvas.drawCircle(
        c,
        r - 2,
        Paint()
          ..color = gold.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(
        c,
        r - 9,
        Paint()
          ..color =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    for (int i = 0; i < 360; i += 5) {
      final a = i * pi / 180;
      final iM = i % 90 == 0;
      final im = i % 45 == 0;
      final i1 = i % 10 == 0;
      final len =
      iM ? r * 0.15 : im ? r * 0.11 : i1 ? r * 0.07 : r * 0.04;

      canvas.drawLine(
        Offset(c.dx + (r - 10) * sin(a), c.dy - (r - 10) * cos(a)),
        Offset(c.dx + (r - 10 - len) * sin(a),
            c.dy - (r - 10 - len) * cos(a)),
        Paint()
          ..color = i == 0
              ? Colors.red
              : iM
              ? gold
              : (isDark ? Colors.white : Colors.black)
              .withValues(alpha: im ? 0.5 : 0.18)
          ..strokeWidth = iM ? 2.5 : im ? 1.5 : 1.0
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final d in [
      (t: 'N', a: 0.0, c2: Colors.red, fs: 21.0, b: true),
      (t: 'S', a: pi, c2: gold, fs: 16.0, b: true),
      (t: 'E', a: pi / 2, c2: gold, fs: 16.0, b: true),
      (t: 'W', a: -pi / 2, c2: gold, fs: 16.0, b: true),
      (
      t: 'NE',
      a: pi / 4,
      c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38),
      fs: 10.5,
      b: false
      ),
      (
      t: 'SE',
      a: 3 * pi / 4,
      c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38),
      fs: 10.5,
      b: false
      ),
      (
      t: 'SW',
      a: -3 * pi / 4,
      c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38),
      fs: 10.5,
      b: false
      ),
      (
      t: 'NW',
      a: -pi / 4,
      c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38),
      fs: 10.5,
      b: false
      ),
    ]) {
      final p = Offset(
        c.dx + r * 0.72 * sin(d.a),
        c.dy - r * 0.72 * cos(d.a),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: d.t,
          style: TextStyle(
            fontSize: d.fs,
            fontWeight: d.b ? FontWeight.w900 : FontWeight.w600,
            color: d.c2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    for (final rr in [r * 0.44, r * 0.27]) {
      canvas.drawCircle(
          c,
          rr,
          Paint()
            ..color =
            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_DialPainter o) => o.isDark != isDark;
}