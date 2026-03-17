import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesRefreshService {
  static Future<Map<String, String>?> refreshUsingMethod(String methodKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('calc_method', methodKey);

      double? lat = prefs.getDouble('last_lat');
      double? long = prefs.getDouble('last_long');

      if (lat == null || long == null) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));

        lat = position.latitude;
        long = position.longitude;

        await prefs.setDouble('last_lat', lat);
        await prefs.setDouble('last_long', long);
      }

      int method = 4;

      switch (methodKey) {
        case 'umm_al_qura':
          method = 4;
          break;
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

      print('METHOD KEY = $methodKey');
      print('METHOD ID = $method');
      print('REQUEST URL = $url');

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);

        await prefs.setString('last_prayer_times', json.encode(timings));

        print('UPDATED TIMINGS = $timings');

        return timings;
      }

      print('API ERROR STATUS = ${response.statusCode}');
      return null;
    } catch (e) {
      print('REFRESH METHOD ERROR = $e');
      return null;
    }
  }

  static Future<Map<String, String>?> loadSavedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('last_prayer_times');
    if (saved == null) return null;
    return Map<String, String>.from(json.decode(saved));
  }
}