
import 'ml_model.dart';
import '../../../features/prayer_os/data/repositories/prayer_repository.dart';
import '../../../features/prayer_os/data/models/prayer_record.dart';

class MLTrainer {
  final PrayerRepository repo;
  final MLModel model;

  MLTrainer(this.repo, this.model);

  Future<void> train() async {
    final records = await repo.getRecordsForLastDays(30);

    for (var r in records) {
      final features = await _extractFeatures(r.prayerKey, r.date);

      model.train(
        missHistory: features['missHistory']!,
        timeOfDay: features['timeOfDay']!,
        dayOfWeek: features['dayOfWeek']!,
        actuallyMissed: r.timing == PrayerTiming.missed,
      );
    }
  }

  Future<Map<String, double>> _extractFeatures(
      String prayerKey, DateTime date) async {

    final allRecords =
    await repo.getRecordsForLastDays(14);
    final related =
    allRecords.where((r) => r.prayerKey == prayerKey).toList();

    int missed = related.where((r) => r.timing == PrayerTiming.missed).length;

    double missHistory = missed / related.length;

    double timeOfDay = date.hour / 24.0;

    double dayOfWeek = date.weekday / 7.0;

    return {
      'missHistory': missHistory,
      'timeOfDay': timeOfDay,
      'dayOfWeek': dayOfWeek,
    };
  }
}
