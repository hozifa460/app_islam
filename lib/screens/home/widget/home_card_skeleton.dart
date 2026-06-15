import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class HomeCardSkeleton extends StatefulWidget {
  final bool isDark;
  final double height;
  final BorderRadius? borderRadius;

  const HomeCardSkeleton({
    super.key,
    required this.isDark,
    this.height = 140,
    this.borderRadius,
  });

  @override
  State<HomeCardSkeleton> createState() => _HomeCardSkeletonState();
}

class _HomeCardSkeletonState extends State<HomeCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
    widget.isDark ? const Color(0xFF1E2A27) : const Color(0xFFEFE7DB);
    final highlightColor =
    widget.isDark ? const Color(0xFF2A3B36) : const Color(0xFFF8F3EA);

    final radius = widget.borderRadius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;

            return RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final shimmerLeft = lerpDouble(
                    -width * 0.65,
                    width * 1.2,
                    _controller.value,
                  )!;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: radius,
                          ),
                        ),
                      ),
                      Positioned(
                        left: shimmerLeft,
                        top: -20,
                        bottom: -20,
                        child: Transform.rotate(
                          angle: 0.18,
                          child: Container(
                            width: width * 0.32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  baseColor.withOpacity(0.0),
                                  highlightColor.withOpacity(0.95),
                                  baseColor.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}