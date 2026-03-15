import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  final List<Map<String, dynamic>> azkarCategories = const [
    {
      'title': 'أذكار الصباح',
      'icon': Icons.wb_sunny_rounded,
      'azkar': [
        {'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ', 'count': 1},
        {'text': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ', 'count': 1},
        {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'count': 100},
        {'text': 'لَا إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 'count': 10},
        {'text': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 'count': 100},
      ],
    },
    {
      'title': 'أذكار المساء',
      'icon': Icons.nights_stay_rounded,
      'azkar': [
        {'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ', 'count': 1},
        {'text': 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ', 'count': 1},
        {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'count': 100},
        {'text': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', 'count': 3},
      ],
    },
    {
      'title': 'أذكار بعد الصلاة',
      'icon': Icons.mosque_rounded,
      'azkar': [
        {'text': 'أَسْتَغْفِرُ اللَّهَ (ثلاثاً) اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ', 'count': 1},
        {'text': 'سُبْحَانَ اللَّهِ', 'count': 33},
        {'text': 'الْحَمْدُ لِلَّهِ', 'count': 33},
        {'text': 'اللَّهُ أَكْبَرُ', 'count': 33},
      ],
    },
    {
      'title': 'أذكار النوم',
      'icon': Icons.bedtime_rounded,
      'azkar': [
        {'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 'count': 1},
        {'text': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ', 'count': 3},
        {'text': 'سُبْحَانَ اللَّهِ', 'count': 33},
        {'text': 'الْحَمْدُ لِلَّهِ', 'count': 33},
        {'text': 'اللَّهُ أَكْبَرُ', 'count': 34},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // الألوان المتكيفة مع الحفاظ على الهوية
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
            'الأذكار',
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
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: azkarCategories.length,
            itemBuilder: (context, index) {
              final category = azkarCategories[index];
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
                        builder: (_) => AzkarDetailScreen(
                          title: category['title'] as String,
                          azkar: category['azkar'] as List<Map<String, dynamic>>,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        // أيقونة زجاجية
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _gold.withOpacity(0.3)),
                          ),
                          child: Icon(category['icon'] as IconData, color: _gold, size: 28),
                        ),
                        const SizedBox(width: 16),
                        // النصوص
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['title'] as String,
                                style: GoogleFonts.cairo(
                                  color: textColorMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : _gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(category['azkar'] as List).length} أذكار',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // سهم
                        Icon(Icons.arrow_forward_ios, size: 16, color: textColorSub.withOpacity(0.5)),
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

class AzkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> azkar;

  const AzkarDetailScreen({
    super.key,
    required this.title,
    required this.azkar,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late List<int> counters;

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  @override
  void initState() {
    super.initState();
    counters = widget.azkar.map((a) => a['count'] as int).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
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
            widget.title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 22,
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
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.azkar.length,
            itemBuilder: (context, index) {
              final isDone = counters[index] == 0;

              return GestureDetector(
                onTap: () {
                  if (counters[index] > 0) {
                    setState(() {
                      counters[index]--;
                    });
                    // يمكن إضافة HapticFeedback هنا للشعور بالضغط
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDone
                          ? [Colors.green.withOpacity(isDark ? 0.2 : 0.1), Colors.green.withOpacity(isDark ? 0.05 : 0.02)]
                          : cardGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDone ? Colors.green.withOpacity(0.5) : borderColor,
                      width: isDone ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // النص القرآني/الذكر
                      Text(
                        widget.azkar[index]['text'],
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          height: 2.2,
                          color: isDone ? (isDark ? Colors.white54 : Colors.black54) : textColorMain,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // العداد بتصميم دائري متوهج
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: isDone
                            ? Container(
                          key: const ValueKey('done'),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text('تم', style: GoogleFonts.cairo(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                            : Container(
                          key: ValueKey(counters[index]),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.15),
                            border: Border.all(color: _gold.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${counters[index]}',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _gold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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