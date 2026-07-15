import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// âœ… ظƒظ„ط§ط³ ط§ظ„ط¨ط­ط« ط§ظ„ظ…ط³طھظ‚ظ„ طھظ…ط§ظ…ط§ظ‹ (ظٹط¹طھظ…ط¯ ط¹ظ„ظ‰ ظ†ظپط³ظ‡ ظ„ط¬ظ„ط¨ ط§ظ„ط¨ظٹط§ظ†ط§طھ)
class QuranSearch extends SearchDelegate<Map<String, dynamic>?> {
  final Color primaryColor;

  // ظ„ط§ ظ†ط­طھط§ط¬ ظ„ط§ط³طھظ‚ط¨ط§ظ„ quranDataطŒ ط³ظ†ظ‚ط±ط¤ظ‡ط§ ظ…ظ† ط§ظ„ط°ط§ظƒط±ط©
  List<dynamic> _allAyahs = [];
  bool _isDataLoaded = false;
  bool _isError = false;

  QuranSearch({required this.primaryColor}) {
    _loadQuranData(); // ط¨ظ…ط¬ط±ط¯ ظپطھط­ ط§ظ„ط¨ط­ط«طŒ ظ†ط¬ظ‡ط² ط§ظ„ط¨ظٹط§ظ†ط§طھ
  }

  @override
  String get searchFieldLabel => 'ابحث عن آية أو كلمة...';

  // ط¯ط§ظ„ط© ط°ظƒظٹط© ظ„ط¥ط²ط§ظ„ط© ط§ظ„طھط´ظƒظٹظ„ ظˆظƒظ„ ط§ظ„ط±ظ…ظˆط² ظ„ظ„ط¨ط­ط« ط§ظ„ط³ظ„ط³
  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا')
        .replaceAll(RegExp(r'[يىئ]'), 'ي')
        .replaceAll(RegExp(r'[ةه]'), 'ظ‡')
        .replaceAll('ؤ', 'ظˆ')
        .trim();
  }

  // âœ… ط§ظ„ط¯ط§ظ„ط© ط§ظ„ظ…ط³ط¤ظˆظ„ط© ط¹ظ† طھظˆظپظٹط± ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ‚ط±ط¢ظ†
  Future<void> _loadQuranData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      String jsonString;

      if (await file.exists()) {
        // ط¥ط°ط§ ظƒط§ظ† ط§ظ„ظ…ظ„ظپ ظ…ظˆط¬ظˆط¯ط§ظ‹ ظپظٹ ط§ظ„ط¬ظ‡ط§ط² (طھظ… طھط­ظ…ظٹظ„ظ‡ ط³ط§ط¨ظ‚ط§ظ‹)
        jsonString = await file.readAsString();
      } else {
        // ط¥ط°ط§ ظ„ظ… ظٹظپطھط­ ط§ظ„ظ…ط³طھط®ط¯ظ… ط§ظ„ظ…طµط­ظپ ط£ط¨ط¯ط§ظ‹طŒ ظ†ط­ظ…ظ„ظ‡ ط§ظ„ط¢ظ† ظ„ظ„ط¨ط­ط«
        final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'));
        if (response.statusCode == 200) {
          jsonString = response.body;
          await file.writeAsString(jsonString); // ظ†ط­ظپط¸ظ‡ ظ„ظ„ظ…ط±ط§طھ ط§ظ„ظ‚ط§ط¯ظ…ط©
        } else {
          _isError = true;
          return;
        }
      }

      final data = json.decode(jsonString);
      List<dynamic> tempList = [];

      // طھط¨ط³ظٹط· ط§ظ„ط¨ظٹط§ظ†ط§طھ ظ„طھظƒظˆظ† ظ‚ط§ط¦ظ…ط© ط¢ظٹط§طھ ط³ظ‡ظ„ط© ط§ظ„ط¨ط­ط«
      for (var surah in data['data']['surahs']) {
        for (var ayah in surah['ayahs']) {
          ayah['surahName'] = surah['name'];
          ayah['surahNumber'] = surah['number'];
          tempList.add(ayah);
        }
      }

      _allAyahs = tempList;
      _isDataLoaded = true;

      // ظ„طھط­ط¯ظٹط« ظˆط§ط¬ظ‡ط© ط§ظ„ط¨ط­ط« ط¥ط°ط§ ظƒط§ظ† ط§ظ„ظ…ط³طھط®ط¯ظ… ظ‚ط¯ ظƒطھط¨ ط´ظٹط¦ط§ظ‹ ط£ط«ظ†ط§ط، ط§ظ„طھط­ظ…ظٹظ„
      if (query.isNotEmpty) {
        showResults(null!); // ط®ط¯ط¹ط© ظ„ط¥ط¹ط§ط¯ط© ط¨ظ†ط§ط، ط§ظ„ظ†طھط§ط¦ط¬
      }

    } catch (e) {
      _isError = true;
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody();

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody();

  Widget _buildBody() {
    if (_isError) {
      return Center(child: Text('حدث خطأ في تحميل بيانات المصحف', style: GoogleFonts.cairo()));
    }

    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('اكتب أي كلمة للبحث في المصحف', style: GoogleFonts.cairo(color: Colors.grey)),
          ],
        ),
      );
    }

    if (!_isDataLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 10),
            Text('جاري تجهيز المصحف للبحث...', style: GoogleFonts.cairo(color: Colors.grey)),
          ],
        ),
      );
    }

    final normalizedQuery = _normalize(query);
    List<Map<String, dynamic>> results = [];

    // âœ… ط¹ظ…ظ„ظٹط© ط§ظ„ط¨ط­ط«
    for (var ayah in _allAyahs) {
      String originalText = ayah['text'];
      String cleanText = _normalize(originalText);

      // ط¨ط­ط« ظٹط­طھظˆظٹ ط¹ظ„ظ‰ ط§ظ„ظƒظ„ظ…ط©
      if (cleanText.contains(normalizedQuery)) {
        results.add({
          'page': ayah['page'],
          'number': ayah['number'],
          'numberInSurah': ayah['numberInSurah'],
          'text': originalText,
          'surahName': ayah['surahName'],
          'surahNumber': ayah['surahNumber'],
        });
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج مطابقة', style: GoogleFonts.cairo(color: Colors.grey)),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final res = results[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                res['text'],
                style: GoogleFonts.amiri(fontSize: 20, height: 1.8),
                textAlign: TextAlign.justify,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '${res['surahName']}',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الآية: ${res['numberInSurah']} | صفحة: ${res['page']}',
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // ط¥ط±ط¬ط§ط¹ ط§ظ„ظ†طھظٹط¬ط© ظ„ظ„طµظپط­ط© ط§ظ„طھظٹ ظپطھط­طھ ط§ظ„ط¨ط­ط«
                close(context, res);
              },
            ),
          );
        },
      ),
    );
  }
}