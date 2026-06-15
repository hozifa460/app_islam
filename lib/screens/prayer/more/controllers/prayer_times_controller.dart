import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/location_services.dart';

class PrayerTimesController extends ChangeNotifier {
  Map<String, String> prayerTimes = {};
  String cityName = 'جاري التحديد...';
  bool isLoading = true;

  final Map<String, String> fallbackTimes = {
    'Fajr': '04:30',
    'Sunrise': '05:45',
    'Dhuhr': '12:15',
    'Asr': '15:30',
    'Maghrib': '18:45',
    'Isha': '20:00',
  };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = prefs.getString('last_prayer_times');

    final savedLocation = await LocationService.getSavedLocation();
    if (savedLocation != null) {
      cityName = savedLocation.cityName;
    }

    if (savedTimes != null) {
      prayerTimes = Map<String, String>.from(json.decode(savedTimes));
      isLoading = false;
      notifyListeners();
    }

    await refreshLocationAndPrayerTimes();
  }

  Future<void> refreshLocationAndPrayerTimes() async {
    isLoading = true;
    notifyListeners();

    final location = await LocationService.resolveBestLocation();

    if (location == null) {
      await _loadLastSavedTimesOrFallback();
      return;
    }

    cityName = location.cityName;
    notifyListeners();

    await fetchPrayerTimesFromAPI(location.latitude, location.longitude);
  }

  Future<void> fetchPrayerTimesFromAPI(double lat, double long) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodKey = prefs.getString('calc_method') ?? 'umm_al_qura';

      int method = 4;
      switch (methodKey) {
        case 'egyptian':
          method = 5;
          break;
        case 'mwl':
          method = 3;
          break;
        default:
          method = 4;
      }

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date?latitude=$lat&longitude=$long&method=$method',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 200 &&
            data['data'] != null &&
            data['data']['timings'] != null) {
          final timings = Map<String, String>.from(data['data']['timings']);

          await prefs.setString('last_prayer_times', json.encode(timings));
          await prefs.setDouble('last_lat', lat);
          await prefs.setDouble('last_long', long);

          prayerTimes = timings;
          isLoading = false;

          // ✅ جديد: علامة أن المواقيت تغيّرت
          final adhanEnabled = prefs.getBool('adhan_enabled') ?? false;
          if (adhanEnabled) {
            await prefs.setBool('prayer_schedule_needs_update', true);
          }

          notifyListeners();
          return;
        }
      }

      await _loadLastSavedTimesOrFallback();
    } on TimeoutException {
      debugPrint('⏱️ Prayer times API timeout');
      await _loadLastSavedTimesOrFallback();
    } catch (e) {
      debugPrint('❌ Prayer times fetch error: $e');
      await _loadLastSavedTimesOrFallback();
    }
  }

  Future<Map<String, String>?> applyCalculationMethod(String methodKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calc_method', methodKey);

    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_long');
    if (lat == null || lng == null) return null;

    // ✅ نفس جدول الـ method ID
    int methodId = 4;
    switch (methodKey) {
      case 'umm_al_qura': methodId = 4;  break;
      case 'egyptian':    methodId = 5;  break;
      case 'mwl':         methodId = 3;  break;
      case 'isna':        methodId = 2;  break;
      case 'karachi':     methodId = 1;  break;
      case 'tehran':      methodId = 7;  break;
      case 'gulf':        methodId = 8;  break;
      case 'kuwait':      methodId = 9;  break;
      case 'qatar':       methodId = 10; break;
      case 'singapore':   methodId = 11; break;
      case 'france':      methodId = 12; break;
      case 'turkey':      methodId = 13; break;
      case 'russia':      methodId = 14; break;
      case 'moonsighting':methodId = 15; break;
      case 'dubai':       methodId = 16; break;
      case 'jakim':       methodId = 17; break;
      case 'tunisia':     methodId = 18; break;
      case 'algeria':     methodId = 19; break;
      case 'kemenag':     methodId = 20; break;
      case 'morocco':     methodId = 21; break;
      case 'portugal':    methodId = 22; break;
      case 'jordan':      methodId = 23; break;
      default:            methodId = 3;  break;
    }

    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings?'
            'latitude=$lat&longitude=$lng&method=$methodId',
      );
      final response = await http.get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(
            data['data']['timings']);

        // ✅ حدّث الـ state في الـ controller
        prayerTimes = {
          'Fajr':    timings['Fajr']    ?? '',
          'Sunrise': timings['Sunrise'] ?? '',
          'Dhuhr':   timings['Dhuhr']   ?? '',
          'Asr':     timings['Asr']     ?? '',
          'Maghrib': timings['Maghrib'] ?? '',
          'Isha':    timings['Isha']    ?? '',
        };
        notifyListeners();
        return prayerTimes;
      }
    } catch (e) {
      debugPrint('❌ applyCalculationMethod error: $e');
    }
    return null;
  }

  Future<void> _loadLastSavedTimesOrFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = prefs.getString('last_prayer_times');

    if (savedTimes != null) {
      prayerTimes = Map<String, String>.from(json.decode(savedTimes));
    } else {
      cityName = 'مكة المكرمة';
      prayerTimes = fallbackTimes;
    }

    isLoading = false;
    notifyListeners();
  }
}