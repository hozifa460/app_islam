import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:share_plus/share_plus.dart';

import '../../languages/app_localizations.dart';
import 'data/hijri_data.dart';
import 'widgets/hijri_theme.dart';
import 'widgets/hijri_hero_header.dart';
import 'widgets/hijri_info_row.dart';
import 'widgets/hijri_event_card.dart';
import 'widgets/hijri_note_card.dart';
import 'widgets/hijri_fact_card.dart';
import 'widgets/hijri_calendar_card.dart';

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
  bool _isLoading = true; // ًں‘ˆ ط£ط¶ظپ ظ‡ط°ط§ ط§ظ„ظ…طھط؛ظٹط±

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

  // ًں‘ˆ ط§ط³طھط®ط¯ظ…ظ†ط§ didChangeDependencies ظ„ط£ظ†ظ†ط§ ظ†ط­طھط§ط¬ ط§ظ„ظˆطµظˆظ„ ظ„ظ„ط؛ط© ط¹ط¨ط± context
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadHijriData();
    }
  }

  Future<void> _loadHijriData() async {
    final langCode = context.tr.locale.languageCode; // ط¬ظ„ط¨ ظ„ط؛ط© ط§ظ„ظ‡ط§طھظپ
    await HijriData.loadData(langCode);
    if (mounted) {
      setState(() {
        _isLoading = false; // ط§ظ„ط¨ظٹط§ظ†ط§طھ ط¬ط§ظ‡ط²ط©طŒ ظ†ط¹ط±ط¶ ط§ظ„ط´ط§ط´ط©
      });
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Helper Functions
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  String _getFact(DateTime date) {
    // ًں‘ˆ ط­ظ…ط§ظٹط©: ط¥ط°ط§ ظƒط§ظ†طھ ط§ظ„ظ‚ط§ط¦ظ…ط© ظپط§ط±ط؛ط©طŒ ظ†ظڈط±ط¬ط¹ ظ†طµط§ظ‹ ظپط§ط±ط؛ط§ظ‹ ظ…ط¤ظ‚طھط§ظ‹
    if (HijriData.islamicFacts.isEmpty) return '';

    final seed = date.year * 10000 + date.month * 100 + date.day + _factOffset;
    return HijriData.islamicFacts[seed % HijriData.islamicFacts.length];
  }

  Map<String, String>? _getEvent(HijriCalendar h) =>
      HijriData.hijriEvents['${h.hMonth}-${h.hDay}'];

  Map<String, String>? _getNote(HijriCalendar h) =>
      HijriData.hijriNotes['${h.hMonth}-${h.hDay}'];

  bool _hasEvent(DateTime d) =>
      _getEvent(HijriCalendar.fromDate(d)) != null;

  bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  Map<String, dynamic>? _getNextEvent(DateTime currentDate) {
    final hijriNow = HijriCalendar.fromDate(currentDate);
    int minDays = 366;
    Map<String, dynamic>? nextEvent;

    for (final event in HijriData.upcomingEvents) {
      final eventMonth = event['month'] as int;
      final eventDay = event['day'] as int;
      int daysUntil;

      if (eventMonth > hijriNow.hMonth ||
          (eventMonth == hijriNow.hMonth && eventDay > hijriNow.hDay)) {
        daysUntil = _calcHijriDiff(
            hijriNow.hMonth, hijriNow.hDay, eventMonth, eventDay);
      } else {
        daysUntil = _calcHijriDiff(
            hijriNow.hMonth, hijriNow.hDay, eventMonth + 12, eventDay);
      }

      if (daysUntil > 0 && daysUntil < minDays) {
        minDays = daysUntil;
        nextEvent = {'title': event['title'], 'daysLeft': daysUntil};
      }
    }
    return nextEvent;
  }

  int _calcHijriDiff(int fromM, int fromD, int toM, int toD) {
    const dpm = 29.5;
    return ((toM * dpm + toD) - (fromM * dpm + fromD)).round();
  }

  void _animateSlide(int dir) {
    _slideAnimation = Tween<Offset>(
      begin: Offset(dir * 0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.reset();
    _slideController.forward();
  }

  Future<void> _shareEvent(Map<String, String> e, HijriCalendar h) async {
    final formattedDate = '${HijriTheme.formatNum(h.hDay, context)} ${HijriData.hijriMonths[h.hMonth - 1]} ${HijriTheme.formatNum(h.hYear, context)}';
    await Share.share(context.tr.shareEventFormat(e['title']!, e['desc']!, formattedDate));
  }

  Future<void> _shareFact(String f) async =>
      await Share.share(context.tr.shareFactTitle(f));

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // BUILD
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    // ًں‘ˆ ظٹط¬ط¨ ط£ظ† ظٹظƒظˆظ† ظ‡ط°ط§ ط§ظ„ط´ط±ط· ظپظٹ ط§ظ„ط£ط¹ظ„ظ‰ طھظ…ط§ظ…ط§ظ‹ ظ‚ط¨ظ„ ط£ظٹ ط­ط³ط§ط¨ط§طھ!
    if (_isLoading || HijriData.weekDays.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF080C14)
            : const Color(0xFFF5F3EE),
        body: Center(child: CircularProgressIndicator(color: widget.primaryColor)),
      );
    }

    // ط¨ط¹ط¯ ط£ظ† ظ†طھط£ظƒط¯ ط£ظ† ط§ظ„طھط­ظ…ظٹظ„ ط§ظ†طھظ‡ظ‰طŒ ظ†ظƒظ…ظ„ ط¨ط§ظ‚ظٹ ط§ظ„ظƒظˆط¯ ط¨ط´ظƒظ„ ط·ط¨ظٹط¹ظٹ
    final mq = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = mq.size.width;
    final h = mq.size.height;

    final theme = HijriTheme(isDark: isDark, primaryColor: widget.primaryColor);
    final compact = theme.isCompact(w);
    final tablet = theme.isTablet(w);
    final padH = theme.padH(w);

    final hijri = HijriCalendar.fromDate(_selectedDate);
    final event = _getEvent(hijri);
    final note = _getNote(hijri);
    final fact = _getFact(_selectedDate);
    final days = _getDays(_displayedMonth);
    final today = DateTime.now();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
        child: Directionality( // ًں‘ˆ ط¥ط¶ط§ظپط© ط¯ط¹ظ… ط§ظ„ظ„ط؛ط§طھ LTR ظˆ RTL
          textDirection: context.tr.textDirection,
          child: Scaffold(
        backgroundColor: theme.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: h * 0.38,
              pinned: true,
              stretch: true,
              backgroundColor: widget.primaryColor,
              elevation: 0,
              leading: _buildBackButton(),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: HijriHeroHeader(
                  hijri: hijri,
                  selectedDate: _selectedDate,
                  primaryColor: widget.primaryColor,
                  compact: compact,
                  tablet: tablet,
                  pulseController: _pulseController,
                  starController: _starController,
                  event: event,
                  nextEvent: _getNextEvent(_selectedDate),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padH, 16, padH, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HijriInfoRow(
                    hijri: hijri,
                    theme: theme,
                    compact: compact,
                    tablet: tablet,
                  ),
                  const SizedBox(height: 16),

                  if (event != null) ...[
                    HijriEventCard(
                      event: event,
                      theme: theme,
                      compact: compact,
                      pulseController: _pulseController,
                      onShare: () => _shareEvent(event, hijri),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (note != null) ...[
                    HijriNoteCard(
                      note: note,
                      theme: theme,
                      compact: compact,
                    ),
                    const SizedBox(height: 16),
                  ],

                  HijriFactCard(
                    fact: fact,
                    theme: theme,
                    compact: compact,
                    onShare: () => _shareFact(fact),
                    onRefresh: () => setState(() => _factOffset++),
                  ),
                  const SizedBox(height: 16),

                  HijriCalendarCard(
                    days: days,
                    today: today,
                    selectedDate: _selectedDate,
                    displayedMonth: _displayedMonth,
                    theme: theme,
                    compact: compact,
                    tablet: tablet,
                    slideAnimation: _slideAnimation,
                    hasEvent: _hasEvent,
                    isSame: _isSame,
                    onDayTap: (day) {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedDate = day);
                    },
                    onPrevMonth: () {
                      setState(() {
                        _displayedMonth = DateTime(
                            _displayedMonth.year,
                            _displayedMonth.month - 1, 1);
                      });
                      _animateSlide(-1);
                    },
                    onNextMonth: () {
                      setState(() {
                        _displayedMonth = DateTime(
                            _displayedMonth.year,
                            _displayedMonth.month + 1, 1);
                      });
                      _animateSlide(1);
                    },
                    onGoToToday: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedDate = today;
                        _displayedMonth =
                            DateTime(today.year, today.month, 1);
                      });
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
        ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}