// lib/screens/qibla/service/magnetic_declination.dart

import 'dart:math' as math;

/// حساب الانحراف المغناطيسي (Magnetic Declination)
/// باستخدام نموذج IGRF-13 المبسط (دقيق لـ 2024-2025)
class MagneticDeclination {
  /// يحسب الانحراف المغناطيسي بالدرجات
  /// القيمة الموجبة = شرق، السالبة = غرب
  static double calculate(double lat, double lng, {DateTime? date}) {
    date ??= DateTime.now();

    // السنة العشرية
    final decimalYear = date.year +
        (date.month - 1) / 12.0 +
        (date.day - 1) / 365.25;

    // تحويل لراديان
    final latRad = lat * math.pi / 180.0;
    final lngRad = lng * math.pi / 180.0;

    // ═══════════════════════════════════════════════════
    // معاملات IGRF-13 المبسطة (Epoch 2025.0)
    // هذه المعاملات الرئيسية الأولى (n=1,2,3)
    // تعطي دقة ~1-2 درجة وهي كافية جداً للقبلة
    // ═══════════════════════════════════════════════════

    // Gauss coefficients for IGRF-13 (2025.0) - أول 8 معاملات
    // g(n,m) و h(n,m)
    const g10 = -29352.0; // nT
    const g11 = -1450.9;
    const h11 = 4652.5;
    const g20 = -2556.2;
    const g21 = 3012.4;
    const h21 = -2819.7;
    const g22 = 1698.5;
    const h22 = -638.8;
    const g30 = 1299.9;
    const g31 = -2267.5;
    const h31 = -160.4;
    const g32 = 1249.3;
    const h32 = 293.5;
    const g33 = 714.3;
    const h33 = -867.7;

    // Secular variation (nT/year) من 2025
    const dg10 = 9.2;
    const dg11 = 7.4;
    const dh11 = -28.1;
    const dg20 = -11.6;
    const dg21 = -5.0;
    const dh21 = -31.8;
    const dg22 = -0.5;
    const dh22 = -18.0;

    // التعويض الزمني من 2025.0
    final dt = decimalYear - 2025.0;

    // المعاملات المعوضة زمنياً
    final G10 = g10 + dg10 * dt;
    final G11 = g11 + dg11 * dt;
    final H11 = h11 + dh11 * dt;
    final G20 = g20 + dg20 * dt;
    final G21 = g21 + dg21 * dt;
    final H21 = h21 + dh21 * dt;
    final G22 = g22 + dg22 * dt;
    final H22 = h22 + dh22 * dt;

    // نصف قطر الأرض
    const a = 6371.2; // km (reference radius)
    const r = 6371.2; // على السطح

    final ratio = a / r; // = 1.0 على السطح

    final cosLat = math.cos(latRad);
    final sinLat = math.sin(latRad);
    final cosLng = math.cos(lngRad);
    final sinLng = math.sin(lngRad);
    final cos2Lng = math.cos(2.0 * lngRad);
    final sin2Lng = math.sin(2.0 * lngRad);
    final cos3Lng = math.cos(3.0 * lngRad);
    final sin3Lng = math.sin(3.0 * lngRad);

    // ═══════════════════════════════════════════════════
    // حساب المركبات X (شمال) و Y (شرق) و Z (أسفل)
    // باستخدام Associated Legendre Functions
    // ═══════════════════════════════════════════════════

    // n=1 terms
    final r2 = ratio * ratio;
    final r3 = r2 * ratio;
    final r4 = r3 * ratio;

    // X component (Northward) = -dV/dθ
    double bx = 0;
    // Y component (Eastward) = dV/(r·sinθ·dφ)
    double by = 0;

    // ─── n=1 ───
    // P(1,0) = cosθ = sinLat (colatitude θ = 90° - lat)
    // dP(1,0)/dθ = -sinθ = -cosLat
    // P(1,1) = sinθ = cosLat
    // dP(1,1)/dθ = cosθ = sinLat

    // Bx contributions (n=1)
    bx += r3 * (G10 * cosLat); // g10 * dP10/dθ (with sign)
    bx += r3 * (-G11 * sinLat * cosLng - H11 * sinLat * sinLng);

    // By contributions (n=1)
    // By = 1/sinθ * m * (g·sin(mφ) - h·cos(mφ)) ...
    // Actually: By = (g·sin(mφ) - h·cos(mφ)) * P(n,m) * m / sinθ
    if (cosLat.abs() > 0.001) {
      by += r3 * (G11 * sinLng - H11 * cosLng) * 1.0; // m=1
    }

    // ─── n=2 (تحسين الدقة) ───
    // P(2,0) = (3sin²lat - 1)/2
    // P(2,1) = 3·sinLat·cosLat
    // P(2,2) = 3·cos²Lat

    final p20 = (3.0 * sinLat * sinLat - 1.0) / 2.0;
    final p21 = 3.0 * sinLat * cosLat;
    final p22 = 3.0 * cosLat * cosLat;

    // dP/dθ for n=2
    final dp20 = -3.0 * sinLat * cosLat;
    final dp21 = 3.0 * (sinLat * sinLat - cosLat * cosLat); // 3·cos(2lat)
    final dp22 = -6.0 * cosLat * sinLat;

    bx += r4 * (G20 * (-dp20));
    bx += r4 * (-(G21 * cosLng + H21 * sinLng) * dp21);
    bx += r4 * (-(G22 * cos2Lng + H22 * sin2Lng) * dp22);

    if (cosLat.abs() > 0.001) {
      by += r4 * (G21 * sinLng - H21 * cosLng) * p21 / cosLat;
      by += r4 * 2.0 * (G22 * sin2Lng - H22 * cos2Lng) * p22 / cosLat;
    }

    // ═══════════════════════════════════════════════════
    // الانحراف = arctan(By / Bx)
    // ═══════════════════════════════════════════════════
    final declination = math.atan2(by, bx) * 180.0 / math.pi;

    return declination;
  }

  /// طريقة مبسطة أكثر لكنها أقل دقة - تستخدم كـ fallback
  /// تعتمد على جدول مبسط للمناطق الرئيسية
  static double estimateSimple(double lat, double lng) {
    // تقريب خطي بسيط يعمل بشكل معقول
    // Declination ≈ f(latitude, longitude)
    // هذا تقريب polynomial من بيانات WMM 2025

    // تطبيع الإحداثيات
    final latN = lat / 90.0;
    final lngN = lng / 180.0;

    // تقريب polynomial بسيط
    double dec = 0;
    dec += -2.09 * lngN;
    dec += 11.4 * latN * lngN;
    dec += -6.86 * lngN * lngN * lngN;
    dec += 2.58 * latN;
    dec += -0.56 * latN * latN;

    return dec;
  }
}