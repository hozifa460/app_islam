import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      // يمكنك إضافة onDidReceiveNotificationResponse هنا لفتح شاشة الأذان
    );
  }

  // ✅ الدالة الذكية لجدولة الأذان بصوت متغير
  static Future<void> scheduleAdhan({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String soundName, // اسم ملف الصوت (مثلاً 'sudais', 'menshawy')
    required Map<String, dynamic> payload,
  }) async {
    if (time.isBefore(DateTime.now())) return;

    // 1. إنشاء قناة خاصة بهذا الصوت تحديداً
    final String channelId = 'adhan_channel_$soundName';

    final AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      channelId,
      'أذان بصوت $soundName',
      description: 'تنبيهات الأذان',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      // ✅ هنا يتم ربط القناة بملف الصوت الموجود في مجلد raw
      sound: RawResourceAndroidNotificationSound(soundName),
    );

    // 2. تسجيل القناة في نظام أندرويد
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhanChannel);

    // 3. إعداد تفاصيل الإشعار بناءً على هذه القناة
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'أذان بصوت $soundName',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      fullScreenIntent: true, // يفتح الشاشة
      category: AndroidNotificationCategory.alarm,
    );

    // 4. جدولة الإشعار
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails()),
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleReminder(int id, String title, DateTime time) async {
    if (time.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'تذكير قبل الصلاة',
      importance: Importance.high,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      'اقترب موعد الصلاة، استعد للوضوء',
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleKhatmaReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time, // وقت التذكير اليومي
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // إذا كان الوقت قد مر اليوم، جدوله للغد
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'khatma_channel',
      'تذكير الختمة',
      channelDescription: 'تذكير يومي لقراءة الورد',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    // استخدام matchDateTimeComponents لجعل التذكير يتكرر يومياً في نفس الوقت
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 👈 التكرار اليومي
    );
  }

  // ✅ دالة لإلغاء تذكير الختمة (إذا أوقفه المستخدم)
  static Future<void> cancelKhatmaReminder(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async => await _plugin.cancelAll();
}
