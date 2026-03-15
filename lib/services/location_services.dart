class LocationService {
  static Future<Map<String, double>> getCurrentLocation() async {
    // موقع افتراضي - مكة المكرمة
    return {
      'latitude': 21.4225,
      'longitude': 39.8262,
    };
  }

  static Future<String> getCityName(double latitude, double longitude) async {
    return 'مكة المكرمة';
  }
}