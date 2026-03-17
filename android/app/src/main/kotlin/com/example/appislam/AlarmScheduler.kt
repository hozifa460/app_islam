package com.example.appislam

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent

object AlarmScheduler {

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
}