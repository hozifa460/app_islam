import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// تهيئة بسيطة - تُستدعى فقط عند الحاجة
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // إنشاء قناة الختمة
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const khatmaChannel = AndroidNotificationChannel(
        'khatma_channel',
        'تذكير الختمة',
        description: 'تذكير يومي لقراءة الورد',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(khatmaChannel);
    }

    _initialized = true;
  }

  /// جدولة تذكير الختمة اليومي
  static Future<void> scheduleKhatmaReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _ensureInitialized();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

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

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// إلغاء تذكير الختمة
  static Future<void> cancelKhatmaReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// إلغاء كل الإشعارات
  static Future<void> cancelAll() async => await _plugin.cancelAll();
}