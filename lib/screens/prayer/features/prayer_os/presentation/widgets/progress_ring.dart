import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 â†’ 1.0
  final String label;
  final Color color;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12),
        ),
      ],
    );
  }
}