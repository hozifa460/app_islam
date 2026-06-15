package com.example.appislam

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

object AlarmScheduler {

    private const val TAG = "AlarmScheduler"

    // ========== الأذان ==========
    fun scheduleAdhan(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?,
        isReminder: Boolean
    ): Boolean {
        if (triggerAtMillis <= System.currentTimeMillis()) {
            Log.w(TAG, "⏭️ Skipping adhan $prayerName - time already passed")
            return false
        }

        Log.d(TAG, "scheduleAdhan: $prayerName at $triggerAtMillis (code=$requestCode)")

        val intent = Intent(context, AdhanReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("isReminder", isReminder)
            putExtra("requestCode", requestCode)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return scheduleExactAlarm(context, triggerAtMillis, pendingIntent, "Adhan $prayerName")
    }

    fun cancelAdhan(context: Context, requestCode: Int) {
        val intent = Intent(context, AdhanReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }

    // ========== التنبيه القبلي ==========
    fun scheduleReminder(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?
    ): Boolean {
        if (triggerAtMillis <= System.currentTimeMillis()) {
            Log.w(TAG, "⏭️ Skipping reminder $prayerName - time already passed")
            return false
        }

        Log.d(TAG, "scheduleReminder: $prayerName at $triggerAtMillis (code=$requestCode)")

        val intent = Intent(context, ReminderReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("requestCode", requestCode)
            putExtra("triggerAt", triggerAtMillis)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return scheduleExactAlarm(context, triggerAtMillis, pendingIntent, "Reminder $prayerName")
    }

    fun cancelReminder(context: Context, requestCode: Int) {
        val intent = Intent(context, ReminderReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }

    // ========== الإقامة ==========
    fun scheduleIqama(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?
    ): Boolean {
        if (triggerAtMillis <= System.currentTimeMillis()) {
            Log.w(TAG, "⏭️ Skipping iqama $prayerName - time already passed")
            return false
        }

        Log.d(TAG, "scheduleIqama: $prayerName at $triggerAtMillis (code=$requestCode)")

        val intent = Intent(context, IqamaReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("requestCode", requestCode)
            putExtra("triggerAt", triggerAtMillis)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return scheduleExactAlarm(context, triggerAtMillis, pendingIntent, "Iqama $prayerName")
    }

    fun cancelIqama(context: Context, requestCode: Int) {
        val intent = Intent(context, IqamaReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }

    // ========== الصلاة على النبي ==========
    fun scheduleSalawat(
        context: Context,
        triggerAtMillis: Long,
        intervalMillis: Long,
        requestCode: Int,
        message: String,
        soundName: String,
        localPath: String?
    ) {
        Log.d(TAG, "scheduleSalawat at $triggerAtMillis")

        val intent = Intent(context, SalawatReceiver::class.java).apply {
            putExtra("message", message)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("intervalMillis", intervalMillis)
            putExtra("requestCode", requestCode)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        scheduleExactAlarm(context, triggerAtMillis, pendingIntent, "Salawat")
    }

    fun cancelSalawat(context: Context, requestCode: Int) {
        val intent = Intent(context, SalawatReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }

    // ✅ دالة موحدة للجدولة
    private fun scheduleExactAlarm(
        context: Context,
        triggerAtMillis: Long,
        pendingIntent: PendingIntent,
        label: String
    ): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (!alarmManager.canScheduleExactAlarms()) {
                    Log.e(TAG, "❌ Cannot schedule exact alarms - permission denied")
                    return false
                }
            }

            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent
            )
            Log.d(TAG, "✅ $label scheduled successfully")
            true
        } catch (e: SecurityException) {
            Log.e(TAG, "❌ SecurityException scheduling $label", e)
            false
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to schedule $label", e)
            false
        }
    }
}