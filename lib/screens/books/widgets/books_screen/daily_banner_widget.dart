import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// البانر اليومي المتحرك
/// ═══════════════════════════════════════════════════════════════════════════
class DailyBannerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final bool isDark;

  const DailyBannerWidget({
    super.key,
    required this.banners,
    required this.isDark,
  });

  @override
  State<DailyBannerWidget> createState() => _DailyBannerWidgetState();
}

class _DailyBannerWidgetState extends State<DailyBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _todayBanner {
    int dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return widget.banners[dayOfYear % widget.banners.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
      ),
      child: BannerGlowAnimation(
        glowColor: BooksTheme.gold,
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BooksTheme.getBannerDecoration(
            List<Color>.from(_todayBanner['colors']),
            widget.isDark,
          ),
          child: Stack(
            children: [
              // خلفية زخرفية
              _buildDecorativeElements(),
              // النص
              Center(
                child: _AnimatedBannerText(text: _todayBanner['text']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: _FloatingCircle(size: 100, opacity: 0.1),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: _FloatingCircle(size: 80, opacity: 0.08),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: _FloatingCircle(size: 40, opacity: 0.15),
        ),
      ],
    );
  }
}

class _AnimatedBannerText extends StatefulWidget {
  final String text;

  const _AnimatedBannerText({required this.text});

  @override
  State<_AnimatedBannerText> createState() => _AnimatedBannerTextState();
}

class _AnimatedBannerTextState extends State<_AnimatedBannerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 2 * (_controller.value - 0.5)),
        child: child,
      ),
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.3,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCircle extends StatefulWidget {
  final double size;
  final double opacity;

  const _FloatingCircle({
    required this.size,
    required this.opacity,
  });

  @override
  State<_FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<_FloatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: 0.9 + (_controller.value * 0.2),
        child: Opacity(
          opacity: widget.opacity + (_controller.value * 0.05),
          child: child,
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(widget.opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}