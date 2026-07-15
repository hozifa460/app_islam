import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/screens/prayer/core/prayer_time_core.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('PrayerClock', () {
    test('converts internal ISO dates to the Aladhan day-first format', () {
      expect(PrayerClock.toAladhanDate('2026-07-15'), '15-07-2026');
      expect(PrayerClock.fromAladhanDate('15-07-2026'), '2026-07-15');
    });

    test('cleans API timezone suffixes without changing the clock time', () {
      expect(PrayerClock.cleanTime('05:17 (EEST)'), '05:17');
      expect(PrayerClock.cleanTime(' 19:42 (+03) '), '19:42');
    });

    test('uses the prayer location timezone across Cairo DST', () {
      final before = PrayerClock.wallTime(
        date: DateTime(2026, 4, 23),
        time: '12:00',
        timeZoneId: 'Africa/Cairo',
      );
      final after = PrayerClock.wallTime(
        date: DateTime(2026, 4, 24),
        time: '12:00',
        timeZoneId: 'Africa/Cairo',
      );

      expect(before.hour, 12);
      expect(after.hour, 12);
      expect(before.timeZoneOffset, isNot(after.timeZoneOffset));
      expect(after.difference(before), const Duration(hours: 23));
    });

    test('moves to the next local calendar day instead of adding 24 hours', () {
      final next = PrayerClock.nextDayWallTime(
        date: DateTime(2026, 4, 23),
        time: '05:00',
        timeZoneId: 'Africa/Cairo',
      );

      expect(
        (next.year, next.month, next.day, next.hour, next.minute),
        (2026, 4, 24, 5, 0),
      );
    });
  });

  group('PrayerMethodCatalog', () {
    test('maps calculation methods consistently for API and coordinates', () {
      expect(PrayerMethodCatalog.apiId('egyptian'), 5);
      expect(PrayerMethodCatalog.apiId('unknown'), 3);
      expect(PrayerMethodCatalog.autoForLocation(30.0444, 31.2357), 'egyptian');
      expect(
        PrayerMethodCatalog.autoForLocation(24.7136, 46.6753),
        'umm_al_qura',
      );
      expect(
        PrayerMethodCatalog.autoForLocation(1.3521, 103.8198),
        'singapore',
      );
    });

    test('exposes a clear automatic method label and explanation', () {
      expect(
        PrayerMethodCatalog.displayName(PrayerMethodCatalog.automaticKey),
        'تلقائي حسب الموقع',
      );
      expect(
        PrayerMethodCatalog.explanation(PrayerMethodCatalog.automaticKey),
        contains('إحداثيات'),
      );
    });

    test('offline fallback returns every displayed prayer', () {
      final result = PrayerMethodCatalog.calculateDay(
        latitude: 30.0444,
        longitude: 31.2357,
        day: DateTime(2026, 7, 15),
        method: 'egyptian',
        timeZoneId: 'Africa/Cairo',
      );

      expect(
        result.keys,
        containsAll(<String>[
          'Fajr',
          'Sunrise',
          'Dhuhr',
          'Asr',
          'Maghrib',
          'Isha',
        ]),
      );
      expect(
        result.values.every((time) => RegExp(r'^\d{2}:\d{2}$').hasMatch(time)),
        isTrue,
      );
    });
  });
}
