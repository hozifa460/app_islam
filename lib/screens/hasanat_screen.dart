import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HasanatScreen extends StatefulWidget {
  const HasanatScreen({super.key});

  @override
  State<HasanatScreen> createState() => _HasanatScreenState();
}

class _HasanatScreenState extends State<HasanatScreen>
    with TickerProviderStateMixin {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  int palmTrees = 0;
  int palaces = 0;
  int hasanat = 0;
  int jewels = 0;
  int lights = 0;
  int doors = 0;
  int shields = 0;
  int scales = 0;

  Map<String, int> progressCounters = {
    'palace': 0,
    'door': 0,
    'jewel': 0,
    'palm': 0,
    'shield': 0,
    'scale': 0,
  };

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  int _lastTappedIndex = -1;

  final List<Map<String, dynamic>> deeds = [
    {
      'title': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'reward': 'تُغرس نخلة في الجنة',
      'hadith': 'من قال سبحان الله وبحمده غُرست له نخلة في الجنة',
      'source': 'رواه الترمذي وصححه الألباني',
      'type': 'palm',
      'icon': '🌴',
      'target': 1,
      'color': 0xFF4CAF50,
    },
    {
      'title': 'سُبْحَانَ اللَّهِ العَظِيمِ وَبِحَمْدِهِ',
      'reward': 'ثقيلتان في الميزان',
      'hadith':
      'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن: سبحان الله وبحمده، سبحان الله العظيم',
      'source': 'رواه البخاري ومسلم',
      'type': 'scale',
      'icon': '⚖️',
      'target': 1,
      'color': 0xFF9C27B0,
    },
    {
      'title': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ (100 مرة)',
      'reward': 'حط الخطايا وإن كانت كزبد البحر',
      'hadith':
      'من قال سبحان الله وبحمده في يوم مائة مرة حُطّت خطاياه وإن كانت مثل زبد البحر',
      'source': 'رواه البخاري ومسلم',
      'type': 'hasana',
      'icon': '🌊',
      'target': 100,
      'hasanaValue': 1,
      'color': 0xFF00BCD4,
    },
    {
      'title': 'قِرَاءَةُ سُورَةِ الإِخْلَاصِ (10 مرات)',
      'reward': 'يُبنى لك قصر في الجنة',
      'hadith':
      'من قرأ قل هو الله أحد عشر مرات بنى الله له قصرًا في الجنة',
      'source': 'رواه أحمد وصححه الألباني',
      'type': 'palace',
      'icon': '🏰',
      'target': 10,
      'color': 0xFFFF9800,
    },
    {
      'title': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'reward': 'كنز من كنوز الجنة',
      'hadith':
      'ألا أدلك على كلمة هي كنز من كنوز الجنة؟ لا حول ولا قوة إلا بالله',
      'source': 'رواه البخاري ومسلم',
      'type': 'jewel',
      'icon': '💎',
      'target': 1,
      'color': 0xFF2196F3,
    },
    {
      'title':
      'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'reward': '100 حسنة وحط 100 سيئة وحرز من الشيطان',
      'hadith':
      'من قالها في يوم مائة مرة كانت له عدل عشر رقاب، وكُتبت له مائة حسنة، ومُحيت عنه مائة سيئة، وكانت له حرزًا من الشيطان',
      'source': 'رواه البخاري ومسلم',
      'type': 'hasana',
      'icon': '📿',
      'target': 1,
      'hasanaValue': 100,
      'color': 0xFF009688,
    },
    {
      'title': 'الصَّلَاةُ عَلَى النَّبِيِّ ﷺ',
      'reward': '10 صلوات من الله وحط 10 سيئات ورفع 10 درجات',
      'hadith':
      'من صلّى عليّ صلاة واحدة صلّى الله عليه عشر صلوات، وحُطّت عنه عشر خطيئات، ورُفعت له عشر درجات',
      'source': 'رواه مسلم والنسائي',
      'type': 'light',
      'icon': '✨',
      'target': 1,
      'color': 0xFFFFC107,
    },
    {
      'title': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'reward': 'فرج من كل ضيق ومخرج من كل هم',
      'hadith':
      'من لزم الاستغفار جعل الله له من كل همّ فرجًا، ومن كل ضيق مخرجًا، ورزقه من حيث لا يحتسب',
      'source': 'رواه أبو داود وابن ماجه',
      'type': 'hasana',
      'icon': '🤲',
      'target': 1,
      'hasanaValue': 10,
      'color': 0xFF8BC34A,
    },
    {
      'title': 'قِرَاءَةُ آيَةِ الكُرْسِيِّ بعد كل صلاة',
      'reward': 'لم يمنعه من دخول الجنة إلا أن يموت',
      'hadith':
      'من قرأ آية الكرسي دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا أن يموت',
      'source': 'رواه النسائي وصححه الألباني',
      'type': 'door',
      'icon': '🚪',
      'target': 5,
      'color': 0xFF795548,
    },
    {
      'title':
      'سُبْحَانَ اللَّهِ، وَالحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      'reward': 'أحب الكلام إلى الله',
      'hadith':
      'أحب الكلام إلى الله أربع: سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
      'source': 'رواه مسلم',
      'type': 'scale',
      'icon': '⚖️',
      'target': 1,
      'color': 0xFFE91E63,
    },
    {
      'title':
      'سُبْحَانَ اللَّهِ (33) وَالحَمْدُ لِلَّهِ (33) وَاللَّهُ أَكْبَرُ (34)',
      'reward': 'تُغفر ذنوبه وإن كانت مثل زبد البحر',
      'hadith':
      'من سبّح الله في دبر كل صلاة ثلاثًا وثلاثين، وحمد الله ثلاثًا وثلاثين، وكبّر الله ثلاثًا وثلاثين',
      'source': 'رواه مسلم',
      'type': 'hasana',
      'icon': '📿',
      'target': 1,
      'hasanaValue': 50,
      'color': 0xFF3F51B5,
    },
    {
      'title': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'reward': 'أفضل ما قاله النبيون',
      'hadith':
      'أفضل الذكر لا إله إلا الله، وأفضل الدعاء الحمد لله',
      'source': 'رواه الترمذي وابن ماجه',
      'type': 'light',
      'icon': '🌟',
      'target': 1,
      'color': 0xFFFF5722,
    },
    {
      'title': 'الحَمْدُ لِلَّهِ',
      'reward': 'تملأ الميزان',
      'hadith':
      'الطهور شطر الإيمان، والحمد لله تملأ الميزان',
      'source': 'رواه مسلم',
      'type': 'scale',
      'icon': '⚖️',
      'target': 1,
      'color': 0xFF607D8B,
    },
    {
      'title':
      'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ العَلِيمُ (3 مرات)',
      'reward': 'حفظ من كل شر',
      'hadith':
      'من قالها ثلاث مرات حين يُصبح وثلاث مرات حين يُمسي لم يضره شيء',
      'source': 'رواه أبو داود والترمذي',
      'type': 'shield',
      'icon': '🛡️',
      'target': 3,
      'color': 0xFF00695C,
    },
    {
      'title': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ (3 مرات)',
      'reward': 'حفظ من كل أذى',
      'hadith':
      'من قالها حين يُمسي ثلاث مرات لم تضره حُمة تلك الليلة',
      'source': 'رواه مسلم',
      'type': 'shield',
      'icon': '🛡️',
      'target': 3,
      'color': 0xFF37474F,
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
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
      shields = prefs.getInt('shields') ?? 0;
      scales = prefs.getInt('scales') ?? 0;

      for (final key in progressCounters.keys) {
        progressCounters[key] = prefs.getInt('prog_$key') ?? 0;
      }
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
    await prefs.setInt('shields', shields);
    await prefs.setInt('scales', scales);

    for (final entry in progressCounters.entries) {
      await prefs.setInt('prog_${entry.key}', entry.value);
    }
  }

  void _addDeed(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastTappedIndex = index;
      final type = deeds[index]['type'] as String;
      final target = deeds[index]['target'] as int;

      if (type == 'hasana') {
        final val = deeds[index]['hasanaValue'] as int? ?? 10;

        if (target > 1) {
          progressCounters[type] = (progressCounters[type] ?? 0) + 1;
          hasanat += val;

          if (progressCounters[type]! >= target) {
            progressCounters[type] = 0;
            _showCompletionSnackbar(deeds[index]['reward'] as String);
          }
        } else {
          hasanat += val;
          _showCompletionSnackbar(deeds[index]['reward'] as String);
        }
      } else if (target > 1) {
        progressCounters[type] = (progressCounters[type] ?? 0) + 1;

        if (progressCounters[type]! >= target) {
          progressCounters[type] = 0;
          _incrementType(type);
          _showCompletionSnackbar(deeds[index]['reward'] as String);
        }
      } else {
        _incrementType(type);
        _showCompletionSnackbar(deeds[index]['reward'] as String);
      }
    });

    _bounceController.forward().then((_) => _bounceController.reverse());
    _saveData();
  }

  void _incrementType(String type) {
    switch (type) {
      case 'palm':
        palmTrees++;
        break;
      case 'palace':
        palaces++;
        break;
      case 'jewel':
        jewels++;
        break;
      case 'light':
        lights++;
        break;
      case 'door':
        doors++;
        break;
      case 'shield':
        shields++;
        break;
      case 'scale':
        scales++;
        break;
    }
  }

  void _showCompletionSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: _gold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _gold.withOpacity(0.3)),
          ),
          title: Text(
            'إعادة تعيين',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل تريد تصفير جميع العدادات؟',
            style: GoogleFonts.cairo(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  palmTrees = 0;
                  palaces = 0;
                  hasanat = 0;
                  jewels = 0;
                  lights = 0;
                  doors = 0;
                  shields = 0;
                  scales = 0;
                  progressCounters = {
                    'palace': 0,
                    'door': 0,
                    'jewel': 0,
                    'palm': 0,
                    'shield': 0,
                    'scale': 0,
                  };
                });
                _saveData();
                Navigator.pop(ctx);
              },
              child: Text(
                'تصفير',
                style: GoogleFonts.cairo(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  String _getTypeFromTitle(String title) {
    if (title.contains('نخل')) return 'palm';
    if (title.contains('قصور')) return 'palace';
    if (title.contains('كنوز')) return 'jewel';
    if (title.contains('أنوار')) return 'light';
    if (title.contains('أبواب')) return 'door';
    if (title.contains('دروع')) return 'shield';
    if (title.contains('موازين')) return 'scale';
    return 'hasana';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'حصاد الحسنات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: textColor,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh,
                    color: Colors.redAccent, size: 20),
                onPressed: _resetAll,
                tooltip: 'تصفير',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildStatsSection(isDark, textColor, isSmall),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'الأعمال والأجور',
                          style: GoogleFonts.cairo(
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${deeds.length} ذكر',
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDeedCard(
                      index,
                      isDark,
                      textColor,
                      subColor,
                      isSmall,
                    ),
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

  Widget _buildStatsSection(bool isDark, Color textColor, bool isSmall) {
    final stats = [
      {'title': 'نخلات', 'count': palmTrees, 'icon': '🌴', 'color': Colors.green},
      {'title': 'قصور', 'count': palaces, 'icon': '🏰', 'color': _gold},
      {'title': 'كنوز', 'count': jewels, 'icon': '💎', 'color': Colors.blue},
      {'title': 'أنوار', 'count': lights, 'icon': '✨', 'color': Colors.orange},
      {'title': 'أبواب', 'count': doors, 'icon': '🚪', 'color': Colors.brown},
      {'title': 'دروع', 'count': shields, 'icon': '🛡️', 'color': Colors.teal},
      {'title': 'موازين', 'count': scales, 'icon': '⚖️', 'color': Colors.purple},
      {'title': 'حسنات', 'count': hasanat, 'icon': '📿', 'color': Colors.cyan},
    ];

    final cardBg = isDark ? _bgCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : _gold.withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth < 280 ? 3 : 4;
          final spacing = isSmall ? 8.0 : 10.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (crossCount - 1)) / crossCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: stats.map((stat) {
              final type = _getTypeFromTitle(stat['title'] as String);
              final isAnimating = _lastTappedIndex != -1 &&
                  _lastTappedIndex < deeds.length &&
                  deeds[_lastTappedIndex]['type'] == type;

              return AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.scale(
                  scale: isAnimating ? _bounceAnim.value : 1.0,
                  child: child,
                ),
                child: SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: isSmall ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                      (stat['color'] as Color).withOpacity(isDark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (stat['color'] as Color).withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stat['icon'] as String,
                            style: TextStyle(fontSize: isSmall ? 18 : 22),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${stat['count']}',
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: stat['color'] as Color,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stat['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDeedCard(
      int index,
      bool isDark,
      Color textColor,
      Color subColor,
      bool isSmall,
      ) {
    final deed = deeds[index];
    final type = deed['type'] as String;
    final target = deed['target'] as int;
    final currentProgress = progressCounters[type] ?? 0;
    final progressValue = target > 1 ? (currentProgress / target) : 0.0;
    final accentColor = Color(deed['color'] as int);

    final cardBg = isDark ? _bgCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : accentColor.withOpacity(0.15);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
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
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الجائزة
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: isSmall ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(isDark ? 0.12 : 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withOpacity(0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  FittedBox(
                    child: Text(
                      deed['icon'] as String,
                      style: TextStyle(fontSize: isSmall ? 18 : 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      deed['reward'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: isSmall ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // المحتوى
            Padding(
              padding: EdgeInsets.all(isSmall ? 14 : 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الذكر
                  Text(
                    deed['title'] as String,
                    style: GoogleFonts.amiri(
                      fontSize: isSmall ? 18 : 22,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // الحديث
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : accentColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : accentColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          deed['hadith'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: isSmall ? 11 : 12,
                            color: subColor,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 12,
                              color: accentColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                deed['source'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 11,
                                  color: accentColor.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // التقدم والزر
                  Row(
                    children: [
                      if (target > 1) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'التقدم:',
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 11,
                                  color: subColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 7,
                                  backgroundColor: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                  valueColor:
                                  AlwaysStoppedAnimation(accentColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$currentProgress / $target',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      GestureDetector(
                        onTap: () => _addDeed(index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: target > 1 ? 16 : 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                              if (target <= 1) ...[
                                const SizedBox(width: 6),
                                FittedBox(
                                  child: Text(
                                    'إضافة',
                                    style: GoogleFonts.cairo(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmall ? 12 : 13,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}