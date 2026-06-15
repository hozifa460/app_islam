import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../languages/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ═══ Animation Controllers ═══
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // ═══ Animations ═══
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring3Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Opacity;
  late Animation<double> _ring3Opacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _dividerWidth;
  late Animation<double> _verseOpacity;
  late Animation<double> _pulse;

  bool _navigated = false;

  // ═══ ألوان ═══
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldLight = Color(0xFFE6C866);
  static const Color _goldDark = Color(0xFFB8860B);


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _ring1Scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _ring2Scale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _ring3Scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _ring1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );

    _ring2Opacity = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
      ),
    );

    _ring3Opacity = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 0.88, curve: Curves.easeOut),
      ),
    );

    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.58, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _verseOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.78, 0.98, curve: Curves.easeOut),
      ),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startSequence() async {
    await _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted && !_navigated) {
      _navigated = true;
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr; // ← الترجمة

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width = size.width;
        final height = size.height;

        final isSmallDevice = width < 360 || height < 640;
        final isMediumDevice = width < 400 || height < 700;

        final logoSize = _calculateLogoSize(
          width, height, isSmallDevice, isMediumDevice,
        );
        final ring1Size = logoSize * 1.45;
        final ring2Size = logoSize * 1.75;
        final ring3Size = logoSize * 2.05;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: _buildBackgroundGradient(isDark),
          ),
          child: Stack(
            children: [
              _buildBackgroundDecoration(isDark, width, height),
              _buildParticles(isDark, width, height),
              _buildMainContent(
                isDark, width, height,
                logoSize, ring1Size, ring2Size, ring3Size,
                isSmallDevice, isMediumDevice,
                tr, // ← تمرير الترجمة
              ),
              _buildBottomSection(isDark, width, height, isSmallDevice, tr),
            ],
          ),
        );
      },
    );
  }

  double _calculateLogoSize(
      double width,
      double height,
      bool isSmall,
      bool isMedium,
      ) {
    if (isSmall) {
      return min(width * 0.26, height * 0.13).clamp(85.0, 110.0);
    } else if (isMedium) {
      return min(width * 0.30, height * 0.15).clamp(100.0, 130.0);
    } else {
      return min(width * 0.33, height * 0.17).clamp(110.0, 150.0);
    }
  }

  Gradient _buildBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
        const Color(0xFF0A0E1A),
        const Color(0xFF1A2540),
        const Color(0xFF0F1628),
        const Color(0xFF050810),
      ]
          : [
        const Color(0xFFFFFDF8),
        const Color(0xFFFFF9EC),
        const Color(0xFFFFFBF0),
        const Color(0xFFFFF5DE),
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    );
  }

  Widget _buildBackgroundDecoration(bool isDark, double width, double height) {
    return Stack(
      children: [
        Positioned(
          top: -height * 0.12,
          left: width * 0.15,
          child: _buildGlowCircle(
            width * 0.7,
            _gold.withOpacity(isDark ? 0.06 : 0.05),
          ),
        ),
        Positioned(
          bottom: -height * 0.08,
          right: -width * 0.15,
          child: _buildGlowCircle(
            width * 0.6,
            _goldLight.withOpacity(isDark ? 0.04 : 0.03),
          ),
        ),
        Positioned(
          top: height * 0.3,
          right: -width * 0.1,
          child: _buildGlowCircle(
            width * 0.4,
            _goldDark.withOpacity(isDark ? 0.03 : 0.02),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _IslamicPatternPainter(
              color: _gold.withOpacity(isDark ? 0.015 : 0.025),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }

  Widget _buildParticles(bool isDark, double width, double height) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(width, height),
          painter: _ParticlePainter(
            progress: _particleController.value,
            color: _gold,
            isDark: isDark,
            centerX: width / 2,
            centerY: height * 0.40,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // المحتوى الرئيسي - مع حماية من الـ Overflow
  // ═══════════════════════════════════════════════════════════
  Widget _buildMainContent(
      bool isDark,
      double width,
      double height,
      double logoSize,
      double ring1Size,
      double ring2Size,
      double ring3Size,
      bool isSmall,
      bool isMedium,
      AppLocalizations tr,
      ) {
    final textColor = isDark ? Colors.white : const Color(0xFF2C1810);
    final subtitleColor = isDark
        ? Colors.white.withOpacity(0.65)
        : const Color(0xFF5D4E37).withOpacity(0.75);

    // ═══ حساب المساحة المتاحة ═══
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = height - topPadding - bottomPadding - 100;

    return SafeArea(
      child: SizedBox(
        width: width,
        height: height - topPadding - bottomPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ═══ مساحة مرنة علوية ═══
            Flexible(flex: 1, child: const SizedBox()),

            // ═══ الشعار مع الحلقات ═══
            Flexible(
              flex: 4,
              child: _buildLogoSection(
                isDark,
                logoSize,
                ring1Size,
                ring2Size,
                ring3Size,
              ),
            ),

            // ═══ مساحة بين الشعار والنص ═══
            SizedBox(height: (height * 0.03).clamp(12.0, 30.0)),

            // ═══ العنوان ═══
            Flexible(
              flex: 1,
              child: _buildTitle(textColor, width, isSmall, tr),
            ),

            // ═══ الفاصل ═══
            SizedBox(height: (height * 0.015).clamp(8.0, 18.0)),
            _buildDivider(width, isSmall),
            SizedBox(height: (height * 0.012).clamp(6.0, 15.0)),

            // ═══ الوصف ═══
            Flexible(
              flex: 1,
              child: _buildSubtitle(subtitleColor, width, isSmall, tr),
            ),

            // ═══ مساحة مرنة سفلية ═══
            Flexible(flex: 2, child: const SizedBox()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // قسم الشعار مع 3 حلقات
  // ═══════════════════════════════════════════════════════════
  Widget _buildLogoSection(
      bool isDark,
      double logoSize,
      double ring1Size,
      double ring2Size,
      double ring3Size,
      ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (_, __) {
        return Center(
          child: SizedBox(
            width: ring3Size * 1.15,
            height: ring3Size * 1.15,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ═══ الحلقة الثالثة ═══
                Opacity(
                  opacity: _ring3Opacity.value,
                  child: Transform.scale(
                    scale: _ring3Scale.value,
                    child: Container(
                      width: ring3Size,
                      height: ring3Size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withOpacity(isDark ? 0.1 : 0.08),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══ الحلقة الثانية ═══
                Opacity(
                  opacity: _ring2Opacity.value,
                  child: Transform.scale(
                    scale: _ring2Scale.value,
                    child: Container(
                      width: ring2Size,
                      height: ring2Size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withOpacity(isDark ? 0.18 : 0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══ الحلقة الأولى ═══
                Opacity(
                  opacity: _ring1Opacity.value,
                  child: Transform.scale(
                    scale: _ring1Scale.value,
                    child: Container(
                      width: ring1Size,
                      height: ring1Size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withOpacity(isDark ? 0.3 : 0.25),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══ الشعار ═══
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value * _pulse.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value,
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [
                              const Color(0xFF1E2A4A),
                              const Color(0xFF0F1628),
                            ]
                                : [
                              Colors.white,
                              const Color(0xFFFFF8E8),
                            ],
                          ),
                          border: Border.all(color: _gold, width: 2.8),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withOpacity(isDark ? 0.35 : 0.25),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : _gold.withOpacity(0.12),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(logoSize * 0.20),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.mosque_rounded,
                              size: logoSize * 0.48,
                              color: _gold,
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
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // العنوان - محمي من الـ Overflow
  // ═══════════════════════════════════════════════════════════
  Widget _buildTitle(Color textColor, double width, bool isSmall, AppLocalizations tr) {
    // ═══ حجم الخط المتكيف ═══
    final baseFontSize = isSmall ? 28.0 : 38.0;
    final maxWidth = width * 0.85;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Opacity(
          opacity: _titleOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _titleSlide.value),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      _goldDark,
                      _gold,
                      _goldLight,
                      _gold,
                      _goldDark,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ).createShader(bounds);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tr.splashTitle, // ← مترجم
                    style: GoogleFonts.amiri(
                      fontSize: baseFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // الفاصل الزخرفي
  // ═══════════════════════════════════════════════════════════
  Widget _buildDivider(double width, bool isSmall) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final progress = _dividerWidth.value;
        final maxWidth = (width * 0.35).clamp(80.0, 140.0);

        return SizedBox(
          height: 26,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: progress,
                child: Opacity(
                  opacity: progress,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: _gold.withOpacity(0.85),
                    size: isSmall ? 10 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: progress,
                  child: Container(
                    width: maxWidth,
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _goldDark.withOpacity(0.6),
                          _gold,
                          _goldLight,
                          _gold,
                          _goldDark.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Transform.scale(
                scale: progress,
                child: Opacity(
                  opacity: progress,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: _gold.withOpacity(0.85),
                    size: isSmall ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // الوصف - محمي من الـ Overflow
  // ═══════════════════════════════════════════════════════════
  Widget _buildSubtitle(Color color, double width, bool isSmall, AppLocalizations tr) {
    final fontSize = isSmall ? 13.0 : 16.0;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Opacity(
          opacity: _subtitleOpacity.value,
          child: Container(
            constraints: BoxConstraints(maxWidth: width * 0.8),
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr.splashSubtitle, // ← مترجم
                style: GoogleFonts.cairo(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.8,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // القسم السفلي - محمي من الـ Overflow
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomSection(
      bool isDark,
      double width,
      double height,
      bool isSmall,
      AppLocalizations tr,
      ) {
    final verseColor = isDark
        ? _gold.withOpacity(0.75)
        : _goldDark.withOpacity(0.85);

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final verseFontSize = isSmall ? 12.0 : 15.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (_, __) {
            return Opacity(
              opacity: _verseOpacity.value,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: (isSmall ? 16 : 24) + bottomPadding,
                  left: width * 0.08,
                  right: width * 0.08,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LoadingDots(color: _gold),
                    SizedBox(height: isSmall ? 12 : 18),

                    // ═══ الآية - محمية من الـ Overflow ═══
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.85,
                        maxHeight: 60,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tr.splashVerse, // ← مترجم
                          style: GoogleFonts.amiri(
                            fontSize: verseFontSize,
                            color: verseColor,
                            fontWeight: FontWeight.w700,
                            height: 1.6,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// رسام الجسيمات (بدون تغيير)
// ═══════════════════════════════════════════════════════════════
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;
  final double centerX;
  final double centerY;

  static final List<_Particle> _particles = List.generate(24, (i) {
    final random = Random(i * 137);
    return _Particle(
      angle: (i / 24) * 2 * pi,
      radius: 0.20 + random.nextDouble() * 0.22,
      size: 1.0 + random.nextDouble() * 2.8,
      speed: 0.15 + random.nextDouble() * 0.75,
      opacity: 0.08 + random.nextDouble() * 0.32,
    );
  });

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.isDark,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final minDimension = min(size.width, size.height);

    for (final particle in _particles) {
      final angle = particle.angle + progress * 2 * pi * particle.speed;
      final radius = particle.radius * minDimension * 0.5;

      final x = centerX + cos(angle) * radius;
      final y = centerY + sin(angle) * radius;

      paint.color = color.withOpacity(
        isDark ? particle.opacity : particle.opacity * 0.65,
      );

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  final double angle;
  final double radius;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// ═══════════════════════════════════════════════════════════════
// رسام النقوش الإسلامية (بدون تغيير)
// ═══════════════════════════════════════════════════════════════
class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const step = 75.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;

        final path = Path();
        for (int i = 0; i < 16; i++) {
          final angle = (pi / 8) * i;
          final r = i.isEven ? step * 0.28 : step * 0.15;
          final px = cx + r * cos(angle);
          final py = cy + r * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ═══════════════════════════════════════════════════════════════
// النقاط المتحركة (بدون تغيير)
// ═══════════════════════════════════════════════════════════════
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      _controllers.add(controller);

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      _animations.add(animation);

      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (_, __) {
            final value = _animations[index].value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 7 + value * 3,
              height: 7 + value * 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withOpacity(0.5 + value * 0.5),
                    widget.color.withOpacity(0.3 + value * 0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(value * 0.5),
                    blurRadius: 6 + value * 6,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}