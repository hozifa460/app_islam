import 'ai_model.dart';
import 'ai_features.dart';
import 'ai_memory.dart';

class AIBrain {
  static final AIModel _model = AIModel();

  static Future<double> predictMiss(String prayerKey) async {
    final features = await AIFeatures.extract(prayerKey);

    return _model.predict(
      missRate: features['missRate']!,
      avgDelay: features['avgDelay']!,
      qualityRate: features['qualityRate']!,
    );
  }

  static Future<String> generateMessage(String prayerKey) async {
    final probability = await predictMiss(prayerKey);

    if (probability > 0.75) {
      AIMemory.lastEmotion = "concern";
      return "واضح إنك ممكن تفوتها 😔\nخلينا نصلي الآن 🤍";
    }

    if (probability > 0.5) {
      AIMemory.lastEmotion = "motivating";
      return "اقتربت الصلاة 🕌\nلا تضيعها 💪";
    }

    AIMemory.lastEmotion = "proud";
    return "ما شاء الله عليك 🔥";
  }

  static Future<void> learn(String prayerKey, bool missed) async {
    final features = await AIFeatures.extract(prayerKey);

    _model.train(
      missRate: features['missRate']!,
      avgDelay: features['avgDelay']!,
      qualityRate: features['qualityRate']!,
      actuallyMissed: missed,
    );
  }
}