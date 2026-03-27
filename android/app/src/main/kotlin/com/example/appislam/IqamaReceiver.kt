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
            PowerManager.PARTIAL_WAKE_LOCK,
            "appislam:iqamaWakeLock"
        )
        wakeLock.acquire(120 * 1000L)

        try {
            val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"
            val soundName = intent.getStringExtra("soundName") ?: "iqama1"
            val localPath = intent.getStringExtra("localPath")
            val requestCode = intent.getIntExtra("requestCode", 0)
            val triggerAtMillis = intent.getLongExtra("triggerAt", 0L)

            Log.d(TAG, "Prayer: $prayerName | Sound: $soundName | LocalPath: $localPath")

            val notificationId = ("iqama_$prayerName").hashCode()

            // إيقاف أي صوت إقامة سابق
            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // تشغيل صوت الإقامة
            try {
                mediaPlayer = when {
                    !localPath.isNullOrEmpty() && File(localPath).exists() -> {
                        Log.d(TAG, "Playing from local path: $localPath")
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
                            }
                            start()
                        }
                    }

                    else -> {
                        val soundResId =
                            context.resources.getIdentifier(soundName, "raw", context.packageName)
                        Log.d(TAG, "Trying raw resource: $soundName (resId=$soundResId)")

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
                                }
                                start()
                            }
                        } else {
                            Log.e(TAG, "No sound found for: $soundName")
                            null
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error playing iqama sound", e)
            }

            // زر إيقاف الصوت
            val stopIntent = Intent(context, StopIqamaReceiver::class.java).apply {
                putExtra("notificationId", notificationId)
            }

            val stopPendingIntent = PendingIntent.getBroadcast(
                context,
                notificationId + 4000,
                stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notificationBuilder =
                NotificationCompat.Builder(context, "iqama_channel")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle("إقامة صلاة $prayerName")
                    .setContentText("قد قامت الصلاة.. قد قامت الصلاة")
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setOngoing(true)
                    .setAutoCancel(false)
                    .addAction(
                        android.R.drawable.ic_media_pause,
                        "إيقاف الإقامة",
                        stopPendingIntent
                    )

            try {
                NotificationManagerCompat.from(context)
                    .notify(notificationId, notificationBuilder.build())
                Log.d(TAG, "Iqama notification shown successfully")
            } catch (e: SecurityException) {
                Log.e(TAG, "Notification permission denied", e)
            }

            // إعادة جدولة لليوم التالي
            if (triggerAtMillis > 0 && requestCode > 0) {
                val nextTrigger = triggerAtMillis + (24 * 60 * 60 * 1000L)
                Log.d(TAG, "Rescheduling iqama for next day at: $nextTrigger")

                AlarmScheduler.scheduleIqama(
                    context = context,
                    triggerAtMillis = nextTrigger,
                    prayerName = prayerName,
                    requestCode = requestCode,
                    soundName = soundName,
                    localPath = localPath
                )
            }

        } finally {
            if (wakeLock.isHeld) {
                wakeLock.release()
            }
        }
    }
}