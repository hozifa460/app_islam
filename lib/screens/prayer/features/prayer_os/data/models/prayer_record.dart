import 'package:flutter/material.dart';

// ══════════════════════════════════════
// توقيت الصلاة
// ══════════════════════════════════════

enum PrayerTiming {
  onTime,
  withinTime,
  delayed,
  qada,
  missed,
}

extension PrayerTimingX on PrayerTiming {
  String get arabicName {
    switch (this) {
      case PrayerTiming.onTime:
        return 'أول الوقت';
      case PrayerTiming.withinTime:
        return 'في الوقت';
      case PrayerTiming.delayed:
        return 'متأخر';
      case PrayerTiming.qada:
        return 'قضاء';
      case PrayerTiming.missed:
        return 'فائتة';
    }
  }

  Color get color {
    switch (this) {
      case PrayerTiming.onTime:
        return const Color(0xFF4CAF50);
      case PrayerTiming.withinTime:
        return const Color(0xFF8BC34A);
      case PrayerTiming.delayed:
        return const Color(0xFFFF9800);
      case PrayerTiming.qada:
        return const Color(0xFFFF5722);
      case PrayerTiming.missed:
        return const Color(0xFF9E9E9E);
    }
  }

  double get multiplier {
    switch (this) {
      case PrayerTiming.onTime:
        return 1.5;
      case PrayerTiming.withinTime:
        return 1.0;
      case PrayerTiming.delayed:
        return 0.7;
      case PrayerTiming.qada:
        return 0.5;
      case PrayerTiming.missed:
        return 0.0;
    }
  }
}

// ══════════════════════════════════════
// جودة الصلاة
// ══════════════════════════════════════

enum PrayerQuality {
  rushed,
  normal,
  focused,
  khushu,
}

extension PrayerQualityX on PrayerQuality {
  String get arabicName {
    switch (this) {
      case PrayerQuality.rushed:
        return 'مستعجل';
      case PrayerQuality.normal:
        return 'عادي';
      case PrayerQuality.focused:
        return 'مركز';
      case PrayerQuality.khushu:
        return 'بخشوع';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerQuality.rushed:
        return Icons.speed;
      case PrayerQuality.normal:
        return Icons.check;
      case PrayerQuality.focused:
        return Icons.center_focus_strong;
      case PrayerQuality.khushu:
        return Icons.favorite;
    }
  }

  Color get color {
    switch (this) {
      case PrayerQuality.rushed:
        return Colors.orange;
      case PrayerQuality.normal:
        return Colors.blue;
      case PrayerQuality.focused:
        return Colors.green;
      case PrayerQuality.khushu:
        return Colors.purple;
    }
  }

  double get multiplier {
    switch (this) {
      case PrayerQuality.rushed:
        return 0.5;
      case PrayerQuality.normal:
        return 1.0;
      case PrayerQuality.focused:
        return 1.5;
      case PrayerQuality.khushu:
        return 2.0;
    }
  }
}

// ══════════════════════════════════════
// مكان الصلاة
// ══════════════════════════════════════

enum PrayerLocation {
  home,
  mosque,
  work,
  travel,
  other,
}

extension PrayerLocationX on PrayerLocation {
  String get arabicName {
    switch (this) {
      case PrayerLocation.home:
        return 'المنزل';
      case PrayerLocation.mosque:
        return 'المسجد';
      case PrayerLocation.work:
        return 'العمل';
      case PrayerLocation.travel:
        return 'سفر';
      case PrayerLocation.other:
        return 'آخر';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerLocation.home:
        return Icons.home;
      case PrayerLocation.mosque:
        return Icons.mosque;
      case PrayerLocation.work:
        return Icons.work;
      case PrayerLocation.travel:
        return Icons.flight;
      case PrayerLocation.other:
        return Icons.place;
    }
  }

  double get bonusMultiplier {
    switch (this) {
      case PrayerLocation.mosque:
        return 27.0;
      default:
        return 1.0;
    }
  }
}

// ══════════════════════════════════════
// سجل الصلاة الواحدة
// ══════════════════════════════════════

class PrayerRecord {
  final String id;
  final String prayerKey;
  final DateTime date;
  final DateTime? loggedAt;
  final PrayerTiming timing;
  final PrayerQuality quality;
  final PrayerLocation location;
  final bool prayedSunnahBefore;
  final bool prayedSunnahAfter;
  final bool saidAdhkar;
  final bool prayedWithJamaa;
  final bool feltKhushu;

  PrayerRecord({
    required this.id,
    required this.prayerKey,
    required this.date,
    this.loggedAt,
    this.timing = PrayerTiming.withinTime,
    this.quality = PrayerQuality.normal,
    this.location = PrayerLocation.home,
    this.prayedSunnahBefore = false,
    this.prayedSunnahAfter = false,
    this.saidAdhkar = false,
    this.prayedWithJamaa = false,
    this.feltKhushu = false,
  });

  /// حساب نقاط النور
  double get noorPoints {
    if (timing == PrayerTiming.missed) return 0;

    double base = 100.0;

    base *= timing.multiplier;
    base *= quality.multiplier;

    // المسجد × 5 كحد أقصى
    if (location == PrayerLocation.mosque) {
      base *= 5.0;
    }

    if (prayedSunnahBefore) base += 20;
    if (prayedSunnahAfter) base += 20;
    if (saidAdhkar) base += 15;
    if (feltKhushu) base += 30;
    if (prayedWithJamaa && location != PrayerLocation.mosque) {
      base += 25;
    }

    return base;
  }

  /// هل صلاة مثالية؟
  bool get isPerfect {
    return timing == PrayerTiming.onTime &&
        quality == PrayerQuality.khushu &&
        prayedSunnahBefore &&
        prayedSunnahAfter &&
        saidAdhkar;
  }

  /// تحويل لـ JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'prayerKey': prayerKey,
    'date': date.toIso8601String(),
    'loggedAt': loggedAt?.toIso8601String(),
    'timing': timing.index,
    'quality': quality.index,
    'location': location.index,
    'prayedSunnahBefore': prayedSunnahBefore,
    'prayedSunnahAfter': prayedSunnahAfter,
    'saidAdhkar': saidAdhkar,
    'prayedWithJamaa': prayedWithJamaa,
    'feltKhushu': feltKhushu,
  };

  /// استرجاع من JSON
  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      id: json['id'] ?? '',
      prayerKey: json['prayerKey'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      loggedAt: json['loggedAt'] != null
          ? DateTime.tryParse(json['loggedAt'])
          : null,
      timing: PrayerTiming.values[json['timing'] ?? 1],
      quality: PrayerQuality.values[json['quality'] ?? 1],
      location: PrayerLocation.values[json['location'] ?? 0],
      prayedSunnahBefore: json['prayedSunnahBefore'] ?? false,
      prayedSunnahAfter: json['prayedSunnahAfter'] ?? false,
      saidAdhkar: json['saidAdhkar'] ?? false,
      prayedWithJamaa: json['prayedWithJamaa'] ?? false,
      feltKhushu: json['feltKhushu'] ?? false,
    );
  }

  PrayerRecord copyWith({
    String? id,
    String? prayerKey,
    DateTime? date,
    DateTime? loggedAt,
    PrayerTiming? timing,
    PrayerQuality? quality,
    PrayerLocation? location,
    bool? prayedSunnahBefore,
    bool? prayedSunnahAfter,
    bool? saidAdhkar,
    bool? prayedWithJamaa,
    bool? feltKhushu,
  }) {
    return PrayerRecord(
      id: id ?? this.id,
      prayerKey: prayerKey ?? this.prayerKey,
      date: date ?? this.date,
      loggedAt: loggedAt ?? this.loggedAt,
      timing: timing ?? this.timing,
      quality: quality ?? this.quality,
      location: location ?? this.location,
      prayedSunnahBefore: prayedSunnahBefore ?? this.prayedSunnahBefore,
      prayedSunnahAfter: prayedSunnahAfter ?? this.prayedSunnahAfter,
      saidAdhkar: saidAdhkar ?? this.saidAdhkar,
      prayedWithJamaa: prayedWithJamaa ?? this.prayedWithJamaa,
      feltKhushu: feltKhushu ?? this.feltKhushu,
    );
  }
}