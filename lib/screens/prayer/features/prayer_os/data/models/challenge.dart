import 'package:flutter/material.dart';

// ══════════════════════════════════════
// نوع التحدي
// ══════════════════════════════════════

enum ChallengeType {
  prayer,
  sunnah,
  mosque,
  khushu,
  dhikr,
  special,
}

// ══════════════════════════════════════
// صعوبة التحدي
// ══════════════════════════════════════

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
}

extension ChallengeDifficultyX on ChallengeDifficulty {
  String get arabicName {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'سهل';
      case ChallengeDifficulty.medium:
        return 'متوسط';
      case ChallengeDifficulty.hard:
        return 'صعب';
    }
  }

  Color get color {
    switch (this) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
    }
  }

  double get noorMultiplier {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 1.0;
      case ChallengeDifficulty.medium:
        return 1.5;
      case ChallengeDifficulty.hard:
        return 2.0;
    }
  }
}

// ══════════════════════════════════════
// تعريف التحدي
// ══════════════════════════════════════

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String islamicMotivation;
  final IconData icon;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int targetValue;
  final double noorReward;
  final bool isDaily;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.islamicMotivation,
    required this.icon,
    required this.type,
    required this.difficulty,
    required this.targetValue,
    required this.noorReward,
    this.isDaily = true,
  });
}

// ══════════════════════════════════════
// تقدم في التحدي
// ══════════════════════════════════════

class ChallengeProgress {
  final String challengeId;
  final DateTime startedAt;
  final int currentValue;
  final bool isCompleted;
  final DateTime? completedAt;

  ChallengeProgress({
    required this.challengeId,
    required this.startedAt,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'startedAt': startedAt.toIso8601String(),
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      challengeId: json['challengeId'] ?? '',
      startedAt:
      DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}