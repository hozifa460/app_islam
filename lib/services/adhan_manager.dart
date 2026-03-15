import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_calculator_service.dart';
import 'notification_service.dart';

class AdhanManager {
  static Future<void> schedulePrayersForNextWeek() async {
    final prefs = await SharedPreferences.getInstance();

    // قراءة إعدادات المستخدم
    bool adhanEnabled = prefs.getBool('adhan_enabled') ?? true;
    bool reminderEnabled = prefs.getBool('reminder_enabled') ?? true;
    int reminderOffset = prefs.getInt('reminder_offset') ?? 10; // 10 دقائق قبل الصلاة
    String method = prefs.getString('calc_method') ?? 'umm_al_qura';
    String soundName = prefs.getString('adhan_sound') ?? 'makkah';

    // مسح الجدولة القديمة
    await NotificationService.cancelAll();

    if (!adhanEnabled) return; // إذا كان الأذان مغلقاً، نتوقف هنا

    // جلب الموقع
    final position = await PrayerCalculatorService.getLocation();
    if (position == null) return;

    // جدولة لمدة 7 أيام قادمة (ليعمل الأوفلاين)
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final prayers = PrayerCalculatorService.getPrayerTimes(position, date, method);

      if (prayers == null) continue;

      // قائمة الصلوات (تخطي الشروق لأنه ليس صلاة مفروضة)
      final prayerMap = {
        'الفجر': prayers.fajr,
        'الظهر': prayers.dhuhr,
        'العصر': prayers.asr,
        'المغرب': prayers.maghrib,
        'العشاء': prayers.isha,
      };

      int baseId = i * 10; // لضمان عدم تداخل الـ IDs

      int j = 0;
      prayerMap.forEach((name, time) {
        final adhanId = baseId + j;
        final reminderId = baseId + j + 1000;

        // 1. جدولة الأذان
        NotificationService.scheduleAdhan(
          id: adhanId,
          title: 'حان وقت صلاة $name',
          body: 'الصلاة خير من النوم',
          time: time,
          soundName: soundName, payload: {},
        );

        // 2. جدولة التذكير القبلي
        if (reminderEnabled) {
          final reminderTime = time.subtract(Duration(minutes: reminderOffset));
          NotificationService.scheduleReminder(
            reminderId,
            'تذكير بصلاة $name بعد $reminderOffset دقائق',
            reminderTime,
          );
        }
        j++;
      });
    }
  }
}