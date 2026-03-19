import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final bool fromCache;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.fromCache,
  });
}

class LocationService {
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getBestAvailablePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );

      return current;
    } catch (_) {
      return null;
    }
  }

  static Future<String> getAccurateCityName(double lat, double long) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, long)
          .timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final locality = place.subLocality?.trim().isNotEmpty == true
            ? place.subLocality!
            : (place.locality ?? '');

        final adminArea = place.administrativeArea ?? '';
        final country = place.country ?? 'موقعي';

        if (locality.isNotEmpty &&
            adminArea.isNotEmpty &&
            locality != adminArea) {
          return '$locality، $adminArea';
        } else if (locality.isNotEmpty) {
          return locality;
        } else if (adminArea.isNotEmpty) {
          return adminArea;
        } else {
          return country;
        }
      }
    } catch (_) {}

    return 'موقعي';
  }

  static Future<LocationResult?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final lat = prefs.getDouble('last_lat');
    final long = prefs.getDouble('last_long');
    final city = prefs.getString('last_city');

    if (lat == null || long == null) return null;

    return LocationResult(
      latitude: lat,
      longitude: long,
      cityName: city ?? 'موقعي',
      fromCache: true,
    );
  }

  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', latitude);
    await prefs.setDouble('last_long', longitude);
    await prefs.setString('last_city', cityName);
  }

  static Future<LocationResult?> resolveBestLocation() async {
    final saved = await getSavedLocation();
    if (saved != null) return saved;

    final position = await getBestAvailablePosition();
    if (position == null) return null;

    final city = await getAccurateCityName(
      position.latitude,
      position.longitude,
    );

    await saveLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: city,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: city,
      fromCache: false,
    );
  }
}