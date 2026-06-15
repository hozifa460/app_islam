import '../../../features/prayer_os/data/repositories/prayer_repository.dart';

class AIFeatures {
  static Future<Map<String, double>> extract(String prayerKey) async {
    final repo = PrayerRepository.instance;
    final records = await repo.getRecordsForLastDays(14);

    final related =
    records.where((r) => r.prayerKey == prayerKey).toList();

    if (related.isEmpty) {
      return {
        'missRate': 0.5,
        'avgDelay': 10,
        'qualityRate': 0.5,
      };
    }

    int missed = 0;
    int totalDelay = 0;
    int goodQuality = 0;

    for (var r in related) {
      if (r.timing.name == "missed") missed++;
      totalDelay += r.timing == null ? 0 : 5;
      if (r.feltKhushu) goodQuality++;
    }

    return {
      'missRate': missed / related.length,
      'avgDelay': totalDelay / related.length,
      'qualityRate': goodQuality / related.length,
    };
  }
}