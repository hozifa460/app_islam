import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════
///  خدمة الإشعارات للبثوث المباشرة
/// ═══════════════════════════════════════════════════════════════
class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static SharedPreferences? _prefs;
  static const String _keySubscribedChannels = 'subscribed_channels';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  static bool _initialized = false;

  /// تهيئة الإشعارات
  static Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('🔔 Notifications initialized');
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('📲 Notification tapped: $payload');
      // يمكن التعامل مع الـ payload هنا (مثل فتح الفيديو)
    }
  }

  /// طلب إذن الإشعارات
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// التحقق من تفعيل الإشعارات
  static bool get isEnabled => _prefs?.getBool(_keyNotificationsEnabled) ?? true;

  /// تفعيل/إلغاء الإشعارات
  static Future<void> setEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  /// الاشتراك في إشعارات قناة
  static Future<void> subscribeToChannel(String channelId, String channelName) async {
    final channels = _getSubscribedChannels();

    if (!channels.containsKey(channelId)) {
      channels[channelId] = {
        'name': channelName,
        'subscribedAt': DateTime.now().toIso8601String(),
      };
      await _saveSubscribedChannels(channels);
      debugPrint('🔔 Subscribed to: $channelName');
    }
  }

  /// إلغاء الاشتراك من إشعارات قناة
  static Future<void> unsubscribeFromChannel(String channelId) async {
    final channels = _getSubscribedChannels();
    channels.remove(channelId);
    await _saveSubscribedChannels(channels);
    debugPrint('🔕 Unsubscribed from: $channelId');
  }

  /// التحقق من الاشتراك
  static bool isSubscribedToChannel(String channelId) {
    return _getSubscribedChannels().containsKey(channelId);
  }

  /// الحصول على القنوات المشترك بها
  static Map<String, dynamic> _getSubscribedChannels() {
    try {
      final jsonStr = _prefs?.getString(_keySubscribedChannels);
      if (jsonStr == null) return {};
      return Map<String, dynamic>.from(json.decode(jsonStr));
    } catch (e) {
      return {};
    }
  }

  static Future<void> _saveSubscribedChannels(Map<String, dynamic> channels) async {
    await _prefs?.setString(_keySubscribedChannels, json.encode(channels));
  }

  /// إرسال إشعار بث مباشر
  static Future<void> showLiveNotification({
    required String channelName,
    required String title,
    required String videoId,
  }) async {
    if (!isEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'live_channel',
      'البث المباشر',
      channelDescription: 'إشعارات البث المباشر',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFEF4444),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      videoId.hashCode,
      '🔴 $channelName بث مباشر الآن',
      title,
      details,
      payload: json.encode({
        'type': 'live',
        'videoId': videoId,
        'channelName': channelName,
      }),
    );
  }

  /// إشعار فيديو جديد
  static Future<void> showNewVideoNotification({
    required String channelName,
    required String title,
    required String videoId,
  }) async {
    if (!isEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'new_video_channel',
      'فيديوهات جديدة',
      channelDescription: 'إشعارات الفيديوهات الجديدة',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      videoId.hashCode,
      '🎬 فيديو جديد من $channelName',
      title,
      details,
      payload: json.encode({
        'type': 'new_video',
        'videoId': videoId,
      }),
    );
  }

  /// إلغاء كل الإشعارات
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}