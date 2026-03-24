import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'book_volumes_screen.dart';
import 'books_reader_screen.dart';
import '../hadith/hadith_book_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BooksScreen extends StatefulWidget {
  final Color primaryColor;

  const BooksScreen({super.key, required this.primaryColor});

   @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // الألوان الأساسية
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  Map<String, String> _downloadedBooks = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoriesList = [
    'الكل', 'الحديث النبوي', 'التفسير وعلوم القرآن', 'العقيدة والتزكية', 'الفقه وأصوله', 'السيرة والتاريخ'
  ];

  final List<Map<String, dynamic>> _dailyBanners = [
    {'text': 'اتقوا الله\nفي النساء', 'colors': [const Color(0xFF151B26), const Color(0xFF0A0E17)]},
    {'text': 'خيركم من تعلم\nالقرآن وعلمه', 'colors': [const Color(0xFFE6B325).withOpacity(0.4), const Color(0xFF151B26)]},
    {'text': 'الدين\nالنصيحة', 'colors': [Colors.blueGrey.shade900, const Color(0xFF0A0E17)]},
    {'text': 'الكلمة الطيبة\nصدقة', 'colors': [const Color(0xFF1E3C3B), const Color(0xFF0A0E17)]},
    {'text': 'إنما الأعمال\nبالنيات', 'colors': [Colors.brown.shade900, const Color(0xFF151B26)]},
  ];

  // ✅ القائمة الكاملة كما أرسلتها بدون أي حذف
  Map<String, List<Map<String, dynamic>>> _libraryCategories = {};
  bool _isBooksLoading = true;

  Future<void> _loadLibraryFromJson() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/json/library_books.json');

      final Map<String, dynamic> decoded = json.decode(jsonString);

      final Map<String, List<Map<String, dynamic>>> loadedCategories = {};

      decoded.forEach((categoryName, booksList) {
        loadedCategories[categoryName] =
        List<Map<String, dynamic>>.from(
          (booksList as List).map((e) => Map<String, dynamic>.from(e)),
        );
      });

      if (mounted) {
        setState(() {
          _libraryCategories = loadedCategories;
          _isBooksLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Books JSON load error: $e');
      if (mounted) {
        setState(() {
          _isBooksLoading = false;
        });
      }
    }


  }

  @override
  void initState() {
    super.initState();
    _loadLibraryFromJson().then((_) {
      _checkDownloadedBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> _getCollectionProgress(Map<String, dynamic> book) {
    if (book['type'] != 'collection') {
      return {'downloaded': 0, 'total': 0};
    }

    final children = List<Map<String, dynamic>>.from(book['children'] ?? []);
    int downloaded = 0;

    for (final child in children) {
      final status = _downloadedBooks[child['id']] ?? 'none';
      if (status == 'full') {
        downloaded++;
      } else if (status == 'partial') {
        downloaded++;
      }
    }

    return {
      'downloaded': downloaded,
      'total': children.length,
    };
  }

  Color _downloadStatusColor(String status) {
    switch (status) {
      case 'full':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.black.withOpacity(0.7);
    }
  }

  IconData _downloadStatusIcon(String status) {
    switch (status) {
      case 'full':
        return Icons.check;
      case 'partial':
        return Icons.downloading_rounded;
      default:
        return Icons.cloud_download;
    }
  }

  String _downloadStatusLabel(String status) {
    switch (status) {
      case 'full':
        return 'محمّل بالكامل';
      case 'partial':
        return 'محمّل جزئيًا';
      default:
        return 'غير محمّل';
    }
  }

  Color _downloadStatusLabelColor(String status) {
    switch (status) {
      case 'full':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _checkDownloadedBooks() async {
    if (_libraryCategories.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    Map<String, String> tempStatus = {};

    _libraryCategories.forEach((category, books) {
      for (var book in books) {
        if (book['type'] == 'collection') {
          final children = List<Map<String, dynamic>>.from(book['children'] ?? []);

          int downloadedCount = 0;

          for (final child in children) {
            String id = child['id'];
            if (id == 'riyad') id = 'riyadussalihin';
            if (id == 'nawawi40') id = 'forty';

            final File file = child['type'] == 'hadith'
                ? File('${dir.path}/hadith_${id}_v1.json')
                : File('${dir.path}/$id.pdf');

            if (file.existsSync()) {
              downloadedCount++;
            }
          }

          if (downloadedCount == 0) {
            tempStatus[book['id']] = 'none';
          } else if (downloadedCount < children.length) {
            tempStatus[book['id']] = 'partial';
          } else {
            tempStatus[book['id']] = 'full';
          }
        } else {
          String id = book['id'];
          if (id == 'riyad') id = 'riyadussalihin';
          if (id == 'nawawi40') id = 'forty';

          final File file = book['type'] == 'hadith'
              ? File('${dir.path}/hadith_${id}_v1.json')
              : File('${dir.path}/$id.pdf');

          tempStatus[book['id']] = file.existsSync() ? 'full' : 'none';
        }
      }
    });

    if (mounted) {
      setState(() {
        _downloadedBooks = tempStatus;
      });
    }
  }

  Future<void> _downloadBookFile(Map<String, dynamic> book) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('بدأ تحميل كتاب ${book['title']}...', style: GoogleFonts.cairo()), backgroundColor: _gold, duration: const Duration(seconds: 2)),
    );

    try {
      String id = book['id'];
      if (id == 'riyad') id = 'riyadussalihin';
      if (id == 'nawawi40') id = 'forty';

      String urlString;
      if (book['type'] == 'hadith') {
        urlString = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$id.json';
      } else {
        urlString = book['pdfUrl'] ?? '';
      }

      final response = await http.get(Uri.parse(urlString)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/${book['type'] == 'hadith' ? 'hadith_${id}_v1.json' : '$id.pdf'}');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _downloadedBooks[book['id']] = true as String;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم التحميل بنجاح!', style: GoogleFonts.cairo()), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحميل. تأكد من الإنترنت.', style: GoogleFonts.cairo()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBookFile(Map<String, dynamic> book) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      if (book['type'] == 'collection') {
        final children = List<Map<String, dynamic>>.from(book['children'] ?? []);

        for (final child in children) {
          String id = child['id'];
          if (id == 'riyad') id = 'riyadussalihin';
          if (id == 'nawawi40') id = 'forty';

          File filePdf = File('${dir.path}/$id.pdf');
          File fileJson = File('${dir.path}/hadith_${id}_v1.json');

          if (await filePdf.exists()) await filePdf.delete();
          if (await fileJson.exists()) await fileJson.delete();
        }
      } else {
        String id = book['id'];
        if (id == 'riyad') id = 'riyadussalihin';
        if (id == 'nawawi40') id = 'forty';

        File filePdf = File('${dir.path}/$id.pdf');
        File fileJson = File('${dir.path}/hadith_${id}_v1.json');

        if (await filePdf.exists()) await filePdf.delete();
        if (await fileJson.exists()) await fileJson.delete();
      }

      await _checkDownloadedBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الكتاب.',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {}
  }

  // ✅ متغيرات التصميم الديناميكي كدوال Getter للحصول عليها بسهولة
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? _bgDark : const Color(0xFFF5F7FA);
  Color get textColorMain => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get textColorSub => isDark ? Colors.white54 : Colors.black54;

  @override
  Widget build(BuildContext context) {

    if (_isBooksLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: CircularProgressIndicator(color: widget.primaryColor),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('المكتبة الإسلامية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24, color: textColorMain)),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // مربع البحث والفلاتر
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2)),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: GoogleFonts.cairo(color: textColorMain),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن كتاب...',
                            hintStyle: GoogleFonts.cairo(color: textColorSub),
                            prefixIcon: Icon(Icons.search, color: _gold),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // فلاتر الأقسام
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categoriesList.map((category) => _buildFilterChip(category)).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // بانر الآية/الحديث
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildDailyBanner(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 25)),

              // قوائم الكتب حسب الأقسام
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final entry = _libraryCategories.entries.elementAt(index);
                    if (_selectedCategory != 'الكل' && entry.key != _selectedCategory) {
                      return const SizedBox.shrink();
                    }

                    List<Map<String, dynamic>> searchedBooks = entry.value.where((book) {
                      return book['title'].toString().contains(_searchQuery);
                    }).toList();

                    if (searchedBooks.isEmpty) return const SizedBox.shrink();

                    return _buildCategorySection(entry.key, searchedBooks);
                  },
                  childCount: _libraryCategories.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _gold.withOpacity(isDark ? 0.2 : 0.8) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _gold.withOpacity(isDark ? 0.5 : 1.0) : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3))),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? (isDark ? _gold : Colors.white) : textColorSub,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyBanner() {
    int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    Map<String, dynamic> todayBanner = _dailyBanners[dayOfYear % _dailyBanners.length];

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: todayBanner['colors'], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Center(
        child: Text(
          todayBanner['text'],
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String categoryName, List<Map<String, dynamic>> books) {
    final firstRow = books.where((book) => book['row'] == 1).toList();
    final secondRow = books.where((book) => book['row'] == 2).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    final bookWidth = isSmall ? 104.0 : 118.0;
    final bookHeight = isSmall ? 210.0 : 228.0;

    Widget buildHorizontalRow(List<Map<String, dynamic>> rowBooks) {
      return SizedBox(
        height: bookHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: rowBooks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final book = rowBooks[index];
            return SizedBox(
              width: bookWidth,
              child: _buildGridBookCard(book, isDark, textColorMain),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoryName,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColorMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (firstRow.isNotEmpty) buildHorizontalRow(firstRow),

          if (secondRow.isNotEmpty) ...[
            const SizedBox(height: 16),
            buildHorizontalRow(secondRow),
          ],

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildGridBookCard(Map<String, dynamic> book, bool isDark, Color mainText) {
    final String downloadStatus = _downloadedBooks[book['id']] ?? 'none';
    final String imageUrl = book['imageUrl'] ?? '';

    final progress = _getCollectionProgress(book);
    final downloadedParts = progress['downloaded'] ?? 0;
    final totalParts = progress['total'] ?? 0;
    final isCollection = book['type'] == 'collection';

    return GestureDetector(
      onTap: () {
        if (book['type'] == 'collection') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookVolumesScreen(
                title: book['title'],
                volumes: book['children'] ?? [],
                primaryColor: widget.primaryColor,
              ),
            ),
          );
        } else if (book['type'] == 'hadith') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HadithBookScreen(
                bookId: book['id'],
                bookTitle: book['title'],
                primaryColor: widget.primaryColor,
              ),
            ),
          ).then((_) => _checkDownloadedBooks());
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookReaderScreen(
                bookId: book['id'],
                bookTitle: book['title'],
                primaryColor: widget.primaryColor,
                pdfUrl: book['pdfUrl'] ?? '',
              ),
            ),
          ).then((_) => _checkDownloadedBooks());
        }
      },
      child: Column(
        children: [
          // الغلاف
          Container(
            height: 155,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: _bgCard,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _gold,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: _bgCard,
                        child: Icon(
                          Icons.book,
                          color: _gold.withOpacity(0.5),
                          size: 36,
                        ),
                      ),
                    )
                        : Container(
                      color: _bgCard,
                      child: Icon(
                        Icons.book,
                        color: _gold.withOpacity(0.5),
                        size: 36,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (downloadStatus == 'none') {
                        _downloadBookFile(book);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: _bgCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: _gold.withOpacity(0.3)),
                            ),
                            title: Text(
                              'إدارة التنزيلات',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              downloadStatus == 'partial'
                                  ? 'بعض أجزاء هذا الكتاب محمّلة. هل ترغب في حذف الملفات الحالية؟'
                                  : 'هل ترغب في حذف هذا الكتاب لتوفير المساحة؟',
                              style: GoogleFonts.cairo(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'إلغاء',
                                  style: GoogleFonts.cairo(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteBookFile(book);
                                },
                                child: Text(
                                  'حذف',
                                  style: GoogleFonts.cairo(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _downloadStatusColor(downloadStatus).withOpacity(
                          downloadStatus == 'none' ? 0.75 : 0.90,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        _downloadStatusIcon(downloadStatus),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // العنوان + الحالة
          SizedBox(
            height: 62,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  child: Text(
                    book['title'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: mainText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _downloadStatusLabel(downloadStatus),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: _downloadStatusLabelColor(downloadStatus),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCollection && totalParts > 0) ...[
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: totalParts == 0 ? 0 : downloadedParts / totalParts,
                        minHeight: 3,
                        backgroundColor: Colors.grey.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          downloadedParts == totalParts ? Colors.green : _gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}