import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class AdahnNotification {
  AdahnNotification._();

  static final AdahnNotification _instance = AdahnNotification._();
  static AdahnNotification get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Function(Map<String, dynamic> payload)? onNotificationTap;

  static const String _adhanChannelId = 'adhan_channel_v3001';
  static const String _adhanChannelName = 'أذان التطبيق';
  static const String _adhanChannelDesc = 'تنبيهات الأذان';

  static const String _reminderChannelId = 'reminder_channel_v3001';
  static const String _reminderChannelName = 'تذكير قبل الصلاة';
  static const String _reminderChannelDesc = 'تنبيهات قبل الصلاة';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

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

    const AndroidNotificationChannel adhanChannel =
    AndroidNotificationChannel(
      _adhanChannelId,
      _adhanChannelName,
      description: _adhanChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('makkah'),
    );

    const AndroidNotificationChannel reminderChannel =
    AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('reminder_beep'),
    );

    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(adhanChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    final type = payload['type']?.toString() ?? 'adhan';
    final isReminder = type == 'reminder';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        isReminder ? _reminderChannelId : _adhanChannelId,
        isReminder ? _reminderChannelName : _adhanChannelName,
        channelDescription:
        isReminder ? _reminderChannelDesc : _adhanChannelDesc,
        importance: isReminder ? Importance.high : Importance.max,
        priority: isReminder ? Priority.high : Priority.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(
          isReminder ? 'reminder_beep' : 'makkah',
        ),
        category: isReminder
            ? AndroidNotificationCategory.reminder
            : AndroidNotificationCategory.alarm,
        fullScreenIntent: false,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        ongoing: false,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: isReminder ? 'reminder_beep.aiff' : null,
      ),
    );

    final scheduled = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _adhanChannelId,
        _adhanChannelName,
        channelDescription: _adhanChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('makkah'),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      5555,
      'اختبار صوت الأذان',
      'إذا سمعت الصوت فالقناة تعمل بشكل صحيح',
      details,
      payload: jsonEncode({'type': 'adhan'}),
    );
  }

  Future<void> showInstantReminderTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: _reminderChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('reminder_beep'),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      5556,
      'اختبار تنبيه قبل الصلاة',
      'هذا تنبيه تجريبي بصوت قصير',
      details,
      payload: jsonEncode({'type': 'reminder'}),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

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