import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sunnah_model.dart';

class SunnahService {
  static const String _completedKey = 'completed_sunnahs_';

  List<SunnahModel> _allSunnahs = [];
  Map<String, PrayerTimeCategory> _categories = {};

  // ==================== تحميل البيانات ====================
  Future<void> loadData() async {
    final String jsonString = await rootBundle.loadString('assets/json/sunnan.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _allSunnahs = (jsonData['sunnahs'] as List)
        .map((s) => SunnahModel.fromJson(s))
        .toList();

    final categoriesJson = jsonData['prayer_times_categories'] as Map<String, dynamic>;
    _categories = categoriesJson.map(
          (key, value) => MapEntry(
        key,
        PrayerTimeCategory.fromJson(key, value),
      ),
    );

    await _loadCompletionStatus();
  }

  // ==================== تحميل حالة الإكمال ====================
  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();

    for (var sunnah in _allSunnahs) {
      final key = '$_completedKey${today}_${sunnah.id}';
      sunnah.isCompleted = prefs.getBool(key) ?? false;
    }
  }

  // ==================== حفظ حالة الإكمال ====================
  Future<void> toggleCompletion(int sunnahId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final key = '$_completedKey${today}_$sunnahId';

    final sunnah = _allSunnahs.firstWhere((s) => s.id == sunnahId);
    sunnah.isCompleted = !sunnah.isCompleted;
    await prefs.setBool(key, sunnah.isCompleted);
  }

  // ==================== الحصول على السنن حسب الوقت ====================
  List<SunnahModel> getCurrentSunnahs() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday; // 1=Monday, 7=Sunday

    return _allSunnahs.where((sunnah) {
      return _isSunnahApplicableNow(sunnah, currentHour, currentDay);
    }).toList();
  }

  bool _isSunnahApplicableNow(SunnahModel sunnah, int currentHour, int currentDay) {
    switch (sunnah.timeCategory) {
      case 'always':
        return true;

      case 'weekly_fast':
      // الاثنين = 1، الخميس = 4
        return currentDay == 1 || currentDay == 4;

      case 'friday':
        return currentDay == 5; // الجمعة

      case 'monthly_fast':
        final dayOfMonth = DateTime.now().day;
        return dayOfMonth == 13 || dayOfMonth == 14 || dayOfMonth == 15;

      case 'fajr':
        return currentHour >= 4 && currentHour < 6;

      case 'morning_adhkar':
        return currentHour >= 5 && currentHour < 8;

      case 'duha':
        return currentHour >= 8 && currentHour < 12;

      case 'dhuhr':
        return currentHour >= 11 && currentHour < 14;

      case 'asr':
        return currentHour >= 14 && currentHour < 17;

      case 'evening_adhkar':
        return currentHour >= 15 && currentHour < 18;

      case 'maghrib':
        return currentHour >= 17 && currentHour < 20;

      case 'isha':
        return currentHour >= 19 && currentHour < 23;

      case 'witr':
        return currentHour >= 20 && currentHour < 24;

      case 'tahajjud':
        return currentHour >= 1 && currentHour < 5;

      case 'sleep':
        return currentHour >= 21 || currentHour < 2;

      case 'yearly_fast':
      // تظهر دائماً للتذكير - يمكن تخصيصها لاحقاً بالتاريخ الهجري
        return true;

      case 'yearly_prayer':
        return true;

      default:
        return false;
    }
  }

  // ==================== الحصول على جميع السنن ====================
  List<SunnahModel> getAllSunnahs() => _allSunnahs;

  // ==================== الحصول على السنن حسب الفئة ====================
  List<SunnahModel> getSunnahsByCategory(String category) {
    return _allSunnahs.where((s) => s.timeCategory == category).toList();
  }

  // ==================== إحصائيات ====================
  int get totalSunnahs => _allSunnahs.length;
  int get completedToday => _allSunnahs.where((s) => s.isCompleted).length;
  double get completionPercentage =>
      totalSunnahs > 0 ? (completedToday / totalSunnahs) * 100 : 0;

  // ==================== مساعدات ====================
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  Map<String, PrayerTimeCategory> get categories => _categories;

  String getCategoryLabel(String category) {
    return _categories[category]?.label ?? category;
  }

  String getCurrentPeriodLabel() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 6) return 'وقت الفجر';
    if (hour >= 6 && hour < 8) return 'الصباح';
    if (hour >= 8 && hour < 12) return 'الضحى';
    if (hour >= 12 && hour < 14) return 'وقت الظهر';
    if (hour >= 14 && hour < 17) return 'وقت العصر';
    if (hour >= 17 && hour < 20) return 'وقت المغرب';
    if (hour >= 20 && hour < 23) return 'وقت العشاء';
    if (hour >= 23 || hour < 2) return 'وقت النوم';
    if (hour >= 1 && hour < 4) return 'قيام الليل';
    return 'وقت الراحة';
  }
}