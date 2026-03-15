package com.example.appislam

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File

class AdhanReceiver : BroadcastReceiver() {

    companion object {
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"
        val soundName = intent.getStringExtra("soundName") ?: "makkah"
        val localPath = intent.getStringExtra("localPath")

        try {
            mediaPlayer?.release()

            // ✅ إذا كان هناك ملف محلي محمّل استخدمه
            if (!localPath.isNullOrEmpty() && File(localPath).exists()) {
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(localPath)
                    prepare()
                    isLooping = false
                    start()
                }
            } else {
                // ✅ وإلا استخدم الملف الافتراضي من raw
                val soundResId = context.resources.getIdentifier(soundName, "raw", context.packageName)
                if (soundResId != 0) {
                    mediaPlayer = MediaPlayer.create(context, soundResId)
                    mediaPlayer?.isLooping = false
                    mediaPlayer?.start()
                }
            }
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