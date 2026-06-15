import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'theme/books_theme.dart';
import 'animations/books_animations.dart';
import 'widgets/common/search_bar_widget.dart';
import 'widgets/common/category_filter_chips.dart';
import 'widgets/books_screen/daily_banner_widget.dart';
import 'widgets/books_screen/category_section_widget.dart';
import 'book_volumes_screen.dart';
import 'books_reader_screen.dart';
import '../hadith/hadith_book_screen.dart';

class BooksScreen extends StatefulWidget {
  final Color primaryColor;

  const BooksScreen({super.key, required this.primaryColor});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  Map<String, String> _downloadedBooks = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoriesList = [
    'الكل',
    'الحديث النبوي',
    'التفسير وعلوم القرآن',
    'العقيدة والتزكية',
    'الفقه وأصوله',
    'السيرة والتاريخ'
  ];

  final List<Map<String, dynamic>> _dailyBanners = [
    {
      'text': 'اتقوا الله\nفي النساء',
      'colors': [const Color(0xFF151B26), const Color(0xFF0A0E17)]
    },
    {
      'text': 'خيركم من تعلم\nالقرآن وعلمه',
      'colors': [
        const Color(0xFFE6B325).withOpacity(0.4),
        const Color(0xFF151B26)
      ]
    },
    {
      'text': 'الدين\nالنصيحة',
      'colors': [Colors.blueGrey.shade900, const Color(0xFF0A0E17)]
    },
    {
      'text': 'الكلمة الطيبة\nصدقة',
      'colors': [const Color(0xFF1E3C3B), const Color(0xFF0A0E17)]
    },
    {
      'text': 'إنما الأعمال\nبالنيات',
      'colors': [Colors.brown.shade900, const Color(0xFF151B26)]
    },
  ];

  Map<String, List<Map<String, dynamic>>> _libraryCategories = {};
  bool _isBooksLoading = true;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => BooksTheme.getBackgroundColor(isDark);
  Color get textColorMain => BooksTheme.getTextColor(isDark);

  @override
  void initState() {
    super.initState();
    _loadLibraryFromJson().then((_) => _checkDownloadedBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLibraryFromJson() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/json/library_books.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      final Map<String, List<Map<String, dynamic>>> loadedCategories = {};

      decoded.forEach((categoryName, booksList) {
        loadedCategories[categoryName] = List<Map<String, dynamic>>.from(
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
      if (mounted) setState(() => _isBooksLoading = false);
    }
  }

  Future<void> _checkDownloadedBooks() async {
    if (_libraryCategories.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    Map<String, String> tempStatus = {};

    _libraryCategories.forEach((category, books) {
      for (var book in books) {
        if (book['type'] == 'collection') {
          final children =
          List<Map<String, dynamic>>.from(book['children'] ?? []);
          int downloadedCount = 0;

          for (final child in children) {
            String id = child['id'];
            if (id == 'riyad') id = 'riyadussalihin';
            if (id == 'nawawi40') id = 'forty';

            final File file = child['type'] == 'hadith'
                ? File('${dir.path}/hadith_${id}_v1.json')
                : File('${dir.path}/$id.pdf');

            if (file.existsSync()) downloadedCount++;
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

    if (mounted) setState(() => _downloadedBooks = tempStatus);
  }

  Map<String, int> _getCollectionProgress(Map<String, dynamic> book) {
    if (book['type'] != 'collection') {
      return {'downloaded': 0, 'total': 0};
    }

    final children = List<Map<String, dynamic>>.from(book['children'] ?? []);
    int downloaded = 0;

    for (final child in children) {
      final status = _downloadedBooks[child['id']] ?? 'none';
      if (status == 'full' || status == 'partial') downloaded++;
    }

    return {'downloaded': downloaded, 'total': children.length};
  }

  void _navigateToBook(Map<String, dynamic> book) {
    if (book['type'] == 'collection') {
      Navigator.push(
        context,
        BooksPageRoute(
          page: BookVolumesScreen(
            title: book['title'],
            volumes: book['children'] ?? [],
            primaryColor: widget.primaryColor,
          ),
        ),
      );
    } else if (book['type'] == 'hadith') {
      Navigator.push(
        context,
        BooksPageRoute(
          page: HadithBookScreen(
            bookId: book['id'],
            bookTitle: book['title'],
            primaryColor: widget.primaryColor,
          ),
        ),
      ).then((_) => _checkDownloadedBooks());
    } else {
      Navigator.push(
        context,
        BooksPageRoute(
          page: BookReaderScreen(
            bookId: book['id'],
            bookTitle: book['title'],
            primaryColor: widget.primaryColor,
            pdfUrl: book['pdfUrl'] ?? '',
          ),
        ),
      ).then((_) => _checkDownloadedBooks());
    }
  }

  Future<void> _handleDownloadTap(Map<String, dynamic> book) async {
    final downloadStatus = _downloadedBooks[book['id']] ?? 'none';

    if (downloadStatus == 'none') {
      await _downloadBookFile(book);
    } else {
      _showDeleteDialog(book, downloadStatus);
    }
  }

  Future<void> _downloadBookFile(Map<String, dynamic> book) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بدأ تحميل كتاب ${book['title']}...',
            style: GoogleFonts.cairo()),
        backgroundColor: BooksTheme.gold,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      String id = book['id'];
      if (id == 'riyad') id = 'riyadussalihin';
      if (id == 'nawawi40') id = 'forty';

      String urlString;
      if (book['type'] == 'hadith') {
        urlString =
        'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$id.json';
      } else {
        urlString = book['pdfUrl'] ?? '';
      }

      final response =
      await http.get(Uri.parse(urlString)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        File file = File(
            '${dir.path}/${book['type'] == 'hadith' ? 'hadith_${id}_v1.json' : '$id.pdf'}');
        await file.writeAsBytes(response.bodyBytes);

        await _checkDownloadedBooks();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم التحميل بنجاح!', style: GoogleFonts.cairo()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('فشل التحميل. تأكد من الإنترنت.', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(Map<String, dynamic> book, String downloadStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BooksTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BooksTheme.gold.withOpacity(0.3)),
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
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
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

  Future<void> _deleteBookFile(Map<String, dynamic> book) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      if (book['type'] == 'collection') {
        final children =
        List<Map<String, dynamic>>.from(book['children'] ?? []);

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
            content: Text('تم حذف الكتاب.', style: GoogleFonts.cairo()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {}
  }

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

    final sizes = BooksSizes(MediaQuery.of(context).size);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // البحث والفلاتر
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      AnimatedSearchBar(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      CategoryFilterChips(
                        categories: _categoriesList,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) =>
                            setState(() => _selectedCategory = category),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // البانر اليومي
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DailyBannerWidget(
                    banners: _dailyBanners,
                    isDark: isDark,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 25)),

              // قوائم الكتب
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final entry = _libraryCategories.entries.elementAt(index);
                    if (_selectedCategory != 'الكل' &&
                        entry.key != _selectedCategory) {
                      return const SizedBox.shrink();
                    }

                    List<Map<String, dynamic>> searchedBooks =
                    entry.value.where((book) {
                      return book['title'].toString().contains(_searchQuery);
                    }).toList();

                    if (searchedBooks.isEmpty) return const SizedBox.shrink();

                    return CategorySectionWidget(
                      categoryName: entry.key,
                      books: searchedBooks,
                      downloadedBooks: _downloadedBooks,
                      isDark: isDark,
                      bookWidth: sizes.bookWidth,
                      bookHeight: sizes.bookHeight,
                      onBookTap: _navigateToBook,
                      onDownloadTap: _handleDownloadTap,
                      getCollectionProgress: _getCollectionProgress,
                    );
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'المكتبة الإسلامية',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: textColorMain,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BooksTheme.getBackButtonDecoration(isDark),
        child: TapScaleAnimation(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Icon(Icons.arrow_back_ios_new, color: textColorMain),
          ),
        ),
      ),
    );
  }
}