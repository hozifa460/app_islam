import 'package:flutter/material.dart';

class PrayerRow {
  final String key;
  final String name;
  String time;
  final IconData icon;
  final bool? noAdhan;

  late DateTime dateTime;

  bool isPast = false;
  bool isCurrent = false;
  bool isNext = false;
  bool isTomorrow = false;

  PrayerRow({
    required this.key,
    required this.name,
    required this.time,
    required this.icon,
    this.noAdhan,
  });
}

class PrayerCustomization {
  final bool adhanEnabled;
  final bool reminderEnabled;
  final int reminderOffset;
  final String reminderSound;
  final bool iqamaEnabled;
  final int iqamaDelay;
  final String iqamaSound;

  const PrayerCustomization({
    required this.adhanEnabled,
    required this.reminderEnabled,
    required this.reminderOffset,
    required this.reminderSound,
    required this.iqamaEnabled,
    required this.iqamaDelay,
    required this.iqamaSound,
  });

  factory PrayerCustomization.defaults() {
    return const PrayerCustomization(
      adhanEnabled: true,
      reminderEnabled: true,
      reminderOffset: 10,
      reminderSound: 'hayalaaslah',
      iqamaEnabled: false,
      iqamaDelay: 10,
      iqamaSound: 'iqama1',
    );
  }

  PrayerCustomization copyWith({
    bool? adhanEnabled,
    bool? reminderEnabled,
    int? reminderOffset,
    String? reminderSound,
    bool? iqamaEnabled,
    int? iqamaDelay,
    String? iqamaSound,
  }) {
    return PrayerCustomization(
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      reminderSound: reminderSound ?? this.reminderSound,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      iqamaDelay: iqamaDelay ?? this.iqamaDelay,
      iqamaSound: iqamaSound ?? this.iqamaSound,
    );
  }
}

class PickItem {
  final bool isHeader;
  final String categoryName;
  final dynamic m;

  PickItem({
    required this.isHeader,
    required this.categoryName,
    required this.m,
  });
}