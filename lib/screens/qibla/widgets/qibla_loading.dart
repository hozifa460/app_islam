import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaLoading extends StatelessWidget {
  final bool isDark;
  const QiblaLoading({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: QiblaTheme.gold, strokeWidth: 3),
          const SizedBox(height: 16),
          Text('جارٍ تحديد موقعك...',
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}