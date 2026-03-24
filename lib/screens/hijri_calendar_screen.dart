import 'package:flutter/material.dart';
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

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  int _factOffset = 0;

  final List<String> _weekDays = const [
    'ن',
    'ث',
    'ر',
    'خ',
    'ج',
    'س',
    'ح',
  ];

  final List<String> _arabicMonths = const [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final List<String> _dailyIslamicFacts = const [
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

  final List<String> _hijriMonths = const [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  String _formatArabicNumber(int n) {
    const arabicNums = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return n
        .toString()
        .split('')
        .map((e) => arabicNums[e] ?? e)
        .join();
  }

  String _getArabicWeekday(DateTime date) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[(date.weekday - 1) % 7];
  }

  String _getDailyIslamicFact(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day + _factOffset;
    return _dailyIslamicFacts[seed % _dailyIslamicFacts.length];
  }

  Map<String, String>? _getHijriEvent(HijriCalendar hijriDate) {
    final hDay = hijriDate.hDay;
    final hMonth = hijriDate.hMonth;

    if (hMonth == 1 && hDay == 10) {
      return {
        'title': 'يوم عاشوراء',
        'desc': 'من الأيام المستحب صيامها، وله فضل عظيم.',
      };
    }

    if (hMonth == 3 && hDay == 12) {
      return {
        'title': 'المولد النبوي',
        'desc': 'ذكرى مولد النبي ﷺ وفق بعض التواريخ المشهورة.',
      };
    }

    if (hMonth == 7 && hDay == 27) {
      return {
        'title': 'الإسراء والمعراج',
        'desc': 'ليلة مباركة ارتبطت بالإسراء والمعراج.',
      };
    }

    if (hMonth == 8 && hDay == 15) {
      return {
        'title': 'ليلة النصف من شعبان',
        'desc': 'ليلة مباركة يعتني بها كثير من المسلمين.',
      };
    }

    if (hMonth == 9 && hDay == 1) {
      return {
        'title': 'بداية رمضان',
        'desc': 'بداية شهر رمضان المبارك.',
      };
    }

    if (hMonth == 9 && hDay == 27) {
      return {
        'title': 'ليلة القدر (مرجحة)',
        'desc': 'من أعظم ليالي العام، وتُطلب في العشر الأواخر.',
      };
    }

    if (hMonth == 10 && hDay == 1) {
      return {
        'title': 'عيد الفطر',
        'desc': 'يوم فرح للمسلمين بعد تمام صيام رمضان.',
      };
    }

    if (hMonth == 12 && hDay == 9) {
      return {
        'title': 'يوم عرفة',
        'desc': 'من أفضل أيام السنة، ويستحب صيامه لغير الحاج.',
      };
    }

    if (hMonth == 12 && hDay == 10) {
      return {
        'title': 'عيد الأضحى',
        'desc': 'يوم النحر وأحد أعظم أيام المسلمين.',
      };
    }

    return null;
  }

  bool _hasHijriEvent(DateTime date) {
    final hijri = _getHijriDate(date);
    return _getHijriEvent(hijri) != null;
  }

  Future<void> _shareHijriEvent(Map<String, String> event, HijriCalendar hijriDate) async {
    final text = '''
${event['title']}

${event['desc']}

التاريخ الهجري:
${_formatArabicNumber(hijriDate.hDay)} ${_hijriMonths[hijriDate.hMonth - 1]} ${_formatArabicNumber(hijriDate.hYear)}
''';

    await Share.share(text.trim());
  }

  Future<void> _shareIslamicFact(String fact) async {
    await Share.share('هل تعلم؟\n\n$fact');
  }

  HijriCalendar _getHijriDate(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final startWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    final List<DateTime> days = [];

    for (int i = 0; i < startWeekday; i++) {
      days.add(firstDayOfMonth.subtract(Duration(days: startWeekday - i)));
    }

    for (int i = 1; i <= totalDays; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, String>? _getHijriEventNote(HijriCalendar hijriDate) {
    final hDay = hijriDate.hDay;
    final hMonth = hijriDate.hMonth;

    if (hMonth == 1 && hDay == 10) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'يستحب صيام يوم عاشوراء، ويُسن أن يُضم إليه يوم قبله أو بعده مخالفةً لليهود.',
      };
    }

    if (hMonth == 9 && hDay == 1) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'رمضان شهر الصيام والقيام وتلاوة القرآن، وفيه تُفتح أبواب الرحمة والمغفرة.',
      };
    }

    if (hMonth == 9 && hDay == 27) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'ليلة القدر تُلتمس في العشر الأواخر، وخاصة الليالي الوترية، وهي خير من ألف شهر.',
      };
    }

    if (hMonth == 10 && hDay == 1) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'يوم العيد يوم فرح وشكر، ويُسن فيه إظهار السرور وصلة الأرحام.',
      };
    }

    if (hMonth == 12 && hDay == 9) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'صيام يوم عرفة لغير الحاج يكفّر سنتين: الماضية والباقية بإذن الله.',
      };
    }

    if (hMonth == 12 && hDay == 10) {
      return {
        'title': 'معلومة شرعية',
        'desc': 'عيد الأضحى من أعظم الأيام، وتُشرع فيه الأضحية لمن استطاع.',
      };
    }

    return null;
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF8F6F1);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final gold = const Color(0xFFE6B325);

    final hijriDate = _getHijriDate(_selectedDate);
    final hijriEvent = _getHijriEvent(hijriDate);
    final hijriNote = _getHijriEventNote(hijriDate);
    final dailyFact = _getDailyIslamicFact(_selectedDate);
    final days = _generateCalendarDays(_displayedMonth);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التقويم الهجري',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // بطاقة التاريخ الحالي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor,
                      widget.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _getArabicWeekday(_selectedDate),
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_formatArabicNumber(hijriDate.hDay)} ${_hijriMonths[hijriDate.hMonth - 1]} ${_formatArabicNumber(hijriDate.hYear)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate),
                      style: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // بطاقة معلومات مختصرة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: gold.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _infoTile(
                        title: 'اليوم الهجري',
                        value: _formatArabicNumber(hijriDate.hDay),
                        color: widget.primaryColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        title: 'الشهر الهجري',
                        value: _hijriMonths[hijriDate.hMonth - 1],
                        color: widget.primaryColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        title: 'السنة الهجرية',
                        value: _formatArabicNumber(hijriDate.hYear),
                        color: widget.primaryColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              if (hijriNote != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151B26) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.16 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          color: widget.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hijriNote['title']!,
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: widget.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hijriNote['desc']!,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                height: 1.75,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151B26) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gold.withOpacity(0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.16 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _shareIslamicFact(dailyFact),
                          icon: Icon(
                            Icons.share_rounded,
                            color: gold,
                            size: 20,
                          ),
                          tooltip: 'مشاركة',
                        ),
                        const Spacer(),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: gold,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'هل تعلم؟',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dailyFact,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.75,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // بطاقة التقويم
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // الهيدر الشهري
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month - 1,
                                1,
                              );
                            });
                          },
                          icon: Icon(Icons.chevron_left, color: widget.primaryColor),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_arabicMonths[_displayedMonth.month - 1]} ${_formatArabicNumber(_displayedMonth.year)}',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_hijriMonths[_getHijriDate(_displayedMonth).hMonth - 1]} ${_formatArabicNumber(_getHijriDate(_displayedMonth).hYear)}',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month + 1,
                                1,
                              );
                            });
                          },
                          icon: Icon(Icons.chevron_right, color: widget.primaryColor),
                        ),
                      ],
                    ),

                    if (hijriEvent != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.primaryColor.withOpacity(0.10),
                              gold.withOpacity(0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: gold.withOpacity(0.25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: gold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'مناسبة اليوم',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: gold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: gold, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  hijriEvent['title']!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              hijriEvent['desc']!,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                height: 1.7,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _shareHijriEvent(hijriEvent, hijriDate),
                                icon: Icon(
                                  Icons.share_rounded,
                                  color: widget.primaryColor,
                                  size: 18,
                                ),
                                label: Text(
                                  'مشاركة',
                                  style: GoogleFonts.cairo(
                                    color: widget.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // أيام الأسبوع
                    Row(
                      children: _weekDays.map((day) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: widget.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // شبكة الأيام
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: days.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isCurrentMonth = day.month == _displayedMonth.month;
                        final isToday = _isSameDate(day, today);
                        final isSelected = _isSameDate(day, _selectedDate);
                        final hasEvent = _hasHijriEvent(day);

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.primaryColor
                                  : isToday
                                  ? gold.withOpacity(0.18)
                                  : hasEvent
                                  ? widget.primaryColor.withOpacity(0.07)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: isToday && !isSelected
                                  ? Border.all(color: gold, width: 1.4)
                                  : hasEvent && !isSelected
                                  ? Border.all(color: widget.primaryColor.withOpacity(0.35), width: 1.0)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    _formatArabicNumber(day.day),
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : isCurrentMonth
                                          ? textColor
                                          : subTextColor.withOpacity(0.4),
                                    ),
                                  ),
                                ),

                                if (hasEvent)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: isSelected ? Colors.white : gold,
                                      shadows: [
                                        Shadow(
                                          color: gold.withOpacity(0.35),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}