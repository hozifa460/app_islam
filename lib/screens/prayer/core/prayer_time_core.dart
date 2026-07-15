import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// القواعد المشتركة لكل أجزاء مواقيت الصلاة.
class PrayerMethodCatalog {
  static const String automaticKey = 'auto';

  static const Map<String, int> apiIds = {
    'karachi': 1,
    'isna': 2,
    'mwl': 3,
    'umm_al_qura': 4,
    'egyptian': 5,
    'tehran': 7,
    'gulf': 8,
    'kuwait': 9,
    'qatar': 10,
    'singapore': 11,
    'france': 12,
    'turkey': 13,
    'russia': 14,
    'moonsighting': 15,
    'dubai': 16,
    'jakim': 17,
    'tunisia': 18,
    'algeria': 19,
    'kemenag': 20,
    'morocco': 21,
    'portugal': 22,
    'jordan': 23,
  };

  static int apiId(String key) => apiIds[key] ?? apiIds['mwl']!;

  static String displayName(String key) {
    return switch (key) {
      automaticKey => 'تلقائي حسب الموقع',
      'karachi' => 'جامعة العلوم الإسلامية - كراتشي',
      'isna' => 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
      'mwl' => 'رابطة العالم الإسلامي (MWL)',
      'umm_al_qura' => 'أم القرى',
      'egyptian' => 'الهيئة المصرية العامة للمساحة',
      'tehran' => 'جامعة طهران',
      'gulf' => 'تقويم الخليج',
      'kuwait' => 'الكويت',
      'qatar' => 'قطر',
      'singapore' => 'سنغافورة',
      'france' => 'اتحاد المنظمات الإسلامية في فرنسا',
      'turkey' => 'تركيا',
      'russia' => 'روسيا',
      'moonsighting' => 'لجنة رؤية الهلال',
      'dubai' => 'دبي',
      'jakim' => 'جاكيم - ماليزيا',
      'tunisia' => 'تونس',
      'algeria' => 'الجزائر',
      'kemenag' => 'وزارة الشؤون الدينية - إندونيسيا',
      'morocco' => 'المغرب',
      'portugal' => 'البرتغال',
      'jordan' => 'الأردن',
      _ => 'رابطة العالم الإسلامي (MWL)',
    };
  }

  static String explanation(String key) {
    return switch (key) {
      automaticKey =>
        'يختار التطبيق الطريقة الأقرب للبلد من إحداثيات موقعك، ويتحدث الاختيار عند انتقالك إلى بلد آخر.',
      'egyptian' => 'مناسبة لمصر؛ الاختلاف الأساسي يظهر عادة في الفجر والعشاء.',
      'umm_al_qura' => 'مناسبة غالبًا للسعودية؛ تعتمد تقويم أم القرى.',
      'mwl' => 'طريقة عالمية شائعة، ويمكن استخدامها عند عدم توفر طريقة محلية.',
      _ =>
        'تؤثر الطريقة أساسًا في الفجر والعشاء، بينما تبقى الظهر والعصر والمغرب متقاربة غالبًا.',
    };
  }

  /// Chooses the most appropriate published calculation convention for the
  /// saved coordinates. More specific regions must stay above broad regions.
  static String autoForLocation(double latitude, double longitude) {
    final lat = latitude;
    final lng = longitude;

    if (lat >= 22.0 && lat <= 31.8 && lng >= 24.5 && lng <= 37.0) {
      return 'egyptian';
    }
    if (lat >= 16.0 && lat <= 33.5 && lng >= 34.0 && lng <= 56.0) {
      if (lat >= 28.4 && lat <= 30.2 && lng >= 46.4 && lng <= 48.6) {
        return 'kuwait';
      }
      if (lat >= 24.3 && lat <= 26.3 && lng >= 50.5 && lng <= 51.8) {
        return 'qatar';
      }
      if (lat >= 22.4 && lat <= 26.5 && lng >= 51.4 && lng <= 56.5) {
        return 'dubai';
      }
      if (lat >= 29.0 && lat <= 33.5 && lng >= 34.8 && lng <= 39.4) {
        return 'jordan';
      }
      if (lat >= 16.0 && lat <= 32.3 && lng >= 34.0 && lng <= 55.8) {
        return 'umm_al_qura';
      }
      return 'gulf';
    }
    if (lat >= 24.0 && lat <= 40.5 && lng >= 44.0 && lng <= 63.5) {
      return 'tehran';
    }
    if (lat >= 35.5 && lat <= 42.5 && lng >= 25.5 && lng <= 45.0) {
      return 'turkey';
    }
    if (lat >= 5.0 && lat <= 37.5 && lng >= 60.0 && lng <= 97.5) {
      return 'karachi';
    }
    if (lat >= 1.1 && lat <= 1.6 && lng >= 103.5 && lng <= 104.1) {
      return 'singapore';
    }
    if (lat >= 0.8 && lat <= 7.5 && lng >= 99.0 && lng <= 120.0) {
      return 'jakim';
    }
    if (lat >= -11.5 && lat <= 6.5 && lng >= 94.0 && lng <= 141.5) {
      return 'kemenag';
    }
    if (lat >= 30.0 && lat <= 72.0 && lng >= 22.0 && lng <= 180.0) {
      return 'russia';
    }
    if (lat >= 41.0 && lat <= 51.5 && lng >= -5.5 && lng <= 10.0) {
      return 'france';
    }
    if (lat >= 36.5 && lat <= 42.5 && lng >= -10.0 && lng <= -6.0) {
      return 'portugal';
    }
    if (lat >= 7.0 && lat <= 84.0 && lng >= -170.0 && lng <= -52.0) {
      return 'isna';
    }
    if (lat >= 18.0 && lat <= 37.5 && lng >= -18.0 && lng <= 37.5) {
      return 'egyptian';
    }
    return 'mwl';
  }

  static CalculationParameters parameters(String key) {
    final parameters = switch (key) {
      'karachi' => CalculationMethod.karachi.getParameters(),
      'isna' => CalculationMethod.north_america.getParameters(),
      'umm_al_qura' => CalculationMethod.umm_al_qura.getParameters(),
      'egyptian' => CalculationMethod.egyptian.getParameters(),
      'tehran' => CalculationMethod.tehran.getParameters(),
      'kuwait' => CalculationMethod.kuwait.getParameters(),
      'qatar' => CalculationMethod.qatar.getParameters(),
      'singapore' || 'jakim' => CalculationMethod.singapore.getParameters(),
      'turkey' => CalculationMethod.turkey.getParameters(),
      'moonsighting' =>
        CalculationMethod.moon_sighting_committee.getParameters(),
      'dubai' || 'gulf' => CalculationMethod.dubai.getParameters(),
      _ => CalculationMethod.muslim_world_league.getParameters(),
    };
    parameters.madhab = Madhab.shafi;
    return parameters;
  }

  static Map<String, String> calculateDay({
    required double latitude,
    required double longitude,
    required DateTime day,
    required String method,
    String? timeZoneId,
  }) {
    final wallNoon = PrayerClock.wallTime(
      date: day,
      time: '12:00',
      timeZoneId: timeZoneId,
    );
    final calculated = PrayerTimes(
      Coordinates(latitude, longitude),
      DateComponents(day.year, day.month, day.day),
      parameters(method),
      utcOffset: Duration(
        minutes: PrayerClock.offsetMinutes(wallNoon, timeZoneId),
      ),
    );
    return {
      'Fajr': DateFormat('HH:mm').format(calculated.fajr),
      'Sunrise': DateFormat('HH:mm').format(calculated.sunrise),
      'Dhuhr': DateFormat('HH:mm').format(calculated.dhuhr),
      'Asr': DateFormat('HH:mm').format(calculated.asr),
      'Maghrib': DateFormat('HH:mm').format(calculated.maghrib),
      'Isha': DateFormat('HH:mm').format(calculated.isha),
    };
  }
}

class PrayerClock {
  static String toAladhanDate(String isoDate) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(isoDate);
    if (match == null) return isoDate;
    return '${match.group(3)}-${match.group(2)}-${match.group(1)}';
  }

  static String fromAladhanDate(String apiDate) {
    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(apiDate);
    if (match == null) return apiDate;
    return '${match.group(3)}-${match.group(2)}-${match.group(1)}';
  }

  static tz.Location? tryLocation(String? timeZoneId) {
    final id = timeZoneId?.trim();
    if (id == null || id.isEmpty) return null;
    try {
      return tz.getLocation(id);
    } catch (_) {
      return null;
    }
  }

  static DateTime nowAt(String? timeZoneId, {DateTime? now}) {
    final instant = now ?? DateTime.now();
    final location = tryLocation(timeZoneId);
    return location == null ? instant : tz.TZDateTime.from(instant, location);
  }

  static String dateKey(DateTime instant, String? timeZoneId) {
    return DateFormat('yyyy-MM-dd').format(nowAt(timeZoneId, now: instant));
  }

  static DateTime wallTime({
    required DateTime date,
    required String time,
    String? timeZoneId,
  }) {
    final parts = cleanTime(time).split(':');
    final hour = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 0;
    final minute = int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0;
    final location = tryLocation(timeZoneId);
    if (location == null) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
    return tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  static DateTime nextDayWallTime({
    required DateTime date,
    required String time,
    String? timeZoneId,
  }) {
    final location = tryLocation(timeZoneId);
    if (location == null) {
      final tomorrow = DateTime(date.year, date.month, date.day + 1);
      return wallTime(date: tomorrow, time: time);
    }
    final localDate = tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day + 1,
    );
    return wallTime(date: localDate, time: time, timeZoneId: timeZoneId);
  }

  static int offsetMinutes(DateTime date, String? timeZoneId) {
    final location = tryLocation(timeZoneId);
    final local = location == null ? date : tz.TZDateTime.from(date, location);
    return local.timeZoneOffset.inMinutes;
  }

  static String cleanTime(String value) {
    final match = RegExp(r'\b([01]?\d|2[0-3]):([0-5]\d)\b').firstMatch(value);
    if (match == null) return '00:00';
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }
}

extension _SafeListRead<T> on List<T> {
  T? elementAtOrNull(int index) =>
      index >= 0 && index < length ? this[index] : null;
}
