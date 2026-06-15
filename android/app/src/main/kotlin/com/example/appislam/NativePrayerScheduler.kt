package com.example.appislam

import android.content.Context
import android.util.Log
import java.text.SimpleDateFormat
import java.util.*

object NativePrayerScheduler {

    private const val TAG = "NativePrayerScheduler"
    private const val BASE_REQUEST_CODE = 10000
    private const val MAX_SCHEDULE_DAYS = 14

    fun generateRequestCode(dayIndex: Int, prayerIndex: Int, type: Int): Int {
        return BASE_REQUEST_CODE + (type * 1000) + (dayIndex * 5) + prayerIndex
    }

    fun scheduleAll(context: Context) {
        val schedule = PrayerTimesScheduleStorage.loadSchedule(context)
        if (schedule.isEmpty()) {
            Log.w(TAG, "No prayer schedule found. Open app to generate.")
            setNeedsUpdateFlag(context)
            return
        }

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )

        val adhanEnabled = prefs.getBoolean("flutter.adhan_enabled", false)
        if (!adhanEnabled) {
            Log.d(TAG, "Adhan disabled, skipping")
            return
        }

        val now = System.currentTimeMillis()
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

        val futureDays = schedule.filter { day ->
            day.date >= today && (
                    day.fajr.time > now || day.dhuhr.time > now || day.asr.time > now ||
                            day.maghrib.time > now || day.isha.time > now
                    )
        }.take(MAX_SCHEDULE_DAYS)

        if (futureDays.isEmpty()) {
            Log.w(TAG, "No future days to schedule. Needs update!")
            setNeedsUpdateFlag(context)
            return
        }

        val todayIndex = schedule.indexOfFirst { it.date == today }
        if (todayIndex != -1) {
            val remainingDays = schedule.size - todayIndex
            if (remainingDays <= 5) {
                Log.w(TAG, "Only $remainingDays days left. Needs update!")
                setNeedsUpdateFlag(context)
            }
        }

        cancelAll(context)

        Log.d(TAG, "Scheduling ${futureDays.size} days with full customization")

        var totalScheduled = 0

        futureDays.forEachIndexed { dayIndex, day ->
            totalScheduled += scheduleDayPrayers(context, day, now, dayIndex)
        }

        prefs.edit()
            .putInt("flutter.scheduled_days_count", futureDays.size)
            .apply()

        Log.d(TAG, "All prayers scheduled: $totalScheduled alarms set")
    }

    private fun scheduleDayPrayers(
        context: Context,
        day: DayPrayerTimesWithCustomization,
        now: Long,
        dayIndex: Int
    ): Int {
        var count = 0

        // ✅ أسماء عربية للإشعارات
        val prayers = listOf(
            Triple(0, "الفجر", day.fajr),
            Triple(1, "الظهر", day.dhuhr),
            Triple(2, "العصر", day.asr),
            Triple(3, "المغرب", day.maghrib),
            Triple(4, "العشاء", day.isha)
        )

        prayers.forEach { (prayerIndex, prayerName, customization) ->
            if (customization.time <= now) return@forEach

            val adhanCode = generateRequestCode(dayIndex, prayerIndex, 0)
            val reminderCode = generateRequestCode(dayIndex, prayerIndex, 1)
            val iqamaCode = generateRequestCode(dayIndex, prayerIndex, 2)

            val adhanScheduled = AlarmScheduler.scheduleAdhan(
                context = context,
                triggerAtMillis = customization.time,
                prayerName = prayerName,
                requestCode = adhanCode,
                soundName = customization.muezzinSound,
                localPath = customization.muezzinLocalPath,
                isReminder = false
            )
            if (adhanScheduled) count++

            if (customization.reminderEnabled && customization.reminderOffset > 0) {
                val reminderTime = customization.time - (customization.reminderOffset * 60 * 1000L)
                if (reminderTime > now) {
                    if (AlarmScheduler.scheduleReminder(
                            context = context,
                            triggerAtMillis = reminderTime,
                            prayerName = prayerName,
                            requestCode = reminderCode,
                            soundName = customization.reminderSound,
                            localPath = customization.reminderLocalPath
                        )) count++
                }
            }

            if (customization.iqamaEnabled && customization.iqamaDelay > 0) {
                val iqamaTime = customization.time + (customization.iqamaDelay * 60 * 1000L)
                if (iqamaTime > now) {
                    if (AlarmScheduler.scheduleIqama(
                            context = context,
                            triggerAtMillis = iqamaTime,
                            prayerName = prayerName,
                            requestCode = iqamaCode,
                            soundName = customization.iqamaSound,
                            localPath = customization.iqamaLocalPath
                        )) count++
                }
            }
        }

        return count
    }

    fun cancelAll(context: Context) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        val daysCount = prefs.getInt("flutter.scheduled_days_count", MAX_SCHEDULE_DAYS)

        for (dayIndex in 0 until daysCount) {
            for (prayerIndex in 0 until 5) {
                for (type in 0..2) {
                    val code = generateRequestCode(dayIndex, prayerIndex, type)
                    when (type) {
                        0 -> AlarmScheduler.cancelAdhan(context, code)
                        1 -> AlarmScheduler.cancelReminder(context, code)
                        2 -> AlarmScheduler.cancelIqama(context, code)
                    }
                }
            }
        }

        val legacyIds = listOf(100, 101, 102, 103, 104)
        legacyIds.forEach { id ->
            AlarmScheduler.cancelAdhan(context, id)
            AlarmScheduler.cancelReminder(context, id + 1000)
            AlarmScheduler.cancelIqama(context, id + 2000)
        }

        Log.d(TAG, "All alarms cancelled")
    }

    private fun setNeedsUpdateFlag(context: Context) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        prefs.edit()
            .putBoolean("flutter.prayer_schedule_needs_update", true)
            .apply()
    }
}