import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class AdahnNotification {
  AdahnNotification._();
  static final AdahnNotification _instance = AdahnNotification._();
  static AdahnNotification get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Function(Map<String, dynamic> payload)? onNotificationTap;

  // ✅ غيرت الـ ID لضمان إنشاء قناة جديدة تماماً
  static const String _adhanChannelId = 'adhan_channel_alarm_110';
  static const String _adhanChannelName = 'تنبيهات الأذان';
  static const String _adhanChannelDesc = 'تنبيهات وقت الصلاة بصوت عالٍ';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && onNotificationTap != null) {
          try {
            final data = jsonDecode(response.payload!);
            onNotificationTap!(Map<String, dynamic>.from(data));
          } catch (_) {}
        }
      },
    );

    // ✅ إجبار أندرويد على التعامل مع الصوت كمنبه (Alarm) لتجاوز الصامت
    final AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      _adhanChannelId,
      _adhanChannelName,
      description: _adhanChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      // تأكد أن ملف menshawy.wav موجود في android/app/src/main/res/raw/
      sound: const RawResourceAndroidNotificationSound('menshawy'),
      // ✅ هذه الأسطر مهمة جداً لهواتف شاومي
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhanChannel);
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _adhanChannelId,
        _adhanChannelName,
        channelDescription: _adhanChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('menshawy'),
        audioAttributesUsage: AudioAttributesUsage.alarm, // ✅ مهم للصوت
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: true,
        icon: '@mipmap/ic_launcher',
        // ✅ إضافة خيارات إضافية للإضاءة والاهتزاز
        enableLights: true,
        color: const Color(0xFFE6B325),
        ledColor: const Color(0xFFE6B325),
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: jsonEncode(payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ تم الجدولة بنجاح');
    } catch (e) {
      debugPrint('❌ فشل الجدولة الدقيقة، محاولة الخطة البديلة: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          payload: jsonEncode(payload),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e2) {
        debugPrint('❌ فشل الجدولة تماماً: $e2');
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      try {
        await android.requestExactAlarmsPermission();
      } catch (_) {}
      return granted ?? false;
    }
    return true;
  }
}