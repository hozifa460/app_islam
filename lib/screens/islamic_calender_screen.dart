import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../utils/higri_extention.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen>
    with TickerProviderStateMixin {
  late HijriCalendar _selectedHijriDate;
  late DateTime _selectedGregorianDate;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // المناسبات الإسلامية
  final Map<String, List<Map<String, dynamic>>> _islamicEvents = {
    '1': [
      {
        'day': 1,
        'name': 'رأس السنة الهجرية',
        'description': 'بداية العام الهجري الجديد',
        'icon': '🌙',
        'color': Color(0xFF667eea),
        'isHoliday': true,
      },
      {
        'day': 10,
        'name': 'عاشوراء',
        'description': 'يوم نجّى الله موسى وقومه من فرعون',
        'icon': '📿',
        'color': Color(0xFF11998e),
        'isHoliday': false,
      },
    ],
    '3': [
      {
        'day': 12,
        'name': 'المولد النبوي الشريف',
        'description': 'مولد النبي محمد ﷺ',
        'icon': '💚',
        'color': Color(0xFF2E7D32),
        'isHoliday': true,
      },
    ],
    '7': [
      {
        'day': 27,
        'name': 'الإسراء والمعراج',
        'description': 'رحلة النبي ﷺ من المسجد الحرام إلى المسجد الأقصى',
        'icon': '✨',
        'color': Color(0xFF667eea),
        'isHoliday': false,
      },
    ],
    '8': [
      {
        'day': 15,
        'name': 'ليلة النصف من شعبان',
        'description': 'ليلة مباركة',
        'icon': '🌕',
        'color': Color(0xFFFFD700),
        'isHoliday': false,
      },
    ],
    '9': [
      {
        'day': 1,
        'name': 'بداية رمضان',
        'description': 'أول يوم من شهر الصيام المبارك',
        'icon': '🌙',
        'color': Color(0xFF667eea),
        'isHoliday': false,
      },
      {
        'day': 27,
        'name': 'ليلة القدر (المرجحة)',
        'description': 'خير من ألف شهر',
        'icon': '✨',
        'color': Color(0xFFFFD700),
        'isHoliday': false,
      },
    ],
    '10': [
      {
        'day': 1,
        'name': 'عيد الفطر المبارك',
        'description': 'يوم الجائزة',
        'icon': '🎉',
        'color': Color(0xFF4CAF50),
        'isHoliday': true,
      },
    ],
    '12': [
      {
        'day': 9,
        'name': 'يوم عرفة',
        'description': 'أعظم يوم طلعت عليه الشمس',
        'icon': '🤲',
        'color': Color(0xFFFF9800),
        'isHoliday': false,
      },
      {
        'day': 10,
        'name': 'عيد الأضحى المبارك',
        'description': 'يوم النحر',
        'icon': '🐑',
        'color': Color(0xFFE91E63),
        'isHoliday': true,
      },
    ],
  };

  // أسماء الأشهر الهجرية
  final List<String> _hijriMonths = [
    'مُحَرَّم',
    'صَفَر',
    'رَبِيع الأَوّل',
    'رَبِيع الثاني',
    'جُمادى الأولى',
    'جُمادى الآخرة',
    'رَجَب',
    'شَعْبان',
    'رَمَضان',
    'شَوّال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  // معلومات الأشهر
  final Map<int, Map<String, dynamic>> _monthsInfo = {
    1: {
      'name': 'محرم',
      'type': 'حرام',
      'description': 'أول الأشهر الحرم الأربعة. سُمي بذلك لأن العرب كانوا يحرّمون القتال فيه.',
      'icon': '🌙',
      'virtue': 'صيام يوم عاشوراء يكفر ذنوب سنة',
    },
    2: {
      'name': 'صفر',
      'type': 'عادي',
      'description': 'سُمي بذلك لأن ديار العرب كانت تصفر فيه من أهلها للحرب.',
      'icon': '📅',
      'virtue': 'شهر عادي لا تشاؤم فيه',
    },
    3: {
      'name': 'ربيع الأول',
      'type': 'عادي',
      'description': 'سُمي بذلك لارتباع العرب فيه في منازلهم.',
      'icon': '🌸',
      'virtue': 'شهر مولد النبي ﷺ',
    },
    4: {
      'name': 'ربيع الآخر',
      'type': 'عادي',
      'description': 'يُسمى أيضاً ربيع الثاني.',
      'icon': '🌺',
      'virtue': 'استمر في العمل الصالح',
    },
    5: {
      'name': 'جمادى الأولى',
      'type': 'عادي',
      'description': 'سُمي بذلك لجمود الماء فيه من شدة البرد.',
      'icon': '❄️',
      'virtue': 'شهر مبارك',
    },
    6: {
      'name': 'جمادى الآخرة',
      'type': 'عادي',
      'description': 'يُسمى أيضاً جمادى الثانية.',
      'icon': '🌊',
      'virtue': 'أكثر من الطاعات',
    },
    7: {
      'name': 'رجب',
      'type': 'حرام',
      'description': 'من الأشهر الحرم، سُمي بذلك لترجيبهم الرماح.',
      'icon': '⭐',
      'virtue': 'شهر الإسراء والمعراج',
    },
    8: {
      'name': 'شعبان',
      'type': 'عادي',
      'description': 'سُمي بذلك لتشعب القبائل فيه وتفرقهم للغارات.',
      'icon': '🌕',
      'virtue': 'كان النبي ﷺ يكثر الصيام فيه',
    },
    9: {
      'name': 'رمضان',
      'type': 'مبارك',
      'description': 'شهر الصيام، سُمي بذلك من شدة وقع الشمس فيه وقت تسميته.',
      'icon': '🌙',
      'virtue': 'شهر الصيام والقرآن وليلة القدر',
    },
    10: {
      'name': 'شوال',
      'type': 'عادي',
      'description': 'سُمي بذلك لشولان النوق فيه بأذنابها إذا حملت.',
      'icon': '🎊',
      'virtue': 'صيام 6 أيام منه مع رمضان كصيام الدهر',
    },
    11: {
      'name': 'ذو القعدة',
      'type': 'حرام',
      'description': 'من الأشهر الحرم، سُمي بذلك لقعود الناس فيه عن القتال.',
      'icon': '🕌',
      'virtue': 'من الأشهر الحرم',
    },
    12: {
      'name': 'ذو الحجة',
      'type': 'حرام',
      'description': 'من الأشهر الحرم، وفيه موسم الحج.',
      'icon': '🕋',
      'virtue': 'العشر الأوائل أفضل أيام الدنيا',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedHijriDate = HijriCalendar.now();
    _selectedGregorianDate = DateTime.now();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEventsForDay(HijriCalendar date) {
    final monthStr = date.hMonth.toString();
    final dayEvents = _islamicEvents[monthStr];

    if (dayEvents == null) return [];

    return dayEvents.where((event) => event['day'] == date.hDay).toList();
  }

  Map<String, dynamic>? _getNextEvent() {
    final current = _selectedHijriDate;
    Map<String, dynamic>? nextEvent;
    int minDaysDiff = 365;

    _islamicEvents.forEach((monthStr, events) {
      final month = int.parse(monthStr);
      for (var event in events) {
        final eventDay = event['day'] as int;
        int daysDiff;

        if (month > current.hMonth ||
            (month == current.hMonth && eventDay >= current.hDay)) {
          daysDiff = (month - current.hMonth) * 30 + (eventDay - current.hDay);
        } else {
          daysDiff = (12 - current.hMonth + month) * 30 +
              (eventDay - current.hDay);
        }

        if (daysDiff >= 0 && daysDiff < minDaysDiff) {
          minDaysDiff = daysDiff;
          nextEvent = {
            ...event,
            'month': month,
            'daysRemaining': daysDiff,
          };
        }
      }
    });

    return nextEvent;
  }

  void _changeMonth(int delta) {
    setState(() {
      // إنشاء تاريخ هجري جديد
      int newMonth = _selectedHijriDate.hMonth + delta;
      int newYear = _selectedHijriDate.hYear;

      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }

      _selectedHijriDate = HijriCalendar()
        ..hYear = newYear
        ..hMonth = newMonth
        ..hDay = 1;

      // تحديث التاريخ الميلادي
      _selectedGregorianDate = _selectedHijriDate.toGregorian();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayEvents = _getEventsForDay(_selectedHijriDate);
    final nextEvent = _getNextEvent();
    final monthInfo = _monthsInfo[_selectedHijriDate.hMonth];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0a0a0a) : const Color(0xFFF8F9FE),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // الهيدر
          _buildHeader(isDark),

          // المناسبة القادمة
          if (nextEvent != null)
            SliverToBoxAdapter(
              child: _buildNextEventCard(nextEvent, isDark),
            ),

          // التقويم
          SliverToBoxAdapter(
            child: _buildCalendar(isDark),
          ),

          // مناسبات اليوم
          if (todayEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildTodayEvents(todayEvents, isDark),
            ),

          // معلومات الشهر
          SliverToBoxAdapter(
            child: _buildMonthInfo(monthInfo!, isDark),
          ),

          // مناسبات الشهر
          SliverToBoxAdapter(
            child: _buildMonthEvents(isDark),
          ),

          // شبكة الأشهر
          SliverToBoxAdapter(
            child: _buildMonthsGrid(isDark),
          ),

          // آية
          SliverToBoxAdapter(
            child: _buildVerseCard(isDark),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                  : [const Color(0xFF667eea), const Color(0xFF764ba2)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text('🌙', style: TextStyle(fontSize: 35)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_selectedHijriDate.hDay}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _hijriMonths[_selectedHijriDate.hMonth - 1],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_selectedHijriDate.hYear} هـ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE، d MMMM yyyy', 'ar')
                              .format(_selectedGregorianDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextEventCard(Map<String, dynamic> event, bool isDark) {
    final daysRemaining = event['daysRemaining'] as int;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            event['color'] as Color,
            (event['color'] as Color).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (event['color'] as Color).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  event['icon'],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المناسبة القادمة',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      event['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${event['day']} ${_hijriMonths[(event['month'] as int) - 1]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        daysRemaining == 0
                            ? 'اليوم'
                            : 'بعد $daysRemaining ${daysRemaining == 1 ? "يوم" : "أيام"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
              Column(
                children: [
                  Text(
                    _hijriMonths[_selectedHijriDate.hMonth - 1],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${_selectedHijriDate.hYear} هـ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'].map((day) {
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _buildDaysGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(bool isDark) {
    final daysInMonth = _selectedHijriDate.lengthOfMonth;

    // حساب اليوم الأول من الشهر
    final firstDay = HijriCalendar()
      ..hYear = _selectedHijriDate.hYear
      ..hMonth = _selectedHijriDate.hMonth
      ..hDay = 1;

    final gregorianFirst = firstDay.toGregorian();
    final weekday = gregorianFirst.weekday % 7;

    List<Widget> dayWidgets = [];

    // مساحات فارغة
    for (int i = 0; i < weekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // أيام الشهر
    for (int day = 1; day <= daysInMonth; day++) {
      final hijriDay = HijriCalendar()
        ..hYear = _selectedHijriDate.hYear
        ..hMonth = _selectedHijriDate.hMonth
        ..hDay = day;

      final isToday = day == HijriCalendar.now().hDay &&
          _selectedHijriDate.hMonth == HijriCalendar.now().hMonth &&
          _selectedHijriDate.hYear == HijriCalendar.now().hYear;

      final hasEvent = _getEventsForDay(hijriDay).isNotEmpty;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedHijriDate = hijriDay;
              _selectedGregorianDate = hijriDay.toGregorian();
            });
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF667eea) : null,
              borderRadius: BorderRadius.circular(12),
              border: hasEvent
                  ? Border.all(color: const Color(0xFF667eea), width: 1.5)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isToday
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasEvent && !isToday)
                  const Positioned(
                    bottom: 4,
                    child: Icon(
                      Icons.circle,
                      size: 4,
                      color: Color(0xFF667eea),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      children: dayWidgets,
    );
  }

  Widget _buildTodayEvents(List<Map<String, dynamic>> events, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎉 مناسبات اليوم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...events.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event['color'] as Color,
                    (event['color'] as Color).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    event['icon'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthInfo(Map<String, dynamic> info, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                info['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات عن ${info['name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: info['type'] == 'حرام'
                            ? Colors.red.withOpacity(0.1)
                            : (info['type'] == 'مبارك'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        info['type'],
                        style: TextStyle(
                          fontSize: 11,
                          color: info['type'] == 'حرام'
                              ? Colors.red
                              : (info['type'] == 'مبارك'
                              ? Colors.green
                              : Colors.blue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            info['description'],
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info['virtue'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthEvents(bool isDark) {
    final monthStr = _selectedHijriDate.hMonth.toString();
    final events = _islamicEvents[monthStr];

    if (events == null || events.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 مناسبات الشهر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...events.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (event['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (event['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        event['icon'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event['day']} ${_hijriMonths[_selectedHijriDate.hMonth - 1]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event['isHoliday'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'عطلة',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthsGrid(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📆 الأشهر الهجرية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isCurrent = month == _selectedHijriDate.hMonth;
              final info = _monthsInfo[month]!;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHijriDate = HijriCalendar()
                      ..hYear = _selectedHijriDate.hYear
                      ..hMonth = month
                      ..hDay = 1;
                    _selectedGregorianDate = _selectedHijriDate.toGregorian();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isCurrent
                        ? const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    )
                        : null,
                    color: isCurrent
                        ? null
                        : (isDark ? const Color(0xFF1e1e1e) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: info['type'] == 'حرام'
                        ? Border.all(
                      color: Colors.red.withOpacity(0.5),
                      width: 2,
                    )
                        : (info['type'] == 'مبارك'
                        ? Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 2,
                    )
                        : null),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        info['icon'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hijriMonths[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withOpacity(0.1),
            const Color(0xFF764ba2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text('📖', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(
            '﴿ إِنَّ عِدَّةَ الشُّهُورِ عِندَ اللَّهِ اثْنَا عَشَرَ شَهْرًا ﴾',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'سورة التوبة - 36',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}