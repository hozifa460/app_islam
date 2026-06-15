package com.example.appislam

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "adhan_native_bridge"
    private var speechPlugin: NativeSpeechPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val speechChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, "native_speech"
        )
        speechPlugin = NativeSpeechPlugin(this, speechChannel)

        createAllNotificationChannels()
        DailyRescheduleManager.scheduleDailyReschedule(this)
        NativePrayerScheduler.scheduleAll(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "savePrayerSchedule" -> {
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val scheduleList = call.argument<List<Map<String, Any>>>("schedule")

                            if (scheduleList != null) {
                                val schedule = scheduleList.map { dayMap ->
                                    @Suppress("UNCHECKED_CAST")
                                    DayPrayerTimesWithCustomization(
                                        date = dayMap["date"] as String,
                                        fajr = parsePrayerCustomization(dayMap["fajr"] as Map<String, Any>),
                                        sunrise = parsePrayerCustomization(dayMap["sunrise"] as Map<String, Any>),
                                        dhuhr = parsePrayerCustomization(dayMap["dhuhr"] as Map<String, Any>),
                                        asr = parsePrayerCustomization(dayMap["asr"] as Map<String, Any>),
                                        maghrib = parsePrayerCustomization(dayMap["maghrib"] as Map<String, Any>),
                                        isha = parsePrayerCustomization(dayMap["isha"] as Map<String, Any>)
                                    )
                                }
                                PrayerTimesScheduleStorage.saveSchedule(this, schedule)
                                NativePrayerScheduler.scheduleAll(this)
                                result.success(true)
                            } else {
                                result.error("INVALID_SCHEDULE", "Schedule is null", null)
                            }
                        } catch (e: Exception) {
                            result.error("PARSE_ERROR", e.message, e.stackTraceToString())
                        }
                    }

                    "cancelAllAlarms" -> {
                        NativePrayerScheduler.cancelAll(this)
                        result.success(true)
                    }

                    "scheduleNativeAdhan" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "makkah"
                        val localPath = call.argument<String>("localPath")
                        val success = AlarmScheduler.scheduleAdhan(
                            this, triggerAt, prayerName, requestCode, soundName, localPath, false
                        )
                        result.success(success)
                    }

                    "cancelNativeAdhan" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelAdhan(this, requestCode)
                        result.success(true)
                    }

                    "scheduleNativeReminder" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "hayalaaslah"
                        val localPath = call.argument<String>("localPath")
                        val success = AlarmScheduler.scheduleReminder(
                            this, triggerAt, prayerName, requestCode, soundName, localPath
                        )
                        result.success(success)
                    }

                    "cancelNativeReminder" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelReminder(this, requestCode)
                        result.success(true)
                    }

                    "scheduleNativeIqama" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                        val requestCode = (call.argument<Number>("requestCode") ?: 999).toInt()
                        val soundName = call.argument<String>("soundName") ?: "iqama1"
                        val localPath = call.argument<String>("localPath")
                        val success = AlarmScheduler.scheduleIqama(
                            this, triggerAt, prayerName, requestCode, soundName, localPath
                        )
                        result.success(success)
                    }

                    "cancelNativeIqama" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 999
                        AlarmScheduler.cancelIqama(this, requestCode)
                        result.success(true)
                    }

                    "scheduleSalawatReminder" -> {
                        val triggerAt = (call.argument<Number>("triggerAt") ?: 0).toLong()
                        val intervalMillis = (call.argument<Number>("intervalMillis") ?: 600000).toLong()
                        val requestCode = (call.argument<Number>("requestCode") ?: 7007).toInt()
                        val message = call.argument<String>("message") ?: "اللهم صل وسلم على نبينا محمد ﷺ"
                        val soundName = call.argument<String>("soundName") ?: "saly"
                        val localPath = call.argument<String>("localPath")
                        AlarmScheduler.scheduleSalawat(
                            this, triggerAt, intervalMillis, requestCode, message, soundName, localPath
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (speechPlugin?.handleActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        speechPlugin?.dispose()
        super.onDestroy()
    }

    private fun parsePrayerCustomization(map: Map<String, Any>): PrayerCustomizationData {
        return PrayerCustomizationData(
            time = (map["time"] as Number).toLong(),
            muezzinSound = map["muezzinSound"] as? String ?: "makkah",
            muezzinLocalPath = map["muezzinLocalPath"] as? String,
            reminderEnabled = map["reminderEnabled"] as? Boolean ?: false,
            reminderOffset = (map["reminderOffset"] as? Number)?.toInt() ?: 10,
            reminderSound = map["reminderSound"] as? String ?: "hayalaaslah",
            reminderLocalPath = map["reminderLocalPath"] as? String,
            iqamaEnabled = map["iqamaEnabled"] as? Boolean ?: false,
            iqamaDelay = (map["iqamaDelay"] as? Number)?.toInt() ?: 10,
            iqamaSound = map["iqamaSound"] as? String ?: "iqama1",
            iqamaLocalPath = map["iqamaLocalPath"] as? String
        )
    }

    private fun createAllNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            val channels = listOf(
                NotificationChannel("adhan_native_channel", "الأذان", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "تنبيهات الأذان"
                    setBypassDnd(true)
                    lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                },
                NotificationChannel("reminder_channel", "التنبيه القبلي للصلاة", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "تنبيه قبل موعد الأذان بدقائق"
                    lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                },
                NotificationChannel("iqama_channel", "الإقامة", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "تنبيه إقامة الصلاة"
                    lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                },
                NotificationChannel("salawat_channel", "الصلاة على النبي ﷺ", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "تنبيهات التذكير بالصلاة على النبي ﷺ"
                }
            )

            channels.forEach { manager.createNotificationChannel(it) }
        }
    }
}