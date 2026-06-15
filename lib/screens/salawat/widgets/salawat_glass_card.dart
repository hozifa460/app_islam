import 'package:flutter/material.dart';
import 'salawat_theme.dart';

class SalawatGlassCard extends StatelessWidget {
  final SalawatTheme theme;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SalawatGlassCard({
    super.key,
    required this.theme,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(SalawatTheme.innerPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SalawatTheme.cardRadius),
        border: Border.all(
          color: theme.cardBorderColor,
          width: 1,
        ),
        boxShadow: theme.cardShadow,
      ),
      child: child,
    );
  }
}