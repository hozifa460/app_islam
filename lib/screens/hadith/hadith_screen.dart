import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hadith_book_screen.dart';

class HadithScreen extends StatelessWidget {
  final Color primaryColor;

  const HadithScreen({super.key, required this.primaryColor});

  final Color _gold = const Color(0xFFD4A847);
  final Color _bgDark = const Color(0xFF0A0E17);

  final List<Map<String, dynamic>> hadithBooks = const [
    {'title': 'صحيح البخاري', 'author': 'الإمام البخاري', 'id': 'bukhari', 'color': Color(0xFF1B5E20), 'icon': Icons.auto_stories_rounded, 'hadithCount': '7563'},
    {'title': 'صحيح مسلم', 'author': 'الإمام مسلم', 'id': 'muslim', 'color': Color(0xFF0D47A1), 'icon': Icons.menu_book_rounded, 'hadithCount': '5362'},
    {'title': 'سنن الترمذي', 'author': 'الإمام الترمذي', 'id': 'tirmidhi', 'color': Color(0xFFBF360C), 'icon': Icons.book_rounded, 'hadithCount': '3956'},
    {'title': 'سنن النسائي', 'author': 'الإمام النسائي', 'id': 'nasai', 'color': Color(0xFF4A148C), 'icon': Icons.chrome_reader_mode_rounded, 'hadithCount': '5774'},
    {'title': 'سنن أبي داود', 'author': 'الإمام أبو داود', 'id': 'abudawud', 'color': Color(0xFF006064), 'icon': Icons.library_books_rounded, 'hadithCount': '5274'},
    {'title': 'سنن ابن ماجه', 'author': 'الإمام ابن ماجه', 'id': 'ibnmajah', 'color': Color(0xFF880E4F), 'icon': Icons.import_contacts_rounded, 'hadithCount': '4341'},
    {'title': 'رياض الصالحين', 'author': 'الإمام النووي', 'id': 'riyad', 'color': Color(0xFF2E7D32), 'icon': Icons.local_library_rounded, 'hadithCount': '1896'},
    {'title': 'الأربعون النووية', 'author': 'الإمام النووي', 'id': 'nawawi40', 'color': Color(0xFFF57F17), 'icon': Icons.bookmark_rounded, 'hadithCount': '42'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bgColor = isDark ? _bgDark : const Color(0xFFF7F5F0);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white60 : const Color(0xFF777777);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ───
            SliverAppBar(
              expandedHeight: screenHeight * 0.28,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? const Color(0xFF111827) : primaryColor,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    final iconSize = (h * 0.22).clamp(40.0, 75.0);
                    final titleSize = (h * 0.09).clamp(16.0, 26.0);
                    final subSize = (h * 0.05).clamp(10.0, 14.0);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [const Color(0xFF111827), const Color(0xFF1E293B)]
                                  : [primaryColor, primaryColor.withOpacity(0.8), const Color(0xFF0D3B2E)],
                            ),
                          ),
                        ),
                        // Pattern overlay
                        CustomPaint(
                          painter: _GeometricPatternPainter(
                            color: Colors.white.withOpacity(0.035),
                          ),
                        ),
                        // Content
                        Positioned(
                          top: h * 0.22,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon circle
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _gold.withOpacity(0.3),
                                      _gold.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(color: _gold.withOpacity(0.5), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _gold.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  size: iconSize * 0.45,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: h * 0.03),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'كتب الحديث الشريف',
                                    style: GoogleFonts.amiriQuran(
                                      fontSize: titleSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: h * 0.015),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'أمهات الكتب الستة وغيرها',
                                    style: GoogleFonts.cairo(
                                      fontSize: subSize,
                                      color: _gold.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom curve
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(28),
                                topRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ─── Stats Bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.08) : _gold.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('${hadithBooks.length}', 'كتاب', Icons.menu_book_rounded, isDark, textColorMain, textColorSub),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                      ),
                      _buildStatItem('34,208', 'حديث', Icons.format_quote_rounded, isDark, textColorMain, textColorSub),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                      ),
                      _buildStatItem('8', 'مؤلف', Icons.person_rounded, isDark, textColorMain, textColorSub),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Grid ───
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final book = hadithBooks[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _HadithBookCard(
                        book: book,
                        gold: _gold,
                        isDark: isDark,
                        textColorMain: textColorMain,
                        textColorSub: textColorSub,
                        primaryColor: primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HadithBookScreen(
                                bookId: book['id'],
                                bookTitle: book['title'],
                                primaryColor: primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: hadithBooks.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: screenWidth > 600 ? 0.8 : (screenWidth / (screenHeight * 0.38)).clamp(0.62, 0.82),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, bool isDark, Color textColor, Color subColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _gold),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: subColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Book Card Widget ───
class _HadithBookCard extends StatefulWidget {
  final Map<String, dynamic> book;
  final Color gold;
  final bool isDark;
  final Color textColorMain;
  final Color textColorSub;
  final Color primaryColor;
  final VoidCallback onTap;

  const _HadithBookCard({
    required this.book,
    required this.gold,
    required this.isDark,
    required this.textColorMain,
    required this.textColorSub,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_HadithBookCard> createState() => _HadithBookCardState();
}

class _HadithBookCardState extends State<_HadithBookCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bookColor = widget.book['color'] as Color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final cardHeight = constraints.maxHeight;
            final iconContainerSize = (cardHeight * 0.28).clamp(40.0, 65.0);
            final iconSize = (iconContainerSize * 0.48).clamp(18.0, 30.0);
            final titleSize = (cardHeight * 0.095).clamp(12.0, 18.0);
            final authorSize = (cardHeight * 0.065).clamp(9.0, 13.0);
            final badgeSize = (cardHeight * 0.055).clamp(8.0, 11.0);
            final spacing = (cardHeight * 0.03).clamp(4.0, 10.0);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDark
                      ? [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.02)]
                      : [Colors.white, const Color(0xFFFCFBF9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: widget.isDark
                      ? bookColor.withOpacity(0.2)
                      : widget.gold.withOpacity(0.18),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withOpacity(0.3)
                        : bookColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Top accent line
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            bookColor.withOpacity(0.6),
                            widget.gold.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Corner ornament
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: bookColor.withOpacity(widget.isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: bookColor.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (cardWidth * 0.08).clamp(8.0, 16.0),
                      vertical: (cardHeight * 0.06).clamp(8.0, 14.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: spacing),

                        // Book icon
                        Container(
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                bookColor.withOpacity(widget.isDark ? 0.3 : 0.15),
                                bookColor.withOpacity(widget.isDark ? 0.15 : 0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: bookColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: bookColor.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.book['icon'] as IconData? ?? Icons.menu_book_rounded,
                            size: iconSize,
                            color: widget.isDark ? widget.gold : bookColor,
                          ),
                        ),

                        SizedBox(height: spacing * 1.2),

                        // Title
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.book['title'],
                              style: GoogleFonts.amiri(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: widget.textColorMain,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        SizedBox(height: spacing * 0.4),

                        // Author
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.book['author'],
                              style: GoogleFonts.cairo(
                                fontSize: authorSize,
                                color: widget.textColorSub,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        SizedBox(height: spacing * 0.8),

                        // Badge
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    bookColor.withOpacity(widget.isDark ? 0.25 : 0.1),
                                    widget.gold.withOpacity(widget.isDark ? 0.15 : 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: bookColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    size: badgeSize,
                                    color: widget.isDark ? widget.gold : bookColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تصفّح',
                                    style: GoogleFonts.cairo(
                                      fontSize: badgeSize,
                                      color: widget.isDark ? widget.gold : bookColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: spacing * 0.3),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Geometric Pattern Painter ───
class _GeometricPatternPainter extends CustomPainter {
  final Color color;

  _GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 45.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawOctagon(canvas, Offset(x, y), spacing * 0.32, paint);
        _drawDiamond(canvas, Offset(x + spacing / 2, y + spacing / 2), spacing * 0.15, paint);
      }
    }
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 8;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}