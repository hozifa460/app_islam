import 'package:flutter/services.dart';

class NativeAdhanBridge {
  static const MethodChannel _channel = MethodChannel('adhan_native_bridge');

  // ========== الأذان ==========
  static Future<void> scheduleAdhan({
    required DateTime time,
    required String prayerName,
    required int requestCode,
    required String soundName,
    String? localPath,
  }) async {
    await _channel.invokeMethod('scheduleNativeAdhan', {
      'triggerAt': time.millisecondsSinceEpoch,
      'prayerName': prayerName,
      'requestCode': requestCode,
      'soundName': soundName,
      'localPath': localPath,
    });
  }

  static Future<void> cancelAdhan(int requestCode) async {
    await _channel.invokeMethod('cancelNativeAdhan', {
      'requestCode': requestCode,
    });
  }

  // ========== التنبيه القبلي ==========
  static Future<void> scheduleReminder({
    required DateTime time,
    required String prayerName,
    required int requestCode,
    String soundName = 'hayalaaslah',
    String? localPath,
  }) async {
    await _channel.invokeMethod('scheduleNativeReminder', {
      'triggerAt': time.millisecondsSinceEpoch,
      'prayerName': prayerName,
      'requestCode': requestCode,
      'soundName': soundName,
      'localPath': localPath,
    });
  }

  static Future<void> cancelReminder(int requestCode) async {
    await _channel.invokeMethod('cancelNativeReminder', {
      'requestCode': requestCode,
    });
  }

  // ========== الإقامة ==========
  static Future<void> scheduleIqama({
    required DateTime time,
    required String prayerName,
    required int requestCode,
    required String soundName,
    String? localPath,
  }) async {
    await _channel.invokeMethod('scheduleNativeIqama', {
      'triggerAt': time.millisecondsSinceEpoch,
      'prayerName': prayerName,
      'requestCode': requestCode,
      'soundName': soundName,
      'localPath': localPath,
    });
  }

  static Future<void> cancelIqama(int requestCode) async {
    await _channel.invokeMethod('cancelNativeIqama', {
      'requestCode': requestCode,
    });
  }

  // ========== الصلاة على النبي ==========
  static Future<void> scheduleSalawatReminder({
    required DateTime startTime,
    required Duration interval,
    int requestCode = 7007,
    String message = 'اللهم صل وسلم على نبينا محمد ﷺ',
    String soundName = 'saly',
    String? localPath,
  }) async {
    await _channel.invokeMethod('scheduleSalawatReminder', {
      'triggerAt': startTime.millisecondsSinceEpoch,
      'intervalMillis': interval.inMilliseconds,
      'requestCode': requestCode,
      'message': message,
      'soundName': soundName,
      'localPath': localPath,
    });
  }

  static Future<void> cancelSalawatReminder({int requestCode = 7007}) async {
    await _channel.invokeMethod('cancelSalawatReminder', {
      'requestCode': requestCode,
    });
  }

  // ✅ حفظ جدول الصلوات
  static Future<void> savePrayerSchedule({
    required List<Map<String, dynamic>> schedule,
  }) async {
    await _channel.invokeMethod('savePrayerSchedule', {'schedule': schedule});
  }

  // ✅ جديد: إلغاء جميع المنبهات
  static Future<void> cancelAllAlarms() async {
    await _channel.invokeMethod('cancelAllAlarms');
  }

  /// إعادة جدولة الجدول المحفوظ فقط، دون إنشاء مسار جدولة موازٍ من الشاشة.
  static Future<void> rescheduleSavedPrayerSchedule() async {
    await _channel.invokeMethod('rescheduleSavedPrayerSchedule');
  }

  // ✅ جديد: توليد requestCode موحد بين Flutter و Kotlin
  static int generateRequestCode(int dayIndex, int prayerIndex, int type) {
    return 10000 + (type * 1000) + (dayIndex * 5) + prayerIndex;
  }

  static const Map<String, int> prayerIndices = {
    'Fajr': 0,
    'Dhuhr': 1,
    'Asr': 2,
    'Maghrib': 3,
    'Isha': 4,
  };
}
