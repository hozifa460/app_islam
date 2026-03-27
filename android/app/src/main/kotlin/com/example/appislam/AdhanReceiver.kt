package com.example.appislam

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
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
        val isReminder = intent.getBooleanExtra("isReminder", false)

        val notificationId = if (isReminder) {
            ("reminder_$prayerName").hashCode()
        } else {
            prayerName.hashCode()
        }

        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null

            mediaPlayer = when {
                !localPath.isNullOrEmpty() && File(localPath).exists() -> {
                    MediaPlayer().apply {
                        setDataSource(localPath)
                        setAudioAttributes(
                            AudioAttributes.Builder()
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .setUsage(
                                    if (isReminder) {
                                        AudioAttributes.USAGE_NOTIFICATION
                                    } else {
                                        AudioAttributes.USAGE_ALARM
                                    }
                                )
                                .build()
                        )
                        prepare()
                        isLooping = false
                        setOnCompletionListener {
                            it.release()
                            mediaPlayer = null
                            NotificationManagerCompat.from(context).cancel(notificationId)
                        }
                        start()
                    }
                }

                else -> {
                    val soundResId =
                        context.resources.getIdentifier(soundName, "raw", context.packageName)

                    if (soundResId != 0) {
                        MediaPlayer.create(context, soundResId)?.apply {
                            isLooping = false
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .setUsage(
                                        if (isReminder) {
                                            AudioAttributes.USAGE_NOTIFICATION
                                        } else {
                                            AudioAttributes.USAGE_ALARM
                                        }
                                    )
                                    .build()
                            )
                            setOnCompletionListener {
                                it.release()
                                mediaPlayer = null
                                NotificationManagerCompat.from(context).cancel(notificationId)
                            }
                            start()
                        }
                    } else {
                        null
                    }
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }

        val stopIntent = Intent(context, StopAdhanReceiver::class.java).apply {
            putExtra("notificationId", notificationId)
        }

        val stopPendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 1000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val title = if (isReminder) {
            "اقتربت صلاة $prayerName"
        } else {
            "حان وقت صلاة $prayerName"
        }

        val body = if (isReminder) {
            "متبقي دقائق قليلة على الأذان"
        } else {
            "حي على الصلاة"
        }

        val notificationBuilder = NotificationCompat.Builder(context, "adhan_native_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(!isReminder)

        if (!isReminder) {
            notificationBuilder
                .setOngoing(true)
                .addAction(
                    android.R.drawable.ic_media_pause,
                    "إيقاف الأذان",
                    stopPendingIntent
                )
        }

        try {
            NotificationManagerCompat.from(context)
                .notify(notificationId, notificationBuilder.build())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }
}