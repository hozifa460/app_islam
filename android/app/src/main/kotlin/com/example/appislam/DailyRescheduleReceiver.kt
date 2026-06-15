package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log

class DailyRescheduleReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "DailyReschedule"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Daily reschedule at midnight!")

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "appislam:dailyRescheduleWakeLock"
        )
        wakeLock.acquire(2 * 60 * 1000L)

        try {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            val adhanEnabled = prefs.getBoolean("flutter.adhan_enabled", false)

            if (adhanEnabled) {
                NativePrayerScheduler.scheduleAll(context)
                Log.d(TAG, "Daily reschedule completed")
            } else {
                Log.d(TAG, "Adhan disabled, skipping reschedule")
            }

            if (PrayerTimesScheduleStorage.needsUpdate(context)) {
                prefs.edit()
                    .putBoolean("flutter.prayer_schedule_needs_update", true)
                    .apply()
                Log.w(TAG, "Schedule needs update from Flutter")
            }

            DailyRescheduleManager.scheduleDailyReschedule(context)

        } catch (e: Exception) {
            Log.e(TAG, "Error in daily reschedule", e)
        } finally {
            if (wakeLock.isHeld) wakeLock.release()
        }
    }
}