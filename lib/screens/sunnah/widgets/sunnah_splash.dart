import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sunnah_theme.dart';

class SunnahSplash extends StatelessWidget {
  final Size size;
  final EdgeInsets padding;
  final SunnahTheme theme;
  final AnimationController pulseController;
  final Animation<double> pulseAnim;

  const SunnahSplash({
    super.key,
    required this.size,
    required this.padding,
    required this.theme,
    required this.pulseController,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.splashGradient,
        ),
      ),
      child: Stack(
        children: [
          ...List.generate(15, (i) => _buildParticle(i)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: pulseAnim.value,
                      child: Container(
                        width: size.width * 0.28,
                        height: size.width * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              SunnahTheme.emeraldLight.withOpacity(0.3),
                              SunnahTheme.emeraldDark.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: SunnahTheme.emerald.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SunnahTheme.emerald.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('🕌',
                              style: TextStyle(fontSize: size.width * 0.12)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [
                        SunnahTheme.emeraldLight,
                        SunnahTheme.goldLight,
                        SunnahTheme.emeraldLight,
                      ],
                    ).createShader(b),
                    child: Text(
                      'متتبع السنن النبوية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'احرص على سننه ﷺ',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: size.width * 0.038,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  SizedBox(
                    width: size.width * 0.45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF1F2937),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(SunnahTheme.emerald),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    final rng = math.Random(index * 42);
    final w = rng.nextDouble() * 3 + 1;
    final left = rng.nextDouble() * size.width;
    final top = rng.nextDouble() * size.height;
    final colors = [SunnahTheme.emerald, SunnahTheme.gold, Colors.white70];

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (_, __) => Opacity(
          opacity:
          (math.sin(pulseController.value * math.pi * 2 + index) + 1) /
              2 *
              0.5,
          child: Container(
            width: w,
            height: w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % 3],
            ),
          ),
        ),
      ),
    );
  }
}