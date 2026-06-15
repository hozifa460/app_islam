package com.example.appislam

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile

class NativeSpeechPlugin(
    private val activity: Activity,
    private val channel: MethodChannel
) : MethodChannel.MethodCallHandler {

    private val TAG = "NativeSpeech"
    private val mainHandler = Handler(Looper.getMainLooper())

    // تسجيل الصوت
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var recordingThread: Thread? = null
    private var recordingFile: File? = null
    private var recordingSeconds = 0

    // Intent fallback
    private var intentLaunched = false

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val available = true // التسجيل متاح دائماً

                if (ContextCompat.checkSelfPermission(
                        activity, Manifest.permission.RECORD_AUDIO
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(Manifest.permission.RECORD_AUDIO),
                        100
                    )
                }

                result.success(available)
            }

            "startRecording" -> {
                startRecording()
                result.success(null)
            }

            "stopRecording" -> {
                val path = stopRecording()
                result.success(path)
            }

            "cancelRecording" -> {
                cancelRecording()
                result.success(null)
            }

            "startListening" -> {
                val locale = call.argument<String>("locale") ?: "ar-SA"
                startWithIntent(locale)
                result.success(null)
            }

            "stopListening" -> {
                cancelRecording()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    // ═══════════════════════════════════════
    // تسجيل الصوت مباشرة (بدون واجهة!)
    // ═══════════════════════════════════════

    private fun startRecording() {
        if (isRecording) return

        if (ContextCompat.checkSelfPermission(
                activity, Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            mainHandler.post {
                channel.invokeMethod("onError", "يجب منح إذن الميكروفون")
            }
            return
        }

        try {
            val sampleRate = 16000
            val channelConfig = AudioFormat.CHANNEL_IN_MONO
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT
            val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize * 2
            )

            // إنشاء ملف مؤقت
            recordingFile = File(activity.cacheDir, "recitation_${System.currentTimeMillis()}.wav")

            isRecording = true
            recordingSeconds = 0
            audioRecord?.startRecording()

            Log.d(TAG, "🎤 بدأ التسجيل: ${recordingFile?.absolutePath}")

            mainHandler.post {
                channel.invokeMethod("onListeningStarted", null)
            }

            // مؤقت الثواني
            val timerRunnable = object : Runnable {
                override fun run() {
                    if (isRecording) {
                        recordingSeconds++
                        mainHandler.post {
                            channel.invokeMethod("onRecordingTime", recordingSeconds)
                        }
                        mainHandler.postDelayed(this, 1000)
                    }
                }
            }
            mainHandler.postDelayed(timerRunnable, 1000)

            // كتابة البيانات في Thread منفصل
            recordingThread = Thread {
                writeWavFile(bufferSize)
            }
            recordingThread?.start()

        } catch (e: Exception) {
            Log.e(TAG, "❌ خطأ التسجيل: ${e.message}")
            isRecording = false
            mainHandler.post {
                channel.invokeMethod("onError", "فشل بدء التسجيل: ${e.message}")
            }
        }
    }

    private fun writeWavFile(bufferSize: Int) {
        try {
            val file = recordingFile ?: return
            val fos = FileOutputStream(file)

            // كتابة WAV header مؤقت (سيتم تحديثه لاحقاً)
            val header = ByteArray(44)
            fos.write(header)

            val buffer = ByteArray(bufferSize)
            var totalBytes = 0L

            while (isRecording) {
                val read = audioRecord?.read(buffer, 0, bufferSize) ?: -1
                if (read > 0) {
                    fos.write(buffer, 0, read)
                    totalBytes += read
                }
            }

            fos.close()

            // تحديث WAV header بالحجم الصحيح
            updateWavHeader(file, totalBytes)

            Log.d(TAG, "✅ تم حفظ التسجيل: ${totalBytes / 1024} KB")

        } catch (e: Exception) {
            Log.e(TAG, "❌ خطأ الكتابة: ${e.message}")
        }
    }

    private fun updateWavHeader(file: File, dataSize: Long) {
        try {
            val raf = RandomAccessFile(file, "rw")
            val sampleRate = 16000
            val channels = 1
            val bitsPerSample = 16
            val byteRate = sampleRate * channels * bitsPerSample / 8
            val blockAlign = channels * bitsPerSample / 8
            val totalSize = dataSize + 36

            raf.seek(0)
            // RIFF header
            raf.writeBytes("RIFF")
            raf.write(intToByteArray(totalSize.toInt()))
            raf.writeBytes("WAVE")
            // fmt chunk
            raf.writeBytes("fmt ")
            raf.write(intToByteArray(16)) // chunk size
            raf.write(shortToByteArray(1)) // PCM
            raf.write(shortToByteArray(channels))
            raf.write(intToByteArray(sampleRate))
            raf.write(intToByteArray(byteRate))
            raf.write(shortToByteArray(blockAlign))
            raf.write(shortToByteArray(bitsPerSample))
            // data chunk
            raf.writeBytes("data")
            raf.write(intToByteArray(dataSize.toInt()))

            raf.close()
        } catch (e: Exception) {
            Log.e(TAG, "❌ خطأ WAV header: ${e.message}")
        }
    }

    private fun stopRecording(): String? {
        if (!isRecording) return null

        isRecording = false

        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
            recordingThread?.join(2000)
            recordingThread = null

            Log.d(TAG, "⏹️ توقف التسجيل")

            mainHandler.post {
                channel.invokeMethod("onListeningStopped", null)
            }

            return recordingFile?.absolutePath

        } catch (e: Exception) {
            Log.e(TAG, "❌ خطأ الإيقاف: ${e.message}")
            return null
        }
    }

    private fun cancelRecording() {
        isRecording = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
            recordingThread?.join(1000)
            recordingThread = null
            recordingFile?.delete()
            recordingFile = null
        } catch (_: Exception) {}

        mainHandler.post {
            channel.invokeMethod("onListeningStopped", null)
        }
    }

    // ═══════════════════════════════════════
    // Intent كبديل
    // ═══════════════════════════════════════

    private fun startWithIntent(locale: String) {
        if (intentLaunched) return
        intentLaunched = true

        try {
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                putExtra(RecognizerIntent.EXTRA_PROMPT, "اقرأ...")
            }
            activity.startActivityForResult(intent, SPEECH_REQUEST_CODE)
        } catch (e: Exception) {
            intentLaunched = false
            channel.invokeMethod("onError", "تعذر فتح خدمة الكلام")
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != SPEECH_REQUEST_CODE) return false
        intentLaunched = false

        if (resultCode == Activity.RESULT_OK && data != null) {
            val matches = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            val text = matches?.firstOrNull() ?: ""
            if (text.isNotEmpty()) {
                channel.invokeMethod("onResult", text)
            }
        }
        channel.invokeMethod("onListeningStopped", null)
        return true
    }

    // ═══════════════════════════════════════
    // أدوات مساعدة
    // ═══════════════════════════════════════

    private fun intToByteArray(value: Int): ByteArray {
        return byteArrayOf(
            (value and 0xFF).toByte(),
            ((value shr 8) and 0xFF).toByte(),
            ((value shr 16) and 0xFF).toByte(),
            ((value shr 24) and 0xFF).toByte()
        )
    }

    private fun shortToByteArray(value: Int): ByteArray {
        return byteArrayOf(
            (value and 0xFF).toByte(),
            ((value shr 8) and 0xFF).toByte()
        )
    }

    fun dispose() {
        cancelRecording()
    }

    companion object {
        const val SPEECH_REQUEST_CODE = 9999
    }
}