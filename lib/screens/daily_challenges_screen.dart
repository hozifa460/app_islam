import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class DailyChallengesScreen extends StatefulWidget {
  final Color primaryColor;
  const DailyChallengesScreen({super.key, required this.primaryColor});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> with SingleTickerProviderStateMixin {
  int _totalXP = 0; // النقاط الإجمالية
  List<bool> _completedTasks = [false, false, false, false, false];

  late AnimationController _animController;
  late Animation<double> _xpAnim;

  // 🏆 نظام المستويات
  final List<Map<String, dynamic>> _ranks = [
    {'title': 'مبتدئ', 'minXP': 0, 'color': Colors.blueGrey},
    {'title': 'ملتزم', 'minXP': 100, 'color': Colors.blue},
    {'title': 'متدين', 'minXP': 300, 'color': Colors.purple},
    {'title': 'عبد الله', 'minXP': 600, 'color': Colors.amber.shade700},
  ];

  // 📝 التحديات اليومية المتاحة
  final List<Map<String, dynamic>> _todayTasks = [
    {'title': 'صلاة الفجر في وقتها', 'xp': 20, 'icon': Icons.wb_twilight},
    {'title': 'قراءة ورد القرآن (صفحتين)', 'xp': 15, 'icon': Icons.menu_book},
    {'title': 'أذكار الصباح والمساء', 'xp': 15, 'icon': Icons.auto_awesome},
    {'title': 'صلاة الضحى', 'xp': 10, 'icon': Icons.wb_sunny},
    {'title': 'ركعتي قيام الليل (الوتر)', 'xp': 25, 'icon': Icons.nights_stay},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _loadProgress();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // التحقق هل هو يوم جديد لتصفير المهام؟
    String lastDate = prefs.getString('last_challenge_date') ?? '';
    String today = DateTime.now().toString().substring(0, 10);

    setState(() {
      _totalXP = prefs.getInt('total_xp') ?? 0;

      if (lastDate == today) {
        // لو نفس اليوم، حمل حالة المهام
        _completedTasks[0] = prefs.getBool('task_0') ?? false;
        _completedTasks[1] = prefs.getBool('task_1') ?? false;
        _completedTasks[2] = prefs.getBool('task_2') ?? false;
        _completedTasks[3] = prefs.getBool('task_3') ?? false;
        _completedTasks[4] = prefs.getBool('task_4') ?? false;
      } else {
        // يوم جديد، صفر المهام واحفظ التاريخ
        prefs.setString('last_challenge_date', today);
        for(int i=0; i<5; i++) prefs.setBool('task_$i', false);
      }
    });

    _animateXP();
  }

  void _animateXP() {
    _xpAnim = Tween<double>(begin: 0, end: _calculateXPProgress()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0);
  }

  Future<void> _toggleTask(int index) async {
    if (_completedTasks[index]) return; // لا يمكن التراجع (لتحفيز التقدم)

    HapticFeedback.heavyImpact(); // اهتزاز عند الإنجاز

    final prefs = await SharedPreferences.getInstance();
    int gainedXP = _todayTasks[index]['xp'];

    setState(() {
      _completedTasks[index] = true;
      _totalXP += gainedXP;
    });

    await prefs.setBool('task_$index', true);
    await prefs.setInt('total_xp', _totalXP);

    _animateXP();
    _checkLevelUp();
  }

  // ✅ تحديد المستوى الحالي
  Map<String, dynamic> _getCurrentRank() {
    Map<String, dynamic> currentRank = _ranks[0];
    for (var rank in _ranks) {
      if (_totalXP >= rank['minXP']) {
        currentRank = rank;
      }
    }
    return currentRank;
  }

  // ✅ تحديد المستوى القادم
  Map<String, dynamic>? _getNextRank() {
    for (var rank in _ranks) {
      if (_totalXP < rank['minXP']) return rank;
    }
    return null; // وصل لأعلى مستوى
  }

  // حساب نسبة التقدم للمستوى التالي
  double _calculateXPProgress() {
    var current = _getCurrentRank();
    var next = _getNextRank();

    if (next == null) return 1.0; // ممتلئ دائماً إذا كان أعلى مستوى

    int currentMin = current['minXP'];
    int nextMin = next['minXP'];
    int xpInCurrentLevel = _totalXP - currentMin;
    int requiredXpForNext = nextMin - currentMin;

    return (xpInCurrentLevel / requiredXpForNext).clamp(0.0, 1.0);
  }

  // التهنئة عند الترقية
  void _checkLevelUp() {
    var next = _getNextRank();
    if (next != null && _totalXP >= next['minXP']) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 ترقية مباركة!'),
          content: Text('ما شاء الله! لقد ارتقيت إلى مقام "${next['title']}". استمر في الطاعات.', style: GoogleFonts.cairo()),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor), child: const Text('متابعة'))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentRank = _getCurrentRank();
    var nextRank = _getNextRank();
    Color rankColor = currentRank['color'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('تحديات اليوم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: rankColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ================== 1. الهيدر (المستوى والـ XP) ==================
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [rankColor, HSLColor.fromColor(rankColor).withLightness(0.3).toColor()],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: rankColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, size: 60, color: Colors.amberAccent),
                    const SizedBox(height: 10),
                    Text('المقام الحالي', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)),
                    Text(currentRank['title'], style: GoogleFonts.amiri(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 20),

                    // شريط التقدم (XP)
                    AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$_totalXP نقاط', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text(nextRank != null ? '${nextRank['minXP']} للمقام القادم' : 'أعلى مقام', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _xpAnim.value,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation(Colors.amberAccent),
                                ),
                              ),
                            ],
                          );
                        }
                    ),
                  ],
                ),
              ),
            ),

            // ================== 2. عنوان المهام ==================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: widget.primaryColor, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text('المهام اليومية', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // ================== 3. قائمة التحديات ==================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final task = _todayTasks[index];
                    final isDone = _completedTasks[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDone ? Colors.green.shade200 : Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDone ? Colors.green : widget.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(task['icon'], color: isDone ? Colors.white : widget.primaryColor),
                        ),
                        title: Text(
                            task['title'],
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: isDone ? Colors.green.shade800 : Colors.black87,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            )
                        ),
                        subtitle: Text('+${task['xp']} نقطة', style: GoogleFonts.cairo(color: Colors.amber.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                        trailing: isDone
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                            : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: widget.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _toggleTask(index),
                          child: Text('إنجاز', style: GoogleFonts.cairo(color: widget.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                  childCount: _todayTasks.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}