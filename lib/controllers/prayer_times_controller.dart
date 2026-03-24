import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/location_services.dart';

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
          notifyListeners();
          return;
        }
      }

      await _loadLastSavedTimesOrFallback();
    } on TimeoutException {
      await _loadLastSavedTimesOrFallback();
    } catch (_) {
      await _loadLastSavedTimesOrFallback();
    }
  }

  Future<Map<String, String>?> applyCalculationMethod(String methodKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calc_method', methodKey);

      final savedLat = prefs.getDouble('last_lat');
      final savedLong = prefs.getDouble('last_long');

      if (savedLat != null && savedLong != null) {
        await fetchPrayerTimesFromAPI(savedLat, savedLong);
        return prayerTimes;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5));

      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_long', position.longitude);

      await fetchPrayerTimesFromAPI(position.latitude, position.longitude);
      return prayerTimes;
    } catch (e) {
      debugPrint('applyCalculationMethod error: $e');
      return null;
    }
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