import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

class StatsService extends ChangeNotifier {
  final AuthService _auth;

  static const _kStreak = 'stats_streak';
  static const _kTotalDays = 'stats_total_days';
  static const _kLastActiveDate = 'stats_last_active_date';
  static const _kActiveDates = 'stats_active_dates';

  int _streak = 0;
  int _totalDays = 0;
  String _lastActiveDate = '';
  Set<String> _activeDates = {};

  int get streak => _streak;
  int get totalDays => _totalDays;

  StatsService(this._auth);

  // ══════════════════════════════════════
  // التهيئة - يُستدعى عند فتح التطبيق
  // ══════════════════════════════════════
  Future<void> init() async {
    await _loadLocal();
    await _recordToday(); // سجّل دخول اليوم تلقائياً
    notifyListeners();
  }

  // ══════════════════════════════════════
  // تسجيل دخول اليوم تلقائياً
  // ══════════════════════════════════════
  Future<void> _recordToday() async {
    final today = _todayStr();

    // إذا سجّلنا اليوم مسبقاً → لا شيء
    if (_activeDates.contains(today)) return;

    // أضف اليوم
    _activeDates.add(today);
    _totalDays = _activeDates.length;

    // احسب السلسلة
    _calculateStreak();

    _lastActiveDate = today;

    await _saveLocal();
    await _saveCloud();
    notifyListeners();
  }

  // ══════════════════════════════════════
  // حساب السلسلة
  // ══════════════════════════════════════
  void _calculateStreak() {
    final today = DateTime.now();
    int count = 0;

    for (int i = 0; i < 3650; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _dateToStr(date);

      if (_activeDates.contains(dateStr)) {
        count++;
      } else {
        break; // كُسرت السلسلة
      }
    }

    _streak = count;
  }

  // ══════════════════════════════════════
  // التخزين المحلي
  // ══════════════════════════════════════
  Future<void> _loadLocal() async {
    final p = await SharedPreferences.getInstance();
    _streak = p.getInt(_kStreak) ?? 0;
    _totalDays = p.getInt(_kTotalDays) ?? 0;
    _lastActiveDate = p.getString(_kLastActiveDate) ?? '';

    final raw = p.getString(_kActiveDates);
    if (raw != null) {
      try {
        _activeDates = Set<String>.from(jsonDecode(raw));
      } catch (_) {
        _activeDates = {};
      }
    }

    // حاول تحميل من السحابة
    await _loadCloud();
  }

  Future<void> _saveLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kStreak, _streak);
    await p.setInt(_kTotalDays, _totalDays);
    await p.setString(_kLastActiveDate, _lastActiveDate);
    await p.setString(
      _kActiveDates,
      jsonEncode(_activeDates.toList()),
    );
  }

  // ══════════════════════════════════════
  // التخزين السحابي
  // ══════════════════════════════════════
  Future<void> _saveCloud() async {
    if (_auth.user == null || _auth.user!.isGuest) return;
    try {
      await _auth.saveProgress('stats', {
        'streak': _streak,
        'totalDays': _totalDays,
        'lastActiveDate': _lastActiveDate,
        'activeDates': _activeDates.toList(),
      });
    } catch (_) {}
  }

  Future<void> _loadCloud() async {
    if (_auth.user == null || _auth.user!.isGuest) return;
    try {
      final data = await _auth.loadProgress('stats');
      if (data == null || data is! Map) return;

      final cloudDays = data['totalDays'] as int? ?? 0;

      // استخدم السحابي إذا كان أكثر
      if (cloudDays > _totalDays) {
        _streak = data['streak'] as int? ?? 0;
        _totalDays = cloudDays;
        _lastActiveDate = data['lastActiveDate'] as String? ?? '';

        if (data['activeDates'] != null) {
          _activeDates = Set<String>.from(data['activeDates']);
        }

        await _saveLocal();
        notifyListeners();
      }
    } catch (_) {}
  }

  // ═══ مساعدات ═══
  String _todayStr() => _dateToStr(DateTime.now());

  String _dateToStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}