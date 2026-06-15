package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) return

        Log.d(TAG, "Boot completed - rescheduling everything")

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "appislam:bootWakeLock"
        )
        wakeLock.acquire(2 * 60 * 1000L)

        try {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            val adhanEnabled = prefs.getBoolean("flutter.adhan_enabled", false)
            if (adhanEnabled) {
                NativePrayerScheduler.scheduleAll(context)
                Log.d(TAG, "Prayer alarms rescheduled")
            }

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

                AlarmScheduler.scheduleSalawat(
                    context = context,
                    triggerAtMillis = System.currentTimeMillis() + intervalMillis,
                    intervalMillis = intervalMillis,
                    requestCode = 7007,
                    message = "اللهم صل وسلم على نبينا محمد ﷺ",
                    soundName = soundName,
                    localPath = localPath
                )
            }

            DailyRescheduleManager.scheduleDailyReschedule(context)

        } catch (e: Exception) {
            Log.e(TAG, "Error during boot reschedule", e)
        } finally {
            if (wakeLock.isHeld) wakeLock.release()
        }
    }
}