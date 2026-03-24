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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
          foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E2C)
            : Colors.white,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: small ? 86 : 100,
                height: small ? 86 : 100,
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: small ? 48 : 56,
                  color: widget.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ابدأ رحلتك النورانية',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: small ? 21 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'حدد وردك اليومي، وسنقوم بتنظيمه لك',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: small ? 13 : 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: EdgeInsets.all(small ? 18 : 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E2C)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'مقدار الورد اليومي',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: small ? 15 : 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _circleBtn(
                          Icons.remove,
                              () {
                            if (_setupPages > 1) {
                              setState(() => _setupPages--);
                            }
                          },
                          small: small,
                        ),
                        SizedBox(
                          width: small ? 90 : 100,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$_setupPages',
                                style: GoogleFonts.cairo(
                                  fontSize: small ? 34 : 40,
                                  fontWeight: FontWeight.bold,
                                  color: widget.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _circleBtn(
                          Icons.add,
                              () {
                            setState(() => _setupPages++);
                          },
                          small: small,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'صفحات',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: widget.primaryColor,
                        inactiveTrackColor: widget.primaryColor.withOpacity(0.15),
                        thumbColor: widget.primaryColor,
                        overlayColor: widget.primaryColor.withOpacity(0.12),
                        trackHeight: 5,
                      ),
                      child: Slider(
                        value: _setupPages.toDouble(),
                        min: 1,
                        max: 40,
                        onChanged: (val) {
                          setState(() => _setupPages = val.toInt());
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timelapse,
                            size: 18,
                            color: widget.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'ستختم القرآن خلال $daysToFinish يوماً',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: widget.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: small ? 13 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => _startKhatma(_setupPages, false),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'بدء الختمة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E2C)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleBtn(
      IconData icon,
      VoidCallback onTap, {
        bool small = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: small ? 46 : 52,
        height: small ? 46 : 52,
        decoration: BoxDecoration(
          color: widget.primaryColor.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: widget.primaryColor,
          size: small ? 24 : 28,
        ),
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

    final bgCard = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        final circleSize = small ? 170.0 : 200.0;
        final percentFont = small ? 38.0 : 48.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ================= الهيدر والدائرة =================
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  bottom: small ? 28 : 40,
                  top: small ? 18 : 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.primaryColor,
                      HSLColor.fromColor(widget.primaryColor)
                          .withLightness(0.3)
                          .toColor(),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
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
                            SizedBox(
                              width: circleSize,
                              height: circleSize,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E1E2C)
                                    : Colors.white,
                                strokeWidth: 12,
                              ),
                            ),
                            SizedBox(
                              width: circleSize,
                              height: circleSize,
                              child: CircularProgressIndicator(
                                value: value,
                                color: Colors.amberAccent,
                                strokeWidth: 12,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(value * 100).toInt()}%',
                                  style: GoogleFonts.cairo(
                                    fontSize: percentFont,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1E1E2C)
                                        : Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  'نسبة الإنجاز',
                                  style: GoogleFonts.cairo(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1E1E2C)
                                        : Colors.white,
                                    fontSize: small ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildStatCol(
                                'قرأت',
                                '${_currentPage - 1}',
                                'صفحة',
                                small: small,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E1E2C)
                                  : Colors.white,
                            ),
                            Expanded(
                              child: _buildStatCol(
                                'متبقي',
                                '$remainingPages',
                                'صفحة',
                                small: small,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= بطاقة الورد القادم =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book, color: widget.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'الورد القادم',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$_dailyPages صفحات',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: widget.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: _pageDetail(
                                'من',
                                _toArabicNum(_currentPage),
                                _surahNames[currentSurahIdx - 1],
                                widget.primaryColor,
                                isDark,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.grey.shade300,
                                size: 28,
                              ),
                            ),
                            Expanded(
                              child: _pageDetail(
                                'إلى',
                                _toArabicNum(endPage),
                                _surahNames[endSurahIdx - 1],
                                widget.primaryColor,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: _goToWird,
                                icon: Icon(
                                  Icons.chrome_reader_mode,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1E1E2C)
                                      : Colors.white,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'قراءة الورد من التطبيق',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF1E1E2C)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.green.shade500,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () => _advanceProgress(endPage + 1),
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade600,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'قرأته من مصحف ورقي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (_previousPage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.25),
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _undoProgress,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.undo_rounded,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'تراجع عن آخر ورد (إذا ضغطت بالخطأ)',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.cairo(
                                            color: Colors.orange.shade800,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCol(
      String label,
      String value,
      String sub, {
        bool small = false,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2C)
                : Colors.white,
            fontSize: small ? 11 : 12,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.cairo(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E2C)
                  : Colors.white,
              fontSize: small ? 22 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2C)
                : Colors.white,
            fontSize: small ? 11 : 12,
          ),
        ),
      ],
    );
  }

  Widget _pageDetail(
      String title,
      String page,
      String surah,
      Color primary,
      bool isDark,
      ) {
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ص $page',
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            surah,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}