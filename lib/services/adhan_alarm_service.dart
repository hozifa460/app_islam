import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class AdhanAlarmService {
  static final AudioPlayer _player = AudioPlayer();

  @pragma('vm:entry-point')
  static Future<void> ringAlarm() async {
    try {
      await _player.setAsset('assets/adahn/menshawy.mp3');
      await _player.setVolume(1.0);
      await _player.play();

      // إيقاف تلقائي بعد 3 دقائق
      Future.delayed(const Duration(minutes: 3), () async {
        try {
          await _player.stop();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('❌ خطأ تشغيل الأذان: $e');
    }
  }

  static Future<void> schedule({
    required int id,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    await AndroidAlarmManager.oneShotAt(
      dateTime,
      id,
      ringAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancel(int id) async {
    await AndroidAlarmManager.cancel(id);
  }

  static Future<void> cancelAll(List<int> ids) async {
    for (final id in ids) {
      await AndroidAlarmManager.cancel(id);
    }
  }
}