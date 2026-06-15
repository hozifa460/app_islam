package com.example.appislam

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

object DailyRescheduleManager {

    private const val TAG = "DailyRescheduleManager"
    private const val DAILY_RESCHEDULE_REQUEST_CODE = 8888

    fun scheduleDailyReschedule(context: Context) {
        val intent = Intent(context, DailyRescheduleReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, DAILY_RESCHEDULE_REQUEST_CODE, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 5)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent
            )
            Log.d(TAG, "Daily reschedule set for: ${calendar.time}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule daily reschedule", e)
        }
    }

    fun cancel(context: Context) {
        val intent = Intent(context, DailyRescheduleReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, DAILY_RESCHEDULE_REQUEST_CODE, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }
}