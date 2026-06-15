import 'package:flutter/material.dart';

/// ويدجت الأنيميشن للظهور مع الانزلاق
class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final int baseDelay;
  final int delayPerItem;
  final double slideOffset;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = 400,
    this.delayPerItem = 80,
    this.slideOffset = 30,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: baseDelay + (index * delayPerItem)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ويدجت أنيميشن للقائمة
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      index: index,
      slideOffset: 20,
      child: child,
    );
  }
}

/// ويدجت أنيميشن للشبكة
class AnimatedGridItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedGridItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      index: index,
      slideOffset: 30,
      child: child,
    );
  }
}