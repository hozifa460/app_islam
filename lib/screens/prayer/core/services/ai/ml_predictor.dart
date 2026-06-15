import '../../../features/prayer_os/data/models/prayer_record.dart';
import 'ml_model.dart';
import '../../../features/prayer_os/data/repositories/prayer_repository.dart';

class MLPredictor {
  final PrayerRepository repo;
  final MLModel model;

  MLPredictor(this.repo, this.model);

  Future<double> predictMiss(String prayerKey, DateTime date) async {
    final features = await _extractFeatures(prayerKey, date);
    return model.predict(
      missHistory: features['missHistory']!,
      timeOfDay: features['timeOfDay']!,
      dayOfWeek: features['dayOfWeek']!,
    );
  }

  Future<Map<String, double>> _extractFeatures(
      String prayerKey, DateTime date) async {

    final allRecords =
    await repo.getRecordsForLastDays(14);
    final related =
    allRecords.where((r) => r.prayerKey == prayerKey).toList();

    int missed = related.where((r) => r.timing == PrayerTiming.missed).length;

    double missHistory = related.isEmpty ? 0.5 : missed / related.length;

    double timeOfDay = date.hour / 24.0;

    double dayOfWeek = date.weekday / 7.0;

    return {
      'missHistory': missHistory,
      'timeOfDay': timeOfDay,
      'dayOfWeek': dayOfWeek,
    };
  }

  Future<String> generateMessage(String prayerKey, DateTime date) async {
    final p = await predictMiss(prayerKey, date);

    if (p > 0.75) {
      return "خطر عالي! احتمال كبير إنك تفوت ${prayerKey}.\nخلينا نصليها الآن 🤍";
    } else if (p > 0.55) {
      return "محتاج تركز! ${prayerKey} تحتاج اهتمام أكثر.";
    } else {
      return "أنت على مستوى عالي من الثبات 🔥";
    }
  }
}
