package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AdhanReceiver : BroadcastReceiver() {

    companion object {
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"

        try {
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer.create(context, R.raw.menshawy)
            mediaPlayer?.isLooping = false
            mediaPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val notification = NotificationCompat.Builder(context, "adhan_native_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("حان وقت صلاة $prayerName")
            .setContentText("الصلاة خير من النوم")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(prayerName.hashCode(), notification)
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }
}