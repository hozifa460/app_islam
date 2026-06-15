import 'package:flutter/material.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/models/prayer_record.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/achievement.dart';
import '../../data/models/challenge.dart';
import '../../data/sources/achievements_catalog.dart';
import '../../data/sources/challenges_catalog.dart';
import '../../data/sources/spiritual_content.dart';
import '../../../../core/services/ai/ai_brain.dart';
import '../../../../core/services/ai/behavioral_analysis_service.dart';

class PrayerJourneyController extends ChangeNotifier {

  final PrayerRepository _repository = PrayerRepository.instance;
  late final BehavioralAnalysisService _behaviorService;

  // ─────────────────────────────
  // State
  // ─────────────────────────────

  UserPrayerProfile? _profile;
  List<PrayerRecord> _todayRecords = [];
  List<DayStats> _weekStats = [];
  List<UnlockedAchievement> _achievements = [];
  List<DailyChallenge> _todayChallenges = [];
  String _aiMessage = "";
  bool _isLoading = true;

  // ─────────────────────────────
  // Getters
  // ─────────────────────────────

  UserPrayerProfile? get profile => _profile;
  List<PrayerRecord> get todayRecords => _todayRecords;
  List<DayStats> get weekStats => _weekStats;
  List<UnlockedAchievement> get achievements => _achievements;
  List<DailyChallenge> get todayChallenges => _todayChallenges;
  String get aiMessage => _aiMessage;
  bool get isLoading => _isLoading;

  int get todayPrayedCount =>
      _todayRecords.where((r) => r.timing != PrayerTiming.missed).length;

  bool get isTodayComplete => todayPrayedCount >= 5;

  // ─────────────────────────────
  // Init
  // ─────────────────────────────

  PrayerJourneyController() {
    _behaviorService = BehavioralAnalysisService(_repository);
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _repository.checkDailyReset();

    _profile = await _repository.getProfile();
    _todayRecords =
    await _repository.getRecordsForDate(DateTime.now());
    _weekStats = await _repository.getWeekStats();
    _achievements =
    await _repository.getUnlockedAchievements();
    _todayChallenges = getTodaysChallenges();

    _aiMessage =
    await AIBrain.generateMessage("Fajr"); // افتراضي

    _isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────
  // Log Prayer
  // ─────────────────────────────

  Future<LogPrayerResult> logPrayer({
    required String prayerKey,
    required PrayerTiming timing,
    PrayerQuality quality = PrayerQuality.normal,
    PrayerLocation location = PrayerLocation.home,
    bool prayedSunnahBefore = false,
    bool prayedSunnahAfter = false,
    bool saidAdhkar = false,
    bool prayedWithJamaa = false,
    bool feltKhushu = false,
  }) async {
    try {
      final record = PrayerRecord(
        id: '',
        prayerKey: prayerKey,
        date: DateTime.now(),
        timing: timing,
        quality: quality,
        location: location,
        prayedSunnahBefore: prayedSunnahBefore,
        prayedSunnahAfter: prayedSunnahAfter,
        saidAdhkar: saidAdhkar,
        prayedWithJamaa: prayedWithJamaa,
        feltKhushu: feltKhushu,
      );

      final savedRecord =
      await _repository.savePrayerRecord(record);

      // AI يتعلم
      await AIBrain.learn(
          prayerKey, timing == PrayerTiming.missed);

      // تحديث البيانات
      await initialize();

      // تحقق من الإنجازات
      final unlocked =
      await _checkAchievements(savedRecord);

      return LogPrayerResult(
        success: true,
        record: savedRecord,
        noorEarned: savedRecord.noorPoints,
        newAchievements: unlocked,
        aiMessage: _aiMessage,
        newStreak: _profile?.currentStreak ?? 0,
      );
    } catch (e) {
      return LogPrayerResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // ─────────────────────────────
  // Achievements Check
  // ─────────────────────────────

  Future<List<SpiritualAchievement>> _checkAchievements(
      PrayerRecord record) async {

    List<SpiritualAchievement> unlockedNow = [];

    final profile = await _repository.getProfile();

    for (final achievement in achievementsCatalog) {
      if (achievement.category ==
          AchievementCategory.streak &&
          profile.currentStreak >= achievement.requiredValue) {

        final isUnlocked =
        await _repository.isAchievementUnlocked(
            achievement.id);

        if (!isUnlocked) {
          await _repository.unlockAchievement(
            UnlockedAchievement(
              achievementId: achievement.id,
              unlockedAt: DateTime.now(),
              triggerPrayer: record.prayerKey,
              noorAwarded: achievement.noorBonus,
            ),
          );
          unlockedNow.add(achievement);
        }
      }
    }

    return unlockedNow;
  }

  // ─────────────────────────────
  // Helper
  // ─────────────────────────────

  bool isPrayerLogged(String key) {
    return _todayRecords.any(
          (r) =>
      r.prayerKey == key &&
          r.timing != PrayerTiming.missed,
    );
  }
}

// ─────────────────────────────
// Log Result Model
// ─────────────────────────────

class LogPrayerResult {
  final bool success;
  final PrayerRecord? record;
  final double noorEarned;
  final List<SpiritualAchievement> newAchievements;
  final String? aiMessage;
  final int newStreak;
  final String? error;

  LogPrayerResult({
    required this.success,
    this.record,
    this.noorEarned = 0,
    this.newAchievements = const [],
    this.aiMessage,
    this.newStreak = 0,
    this.error,
  });
}