import 'dart:math';

class AIModel {
  double wMiss = 0.6;
  double wDelay = 0.3;
  double wQuality = -0.4;
  double bias = -0.1;

  double predict({
    required double missRate,
    required double avgDelay,
    required double qualityRate,
  }) {
    final z =
        bias +
            (wMiss * missRate) +
            (wDelay * (avgDelay / 30)) +
            (wQuality * qualityRate);

    return 1 / (1 + exp(-z));
  }

  void train({
    required double missRate,
    required double avgDelay,
    required double qualityRate,
    required bool actuallyMissed,
    double lr = 0.05,
  }) {
    final prediction = predict(
      missRate: missRate,
      avgDelay: avgDelay,
      qualityRate: qualityRate,
    );

    final y = actuallyMissed ? 1.0 : 0.0;
    final error = prediction - y;

    wMiss -= lr * error * missRate;
    wDelay -= lr * error * (avgDelay / 30);
    wQuality -= lr * error * qualityRate;
    bias -= lr * error;
  }
}