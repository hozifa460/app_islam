// lib/screens/hijri_screen.dart

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../utils/higri_extention.dart';

class HijriScreen extends StatefulWidget {
  const HijriScreen({super.key});

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  late HijriCalendar _currentHijri;
  late DateTime _currentGregorian;
  int _selectedDay = 0;

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

  // أسماء أيام الأسبوع
  final List<String> _weekDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final List<String> _weekDaysShort = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  // المناسبات الإسلامية
  final Map<String, List<Map<String, dynamic>>> _events = {
    '1-1': [
      {'name': 'رأس السنة الهجرية', 'icon': '🌙', 'color': Color(0xFF667eea)},
    ],
    '1-10': [
      {'name': 'يوم عاشوراء', 'icon': '📿', 'color': Color(0xFF11998e)},
    ],
    '3-12': [
      {'name': 'المولد النبوي الشريف', 'icon': '💚', 'color': Color(0xFF2E7D32)},
    ],
    '7-27': [
      {'name': 'الإسراء والمعراج', 'icon': '✨', 'color': Color(0xFF9C27B0)},
    ],
    '8-15': [
      {'name': 'ليلة النصف من شعبان', 'icon': '🌕', 'color': Color(0xFFFFD700)},
    ],
    '9-1': [
      {'name': 'أول رمضان', 'icon': '🌙', 'color': Color(0xFF667eea)},
    ],
    '9-27': [
      {'name': 'ليلة القدر (المرجحة)', 'icon': '⭐', 'color': Color(0xFFFFD700)},
    ],
    '10-1': [
      {'name': 'عيد الفطر المبارك', 'icon': '🎉', 'color': Color(0xFF4CAF50)},
    ],
    '12-9': [
      {'name': 'يوم عرفة', 'icon': '🤲', 'color': Color(0xFFFF9800)},
    ],
    '12-10': [
      {'name': 'عيد الأضحى المبارك', 'icon': '🐑', 'color': Color(0xFFE91E63)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _currentHijri = HijriCalendar.now();
    _currentGregorian = DateTime.now();
    _selectedDay = _currentHijri.hDay;
  }

  void _previousMonth() {
    setState(() {
      int newMonth = _currentHijri.hMonth - 1;
      int newYear = _currentHijri.hYear;

      if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }

      _currentHijri = HijriCalendar()
        ..hYear = newYear
        ..hMonth = newMonth
        ..hDay = 1;

      _currentGregorian = _currentHijri.toGregorian();
      _selectedDay = 1;
    });
  }

  void _nextMonth() {
    setState(() {
      int newMonth = _currentHijri.hMonth + 1;
      int newYear = _currentHijri.hYear;

      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      }

      _currentHijri = HijriCalendar()
        ..hYear = newYear
        ..hMonth = newMonth
        ..hDay = 1;

      _currentGregorian = _currentHijri.toGregorian();
      _selectedDay = 1;
    });
  }

  void _goToToday() {
    setState(() {
      _currentHijri = HijriCalendar.now();
      _currentGregorian = DateTime.now();
      _selectedDay = _currentHijri.hDay;
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
      _currentHijri = HijriCalendar()
        ..hYear = _currentHijri.hYear
        ..hMonth = _currentHijri.hMonth
        ..hDay = day;
      _currentGregorian = _currentHijri.toGregorian();
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(int month, int day) {
    final key = '$month-$day';
    return _events[key] ?? [];
  }

  bool _hasEvent(int month, int day) {
    return _getEventsForDay(month, day).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayEvents = _getEventsForDay(_currentHijri.hMonth, _selectedDay);
    final isToday = _selectedDay == HijriCalendar.now().hDay &&
        _currentHijri.hMonth == HijriCalendar.now().hMonth &&
        _currentHijri.hYear == HijriCalendar.now().hYear;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0a0a0a) : const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ═══════════════════════════════════════════════════════
          // الهيدر الرئيسي
          // ═══════════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF667eea),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(isDark, isToday),
            ),
            actions: [
              IconButton(
                onPressed: _goToToday,
                icon: const Icon(Icons.today),
                tooltip: 'اليوم',
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════
          // التقويم
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: _buildCalendarCard(isDark),
          ),

          // ═══════════════════════════════════════════════════════
          // تفاصيل اليوم المحدد
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: _buildSelectedDayDetails(isDark, isToday),
          ),

          // ═══════════════════════════════════════════════════════
          // مناسبات اليوم
          // ═══════════════════════════════════════════════════════
          if (todayEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildEventsList(todayEvents, isDark),
            ),

          // ═══════════════════════════════════════════════════════
          // محول التاريخ
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: _buildDateConverter(isDark),
          ),

          // ═══════════════════════════════════════════════════════
          // المناسبات القادمة
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: _buildUpcomingEvents(isDark),
          ),

          // ═══════════════════════════════════════════════════════
          // معلومات الشهر
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: _buildMonthInfo(isDark),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // الهيدر
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark, bool isToday) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // الأيقونة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: const Center(
                child: Text('🌙', style: TextStyle(fontSize: 40)),
              ),
            ),

            const SizedBox(height: 20),

            // التاريخ الهجري الكبير
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$_selectedDay',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hijriMonths[_currentHijri.hMonth - 1],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_currentHijri.hYear} هـ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // شارة اليوم
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'اليوم',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // بطاقة التقويم
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCalendarCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط التنقل بين الأشهر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // السهم الأيمن (الشهر السابق)
              _buildNavButton(Icons.chevron_right, _previousMonth),

              // اسم الشهر والسنة
              GestureDetector(
                onTap: () => _showMonthPicker(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _hijriMonths[_currentHijri.hMonth - 1],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF667eea),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentHijri.hYear}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              // السهم الأيسر (الشهر التالي)
              _buildNavButton(Icons.chevron_left, _nextMonth),
            ],
          ),

          const SizedBox(height: 20),

          // أسماء الأيام
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDaysShort.map((day) {
              final isJumaa = day == 'ج';
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isJumaa
                          ? const Color(0xFF667eea)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // شبكة الأيام
          _buildDaysGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid(bool isDark) {
    final daysInMonth = _currentHijri.lengthOfMonth;

    // حساب أول يوم في الشهر
    final firstDay = HijriCalendar()
      ..hYear = _currentHijri.hYear
      ..hMonth = _currentHijri.hMonth
      ..hDay = 1;

    final gregorianFirst = firstDay.toGregorian();
    final startWeekday = gregorianFirst.weekday % 7;

    // التاريخ الهجري الحالي
    final todayHijri = HijriCalendar.now();

    List<Widget> dayWidgets = [];

    // مساحات فارغة قبل أول يوم
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 44));
    }

    // أيام الشهر
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = day == _selectedDay;
      final isToday = day == todayHijri.hDay &&
          _currentHijri.hMonth == todayHijri.hMonth &&
          _currentHijri.hYear == todayHijri.hYear;
      final hasEvent = _hasEvent(_currentHijri.hMonth, day);

      dayWidgets.add(
        GestureDetector(
          onTap: () => _selectDay(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 44,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              )
                  : null,
              color: isSelected
                  ? null
                  : (isToday
                  ? const Color(0xFF667eea).withOpacity(0.15)
                  : null),
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF667eea), width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: (isSelected || isToday)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                if (hasEvent)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
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

  // ══════════════════════════════════════════════════════════════════
  // تفاصيل اليوم المحدد
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSelectedDayDetails(bool isDark, bool isToday) {
    // حساب التاريخ الميلادي المقابل
    final selectedHijri = HijriCalendar()
      ..hYear = _currentHijri.hYear
      ..hMonth = _currentHijri.hMonth
      ..hDay = _selectedDay;

    final gregorianDate = selectedHijri.toGregorian();
    final dayName = _weekDays[gregorianDate.weekday % 7];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF11998e).withOpacity(isDark ? 0.3 : 1),
            const Color(0xFF38ef7d).withOpacity(isDark ? 0.3 : 1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11998e).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // اليوم في الأسبوع
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_view_day,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يوم $dayName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_selectedDay ${_hijriMonths[_currentHijri.hMonth - 1]} ${_currentHijri.hYear} هـ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '📍',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // التاريخ الميلادي
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('d MMMM yyyy', 'ar').format(gregorianDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'م',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // قائمة المناسبات
  // ══════════════════════════════════════════════════════════════════
  Widget _buildEventsList(List<Map<String, dynamic>> events, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'مناسبة هذا اليوم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...events.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event['color'] as Color,
                    (event['color'] as Color).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (event['color'] as Color).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event['icon'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      event['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // محول التاريخ
  // ══════════════════════════════════════════════════════════════════
  Widget _buildDateConverter(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
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
              const Text('🔄', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'تحويل التاريخ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // الهجري
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      const Text(
                        'هجري',
                        style: TextStyle(
                          color: Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_selectedDay/${_currentHijri.hMonth}/${_currentHijri.hYear}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // السهم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.swap_horiz,
                  color: Colors.grey[400],
                  size: 28,
                ),
              ),

              // الميلادي
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      const Text(
                        'ميلادي',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d/M/yyyy').format(_currentGregorian),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // المناسبات القادمة
  // ══════════════════════════════════════════════════════════════════
  Widget _buildUpcomingEvents(bool isDark) {
    List<Map<String, dynamic>> upcoming = [];

    _events.forEach((key, events) {
      final parts = key.split('-');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);

      for (var event in events) {
        int daysRemaining;
        if (month > _currentHijri.hMonth ||
            (month == _currentHijri.hMonth && day > _selectedDay)) {
          daysRemaining = (month - _currentHijri.hMonth) * 30 + (day - _selectedDay);
        } else {
          daysRemaining =
              (12 - _currentHijri.hMonth + month) * 30 + (day - _selectedDay);
        }

        if (daysRemaining > 0 && daysRemaining <= 90) {
          upcoming.add({
            ...event,
            'month': month,
            'day': day,
            'daysRemaining': daysRemaining,
          });
        }
      }
    });

    upcoming.sort(
            (a, b) => (a['daysRemaining'] as int).compareTo(b['daysRemaining'] as int));

    if (upcoming.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📆', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'المناسبات القادمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.take(5).map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
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
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: (event['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        event['icon'],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${event['day']} ${_hijriMonths[event['month'] - 1]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (event['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'بعد ${event['daysRemaining']} يوم',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: event['color'] as Color,
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

  // ══════════════════════════════════════════════════════════════════
  // معلومات الشهر
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMonthInfo(bool isDark) {
    final monthName = _hijriMonths[_currentHijri.hMonth - 1];
    final isHaram = [1, 7, 11, 12].contains(_currentHijri.hMonth);
    final isRamadan = _currentHijri.hMonth == 9;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRamadan
              ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
              : (isHaram
              ? [const Color(0xFFf5af19), const Color(0xFFf12711)]
              : [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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
                  isRamadan ? '🌙' : (isHaram ? '⭐' : '📅'),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شهر $monthName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isRamadan
                            ? 'شهر الصيام'
                            : (isHaram ? 'من الأشهر الحرم' : 'شهر مبارك'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getMonthVirtue(_currentHijri.hMonth),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      height: 1.4,
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

  String _getMonthVirtue(int month) {
    final virtues = {
      1: 'أفضل الصيام بعد رمضان صيام شهر الله المحرم',
      2: 'لا تشاؤم في صفر، فهو شهر من شهور الله',
      3: 'شهر مولد النبي محمد ﷺ',
      4: 'أكثر من الاستغفار والذكر',
      5: 'واصل على العمل الصالح',
      6: 'استعد لشهر رجب المبارك',
      7: 'من الأشهر الحرم، أكثر من العبادة',
      8: 'كان النبي ﷺ يكثر الصيام في شعبان',
      9: 'شهر القرآن والصيام وليلة القدر',
      10: 'صيام 6 أيام من شوال مع رمضان كصيام الدهر',
      11: 'من الأشهر الحرم، فأكثر من الطاعات',
      12: 'العشر الأوائل أفضل أيام الدنيا للعمل الصالح',
    };
    return virtues[month] ?? 'شهر مبارك';
  }

  // ══════════════════════════════════════════════════════════════════
  // اختيار الشهر
  // ══════════════════════════════════════════════════════════════════
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // المقبض
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'اختر الشهر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isCurrent = month == _currentHijri.hMonth;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentHijri = HijriCalendar()
                            ..hYear = _currentHijri.hYear
                            ..hMonth = month
                            ..hDay = 1;
                          _selectedDay = 1;
                          _currentGregorian = _currentHijri.toGregorian();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isCurrent
                              ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                              : null,
                          color: isCurrent ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _hijriMonths[index],
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}