import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderTopBarWidget extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final double topPadding;
  final String surahName;
  final int currentPage;
  final int hizbQuarter;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;

  const ReaderTopBarWidget({
    super.key,
    required this.primary,
    required this.isDark,
    required this.topPadding,
    required this.surahName,
    required this.currentPage,
    required this.hizbQuarter,
    required this.onMenuTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? Colors.white : Colors.black87;
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;
    return ColoredBox(
      color: isDark ? const Color(0xF2111111) : const Color(0xF9FEFDFB),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, left: 4, right: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenuTap,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.menu_rounded, color: ink, size: 21),
            ),
            Flexible(
              child: Text(
                surahName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 16,
                  color: ink,
                ),
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'جزء ${_arabicNumber(juz)}   ◔   حزب ${_arabicNumber(hizb)}',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(fontSize: 12, color: ink),
              ),
            ),
            IconButton(
              onPressed: onSearchTap,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.search_rounded, color: ink, size: 21),
            ),
          ],
        ),
      ),
    );
  }

  String _arabicNumber(int value) {
    const digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return value.toString().split('').map((digit) => digits[digit]).join();
  }
}
