import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';

class AdhanAlarmManager {
  static final AudioPlayer _player = AudioPlayer();
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // ✅ تهيئة النظام
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();

    // تهيئة الإشعارات البسيطة (للعرض فقط)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
  }

  // ✅ جدولة أذان جديد
  static Future<void> scheduleAdhan(int id, DateTime time, String prayerName, String muezzinName) async {
    if (time.isBefore(DateTime.now())) return;

    debugPrint('🔔 جدولة أذان $prayerName باستخدام AlarmManager في: $time');

    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      _playAdhanCallback, // الدالة التي ستعمل في الخلفية
      exact: true,
      wakeup: true, // يوقظ الجهاز من النوم
      rescheduleOnReboot: true,
    );
  }

  // ✅ إلغاء كل الأذانات
  static Future<void> cancelAll() async {
    for (int i = 100; i <= 104; i++) {
      await AndroidAlarmManager.cancel(i);
    }
    // إيقاف أي صوت شغال
    try {
      await _player.stop();
    } catch (_) {}
  }

  // ==========================================
  // 🚀 الدالة التي تعمل في الخلفية وقت الأذان
  // يجب أن تكون @pragma('vm:entry-point') لتعمل والتطبيق مغلق
  // ==========================================
  @pragma('vm:entry-point')
  static Future<void> _playAdhanCallback(int id) async {
    debugPrint('⏰ حان وقت الأذان! استيقاظ في الخلفية...');

    // 1. إظهار إشعار صامت (لأننا سنشغل الصوت ببرنامجنا)
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'adhan_silent_channel',
        'تنبيهات الأذان',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false, // ❌ نمنع صوت النظام
        enableVibration: true,
        fullScreenIntent: true,
      ),
    );

    await _notifications.show(
      id,
      'حان وقت الصلاة',
      'اضغط لإيقاف الأذان',
      details,
    );

    // 2. تشغيل الصوت بأعلى قوة عبر JustAudio
    try {
      // ✅ نستخدم الملف من Assets (وليس من raw)
      // تأكد أن الملف موجود في assets/adahn/menshawy.mp3
      await _player.setAsset('assets/adahn/menshawy.mp3');

      // يمكنك محاولة رفع الصوت للحد الأقصى
      await _player.setVolume(1.0);

      await _player.play();

      // إيقاف الصوت تلقائياً بعد 4 دقائق مثلاً
      Future.delayed(const Duration(minutes: 4), () async {
        await _player.stop();
      });

    } catch (e) {
      debugPrint('❌ فشل تشغيل الصوت في الخلفية: $e');
    }
  }
}