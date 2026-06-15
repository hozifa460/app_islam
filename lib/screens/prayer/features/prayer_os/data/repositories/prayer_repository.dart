import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_record.dart';
import '../models/user_profile.dart';
import '../models/achievement.dart';

// ══════════════════════════════════════
// إحصائيات يوم واحد
// ══════════════════════════════════════

class DayStats {
  final DateTime date;
  final List<PrayerRecord> records;

  DayStats({required this.date, required this.records});

  int get prayedCount =>
      records.where((r) => r.timing != PrayerTiming.missed).length;

  bool get isPerfectDay => prayedCount >= 5;

  double get totalNoor =>
      records.fold(0.0, (sum, r) => sum + r.noorPoints);

  double get completionRate => prayedCount / 5.0;

  bool hasPrayer(String key) =>
      records.any((r) =>
      r.prayerKey == key && r.timing != PrayerTiming.missed);
}

// ══════════════════════════════════════
// Repository الرئيسي
// ══════════════════════════════════════

class PrayerRepository {
  static const String _recordsKey = 'prayer_os_records';
  static const String _profileKey = 'prayer_os_profile';
  static const String _achievementsKey = 'prayer_os_achievements';
  static const String _lastResetKey = 'prayer_os_last_reset';

  static final PrayerRepository _instance = PrayerRepository._();
  static PrayerRepository get instance => _instance;
  PrayerRepository._();

  // ═══════ Cache ═══════
  List<PrayerRecord>? _cachedRecords;
  UserPrayerProfile? _cachedProfile;
  DateTime? _lastCacheTime;

  bool get _isCacheValid {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!).inMinutes < 5;
  }

  void _invalidateCache() {
    _cachedRecords = null;
    _cachedProfile = null;
    _lastCacheTime = null;
  }

  // ═══════════════════════════════════
  // Prayer Records
  // ═══════════════════════════════════

  /// حفظ سجل صلاة
  Future<PrayerRecord> savePrayerRecord(PrayerRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAllRecords();

    // حذف أي سجل سابق لنفس الصلاة في نفس اليوم
    records.removeWhere((r) =>
    r.prayerKey == record.prayerKey &&
        _isSameDay(r.date, record.date));

    // إنشاء سجل جديد مع ID و loggedAt
    final newRecord = record.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      loggedAt: DateTime.now(),
    );

    records.add(newRecord);

    // حفظ
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsKey, json.encode(jsonList));

    _invalidateCache();

    // تحديث الملف الشخصي
    await _updateProfileAfterPrayer(newRecord);

    return newRecord;
  }

  /// جلب كل السجلات
  Future<List<PrayerRecord>> getAllRecords() async {
    if (_cachedRecords != null && _isCacheValid) {
      return List.from(_cachedRecords!);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recordsKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      _cachedRecords = [];
      _lastCacheTime = DateTime.now();
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      _cachedRecords = jsonList
          .map((j) =>
          PrayerRecord.fromJson(Map<String, dynamic>.from(j)))
          .toList();
      _lastCacheTime = DateTime.now();
      return List.from(_cachedRecords!);
    } catch (e) {
      debugPrint('❌ Error loading records: $e');
      return [];
    }
  }

  /// جلب سجلات يوم معين
  Future<List<PrayerRecord>> getRecordsForDate(DateTime date) async {
    final records = await getAllRecords();
    return records.where((r) => _isSameDay(r.date, date)).toList();
  }

  /// جلب سجل صلاة معينة في يوم معين
  Future<PrayerRecord?> getRecord(
      String prayerKey, DateTime date) async {
    final records = await getRecordsForDate(date);
    try {
      return records.firstWhere((r) => r.prayerKey == prayerKey);
    } catch (_) {
      return null;
    }
  }

  /// حذف سجل صلاة
  Future<void> deleteRecord(
      String prayerKey, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAllRecords();

    records.removeWhere((r) =>
    r.prayerKey == prayerKey && _isSameDay(r.date, date));

    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsKey, json.encode(jsonList));

    _invalidateCache();
    await _recalculateProfile();
  }

  /// جلب سجلات آخر N يوم
  Future<List<PrayerRecord>> getRecordsForLastDays(int days) async {
    final records = await getAllRecords();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records.where((r) => r.date.isAfter(cutoff)).toList();
  }

  /// جلب إحصائيات يوم
  Future<DayStats> getDayStats(DateTime date) async {
    final records = await getRecordsForDate(date);
    return DayStats(date: date, records: records);
  }

  /// جلب إحصائيات الأسبوع
  Future<List<DayStats>> getWeekStats() async {
    final stats = <DayStats>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      stats.add(await getDayStats(date));
    }

    return stats;
  }

  // ═══════════════════════════════════
  // User Profile
  // ═══════════════════════════════════

  /// جلب الملف الشخصي
  Future<UserPrayerProfile> getProfile() async {
    if (_cachedProfile != null && _isCacheValid) {
      return _cachedProfile!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      final newProfile = UserPrayerProfile(
        odUser: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      await _saveProfile(newProfile);
      return newProfile;
    }

    try {
      _cachedProfile =
          UserPrayerProfile.fromJson(json.decode(jsonStr));
      _lastCacheTime = DateTime.now();
      return _cachedProfile!;
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      return UserPrayerProfile(
        odUser: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
    }
  }

  /// حفظ الملف الشخصي
  Future<void> _saveProfile(UserPrayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _profileKey, json.encode(profile.toJson()));
    _cachedProfile = profile;
    _lastCacheTime = DateTime.now();
  }

  Future<Map<String, int>> getPrayerStats() async {
    final records = await getAllRecords();

    Map<String, int> stats = {
      'Fajr': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    };

    for (var r in records) {
      if (r.timing != PrayerTiming.missed) {
        stats[r.prayerKey] =
            (stats[r.prayerKey] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// تحديث الملف بعد كل صلاة
  Future<void> _updateProfileAfterPrayer(
      PrayerRecord record) async {
    final profile = await getProfile();
    final todayRecords =
    await getRecordsForDate(DateTime.now());

    final newStreak = await _calculateCurrentStreak();

    final updatedProfile = profile.copyWith(
      lastActiveAt: DateTime.now(),
      currentStreak: newStreak,
      longestStreak: newStreak > profile.longestStreak
          ? newStreak
          : profile.longestStreak,
      totalPrayersLogged: profile.totalPrayersLogged + 1,
      totalNoorPoints:
      profile.totalNoorPoints + record.noorPoints,
      todayPrayersCount: todayRecords.length,
      todayNoorPoints: todayRecords.fold(
          0.0, (sum, r) => sum! + r.noorPoints),
      todayCompletedPrayers:
      todayRecords.map((r) => r.prayerKey).toList(),
      rank: SpiritualRankX.fromStreak(newStreak),
      totalMosquePrayers:
      record.location == PrayerLocation.mosque
          ? profile.totalMosquePrayers + 1
          : profile.totalMosquePrayers,
      totalSunnahPrayers: (record.prayedSunnahBefore ||
          record.prayedSunnahAfter)
          ? profile.totalSunnahPrayers + 1
          : profile.totalSunnahPrayers,
      totalPerfectDays: todayRecords.length >= 5
          ? profile.totalPerfectDays + 1
          : profile.totalPerfectDays,
    );

    await _saveProfile(updatedProfile);
  }

  /// إعادة حساب الملف
  Future<void> _recalculateProfile() async {
    final records = await getAllRecords();
    final profile = await getProfile();

    final streak = await _calculateCurrentStreak();
    final todayRecords =
    await getRecordsForDate(DateTime.now());

    int mosquePrayers = 0;
    int sunnahPrayers = 0;
    double totalNoor = 0;

    for (final r in records) {
      totalNoor += r.noorPoints;
      if (r.location == PrayerLocation.mosque) mosquePrayers++;
      if (r.prayedSunnahBefore || r.prayedSunnahAfter) {
        sunnahPrayers++;
      }
    }

    final updatedProfile = profile.copyWith(
      currentStreak: streak,
      totalPrayersLogged: records.length,
      totalNoorPoints: totalNoor,
      totalMosquePrayers: mosquePrayers,
      totalSunnahPrayers: sunnahPrayers,
      todayPrayersCount: todayRecords.length,
      todayCompletedPrayers:
      todayRecords.map((r) => r.prayerKey).toList(),
      rank: SpiritualRankX.fromStreak(streak),
    );

    await _saveProfile(updatedProfile);
  }

  /// حساب الـ Streak
  Future<int> _calculateCurrentStreak() async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final day = DateTime(
          checkDate.year, checkDate.month, checkDate.day);

      final dayRecords =
      records.where((r) => _isSameDay(r.date, day)).toList();

      final prayedKeys = dayRecords
          .where((r) => r.timing != PrayerTiming.missed)
          .map((r) => r.prayerKey)
          .toSet();

      final allPrayers = {
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha'
      };

      if (prayedKeys.containsAll(allPrayers)) {
        streak++;
        checkDate =
            checkDate.subtract(const Duration(days: 1));
      } else {
        // اليوم الحالي لم يكتمل بعد
        if (_isSameDay(day, DateTime.now())) {
          checkDate =
              checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }

  // ═══════════════════════════════════
  // Achievements
  // ═══════════════════════════════════

  /// جلب الإنجازات المفتوحة
  Future<List<UnlockedAchievement>>
  getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_achievementsKey);

    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList
          .map((j) => UnlockedAchievement.fromJson(
          Map<String, dynamic>.from(j)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// فتح إنجاز
  Future<void> unlockAchievement(
      UnlockedAchievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final achievements = await getUnlockedAchievements();

    // تأكد من عدم التكرار
    if (achievements
        .any((a) => a.achievementId == achievement.achievementId)) {
      return;
    }

    achievements.add(achievement);

    final jsonList =
    achievements.map((a) => a.toJson()).toList();
    await prefs.setString(
        _achievementsKey, json.encode(jsonList));

    // إضافة النقاط
    final profile = await getProfile();
    await _saveProfile(profile.copyWith(
      totalNoorPoints:
      profile.totalNoorPoints + achievement.noorAwarded,
      unlockedAchievements: [
        ...profile.unlockedAchievements,
        achievement.achievementId,
      ],
    ));
  }

  /// هل الإنجاز مفتوح؟
  Future<bool> isAchievementUnlocked(String id) async {
    final achievements = await getUnlockedAchievements();
    return achievements.any((a) => a.achievementId == id);
  }

  // ═══════════════════════════════════
  // Daily Reset
  // ═══════════════════════════════════

  /// فحص إعادة التعيين اليومي
  Future<void> checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month}-${today.day}';

    if (lastReset != todayStr) {
      _invalidateCache();
      await prefs.setString(_lastResetKey, todayStr);

      final profile = await getProfile();
      await _saveProfile(profile.copyWith(
        todayPrayersCount: 0,
        todayNoorPoints: 0,
        todayCompletedPrayers: [],
        lastActiveAt: DateTime.now(),
      ));
    }
  }

  // ═══════════════════════════════════
  // Utilities
  // ═══════════════════════════════════

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  /// مسح كل البيانات (للاختبار)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_achievementsKey);
    _invalidateCache();
  }
}