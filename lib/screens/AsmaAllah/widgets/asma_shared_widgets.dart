import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'asma_theme.dart';

class AsmaAppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDecorative;

  const AsmaAppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isDecorative ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AsmaTheme.gold.withOpacity(isDecorative ? 0.1 : 0.15),
                AsmaTheme.gold.withOpacity(isDecorative ? 0.05 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AsmaTheme.gold.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: isDecorative ? AsmaTheme.gold.withOpacity(0.5) : AsmaTheme.gold,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class AsmaMiniDot extends StatelessWidget {
  const AsmaMiniDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AsmaTheme.gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AsmaTheme.gold.withOpacity(0.5), blurRadius: 4),
        ],
      ),
    );
  }
}

class AsmaDecorativeDivider extends StatelessWidget {
  final bool isSmall;
  const AsmaDecorativeDivider({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isSmall ? 100 : 120,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AsmaTheme.gold.withOpacity(0.5),
                  AsmaTheme.gold,
                ]),
              ),
            ),
          ),
          Container(
            width: isSmall ? 10 : 12,
            height: isSmall ? 10 : 12,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AsmaTheme.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AsmaTheme.gold.withOpacity(0.5), blurRadius: 8),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AsmaTheme.gold,
                  AsmaTheme.gold.withOpacity(0.5),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}