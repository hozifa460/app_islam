import 'package:flutter/services.dart';

class NativeAdhanBridge {
  static const MethodChannel _channel = MethodChannel('adhan_native_bridge');

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
      'isReminder': false,
    });
  }

  static Future<void> scheduleReminder({
    required DateTime time,
    required String prayerName,
    required int requestCode,
    String soundName = 'reminder_beep',
  }) async {
    await _channel.invokeMethod('scheduleNativeAdhan', {
      'triggerAt': time.millisecondsSinceEpoch,
      'prayerName': prayerName,
      'requestCode': requestCode,
      'soundName': soundName,
      'localPath': null,
      'isReminder': true,
    });
  }

  static Future<void> cancelAdhan(int requestCode) async {
    await _channel.invokeMethod('cancelNativeAdhan', {
      'requestCode': requestCode,
    });
  }
}