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

        createNativeAdhanChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleNativeAdhan" -> {
                        val triggerAt = call.argument<Long>("triggerAt") ?: 0L
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        val soundName = call.argument<String>("soundName") ?: "makkah"
                        val localPath = call.argument<String>("localPath")
                        val isReminder = call.argument<Boolean>("isReminder") ?: false

                        AlarmScheduler.scheduleAdhan(
                            this,
                            triggerAt,
                            prayerName,
                            requestCode,
                            soundName,
                            localPath,
                            isReminder
                        )
                        result.success(true)
                    }

                    "cancelNativeAdhan" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelAdhan(this, requestCode)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun createNativeAdhanChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "adhan_native_channel",
                "الأذان والتنبيهات",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيهات الأذان والتنبيه قبل الصلاة"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}