import 'package:shared_preferences/shared_preferences.dart';
import '../data/prayer/muezzin_catalog.dart';

class MuezzinStore {
  static const _kDefaultId = 'default_muezzin_id';
  static const _kDefaultName = 'default_muezzin_name';
  static const _kDefaultUrl = 'default_muezzin_url';

  /// تخصيص لكل صلاة (اختياري لاحقًا)
  static String _customIdKey(String prayerKey) => 'custom_${prayerKey}_muezzin_id';
  static String _customNameKey(String prayerKey) => 'custom_${prayerKey}_muezzin_name';
  static String _customUrlKey(String prayerKey) => 'custom_${prayerKey}_muezzin_url';

  /// اجلب الافتراضي (إن لم يوجد → أول عنصر في الكتالوج)
  static Future<MuezzinInfo> getDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kDefaultId);
    final name = prefs.getString(_kDefaultName);
    final url = prefs.getString(_kDefaultUrl);

    if (id != null && name != null && url != null) {
      return MuezzinInfo(
        id: id,
        name: name,
        url: url,
        description: '',
        imageUrl: '',
      );
    }

    // fallback من الكتالوج
    final first = muezzinCatalog.first.items.first;
    await setDefault(first, resetAllCustom: true);
    return first;
  }

  static Future<void> clearCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customIdKey(prayerKey));
    await prefs.remove(_customNameKey(prayerKey));
    await prefs.remove(_customUrlKey(prayerKey));
  }

  /// ضبط الافتراضي + (حسب طلبك) يرجّع كل الصلوات لنفس الافتراضي بإزالة تخصيصات الصلوات
  static Future<void> setDefault(MuezzinInfo m, {required bool resetAllCustom}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultId, m.id);
    await prefs.setString(_kDefaultName, m.name);
    await prefs.setString(_kDefaultUrl, m.url);

    if (resetAllCustom) {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        await prefs.remove(_customIdKey(key));
        await prefs.remove(_customNameKey(key));
        await prefs.remove(_customUrlKey(key));
      }
    }
  }

  /// (اختياري) تخصيص مؤذن لصلاة معينة
  static Future<void> setCustomForPrayer(String prayerKey, MuezzinInfo m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customIdKey(prayerKey), m.id);
    await prefs.setString(_customNameKey(prayerKey), m.name);
    await prefs.setString(_customUrlKey(prayerKey), m.url);
  }

  static Future<MuezzinInfo?> getCustomForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_customIdKey(prayerKey));
    final name = prefs.getString(_customNameKey(prayerKey));
    final url = prefs.getString(_customUrlKey(prayerKey));
    if (id == null || name == null || url == null) return null;

    return MuezzinInfo(id: id, name: name, url: url, description: '', imageUrl: '');
  }

  static Future<MuezzinInfo> getEffectiveForPrayer(String prayerKey) async {
    final custom = await getCustomForPrayer(prayerKey);
    return custom ?? await getDefault();
  }
}