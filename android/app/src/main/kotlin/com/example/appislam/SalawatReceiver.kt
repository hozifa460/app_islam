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

class SalawatReceiver : BroadcastReceiver() {

    companion object {
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val message = intent.getStringExtra("message")
            ?: "اللهم صل وسلم على نبينا محمد ﷺ"
        val soundName = intent.getStringExtra("soundName") ?: "saly"
        val localPath = intent.getStringExtra("localPath")
        val intervalMillis = intent.getLongExtra("intervalMillis", 1800000L)
        val requestCode = intent.getIntExtra("requestCode", 7007)

        val notificationId = 7007

        // ✅ إيقاف أي صوت سابق
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // ✅ تشغيل الصوت
        try {
            mediaPlayer = when {
                !localPath.isNullOrEmpty() && File(localPath).exists() -> {
                    MediaPlayer().apply {
                        setAudioAttributes(
                            AudioAttributes.Builder()
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                                .build()
                        )
                        setDataSource(localPath)
                        prepare()
                        isLooping = false
                        setOnCompletionListener {
                            it.release()
                            mediaPlayer = null
                        }
                        start()
                    }
                }

                else -> {
                    val soundResId =
                        context.resources.getIdentifier(soundName, "raw", context.packageName)

                    if (soundResId != 0) {
                        MediaPlayer.create(context, soundResId)?.apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                                    .build()
                            )
                            isLooping = false
                            setOnCompletionListener {
                                it.release()
                                mediaPlayer = null
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

        // ✅ إرسال الإشعار
        val stopIntent = Intent(context, StopSalawatReceiver::class.java).apply {
            putExtra("notificationId", notificationId)
        }

        val stopPendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 2000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notificationBuilder = NotificationCompat.Builder(context, "salawat_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("صلِّ على النبي ﷺ")
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "إيقاف الصوت",
                stopPendingIntent
            )

        try {
            NotificationManagerCompat.from(context)
                .notify(notificationId, notificationBuilder.build())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }

        // ✅ إعادة جدولة التنبيه التالي تلقائياً (بدل setRepeating)
        val nextTrigger = System.currentTimeMillis() + intervalMillis

        AlarmScheduler.scheduleSalawat(
            context = context,
            triggerAtMillis = nextTrigger,
            intervalMillis = intervalMillis,
            requestCode = requestCode,
            message = message,
            soundName = soundName,
            localPath = localPath
        )
    }
}