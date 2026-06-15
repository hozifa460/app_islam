import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════════════
/// BooksAnimations - المسؤول عن جميع الحركات والانيميشن
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════
// انيميشن ظهور البطاقات مع انزلاق
// ═══════════════════════════════════════════
class StaggeredBookCardAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration? baseDuration;

  const StaggeredBookCardAnimation({
    super.key,
    required this.child,
    required this.index,
    this.baseDuration,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: baseDuration ?? Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن الضغط على البطاقة
// ═══════════════════════════════════════════
class TapScaleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressScale;

  const TapScaleAnimation({
    super.key,
    required this.child,
    required this.onTap,
    this.pressScale = 0.96,
  });

  @override
  State<TapScaleAnimation> createState() => _TapScaleAnimationState();
}

class _TapScaleAnimationState extends State<TapScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن التوهج للبانر
// ═══════════════════════════════════════════
class BannerGlowAnimation extends StatefulWidget {
  final Widget child;
  final Color glowColor;

  const BannerGlowAnimation({
    super.key,
    required this.child,
    this.glowColor = Colors.white,
  });

  @override
  State<BannerGlowAnimation> createState() => _BannerGlowAnimationState();
}

class _BannerGlowAnimationState extends State<BannerGlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withOpacity(_animation.value * 0.3),
              blurRadius: 20 + (_animation.value * 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن التحميل الدائري
// ═══════════════════════════════════════════
class CircularProgressAnimation extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;

  const CircularProgressAnimation({
    super.key,
    required this.progress,
    required this.color,
    this.size = 50,
  });

  @override
  State<CircularProgressAnimation> createState() =>
      _CircularProgressAnimationState();
}

class _CircularProgressAnimationState extends State<CircularProgressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          value: _animation.value,
          strokeWidth: 3,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن الشيمر للصور
// ═══════════════════════════════════════════
class ShimmerLoadingAnimation extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoadingAnimation({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoadingAnimation> createState() =>
      _ShimmerLoadingAnimationState();
}

class _ShimmerLoadingAnimationState extends State<ShimmerLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFFE0E0E0),
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
            stops: [
              _controller.value - 0.3,
              _controller.value,
              _controller.value + 0.3,
            ].map((e) => e.clamp(0.0, 1.0)).toList(),
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن نبض أيقونة التحميل
// ═══════════════════════════════════════════
class PulseDownloadIcon extends StatefulWidget {
  final Widget child;
  final bool isDownloading;

  const PulseDownloadIcon({
    super.key,
    required this.child,
    this.isDownloading = false,
  });

  @override
  State<PulseDownloadIcon> createState() => _PulseDownloadIconState();
}

class _PulseDownloadIconState extends State<PulseDownloadIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isDownloading) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseDownloadIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDownloading && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isDownloading && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDownloading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن انزلاق الإعدادات
// ═══════════════════════════════════════════
class SlideDownAnimation extends StatelessWidget {
  final Widget child;
  final bool show;

  const SlideDownAnimation({
    super.key,
    required this.child,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
      child: show ? child : const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن عدد الصفحات
// ═══════════════════════════════════════════
class CounterTextAnimation extends StatelessWidget {
  final int count;
  final TextStyle? style;
  final Duration duration;

  const CounterTextAnimation({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Text(
        '$value',
        style: style,
      ),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن ظهور وإخفاء UI القارئ
// ═══════════════════════════════════════════
class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final bool show;
  final Offset beginOffset;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    required this.show,
    this.beginOffset = const Offset(0, -0.2),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedSlide(
        offset: show ? Offset.zero : beginOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن دوران أيقونة القفل
// ═══════════════════════════════════════════
class RotateIconAnimation extends StatelessWidget {
  final IconData icon;
  final bool rotate;
  final Color? color;
  final double? size;

  const RotateIconAnimation({
    super.key,
    required this.icon,
    this.rotate = false,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rotate ? math.pi / 4 : 0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) => Transform.rotate(
        angle: value,
        child: child,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن الفلاتر
// ═══════════════════════════════════════════
class FilterChipAnimation extends StatelessWidget {
  final Widget child;
  final bool isSelected;

  const FilterChipAnimation({
    super.key,
    required this.child,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════
// انيميشن انتقال الصفحات
// ═══════════════════════════════════════════
class BooksPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  BooksPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}