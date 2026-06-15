package com.example.appislam

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

object PrayerTimesScheduleStorage {

    private const val TAG = "PrayerScheduleStorage"
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_SCHEDULE = "flutter.prayer_schedule_60days_v2"
    private const val KEY_LAST_UPDATE = "flutter.prayer_schedule_last_update"

    fun saveSchedule(context: Context, schedule: List<DayPrayerTimesWithCustomization>) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val jsonArray = JSONArray()
        schedule.forEach { day ->
            val dayObject = JSONObject().apply {
                put("date", day.date)
                put("fajr", day.fajr.toJson())
                put("sunrise", day.sunrise.toJson())
                put("dhuhr", day.dhuhr.toJson())
                put("asr", day.asr.toJson())
                put("maghrib", day.maghrib.toJson())
                put("isha", day.isha.toJson())
            }
            jsonArray.put(dayObject)
        }

        prefs.edit()
            .putString(KEY_SCHEDULE, jsonArray.toString())
            .putLong(KEY_LAST_UPDATE, System.currentTimeMillis())
            .apply()

        Log.d(TAG, "Saved ${schedule.size} days to storage")
    }

    fun loadSchedule(context: Context): List<DayPrayerTimesWithCustomization> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_SCHEDULE, null) ?: return emptyList()

        val result = mutableListOf<DayPrayerTimesWithCustomization>()
        try {
            val jsonArray = JSONArray(json)
            for (i in 0 until jsonArray.length()) {
                val dayObject = jsonArray.getJSONObject(i)
                result.add(
                    DayPrayerTimesWithCustomization(
                        date = dayObject.getString("date"),
                        fajr = PrayerCustomizationData.fromJson(dayObject.getJSONObject("fajr")),
                        sunrise = PrayerCustomizationData.fromJson(dayObject.getJSONObject("sunrise")),
                        dhuhr = PrayerCustomizationData.fromJson(dayObject.getJSONObject("dhuhr")),
                        asr = PrayerCustomizationData.fromJson(dayObject.getJSONObject("asr")),
                        maghrib = PrayerCustomizationData.fromJson(dayObject.getJSONObject("maghrib")),
                        isha = PrayerCustomizationData.fromJson(dayObject.getJSONObject("isha"))
                    )
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading schedule", e)
        }

        return result
    }

    fun getLastUpdateTime(context: Context): Long {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getLong(KEY_LAST_UPDATE, 0L)
    }

    fun needsUpdate(context: Context): Boolean {
        val lastUpdate = getLastUpdateTime(context)
        if (lastUpdate == 0L) return true

        val daysSinceUpdate = (System.currentTimeMillis() - lastUpdate) / (24 * 60 * 60 * 1000)
        if (daysSinceUpdate >= 5) return true

        val schedule = loadSchedule(context)
        if (schedule.isEmpty()) return true

        val now = System.currentTimeMillis()
        val futureDays = schedule.count { it.fajr.time > now }
        if (futureDays < 5) return true

        return false
    }
}