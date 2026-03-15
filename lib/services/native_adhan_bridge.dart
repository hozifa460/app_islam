import 'package:flutter/services.dart';

class NativeAdhanBridge {
  static const MethodChannel _channel = MethodChannel('adhan_native_bridge');

  static Future<void> scheduleAdhan({
    required DateTime time,
    required String prayerName,
    required int requestCode,
  }) async {
    await _channel.invokeMethod('scheduleNativeAdhan', {
      'triggerAt': time.millisecondsSinceEpoch,
      'prayerName': prayerName,
      'requestCode': requestCode,
    });
  }

  static Future<void> cancelAdhan(int requestCode) async {
    await _channel.invokeMethod('cancelNativeAdhan', {
      'requestCode': requestCode,
    });
  }
}