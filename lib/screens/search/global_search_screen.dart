import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_app/screens/quran/surah_detail/surah_deatil.dart';
import 'package:path_provider/path_provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  final Color primaryColor;
  const GlobalSearchScreen({super.key, required this.primaryColor});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ظ‚ظˆط§ط¹ط¯ ط§ظ„ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ…ط¯ظ…ط¬ط©
  List<Map<String, dynamic>> _quranDatabase = [];
  List<Map<String, dynamic>> _hadithDatabase = [];

  // ظ†طھط§ط¦ط¬ ط§ظ„ط¨ط­ط«
  List<Map<String, dynamic>> _quranResults = [];
  List<Map<String, dynamic>> _hadithResults = [];

  bool _isInitializing = true;
  String _statusMessage = 'ط¬ط§ط±ظٹ طھط­ط¶ظٹط± ط§ظ„ظ…ظƒطھط¨ط© ط§ظ„ط´ط§ظ…ظ„ط©...';

  @override
  void initState() {
    super.initState();
    _initializeDatabases();
  }

  // âœ… ط¯ط§ظ„ط© ظ„ط¥ط²ط§ظ„ط© ط§ظ„طھط´ظƒظٹظ„ ظˆطھظˆط­ظٹط¯ ط§ظ„ط­ط±ظˆظپ ظ„ظ„ط¨ط­ط« ط§ظ„ط¯ظ‚ظٹظ‚
  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[ط£ط¥ط¢ط§ظ±ظ°]'), 'ط§')
        .replaceAll(RegExp(r'[ظٹظ‰ط¦]'), 'ظٹ')
        .replaceAll(RegExp(r'[ط©ظ‡]'), 'ظ‡')
        .replaceAll('ط¤', 'ظˆ')
        .toLowerCase()
        .trim();
  }

  // âœ… طھط­ظ…ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ† ظˆط§ظ„ط£ط­ط§ط¯ظٹط«
  Future<void> _initializeDatabases() async {
    // 1. طھط­ظ…ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ† ظ…ظ† ط§ظ„ظ…ظ„ظپ ط§ظ„ظ…ط­ظ„ظٹ
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);

        List<Map<String, dynamic>> tempQuran = [];
        for (var surah in data['data']['surahs']) {
          for (var ayah in surah['ayahs']) {
            tempQuran.add({
              'type': 'quran',
              'text': ayah['text'],
              'surahName': surah['name'].toString().replaceAll('ط³ظˆط±ط© ', ''),
              'surahNumber': surah['number'],
              'numberInSurah': ayah['numberInSurah'],
              'number': ayah['number'], // ط§ظ„ط±ظ‚ظ… ط§ظ„ط¹ط§ظ„ظ…ظٹ
              'page': ayah['page'],
            });
          }
        }
        _quranDatabase = tempQuran;
      }
    } catch (e) {
      print("Error loading Quran for search: $e");
    }

    // 2. طھط­ظ…ظٹظ„ ط§ظ„ط£ط­ط§ط¯ظٹط« ط§ظ„ظ…ط­ظ„ظٹط© (ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط© ظƒط¹ظٹظ†ط© ط³ط±ظٹط¹ط© + ظ…ط­ط§ظˆظ„ط© ط¬ظ„ط¨ ط±ظٹط§ط¶ ط§ظ„طµط§ظ„ط­ظٹظ†)
    _hadithDatabase.addAll(_localFortyNawawi);

    try {
      final response = await http.get(Uri.parse('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-riyadussalihin.json'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        for (var h in data['hadiths']) {
          _hadithDatabase.add({
            'type': 'hadith',
            'text': h['text'] ?? '',
            'number': h['hadithnumber'],
            'book': 'ط±ظٹط§ط¶ ط§ظ„طµط§ظ„ط­ظٹظ†',
            'grade': (h['grades'] as List?)?.isNotEmpty == true ? h['grades'][0]['grade'] : '',
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _statusMessage = 'ط¬ط§ظ‡ط² ظ„ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ† ظˆط§ظ„ط³ظ†ط©';
      });
    }
  }

  // âœ… طھظ†ظپظٹط° ط§ظ„ط¨ط­ط« ط§ظ„ظپظˆط±ظٹ
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _quranResults = [];
        _hadithResults = [];
      });
      return;
    }

    final cleanQuery = _normalize(query);

    setState(() {
      // ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ†
      _quranResults = _quranDatabase.where((item) {
        return _normalize(item['text']).contains(cleanQuery);
      }).toList();

      // ط¨ط­ط« ظپظٹ ط§ظ„ط£ط­ط§ط¯ظٹط«
      _hadithResults = _hadithDatabase.where((item) {
        return _normalize(item['text']).contains(cleanQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasResults = _quranResults.isNotEmpty || _hadithResults.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('ط§ظ„ط¨ط­ط« ط§ظ„ط´ط§ظ…ظ„', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // ================== ط´ط±ظٹط· ط§ظ„ط¨ط­ط« ==================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: _isInitializing ? 'ط¬ط§ط±ظٹ ط§ظ„طھط­ط¶ظٹط±...' : 'ط§ط¨ط­ط« ط¹ظ† ط¢ظٹط© ط£ظˆ ط­ط¯ظٹط«...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  prefixIcon: _isInitializing
                      ? Padding(padding: const EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search, color: Colors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),

            // ================== ط§ظ„ظ†طھط§ط¦ط¬ ==================
            Expanded(
              child: _isInitializing
                  ? Center(child: Text(_statusMessage, style: GoogleFonts.cairo(color: Colors.grey)))
                  : _searchController.text.isNotEmpty && !hasResults
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬', style: GoogleFonts.cairo(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // ًں“– ظ†طھط§ط¦ط¬ ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…
                  if (_quranResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('ًں“– ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ… (${_quranResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: widget.primaryColor)),
                    ),
                    ..._quranResults.map((q) => _buildQuranCard(q)).toList(),
                  ],

                  // ًں“ڑ ظ†طھط§ط¦ط¬ ط§ظ„ط£ط­ط§ط¯ظٹط«
                  if (_hadithResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text('ًں“ڑ ط§ظ„ط£ط­ط§ط¯ظٹط« (${_hadithResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
                    ),
                    ..._hadithResults.map((h) => _buildHadithCard(h)).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // âœ… ط¨ط·ط§ظ‚ط© ط¹ط±ط¶ ظ†طھظٹط¬ط© ط§ظ„ظ‚ط±ط¢ظ†
  Widget _buildQuranCard(Map<String, dynamic> quran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // ًںڑ€ ط§ظ„ط§ظ†طھظ‚ط§ظ„ ظ„طµظپط­ط© ط§ظ„ظ…طµط­ظپ
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surahName: quran['surahName'],
                surahNumber: quran['surahNumber'],
                initialPage: quran['page'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${quran['text']} ï´؟${quran['numberInSurah']}ï´¾',
                style: GoogleFonts.amiri(fontSize: 20, height: 1.8),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: widget.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('ط³ظˆط±ط© ${quran['surahName']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: widget.primaryColor)),
                  ),
                  const Spacer(),
                  Text('طµظپط­ط©: ${quran['page']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_back_ios_new, size: 12, color: widget.primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // âœ… ط¨ط·ط§ظ‚ط© ط¹ط±ط¶ ظ†طھظٹط¬ط© ط§ظ„ط­ط¯ظٹط«
  Widget _buildHadithCard(Map<String, dynamic> hadith) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hadith['text'],
              style: GoogleFonts.amiri(fontSize: 18, height: 1.8, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('ًں“ڑ ${hadith['book']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
                ),
                const Spacer(),
                if (hadith['grade'].toString().isNotEmpty)
                  Text('ط§ظ„ط¯ط±ط¬ط©: ${hadith['grade']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ط¨ظٹط§ظ†ط§طھ ط§ظ„ط£ط±ط¨ط¹ظٹظ† ط§ظ„ظ†ظˆظˆظٹط© (ط£ظˆظپظ„ط§ظٹظ†)
  final List<Map<String, dynamic>> _localFortyNawawi = [
    {'type': 'hadith', 'number': 1, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¥ظ†ظ…ط§ ط§ظ„ط£ط¹ظ…ط§ظ„ ط¨ط§ظ„ظ†ظٹط§طھطŒ ظˆط¥ظ†ظ…ط§ ظ„ظƒظ„ ط§ظ…ط±ط¦ ظ…ط§ ظ†ظˆظ‰...'},
    {'type': 'hadith', 'number': 2, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¨ظٹظ†ظ…ط§ ظ†ط­ظ† ط¬ظ„ظˆط³ ط¹ظ†ط¯ ط±ط³ظˆظ„ ط§ظ„ظ„ظ‡ طµظ„ظ‰ ط§ظ„ظ„ظ‡ ط¹ظ„ظٹظ‡ ظˆط³ظ„ظ… ط°ط§طھ ظٹظˆظ…طŒ ط¥ط° ط·ظ„ط¹ ط¹ظ„ظٹظ†ط§ ط±ط¬ظ„ ط´ط¯ظٹط¯ ط¨ظٹط§ط¶ ط§ظ„ط«ظٹط§ط¨...'},
    {'type': 'hadith', 'number': 3, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¨ظ†ظٹ ط§ظ„ط¥ط³ظ„ط§ظ… ط¹ظ„ظ‰ ط®ظ…ط³: ط´ظ‡ط§ط¯ط© ط£ظ† ظ„ط§ ط¥ظ„ظ‡ ط¥ظ„ط§ ط§ظ„ظ„ظ‡...'},
    {'type': 'hadith', 'number': 7, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط§ظ„ط¯ظٹظ† ط§ظ„ظ†طµظٹط­ط©. ظ‚ظ„ظ†ط§: ظ„ظ…ظ†طں ظ‚ط§ظ„: ظ„ظ„ظ‡طŒ ظˆظ„ظƒطھط§ط¨ظ‡طŒ ظˆظ„ط±ط³ظˆظ„ظ‡...'},
    {'type': 'hadith', 'number': 16, 'book': 'ط§ظ„ط£ط±ط¨ط¹ظˆظ† ط§ظ„ظ†ظˆظˆظٹط©', 'text': 'ط¹ظ† ط£ط¨ظٹ ظ‡ط±ظٹط±ط© ط±ط¶ظٹ ط§ظ„ظ„ظ‡ ط¹ظ†ظ‡طŒ ط£ظ† ط±ط¬ظ„ط§ ظ‚ط§ظ„ ظ„ظ„ظ†ط¨ظٹ طµظ„ظ‰ ط§ظ„ظ„ظ‡ ط¹ظ„ظٹظ‡ ظˆط³ظ„ظ…: ط£ظˆطµظ†ظٹطŒ ظ‚ط§ظ„: ظ„ط§ طھط؛ط¶ط¨. ظپط±ط¯ط¯ ظ…ط±ط§ط±ط§طŒ ظ‚ط§ظ„: ظ„ط§ طھط؛ط¶ط¨.'},
  ];
}