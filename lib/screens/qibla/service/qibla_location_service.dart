import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum QiblaLocationStatus {
  granted,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
}

class QiblaLocationService {
  static Future<QiblaLocationStatus> checkStatus() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return QiblaLocationStatus.serviceDisabled;
    }
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.deniedForever) {
      return QiblaLocationStatus.permissionDeniedForever;
    }
    if (perm == LocationPermission.denied) {
      return QiblaLocationStatus.permissionDenied;
    }
    return QiblaLocationStatus.granted;
  }

  static Future<QiblaLocationStatus> requestPermission() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) {
      return QiblaLocationStatus.permissionDeniedForever;
    }
    if (perm == LocationPermission.denied) {
      return QiblaLocationStatus.permissionDenied;
    }
    return QiblaLocationStatus.granted;
  }

  static Future<Position?> getAccuratePosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 20),
      );
    } catch (_) {}
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {}
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {}
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {}
    return null;
  }

  // ✅ Stream بـ distanceFilter = 0 لأقصى دقة
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );
  }

  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<void> openAppSettings() => Geolocator.openAppSettings();
}