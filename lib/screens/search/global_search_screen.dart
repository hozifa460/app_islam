import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_app/screens/quran/surah_deatil.dart';
import 'package:path_provider/path_provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  final Color primaryColor;
  const GlobalSearchScreen({super.key, required this.primaryColor});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // قواعد البيانات المدمجة
  List<Map<String, dynamic>> _quranDatabase = [];
  List<Map<String, dynamic>> _hadithDatabase = [];

  // نتائج البحث
  List<Map<String, dynamic>> _quranResults = [];
  List<Map<String, dynamic>> _hadithResults = [];

  bool _isInitializing = true;
  String _statusMessage = 'جاري تحضير المكتبة الشاملة...';

  @override
  void initState() {
    super.initState();
    _initializeDatabases();
  }

  // ✅ دالة لإزالة التشكيل وتوحيد الحروف للبحث الدقيق
  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا')
        .replaceAll(RegExp(r'[يىئ]'), 'ي')
        .replaceAll(RegExp(r'[ةه]'), 'ه')
        .replaceAll('ؤ', 'و')
        .toLowerCase()
        .trim();
  }

  // ✅ تحميل القرآن والأحاديث
  Future<void> _initializeDatabases() async {
    // 1. تحميل القرآن من الملف المحلي
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
              'surahName': surah['name'].toString().replaceAll('سورة ', ''),
              'surahNumber': surah['number'],
              'numberInSurah': ayah['numberInSurah'],
              'number': ayah['number'], // الرقم العالمي
              'page': ayah['page'],
            });
          }
        }
        _quranDatabase = tempQuran;
      }
    } catch (e) {
      print("Error loading Quran for search: $e");
    }

    // 2. تحميل الأحاديث المحلية (الأربعون النووية كعينة سريعة + محاولة جلب رياض الصالحين)
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
            'book': 'رياض الصالحين',
            'grade': (h['grades'] as List?)?.isNotEmpty == true ? h['grades'][0]['grade'] : '',
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _statusMessage = 'جاهز للبحث في القرآن والسنة';
      });
    }
  }

  // ✅ تنفيذ البحث الفوري
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
      // بحث في القرآن
      _quranResults = _quranDatabase.where((item) {
        return _normalize(item['text']).contains(cleanQuery);
      }).toList();

      // بحث في الأحاديث
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
          title: Text('البحث الشامل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // ================== شريط البحث ==================
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
                  hintText: _isInitializing ? 'جاري التحضير...' : 'ابحث عن آية أو حديث...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),

            // ================== النتائج ==================
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
                    Text('لا توجد نتائج', style: GoogleFonts.cairo(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // 📖 نتائج القرآن الكريم
                  if (_quranResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('📖 القرآن الكريم (${_quranResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: widget.primaryColor)),
                    ),
                    ..._quranResults.map((q) => _buildQuranCard(q)).toList(),
                  ],

                  // 📚 نتائج الأحاديث
                  if (_hadithResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text('📚 الأحاديث (${_hadithResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
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

  // ✅ بطاقة عرض نتيجة القرآن
  Widget _buildQuranCard(Map<String, dynamic> quran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 🚀 الانتقال لصفحة المصحف
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
                '${quran['text']} ﴿${quran['numberInSurah']}﴾',
                style: GoogleFonts.amiri(fontSize: 20, height: 1.8),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('سورة ${quran['surahName']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: widget.primaryColor)),
                  ),
                  const Spacer(),
                  Text('صفحة: ${quran['page']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
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

  // ✅ بطاقة عرض نتيجة الحديث
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
                  decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('📚 ${hadith['book']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
                ),
                const Spacer(),
                if (hadith['grade'].toString().isNotEmpty)
                  Text('الدرجة: ${hadith['grade']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بيانات الأربعين النووية (أوفلاين)
  final List<Map<String, dynamic>> _localFortyNawawi = [
    {'type': 'hadith', 'number': 1, 'book': 'الأربعون النووية', 'text': 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى...'},
    {'type': 'hadith', 'number': 2, 'book': 'الأربعون النووية', 'text': 'بينما نحن جلوس عند رسول الله صلى الله عليه وسلم ذات يوم، إذ طلع علينا رجل شديد بياض الثياب...'},
    {'type': 'hadith', 'number': 3, 'book': 'الأربعون النووية', 'text': 'بني الإسلام على خمس: شهادة أن لا إله إلا الله...'},
    {'type': 'hadith', 'number': 7, 'book': 'الأربعون النووية', 'text': 'الدين النصيحة. قلنا: لمن؟ قال: لله، ولكتابه، ولرسوله...'},
    {'type': 'hadith', 'number': 16, 'book': 'الأربعون النووية', 'text': 'عن أبي هريرة رضي الله عنه، أن رجلا قال للنبي صلى الله عليه وسلم: أوصني، قال: لا تغضب. فردد مرارا، قال: لا تغضب.'},
  ];
}