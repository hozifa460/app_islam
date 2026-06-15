import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AdahnNotification {
  AdahnNotification._();

  static final AdahnNotification _instance = AdahnNotification._();
  static AdahnNotification get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Function(Map<String, dynamic> payload)? onNotificationTap;

  Future<void> init() async {
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