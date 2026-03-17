package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class StopAdhanReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            AdhanReceiver.mediaPlayer?.stop()
            AdhanReceiver.mediaPlayer?.release()
            AdhanReceiver.mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val notificationId = intent.getIntExtra("notificationId", 0)
        NotificationManagerCompat.from(context).cancel(notificationId)
    }
}