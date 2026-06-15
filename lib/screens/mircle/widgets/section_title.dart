import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color_control/miracle_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color  accentColor;
  final MiracleThemeColors t;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width:  4,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end:   Alignment.bottomCenter,
              colors: [accentColor, accentColor.withValues(alpha: 0.3)],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              color:      Colors.white,
              fontSize:   17,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 8),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              color:       accentColor.withValues(alpha: 0.7),
              fontSize:    10,
              fontWeight:  FontWeight.w400,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}