import 'package:shared_preferences/shared_preferences.dart';

class HomePreviewSettingsService {
  static const String _enabledKey = 'home_preview_enabled_v1';
  static const String _autoplayKey = 'home_preview_autoplay_v1';
  static const String _mutedKey = 'home_preview_muted_v1';
  static const String _durationKey = 'home_preview_duration_v1';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  static Future<bool> isAutoplayEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoplayKey) ?? true;
  }

  static Future<void> setAutoplayEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayKey, value);
  }

  static Future<bool> isMuted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mutedKey) ?? true;
  }

  static Future<void> setMuted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, value);
  }

  static Future<int> previewDurationSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_durationKey) ?? 12;
  }

  static Future<void> setPreviewDurationSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, seconds);
  }
}