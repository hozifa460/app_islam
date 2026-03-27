package com.example.appislam

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent

object AlarmScheduler {

    // ========== الأذان (بدون تعديل) ==========
    fun scheduleAdhan(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?,
        isReminder: Boolean
    ) {
        val intent = Intent(context, AdhanReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("isReminder", isReminder)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            pendingIntent
        )
    }

    fun cancelAdhan(context: Context, requestCode: Int) {
        val intent = Intent(context, AdhanReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
    }

    // ========== الصلاة على النبي (بدون تعديل) ==========
    fun scheduleSalawat(
        context: Context,
        triggerAtMillis: Long,
        intervalMillis: Long,
        requestCode: Int,
        message: String,
        soundName: String,
        localPath: String?
    ) {
        val intent = Intent(context, SalawatReceiver::class.java).apply {
            putExtra("message", message)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("intervalMillis", intervalMillis)
            putExtra("requestCode", requestCode)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            pendingIntent
        )
    }

    fun cancelSalawat(context: Context, requestCode: Int) {
        val intent = Intent(context, SalawatReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
    }

    // ========== التنبيه القبلي ==========
    fun scheduleReminder(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?
    ) {
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("requestCode", requestCode)
            putExtra("triggerAt", triggerAtMillis)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            pendingIntent
        )
    }

    fun cancelReminder(context: Context, requestCode: Int) {
        val intent = Intent(context, ReminderReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
    }

    // ========== الإقامة ==========
    fun scheduleIqama(
        context: Context,
        triggerAtMillis: Long,
        prayerName: String,
        requestCode: Int,
        soundName: String,
        localPath: String?
    ) {
        val intent = Intent(context, IqamaReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("soundName", soundName)
            putExtra("localPath", localPath)
            putExtra("requestCode", requestCode)
            putExtra("triggerAt", triggerAtMillis)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            pendingIntent
        )
    }

    fun cancelIqama(context: Context, requestCode: Int) {
        val intent = Intent(context, IqamaReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
    }
}