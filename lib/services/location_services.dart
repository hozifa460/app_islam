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
  // Refreshing the GPS fix on every rebuild is expensive and can make the
  // prayer screen feel slow. A six-hour window still detects a trip to a new
  // city/country during normal use while keeping the cached location instant.
  static const _automaticRefreshWindow = Duration(hours: 6);
  static const _locationChangeThresholdMeters = 15000.0;

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

  static Future<Position?> getBestAvailablePosition({
    bool preferFresh = false,
  }) async {
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
      if (!preferFresh && lastKnown != null) return lastKnown;

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        return lastKnown;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<String> getAccurateCityName(double lat, double long) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        long,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final locality =
            place.subLocality?.trim().isNotEmpty == true
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
    await prefs.setInt(
      'last_location_refresh_at',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<LocationResult?> resolveBestLocation({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedLocation();
    if (!forceRefresh && saved != null) {
      final lastRefresh = prefs.getInt('last_location_refresh_at');
      final refreshDue =
          lastRefresh == null ||
          DateTime.now().millisecondsSinceEpoch - lastRefresh >=
              _automaticRefreshWindow.inMilliseconds;
      if (!refreshDue) {
        // A last-known fix is fast and does not request a permission dialog.
        // It lets us notice a trip to another city/country before the normal
        // refresh window elapses; a fresh GPS fix is only requested when the
        // displacement is meaningful.
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown == null ||
              Geolocator.distanceBetween(
                    saved.latitude,
                    saved.longitude,
                    lastKnown.latitude,
                    lastKnown.longitude,
                  ) <
                  _locationChangeThresholdMeters) {
            return saved;
          }
        } catch (_) {
          return saved;
        }
      }
    }

    final position = await getBestAvailablePosition(preferFresh: true);
    if (position == null) return saved;

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
