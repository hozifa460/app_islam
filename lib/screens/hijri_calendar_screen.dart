import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HijriCalendarScreen extends StatefulWidget {
  final Color primaryColor;

  const HijriCalendarScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _starController;
  late Animation<Offset> _slideAnimation;

  int _factOffset = 0;

  static const List<String> _weekDays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];

  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> _hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const List<String> _islamicFacts = [
    'التقويم الهجري يبدأ من هجرة النبي ﷺ من مكة إلى المدينة.',
    'شهر رمضان هو الشهر التاسع في التقويم الهجري.',
    'الأشهر الحرم هي: ذو القعدة، ذو الحجة، محرم، رجب.',
    'ليلة القدر خير من ألف شهر، وتلتمس في العشر الأواخر من رمضان.',
    'يوم الجمعة هو خير أيام الأسبوع عند المسلمين.',
    'صيام يوم عرفة يكفّر سنتين بإذن الله لغير الحاج.',
    'يوم عاشوراء من الأيام المباركة ويستحب صيامه.',
    'الزكاة والصيام والحج ترتبط في أحكامها بالتقويم الهجري.',
    'رؤية الهلال من السنن المرتبطة ببداية الشهور الهجرية.',
    'الأعياد الإسلامية تُحدد وفق التقويم الهجري وليس الميلادي.',
  ];

  static const Map<String, Map<String, String>> _hijriEvents = {
    '1-10': {'title': 'يوم عاشوراء', 'desc': 'من الأيام المستحب صيامها، وله فضل عظيم.'},
    '3-12': {'title': 'المولد النبوي', 'desc': 'ذكرى مولد النبي ﷺ وفق بعض التواريخ المشهورة.'},
    '7-27': {'title': 'الإسراء والمعراج', 'desc': 'ليلة مباركة ارتبطت بالإسراء والمعراج.'},
    '8-15': {'title': 'ليلة النصف من شعبان', 'desc': 'ليلة مباركة يعتني بها كثير من المسلمين.'},
    '9-1': {'title': 'بداية رمضان', 'desc': 'بداية شهر رمضان المبارك.'},
    '9-27': {'title': 'ليلة القدر (مرجحة)', 'desc': 'من أعظم ليالي العام، وتُطلب في العشر الأواخر.'},
    '10-1': {'title': 'عيد الفطر', 'desc': 'يوم فرح للمسلمين بعد تمام صيام رمضان.'},
    '12-9': {'title': 'يوم عرفة', 'desc': 'من أفضل أيام السنة، ويستحب صيامه لغير الحاج.'},
    '12-10': {'title': 'عيد الأضحى', 'desc': 'يوم النحر وأحد أعظم أيام المسلمين.'},
  };

  static const Map<String, Map<String, String>> _hijriNotes = {
    '1-10': {'title': 'معلومة شرعية', 'desc': 'يستحب صيام يوم عاشوراء، ويُسن أن يُضم إليه يوم قبله أو بعده.'},
    '9-1': {'title': 'معلومة شرعية', 'desc': 'رمضان شهر الصيام والقيام وتلاوة القرآن.'},
    '9-27': {'title': 'معلومة شرعية', 'desc': 'ليلة القدر تُلتمس في العشر الأواخر، وهي خير من ألف شهر.'},
    '10-1': {'title': 'معلومة شرعية', 'desc': 'يوم العيد يوم فرح وشكر، ويُسن فيه إظهار السرور.'},
    '12-9': {'title': 'معلومة شرعية', 'desc': 'صيام يوم عرفة لغير الحاج يكفّر سنتين.'},
    '12-10': {'title': 'معلومة شرعية', 'desc': 'عيد الأضحى من أعظم الأيام، وتُشرع فيه الأضحية.'},
  };

  // الحصول على أقرب مناسبة قادمة
  Map<String, dynamic>? _getNextEvent(DateTime currentDate) {
    final hijriNow = HijriCalendar.fromDate(currentDate);

    // قائمة المناسبات مرتبة
    final events = [
      {'month': 1, 'day': 10, 'title': 'يوم عاشوراء'},
      {'month': 3, 'day': 12, 'title': 'المولد النبوي'},
      {'month': 7, 'day': 27, 'title': 'الإسراء والمعراج'},
      {'month': 8, 'day': 15, 'title': 'ليلة النصف من شعبان'},
      {'month': 9, 'day': 1, 'title': 'بداية رمضان'},
      {'month': 9, 'day': 27, 'title': 'ليلة القدر'},
      {'month': 10, 'day': 1, 'title': 'عيد الفطر'},
      {'month': 12, 'day': 9, 'title': 'يوم عرفة'},
      {'month': 12, 'day': 10, 'title': 'عيد الأضحى'},
    ];

    int minDays = 366;
    Map<String, dynamic>? nextEvent;

    for (final event in events) {
      final eventMonth = event['month'] as int;
      final eventDay = event['day'] as int;

      int daysUntil;

      if (eventMonth > hijriNow.hMonth ||
          (eventMonth == hijriNow.hMonth && eventDay > hijriNow.hDay)) {
        // المناسبة في نفس السنة
        daysUntil = _calculateHijriDaysDifference(
          hijriNow.hMonth, hijriNow.hDay,
          eventMonth, eventDay,
        );
      } else {
        // المناسبة في السنة القادمة
        daysUntil = _calculateHijriDaysDifference(
          hijriNow.hMonth, hijriNow.hDay,
          eventMonth + 12, eventDay,
        );
      }

      if (daysUntil > 0 && daysUntil < minDays) {
        minDays = daysUntil;
        nextEvent = {
          'title': event['title'],
          'daysLeft': daysUntil,
        };
      }
    }

    return nextEvent;
  }

  int _calculateHijriDaysDifference(int fromMonth, int fromDay, int toMonth, int toDay) {
    // تقريب بسيط: كل شهر هجري ≈ 29.5 يوم
    const daysPerMonth = 29.5;
    final fromTotal = (fromMonth * daysPerMonth) + fromDay;
    final toTotal = (toMonth * daysPerMonth) + toDay;
    return (toTotal - fromTotal).round();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _starController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _starController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // Helper Functions
  // ═══════════════════════════════════════════════════════════
  String _toArabicNum(int n) {
    const nums = {'0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤', '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'};
    return n.toString().split('').map((e) => nums[e] ?? e).join();
  }

  String _getWeekday(DateTime date) {
    const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return days[(date.weekday - 1) % 7];
  }

  String _getFact(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day + _factOffset;
    return _islamicFacts[seed % _islamicFacts.length];
  }

  Map<String, String>? _getEvent(HijriCalendar h) => _hijriEvents['${h.hMonth}-${h.hDay}'];
  Map<String, String>? _getNote(HijriCalendar h) => _hijriNotes['${h.hMonth}-${h.hDay}'];
  bool _hasEvent(DateTime d) => _getEvent(HijriCalendar.fromDate(d)) != null;
  bool _isSame(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _getDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startWeekday = first.weekday % 7;
    final List<DateTime> days = [];

    for (int i = 0; i < startWeekday; i++) {
      days.add(first.subtract(Duration(days: startWeekday - i)));
    }
    for (int i = 1; i <= last.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }
    return days;
  }

  void _animateSlide(int dir) {
    _slideAnimation = Tween<Offset>(
      begin: Offset(dir * 0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.reset();
    _slideController.forward();
  }

  Future<void> _shareEvent(Map<String, String> e, HijriCalendar h) async {
    await Share.share('${e['title']}\n\n${e['desc']}\n\nالتاريخ: ${_toArabicNum(h.hDay)} ${_hijriMonths[h.hMonth - 1]} ${_toArabicNum(h.hYear)}');
  }

  Future<void> _shareFact(String f) async => await Share.share('هل تعلم؟\n\n$f');

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = mq.size.width;
    final h = mq.size.height;

    final bg = isDark ? const Color(0xFF080C14) : const Color(0xFFF5F3EE);
    final card = isDark ? const Color(0xFF131A27) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white60 : Colors.black45;
    const gold = Color(0xFFD4A843);

    final compact = w < 360;
    final tablet = w > 600;
    final padH = compact ? 12.0 : tablet ? 28.0 : 16.0;

    final hijri = HijriCalendar.fromDate(_selectedDate);
    final event = _getEvent(hijri);
    final note = _getNote(hijri);
    final fact = _getFact(_selectedDate);
    final days = _getDays(_displayedMonth);
    final today = DateTime.now();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ═══════════════════════════════════
            // ENHANCED HEADER WITH DECORATIONS
            // ═══════════════════════════════════
            SliverAppBar(
              expandedHeight: h * 0.38,
              pinned: true,
              stretch: true,
              backgroundColor: widget.primaryColor,
              elevation: 0,
              leading: _buildBackButton(),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _EnhancedHeroHeader(
                  hijri: hijri,
                  selectedDate: _selectedDate,
                  primaryColor: widget.primaryColor,
                  gold: gold,
                  compact: compact,
                  tablet: tablet,
                  pulseController: _pulseController,
                  starController: _starController,
                  event: event,
                  nextEvent: _getNextEvent(_selectedDate), // ✅ أضف هذا
                  hijriMonths: _hijriMonths,
                  toArabicNum: _toArabicNum,
                  getWeekday: _getWeekday,
                ),
              ),
            ),

            // ═══════════════════════════════════
            // CONTENT
            // ═══════════════════════════════════
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padH, 16, padH, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _InfoRow(
                    hijri: hijri,
                    hijriMonths: _hijriMonths,
                    primaryColor: widget.primaryColor,
                    card: card,
                    text: text,
                    subText: subText,
                    compact: compact,
                    tablet: tablet,
                    isDark: isDark,
                    toArabicNum: _toArabicNum,
                  ),
                  const SizedBox(height: 16),

                  if (event != null) ...[
                    _EventCard(
                      event: event,
                      hijri: hijri,
                      primaryColor: widget.primaryColor,
                      gold: gold,
                      isDark: isDark,
                      compact: compact,
                      pulseController: _pulseController,
                      onShare: () => _shareEvent(event, hijri),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (note != null) ...[
                    _NoteCard(
                      note: note,
                      primaryColor: widget.primaryColor,
                      card: card,
                      isDark: isDark,
                      compact: compact,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _FactCard(
                    fact: fact,
                    gold: gold,
                    card: card,
                    isDark: isDark,
                    compact: compact,
                    onShare: () => _shareFact(fact),
                    onRefresh: () => setState(() => _factOffset++),
                  ),
                  const SizedBox(height: 16),

                  _CalendarCard(
                    days: days,
                    today: today,
                    selectedDate: _selectedDate,
                    displayedMonth: _displayedMonth,
                    primaryColor: widget.primaryColor,
                    gold: gold,
                    card: card,
                    text: text,
                    subText: subText,
                    isDark: isDark,
                    compact: compact,
                    tablet: tablet,
                    slideAnimation: _slideAnimation,
                    weekDays: _weekDays,
                    arabicMonths: _arabicMonths,
                    hijriMonths: _hijriMonths,
                    toArabicNum: _toArabicNum,
                    hasEvent: _hasEvent,
                    isSame: _isSame,
                    onDayTap: (day) {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedDate = day);
                    },
                    onPrevMonth: () {
                      setState(() {
                        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
                      });
                      _animateSlide(-1);
                    },
                    onNextMonth: () {
                      setState(() {
                        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
                      });
                      _animateSlide(1);
                    },
                    onGoToToday: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedDate = today;
                        _displayedMonth = DateTime(today.year, today.month, 1);
                      });
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ENHANCED HERO HEADER WITH ISLAMIC DECORATIONS
// ═══════════════════════════════════════════════════════════════
class _EnhancedHeroHeader extends StatelessWidget {
  final HijriCalendar hijri;
  final DateTime selectedDate;
  final Color primaryColor;
  final Color gold;
  final bool compact;
  final bool tablet;
  final AnimationController pulseController;
  final AnimationController starController;
  final Map<String, String>? event;
  final Map<String, dynamic>? nextEvent; // ✅ أضف هذا
  final List<String> hijriMonths;
  final String Function(int) toArabicNum;
  final String Function(DateTime) getWeekday;

  const _EnhancedHeroHeader({
    required this.hijri,
    required this.selectedDate,
    required this.primaryColor,
    required this.gold,
    required this.compact,
    required this.tablet,
    required this.pulseController,
    required this.starController,
    required this.event,
    required this.nextEvent, // ✅ أضف هذا
    required this.hijriMonths,
    required this.toArabicNum,
    required this.getWeekday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.3)!,
            Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.5)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // ═══════════════════════════════════
          // النقش الإسلامي الهندسي
          // ═══════════════════════════════════
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(
                color: Colors.white.withOpacity(0.03),
                lineWidth: 0.5,
              ),
            ),
          ),

          // ═══════════════════════════════════
          // الدوائر الزخرفية المتوهجة
          // ═══════════════════════════════════
          // دائرة كبيرة أعلى اليمين
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Transform.scale(
                scale: 1 + (pulseController.value * 0.1),
                child: Container(
                  width: compact ? 180 : 220,
                  height: compact ? 180 : 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gold.withOpacity(0.12),
                        gold.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // دائرة متوسطة أسفل اليسار
          Positioned(
            bottom: -50,
            left: -40,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Transform.scale(
                scale: 1 + (pulseController.value * 0.08),
                child: Container(
                  width: compact ? 140 : 170,
                  height: compact ? 140 : 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.06),
                        Colors.white.withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // دائرة صغيرة في الوسط
          Positioned(
            top: compact ? 100 : 120,
            right: compact ? 80 : 100,
            child: AnimatedBuilder(
              animation: starController,
              builder: (_, __) => Opacity(
                opacity: 0.3 + (starController.value * 0.4),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gold.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════
          // الهلال الكبير المزخرف
          // ═══════════════════════════════════
          Positioned(
            top: compact ? 50 : 60,
            left: compact ? 20 : tablet ? 40 : 28,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) => Transform.rotate(
                angle: pulseController.value * 0.06,
                child: _buildEnhancedCrescent(),
              ),
            ),
          ),

          // ═══════════════════════════════════
          // النجوم المتلألئة
          // ═══════════════════════════════════
          ..._buildStars(),

          // ═══════════════════════════════════
          // الزخارف الهندسية الجانبية
          // ═══════════════════════════════════
          Positioned(
            top: compact ? 55 : 65,
            right: compact ? 15 : 25,
            child: _buildGeometricDecoration(),
          ),

          // ═══════════════════════════════════
          // المحتوى الرئيسي
          // ═══════════════════════════════════
          Positioned(
            left: 16,
            right: 16,
            bottom: compact ? 20 : 28,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ═══════════════════════════════════
// المناسبة القادمة
// ═══════════════════════════════════
                  if (nextEvent != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 10 : 14,
                        vertical: compact ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gold.withOpacity(0.2),
                            gold.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gold.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_rounded,
                            color: gold,
                            size: compact ? 12 : 14,
                          ),
                          SizedBox(width: compact ? 4 : 6),
                          Flexible(
                            child: Text(
                              'القادم: ${nextEvent!['title']}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: compact ? 9 : 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 6 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 6 : 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'بعد ${toArabicNum(nextEvent!['daysLeft'])} يوم',
                              style: GoogleFonts.cairo(
                                color: gold,
                                fontSize: compact ? 8 : 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 10),
                  ],
                  // اسم اليوم
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 18,
                      vertical: compact ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: gold.withOpacity(0.8),
                          size: compact ? 12 : 14,
                        ),
                        SizedBox(width: compact ? 4 : 6),
                        Text(
                          getWeekday(selectedDate),
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: compact ? 11 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),

                  // التاريخ الهجري
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: FittedBox(
                      key: ValueKey('${hijri.hDay}-${hijri.hMonth}-${hijri.hYear}'),
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // زخرفة يسار
                          _buildSideDecoration(isLeft: true),
                          SizedBox(width: compact ? 8 : 12),
                          // التاريخ
                          Text(
                            '${toArabicNum(hijri.hDay)} ${hijriMonths[hijri.hMonth - 1]} ${toArabicNum(hijri.hYear)}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              color: Colors.white,
                              fontSize: compact ? 26 : tablet ? 38 : 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: compact ? 8 : 12),
                          // زخرفة يمين
                          _buildSideDecoration(isLeft: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // التاريخ الميلادي
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Row(
                      key: ValueKey(selectedDate.toString()),
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: compact ? 20 : 25,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                gold.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                          child: Text(
                            DateFormat('dd MMMM yyyy', 'ar').format(selectedDate),
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: compact ? 11 : 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          width: compact ? 20 : 25,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gold.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // وسم المناسبة
                  if (event != null) ...[
                    SizedBox(height: compact ? 10 : 14),
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, child) => Transform.scale(
                        scale: 1 + (pulseController.value * 0.03),
                        child: child,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 12 : 16,
                          vertical: compact ? 5 : 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gold.withOpacity(0.25),
                              gold.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: gold.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: gold, size: compact ? 12 : 14),
                            SizedBox(width: compact ? 4 : 6),
                            Flexible(
                              child: Text(
                                event!['title']!,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  color: gold,
                                  fontSize: compact ? 10 : 11,
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
          ),

          // ═══════════════════════════════════
          // التدرج السفلي
          // ═══════════════════════════════════
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.5)!.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // الهلال المحسّن
  // ═══════════════════════════════════
  Widget _buildEnhancedCrescent() {
    final s = compact ? 55.0 : tablet ? 75.0 : 65.0;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          // توهج خارجي
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gold.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // الهلال الرئيسي
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  gold.withOpacity(0.5),
                  gold.withOpacity(0.25),
                  gold.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: gold.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // القطع الداخلي للهلال
          Positioned(
            left: s * 0.22,
            top: s * 0.05,
            child: Container(
              width: s * 0.82,
              height: s * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.35),
              ),
            ),
          ),
          // نجمة صغيرة بجانب الهلال
          Positioned(
            right: s * 0.05,
            bottom: s * 0.25,
            child: AnimatedBuilder(
              animation: starController,
              builder: (_, __) => Opacity(
                opacity: 0.5 + (starController.value * 0.5),
                child: _buildMiniStar(size: s * 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStar({required double size}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: gold),
    );
  }

  // ═══════════════════════════════════
  // النجوم المتلألئة
  // ═══════════════════════════════════
  List<Widget> _buildStars() {
    final starData = [
      {'top': 70.0, 'right': 50.0, 'size': 3.0, 'delay': 0.0},
      {'top': 90.0, 'right': 90.0, 'size': 2.5, 'delay': 0.3},
      {'top': 60.0, 'right': 130.0, 'size': 2.0, 'delay': 0.6},
      {'top': 110.0, 'left': 80.0, 'size': 2.5, 'delay': 0.2},
      {'top': 80.0, 'left': 120.0, 'size': 2.0, 'delay': 0.5},
      {'top': 130.0, 'right': 70.0, 'size': 1.8, 'delay': 0.4},
    ];

    return starData.map((data) {
      return Positioned(
        top: data['top'] as double,
        right: data.containsKey('right') ? data['right'] as double : null,
        left: data.containsKey('left') ? data['left'] as double : null,
        child: AnimatedBuilder(
          animation: starController,
          builder: (_, __) {
            final delay = data['delay'] as double;
            final animValue = ((starController.value + delay) % 1.0);
            return Opacity(
              opacity: (0.3 + (animValue * 0.7)).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.8 + (animValue * 0.4),
                child: Container(
                  width: (data['size'] as double) * 2,
                  height: (data['size'] as double) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // ═══════════════════════════════════
  // الزخرفة الهندسية
  // ═══════════════════════════════════
  Widget _buildGeometricDecoration() {
    final size = compact ? 35.0 : 45.0;
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Transform.rotate(
        angle: pulseController.value * 0.1,
        child: Opacity(
          opacity: 0.15 + (pulseController.value * 0.1),
          child: CustomPaint(
            size: Size(size, size),
            painter: _GeometricDecorationPainter(color: gold),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  // الزخارف الجانبية للتاريخ
  // ═══════════════════════════════════
  Widget _buildSideDecoration({required bool isLeft}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLeft) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          width: compact ? 15 : 20,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: isLeft
                  ? [Colors.transparent, gold.withOpacity(0.5)]
                  : [gold.withOpacity(0.5), Colors.transparent],
            ),
          ),
        ),
        if (isLeft) ...[
          const SizedBox(width: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// النقش الإسلامي الهندسي
// ═══════════════════════════════════════════════════════════════
class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double lineWidth;

  _IslamicPatternPainter({required this.color, this.lineWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    const step = 40.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;

        // رسم شكل ثماني
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i - math.pi / 8;
          final r = step * 0.35;
          final px = cx + r * math.cos(angle);
          final py = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        // خطوط متقاطعة
        canvas.drawLine(
          Offset(cx - step * 0.2, cy),
          Offset(cx + step * 0.2, cy),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy - step * 0.2),
          Offset(cx, cy + step * 0.2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════
// رسام النجمة
// ═══════════════════════════════════════════════════════════════
class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = size.width / 4;

    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (math.pi / 5) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════
// رسام الزخرفة الهندسية
// ═══════════════════════════════════════════════════════════════
class _GeometricDecorationPainter extends CustomPainter {
  final Color color;

  _GeometricDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // مربع خارجي مائل
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 1.4),
      paint,
    );
    canvas.restore();

    // دائرة داخلية
    canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);

    // نقطة مركزية
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.1, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GeometricDecorationPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════
// باقي الـ Widgets (نفس الكود السابق)
// ═══════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final HijriCalendar hijri;
  final List<String> hijriMonths;
  final Color primaryColor, card, text, subText;
  final bool compact, tablet, isDark;
  final String Function(int) toArabicNum;

  const _InfoRow({
    required this.hijri,
    required this.hijriMonths,
    required this.primaryColor,
    required this.card,
    required this.text,
    required this.subText,
    required this.compact,
    required this.tablet,
    required this.isDark,
    required this.toArabicNum,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'اليوم', 'value': toArabicNum(hijri.hDay), 'icon': Icons.today_rounded},
      {'title': 'الشهر', 'value': hijriMonths[hijri.hMonth - 1], 'icon': Icons.calendar_month_rounded},
      {'title': 'السنة', 'value': toArabicNum(hijri.hYear), 'icon': Icons.date_range_rounded},
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
            padding: EdgeInsets.symmetric(vertical: compact ? 12 : tablet ? 20 : 16, horizontal: 6),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : primaryColor.withOpacity(0.06)),
              boxShadow: [BoxShadow(color: primaryColor.withOpacity(isDark ? 0.08 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Container(
                  width: compact ? 32 : 38,
                  height: compact ? 32 : 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor.withOpacity(0.12), primaryColor.withOpacity(0.04)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: primaryColor, size: compact ? 15 : 17),
                ),
                SizedBox(height: compact ? 6 : 10),
                Text(item['title'] as String, style: GoogleFonts.cairo(fontSize: compact ? 9 : 10, color: subText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(item['value'] as String, style: GoogleFonts.cairo(fontSize: compact ? 13 : 16, fontWeight: FontWeight.bold, color: primaryColor)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, String> event;
  final HijriCalendar hijri;
  final Color primaryColor, gold;
  final bool isDark, compact;
  final AnimationController pulseController;
  final VoidCallback onShare;

  const _EventCard({
    required this.event,
    required this.hijri,
    required this.primaryColor,
    required this.gold,
    required this.isDark,
    required this.compact,
    required this.pulseController,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primaryColor.withOpacity(isDark ? 0.15 : 0.08), gold.withOpacity(isDark ? 0.08 : 0.03)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _IconBtn(icon: Icons.share_rounded, color: primaryColor, onTap: onShare),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Badge(text: 'مناسبة اليوم', color: gold),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(event['title']!, style: GoogleFonts.cairo(fontSize: compact ? 15 : 17, fontWeight: FontWeight.bold, color: primaryColor)),
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, __) => Transform.scale(
                          scale: 1 + (pulseController.value * 0.12),
                          child: Icon(Icons.auto_awesome_rounded, color: gold, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Divider(color: gold),
          const SizedBox(height: 12),
          Text(event['desc']!, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: compact ? 12 : 13, height: 1.8, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Map<String, String> note;
  final Color primaryColor, card;
  final bool isDark, compact;

  const _NoteCard({required this.note, required this.primaryColor, required this.card, required this.isDark, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : primaryColor.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(note['title']!, style: GoogleFonts.cairo(fontSize: compact ? 12 : 14, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 6),
                Text(note['desc']!, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: compact ? 11 : 12, height: 1.8, color: isDark ? Colors.white70 : Colors.black87)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor.withOpacity(0.12), primaryColor.withOpacity(0.04)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.lightbulb_outline_rounded, color: primaryColor, size: compact ? 20 : 22),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final String fact;
  final Color gold, card;
  final bool isDark, compact;
  final VoidCallback onShare, onRefresh;

  const _FactCard({required this.fact, required this.gold, required this.card, required this.isDark, required this.compact, required this.onShare, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _IconBtn(icon: Icons.share_rounded, color: gold, onTap: onShare),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.refresh_rounded, color: gold, onTap: onRefresh),
              const Spacer(),
              Text('هل تعلم؟', style: GoogleFonts.cairo(fontSize: compact ? 13 : 15, fontWeight: FontWeight.bold, color: gold)),
              const SizedBox(width: 8),
              Container(
                width: compact ? 36 : 42,
                height: compact ? 36 : 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gold.withOpacity(0.12), gold.withOpacity(0.04)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: gold, size: compact ? 16 : 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Divider(color: gold),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(fact, key: ValueKey(fact), textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: compact ? 12 : 13, height: 1.8, color: isDark ? Colors.white70 : Colors.black87)),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final List<DateTime> days;
  final DateTime today, selectedDate, displayedMonth;
  final Color primaryColor, gold, card, text, subText;
  final bool isDark, compact, tablet;
  final Animation<Offset> slideAnimation;
  final List<String> weekDays, arabicMonths, hijriMonths;
  final String Function(int) toArabicNum;
  final bool Function(DateTime) hasEvent;
  final bool Function(DateTime, DateTime) isSame;
  final void Function(DateTime) onDayTap;
  final VoidCallback onPrevMonth, onNextMonth, onGoToToday;

  const _CalendarCard({
    required this.days,
    required this.today,
    required this.selectedDate,
    required this.displayedMonth,
    required this.primaryColor,
    required this.gold,
    required this.card,
    required this.text,
    required this.subText,
    required this.isDark,
    required this.compact,
    required this.tablet,
    required this.slideAnimation,
    required this.weekDays,
    required this.arabicMonths,
    required this.hijriMonths,
    required this.toArabicNum,
    required this.hasEvent,
    required this.isSame,
    required this.onDayTap,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onGoToToday,
  });

  @override
  Widget build(BuildContext context) {
    final hijriMonth = HijriCalendar.fromDate(displayedMonth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : tablet ? 22 : 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white10 : primaryColor.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: compact ? 8 : 12, horizontal: compact ? 4 : 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor.withOpacity(0.06), primaryColor.withOpacity(0.02)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _MonthArrow(icon: Icons.chevron_left_rounded, color: primaryColor, onTap: onPrevMonth),
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${arabicMonths[displayedMonth.month - 1]} ${toArabicNum(displayedMonth.year)}',
                          style: GoogleFonts.cairo(fontSize: compact ? 14 : 17, fontWeight: FontWeight.bold, color: text),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${hijriMonths[hijriMonth.hMonth - 1]} ${toArabicNum(hijriMonth.hYear)}',
                          style: GoogleFonts.cairo(fontSize: compact ? 10 : 12, color: subText),
                        ),
                      ),
                    ],
                  ),
                ),
                _MonthArrow(icon: Icons.chevron_right_rounded, color: primaryColor, onTap: onNextMonth),
              ],
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Row(
            children: weekDays.map((d) {
              final isFri = d == 'ج';
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(d, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: isFri ? gold : primaryColor.withOpacity(0.6), fontSize: compact ? 10 : 12)),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: compact ? 6 : 10),
          SlideTransition(
            position: slideAnimation,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: compact ? 3 : 5,
                mainAxisSpacing: compact ? 3 : 5,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final day = days[i];
                final isCurrent = day.month == displayedMonth.month;
                final isToday = isSame(day, today);
                final isSelected = isSame(day, selectedDate);
                final hasEv = hasEvent(day);
                final isFri = day.weekday == DateTime.friday;

                return GestureDetector(
                  onTap: () => onDayTap(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [primaryColor, Color.lerp(primaryColor, Colors.black, 0.25)!]) : null,
                      color: !isSelected ? (isToday ? gold.withOpacity(0.1) : hasEv ? primaryColor.withOpacity(0.04) : null) : null,
                      borderRadius: BorderRadius.circular(compact ? 10 : 12),
                      border: isToday && !isSelected ? Border.all(color: gold.withOpacity(0.5), width: 1.5) : hasEv && !isSelected ? Border.all(color: primaryColor.withOpacity(0.15)) : null,
                      boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              toArabicNum(day.day),
                              style: GoogleFonts.cairo(
                                fontSize: compact ? 11 : 13,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : !isCurrent ? subText.withOpacity(0.3) : isFri ? gold : text,
                              ),
                            ),
                          ),
                        ),
                        if (hasEv)
                          Positioned(
                            top: compact ? 2 : 3,
                            left: compact ? 2 : 3,
                            child: Container(
                              width: compact ? 6 : 8,
                              height: compact ? 6 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [isSelected ? Colors.white : gold, (isSelected ? Colors.white : gold).withOpacity(0.6)]),
                                boxShadow: [BoxShadow(color: (isSelected ? Colors.white : gold).withOpacity(0.5), blurRadius: 3)],
                              ),
                            ),
                          ),
                        if (isToday && !isSelected)
                          Positioned(
                            bottom: compact ? 2 : 3,
                            child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: gold)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          if (!isSame(selectedDate, today))
            GestureDetector(
              onTap: onGoToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.04)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryColor.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('العودة لليوم', style: GoogleFonts.cairo(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(Icons.today_rounded, color: primaryColor, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MonthArrow({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(text, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, color.withOpacity(0.2), Colors.transparent])),
    );
  }
}