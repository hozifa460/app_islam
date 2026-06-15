import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class GlobalSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final Color primaryColor;

  List<dynamic> _quranAyahs = [];
  List<Map<String, dynamic>> _hadithDatabase = [];

  bool _isDataLoaded = false;
  bool _isError = false;
  String _statusMsg = 'ط¬ط§ط±ظٹ طھط­ط¶ظٹط± ط§ظ„ظ…ظƒطھط¨ط©...';

  // ظ‚ط§ط¦ظ…ط© ط§ظ„ظƒطھط¨ ط§ظ„طھظٹ ط³ظٹطھظ… ط§ظ„ط¨ط­ط« ظپظٹ ظ…ظ„ظپط§طھظ‡ط§ ط§ظ„ظ…ط­ظ„ظٹط©
  final List<String> _bookIds = [
    'bukhari', 'muslim', 'tirmidhi', 'abudawud',
    'nasai', 'ibnmajah', 'riyadussalihin', 'forty'
  ];

  GlobalSearchDelegate({required this.primaryColor}) {
    _loadAllOfflineData();
  }

  @override
  String get searchFieldLabel => 'ط§ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ† ظˆط§ظ„ط³ظ†ط©...';

  String _normalize(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[ط£ط¥ط¢ط§ظ±ظ°]'), 'ط§')
        .replaceAll(RegExp(r'[ظٹظ‰ط¦]'), 'ظٹ')
        .replaceAll(RegExp(r'[ط©ظ‡]'), 'ظ‡')
        .replaceAll('ط¤', 'ظˆ')
        .replaceAll(RegExp(r'<[^>]*>'), '') // ط¥ط²ط§ظ„ط© HTML
        .trim();
  }
  // âœ… ط¬ظ„ط¨ ط§ظ„ط¨ظٹط§ظ†ط§طھ ظ…ظ† ط§ظ„ظ…ظ„ظپط§طھ ط§ظ„ظ…ط­ظ„ظٹط© (ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ) ظˆطھطµط­ظٹط­ ط£ط³ظ…ط§ط، ط§ظ„ظƒطھط¨
  Future<void> _loadAllOfflineData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // 1. ظ‚ط±ط§ط،ط© ط§ظ„ظ…طµط­ظپ (ظ…ط­ظ…ظٹ ط¨ظ€ try-catch ط¯ط§ط®ظ„ظٹ)
      try {
        final quranFile = File('${dir.path}/quran_uthmani_v1.json');
        if (await quranFile.exists()) {
          final data = json.decode(await quranFile.readAsString());
          for (var surah in data['data']['surahs']) {
            for (var ayah in surah['ayahs']) {
              _quranAyahs.add({
                'type': 'quran',
                'text': ayah['text'],
                'searchableText': _normalize(ayah['text']),
                'surahName': surah['name'].toString().replaceAll('ط³ظˆط±ط© ', ''),
                'surahNumber': surah['number'],
                'numberInSurah': ayah['numberInSurah'],
                'page': ayah['page'],
              });
            }
          }
        } else {
          // ط¥ط°ط§ ظ„ظ… ظٹط¬ط¯ ط§ظ„ظ‚ط±ط¢ظ† ظ…ط­ظ„ظٹط§ظ‹طŒ ظٹط­ط§ظˆظ„ ط¬ظ„ط¨ظ‡ ظ…ظ† ط§ظ„ط¥ظ†طھط±ظ†طھ ظ„ظ„ط¨ط­ط«
          final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani')).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            await quranFile.writeAsString(response.body);
            final data = json.decode(response.body);
            for (var surah in data['data']['surahs']) {
              for (var ayah in surah['ayahs']) {
                _quranAyahs.add({
                  'type': 'quran',
                  'text': ayah['text'],
                  'searchableText': _normalize(ayah['text']),
                  'surahName': surah['name'].toString().replaceAll('ط³ظˆط±ط© ', ''),
                  'surahNumber': surah['number'],
                  'numberInSurah': ayah['numberInSurah'],
                  'page': ayah['page'],
                });
              }
            }
          }
        }
      } catch (e) {
        print("Quran Error: $e");
      }

      // 2. ظ‚ط±ط§ط،ط© ظƒطھط¨ ط§ظ„ط£ط­ط§ط¯ظٹط« ط§ظ„ظ…طھظˆظپط±ط© ظپظ‚ط· ظˆطھط¹ظٹظٹظ† ط§ظ„ط§ط³ظ… ط§ظ„طµط­ظٹط­
      for (String bookId in _bookIds) {
        try {
          final hadithFile = File('${dir.path}/hadith_${bookId}_v1.json');
          if (await hadithFile.exists()) {
            final data = json.decode(await hadithFile.readAsString());

            List<dynamic> rawList = [];
            if (data is Map && data.containsKey('hadiths')) {
              rawList = data['hadiths'];
            } else if (data is List) {
              rawList = data;
            }

            for (var h in rawList) {
              String rawText = h['text'] ?? h['body'] ?? h['hadithArabic'] ?? '';
              String cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              if (cleanText.length > 5) {
                _hadithDatabase.add({
                  'type': 'hadith',
                  'text': cleanText,
                  'searchableText': _normalize(cleanText),
                  'number': h['hadithnumber'],
                  'bookId': bookId,
                  'book': _getBookName(bookId), // âœ… ظ‡ظ†ط§ ط­ظ„ ط§ظ„ظ…ط´ظƒظ„ط©: طھط¹ظٹظٹظ† ط§ط³ظ… ط§ظ„ظƒطھط§ط¨
                  'grade': (h['grades'] as List?)?.isNotEmpty == true ? h['grades'][0]['grade'] : '',
                });
              }
            }
          }
        } catch (e) {
          print("Hadith Error for $bookId: $e");
        }
      }

      // ط¥ط¶ط§ظپط© ط§ظ„ط£ط±ط¨ط¹ظٹظ† ط§ظ„ظ†ظˆظˆظٹط© ظ…ظ† ط§ظ„ط°ط§ظƒط±ط© ظ„ط¶ظ…ط§ظ† ظˆط¬ظˆط¯ ظ†طھط§ط¦ط¬ ط¯ط§ط¦ظ…ط§ظ‹
      _hadithDatabase.addAll(_localFortyNawawi);

      // طھط­ط¯ظٹط« ط­ط§ظ„ط© ط§ظ„ظˆط§ط¬ظ‡ط©
      _isDataLoaded = true;
      if (query.isNotEmpty) {
        showResults(null!);
      }

    } catch (e) {
      _isError = true;
      _statusMsg = 'ط­ط¯ط« ط®ط·ط£ ط؛ظٹط± ظ…طھظˆظ‚ط¹.';
    }
  }
  String _getBookName(String id) {
    switch(id) {
      case 'bukhari': return 'طµط­ظٹط­ ط§ظ„ط¨ط®ط§ط±ظٹ';
      case 'muslim': return 'طµط­ظٹط­ ظ…ط³ظ„ظ…';
      case 'tirmidhi': return 'ط³ظ†ظ† ط§ظ„طھط±ظ…ط°ظٹ';
      case 'abudawud': return 'ط³ظ†ظ† ط£ط¨ظٹ ط¯ط§ظˆط¯';
      case 'nasai': return 'ط³ظ†ظ† ط§ظ„ظ†ط³ط§ط¦ظٹ';
      case 'ibnmajah': return 'ط³ظ†ظ† ط§ط¨ظ† ظ…ط§ط¬ظ‡';
      case 'riyadussalihin': return 'ط±ظٹط§ط¶ ط§ظ„طµط§ظ„ط­ظٹظ†';
      case 'forty': return 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©';
      default: return 'ظƒطھط§ط¨ ط­ط¯ظٹط«';
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) => [if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () { query = ''; showSuggestions(context); })];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    if (_isError) return Center(child: Text('ط¹ط°ط±ط§ظ‹طŒ ط­ط¯ط« ط®ط·ط£ ظپظٹ ط§ظ„طھط­ظ…ظٹظ„', style: GoogleFonts.cairo(color: Colors.red)));

    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('ط§ظƒطھط¨ ط£ظٹ ظƒظ„ظ…ط© ظ„ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ† ظˆط§ظ„ط³ظ†ط©', style: GoogleFonts.cairo(color: Colors.grey)),
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
            Text('ط¬ط§ط±ظٹ طھط¬ظ‡ظٹط² ط§ظ„ظ…ظƒطھط¨ط© ظ„ظ„ط¨ط­ط«...', style: GoogleFonts.cairo(color: Colors.grey)),
          ],
        ),
      );
    }

    // ==========================================
    // ط¹ظ…ظ„ظٹط© ط§ظ„ط¨ط­ط« ط§ظ„ط³ط±ظٹط¹ط©
    // ==========================================
    final normalizedQuery = _normalize(query);

    // ظپظ„طھط±ط© (ط­ط¯ ط£ظ‚طµظ‰ 50 ظ†طھظٹط¬ط© ظ„ظ„ط³ط±ط¹ط© ظˆظ…ظ†ط¹ ط§ظ„طھط¹ظ„ظٹظ‚)
    var quranResults = _quranAyahs.where((a) => a['searchableText'].contains(normalizedQuery)).take(50).toList();
    var hadithResults = _hadithDatabase.where((h) {
      final hText = h['searchableText'] ?? '';
      return hText.contains(normalizedQuery);
    }).take(50).toList();

    if (quranResults.isEmpty && hadithResults.isEmpty) {
      return Center(child: Text('ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬ ظ…ط·ط§ط¨ظ‚ط©', style: GoogleFonts.cairo(color: Colors.grey)));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ًں“– ط¹ط±ط¶ ظ†طھط§ط¦ط¬ ط§ظ„ظ‚ط±ط¢ظ†
          if (quranResults.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.all(8), child: Text('ًں“– ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ… (${quranResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor))),
            ...quranResults.map((q) => _buildQuranCard(q, context)).toList(),
          ],

          // ًں“ڑ ط¹ط±ط¶ ظ†طھط§ط¦ط¬ ط§ظ„ط£ط­ط§ط¯ظٹط«
          if (hadithResults.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.all(8), child: Text('ًں“ڑ ط§ظ„ط£ط­ط§ط¯ظٹط« (${hadithResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown))),
            ...hadithResults.map((h) => _buildHadithCard(h, context)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuranCard(Map<String, dynamic> quran, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text('${quran['text']} ï´؟${quran['numberInSurah']}ï´¾', style: GoogleFonts.amiri(fontSize: 20, height: 1.8), textAlign: TextAlign.justify),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text('ط³ظˆط±ط© ${quran['surahName']}', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor))),
              const Spacer(),
              Text('طµظپط­ط©: ${quran['page']}', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        onTap: () {
          quran['keyword'] = query; // ظ„طھظ„ظˆظٹظ† ط§ظ„ط¨ط­ط« ظ„ط§ط­ظ‚ط§ظ‹
          close(context, quran);
        },
      ),
    );
  }

  Widget _buildHadithCard(Map<String, dynamic> hadith, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(hadith['text'], style: GoogleFonts.amiri(fontSize: 18, height: 1.8), maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.justify),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('ًں“ڑ ${hadith['book']} #${hadith['number']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown))),
              const Spacer(),
              if (hadith['grade'].toString().isNotEmpty) Text('ط§ظ„ط¯ط±ط¬ط©: ${hadith['grade']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.green)),
            ],
          ),
        ),
        onTap: () {
          hadith['keyword'] = query; // ظ„طھظ„ظˆظٹظ† ط§ظ„ط¨ط­ط« ظ„ط§ط­ظ‚ط§ظ‹
          close(context, hadith);
        },
      ),
    );
  }

  // ظ‚ط§ط¹ط¯ط© ط¨ظٹط§ظ†ط§طھ ط£ظˆظپظ„ط§ظٹظ† ظ„ظ„ط£ط±ط¨ط¹ظٹظ† ط§ظ„ظ†ظˆظˆظٹط© (ط¶ظ…ط§ظ†ط© ط¹ظ…ظ„ ط§ظ„ط¨ط­ط« ط¯ط§ط¦ظ…ط§ظ‹)
  final List<Map<String, dynamic>> _localFortyNawawi = [
    {'type': 'hadith', 'number': 1, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¥ظ†ظ…ط§ ط§ظ„ط£ط¹ظ…ط§ظ„ ط¨ط§ظ„ظ†ظٹط§طھطŒ ظˆط¥ظ†ظ…ط§ ظ„ظƒظ„ ط§ظ…ط±ط¦ ظ…ط§ ظ†ظˆظ‰...', 'searchableText': 'ط§ظ†ظ…ط§ ط§ظ„ط§ط¹ظ…ط§ظ„ ط¨ط§ظ„ظ†ظٹط§طھ ظˆط§ظ†ظ…ط§ ظ„ظƒظ„ ط§ظ…ط±ط¦ ظ…ط§ ظ†ظˆظٹ'},
    {'type': 'hadith', 'number': 2, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¨ظٹظ†ظ…ط§ ظ†ط­ظ† ط¬ظ„ظˆط³ ط¹ظ†ط¯ ط±ط³ظˆظ„ ط§ظ„ظ„ظ‡ طµظ„ظ‰ ط§ظ„ظ„ظ‡ ط¹ظ„ظٹظ‡ ظˆط³ظ„ظ…...', 'searchableText': 'ط¨ظٹظ†ظ…ط§ ظ†ط­ظ† ط¬ظ„ظˆط³ ط¹ظ†ط¯ ط±ط³ظˆظ„ ط§ظ„ظ„ظ‡ طµظ„ظٹ ط§ظ„ظ„ظ‡ ط¹ظ„ظٹظ‡ ظˆط³ظ„ظ…'},
    {'type': 'hadith', 'number': 3, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¨ظ†ظٹ ط§ظ„ط¥ط³ظ„ط§ظ… ط¹ظ„ظ‰ ط®ظ…ط³: ط´ظ‡ط§ط¯ط© ط£ظ† ظ„ط§ ط¥ظ„ظ‡ ط¥ظ„ط§ ط§ظ„ظ„ظ‡...', 'searchableText': 'ط¨ظ†ظٹ ط§ظ„ط§ط³ظ„ط§ظ… ط¹ظ„ظٹ ط®ظ…ط³ ط´ظ‡ط§ط¯ظ‡ ط§ظ† ظ„ط§ ط§ظ„ظ‡ ط§ظ„ط§ ط§ظ„ظ„ظ‡'},
    {'type': 'hadith', 'number': 7, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط§ظ„ط¯ظٹظ† ط§ظ„ظ†طµظٹط­ط©. ظ‚ظ„ظ†ط§: ظ„ظ…ظ†طں ظ‚ط§ظ„: ظ„ظ„ظ‡طŒ ظˆظ„ظƒطھط§ط¨ظ‡طŒ ظˆظ„ط±ط³ظˆظ„ظ‡...', 'searchableText': 'ط§ظ„ط¯ظٹظ† ط§ظ„ظ†طµظٹط­ظ‡ ظ‚ظ„ظ†ط§ ظ„ظ…ظ† ظ‚ط§ظ„ ظ„ظ„ظ‡ ظˆظ„ظƒطھط§ط¨ظ‡ ظˆظ„ط±ط³ظˆظ„ظ‡'},
  ];
}