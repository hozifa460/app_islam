import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ظˆظٹط¯ط¬طھ ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ظ…ط­ط³ظ†ط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AzkarLoadingWidget extends StatefulWidget {
  final String message;

  const AzkarLoadingWidget({
    super.key,
    this.message = 'جاري تحميل الأذكار...',
  });

  @override
  State<AzkarLoadingWidget> createState() => _AzkarLoadingWidgetState();
}

class _AzkarLoadingWidgetState extends State<AzkarLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AzkarTheme.getBackgroundColor(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ط£ظٹظ‚ظˆظ†ط© ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ظ…طھط­ط±ظƒط©
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ط§ظ„ط¯ط§ط¦ط±ط© ط§ظ„ط®ط§ط±ط¬ظٹط© ط§ظ„ظ…طھط­ط±ظƒط©
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AzkarTheme.gold.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 35,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AzkarTheme.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ط§ظ„ط£ظٹظ‚ظˆظ†ط© ط§ظ„ظ…ط±ظƒط²ظٹط©
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AzkarTheme.gold.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AzkarTheme.gold,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ظ†طµ ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ظ…طھط­ط±ظƒ
            ShimmerAnimationWidget(
              baseColor: AzkarTheme.gold.withValues(alpha: 0.5),
              highlightColor: AzkarTheme.gold,
              child: Text(
                widget.message,
                style: GoogleFonts.cairo(
                  color: AzkarTheme.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ظ†ظ‚ط§ط· ط§ظ„طھط­ظ…ظٹظ„
            _LoadingDots(),
          ],
        ),
      ),
    );
  }
}

// ظ†ظ‚ط§ط· ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ظ…طھط­ط±ظƒط©
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 150));
      if (mounted) {
        _controllers[i].repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Opacity(
              opacity: _animations[index].value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AzkarTheme.gold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}