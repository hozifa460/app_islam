// services/voice_search_service.dart
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

class VoiceSearchService {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;

  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('â‌Œ ط®ط·ط£: $error'),
      onStatus: (status) => debugPrint('ًں“¢ ط§ظ„ط­ط§ظ„ط©: $status'),
    );
    return _isInitialized;
  }

  static Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningStart,
    required Function() onListeningStop,
    required Function(String error) onError,
  }) async {
    final available = await initialize();

    if (!available) {
      onError('ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ† ط؛ظٹط± ظ…طھط§ط­');
      return;
    }

    onListeningStart();

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onListeningStop();
        }
      },
      localeId: 'ar_SA',       // ط¹ط±ط¨ظٹ ط³ط¹ظˆط¯ظٹ
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      cancelOnError: true,
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;
}