import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';
import 'book_card_widget.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// قسم تصنيف الكتب
/// ═══════════════════════════════════════════════════════════════════════════
class CategorySectionWidget extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> books;
  final Map<String, String> downloadedBooks;
  final bool isDark;
  final double bookWidth;
  final double bookHeight;
  final Function(Map<String, dynamic>) onBookTap;
  final Function(Map<String, dynamic>) onDownloadTap;
  final Function(Map<String, dynamic>) getCollectionProgress;

  const CategorySectionWidget({
    super.key,
    required this.categoryName,
    required this.books,
    required this.downloadedBooks,
    required this.isDark,
    required this.bookWidth,
    required this.bookHeight,
    required this.onBookTap,
    required this.onDownloadTap,
    required this.getCollectionProgress,
  });

  @override
  Widget build(BuildContext context) {
    final firstRow = books.where((book) => book['row'] == 1).toList();
    final secondRow = books.where((book) => book['row'] == 2).toList();

    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          _CategoryHeader(
            title: categoryName,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          // الصف الأول
          if (firstRow.isNotEmpty)
            _HorizontalBookRow(
              books: firstRow,
              downloadedBooks: downloadedBooks,
              isDark: isDark,
              bookWidth: bookWidth,
              bookHeight: bookHeight,
              onBookTap: onBookTap,
              onDownloadTap: onDownloadTap,
              getCollectionProgress: getCollectionProgress,
            ),
          // الصف الثاني
          if (secondRow.isNotEmpty) ...[
            const SizedBox(height: 16),
            _HorizontalBookRow(
              books: secondRow,
              downloadedBooks: downloadedBooks,
              isDark: isDark,
              bookWidth: bookWidth,
              bookHeight: bookHeight,
              onBookTap: onBookTap,
              onDownloadTap: onDownloadTap,
              getCollectionProgress: getCollectionProgress,
            ),
          ],
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// عنوان القسم المتحرك
// ═══════════════════════════════════════════
class _CategoryHeader extends StatefulWidget {
  final String title;
  final bool isDark;

  const _CategoryHeader({
    required this.title,
    required this.isDark,
  });

  @override
  State<_CategoryHeader> createState() => _CategoryHeaderState();
}

class _CategoryHeaderState extends State<_CategoryHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _widthAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) => Container(
            width: _widthAnimation.value,
            height: 24,
            decoration: BoxDecoration(
              color: BooksTheme.gold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BooksTheme.getTextColor(widget.isDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// صف الكتب الأفقي
// ═══════════════════════════════════════════
class _HorizontalBookRow extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final Map<String, String> downloadedBooks;
  final bool isDark;
  final double bookWidth;
  final double bookHeight;
  final Function(Map<String, dynamic>) onBookTap;
  final Function(Map<String, dynamic>) onDownloadTap;
  final Function(Map<String, dynamic>) getCollectionProgress;

  const _HorizontalBookRow({
    required this.books,
    required this.downloadedBooks,
    required this.isDark,
    required this.bookWidth,
    required this.bookHeight,
    required this.onBookTap,
    required this.onDownloadTap,
    required this.getCollectionProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bookHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          final downloadStatus = downloadedBooks[book['id']] ?? 'none';
          final progress = getCollectionProgress(book);

          return StaggeredBookCardAnimation(
            index: index,
            child: SizedBox(
              width: bookWidth,
              child: BookCardWidget(
                book: book,
                downloadStatus: downloadStatus,
                isDark: isDark,
                downloadedParts: progress['downloaded'],
                totalParts: progress['total'],
                onTap: () => onBookTap(book),
                onDownloadTap: () => onDownloadTap(book),
              ),
            ),
          );
        },
      ),
    );
  }
}