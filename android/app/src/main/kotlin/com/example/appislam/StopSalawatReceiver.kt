package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class StopSalawatReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notificationId", 7007)

        try {
            SalawatReceiver.mediaPlayer?.stop()
            SalawatReceiver.mediaPlayer?.release()
            SalawatReceiver.mediaPlayer = null
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