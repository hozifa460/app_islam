import 'dart:math' as MathExp;

class MLModel {
  // الأوزان تتعلم مع الوقت
  Map<String, double> weights = {
    'missHistory': 0.5,
    'timeOfDay': 0.3,
    'dayOfWeek': 0.2,
  };

  double bias = 0.0;

  double predict({
    required double missHistory,
    required double timeOfDay,
    required double dayOfWeek,
  }) {
    final z = bias +
        (weights['missHistory']! * missHistory) +
        (weights['timeOfDay']! * timeOfDay) +
        (weights['dayOfWeek']! * dayOfWeek);

    return 1 / (1 + exp(-z));
  }

  void train({
    required double missHistory,
    required double timeOfDay,
    required double dayOfWeek,
    required bool actuallyMissed,
    double lr = 0.01,
  }) {
    final prediction = predict(
      missHistory: missHistory,
      timeOfDay: timeOfDay,
      dayOfWeek: dayOfWeek,
    );

    final error = prediction - (actuallyMissed ? 1.0 : 0.0);

    weights['missHistory'] =
        weights['missHistory']! - lr * error * missHistory;
    weights['timeOfDay'] =
        weights['timeOfDay']! - lr * error * timeOfDay;
    weights['dayOfWeek'] =
        weights['dayOfWeek']! - lr * error * dayOfWeek;
    bias = bias - lr * error;
  }

  double exp(double x) =>
      double.parse(MathExp.exp(x).toStringAsFixed(5));
}
