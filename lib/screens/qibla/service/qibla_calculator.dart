import 'dart:math' as math;

class QiblaCalculator {
  static const double kaabeLat = 21.422487;
  static const double kaabeLng = 39.826206;
  static const double _earthRadiusKm = 6378.137;

  static double calculate(double userLat, double userLng) {
    final lat1 = _toRad(userLat);
    final lat2 = _toRad(kaabeLat);
    final dLng = _toRad(kaabeLng - userLng);
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (_toDeg(math.atan2(y, x)) + 360.0) % 360.0;
  }

  static double distanceToKaaba(double userLat, double userLng) {
    const a = 6378.137;
    const b = 6356.752314245;
    const f = 1 / 298.257223563;
    final lat1 = _toRad(userLat);
    final lat2 = _toRad(kaabeLat);
    final L = _toRad(kaabeLng - userLng);
    final U1 = math.atan((1 - f) * math.tan(lat1));
    final U2 = math.atan((1 - f) * math.tan(lat2));
    final sinU1 = math.sin(U1), cosU1 = math.cos(U1);
    final sinU2 = math.sin(U2), cosU2 = math.cos(U2);
    double lambda = L, lambdaP = 0;
    double sinSigma = 0, cosSigma = 0, sigma = 0;
    double sinAlpha = 0, cosSqAlpha = 0, cos2SigmaM = 0, C = 0;
    int iter = 100;
    do {
      final sinL = math.sin(lambda);
      final cosL = math.cos(lambda);
      sinSigma = math.sqrt(math.pow(cosU2 * sinL, 2) +
          math.pow(cosU1 * sinU2 - sinU1 * cosU2 * cosL, 2));
      if (sinSigma == 0) return 0;
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosL;
      sigma = math.atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * math.sin(lambda) / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSqAlpha != 0
          ? cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha
          : 0;
      C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L +
          (1 - C) * f * sinAlpha *
              (sigma + C * sinSigma *
                  (cos2SigmaM + C * cosSigma *
                      (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    } while ((lambda - lambdaP).abs() > 1e-12 && --iter > 0);
    if (iter == 0) return _haversine(userLat, userLng);
    final uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    final A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    final B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    final ds = B * sinSigma * (cos2SigmaM + B / 4 *
        (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
            B / 6 * cos2SigmaM *
                (-3 + 4 * sinSigma * sinSigma) *
                (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    return b * A * (sigma - ds);
  }

  static double _haversine(double lat, double lng) {
    final dLat = _toRad(kaabeLat - lat);
    final dLng = _toRad(kaabeLng - lng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat)) * math.cos(_toRad(kaabeLat)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return _earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} م';
    if (km < 10) return '${km.toStringAsFixed(2)} كم';
    if (km < 100) return '${km.toStringAsFixed(1)} كم';
    return '${km.round()} كم';
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
  static double _toDeg(double rad) => rad * 180.0 / math.pi;
}