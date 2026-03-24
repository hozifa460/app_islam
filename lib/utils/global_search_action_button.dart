import 'package:flutter/material.dart';
import 'package:islamic_app/screens/hadith/hadith_book_screen.dart';
import 'package:islamic_app/screens/quran/surah_deatil.dart';
import 'package:islamic_app/screens/search/global_search_delegate_screen.dart';

class GlobalSearchActionButton extends StatelessWidget {
  final Color primaryColor;
  final Color? iconColor;

  const GlobalSearchActionButton({
    super.key,
    required this.primaryColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black87;

    return IconButton(
      icon: Icon(Icons.search, color: effectiveIconColor),
      onPressed: () {
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
                  initialHadithNumber: result['number'],
                ),
              ),
            );
          }
        });
      },
      tooltip: 'البحث',
    );
  }
}