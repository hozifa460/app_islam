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
  String _statusMsg = 'جاري تحضير المكتبة...';

  // قائمة الكتب التي سيتم البحث في ملفاتها المحلية
  final List<String> _bookIds = [
    'bukhari', 'muslim', 'tirmidhi', 'abudawud',
    'nasai', 'ibnmajah', 'riyadussalihin', 'forty'
  ];

  GlobalSearchDelegate({required this.primaryColor}) {
    _loadAllOfflineData();
  }

  @override
  String get searchFieldLabel => 'ابحث في القرآن والسنة...';

  String _normalize(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا')
        .replaceAll(RegExp(r'[يىئ]'), 'ي')
        .replaceAll(RegExp(r'[ةه]'), 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll(RegExp(r'<[^>]*>'), '') // إزالة HTML
        .trim();
  }
  // ✅ جلب البيانات من الملفات المحلية (بدون إنترنت) وتصحيح أسماء الكتب
  Future<void> _loadAllOfflineData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // 1. قراءة المصحف (محمي بـ try-catch داخلي)
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
                'surahName': surah['name'].toString().replaceAll('سورة ', ''),
                'surahNumber': surah['number'],
                'numberInSurah': ayah['numberInSurah'],
                'page': ayah['page'],
              });
            }
          }
        } else {
          // إذا لم يجد القرآن محلياً، يحاول جلبه من الإنترنت للبحث
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
                  'surahName': surah['name'].toString().replaceAll('سورة ', ''),
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

      // 2. قراءة كتب الأحاديث المتوفرة فقط وتعيين الاسم الصحيح
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
                  'book': _getBookName(bookId), // ✅ هنا حل المشكلة: تعيين اسم الكتاب
                  'grade': (h['grades'] as List?)?.isNotEmpty == true ? h['grades'][0]['grade'] : '',
                });
              }
            }
          }
        } catch (e) {
          print("Hadith Error for $bookId: $e");
        }
      }

      // إضافة الأربعين النووية من الذاكرة لضمان وجود نتائج دائماً
      _hadithDatabase.addAll(_localFortyNawawi);

      // تحديث حالة الواجهة
      _isDataLoaded = true;
      if (query.isNotEmpty) {
        showResults(null!);
      }

    } catch (e) {
      _isError = true;
      _statusMsg = 'حدث خطأ غير متوقع.';
    }
  }
  String _getBookName(String id) {
    switch(id) {
      case 'bukhari': return 'صحيح البخاري';
      case 'muslim': return 'صحيح مسلم';
      case 'tirmidhi': return 'سنن الترمذي';
      case 'abudawud': return 'سنن أبي داود';
      case 'nasai': return 'سنن النسائي';
      case 'ibnmajah': return 'سنن ابن ماجه';
      case 'riyadussalihin': return 'رياض الصالحين';
      case 'forty': return 'الأربعون النووية';
      default: return 'كتاب حديث';
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
    if (_isError) return Center(child: Text('عذراً، حدث خطأ في التحميل', style: GoogleFonts.cairo(color: Colors.red)));

    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('اكتب أي كلمة للبحث في القرآن والسنة', style: GoogleFonts.cairo(color: Colors.grey)),
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
            Text('جاري تجهيز المكتبة للبحث...', style: GoogleFonts.cairo(color: Colors.grey)),
          ],
        ),
      );
    }

    // ==========================================
    // عملية البحث السريعة
    // ==========================================
    final normalizedQuery = _normalize(query);

    // فلترة (حد أقصى 50 نتيجة للسرعة ومنع التعليق)
    var quranResults = _quranAyahs.where((a) => a['searchableText'].contains(normalizedQuery)).take(50).toList();
    var hadithResults = _hadithDatabase.where((h) {
      final hText = h['searchableText'] ?? '';
      return hText.contains(normalizedQuery);
    }).take(50).toList();

    if (quranResults.isEmpty && hadithResults.isEmpty) {
      return Center(child: Text('لا توجد نتائج مطابقة', style: GoogleFonts.cairo(color: Colors.grey)));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 📖 عرض نتائج القرآن
          if (quranResults.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.all(8), child: Text('📖 القرآن الكريم (${quranResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor))),
            ...quranResults.map((q) => _buildQuranCard(q, context)).toList(),
          ],

          // 📚 عرض نتائج الأحاديث
          if (hadithResults.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.all(8), child: Text('📚 الأحاديث (${hadithResults.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown))),
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
        title: Text('${quran['text']} ﴿${quran['numberInSurah']}﴾', style: GoogleFonts.amiri(fontSize: 20, height: 1.8), textAlign: TextAlign.justify),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text('سورة ${quran['surahName']}', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor))),
              const Spacer(),
              Text('صفحة: ${quran['page']}', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        onTap: () {
          quran['keyword'] = query; // لتلوين البحث لاحقاً
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
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('📚 ${hadith['book']} #${hadith['number']}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown))),
              const Spacer(),
              if (hadith['grade'].toString().isNotEmpty) Text('الدرجة: ${hadith['grade']}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.green)),
            ],
          ),
        ),
        onTap: () {
          hadith['keyword'] = query; // لتلوين البحث لاحقاً
          close(context, hadith);
        },
      ),
    );
  }

  // قاعدة بيانات أوفلاين للأربعين النووية (ضمانة عمل البحث دائماً)
  final List<Map<String, dynamic>> _localFortyNawawi = [
    {'type': 'hadith', 'number': 1, 'book': 'الأربعون النووية', 'text': 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى...', 'searchableText': 'انما الاعمال بالنيات وانما لكل امرئ ما نوي'},
    {'type': 'hadith', 'number': 2, 'book': 'الأربعون النووية', 'text': 'بينما نحن جلوس عند رسول الله صلى الله عليه وسلم...', 'searchableText': 'بينما نحن جلوس عند رسول الله صلي الله عليه وسلم'},
    {'type': 'hadith', 'number': 3, 'book': 'الأربعون النووية', 'text': 'بني الإسلام على خمس: شهادة أن لا إله إلا الله...', 'searchableText': 'بني الاسلام علي خمس شهاده ان لا اله الا الله'},
    {'type': 'hadith', 'number': 7, 'book': 'الأربعون النووية', 'text': 'الدين النصيحة. قلنا: لمن؟ قال: لله، ولكتابه، ولرسوله...', 'searchableText': 'الدين النصيحه قلنا لمن قال لله ولكتابه ولرسوله'},
  ];
}