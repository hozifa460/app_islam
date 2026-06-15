import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranLoadingView extends StatelessWidget {
  final Color primary;
  final Color bgColor;
  final String message;
  final double progress;

  const QuranLoadingView({
    Key? key,
    required this.primary,
    required this.bgColor,
    required this.message,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        value: progress > 0 && progress < 1 ? progress : null,
                        strokeWidth: 4,
                        color: primary,
                        backgroundColor: primary.withValues(alpha: 0.15),
                      ),
                    ),
                    Icon(Icons.menu_book_rounded, color: primary, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress > 0 && progress <= 1 ? progress : null,
                  minHeight: 7,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).clamp(0, 100).toInt()}%',
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}