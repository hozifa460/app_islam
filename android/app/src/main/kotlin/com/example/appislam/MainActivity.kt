package com.example.appislam

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "adhan_native_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createAllNotificationChannels()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ========== الأذان ==========
                    "scheduleNativeAdhan" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "makkah"
                        val localPath = call.argument<String>("localPath")

                        AlarmScheduler.scheduleAdhan(
                            this, triggerAt, prayerName,
                            requestCode, soundName, localPath, false
                        )
                        result.success(true)
                    }

                    "cancelNativeAdhan" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelAdhan(this, requestCode)
                        result.success(true)
                    }

                    // ========== التنبيه القبلي ==========
                    "scheduleNativeReminder" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "hayalaaslah"
                        val localPath = call.argument<String>("localPath")

                        AlarmScheduler.scheduleReminder(
                            this, triggerAt, prayerName,
                            requestCode, soundName, localPath
                        )
                        result.success(true)
                    }

                    "cancelNativeReminder" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelReminder(this, requestCode)
                        result.success(true)
                    }

                    // ========== الإقامة ==========
                    "scheduleNativeIqama" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "iqama1"
                        val localPath = call.argument<String>("localPath")

                        AlarmScheduler.scheduleIqama(
                            this, triggerAt, prayerName,
                            requestCode, soundName, localPath
                        )
                        result.success(true)
                    }

                    "cancelNativeIqama" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelIqama(this, requestCode)
                        result.success(true)
                    }

                    // ========== الصلاة على النبي ==========
                    "scheduleSalawatReminder" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val intervalMillis =
                            (call.argument<Number>("intervalMillis") ?: 600000).toLong()
                        val requestCode =
                            (call.argument<Number>("requestCode") ?: 7007).toInt()
                        val message = call.argument<String>("message")
                            ?: "اللهم صل وسلم على نبينا محمد ﷺ"
                        val soundName = call.argument<String>("soundName") ?: "saly"
                        val localPath = call.argument<String>("localPath")

                        AlarmScheduler.scheduleSalawat(
                            this, triggerAt, intervalMillis,
                            requestCode, message, soundName, localPath
                        )
                        result.success(true)
                    }

                    "cancelSalawatReminder" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 7007
                        AlarmScheduler.cancelSalawat(this, requestCode)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun createAllNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            val adhanChannel = NotificationChannel(
                "adhan_native_channel",
                "الأذان",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيهات الأذان"
            }

            val reminderChannel = NotificationChannel(
                "reminder_channel",
                "التنبيه القبلي للصلاة",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيه قبل موعد الأذان بدقائق"
            }

            val iqamaChannel = NotificationChannel(
                "iqama_channel",
                "الإقامة",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيه إقامة الصلاة"
            }

            val salawatChannel = NotificationChannel(
                "salawat_channel",
                "الصلاة على النبي ﷺ",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيهات التذكير بالصلاة على النبي ﷺ"
            }

            manager.createNotificationChannel(adhanChannel)
            manager.createNotificationChannel(reminderChannel)
            manager.createNotificationChannel(iqamaChannel)
            manager.createNotificationChannel(salawatChannel)
        }
    }
}