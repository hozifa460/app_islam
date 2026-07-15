package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Keeps RTC alarms aligned when Android changes the wall clock, timezone, or
 * date. Flutter will refresh the API/cache the next time it is resumed.
 */
class TimeChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_TIMEZONE_CHANGED &&
            action != Intent.ACTION_TIME_CHANGED &&
            action != Intent.ACTION_DATE_CHANGED
        ) return

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        prefs.edit()
            .putBoolean("flutter.prayer_schedule_needs_update", true)
            .putBoolean("flutter.full_schedule_saved", false)
            .apply()

        try {
            if (prefs.getBoolean("flutter.adhan_enabled", false)) {
                NativePrayerScheduler.scheduleAll(context)
            }
            DailyRescheduleManager.scheduleDailyReschedule(context)
            Log.d("TimeChangeReceiver", "Prayer alarms refreshed for $action")
        } catch (error: Exception) {
            Log.e("TimeChangeReceiver", "Unable to refresh prayer alarms", error)
        }
    }
}
