import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  âœ¨ ظ†ظ‚ط·ط© ط¨ط« ظ…طھط­ط±ظƒط© ظ…ط¹ ط£ظ…ظˆط§ط¬ (Ripple Waves)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AnimatedPulsingDot extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedPulsingDot({
    super.key,
    required this.size,
    this.color = Colors.red,
  });

  @override
  State<AnimatedPulsingDot> createState() => _AnimatedPulsingDotState();
}

class _AnimatedPulsingDotState extends State<AnimatedPulsingDot>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _wave1Ctrl;
  late AnimationController _wave2Ctrl;

  late Animation<double> _pulseAnim;
  late Animation<double> _wave1Anim;
  late Animation<double> _wave2Anim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _wave1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _wave2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // طھط£ط®ظٹط± ط§ظ„ظ…ظˆط¬ط© ط§ظ„ط«ط§ظ†ظٹط©
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _wave2Ctrl.repeat();
    });

    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _wave1Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wave1Ctrl, curve: Curves.easeOut),
    );

    _wave2Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wave2Ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _wave1Ctrl.dispose();
    _wave2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ظ…ظˆط¬ط© 1
          AnimatedBuilder(
            animation: _wave1Anim,
            builder: (_, __) => Container(
              width: widget.size + (widget.size * 2 * _wave1Anim.value),
              height: widget.size + (widget.size * 2 * _wave1Anim.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.4 * (1 - _wave1Anim.value)),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // ظ…ظˆط¬ط© 2
          AnimatedBuilder(
            animation: _wave2Anim,
            builder: (_, __) => Container(
              width: widget.size + (widget.size * 2 * _wave2Anim.value),
              height: widget.size + (widget.size * 2 * _wave2Anim.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3 * (1 - _wave2Anim.value)),
                  width: 1,
                ),
              ),
            ),
          ),

          // ط§ظ„ظ†ظ‚ط·ط© ط§ظ„ط±ط¦ظٹط³ظٹط©
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: _pulseAnim.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _pulseAnim.value * 0.5),
                    blurRadius: widget.size * 1.5,
                    spreadRadius: widget.size * 0.3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  âœ¨ ط´ط§ط±ط© LIVE ظ…ط­ط³ظ‘ظ†ط© ظ…ط¹ Shimmer + Glow
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AnimatedLiveBadge extends StatefulWidget {
  final double dotSize;
  final double fontSize;
  final double px;
  final double py;
  final bool showWaves;

  const AnimatedLiveBadge({
    super.key,
    required this.dotSize,
    required this.fontSize,
    required this.px,
    required this.py,
    this.showWaves = false,
  });

  @override
  State<AnimatedLiveBadge> createState() => _AnimatedLiveBadgeState();
}

class _AnimatedLiveBadgeState extends State<AnimatedLiveBadge>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _glowAnim = Tween<double>(begin: 0.08, end: 0.25).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.px,
          vertical: widget.py,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: _glowAnim.value),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3 + _glowAnim.value),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: _glowAnim.value * 0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ظ†ظ‚ط·ط© ظ…طھط­ط±ظƒط© ظ…ط¹ ط£ظ…ظˆط§ط¬
            SizedBox(
              width: widget.dotSize * (widget.showWaves ? 3 : 1),
              height: widget.dotSize * (widget.showWaves ? 3 : 1),
              child: widget.showWaves
                  ? AnimatedPulsingDot(size: widget.dotSize)
                  : _SimplePulsingDot(size: widget.dotSize),
            ),
            SizedBox(width: widget.dotSize * 0.8),
            // ظ†طµ LIVE ظ…ط¹ Shimmer
            AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (_, __) => ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(_shimmerAnim.value - 1, 0),
                  end: Alignment(_shimmerAnim.value, 0),
                  colors: const [
                    Colors.red,
                    Colors.white,
                    Colors.red,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.cairo(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
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

// ظ†ظ‚ط·ط© ط¨ط³ظٹط·ط© ط¨ط¯ظˆظ† ط£ظ…ظˆط§ط¬ (ظ„ظ„ط£ظ…ط§ظƒظ† ط§ظ„طµط؛ظٹط±ط©)
class _SimplePulsingDot extends StatefulWidget {
  final double size;
  const _SimplePulsingDot({required this.size});

  @override
  State<_SimplePulsingDot> createState() => _SimplePulsingDotState();
}

class _SimplePulsingDotState extends State<_SimplePulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: _anim.value),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: _anim.value * 0.4),
              blurRadius: widget.size,
              spreadRadius: widget.size * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  âœ¨ ط²ط± ط§ظ„ط¨ط« ط§ظ„ظ…ط¨ط§ط´ط± ط§ظ„ظ…ط­ط³ظ‘ظ† ظ…ط¹ ط£ظ…ظˆط§ط¬ ظˆطھظˆظ‡ط¬
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AnimatedLiveButton extends StatefulWidget {
  final double w;
  final double nameFontSize;
  final bool isDark;
  final VoidCallback onTap;

  const AnimatedLiveButton({
    super.key,
    required this.w,
    required this.nameFontSize,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<AnimatedLiveButton> createState() => _AnimatedLiveButtonState();
}

class _AnimatedLiveButtonState extends State<AnimatedLiveButton>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _borderCtrl;

  late Animation<double> _glowAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _borderAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowAnim = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );

    _borderAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _borderCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _scaleCtrl.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnim, _scaleAnim, _borderAnim]),
        builder: (_, __) => Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.w * 0.035,
              vertical: widget.w * 0.022,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  math.cos(_borderAnim.value),
                  math.sin(_borderAnim.value),
                ),
                end: Alignment(
                  math.cos(_borderAnim.value + math.pi),
                  math.sin(_borderAnim.value + math.pi),
                ),
                colors: [
                  Colors.red.withValues(alpha: widget.isDark ? 0.2 : 0.12),
                  const Color(0xFFFF4444).withValues(alpha: widget.isDark ? 0.15 : 0.08),
                  Colors.red.withValues(alpha: widget.isDark ? 0.2 : 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(
                  (widget.w * 0.035).clamp(12.0, 16.0)),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.35 + _glowAnim.value * 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: _glowAnim.value * 0.5),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.red.withValues(alpha: _glowAnim.value * 0.2),
                  blurRadius: 30,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ط£ظٹظ‚ظˆظ†ط© ط¨ط« ظ…ط¹ ط£ظ…ظˆط§ط¬
                SizedBox(
                  width: (widget.w * 0.06).clamp(18.0, 28.0),
                  height: (widget.w * 0.06).clamp(18.0, 28.0),
                  child: AnimatedPulsingDot(
                    size: (widget.w * 0.02).clamp(6.0, 9.0),
                  ),
                ),
                SizedBox(width: widget.w * 0.012),
                // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ط¨ط«
                Icon(
                  Icons.live_tv_rounded,
                  color: Colors.red,
                  size: (widget.w * 0.04).clamp(14.0, 20.0),
                ),
                SizedBox(width: widget.w * 0.014),
                Text(
                  'بث مباشر',
                  style: GoogleFonts.cairo(
                    fontSize: widget.nameFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  âœ¨ ظ…ط¤ط´ط± "ظ…ط¨ط§ط´ط± ط§ظ„ط¢ظ†" ظٹط¸ظ‡ط± ط¹ظ„ظ‰ ط¨ط·ط§ظ‚ط© ط§ظ„ط´ظٹط®
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class LiveNowIndicator extends StatefulWidget {
  final double w;

  const LiveNowIndicator({super.key, required this.w});

  @override
  State<LiveNowIndicator> createState() => _LiveNowIndicatorState();
}

class _LiveNowIndicatorState extends State<LiveNowIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 3,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: _anim.value * 0.8),
              Colors.red.withValues(alpha: 0.1),
              Colors.red.withValues(alpha: _anim.value * 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: _anim.value * 0.3),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}