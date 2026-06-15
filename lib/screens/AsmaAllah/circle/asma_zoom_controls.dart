import 'package:flutter/material.dart';
import '../widgets/asma_theme.dart';

class AsmaZoomControls extends StatelessWidget {
  final bool isDark;
  final TransformationController transformController;

  const AsmaZoomControls({
    super.key,
    required this.isDark,
    required this.transformController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;

        return Container(
          margin: EdgeInsets.only(bottom: isSmall ? 8 : 12),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12,
            vertical: isSmall ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? AsmaTheme.gold.withOpacity(0.3) : AsmaTheme.gold.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : AsmaTheme.gold.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ZoomBtn(
                icon: Icons.remove_rounded,
                isDark: isDark,
                size: isSmall ? 18 : 22,
                onTap: () {
                  final current = transformController.value.clone();
                  transformController.value = current..scale(0.85);
                },
              ),
              _divider(isSmall),
              _ZoomBtn(
                icon: Icons.center_focus_strong_rounded,
                isDark: isDark,
                size: isSmall ? 18 : 22,
                onTap: () => transformController.value = Matrix4.identity(),
              ),
              _divider(isSmall),
              _ZoomBtn(
                icon: Icons.add_rounded,
                isDark: isDark,
                size: isSmall ? 18 : 22,
                onTap: () {
                  final current = transformController.value.clone();
                  transformController.value = current..scale(1.2);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider(bool isSmall) {
    return Container(
      width: 1,
      height: isSmall ? 20 : 24,
      color: AsmaTheme.gold.withOpacity(isDark ? 0.3 : 0.25),
      margin: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 8),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final double size;
  final VoidCallback onTap;

  const _ZoomBtn({
    required this.icon,
    required this.isDark,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(size < 20 ? 8 : 10),
          child: Icon(
            icon,
            color: isDark ? AsmaTheme.gold : AsmaTheme.brownSub,
            size: size,
          ),
        ),
      ),
    );
  }
}