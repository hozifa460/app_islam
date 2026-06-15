import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesService {
  static Future<PrayerTimes> todayTimes() async {
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coords = Coordinates(pos.latitude, pos.longitude);

    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi; // غيّره من الإعدادات لاحقاً إن أردت

    final date = DateComponents.from(DateTime.now());
    return PrayerTimes(coords, date, params);
  }
}