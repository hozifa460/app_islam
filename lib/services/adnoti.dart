import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
  }

  // جدولة الأذان الأساسي
  static Future<void> scheduleAdhan({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String soundName, // اسم الملف في مجلد raw بدون .mp3
  }) async {
    if (time.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'adhan_channel_$soundName', // قناة منفصلة لكل صوت
      'تنبيهات الأذان',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundName),
      fullScreenIntent: true, // يفتح الشاشة المغلقة
      category: AndroidNotificationCategory.alarm,
    );

    await _plugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // جدولة التذكير قبل الصلاة (بدون أذان)
  static Future<void> scheduleReminder(int id, String title, DateTime time) async {
    if (time.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel', 'تذكير قبل الصلاة',
      importance: Importance.high,
    );

    await _plugin.zonedSchedule(
      id, title, 'اقترب موعد الصلاة، استعد للوضوء',
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async => await _plugin.cancelAll();
}