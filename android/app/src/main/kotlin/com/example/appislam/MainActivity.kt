package com.example.appislam

import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "adhan_native_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNativeAdhanChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNativeAdhan" -> {
                    val triggerAt = call.argument<Long>("triggerAt") ?: 0L
                    val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                    val requestCode = call.argument<Int>("requestCode") ?: 999
                    val soundName = call.argument<String>("soundName") ?: "makkah"
                    val localPath = call.argument<String>("localPath")

                    AlarmScheduler.scheduleAdhan(
                        this,
                        triggerAt,
                        prayerName,
                        requestCode,
                        soundName,
                        localPath
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
            val channel = android.app.NotificationChannel(
                "adhan_native_channel",
                "الأذان",
                android.app.NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيهات الأذان الأصلية"
            }

            val manager = getSystemService(android.app.NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}