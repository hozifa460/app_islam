import 'package:flutter/material.dart';

// ══════════════════════════════════════
// المستوى الروحاني
// ══════════════════════════════════════

enum SpiritualRank {
  seeker,
  beginner,
  committed,
  steadfast,
  devoted,
  enlightened,
  muhsin,
}

extension SpiritualRankX on SpiritualRank {
  String get arabicName {
    switch (this) {
      case SpiritualRank.seeker:
        return 'الباحث';
      case SpiritualRank.beginner:
        return 'المبتدئ';
      case SpiritualRank.committed:
        return 'الملتزم';
      case SpiritualRank.steadfast:
        return 'الثابت';
      case SpiritualRank.devoted:
        return 'المتعبد';
      case SpiritualRank.enlightened:
        return 'المتنور';
      case SpiritualRank.muhsin:
        return 'المحسن';
    }
  }

  String get description {
    switch (this) {
      case SpiritualRank.seeker:
        return 'بداية الطريق إلى الله';
      case SpiritualRank.beginner:
        return 'أول خطوات الثبات';
      case SpiritualRank.committed:
        return 'الصلاة أصبحت عادة';
      case SpiritualRank.steadfast:
        return 'ثبات على الطاعة';
      case SpiritualRank.devoted:
        return 'قلب معلق بالمساجد';
      case SpiritualRank.enlightened:
        return 'نور الصلاة في القلب';
      case SpiritualRank.muhsin:
        return 'كأنك تراه';
    }
  }

  String get emoji {
    switch (this) {
      case SpiritualRank.seeker:
        return '🌱';
      case SpiritualRank.beginner:
        return '🌿';
      case SpiritualRank.committed:
        return '🌳';
      case SpiritualRank.steadfast:
        return '🏔️';
      case SpiritualRank.devoted:
        return '🕌';
      case SpiritualRank.enlightened:
        return '✨';
      case SpiritualRank.muhsin:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case SpiritualRank.seeker:
        return const Color(0xFF8BC34A);
      case SpiritualRank.beginner:
        return const Color(0xFF4CAF50);
      case SpiritualRank.committed:
        return const Color(0xFF009688);
      case SpiritualRank.steadfast:
        return const Color(0xFF00BCD4);
      case SpiritualRank.devoted:
        return const Color(0xFF3F51B5);
      case SpiritualRank.enlightened:
        return const Color(0xFF9C27B0);
      case SpiritualRank.muhsin:
        return const Color(0xFFE6B325);
    }
  }

  int get requiredStreak {
    switch (this) {
      case SpiritualRank.seeker:
        return 0;
      case SpiritualRank.beginner:
        return 7;
      case SpiritualRank.committed:
        return 21;
      case SpiritualRank.steadfast:
        return 41;
      case SpiritualRank.devoted:
        return 71;
      case SpiritualRank.enlightened:
        return 101;
      case SpiritualRank.muhsin:
        return 151;
    }
  }

  SpiritualRank? get nextRank {
    final idx = SpiritualRank.values.indexOf(this);
    if (idx < SpiritualRank.values.length - 1) {
      return SpiritualRank.values[idx + 1];
    }
    return null;
  }

  static SpiritualRank fromStreak(int streak) {
    if (streak >= 151) return SpiritualRank.muhsin;
    if (streak >= 101) return SpiritualRank.enlightened;
    if (streak >= 71) return SpiritualRank.devoted;
    if (streak >= 41) return SpiritualRank.steadfast;
    if (streak >= 21) return SpiritualRank.committed;
    if (streak >= 7) return SpiritualRank.beginner;
    return SpiritualRank.seeker;
  }
}

// ══════════════════════════════════════
// ملف المستخدم الروحاني
// ══════════════════════════════════════

class UserPrayerProfile {
  final String odUser;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  // الإحصائيات
  final int currentStreak;
  final int longestStreak;
  final int totalPrayersLogged;
  final int totalPerfectDays;
  final int totalMosquePrayers;
  final int totalSunnahPrayers;

  // نقاط النور
  final double totalNoorPoints;
  final double weeklyNoorPoints;
  final double todayNoorPoints;

  // المستوى
  final SpiritualRank rank;
  final List<String> unlockedAchievements;

  // اليوم
  final int todayPrayersCount;
  final List<String> todayCompletedPrayers;

  UserPrayerProfile({
    required this.odUser,
    required this.createdAt,
    required this.lastActiveAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPrayersLogged = 0,
    this.totalPerfectDays = 0,
    this.totalMosquePrayers = 0,
    this.totalSunnahPrayers = 0,
    this.totalNoorPoints = 0,
    this.weeklyNoorPoints = 0,
    this.todayNoorPoints = 0,
    this.rank = SpiritualRank.seeker,
    this.unlockedAchievements = const [],
    this.todayPrayersCount = 0,
    this.todayCompletedPrayers = const [],
  });

  /// نسبة التقدم نحو الرتبة التالية
  double get progressToNextRank {
    final next = rank.nextRank;
    if (next == null) return 1.0;

    final currentReq = rank.requiredStreak;
    final nextReq = next.requiredStreak;
    final progress = currentStreak - currentReq;
    final total = nextReq - currentReq;

    return (progress / total).clamp(0.0, 1.0);
  }

  /// أيام متبقية للرتبة التالية
  int get daysToNextRank {
    final next = rank.nextRank;
    if (next == null) return 0;
    return (next.requiredStreak - currentStreak).clamp(0, 999);
  }

  /// هل أتم صلوات اليوم؟
  bool get isTodayComplete => todayPrayersCount >= 5;

  /// نسبة إتمام اليوم
  double get todayProgress =>
      (todayPrayersCount / 5.0).clamp(0.0, 1.0);

  /// تحويل لـ JSON
  Map<String, dynamic> toJson() => {
    'odUser': odUser,
    'createdAt': createdAt.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalPrayersLogged': totalPrayersLogged,
    'totalPerfectDays': totalPerfectDays,
    'totalMosquePrayers': totalMosquePrayers,
    'totalSunnahPrayers': totalSunnahPrayers,
    'totalNoorPoints': totalNoorPoints,
    'weeklyNoorPoints': weeklyNoorPoints,
    'todayNoorPoints': todayNoorPoints,
    'rank': rank.index,
    'unlockedAchievements': unlockedAchievements,
    'todayPrayersCount': todayPrayersCount,
    'todayCompletedPrayers': todayCompletedPrayers,
  };

  /// استرجاع من JSON
  factory UserPrayerProfile.fromJson(Map<String, dynamic> json) {
    return UserPrayerProfile(
      odUser: json['odUser'] ?? '',
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastActiveAt:
      DateTime.tryParse(json['lastActiveAt'] ?? '') ?? DateTime.now(),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalPrayersLogged: json['totalPrayersLogged'] ?? 0,
      totalPerfectDays: json['totalPerfectDays'] ?? 0,
      totalMosquePrayers: json['totalMosquePrayers'] ?? 0,
      totalSunnahPrayers: json['totalSunnahPrayers'] ?? 0,
      totalNoorPoints: (json['totalNoorPoints'] ?? 0).toDouble(),
      weeklyNoorPoints: (json['weeklyNoorPoints'] ?? 0).toDouble(),
      todayNoorPoints: (json['todayNoorPoints'] ?? 0).toDouble(),
      rank: SpiritualRank.values[json['rank'] ?? 0],
      unlockedAchievements:
      List<String>.from(json['unlockedAchievements'] ?? []),
      todayPrayersCount: json['todayPrayersCount'] ?? 0,
      todayCompletedPrayers:
      List<String>.from(json['todayCompletedPrayers'] ?? []),
    );
  }

  UserPrayerProfile copyWith({
    String? odUser,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? currentStreak,
    int? longestStreak,
    int? totalPrayersLogged,
    int? totalPerfectDays,
    int? totalMosquePrayers,
    int? totalSunnahPrayers,
    double? totalNoorPoints,
    double? weeklyNoorPoints,
    double? todayNoorPoints,
    SpiritualRank? rank,
    List<String>? unlockedAchievements,
    int? todayPrayersCount,
    List<String>? todayCompletedPrayers,
  }) {
    return UserPrayerProfile(
      odUser: odUser ?? this.odUser,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPrayersLogged: totalPrayersLogged ?? this.totalPrayersLogged,
      totalPerfectDays: totalPerfectDays ?? this.totalPerfectDays,
      totalMosquePrayers: totalMosquePrayers ?? this.totalMosquePrayers,
      totalSunnahPrayers: totalSunnahPrayers ?? this.totalSunnahPrayers,
      totalNoorPoints: totalNoorPoints ?? this.totalNoorPoints,
      weeklyNoorPoints: weeklyNoorPoints ?? this.weeklyNoorPoints,
      todayNoorPoints: todayNoorPoints ?? this.todayNoorPoints,
      rank: rank ?? this.rank,
      unlockedAchievements:
      unlockedAchievements ?? this.unlockedAchievements,
      todayPrayersCount: todayPrayersCount ?? this.todayPrayersCount,
      todayCompletedPrayers:
      todayCompletedPrayers ?? this.todayCompletedPrayers,
    );
  }
}