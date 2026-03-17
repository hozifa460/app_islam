import 'package:shared_preferences/shared_preferences.dart';
import '../data/prayer/muezzin_catalog.dart';

class MuezzinStore {
  static const _kDefaultId = 'default_muezzin_id';

  static String _customIdKey(String prayerKey) => 'custom_${prayerKey}_muezzin_id';

  static Future<MuezzinInfo> getDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kDefaultId);

    if (id != null) {
      final found = findMuezzinById(id);
      if (found != null) return found;
    }

    final first = muezzinCatalog.first.items.first;
    await setDefault(first, resetAllCustom: true);
    return first;
  }

  static Future<void> setDefault(MuezzinInfo m, {required bool resetAllCustom}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultId, m.id);

    if (resetAllCustom) {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        await clearCustomForPrayer(key);
      }
    }
  }

  static Future<void> setCustomForPrayer(String prayerKey, MuezzinInfo m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customIdKey(prayerKey), m.id);
  }

  static Future<MuezzinInfo?> getCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_customIdKey(prayerKey));

    if (id == null) return null;

    return findMuezzinById(id);
  }

  static Future<void> clearCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customIdKey(prayerKey));
  }

  static Future<MuezzinInfo> getEffectiveForPrayer(String prayerKey) async {
    final custom = await getCustomForPrayer(prayerKey);
    return custom ?? await getDefault();
  }
}