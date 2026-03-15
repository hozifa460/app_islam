import 'package:shared_preferences/shared_preferences.dart';
import '../data/prayer/muezzin_catalog.dart';

class MuezzinStore {
  static const _kDefaultId = 'default_muezzin_id';
  static const _kDefaultName = 'default_muezzin_name';
  static const _kDefaultUrl = 'default_muezzin_url';
  static const _kDefaultLocalSound = 'default_muezzin_local_sound';

  static String _customIdKey(String prayerKey) => 'custom_${prayerKey}_muezzin_id';
  static String _customNameKey(String prayerKey) => 'custom_${prayerKey}_muezzin_name';
  static String _customUrlKey(String prayerKey) => 'custom_${prayerKey}_muezzin_url';
  static String _customLocalSoundKey(String prayerKey) => 'custom_${prayerKey}_muezzin_local_sound';

  static Future<MuezzinInfo> getDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kDefaultId);
    final name = prefs.getString(_kDefaultName);
    final url = prefs.getString(_kDefaultUrl);
    final localSound = prefs.getString(_kDefaultLocalSound);

    if (id != null && name != null && url != null && localSound != null) {
      return MuezzinInfo(
        id: id,
        name: name,
        url: url,
        description: '',
        imageUrl: '',
        localSoundName: localSound,
      );
    }

    final first = muezzinCatalog.first.items.first;
    await setDefault(first, resetAllCustom: true);
    return first;
  }

  static Future<void> setDefault(MuezzinInfo m, {required bool resetAllCustom}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultId, m.id);
    await prefs.setString(_kDefaultName, m.name);
    await prefs.setString(_kDefaultUrl, m.url);
    await prefs.setString(_kDefaultLocalSound, m.localSoundName);

    if (resetAllCustom) {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        await clearCustomForPrayer(key);
      }
    }
  }

  static Future<void> setCustomForPrayer(String prayerKey, MuezzinInfo m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customIdKey(prayerKey), m.id);
    await prefs.setString(_customNameKey(prayerKey), m.name);
    await prefs.setString(_customUrlKey(prayerKey), m.url);
    await prefs.setString(_customLocalSoundKey(prayerKey), m.localSoundName);
  }

  static Future<MuezzinInfo?> getCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_customIdKey(prayerKey));
    final name = prefs.getString(_customNameKey(prayerKey));
    final url = prefs.getString(_customUrlKey(prayerKey));
    final localSound = prefs.getString(_customLocalSoundKey(prayerKey));

    if (id == null || name == null || url == null || localSound == null) {
      return null;
    }

    return MuezzinInfo(
      id: id,
      name: name,
      url: url,
      description: '',
      imageUrl: '',
      localSoundName: localSound,
    );
  }

  static Future<void> clearCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customIdKey(prayerKey));
    await prefs.remove(_customNameKey(prayerKey));
    await prefs.remove(_customUrlKey(prayerKey));
    await prefs.remove(_customLocalSoundKey(prayerKey));
  }

  static Future<MuezzinInfo> getEffectiveForPrayer(String prayerKey) async {
    final custom = await getCustomForPrayer(prayerKey);
    return custom ?? await getDefault();
  }
}