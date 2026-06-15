import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:islamic_app/screens/quran/surah_detail/surah_deatil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../languages/app_localizations.dart';
import '../../services/notification_service.dart';
import '../auth/services/auth_service.dart';
import 'widgets/khatma_setup_view.dart';
import 'widgets/khatma_dashboard_view.dart';
import 'widgets/khatma_dialogs.dart';

class KhatmaScreen extends StatefulWidget {
  final Color primaryColor;
  const KhatmaScreen({super.key, required this.primaryColor});

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen>
    with TickerProviderStateMixin {
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

  int? _previousPage;

  int _consecutiveDays = 0;
  DateTime? _startDate;
  int _totalPagesRead = 0;

  final int _totalPages = 604;

  final List<int> surahStartPages = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602,
    602, 602, 603, 603, 603, 604, 604, 604
  ];

  final List<String> surahNames = [
    "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام",
    "الأعراف", "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد",
    "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه",
    "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء",
    "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
    "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت",
    "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح",
    "الحجرات", "ق", "الذاريات", "الطور", "النجم", "القمر", "الرحمن",
    "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة", "الصف",
    "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك",
    "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر",
    "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس",
    "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق",
    "الأعلى", "الغاشية", "الفجر", "البلد", "الشمس", "الليل", "الضحى",
    "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات",
    "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون",
    "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      _initData();
    }
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _hasActiveKhatma = prefs.getBool('hasActiveKhatma') ?? false;
      _currentPage = prefs.getInt('khatmaCurrentPage') ?? 1;
      _dailyPages = prefs.getInt('khatmaDailyAmount') ?? 20;
      _consecutiveDays = prefs.getInt('khatmaConsecutiveDays') ?? 0;
      _totalPagesRead = prefs.getInt('khatmaTotalPagesRead') ?? 0;

      final startDateStr = prefs.getString('khatmaStartDate');
      if (startDateStr != null) {
        _startDate = DateTime.parse(startDateStr);
      }

      final savedPrev = prefs.getInt('khatmaPreviousPage') ?? -1;
      _previousPage = savedPrev != -1 ? savedPrev : null;

      _isLoading = false;
    });

    _playProgressAnimation();
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    try {
      final cloudData = await auth.loadProgress('khatma');
      if (cloudData == null || cloudData is! Map || !mounted) return;

      final cloudPage = cloudData['currentPage'] as int? ?? 1;
      if (cloudPage > _currentPage) {
        setState(() {
          _hasActiveKhatma = cloudData['hasActive'] as bool? ?? false;
          _currentPage = cloudPage;
          _dailyPages = cloudData['dailyPages'] as int? ?? 20;
          _consecutiveDays = cloudData['consecutiveDays'] as int? ?? 0;
          _totalPagesRead = cloudData['totalPagesRead'] as int? ?? 0;

          final startStr = cloudData['startDate'] as String?;
          if (startStr != null) {
            _startDate = DateTime.tryParse(startStr);
          }
        });

        final prefs = await SharedPreferences.getInstance();
        await _saveLocal(prefs);
        _playProgressAnimation();
      }
    } catch (_) {}
  }

  Future<void> _saveLocal(SharedPreferences prefs) async {
    await prefs.setBool('hasActiveKhatma', _hasActiveKhatma);
    await prefs.setInt('khatmaCurrentPage', _currentPage);
    await prefs.setInt('khatmaDailyAmount', _dailyPages);
    await prefs.setInt('khatmaConsecutiveDays', _consecutiveDays);
    await prefs.setInt('khatmaTotalPagesRead', _totalPagesRead);
    if (_startDate != null) {
      await prefs.setString('khatmaStartDate', _startDate!.toIso8601String());
    }
    if (_previousPage != null) {
      await prefs.setInt('khatmaPreviousPage', _previousPage!);
    }
  }

  Future<void> _saveCloud() async {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    await auth.saveProgress('khatma', {
      'hasActive': _hasActiveKhatma,
      'currentPage': _currentPage,
      'dailyPages': _dailyPages,
      'consecutiveDays': _consecutiveDays,
      'totalPagesRead': _totalPagesRead,
      'startDate': _startDate?.toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  Future<void> startKhatma(int amount, bool isJuz) async {
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

    await _saveLocal(prefs);
    await _saveCloud();

    _playProgressAnimation();
  }

  // ═══ التذكير ═══
  Future<void> selectReminderTime() async {
    final tr = context.tr; // ← الترجمة

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: tr.khatmaSelectTime, // ← مترجم
      confirmText: tr.khatmaSave, // ← مترجم
      cancelText: tr.khatmaCancel, // ← مترجم
    );

    if (picked != null) {
      await NotificationService.scheduleKhatmaReminder(
        id: 1001,
        title: tr.khatmaReminderTitle, // ← مترجم
        body: tr.khatmaReminderBody, // ← مترجم
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
                    tr.khatmaReminderSet(picked.format(context)), // ← مترجم
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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

  Future<void> resetKhatma() async {
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

    final auth = context.read<AuthService>();
    if (!(auth.user?.isGuest ?? true)) {
      await auth.saveProgress('khatma', {
        'hasActive': false,
        'currentPage': 1,
        'dailyPages': 20,
        'consecutiveDays': 0,
        'totalPagesRead': 0,
        'startDate': null,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> goToWird() async {
    int endPage = _currentPage + _dailyPages - 1;
    if (endPage > 604) endPage = 604;

    int surahIndex = getSurahIndexForPage(_currentPage);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahName: surahNames[surahIndex - 1],
          surahNumber: surahIndex,
          initialPage: _currentPage,
          targetPage: endPage,
        ),
      ),
    );

    if (result == true) {
      advanceProgress(endPage + 1);
    }
  }

  Future<void> advanceProgress(int newPage) async {
    if (newPage > 604) newPage = 604;
    final prefs = await SharedPreferences.getInstance();

    final pagesCompleted = newPage - _currentPage;

    setState(() {
      _previousPage = _currentPage;
      _currentPage = newPage;
      _consecutiveDays++;
      _totalPagesRead += pagesCompleted;
    });

    await _saveLocal(prefs);
    await _saveCloud();

    _playProgressAnimation();

    if (_currentPage >= 604) {
      if (mounted) {
        KhatmaDialogs.showCongratsDialog(
          context: context,
          primaryColor: widget.primaryColor,
          onReset: resetKhatma,
        );
      }
    } else {
      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    final tr = context.tr; // ← الترجمة

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
              child: const Icon(Icons.celebration,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.khatmaWirdDone, // ← مترجم
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  Text(tr.khatmaKeepGoing, // ← مترجم
                      style: GoogleFonts.cairo(fontSize: 12)),
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

  Future<void> undoProgress() async {
    if (_previousPage == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = _previousPage!;
      _previousPage = null;
      _consecutiveDays = (_consecutiveDays - 1).clamp(0, 9999);
    });

    await prefs.setInt('khatmaCurrentPage', _currentPage);
    await prefs.remove('khatmaPreviousPage');
    await _saveCloud();

    _playProgressAnimation();

    if (mounted) {
      final tr = context.tr; // ← الترجمة

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.undo, color: Colors.white),
              const SizedBox(width: 12),
              Text(tr.khatmaUndone, // ← مترجم
                  style: GoogleFonts.cairo()),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  int getSurahIndexForPage(int page) {
    int index = 1;
    for (int i = 0; i < surahStartPages.length; i++) {
      if (page >= surahStartPages[i])
        index = i + 1;
      else
        break;
    }
    return index;
  }

  int getCurrentJuz() {
    return ((_currentPage - 1) ~/ 20) + 1;
  }

  String toArabicNum(int n) {
    const nums = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
    };
    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  int getEstimatedMinutes() => _dailyPages;

  int getDaysRemaining() {
    int remaining = _totalPages - _currentPage + 1;
    return (remaining / _dailyPages).ceil();
  }

  void updateSetupPages(int pages) {
    setState(() {
      _setupPages = pages;
      _selectedPreset = -1;
    });
  }

  void selectPreset(int index) {
    setState(() {
      _selectedPreset = index;
      // ═══ استخدام القيم من khatmaPresets المترجمة ═══
      final tr = context.tr;
      final presets = tr.khatmaPresets;
      _setupPages = int.parse(presets[index]['pages']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr; // ← الترجمة

    // ═══ بناء الخطط السريعة من الترجمة ═══
    final presets = tr.khatmaPresets.map((p) {
      final days = int.parse(p['days']!);
      final pages = int.parse(p['pages']!);
      return {
        'days': days,
        'pages': pages,
        'icon': _getPresetIcon(days),
        'label': p['label'],
      };
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        body: _isLoading
            ? Center(
            child:
            CircularProgressIndicator(color: widget.primaryColor))
            : _hasActiveKhatma
            ? KhatmaDashboardView(
          primaryColor: widget.primaryColor,
          currentPage: _currentPage,
          dailyPages: _dailyPages,
          totalPages: _totalPages,
          previousPage: _previousPage,
          surahNames: surahNames,
          getSurahIndexForPage: getSurahIndexForPage,
          getCurrentJuz: getCurrentJuz,
          toArabicNum: toArabicNum,
          getEstimatedMinutes: getEstimatedMinutes,
          getDaysRemaining: getDaysRemaining,
          onGoToWird: goToWird,
          onAdvanceProgress: advanceProgress,
          onUndoProgress: undoProgress,
          onSelectReminderTime: selectReminderTime,
          onShowResetDialog: () {
            KhatmaDialogs.showResetDialog(
              context: context,
              onReset: resetKhatma,
            );
          },
        )
            : KhatmaSetupView(
          primaryColor: widget.primaryColor,
          setupPages: _setupPages,
          selectedPreset: _selectedPreset,
          totalPages: _totalPages,
          presets: presets,
          pulseAnim: _pulseAnim,
          onPresetSelected: selectPreset,
          onPagesChanged: updateSetupPages,
          onStartKhatma: startKhatma,
        ),
      ),
    );
  }

  // ═══ أيقونات الخطط ═══
  IconData _getPresetIcon(int days) {
    if (days == 30) return Icons.calendar_month;
    if (days == 15) return Icons.speed;
    if (days == 10) return Icons.flash_on;
    if (days == 7) return Icons.rocket_launch;
    return Icons.schedule;
  }
}