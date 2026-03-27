package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            // ✅ إعلام Flutter بإعادة جدولة الأذان
            prefs.edit().putBoolean("flutter.needs_reschedule_after_boot", true).apply()

            // ✅ إعادة جدولة الصلاة على النبي تلقائياً
            val salawatEnabled = prefs.getBoolean("flutter.salawat_enabled", false)

            if (salawatEnabled) {
                val intervalMinutes = try {
                    prefs.getLong("flutter.salawat_interval_minutes", 30L)
                } catch (e: ClassCastException) {
                    prefs.getInt("flutter.salawat_interval_minutes", 30).toLong()
                }
                val intervalMillis = intervalMinutes * 60 * 1000
                val soundName = prefs.getString("flutter.salawat_sound", "saly") ?: "saly"
                val localPath = prefs.getString("flutter.salawat_local_path", null)
                val message = "اللهم صل وسلم على نبينا محمد ﷺ"
                val requestCode = 7007

                val triggerAt = System.currentTimeMillis() + intervalMillis

                AlarmScheduler.scheduleSalawat(
                    context = context,
                    triggerAtMillis = triggerAt,
                    intervalMillis = intervalMillis,
                    requestCode = requestCode,
                    message = message,
                    soundName = soundName,
                    localPath = localPath
                )
            }
        }
    }
}