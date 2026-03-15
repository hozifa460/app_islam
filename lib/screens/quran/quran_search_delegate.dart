import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// ✅ كلاس البحث المستقل تماماً (يعتمد على نفسه لجلب البيانات)
class QuranSearch extends SearchDelegate<Map<String, dynamic>?> {
  final Color primaryColor;

  // لا نحتاج لاستقبال quranData، سنقرؤها من الذاكرة
  List<dynamic> _allAyahs = [];
  bool _isDataLoaded = false;
  bool _isError = false;

  QuranSearch({required this.primaryColor}) {
    _loadQuranData(); // بمجرد فتح البحث، نجهز البيانات
  }

  @override
  String get searchFieldLabel => 'ابحث عن آية أو كلمة...';

  // دالة ذكية لإزالة التشكيل وكل الرموز للبحث السلس
  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا')
        .replaceAll(RegExp(r'[يىئ]'), 'ي')
        .replaceAll(RegExp(r'[ةه]'), 'ه')
        .replaceAll('ؤ', 'و')
        .trim();
  }

  // ✅ الدالة المسؤولة عن توفير بيانات القرآن
  Future<void> _loadQuranData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_uthmani_v1.json');

      String jsonString;

      if (await file.exists()) {
        // إذا كان الملف موجوداً في الجهاز (تم تحميله سابقاً)
        jsonString = await file.readAsString();
      } else {
        // إذا لم يفتح المستخدم المصحف أبداً، نحمله الآن للبحث
        final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'));
        if (response.statusCode == 200) {
          jsonString = response.body;
          await file.writeAsString(jsonString); // نحفظه للمرات القادمة
        } else {
          _isError = true;
          return;
        }
      }

      final data = json.decode(jsonString);
      List<dynamic> tempList = [];

      // تبسيط البيانات لتكون قائمة آيات سهلة البحث
      for (var surah in data['data']['surahs']) {
        for (var ayah in surah['ayahs']) {
          ayah['surahName'] = surah['name'];
          ayah['surahNumber'] = surah['number'];
          tempList.add(ayah);
        }
      }

      _allAyahs = tempList;
      _isDataLoaded = true;

      // لتحديث واجهة البحث إذا كان المستخدم قد كتب شيئاً أثناء التحميل
      if (query.isNotEmpty) {
        showResults(null!); // خدعة لإعادة بناء النتائج
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

    // ✅ عملية البحث
    for (var ayah in _allAyahs) {
      String originalText = ayah['text'];
      String cleanText = _normalize(originalText);

      // بحث يحتوي على الكلمة
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
                      decoration: BoxDecoration(color: primaryColor?.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
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
                // إرجاع النتيجة للصفحة التي فتحت البحث
                close(context, res);
              },
            ),
          );
        },
      ),
    );
  }
}