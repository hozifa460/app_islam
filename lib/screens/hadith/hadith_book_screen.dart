import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HadithBookScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final Color primaryColor;

  // ✅ يجب أن تكون المتغيرات اختيارية (علامة ؟) وليست (required)
  final int? targetHadithNumber;
  final String? searchQuery;

  const HadithBookScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.primaryColor, this.targetHadithNumber, this.searchQuery,
  });

  @override
  State<HadithBookScreen> createState() => _HadithBookScreenState();
}

class _HadithBookScreenState extends State<HadithBookScreen> {
  List<dynamic> _allHadiths = [];
  List<dynamic> _displayedHadiths = [];

  bool _isLoading = true;
  bool _isDownloading = false;
  bool _hasError = false;
  String _statusMessage = 'جاري التهيئة...';

  int _currentMax = 20;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initOfflineBook();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ دالة قوية لتنظيف النص للبحث
  String _normalizeText(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآاٱٰ]'), 'ا')
        .replaceAll(RegExp(r'[يىئ]'), 'ي')
        .replaceAll(RegExp(r'[ةه]'), 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }


  // دالة لتلوين كلمة البحث داخل الحديث
  List<TextSpan> _buildHighlightedHadithText(String text, String? keyword, Color textColor) {
    if (keyword == null || keyword.trim().isEmpty) {
      return [TextSpan(text: text, style: GoogleFonts.amiri(fontSize: 22, height: 1.8, color: textColor))];
    }

    List<TextSpan> spans = [];
    List<String> words = text.split(' ');
    String cleanKeyword = _normalizeText(keyword);

    for (String word in words) {
      String cleanWord = _normalizeText(word);
      if (cleanWord.contains(cleanKeyword)) {
        spans.add(TextSpan(
          text: '$word ',
          style: GoogleFonts.amiri(fontSize: 22, height: 1.8, color: Colors.black87, backgroundColor: Colors.amber.withOpacity(0.8)),
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: GoogleFonts.amiri(fontSize: 22, height: 1.8, color: textColor),
        ));
      }
    }
    return spans;
  }
  // ✅ تحميل وحفظ الكتاب أوفلاين
  Future<void> _initOfflineBook() async {
    try {
      String apiId = widget.bookId;
      if (apiId == 'riyad') apiId = 'riyadussalihin';
      if (apiId == 'nawawi40') apiId = 'forty';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/hadith_${apiId}_v1.json');

      if (await file.exists()) {
        // 1. الكتاب محمل مسبقاً (سريع جداً)
        setState(() {
          _statusMessage = 'جاري فتح الكتاب...';
        });
        final jsonString = await file.readAsString();
        _processData(json.decode(jsonString));
      } else {
        // 2. تحميل الكتاب لأول مرة (يأخذ بضع ثواني)
        setState(() {
          _isDownloading = true;
          _statusMessage = 'جاري تنزيل الكتاب لأول مرة...\nسيعمل بدون إنترنت لاحقاً.';
        });

        final url = Uri.parse('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$apiId.json');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // فك التشفير لحفظ اللغة العربية بشكل صحيح
          final decodedBody = utf8.decode(response.bodyBytes);
          await file.writeAsString(decodedBody); // حفظ في الهاتف

          _processData(json.decode(decodedBody));
        } else {
          throw Exception('فشل في التحميل');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _hasError = true;
          _statusMessage = 'تأكد من اتصالك بالإنترنت في المرة الأولى';
        });
      }
    }
  }

  // ✅ تجهيز البيانات للعرض
  void _processData(dynamic data) {
    List<dynamic> rawList = [];
    if (data is Map && data.containsKey('hadiths')) {
      rawList = data['hadiths'];
    } else if (data is List) {
      rawList = data;
    }

    List<dynamic> validList = [];

    for (var h in rawList) {
      // محاولة استخراج النص من الحقول المختلفة
      String rawText = h['text'] ?? h['body'] ?? h['hadithArabic'] ?? '';
      String cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      // استخراج الباب (Reference / Chapter)
      String reference = '';
      if (h['reference'] != null && h['reference'] is Map) {
        reference = h['reference']['book']?.toString() ?? '';
      }

      if (cleanText.length > 5) {
        h['originalText'] = cleanText;
        h['searchableText'] = _normalizeText(cleanText);
        h['chapter'] = reference;
        validList.add(h);
      }
    }

    if (mounted) {
      setState(() {
        _allHadiths = validList;

        // ✅ إذا كنا قادمين من نتيجة بحث لحديث معين
        if (widget.targetHadithNumber != null) {
          _displayedHadiths = _allHadiths.where((h) => h['hadithnumber'] == widget.targetHadithNumber).toList();
        } else {
          _displayedHadiths = _allHadiths;
        }

        _isLoading = false;
        _isDownloading = false;
        _hasError = false;
      });
    }
  }

  void _loadMore() {
    if (_currentMax < _displayedHadiths.length) {
      setState(() {
        _currentMax += 20;
      });
    }
  }

  void _filterHadiths(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _displayedHadiths = _allHadiths;
        _currentMax = 20;
      });
      return;
    }

    String normalizedQuery = _normalizeText(query);

    setState(() {
      _displayedHadiths = _allHadiths.where((hadith) {
        final searchableText = hadith['searchableText'] ?? '';
        final number = hadith['hadithnumber'].toString();
        return searchableText.contains(normalizedQuery) || number.contains(normalizedQuery);
      }).toList();
      _currentMax = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ كشف وضع الهاتف
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor, // ✅ خلفية متكيفة
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.bookTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              if (!_isLoading && !_hasError)
                Text(
                  '${_allHadiths.length} حديث',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
                ),
            ],
          ),
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _buildBody(isDark, textColor), // ✅ تمرير المتغيرات
      ),
    );
  }

  Widget _buildBody(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    if (_isLoading || _isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.primaryColor),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 16, color: widget.primaryColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey),
            const SizedBox(height: 16),
            Text(_statusMessage, style: GoogleFonts.cairo(fontSize: 16, color: textColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor),
              onPressed: _initOfflineBook,
              child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        // ================= 1. شريط البحث =================
        Container(
          padding: const EdgeInsets.all(16),
          color: widget.primaryColor,
          child: TextField(
            controller: _searchController,
            onChanged: _filterHadiths,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87), // ✅ لون النص متكيف
            decoration: InputDecoration(
              hintText: 'ابحث عن كلمة، أو رقم الحديث...',
              hintStyle: GoogleFonts.cairo(color: isDark ? Colors.white54 : Colors.grey),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : widget.primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: isDark ? Colors.white54 : Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _filterHadiths('');
                },
              )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.white, // ✅ خلفية حقل البحث متكيفة
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        // ================= 2. القائمة =================
        Expanded(
          child: _displayedHadiths.isEmpty
              ? Center(child: Text('لا توجد نتائج مطابقة', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: (_currentMax < _displayedHadiths.length) ? _currentMax + 1 : _displayedHadiths.length,
            itemBuilder: (context, index) {
              if (index == _currentMax) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator(color: widget.primaryColor, strokeWidth: 3)),
                );
              }

              final hadith = _displayedHadiths[index];
              return _buildHadithCard(hadith, isDark, cardColor, textColor); // ✅ تمرير الألوان للبطاقة
            },
          ),
        ),
      ],
    );
  }

  // ✅ بناء بطاقة الحديث الاحترافية
  Widget _buildHadithCard(dynamic hadith, bool isDark, Color cardColor, Color textColor) {
    final body = hadith['originalText'];
    final hadithNumber = hadith['hadithnumber'];
    final chapter = hadith['chapter'];

    List grades = hadith['grades'] ?? [];
    String narrator = '';

    if (body.startsWith('عن') || body.startsWith('حدثنا')) {
      int firstComma = body.indexOf('،');
      int firstColon = body.indexOf(':');
      int splitIndex = -1;

      if (firstComma != -1 && firstColon != -1) {
        splitIndex = firstComma < firstColon ? firstComma : firstColon;
      } else if (firstComma != -1) {
        splitIndex = firstComma;
      } else if (firstColon != -1) {
        splitIndex = firstColon;
      }

      if (splitIndex > 0 && splitIndex < 100) {
        narrator = body.substring(0, splitIndex).trim();
      }
    }

    return Card(
      color: cardColor, // ✅ بطاقة متكيفة
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? BorderSide(color: Colors.white.withOpacity(0.05)) : BorderSide.none, // حد خفيف في الداكن
      ),
      elevation: isDark ? 0 : 2, // إزالة الظل في الداكن لجمالية أفضل
      shadowColor: Colors.black.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الترويسة العلوية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? widget.primaryColor.withOpacity(0.15) : widget.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: widget.primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'رقم: $hadithNumber',
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    chapter.isNotEmpty ? 'باب: $chapter' : widget.bookTitle,
                    style: GoogleFonts.cairo(color: widget.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Share.share('$body\n\n[${widget.bookTitle} - رقم: $hadithNumber]');
                  },
                )
              ],
            ),
          ),

          // 2. نص الحديث
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  if (narrator.isNotEmpty)
                    TextSpan(
                      text: '$narrator\n',
                      style: GoogleFonts.amiri(fontSize: 18, color: widget.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  // ✅ تمرير textColor لضمان تلون النص الأساسي
                  ..._buildHighlightedHadithText(
                    narrator.isNotEmpty ? body.substring(narrator.length).trim().replaceFirst(RegExp(r'^[،:]'), '').trim() : body,
                    widget.searchQuery,
                    textColor,
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),

          // 3. الحكم على الحديث
          if (grades.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: grades.map<Widget>((grade) {
                      String gradeText = grade['grade'].toString().trim();
                      String gradeName = grade['name'].toString().trim();

                      // ✅ ألوان تقييم متكيفة مع الوضع الداكن
                      Color chipBg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
                      Color chipText = isDark ? Colors.grey.shade300 : Colors.black87;

                      if (gradeText.toLowerCase().contains('sahih')) {
                        chipBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;
                        chipText = isDark ? Colors.green.shade300 : Colors.green.shade800;
                        gradeText = 'صحيح';
                      } else if (gradeText.toLowerCase().contains('hasan')) {
                        chipBg = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50;
                        chipText = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
                        gradeText = 'حسن';
                      } else if (gradeText.toLowerCase().contains('daif')) {
                        chipBg = isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50;
                        chipText = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
                        gradeText = 'ضعيف';
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: chipText.withOpacity(isDark ? 0.4 : 0.2))
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_outlined, size: 14, color: chipText),
                            const SizedBox(width: 4),
                            Text('$gradeName: $gradeText', style: GoogleFonts.cairo(fontSize: 11, color: chipText, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}