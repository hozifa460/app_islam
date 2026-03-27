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

class _KhatmaScreenState extends State<KhatmaScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;

  bool _isLoading = true;
  bool _hasActiveKhatma = false;

  int _currentPage = 1;
  int _dailyPages = 20;
  int _setupPages = 4;
  int _selectedPreset = -1;

  // ✅ التراجع
  int? _previousPage;

  // ✅ إحصائيات إضافية
  int _consecutiveDays = 0;
  DateTime? _startDate;
  int _totalPagesRead = 0;

  final int _totalPages = 604;
  final int _totalJuz = 30;

  final List<int> _surahStartPages = [1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604];
  final List<String> _surahNames = ["الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس", "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"];

  // ✅ خيارات الختمة السريعة
  final List<Map<String, dynamic>> _presets = [
    {'days': 30, 'pages': 20, 'icon': Icons.calendar_month, 'label': 'شهر'},
    {'days': 15, 'pages': 40, 'icon': Icons.speed, 'label': 'أسبوعين'},
    {'days': 10, 'pages': 60, 'icon': Icons.flash_on, 'label': '10 أيام'},
    {'days': 7, 'pages': 86, 'icon': Icons.rocket_launch, 'label': 'أسبوع'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasActiveKhatma = prefs.getBool('hasActiveKhatma') ?? false;
      _currentPage = prefs.getInt('khatmaCurrentPage') ?? 1;
      _dailyPages = prefs.getInt('khatmaDailyAmount') ?? 20;
      _consecutiveDays = prefs.getInt('khatmaConsecutiveDays') ?? 0;
      _totalPagesRead = prefs.getInt('khatmaTotalPagesRead') ?? 0;

      String? startDateStr = prefs.getString('khatmaStartDate');
      if (startDateStr != null) {
        _startDate = DateTime.parse(startDateStr);
      }

      int savedPrev = prefs.getInt('khatmaPreviousPage') ?? -1;
      _previousPage = savedPrev != -1 ? savedPrev : null;

      _isLoading = false;
    });

    _playProgressAnimation();
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'اختر وقت التذكير اليومي للختمة',
      confirmText: 'حفظ',
      cancelText: 'إلغاء',
    );

    if (picked != null) {
      await NotificationService.scheduleKhatmaReminder(
        id: 1001,
        title: 'وقت قراءة القرآن 📖',
        body: 'حان موعد وردك اليومي، لا تفوّت أجر القراءة',
        time: picked,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تم ضبط التذكير في ${picked.format(context)}',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

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
      _previousPage = null;
      _dailyPages = isJuz ? amount * 20 : amount;
      _startDate = DateTime.now();
      _consecutiveDays = 0;
      _totalPagesRead = 0;
    });
    await prefs.setBool('hasActiveKhatma', true);
    await prefs.setInt('khatmaCurrentPage', 1);
    await prefs.setInt('khatmaDailyAmount', _dailyPages);
    await prefs.setString('khatmaStartDate', _startDate!.toIso8601String());
    await prefs.setInt('khatmaConsecutiveDays', 0);
    await prefs.setInt('khatmaTotalPagesRead', 0);
    await prefs.remove('khatmaPreviousPage');

    _playProgressAnimation();
  }

  Future<void> _resetKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasActiveKhatma = false;
      _currentPage = 1;
      _previousPage = null;
      _startDate = null;
      _consecutiveDays = 0;
      _totalPagesRead = 0;
    });
    await prefs.remove('hasActiveKhatma');
    await prefs.remove('khatmaCurrentPage');
    await prefs.remove('khatmaDailyAmount');
    await prefs.remove('khatmaPreviousPage');
    await prefs.remove('khatmaStartDate');
    await prefs.remove('khatmaConsecutiveDays');
    await prefs.remove('khatmaTotalPagesRead');
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

  Future<void> _advanceProgress(int newPage) async {
    if (newPage > 604) newPage = 604;
    final prefs = await SharedPreferences.getInstance();

    int pagesCompleted = newPage - _currentPage;

    setState(() {
      _previousPage = _currentPage;
      _currentPage = newPage;
      _consecutiveDays++;
      _totalPagesRead += pagesCompleted;
    });

    await prefs.setInt('khatmaPreviousPage', _previousPage!);
    await prefs.setInt('khatmaCurrentPage', newPage);
    await prefs.setInt('khatmaConsecutiveDays', _consecutiveDays);
    await prefs.setInt('khatmaTotalPagesRead', _totalPagesRead);

    _playProgressAnimation();

    if (_currentPage >= 604) {
      _showCongratsDialog();
    } else {
      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.celebration, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أحسنت! تم إنجاز الورد ✅', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  Text('استمر في المحافظة على وردك', style: GoogleFonts.cairo(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _undoProgress() async {
    if (_previousPage == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = _previousPage!;
      _previousPage = null;
    });

    await prefs.setInt('khatmaCurrentPage', _currentPage);
    await prefs.remove('khatmaPreviousPage');

    _playProgressAnimation();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.undo, color: Colors.white),
            const SizedBox(width: 12),
            Text('تم التراجع عن الورد الأخير', style: GoogleFonts.cairo()),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.amber.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                '🎉 ختمة مباركة!',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'تقبل الله طاعتك وبارك لك في وقتك وعملك\nأتممت قراءة القرآن الكريم كاملاً',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetKhatma();
                  },
                  child: Text('بدء ختمة جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('لاحقاً', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
            ],
          ),
        ),
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

  int _getCurrentJuz() {
    return ((_currentPage - 1) ~/ 20) + 1;
  }

  int _getCurrentHizb() {
    return ((_currentPage - 1) ~/ 10) + 1;
  }

  String _toArabicNum(int n) {
    const nums = {'0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤', '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'};
    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  int _getEstimatedMinutes() {
    // تقدير: حوالي دقيقة لكل صفحة
    return _dailyPages;
  }

  int _getDaysRemaining() {
    int remaining = _totalPages - _currentPage + 1;
    return (remaining / _dailyPages).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: widget.primaryColor))
            : _hasActiveKhatma
            ? _buildDashboard(isDark)
            : _buildSetupScreen(isDark),
      ),
    );
  }

  // ======================================================
  // 1️⃣ شاشة إعداد الختمة المحسّنة
  // ======================================================
  Widget _buildSetupScreen(bool isDark) {
    int daysToFinish = (_totalPages / _setupPages).ceil();
    final bgCard = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ✅ Header مخصص
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: widget.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final availableHeight = constraints.maxHeight - topPadding - kToolbarHeight;
                final isSmall = availableHeight < 100;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        widget.primaryColor,
                        HSLColor.fromColor(widget.primaryColor).withLightness(0.25).toColor(),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: kToolbarHeight,
                        left: 16,
                        right: 16,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                padding: EdgeInsets.all(isSmall ? 12 : 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  size: isSmall ? 30 : 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ابدأ رحلتك مع القرآن',
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اختر خطتك واستمر في الطاعة',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ الاختيارات السريعة
                Text(
                  'خطط سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_presets.length, (index) {
                        final preset = _presets[index];
                        final isSelected = _selectedPreset == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPreset = index;
                              _setupPages = preset['pages'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: itemWidth,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.primaryColor : bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? widget.primaryColor : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: widget.primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  preset['icon'],
                                  size: 32,
                                  color: isSelected ? Colors.white : widget.primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  preset['label'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                Text(
                                  '${preset['pages']} صفحة/يوم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ✅ التخصيص اليدوي
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: widget.primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            'تخصيص يدوي',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleBtn(Icons.remove, () {
                            if (_setupPages > 1) {
                              setState(() {
                                _setupPages--;
                                _selectedPreset = -1;
                              });
                            }
                          }),
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  '$_setupPages',
                                  style: GoogleFonts.cairo(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: widget.primaryColor,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'صفحة يومياً',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _circleBtn(Icons.add, () {
                            setState(() {
                              _setupPages++;
                              _selectedPreset = -1;
                            });
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: widget.primaryColor,
                          inactiveTrackColor: widget.primaryColor.withOpacity(0.15),
                          thumbColor: widget.primaryColor,
                          overlayColor: widget.primaryColor.withOpacity(0.12),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _setupPages.toDouble().clamp(1, 100),
                          min: 1,
                          max: 100,
                          onChanged: (val) {
                            setState(() {
                              _setupPages = val.toInt();
                              _selectedPreset = -1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ ملخص الخطة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primaryColor.withOpacity(0.1),
                        widget.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: widget.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ملخص الخطة',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: widget.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _summaryRow(Icons.calendar_today, 'مدة الختمة', '$daysToFinish يوم'),
                      const SizedBox(height: 10),
                      _summaryRow(Icons.timer_outlined, 'وقت القراءة اليومي', '≈ $_setupPages دقيقة'),
                      const SizedBox(height: 10),
                      _summaryRow(Icons.auto_stories, 'عدد الصفحات الكلي', '٦٠٤ صفحة'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ✅ زر البدء
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: widget.primaryColor.withOpacity(0.4),
                    ),
                    onPressed: () => _startKhatma(_setupPages, false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'ابدأ الختمة الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 280;

        return Row(
          children: [
            Icon(
              icon,
              size: isSmall ? 16 : 18,
              color: widget.primaryColor.withOpacity(0.7),
            ),
            SizedBox(width: isSmall ? 8 : 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: isSmall ? 12 : 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 12 : 14,
                    color: widget.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // حجم ديناميكي بناءً على عرض الشاشة
        final screenWidth = MediaQuery.of(context).size.width;
        final size = screenWidth < 360 ? 44.0 : 52.0;
        final iconSize = screenWidth < 360 ? 24.0 : 28.0;

        return Material(
          color: widget.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size / 2),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(icon, color: widget.primaryColor, size: iconSize),
            ),
          ),
        );
      },
    );
  }

  // ======================================================
  // 2️⃣ لوحة التحكم الاحترافية (Dashboard)
  // ======================================================
  Widget _buildDashboard(bool isDark) {
    int endPage = _currentPage + _dailyPages - 1;
    if (endPage > _totalPages) endPage = _totalPages;
    int remainingPages = _totalPages - _currentPage + 1;
    double progress = (_currentPage - 1) / _totalPages;

    int currentSurahIdx = _getSurahIndexForPage(_currentPage);
    int endSurahIdx = _getSurahIndexForPage(endPage);
    int currentJuz = _getCurrentJuz();

    final bgCard = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ✅ Header مع الدائرة
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: widget.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
              tooltip: 'تذكير يومي',
              onPressed: _selectReminderTime,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'reset') {
                  _showResetDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, color: Colors.red),
                      const SizedBox(width: 10),
                      Text('إعادة الختمة', style: GoogleFonts.cairo()),
                    ],
                  ),
                ),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final totalHeight = constraints.maxHeight;
                final contentHeight = totalHeight - topPadding - kToolbarHeight;
                final screenWidth = constraints.maxWidth;

                // أحجام ديناميكية
                final isNarrow = screenWidth < 360;
                final isTight = contentHeight < 200;

                final circleSize = isTight
                    ? 100.0
                    : isNarrow
                    ? 120.0
                    : 150.0;

                final percentFont = isTight
                    ? 24.0
                    : isNarrow
                    ? 30.0
                    : 36.0;

                final strokeW = isTight ? 8.0 : (isNarrow ? 10.0 : 14.0);
                final juzFont = isTight ? 9.0 : (isNarrow ? 10.0 : 12.0);
                final gapAfterCircle = isTight ? 8.0 : (isNarrow ? 12.0 : 18.0);

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        widget.primaryColor,
                        HSLColor.fromColor(widget.primaryColor)
                            .withLightness(0.25)
                            .toColor(),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: kToolbarHeight),
                      child: ClipRect(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrow ? 12 : 20,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: screenWidth - (isNarrow ? 24 : 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // دائرة التقدم
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: progress),
                                    duration: const Duration(milliseconds: 1500),
                                    curve: Curves.easeOutExpo,
                                    builder: (context, value, child) {
                                      return SizedBox(
                                        width: circleSize,
                                        height: circleSize,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox.expand(
                                              child: CircularProgressIndicator(
                                                value: 1.0,
                                                strokeWidth: strokeW,
                                                backgroundColor:
                                                Colors.white.withOpacity(0.2),
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            SizedBox.expand(
                                              child: CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: strokeW,
                                                backgroundColor: Colors.transparent,
                                                valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                                    Colors.amberAccent),
                                                strokeCap: StrokeCap.round,
                                              ),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${(value * 100).toInt()}%',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: percentFont,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      'الجزء ${_toArabicNum(currentJuz)}',
                                                      style: GoogleFonts.cairo(
                                                        fontSize: juzFont,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: gapAfterCircle),

                                  // الإحصائيات السريعة
                                  _buildDashboardStats(remainingPages, isNarrow, isTight),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ بطاقة الورد اليومي
                Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // العنوان
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 300;

                            return Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isSmall ? 8 : 10),
                                  decoration: BoxDecoration(
                                    color: widget.primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: widget.primaryColor,
                                    size: isSmall ? 18 : 22,
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          'ورد اليوم',
                                          style: GoogleFonts.cairo(
                                            fontSize: isSmall ? 14 : 16,
                                            fontWeight: FontWeight.bold,
                                            color: textMain,
                                          ),
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          '$_dailyPages صفحة • ≈ ${_getEstimatedMinutes()} دقيقة',
                                          style: GoogleFonts.cairo(
                                            fontSize: isSmall ? 10 : 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // تفاصيل الورد
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 280;

                            return Row(
                              children: [
                                Expanded(
                                  child: _pageCard('البداية', _currentPage, currentSurahIdx, isDark),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 12),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: widget.primaryColor,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                                Expanded(
                                  child: _pageCard('النهاية', endPage, endSurahIdx, isDark),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // الأزرار
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 300;

                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: isSmall ? 48 : 54,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: _goToWird,
                                    icon: Icon(
                                      Icons.auto_stories,
                                      color: Colors.white,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'قراءة الورد',
                                        style: GoogleFonts.cairo(
                                          fontSize: isSmall ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmall ? 8 : 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: isSmall ? 44 : 50,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.green.shade400, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () => _advanceProgress(endPage + 1),
                                    icon: Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green.shade600,
                                      size: isSmall ? 18 : 22,
                                    ),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'قرأته من المصحف',
                                        style: GoogleFonts.cairo(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_previousPage != null) ...[
                                  SizedBox(height: isSmall ? 8 : 12),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: TextButton.icon(
                                      onPressed: _undoProgress,
                                      icon: Icon(
                                        Icons.undo,
                                        size: isSmall ? 16 : 18,
                                        color: Colors.orange,
                                      ),
                                      label: Text(
                                        'تراجع عن آخر ورد',
                                        style: GoogleFonts.cairo(
                                          color: Colors.orange,
                                          fontSize: isSmall ? 11 : 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ الإحصائيات التفصيلية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: widget.primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                'إحصائيات الختمة',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _statRow(Icons.auto_stories, 'الصفحة الحالية', '${_toArabicNum(_currentPage)} / ٦٠٤', isDark),
                      const SizedBox(height: 14),
                      _statRow(Icons.view_agenda, 'الجزء الحالي', 'الجزء ${_toArabicNum(currentJuz)} من ٣٠', isDark),
                      const SizedBox(height: 14),
                      _statRow(Icons.book, 'السورة الحالية', _surahNames[currentSurahIdx - 1], isDark),
                      const SizedBox(height: 14),
                      _statRow(Icons.calendar_today, 'أيام متبقية', '${_getDaysRemaining()} يوم', isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStats(int remainingPages, bool isNarrow, bool isTight) {
    final statFontSize = isTight ? 16.0 : (isNarrow ? 18.0 : 22.0);
    final labelFontSize = isTight ? 9.0 : (isNarrow ? 10.0 : 12.0);
    final dividerHeight = isTight ? 24.0 : (isNarrow ? 30.0 : 40.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 8 : 16,
        vertical: isTight ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _dashStatItem(
                'قرأت',
                '${_currentPage - 1}',
                'صفحة',
                statFontSize,
                labelFontSize,
              ),
            ),
            VerticalDivider(
              color: Colors.white30,
              thickness: 1,
              width: isNarrow ? 16 : 24,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _dashStatItem(
                'متبقي',
                '$remainingPages',
                'صفحة',
                statFontSize,
                labelFontSize,
              ),
            ),
            VerticalDivider(
              color: Colors.white30,
              thickness: 1,
              width: isNarrow ? 16 : 24,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _dashStatItem(
                'الأيام',
                '${_getDaysRemaining()}',
                'متبقية',
                statFontSize,
                labelFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashStatItem(
      String label,
      String value,
      String unit,
      double valueFontSize,
      double labelFontSize,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: labelFontSize,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            unit,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: labelFontSize,
            ),
          ),
        ),
      ],
    );
  }


  Widget _pageCard(String label, int page, int surahIdx, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 120;

        return Container(
          padding: EdgeInsets.all(isSmall ? 10 : 14),
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.cairo(fontSize: isSmall ? 10 : 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'ص ${_toArabicNum(page)}',
                  style: GoogleFonts.amiri(
                    fontSize: isSmall ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth - 20),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _surahNames[surahIdx - 1],
                    style: GoogleFonts.cairo(
                      fontSize: isSmall ? 10 : 11,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(IconData icon, String label, String value, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 300;

        return Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 6 : 8),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: isSmall ? 16 : 18, color: widget.primaryColor),
            ),
            SizedBox(width: isSmall ? 10 : 14),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade600,
                  fontSize: isSmall ? 12 : 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 12 : 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 10),
            Text('تأكيد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إعادة الختمة؟ سيتم مسح كل التقدم الحالي.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _resetKhatma();
            },
            child: Text('إعادة', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}