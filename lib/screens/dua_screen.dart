import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  final List<Map<String, String>> duas = const [
    {'title': 'دعاء الاستخارة', 'text': 'اللَّهُمَّ إنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ'},
    {'title': 'دعاء الهم والحزن', 'text': 'اللَّهُمَّ إنِّي أعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ'},
    {'title': 'دعاء السفر', 'text': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإنَّا إلَى رَبِّنَا لَمُنْقَلِبُونَ'},
    {'title': 'دعاء دخول المسجد', 'text': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ'},
    {'title': 'دعاء الخروج من المسجد', 'text': 'اللَّهُمَّ إنِّي أَسْأَلُكَ مِنْ فَضْلِكَ'},
    {'title': 'دعاء قبل الطعام', 'text': 'بِسْمِ اللَّهِ'},
    {'title': 'دعاء بعد الطعام', 'text': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ'},
    {'title': 'دعاء لبس الثوب', 'text': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ'},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary; // الاحتفاظ باللون الأساسي للتطبيق
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان الهوية الزجاجية متكيفة مع وضع الظلام/الفاتح
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : primary.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor, // خلفية الهوية
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الأدعية',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24, color: textColorMain),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : primary.withOpacity(0.1),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: duas.length,
            itemBuilder: (context, index) {
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // لإخفاء خط الـ ExpansionTile
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      iconColor: primary,
                      collapsedIconColor: primary.withOpacity(0.7),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.favorite_rounded, color: primary, size: 24),
                      ),
                      title: Text(
                        duas[index]['title']!,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColorMain,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Text(
                            duas[index]['text']!,
                            style: GoogleFonts.amiri(
                              fontSize: 24,
                              height: 2.2,
                              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}