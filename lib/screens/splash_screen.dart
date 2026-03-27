// splash_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _ringScale1;
  late Animation<double> _ringScale2;
  late Animation<double> _ringOpacity1;
  late Animation<double> _ringOpacity2;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _dividerWidth;
  late Animation<double> _bottomOpacity;
  late Animation<double> _pulse;

  bool _navigated = false;

  static const _gold    = Color(0xFFE6B325);
  static const _bgDark  = Color(0xFF0A0E17);
  static const _bgLight = Color(0xFFF0F4FF);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // شعار
    _logoScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.00, 0.45, curve: Curves.easeOutBack),
    ));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.00, 0.30, curve: Curves.easeIn),
    ));

    // حلقات
    _ringScale1 = Tween(begin: 0.6, end: 1.15).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.10, 0.50, curve: Curves.easeOut),
    ));
    _ringScale2 = Tween(begin: 0.4, end: 1.30).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOut),
    ));
    _ringOpacity1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.10, 0.40, curve: Curves.easeIn),
    ));
    _ringOpacity2 = Tween(begin: 0.0, end: 0.6).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.15, 0.45, curve: Curves.easeIn),
    ));

    // نصوص
    _textSlide = Tween(begin: 40.0, end: 0.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.40, 0.72, curve: Curves.easeOutCubic),
    ));
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.40, 0.70, curve: Curves.easeIn),
    ));
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.58, 0.82, curve: Curves.easeIn),
    ));
    _dividerWidth = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.52, 0.78, curve: Curves.easeOutCubic),
    ));
    _bottomOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.72, 1.00, curve: Curves.easeIn),
    ));

    // نبضة
    _pulse = Tween(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  void _startSequence() {
    _mainCtrl.forward();
    // ✅ وقت كافٍ للـ HomeScreen يبني نفسه خلف السبلاش
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && !_navigated) {
        _navigated = true;
        // ✅ نوقف الـ controllers الثقيلة قبل الانتقال
        _pulseCtrl.stop();
        _particleCtrl.stop();
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final logoSize = (w * 0.32).clamp(90.0, 155.0);
        final ringSize = logoSize * 1.35;

        return ColoredBox(
          color: isDark ? _bgDark : _bgLight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(isDark, w, h),
              _buildParticles(isDark, w, h),
              _buildCenter(isDark, w, h, logoSize, ringSize),
              _buildBottom(isDark, w, h),
            ],
          ),
        );
      },
    );
  }

  // ── خلفية ──
  Widget _buildBackground(bool isDark, double w, double h) {
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: isDark
                ? [const Color(0xFF1A2744), const Color(0xFF0D1420), _bgDark]
                : [const Color(0xFFDDE8FF), const Color(0xFFEEF3FF), _bgLight],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
      Positioned(
        top: -(h * 0.12), left: w * 0.1,
        child: _glowCircle(w * 0.8, _gold.withOpacity(isDark ? 0.12 : 0.08)),
      ),
      Positioned(
        bottom: -(h * 0.08), right: -(w * 0.2),
        child: _glowCircle(w * 0.7, _gold.withOpacity(isDark ? 0.07 : 0.05)),
      ),
    ]);
  }

  Widget _glowCircle(double size, Color color) => SizedBox(
    width: size, height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    ),
  );

  // ── جسيمات ──
  Widget _buildParticles(bool isDark, double w, double h) {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(
          progress: _particleCtrl.value,
          color: _gold,
          isDark: isDark,
          centerY: h * 0.42,
        ),
      ),
    );
  }

  // ── المحتوى الوسطى ──
  Widget _buildCenter(bool isDark, double w, double h,
      double logoSize, double ringSize) {

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // شعار + حلقات
          AnimatedBuilder(
            animation: Listenable.merge([_mainCtrl, _pulseCtrl]),
            builder: (_, __) {
              final rW = ringSize * 1.4;
              return SizedBox(
                width: rW, height: rW,
                child: Stack(alignment: Alignment.center, children: [

                  // حلقة خارجية
                  Opacity(
                    opacity: _ringOpacity2.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _ringScale2.value,
                      child: _ring(ringSize * 1.2, _gold.withOpacity(0.15), 1.0),
                    ),
                  ),

                  // حلقة داخلية
                  Opacity(
                    opacity: _ringOpacity1.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _ringScale1.value,
                      child: _ring(ringSize, _gold.withOpacity(0.30), 1.5),
                    ),
                  ),

                  // الشعار
                  Opacity(
                    opacity: _logoOpacity.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: (_logoScale.value * _pulse.value).clamp(0.0, 2.0),
                      child: _buildLogo(isDark, logoSize),
                    ),
                  ),
                ]),
              );
            },
          ),

          SizedBox(height: h * 0.038),

          // الاسم
          AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, __) => Opacity(
              opacity: _textOpacity.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, _textSlide.value),
                child: Text(
                  'طريق الإسلام',
                  style: GoogleFonts.amiri(
                    fontSize: (w * 0.10).clamp(28.0, 50.0),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                    shadows: [Shadow(color: _gold.withOpacity(0.2), blurRadius: 12)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          SizedBox(height: h * 0.010),

          // فاصل
          AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, __) {
              final v = _dividerWidth.value.clamp(0.0, 1.0);
              final maxW = (w * 0.32).clamp(80.0, 150.0);
              return SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Opacity(opacity: v,
                        child: Icon(Icons.star_rounded,
                            color: _gold.withOpacity(0.7), size: 10)),
                    const SizedBox(width: 6),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: v,
                        child: Container(
                          width: maxW, height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              _gold.withOpacity(0.7),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Opacity(opacity: v,
                        child: Icon(Icons.star_rounded,
                            color: _gold.withOpacity(0.7), size: 10)),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: h * 0.008),

          // الوصف
          AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, __) => Opacity(
              opacity: _subtitleOpacity.value.clamp(0.0, 1.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: (w * 0.1).clamp(12.0, 40.0)),
                child: Text(
                  'رفيقك في العبادة اليومية',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.040).clamp(12.0, 17.0),
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.55)
                        : const Color(0xFF1A1A2E).withOpacity(0.50),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size, Color color, double width) => SizedBox(
    width: size, height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
      ),
    ),
  );

  Widget _buildLogo(bool isDark, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? [const Color(0xFF1E2D4A), const Color(0xFF0D1420)]
              : [Colors.white, const Color(0xFFEEF3FF)],
        ),
        border: Border.all(color: _gold.withOpacity(0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(isDark ? 0.22 : 0.14),
            blurRadius: 28, spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.07),
            blurRadius: 18, offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Image.asset(
        'assets/icon/icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.mosque_rounded, size: size * 0.48, color: _gold),
      ),
    );
  }

  // ── القسم السفلي ──
  Widget _buildBottom(bool isDark, double w, double h) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _mainCtrl,
          builder: (_, __) => Opacity(
            opacity: _bottomOpacity.value.clamp(0.0, 1.0),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: (h * 0.038).clamp(14.0, 38.0),
                left:   (w * 0.06).clamp(12.0, 30.0),
                right:  (w * 0.06).clamp(12.0, 30.0),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _AnimatedDots(color: _gold),
                SizedBox(height: (h * 0.018).clamp(8.0, 20.0)),
                Text(
                  '﴿ وَاذْكُرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ ﴾',
                  style: GoogleFonts.amiri(
                    fontSize: (w * 0.035).clamp(11.0, 15.0),
                    color: _gold.withOpacity(isDark ? 0.65 : 0.72),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Particle Painter
// ══════════════════════════════════════════════════════════════
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color  color;
  final bool   isDark;
  final double centerY;

  static final _pts = List.generate(16, (i) {
    final r = Random(i * 137);
    return (
    angle:   (i / 16) * 2 * pi,
    radius:  0.26 + r.nextDouble() * 0.16,
    size:    1.4  + r.nextDouble() * 2.2,
    speed:   0.25 + r.nextDouble() * 0.65,
    opacity: 0.12 + r.nextDouble() * 0.28,
    );
  });

  const _ParticlePainter({
    required this.progress,
    required this.color,
    required this.isDark,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = centerY;
    final minD = size.width < size.height ? size.width : size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _pts) {
      final a = p.angle + progress * 2 * pi * p.speed;
      final r = p.radius * minD * 0.5;
      paint.color = color.withOpacity(
          isDark ? p.opacity : p.opacity * 0.55);
      canvas.drawCircle(
        Offset(cx + cos(a) * r, cy + sin(a) * r),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.progress != progress;
}

// ══════════════════════════════════════════════════════════════
//  Loading Dots
// ══════════════════════════════════════════════════════════════
class _AnimatedDots extends StatefulWidget {
  final Color color;
  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {

  final _ctrls = <AnimationController>[];
  final _anims = <Animation<double>>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 650),
      );
      _ctrls.add(c);
      _anims.add(Tween(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)));
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) {
          final v = _anims[i].value;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width:  5 + v * 2,
            height: 5 + v * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.35 + v * 0.65),
            ),
          );
        },
      )),
    );
  }
}