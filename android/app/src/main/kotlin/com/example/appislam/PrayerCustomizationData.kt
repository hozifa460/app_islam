package com.example.appislam

import org.json.JSONObject

data class PrayerCustomizationData(
    val time: Long,
    val muezzinSound: String,
    val muezzinLocalPath: String?,
    val reminderEnabled: Boolean,
    val reminderOffset: Int,
    val reminderSound: String,
    val reminderLocalPath: String?,
    val iqamaEnabled: Boolean,
    val iqamaDelay: Int,
    val iqamaSound: String,
    val iqamaLocalPath: String?
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("time", time)
            put("muezzinSound", muezzinSound)
            put("muezzinLocalPath", muezzinLocalPath ?: "")
            put("reminderEnabled", reminderEnabled)
            put("reminderOffset", reminderOffset)
            put("reminderSound", reminderSound)
            put("reminderLocalPath", reminderLocalPath ?: "")
            put("iqamaEnabled", iqamaEnabled)
            put("iqamaDelay", iqamaDelay)
            put("iqamaSound", iqamaSound)
            put("iqamaLocalPath", iqamaLocalPath ?: "")
        }
    }

    companion object {
        fun fromJson(json: JSONObject): PrayerCustomizationData {
            return PrayerCustomizationData(
                time = json.getLong("time"),
                muezzinSound = json.getString("muezzinSound"),
                muezzinLocalPath = json.optString("muezzinLocalPath").takeIf { it.isNotEmpty() },
                reminderEnabled = json.getBoolean("reminderEnabled"),
                reminderOffset = json.getInt("reminderOffset"),
                reminderSound = json.getString("reminderSound"),
                reminderLocalPath = json.optString("reminderLocalPath").takeIf { it.isNotEmpty() },
                iqamaEnabled = json.getBoolean("iqamaEnabled"),
                iqamaDelay = json.getInt("iqamaDelay"),
                iqamaSound = json.getString("iqamaSound"),
                iqamaLocalPath = json.optString("iqamaLocalPath").takeIf { it.isNotEmpty() }
            )
        }
    }
}

data class DayPrayerTimesWithCustomization(
    val date: String,
    val fajr: PrayerCustomizationData,
    val sunrise: PrayerCustomizationData,
    val dhuhr: PrayerCustomizationData,
    val asr: PrayerCustomizationData,
    val maghrib: PrayerCustomizationData,
    val isha: PrayerCustomizationData
)