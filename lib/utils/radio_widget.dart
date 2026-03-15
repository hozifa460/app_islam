import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/radio_services.dart';

class RadioMiniPlayer extends StatelessWidget {
  final Color gold;
  const RadioMiniPlayer({super.key, required this.gold});

  @override
  Widget build(BuildContext context) {
    // ✅ كشف الوضع الحالي
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ ألوان ديناميكية
    final bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor = gold.withOpacity(isDark ? 0.3 : 0.6); // حدود أوضح في الوضع الفاتح

    return StreamBuilder<bool>(
      stream: RadioService.player.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            leading: isPlaying
                ? const Icon(Icons.stop_circle, color: Colors.red, size: 32)
                : Icon(Icons.play_circle_fill, color: gold, size: 32),
            title: Text(
              'إذاعة القرآن الكريم',
              style: GoogleFonts.cairo(
                color: textColor, // نص ديناميكي
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isPlaying ? 'جاري البث المباشر...' : 'اضغط للاستماع',
              style: GoogleFonts.cairo(
                color: subTextColor, // نص ثانوي ديناميكي
                fontSize: 12,
              ),
            ),
            onTap: () => RadioService.toggleRadio(),
          ),
        );
      },
    );
  }
}