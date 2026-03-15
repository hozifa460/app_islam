import 'package:hijri/hijri_calendar.dart';

extension HijriCalendarExtension on HijriCalendar {
  /// تحويل التاريخ الهجري إلى ميلادي
  DateTime toGregorian() {
    return hijriToGregorian(hYear, hMonth, hDay);
  }

  /// الحصول على اسم الشهر بالعربي
  String get monthNameArabic {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    return months[hMonth - 1];
  }

  /// الحصول على اسم اليوم بالعربي
  String get dayNameArabic {
    final gregorian = toGregorian();
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[gregorian.weekday - 1];
  }

  /// التاريخ الهجري كامل بالعربي
  String get fullDateArabic {
    return '$hDay $monthNameArabic $hYear هـ';
  }

  /// هل هذا اليوم هو اليوم الحالي؟
  bool get isToday {
    final today = HijriCalendar.now();
    return hDay == today.hDay &&
        hMonth == today.hMonth &&
        hYear == today.hYear;
  }

  /// نسخة جديدة من التاريخ مع يوم محدد
  HijriCalendar copyWithDay(int day) {
    return HijriCalendar()
      ..hYear = hYear
      ..hMonth = hMonth
      ..hDay = day;
  }

  /// نسخة جديدة من التاريخ مع شهر محدد
  HijriCalendar copyWithMonth(int month) {
    int newYear = hYear;
    int newMonth = month;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    return HijriCalendar()
      ..hYear = newYear
      ..hMonth = newMonth
      ..hDay = 1;
  }

  /// إضافة شهور
  HijriCalendar addMonths(int months) {
    int newMonth = hMonth + months;
    int newYear = hYear;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    return HijriCalendar()
      ..hYear = newYear
      ..hMonth = newMonth
      ..hDay = 1;
  }
}