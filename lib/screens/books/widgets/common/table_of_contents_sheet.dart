import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../animations/books_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// لوحة الفهرس السفلية
/// ═══════════════════════════════════════════════════════════════════════════
class TableOfContentsSheet extends StatelessWidget {
  final List<Map<String, dynamic>>? chapters;
  final Function(int)? onChapterTap;

  const TableOfContentsSheet({
    super.key,
    this.chapters,
    this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // المقبض
          _DragHandle(),
          const SizedBox(height: 16),
          // العنوان
          _SheetHeader(),
          const Divider(),
          // المحتوى
          Expanded(
            child: chapters == null || chapters!.isEmpty
                ? _EmptyState()
                : _ChaptersList(
              chapters: chapters!,
              onChapterTap: onChapterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatefulWidget {
  @override
  State<_SheetHeader> createState() => _SheetHeaderState();
}

class _SheetHeaderState extends State<_SheetHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: -20, end: 0).animate(
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
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Opacity(
          opacity: _controller.value,
          child: child,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_rounded,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'فهرس الكتاب',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'هذه الميزة تعمل مع الكتب النصية فقط',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChaptersList extends StatelessWidget {
  final List<Map<String, dynamic>> chapters;
  final Function(int)? onChapterTap;

  const _ChaptersList({
    required this.chapters,
    this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return StaggeredBookCardAnimation(
          index: index,
          baseDuration: Duration(milliseconds: 200 + (index * 50)),
          child: _ChapterItem(
            title: chapter['title'] ?? 'فصل ${index + 1}',
            page: chapter['page'] ?? 0,
            onTap: () => onChapterTap?.call(chapter['page'] ?? 0),
          ),
        );
      },
    );
  }
}

class _ChapterItem extends StatefulWidget {
  final String title;
  final int page;
  final VoidCallback onTap;

  const _ChapterItem({
    required this.title,
    required this.page,
    required this.onTap,
  });

  @override
  State<_ChapterItem> createState() => _ChapterItemState();
}

class _ChapterItemState extends State<_ChapterItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.page}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}