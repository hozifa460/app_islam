import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerCalculatorService {
  // جلب الموقع الحالي
  static Future<Position?> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  // حساب المواقيت ليوم محدد
  static PrayerTimes? getPrayerTimes(Position position, DateTime date, String methodStr) {
    final coordinates = Coordinates(position.latitude, position.longitude);

    // اختيار طريقة الحساب بناءً على إعدادات المستخدم
    CalculationParameters params;
    switch (methodStr) {
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'mwl':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      default:
        params = CalculationMethod.umm_al_qura.getParameters();
    }

    // المذهب (شافعي افتراضي، حنفي للخليج، الخ)
    params.madhab = Madhab.shafi;

    return PrayerTimes.today(coordinates, params);
  }
}