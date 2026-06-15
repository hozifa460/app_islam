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
    weekDays = ['ظ†', 'ط«', 'ط±', 'ط®', 'ط¬', 'ط³', 'ط­'];
    arabicMonths = ['ظٹظ†ط§ظٹط±', 'ظپط¨ط±ط§ظٹط±', 'ظ…ط§ط±ط³', 'ط£ط¨ط±ظٹظ„', 'ظ…ط§ظٹظˆ', 'ظٹظˆظ†ظٹظˆ', 'ظٹظˆظ„ظٹظˆ', 'ط£ط؛ط³ط·ط³', 'ط³ط¨طھظ…ط¨ط±', 'ط£ظƒطھظˆط¨ط±', 'ظ†ظˆظپظ…ط¨ط±', 'ط¯ظٹط³ظ…ط¨ط±'];
    hijriMonths = ['ظ…ط­ط±ظ…', 'طµظپط±', 'ط±ط¨ظٹط¹ ط§ظ„ط£ظˆظ„', 'ط±ط¨ظٹط¹ ط§ظ„ط¢ط®ط±', 'ط¬ظ…ط§ط¯ظ‰ ط§ظ„ط£ظˆظ„ظ‰', 'ط¬ظ…ط§ط¯ظ‰ ط§ظ„ط¢ط®ط±ط©', 'ط±ط¬ط¨', 'ط´ط¹ط¨ط§ظ†', 'ط±ظ…ط¶ط§ظ†', 'ط´ظˆط§ظ„', 'ط°ظˆ ط§ظ„ظ‚ط¹ط¯ط©', 'ط°ظˆ ط§ظ„ط­ط¬ط©'];
    islamicFacts = ['ط§ظ„طھظ‚ظˆظٹظ… ط§ظ„ظ‡ط¬ط±ظٹ ظٹط¨ط¯ط£ ظ…ظ† ظ‡ط¬ط±ط© ط§ظ„ظ†ط¨ظٹ ï·؛ ظ…ظ† ظ…ظƒط© ط¥ظ„ظ‰ ط§ظ„ظ…ط¯ظٹظ†ط©.'];
    hijriEvents = {'1-10': {'title': 'ظٹظˆظ… ط¹ط§ط´ظˆط±ط§ط،', 'desc': 'ظ…ظ† ط§ظ„ط£ظٹط§ظ… ط§ظ„ظ…ط³طھط­ط¨ طµظٹط§ظ…ظ‡ط§.'}};
    hijriNotes = {'1-10': {'title': 'ظ…ط¹ظ„ظˆظ…ط©', 'desc': 'ظٹط³طھط­ط¨ طµظٹط§ظ… ظٹظˆظ… ط¹ط§ط´ظˆط±ط§ط،.'}};
    upcomingEvents = [{'month': 1, 'day': 10, 'title': 'ظٹظˆظ… ط¹ط§ط´ظˆط±ط§ط،'}];
  }
}