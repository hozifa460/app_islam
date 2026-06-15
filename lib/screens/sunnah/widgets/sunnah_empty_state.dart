import 'package:flutter/material.dart';
import 'sunnah_theme.dart';

class SunnahEmptyState extends StatelessWidget {
  final Size size;
  final SunnahTheme theme;
  final AnimationController floatingController;
  final Animation<double> floatingAnim;
  final TabController tabController;

  const SunnahEmptyState({
    super.key,
    required this.size,
    required this.theme,
    required this.floatingController,
    required this.floatingAnim,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: floatingController,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, floatingAnim.value),
                child: child,
              ),
              child: Container(
                width: size.width * 0.28,
                height: size.width * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    SunnahTheme.emerald.withOpacity(0.15),
                    Colors.transparent,
                  ]),
                  border: Border.all(
                    color: SunnahTheme.emerald.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text('🌙',
                      style: TextStyle(fontSize: size.width * 0.14)),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text('لا توجد سنن لهذا الوقت',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: size.width * 0.048,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: size.height * 0.01),
            Text('تفضل بمشاهدة جميع السنن\nمن التبويب الثاني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: size.width * 0.035,
                  height: 1.5,
                )),
            SizedBox(height: size.height * 0.035),
            GestureDetector(
              onTap: () => tabController.animateTo(1),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.018,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: SunnahTheme.emeraldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: SunnahTheme.emerald.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 16)),
                    SizedBox(width: size.width * 0.02),
                    Text('جميع السنن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}