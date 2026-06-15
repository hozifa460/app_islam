import '../../../features/prayer_os/data/repositories/prayer_repository.dart';

class BehavioralAnalysisService {
  final PrayerRepository repo;

  BehavioralAnalysisService(this.repo);

  Future<String> weakestPrayer() async {
    final weekStats = await repo.getWeekStats();

    final prayerCounts = {
      'Fajr': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    };

    for (var day in weekStats) {
      for (var key in prayerCounts.keys) {
        if (day.hasPrayer(key)) {
          prayerCounts[key] = prayerCounts[key]! + 1;
        }
      }
    }

    var weakest = prayerCounts.entries.first;

    for (var entry in prayerCounts.entries) {
      if (entry.value < weakest.value) {
        weakest = entry;
      }
    }

    return weakest.key;
  }

  Future<double> weeklyConsistency() async {
    final weekStats = await repo.getWeekStats();
    int total = 0;

    for (var day in weekStats) {
      total += day.prayedCount;
    }

    return total / 35.0;
  }
}