import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hadith_book_screen.dart';

class HadithScreen extends StatelessWidget {
  final Color primaryColor;

  const HadithScreen({super.key, required this.primaryColor});

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);

  final List<Map<String, dynamic>> hadithBooks = const [
    {'title': 'صحيح البخاري', 'author': 'الإمام البخاري', 'id': 'bukhari', 'color': Color(0xFF1B5E20)},
    {'title': 'صحيح مسلم', 'author': 'الإمام مسلم', 'id': 'muslim', 'color': Color(0xFF0D47A1)},
    {'title': 'سنن الترمذي', 'author': 'الإمام الترمذي', 'id': 'tirmidhi', 'color': Color(0xFFBF360C)},
    {'title': 'سنن النسائي', 'author': 'الإمام النسائي', 'id': 'nasai', 'color': Color(0xFF4A148C)},
    {'title': 'سنن أبي داود', 'author': 'الإمام أبو داود', 'id': 'abudawud', 'color': Color(0xFF006064)},
    {'title': 'سنن ابن ماجه', 'author': 'الإمام ابن ماجه', 'id': 'ibnmajah', 'color': Color(0xFF880E4F)},
    {'title': 'رياض الصالحين', 'author': 'الإمام النووي', 'id': 'riyad', 'color': Color(0xFF2E7D32)},
    {'title': 'الأربعون النووية', 'author': 'الإمام النووي', 'id': 'nawawi40', 'color': Color(0xFFF9A825)},
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ كشف الوضع الحالي
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ الألوان الديناميكية
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'كتب الحديث',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: textColorMain,
            ),
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: hadithBooks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                // ✅ تصغير هذه النسبة يجعل البطاقة "أطول"، مما يمنع الـ Overflow تماماً
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final book = hadithBooks[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cardGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      // ✅ إزالة padding ثابت كبير واستبداله بهامش آمن
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // ✅ يمنع تمدد العمود أكثر من اللازم
                        children: [
                          // الأيقونة الدائرية
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (book['color'] as Color).withOpacity(0.2)
                                  : (book['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (book['color'] as Color).withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 32, // ✅ تصغير الأيقونة قليلاً لتوفير مساحة
                              color: isDark ? _gold : (book['color'] as Color),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // العنوان
                          Flexible(
                            child: Text(
                              book['title'],
                              style: GoogleFonts.amiri(
                                fontSize: 20, // ✅ تصغير الخط درجة واحدة
                                fontWeight: FontWeight.bold,
                                color: textColorMain,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // اسم المؤلف
                          Flexible(
                            child: Text(
                              book['author'],
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: textColorSub,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // زر التصفح
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _gold.withOpacity(0.2)),
                            ),
                            child: Text(
                              'تصفح',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: _gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ),
        ),
      ),
    );
  }
}