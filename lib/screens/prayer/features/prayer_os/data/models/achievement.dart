import 'package:flutter/material.dart';

// ══════════════════════════════════════
// فئة الإنجاز
// ══════════════════════════════════════

enum AchievementCategory {
  streak,
  quality,
  sunnah,
  mosque,
  fajr,
  khushu,
  special,
}

// ══════════════════════════════════════
// مستوى الإنجاز
// ══════════════════════════════════════

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

extension AchievementTierX on AchievementTier {
  Color get color {
    switch (this) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  String get arabicName {
    switch (this) {
      case AchievementTier.bronze:
        return 'برونزي';
      case AchievementTier.silver:
        return 'فضي';
      case AchievementTier.gold:
        return 'ذهبي';
      case AchievementTier.platinum:
        return 'بلاتيني';
      case AchievementTier.diamond:
        return 'ماسي';
    }
  }
}

// ══════════════════════════════════════
// تعريف الإنجاز
// ══════════════════════════════════════

class SpiritualAchievement {
  final String id;
  final String title;
  final String description;
  final String islamicQuote;
  final String quoteSource;
  final IconData icon;
  final AchievementCategory category;
  final AchievementTier tier;
  final int requiredValue;
  final double noorBonus;
  final bool isSecret;
  final String? unlockHint;

  const SpiritualAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.islamicQuote,
    required this.quoteSource,
    required this.icon,
    required this.category,
    required this.tier,
    required this.requiredValue,
    this.noorBonus = 100,
    this.isSecret = false,
    this.unlockHint,
  });
}

// ══════════════════════════════════════
// إنجاز تم فتحه
// ══════════════════════════════════════

class UnlockedAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final String? triggerPrayer;
  final double noorAwarded;
  final bool isNew;

  UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    this.triggerPrayer,
    this.noorAwarded = 0,
    this.isNew = true,
  });

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'unlockedAt': unlockedAt.toIso8601String(),
    'triggerPrayer': triggerPrayer,
    'noorAwarded': noorAwarded,
    'isNew': isNew,
  };

  factory UnlockedAchievement.fromJson(Map<String, dynamic> json) {
    return UnlockedAchievement(
      achievementId: json['achievementId'] ?? '',
      unlockedAt:
      DateTime.tryParse(json['unlockedAt'] ?? '') ?? DateTime.now(),
      triggerPrayer: json['triggerPrayer'],
      noorAwarded: (json['noorAwarded'] ?? 0).toDouble(),
      isNew: json['isNew'] ?? false,
    );
  }
}