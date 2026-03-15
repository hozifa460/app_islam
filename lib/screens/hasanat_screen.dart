import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class HasanatScreen extends StatefulWidget {
  const HasanatScreen({super.key});

  @override
  State<HasanatScreen> createState() => _HasanatScreenState();
}

class _HasanatScreenState extends State<HasanatScreen> with TickerProviderStateMixin {
  // ألوان الهوية البصرية המوحدة
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  // العدادات المكتملة
  int palmTrees = 0; // نخلات
  int palaces = 0; // قصور
  int hasanat = 0; // حسنات
  int jewels = 0; // كنوز
  int lights = 0; // أنوار
  int doors = 0; // أبواب

  // عدادات التقدم
  Map<String, int> progressCounters = {
    'palace': 0,
    'door': 0,
    'jewel': 0,
    'palm': 0,
  };

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  int _lastTappedIndex = -1;

  final List<Map<String, dynamic>> deeds = [
    {
      'title': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'reward': 'تُغرس نخلة في الجنة 🌴',
      'hadith': 'من قال سبحان الله وبحمده غرست له نخلة في الجنة',
      'source': 'رواه الترمذي',
      'type': 'palm',
      'icon': '🌴',
      'target': 1,
    },
    {
      'title': 'سُبْحَانَ اللَّهِ العَظِيمِ وَبِحَمْدِهِ',
      'reward': 'تُغرس نخلة في الجنة 🌴',
      'hadith': 'كلمتان خفيفتان على اللسان ثقيلتان في الميزان حبيبتان إلى الرحمن',
      'source': 'رواه البخاري ومسلم',
      'type': 'palm',
      'icon': '🌴',
      'target': 1,
    },
    {
      'title': 'قِرَاءَةُ سُورَةِ الإِخْلَاصِ',
      'reward': 'يُبنى لك قصر في الجنة 🏰',
      'hadith': 'من قرأ قل هو الله أحد عشر مرات بنى الله له قصراً في الجنة',
      'source': 'رواه أحمد',
      'type': 'palace',
      'icon': '🏰',
      'target': 10,
    },
    {
      'title': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'reward': 'كنز من كنوز الجنة 💎',
      'hadith': 'ألا أدلك على كلمة هي كنز من كنوز الجنة: لا حول ولا قوة إلا بالله',
      'source': 'رواه البخاري ومسلم',
      'type': 'jewel',
      'icon': '💎',
      'target': 1,
    },
    {
      'title': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'reward': '100 حسنة وحط 100 سيئة 📿',
      'hadith': 'من قالها في يوم مائة مرة كانت له عدل عشر رقاب...',
      'source': 'رواه البخاري',
      'type': 'hasana',
      'icon': '📿',
      'target': 1,
      'hasanaValue': 100,
    },
    {
      'title': 'الصَّلَاةُ عَلَى النَّبِيِّ ﷺ',
      'reward': 'نور وعشر صلوات ✨',
      'hadith': 'من صلى عليّ صلاة واحدة صلى الله عليه عشر صلوات',
      'source': 'رواه مسلم',
      'type': 'light',
      'icon': '✨',
      'target': 1,
    },
    {
      'title': 'أَسْتَغْفِرُ اللَّهَ',
      'reward': '10 حسنات 📿',
      'hadith': 'من لزم الاستغفار جعل الله له من كل هم فرجاً',
      'source': 'رواه أبو داود',
      'type': 'hasana',
      'icon': '📿',
      'target': 1,
      'hasanaValue': 10,
    },
    {
      'title': 'قِرَاءَةُ آيَةِ الكُرْسِيِّ',
      'reward': 'تفتح لك أبواب الجنة 🚪',
      'hadith': 'من قرأ آية الكرسي دبر كل صلاة لم يمنعه من دخول الجنة إلا أن يموت',
      'source': 'النسائي',
      'type': 'door',
      'icon': '🚪',
      'target': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut)
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      palmTrees = prefs.getInt('palmTrees') ?? 0;
      palaces = prefs.getInt('palaces') ?? 0;
      hasanat = prefs.getInt('hasanat') ?? 0;
      jewels = prefs.getInt('jewels') ?? 0;
      lights = prefs.getInt('lights') ?? 0;
      doors = prefs.getInt('doors') ?? 0;

      progressCounters['palace'] = prefs.getInt('prog_palace') ?? 0;
      progressCounters['door'] = prefs.getInt('prog_door') ?? 0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('palmTrees', palmTrees);
    await prefs.setInt('palaces', palaces);
    await prefs.setInt('hasanat', hasanat);
    await prefs.setInt('jewels', jewels);
    await prefs.setInt('lights', lights);
    await prefs.setInt('doors', doors);

    await prefs.setInt('prog_palace', progressCounters['palace']!);
    await prefs.setInt('prog_door', progressCounters['door']!);
  }

  void _addDeed(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastTappedIndex = index;
      final type = deeds[index]['type'];
      final target = deeds[index]['target'] as int;

      if (type == 'hasana') {
        hasanat += (deeds[index]['hasanaValue'] as int? ?? 10);
      } else if (target > 1) {
        progressCounters[type] = (progressCounters[type] ?? 0) + 1;

        if (progressCounters[type]! >= target) {
          progressCounters[type] = 0;
          _showCompletionSnackbar(deeds[index]['reward']);

          if (type == 'palace') palaces++;
          if (type == 'door') doors++;
        }
      } else {
        _showCompletionSnackbar(deeds[index]['reward']);
        if (type == 'palm') palmTrees++;
        if (type == 'jewel') jewels++;
        if (type == 'light') lights++;
      }
    });

    _bounceController.forward().then((_) => _bounceController.reverse());
    _saveData();
  }

  void _showCompletionSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: _gold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _gold.withOpacity(0.3)),
          ),
          title: Text('إعادة تعيين', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          content: Text('هل تريد تصفير جميع حسناتك وقصورك؟', style: GoogleFonts.cairo(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey))
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  palmTrees = 0; palaces = 0; hasanat = 0; jewels = 0; lights = 0; doors = 0;
                  progressCounters = {'palace': 0, 'door': 0, 'jewel': 0, 'palm': 0};
                });
                _saveData();
                Navigator.pop(context);
              },
              child: Text('إعادة تعيين', style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // الألوان المتكيفة مع الهوية
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('حصاد الحسنات', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24, color: textColorMain)),
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
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                onPressed: _resetAll,
                tooltip: 'تصفير العدادات',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ✅ الإحصائيات (الزجاجية)
              SliverToBoxAdapter(
                child: _buildStatsGrid(isDark, textColorMain),
              ),

              // العنوان
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Container(width: 4, height: 24, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 10),
                      Text('الأعمال والأجور', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: textColorMain)),
                    ],
                  ),
                ),
              ),

              // ✅ قائمة الأعمال
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDeedCard(index, isDark, textColorMain, textColorSub),
                    childCount: deeds.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark, Color textColorMain) {
    final stats = [
      {'title': 'نخلات', 'count': palmTrees, 'icon': '🌴', 'color': Colors.greenAccent},
      {'title': 'قصور', 'count': palaces, 'icon': '🏰', 'color': _gold},
      {'title': 'كنوز', 'count': jewels, 'icon': '💎', 'color': Colors.blueAccent},
      {'title': 'أنوار', 'count': lights, 'icon': '✨', 'color': Colors.orangeAccent},
      {'title': 'أبواب', 'count': doors, 'icon': '🚪', 'color': Colors.brown.shade300},
      {'title': 'حسنات', 'count': hasanat, 'icon': '📿', 'color': Colors.tealAccent},
    ];

    final cardBg = isDark ? _bgCard : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 300 ? 2 : 3;
          double spacing = 12.0;
          double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: stats.map((stat) {
              int index = stats.indexOf(stat);
              final isAnimating = _lastTappedIndex != -1 &&
                  deeds[_lastTappedIndex]['type'] == _getTypeFromTitle(stat['title'] as String);

              return AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.scale(
                  scale: isAnimating ? _bounceAnim.value : 1.0,
                  child: child,
                ),
                child: Container(
                  width: itemWidth,
                  height: itemWidth * 1.1,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (stat['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stat['icon'] as String, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${stat['count']}',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: stat['color'] as Color,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        stat['title'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColorMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _getTypeFromTitle(String title) {
    if (title.contains('نخل')) return 'palm';
    if (title.contains('قصور')) return 'palace';
    if (title.contains('كنوز')) return 'jewel';
    if (title.contains('أنوار')) return 'light';
    if (title.contains('أبواب')) return 'door';
    return 'hasana';
  }

  Widget _buildDeedCard(int index, bool isDark, Color textColorMain, Color textColorSub) {
    final deed = deeds[index];
    final target = deed['target'] as int;
    final currentProgress = progressCounters[deed['type']] ?? 0;
    double progressValue = target > 1 ? (currentProgress / target) : 1.0;

    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);

    return Container(
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
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // الجائزة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _gold.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: _gold.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Text(deed['icon'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    deed['reward'] as String,
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: _gold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // الذكر
                Text(
                  deed['title'] as String,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    height: 1.8,
                    fontWeight: FontWeight.bold,
                    color: textColorMain,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // الحديث (الدليل)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : _gold.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Text(
                        deed['hadith'] as String,
                        style: GoogleFonts.cairo(fontSize: 13, color: textColorSub),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deed['source'] as String,
                        style: GoogleFonts.cairo(fontSize: 11, color: _gold.withOpacity(0.8), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // شريط التقدم وزر الإضافة
                Row(
                  children: [
                    if (target > 1) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'التقدم للهدف:',
                                style: GoogleFonts.cairo(fontSize: 11, color: textColorSub)
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 8,
                                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(_gold),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentProgress / $target',
                              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _gold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    // الزر
                    GestureDetector(
                      onTap: () => _addDeed(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: target > 1 ? 20 : 30, vertical: 12),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_task, color: _gold, size: 20),
                            if (target == 1) ...[
                              const SizedBox(width: 8),
                              Text('إضافة', style: GoogleFonts.cairo(color: _gold, fontWeight: FontWeight.bold)),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}