import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/quran/surah_deatil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class KhatmaScreen extends StatefulWidget {
  final Color primaryColor;
  const KhatmaScreen({super.key, required this.primaryColor});

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  bool _isLoading = true;
  bool _hasActiveKhatma = false;

  int _currentPage = 1;
  int _dailyPages = 20;
  int _setupPages = 4;

  // ✅ التراجع
  int? _previousPage;

  final int _totalPages = 604;

  final List<int> _surahStartPages = [1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604];
  final List<String> _surahNames = ["الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس", "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasActiveKhatma = prefs.getBool('hasActiveKhatma') ?? false;
      _currentPage = prefs.getInt('khatmaCurrentPage') ?? 1;
      _dailyPages = prefs.getInt('khatmaDailyAmount') ?? 20;

      // جلب الصفحة السابقة إن وجدت للتراجع
      int savedPrev = prefs.getInt('khatmaPreviousPage') ?? -1;
      _previousPage = savedPrev != -1 ? savedPrev : null;

      _isLoading = false;
    });

    _playProgressAnimation();
  }

  // ✅ دالة لاختيار وقت التذكير
  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'اختر وقت التذكير اليومي للختمة',
      confirmText: 'حفظ',
      cancelText: 'إلغاء',
    );

    if (picked != null) {
      // تمرير 'picked' بدلاً من 'selectedTime'
      await NotificationService.scheduleKhatmaReminder(
        id: 1001, // رقم مميز لإشعار الختمة
        title: 'وقت قراءة القرآن',
        body: 'لا تنسَ قراءة وردك اليومي 📖',
        time: picked, // ✅ تم التعديل هنا
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم ضبط التذكير اليومي للختمة في ${picked.format(context)}',
                  style: GoogleFonts.cairo()),
              backgroundColor: Colors.green,
            )
        );
      }
    }
  }

  // ... داخل دالة build، عدل الـ AppBar ليصبح:


  void _playProgressAnimation() {
    double progress = _currentPage / _totalPages;
    _progressAnim = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0);
  }

  Future<void> _startKhatma(int amount, bool isJuz) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasActiveKhatma = true;
      _currentPage = 1;
      _previousPage = null; // لا يوجد تراجع عند البدء
      _dailyPages = isJuz ? amount * 20 : amount;
    });
    await prefs.setBool('hasActiveKhatma', true);
    await prefs.setInt('khatmaCurrentPage', 1);
    await prefs.setInt('khatmaDailyAmount', _dailyPages);
    await prefs.remove('khatmaPreviousPage');

    _playProgressAnimation();
  }

  Future<void> _resetKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasActiveKhatma = false;
      _currentPage = 1;
      _previousPage = null;
    });
    await prefs.remove('hasActiveKhatma');
    await prefs.remove('khatmaCurrentPage');
    await prefs.remove('khatmaDailyAmount');
    await prefs.remove('khatmaPreviousPage');
  }

  Future<void> _goToWird() async {
    int endPage = _currentPage + _dailyPages - 1;
    if (endPage > 604) endPage = 604;

    int surahIndex = _getSurahIndexForPage(_currentPage);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahName: _surahNames[surahIndex - 1],
          surahNumber: surahIndex,
          initialPage: _currentPage,
          targetPage: endPage,
        ),
      ),
    );

    if (result == true) {
      _advanceProgress(endPage + 1);
    }
  }

  // ✅ التقدم مع حفظ نقطة للرجوع
  Future<void> _advanceProgress(int newPage) async {
    if (newPage > 604) newPage = 604;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _previousPage = _currentPage; // نحفظ الصفحة القديمة قبل التحديث
      _currentPage = newPage;
    });

    await prefs.setInt('khatmaPreviousPage', _previousPage!);
    await prefs.setInt('khatmaCurrentPage', newPage);

    _playProgressAnimation();

    if (_currentPage >= 604) {
      _showCongratsDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إنجاز الورد بنجاح ✅', style: GoogleFonts.cairo()), backgroundColor: Colors.green));
    }
  }

  // ✅ ميزة التراجع الذكية
  Future<void> _undoProgress() async {
    if (_previousPage == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = _previousPage!;
      _previousPage = null; // لا يمكن التراجع مرتين متتاليتين
    });

    await prefs.setInt('khatmaCurrentPage', _currentPage);
    await prefs.remove('khatmaPreviousPage');

    _playProgressAnimation();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم التراجع عن الورد الأخير', style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
    );
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 ختمة مباركة'),
        content: const Text('تقبل الله طاعتك وبارك لك في وقتك وعملك. هل تريد بدء رحلة جديدة مع القرآن؟'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); _resetKhatma(); }, child: const Text('نعم، ختمة جديدة')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لاحقاً', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  int _getSurahIndexForPage(int page) {
    int index = 1;
    for (int i = 0; i < _surahStartPages.length; i++) {
      if (page >= _surahStartPages[i]) index = i + 1;
      else break;
    }
    return index;
  }

  String _toArabicNum(int n) {
    const nums = {'0':'٠','1':'١','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF151515) : Colors.grey.shade50,
        appBar: AppBar(
          title: Text('رحلة الختمة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [

            if (_hasActiveKhatma)
              IconButton(
                icon: const Icon(Icons.alarm_add_rounded),
                tooltip: 'تذكير يومي للورد',
                onPressed: _selectReminderTime,
              ),

            if (_hasActiveKhatma)
              IconButton(
                icon: const Icon(Icons.settings_backup_restore_rounded),
                tooltip: 'إعادة الختمة من البداية',
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('تنبيه', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        content: Text('هل أنت متأكد أنك تريد تصفير الختمة والبدء من جديد؟', style: GoogleFonts.cairo()),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                          TextButton(onPressed: () { Navigator.pop(ctx); _resetKhatma(); }, child: const Text('نعم، متأكد', style: TextStyle(color: Colors.red))),
                        ],
                      )
                  );
                },
              )
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: widget.primaryColor))
            : _hasActiveKhatma
            ? _buildDashboard(isDark)
            : _buildSetupScreen(),
      ),
    );
  }

  // ======================================================
  // 1️⃣ شاشة إعداد الختمة
  // ======================================================
  Widget _buildSetupScreen() {
    int daysToFinish = (_totalPages / _setupPages).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.auto_stories_rounded, size: 80, color: widget.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text('ابدأ رحلتك النورانية', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('حدد وردك اليومي، وسنقوم بتنظيمه لك', style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Text('مقدار الورد اليومي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleBtn(Icons.remove, () { if (_setupPages > 1) setState(() => _setupPages--); }),
                    Container(width: 100, alignment: Alignment.center, child: Text('$_setupPages', style: GoogleFonts.cairo(fontSize: 40, fontWeight: FontWeight.bold, color: widget.primaryColor))),
                    _circleBtn(Icons.add, () { setState(() => _setupPages++); }),
                  ],
                ),
                Text('صفحات', style: GoogleFonts.cairo(color: Colors.grey)),
                const SizedBox(height: 20),
                Slider(
                  value: _setupPages.toDouble(), min: 1, max: 40, activeColor: widget.primaryColor,
                  onChanged: (val) => setState(() => _setupPages = val.toInt()),
                ),
                const Divider(height: 40),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timelapse, size: 18, color: widget.primaryColor),
                      const SizedBox(width: 8),
                      Text('ستختم القرآن خلال $daysToFinish يوماً', style: GoogleFonts.cairo(color: widget.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
              onPressed: () => _startKhatma(_setupPages, false),
              child: Text('بدء الختمة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: widget.primaryColor, size: 28),
      ),
    );
  }

  // ======================================================
  // 2️⃣ لوحة التحكم الاحترافية (Dashboard)
  // ======================================================
  Widget _buildDashboard(bool isDark) {
    int endPage = _currentPage + _dailyPages - 1;
    if (endPage > _totalPages) endPage = _totalPages;
    int remainingPages = _totalPages - _currentPage + 1;

    int currentSurahIdx = _getSurahIndexForPage(_currentPage);
    int endSurahIdx = _getSurahIndexForPage(endPage);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ================= الهيدر والدائرة =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [widget.primaryColor, HSLColor.fromColor(widget.primaryColor).withLightness(0.3).toColor()],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progressAnim.value),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 200, height: 200, child: CircularProgressIndicator(value: 1.0, color: Colors.white.withOpacity(0.1), strokeWidth: 12)),
                        SizedBox(width: 200, height: 200, child: CircularProgressIndicator(value: value, color: Colors.amberAccent, strokeWidth: 12, strokeCap: StrokeCap.round)),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(value * 100).toInt()}%', style: GoogleFonts.cairo(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                            Text('نسبة الإنجاز', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol('قرأت', '${_currentPage - 1}', 'صفحة'),
                    Container(width: 1, height: 40, color: Colors.white30),
                    _buildStatCol('متبقي', '$remainingPages', 'صفحة'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= بطاقة الورد اليومي =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // رأس البطاقة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book, color: widget.primaryColor),
                            const SizedBox(width: 8),
                            Text('الورد القادم', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text('$_dailyPages صفحات', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: widget.primaryColor)),
                        ),
                      ],
                    ),
                  ),

                  // تفاصيل الورد
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _pageDetail('من', _toArabicNum(_currentPage), _surahNames[currentSurahIdx - 1], widget.primaryColor),
                        Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade300, size: 30),
                        _pageDetail('إلى', _toArabicNum(endPage), _surahNames[endSurahIdx - 1], widget.primaryColor),
                      ],
                    ),
                  ),

                  // الأزرار
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity, height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2),
                            onPressed: _goToWird,
                            icon: const Icon(Icons.chrome_reader_mode, color: Colors.white),
                            label: Text('قراءة الورد من التطبيق', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.green.shade500, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            onPressed: () => _advanceProgress(endPage + 1),
                            icon: Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                            label: Text('قرأته من مصحف ورقي', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ),
                        ),

                        // ✅ زر التراجع (يظهر فقط إذا كان هناك تقدم سابق)
                        if (_previousPage != null) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _undoProgress,
                            icon: const Icon(Icons.undo, color: Colors.orange, size: 18),
                            label: Text('تراجع عن آخر ورد (أخطأت بالضغط)', style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12, decoration: TextDecoration.underline)),
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, String sub) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
        Text(value, style: GoogleFonts.cairo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(sub, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _pageDetail(String title, String page, String surah, Color primary) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text('ص $page', style: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(surah, style: GoogleFonts.cairo(color: primary, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}