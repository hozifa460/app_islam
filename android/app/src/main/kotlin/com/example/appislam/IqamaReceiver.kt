package com.example.appislam

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File

class IqamaReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "IqamaReceiver"
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive triggered!")

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "appislam:iqamaWakeLock"
        )
        wakeLock.acquire(2 * 60 * 1000L)

        try {
            val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"
            val soundName = intent.getStringExtra("soundName") ?: "iqama1"
            val localPath = intent.getStringExtra("localPath")

            Log.d(TAG, "Prayer: $prayerName | Sound: $soundName | Local: $localPath")

            val notificationId = ("iqama_$prayerName").hashCode()

            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null
            } catch (e: Exception) {
                Log.w(TAG, "Error stopping previous player", e)
            }

            try {
                mediaPlayer = when {
                    !localPath.isNullOrEmpty() && File(localPath).exists() -> {
                        MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .setUsage(AudioAttributes.USAGE_ALARM)
                                    .build()
                            )
                            setDataSource(localPath)
                            prepare()
                            isLooping = false
                            setOnCompletionListener {
                                it.release()
                                mediaPlayer = null
                                NotificationManagerCompat.from(context).cancel(notificationId)
                                if (wakeLock.isHeld) wakeLock.release()
                            }
                            start()
                        }
                    }

                    else -> {
                        var soundResId = context.resources.getIdentifier(soundName, "raw", context.packageName)

                        // ✅ Fallback إلى makkah
                        if (soundResId == 0) {
                            Log.w(TAG, "Iqama sound '$soundName' not found, falling back to makkah")
                            soundResId = context.resources.getIdentifier("makkah", "raw", context.packageName)
                        }

                        if (soundResId != 0) {
                            MediaPlayer.create(context, soundResId)?.apply {
                                setAudioAttributes(
                                    AudioAttributes.Builder()
                                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                        .setUsage(AudioAttributes.USAGE_ALARM)
                                        .build()
                                )
                                isLooping = false
                                setOnCompletionListener {
                                    it.release()
                                    mediaPlayer = null
                                    NotificationManagerCompat.from(context).cancel(notificationId)
                                    if (wakeLock.isHeld) wakeLock.release()
                                }
                                start()
                            }
                        } else null
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error playing iqama sound", e)
            }

            val stopIntent = Intent(context, StopIqamaReceiver::class.java).apply {
                putExtra("notificationId", notificationId)
            }
            val stopPendingIntent = PendingIntent.getBroadcast(
                context, notificationId + 7000, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val builder = NotificationCompat.Builder(context, "iqama_channel")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("إقامة صلاة $prayerName")
                .setContentText("قد قامت الصلاة.. قد قامت الصلاة")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setOngoing(true)
                .setAutoCancel(false)
                .addAction(android.R.drawable.ic_media_pause, "إيقاف الإقامة", stopPendingIntent)

            try {
                NotificationManagerCompat.from(context).notify(notificationId, builder.build())
            } catch (e: SecurityException) {
                Log.e(TAG, "Notification permission denied", e)
            }

        } catch (e: Exception) {
            Log.e(TAG, "Fatal error in IqamaReceiver", e)
        } finally {
            if (mediaPlayer == null && wakeLock.isHeld) wakeLock.release()
        }
    }
}