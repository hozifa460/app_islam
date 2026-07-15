import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HijriData {
  static List<String> weekDays = [];
  static List<String> arabicMonths = [];
  static List<String> hijriMonths = [];
  static List<String> islamicFacts = [];
  static Map<String, Map<String, String>> hijriEvents = {};
  static Map<String, Map<String, String>> hijriNotes = {};
  static List<Map<String, dynamic>> upcomingEvents = [];

  static Future<void> loadData(String langCode) async {
    try {
      String jsonString;
      try {
        // ظ…ط­ط§ظˆظ„ط© ظ‚ط±ط§ط،ط© ظ„ط؛ط© ط§ظ„ط¬ظ‡ط§ط²
        jsonString = await rootBundle.loadString('assets/hijri/hijri_$langCode.json');
      } catch (_) {
        try {
          // ط¥ط°ط§ ظپط´ظ„طŒ ظٹط­ط§ظˆظ„ ظ‚ط±ط§ط،ط© ط§ظ„ط¹ط±ط¨ظٹ ظƒط§ط­طھظٹط§ط·ظٹ
          jsonString = await rootBundle.loadString('assets/hijri/hijri_ar.json');
        } catch (_) {
          // ط¥ط°ط§ ظپط´ظ„ ظƒظ„ ط´ظٹط، (ط§ظ„ظ…ظ„ظپط§طھ ط؛ظٹط± ظ…ظˆط¬ظˆط¯ط©)طŒ ظ†ظڈط­ظ…ظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„ط·ظˆط§ط±ط¦!
          _loadFallbackData();
          return;
        }
      }

      final Map<String, dynamic> data = json.decode(jsonString);

      weekDays = List<String>.from(data['weekDays']);
      arabicMonths = List<String>.from(data['arabicMonths']);
      hijriMonths = List<String>.from(data['hijriMonths']);
      islamicFacts = List<String>.from(data['islamicFacts']);

      hijriEvents = (data['hijriEvents'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
      );

      hijriNotes = (data['hijriNotes'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
      );

      upcomingEvents = List<Map<String, dynamic>>.from(data['upcomingEvents']);

    } catch (e) {
      debugPrint("Error loading Hijri Data: $e");
      // ظپظٹ ط­ط§ظ„ ظˆط¬ظˆط¯ ط®ط·ط£ ط¨ط¯ط§ط®ظ„ ط§ظ„ط¬ظٹط³ظˆظ† ظ†ظپط³ظ‡طŒ ظ†ط­ظ…ظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„ط·ظˆط§ط±ط¦
      _loadFallbackData();
    }
  }

  // ًں›،ï¸ڈ ط¯ط§ظ„ط© ط§ظ„ط·ظˆط§ط±ط¦: طھظ…ظ†ط¹ ط§ظ„ط´ط§ط´ط© ظ…ظ† ط§ظ„طھط¹ظ„ظٹظ‚ ظ„ظ„ط£ط¨ط¯
  static void _loadFallbackData() {
    weekDays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    arabicMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    hijriMonths = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
    islamicFacts = ['التقويم الهجري يبدأ من هجرة النبي ﷺ من مكة إلى المدينة.'];
    hijriEvents = {'1-10': {'title': 'يوم عاشوراء', 'desc': 'من الأيام المستحب صيامها.'}};
    hijriNotes = {'1-10': {'title': 'معلومة', 'desc': 'يستحب صيام يوم عاشوراء.'}};
    upcomingEvents = [{'month': 1, 'day': 10, 'title': 'يوم عاشوراء'}];
  }
}