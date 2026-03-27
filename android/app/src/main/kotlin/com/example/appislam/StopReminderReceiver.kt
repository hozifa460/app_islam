package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class StopReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notificationId", 0)

        try {
            ReminderReceiver.mediaPlayer?.stop()
            ReminderReceiver.mediaPlayer?.release()
            ReminderReceiver.mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {
            NotificationManagerCompat.from(context).cancel(notificationId)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}