import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../sunnah/model/sunnah_model.dart';

class SunnahService {
  static final SunnahService _instance = SunnahService._internal();
  factory SunnahService() => _instance;
  SunnahService._internal();

  List<SunnahModel> _sunnahs = [];
  Set<int> _completedIds = {};
  bool _isLoaded = false;

  List<SunnahModel> get allSunnahs => _sunnahs;
  int get totalSunnahs => _sunnahs.length;
  int get completedToday => _completedIds.length;
  double get completionPercentage =>
      totalSunnahs > 0 ? (completedToday / totalSunnahs) * 100 : 0;

  static const List<String> _orderedPeriods = [
    'fajr',
    'morning_adhkar',
    'duha',
    'dhuhr',
    'asr',
    'evening_adhkar',
    'maghrib',
    'isha',
    'witr',
    'tahajjud',
  ];

  Future<void> loadData() async {
    if (_isLoaded) {
      await _loadCompletedFromPrefs();
      return;
    }
    try {
      final jsonString =
      await rootBundle.loadString('assets/data/sunnahs.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _sunnahs = jsonList.map((e) => SunnahModel.fromJson(e)).toList();
      await _loadCompletedFromPrefs();
      _isLoaded = true;
    } catch (e) {
      print('Error loading sunnahs: $e');
      _sunnahs = [];
    }
  }

  Future<void> _loadCompletedFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final savedIds =
          prefs.getStringList('completed_sunnahs_$today') ?? [];
      _completedIds =
          savedIds.map((s) => int.tryParse(s) ?? 0).toSet();
      for (var sunnah in _sunnahs) {
        sunnah.isCompleted = _completedIds.contains(sunnah.id);
      }
    } catch (e) {
      print('Error loading completed: $e');
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ─── الفترة الحالية ───
  String getCurrentPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 6) return 'fajr';
    if (hour >= 6 && hour < 9) return 'morning_adhkar';
    if (hour >= 9 && hour < 12) return 'duha';
    if (hour >= 12 && hour < 15) return 'dhuhr';
    if (hour >= 15 && hour < 17) return 'asr';
    if (hour >= 17 && hour < 19) return 'evening_adhkar';
    if (hour >= 19 && hour < 20) return 'maghrib';
    if (hour >= 20 && hour < 22) return 'isha';
    if (hour >= 22 || hour < 1) return 'witr';
    return 'tahajjud';
  }

  // ─── تسمية الفترة ───
  String getPeriodLabel(String period) {
    const labels = {
      'fajr': 'وقت الفجر',
      'morning_adhkar': 'أذكار الصباح',
      'duha': 'وقت الضحى',
      'dhuhr': 'وقت الظهر',
      'asr': 'وقت العصر',
      'evening_adhkar': 'أذكار المساء',
      'maghrib': 'وقت المغرب',
      'isha': 'وقت العشاء',
      'witr': 'وقت الوتر',
      'tahajjud': 'وقت التهجد',
    };
    return labels[period] ?? period;
  }

  // ─── سنن فترة معينة ───
  List<SunnahModel> getSunnahsForPeriod(String period) {
    final weekday = DateTime.now().weekday;
    final result = <SunnahModel>[];
    result.addAll(_sunnahs.where((s) => s.timeCategory == period));
    result.addAll(_sunnahs.where((s) => s.timeCategory == 'always'));
    if (weekday == 5) {
      result.addAll(
          _sunnahs.where((s) => s.timeCategory == 'friday'));
    }
    return result;
  }

  // ─── معلومات الفترة التالية ───
  NextPeriodInfo? getNextPeriodInfo() {
    final cur = getCurrentPeriod();
    final idx = _orderedPeriods.indexOf(cur);
    if (idx == -1) return null;

    for (int i = 1; i < _orderedPeriods.length; i++) {
      final nextPeriod =
      _orderedPeriods[(idx + i) % _orderedPeriods.length];

      final list = _sunnahs
          .where((s) => s.timeCategory == nextPeriod)
          .toList();

      if (list.isEmpty) continue;

      final sunnah = list.firstWhere(
            (s) => !s.isCompleted,
        orElse: () => list.first,
      );

      return NextPeriodInfo(
        sunnah: sunnah,
        periodLabel: getPeriodLabel(nextPeriod),
      );
    }
    return null;
  }

  // ─── السنن الحالية ───
  List<SunnahModel> getCurrentSunnahs() {
    final weekday = DateTime.now().weekday;
    final currentPeriod = getCurrentPeriod();
    final result = <SunnahModel>[];
    result.addAll(
        _sunnahs.where((s) => s.timeCategory == currentPeriod));
    result.addAll(
        _sunnahs.where((s) => s.timeCategory == 'always'));
    if (weekday == 5) {
      result.addAll(
          _sunnahs.where((s) => s.timeCategory == 'friday'));
    }
    return result;
  }

  List<SunnahModel> getAllSunnahs() => _sunnahs;

  String getCurrentPeriodLabel() =>
      getPeriodLabel(getCurrentPeriod());

  String getCategoryLabel(String category) {
    const labels = {
      'fajr': 'سنن الفجر',
      'morning_adhkar': 'أذكار الصباح',
      'duha': 'صلاة الضحى',
      'dhuhr': 'سنن الظهر',
      'asr': 'سنن العصر',
      'evening_adhkar': 'أذكار المساء',
      'maghrib': 'سنن المغرب',
      'isha': 'سنن العشاء',
      'witr': 'صلاة الوتر',
      'tahajjud': 'قيام الليل',
      'sleep': 'سنن النوم',
      'always': 'سنن دائمة',
      'weekly_fast': 'صيام أسبوعي',
      'monthly_fast': 'صيام شهري',
      'friday': 'سنن الجمعة',
      'yearly_fast': 'صيام سنوي',
      'yearly_prayer': 'صلوات سنوية',
    };
    return labels[category] ?? category;
  }

  Future<void> toggleCompletion(int id) async {
    final index = _sunnahs.indexWhere((s) => s.id == id);
    if (index == -1) return;

    _sunnahs[index].isCompleted = !_sunnahs[index].isCompleted;

    if (_sunnahs[index].isCompleted) {
      _completedIds.add(id);
    } else {
      _completedIds.remove(id);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      await prefs.setStringList(
        'completed_sunnahs_$today',
        _completedIds.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      print('Error saving completed: $e');
    }
  }

  Future<void> resetForNewDay() async {
    _completedIds.clear();
    for (var sunnah in _sunnahs) {
      sunnah.isCompleted = false;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      await prefs.setStringList('completed_sunnahs_$today', []);
    } catch (e) {
      print('Error resetting: $e');
    }
  }
}

// ─── Model ───
class NextPeriodInfo {
  final SunnahModel sunnah;
  final String periodLabel;
  NextPeriodInfo({required this.sunnah, required this.periodLabel});
}