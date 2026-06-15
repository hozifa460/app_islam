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

class AdhanReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AdhanReceiver"
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive triggered!")

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "appislam:adhanWakeLock"
        )
        wakeLock.acquire(5 * 60 * 1000L)

        try {
            val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"
            val soundName = intent.getStringExtra("soundName") ?: "makkah"
            val localPath = intent.getStringExtra("localPath")
            val isReminder = intent.getBooleanExtra("isReminder", false)

            Log.d(TAG, "Prayer: $prayerName | Sound: $soundName | Local: $localPath")

            val notificationId = if (isReminder) {
                ("reminder_$prayerName").hashCode()
            } else {
                prayerName.hashCode()
            }

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
                        Log.d(TAG, "Playing from local: $localPath")
                        MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .setUsage(if (isReminder) AudioAttributes.USAGE_NOTIFICATION else AudioAttributes.USAGE_ALARM)
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
                            Log.w(TAG, "Sound '$soundName' not found, falling back to makkah")
                            soundResId = context.resources.getIdentifier("makkah", "raw", context.packageName)
                        }

                        if (soundResId != 0) {
                            MediaPlayer.create(context, soundResId)?.apply {
                                isLooping = false
                                setAudioAttributes(
                                    AudioAttributes.Builder()
                                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                        .setUsage(if (isReminder) AudioAttributes.USAGE_NOTIFICATION else AudioAttributes.USAGE_ALARM)
                                        .build()
                                )
                                setOnCompletionListener {
                                    it.release()
                                    mediaPlayer = null
                                    NotificationManagerCompat.from(context).cancel(notificationId)
                                    if (wakeLock.isHeld) wakeLock.release()
                                }
                                start()
                            }
                        } else {
                            Log.e(TAG, "Even makkah fallback not found!")
                            null
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error playing adhan", e)
            }

            val stopIntent = Intent(context, StopAdhanReceiver::class.java).apply {
                putExtra("notificationId", notificationId)
            }
            val stopPendingIntent = PendingIntent.getBroadcast(
                context, notificationId + 5000, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val title = if (isReminder) "اقتربت صلاة $prayerName" else "حان وقت صلاة $prayerName"
            val body = if (isReminder) "متبقي دقائق قليلة على الأذان" else "حي على الصلاة"

            val builder = NotificationCompat.Builder(context, "adhan_native_channel")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setAutoCancel(!isReminder)

            if (!isReminder) {
                builder.setOngoing(true)
                    .addAction(android.R.drawable.ic_media_pause, "إيقاف الأذان", stopPendingIntent)
            }

            try {
                NotificationManagerCompat.from(context).notify(notificationId, builder.build())
            } catch (e: SecurityException) {
                Log.e(TAG, "Notification permission denied", e)
            }

        } catch (e: Exception) {
            Log.e(TAG, "Fatal error in AdhanReceiver", e)
        } finally {
            if (mediaPlayer == null && wakeLock.isHeld) wakeLock.release()
        }
    }
}