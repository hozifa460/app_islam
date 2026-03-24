import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/hadith/hadith_book_screen.dart';
import 'package:islamic_app/screens/quran/surah_deatil.dart';
import 'package:islamic_app/screens/search/global_search_delegate_screen.dart';

class GlobalSearchBarCard extends StatelessWidget {
  final Color primaryColor;
  final String hintText;

  const GlobalSearchBarCard({
    super.key,
    required this.primaryColor,
    this.hintText = 'ابحث في القرآن والسنة...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        showSearch(
          context: context,
          delegate: GlobalSearchDelegate(
            primaryColor: primaryColor,
          ),
        ).then((result) {
          if (result == null) return;

          if (result['type'] == 'quran') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahName: result['surahName'],
                  surahNumber: result['surahNumber'],
                  initialPage: result['page'],
                  searchQuery: result['text'],
                ),
              ),
            );
          } else if (result['type'] == 'hadith') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HadithBookScreen(
                  bookId: result['bookId'] ?? 'riyad',
                  bookTitle: result['bookName'] ?? 'رياض الصالحين',
                  primaryColor: primaryColor,
                ),
              ),
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.14 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hintText,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}