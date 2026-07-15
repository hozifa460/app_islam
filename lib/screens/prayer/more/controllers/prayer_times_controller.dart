import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/location_services.dart';
import '../../core/prayer_time_core.dart';

class PrayerTimesController extends ChangeNotifier {
  static const _cacheKey = 'prayer_times_cache_v2';

  Map<String, String> prayerTimes = {};
  Map<String, String> tomorrowPrayerTimes = {};
  String cityName = 'جاري التحديد...';
  String timeZoneId = '';
  String prayerDate = '';
  String calculationMethod = 'umm_al_qura';
  bool isLoading = true;
  bool hasLocation = false;

  Future<void>? _initializeFuture;
  Future<void>? _refreshFuture;
  bool _initialized = false;

  Future<void> initialize() {
    if (_initialized) return Future.value();
    final pending = _initializeFuture;
    if (pending != null) return pending;
    final future = _initializeInternal();
    _initializeFuture = future;
    future.whenComplete(() {
      if (identical(_initializeFuture, future)) _initializeFuture = null;
    });
    return future;
  }

  Future<void> _initializeInternal() async {
    final prefs = await SharedPreferences.getInstance();
    calculationMethod =
        prefs.getString('calc_method_manual') ??
        prefs.getString('calc_method') ??
        calculationMethod;

    final savedLocation = await LocationService.getSavedLocation();
    if (savedLocation != null) {
      hasLocation = true;
      cityName = savedLocation.cityName;
    }

    final restored = await _restoreValidCache(
      prefs,
      latitude: savedLocation?.latitude,
      longitude: savedLocation?.longitude,
      method: calculationMethod,
    );
    if (restored) {
      isLoading = false;
      notifyListeners();
    }

    await refreshLocationAndPrayerTimes();
    _initialized = true;
  }

  Future<void> refreshLocationAndPrayerTimes({bool forceLocation = false}) {
    final pending = _refreshFuture;
    if (pending != null) return pending;
    final future = _refreshInternal(forceLocation: forceLocation);
    _refreshFuture = future;
    future.whenComplete(() {
      if (identical(_refreshFuture, future)) _refreshFuture = null;
    });
    return future;
  }

  Future<void> _refreshInternal({required bool forceLocation}) async {
    isLoading = prayerTimes.isEmpty;
    notifyListeners();

    final location = await LocationService.resolveBestLocation(
      forceRefresh: forceLocation,
    );
    if (location == null) {
      await _loadLastSavedTimesOrOffline();
      return;
    }
    hasLocation = true;

    final locationChanged =
        cityName != location.cityName || !location.fromCache;
    cityName = location.cityName;
    if (!location.fromCache) timeZoneId = '';
    if (locationChanged) notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final manualMethod = prefs.getString('calc_method_manual');
    if (manualMethod == null) {
      final automaticMethod = PrayerMethodCatalog.autoForLocation(
        location.latitude,
        location.longitude,
      );
      if (automaticMethod != calculationMethod) {
        calculationMethod = automaticMethod;
        await prefs.setString('calc_method', automaticMethod);
      }
    } else {
      calculationMethod = manualMethod;
    }

    await fetchPrayerTimesFromAPI(location.latitude, location.longitude);
  }

  Future<void> fetchPrayerTimesFromAPI(double lat, double long) async {
    final prefs = await SharedPreferences.getInstance();
    calculationMethod =
        prefs.getString('calc_method_manual') ??
        prefs.getString('calc_method') ??
        calculationMethod;
    final requestedDate = PrayerClock.dateKey(DateTime.now(), timeZoneId);

    try {
      var today = await _fetchDay(
        date: requestedDate,
        lat: lat,
        long: long,
        method: calculationMethod,
      );
      if (today == null) throw const FormatException('Invalid prayer response');

      // On a first launch the device timezone can differ from the selected
      // location. Re-request the right local calendar day once the API tells
      // us the location timezone.
      final locationDate = PrayerClock.dateKey(
        DateTime.now(),
        today.timeZoneId,
      );
      if (today.date != locationDate) {
        today = await _fetchDay(
          date: locationDate,
          lat: lat,
          long: long,
          method: calculationMethod,
        );
        if (today == null) {
          throw const FormatException('Invalid corrected prayer response');
        }
      }

      final oldSignature = _signature();
      prayerTimes = today.times;
      tomorrowPrayerTimes = {};
      prayerDate = today.date;
      timeZoneId = today.timeZoneId;
      isLoading = false;

      await _persistCache(
        prefs,
        latitude: lat,
        longitude: long,
        date: prayerDate,
        times: prayerTimes,
        method: calculationMethod,
        timeZone: timeZoneId,
      );
      await prefs.setDouble('last_lat', lat);
      await prefs.setDouble('last_long', long);

      if (oldSignature != _signature()) {
        await prefs.setBool('prayer_schedule_needs_update', true);
      }
      notifyListeners();

      // جلب فجر الغد على نحو منفصل يجعل عدّاد ما بعد العشاء دقيقاً،
      // ولا يمنع عرض مواقيت اليوم إذا تعذر الطلب الثاني.
      unawaited(_loadTomorrow(lat, long));
    } on TimeoutException {
      debugPrint('⏱️ Prayer times API timeout');
      await _loadLastSavedTimesOrOffline(latitude: lat, longitude: long);
    } catch (e) {
      debugPrint('❌ Prayer times fetch error: $e');
      await _loadLastSavedTimesOrOffline(latitude: lat, longitude: long);
    }
  }

  Future<void> _loadTomorrow(double lat, double long) async {
    final localNow = PrayerClock.nowAt(timeZoneId);
    final tomorrow = DateTime(localNow.year, localNow.month, localNow.day + 1);
    try {
      final result = await _fetchDay(
        date: DateFormat('yyyy-MM-dd').format(tomorrow),
        lat: lat,
        long: long,
        method: calculationMethod,
      );
      tomorrowPrayerTimes =
          result?.times ?? _calculateOfflineDay(lat, long, tomorrow);
    } catch (e) {
      debugPrint('Tomorrow prayer times fetch error: $e');
      tomorrowPrayerTimes = _calculateOfflineDay(lat, long, tomorrow);
    }
    notifyListeners();
  }

  Future<_ApiPrayerDay?> _fetchDay({
    required String date,
    required double lat,
    required double long,
    required String method,
  }) async {
    final methodId = PrayerMethodCatalog.apiId(method);
    final query = <String, String>{
      'latitude': '$lat',
      'longitude': '$long',
      'method': '$methodId',
      'school': '0',
      if (timeZoneId.trim().isNotEmpty) 'timezonestring': timeZoneId.trim(),
    };
    final url = Uri.https(
      'api.aladhan.com',
      '/v1/timings/${PrayerClock.toAladhanDate(date)}',
      query,
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body);
    final payload = data['data'];
    if (data['code'] != 200 || payload is! Map || payload['timings'] is! Map) {
      return null;
    }
    final raw = Map<String, dynamic>.from(payload['timings'] as Map);
    final times = <String, String>{};
    for (final key in const [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ]) {
      final value = raw[key]?.toString();
      if (value == null || value.isEmpty) return null;
      times[key] = PrayerClock.cleanTime(value);
    }
    final meta = payload['meta'];
    final dateData = payload['date'];
    final gregorian = dateData is Map ? dateData['gregorian'] : null;
    final apiDate = gregorian is Map ? gregorian['date']?.toString() : null;
    final timezone = meta is Map ? meta['timezone']?.toString() : null;
    return _ApiPrayerDay(
      times: times,
      date: apiDate == null ? date : PrayerClock.fromAladhanDate(apiDate),
      timeZoneId: timezone?.trim().isNotEmpty == true ? timezone! : timeZoneId,
    );
  }

  Future<Map<String, String>?> applyCalculationMethod(String methodKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (methodKey == PrayerMethodCatalog.automaticKey) {
      await prefs.remove('calc_method_manual');
      final lat = prefs.getDouble('last_lat');
      final long = prefs.getDouble('last_long');
      if (lat == null || long == null) {
        await refreshLocationAndPrayerTimes();
        return prayerTimes.isEmpty ? null : prayerTimes;
      }
      calculationMethod = PrayerMethodCatalog.autoForLocation(lat, long);
      await prefs.setString('calc_method', calculationMethod);
    } else {
      calculationMethod = methodKey;
      await prefs.setString('calc_method', methodKey);
      await prefs.setString('calc_method_manual', methodKey);
    }

    final lat = prefs.getDouble('last_lat');
    final long = prefs.getDouble('last_long');
    if (lat == null || long == null) {
      await refreshLocationAndPrayerTimes();
      return prayerTimes.isEmpty ? null : prayerTimes;
    }
    await fetchPrayerTimesFromAPI(lat, long);
    return prayerTimes.isEmpty ? null : prayerTimes;
  }

  Future<bool> _restoreValidCache(
    SharedPreferences prefs, {
    required double? latitude,
    required double? longitude,
    required String method,
  }) async {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return false;
    try {
      final data = json.decode(raw);
      if (data is! Map || data['times'] is! Map) return false;
      final cacheTimeZone = data['timeZoneId']?.toString() ?? '';
      final cacheDate = data['date']?.toString() ?? '';
      final cacheMethod = data['method']?.toString() ?? '';
      if (cacheTimeZone.isNotEmpty) timeZoneId = cacheTimeZone;
      if (cacheDate != PrayerClock.dateKey(DateTime.now(), cacheTimeZone) ||
          cacheMethod != method) {
        return false;
      }
      final cacheOffset = (data['offsetMinutes'] as num?)?.toInt();
      final currentOffset = PrayerClock.offsetMinutes(
        DateTime.now(),
        cacheTimeZone,
      );
      if (cacheOffset == null || cacheOffset != currentOffset) return false;
      final cacheLat = (data['latitude'] as num?)?.toDouble();
      final cacheLong = (data['longitude'] as num?)?.toDouble();
      if (latitude != null &&
          longitude != null &&
          (cacheLat == null ||
              cacheLong == null ||
              (cacheLat - latitude).abs() > 0.25 ||
              (cacheLong - longitude).abs() > 0.25)) {
        return false;
      }
      prayerTimes = Map<String, String>.from(data['times'] as Map);
      prayerDate = cacheDate;
      timeZoneId = cacheTimeZone;
      calculationMethod = cacheMethod;
      return prayerTimes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persistCache(
    SharedPreferences prefs, {
    required double latitude,
    required double longitude,
    required String date,
    required Map<String, String> times,
    required String method,
    required String timeZone,
  }) async {
    await prefs.setString(
      _cacheKey,
      json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'date': date,
        'times': times,
        'method': method,
        'timeZoneId': timeZone,
        'offsetMinutes': PrayerClock.offsetMinutes(DateTime.now(), timeZone),
        'savedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    // يبقى هذا المفتاح للنسخ القديمة، لكن لا يُستخدم ككاش موثوق بعد الآن.
    await prefs.setString('last_prayer_times', json.encode(times));
  }

  Future<void> _loadLastSavedTimesOrOffline({
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final restored = await _restoreValidCache(
      prefs,
      latitude: latitude ?? prefs.getDouble('last_lat'),
      longitude: longitude ?? prefs.getDouble('last_long'),
      method: calculationMethod,
    );
    if (restored) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final lat = latitude ?? prefs.getDouble('last_lat');
    final long = longitude ?? prefs.getDouble('last_long');
    if (lat != null && long != null) {
      _calculateOffline(lat, long);
    } else {
      // لا نعرض أوقاتًا افتراضية مضللة عندما لا يملك التطبيق موقعًا.
      prayerTimes = {};
      tomorrowPrayerTimes = {};
      prayerDate = PrayerClock.dateKey(DateTime.now(), timeZoneId);
      isLoading = false;
      notifyListeners();
    }
  }

  void _calculateOffline(double latitude, double longitude) {
    try {
      final now = PrayerClock.nowAt(timeZoneId);
      prayerTimes = _calculateOfflineDay(latitude, longitude, now);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      tomorrowPrayerTimes = _calculateOfflineDay(latitude, longitude, tomorrow);
      prayerDate = PrayerClock.dateKey(DateTime.now(), timeZoneId);
    } catch (e) {
      debugPrint('❌ Offline prayer calculation error: $e');
      prayerTimes = {};
      tomorrowPrayerTimes = {};
    }
    isLoading = false;
    notifyListeners();
  }

  Map<String, String> _calculateOfflineDay(
    double latitude,
    double longitude,
    DateTime day,
  ) {
    return PrayerMethodCatalog.calculateDay(
      latitude: latitude,
      longitude: longitude,
      day: day,
      method: calculationMethod,
      timeZoneId: timeZoneId,
    );
  }

  String _signature() =>
      '$prayerDate|$timeZoneId|$calculationMethod|${prayerTimes.entries.join(';')}';
}

class _ApiPrayerDay {
  final Map<String, String> times;
  final String date;
  final String timeZoneId;

  const _ApiPrayerDay({
    required this.times,
    required this.date,
    required this.timeZoneId,
  });
}
