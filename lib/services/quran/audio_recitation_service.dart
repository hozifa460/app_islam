import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'quran_text_service.dart';

enum RecitationState { idle, recording, processing, correct, incorrect, listening }

class WordMatch {
  final String expectedWord;
  final String? spokenWord;
  final bool isCorrect;
  final bool isRevealed;

  WordMatch({
    required this.expectedWord,
    this.spokenWord,
    required this.isCorrect,
    this.isRevealed = false,
  });
}

class RecitationResult {
  final String spokenText;
  final String expectedText;
  final double accuracy;
  final bool isCorrect;
  final List<String> incorrectWords;
  final List<WordMatch> wordMatches;

  RecitationResult({
    required this.spokenText,
    required this.expectedText,
    required this.accuracy,
    required this.isCorrect,
    this.incorrectWords = const [],
    this.wordMatches = const [],
  });
}

class RecitationService {
  static const _channel = MethodChannel('native_speech');

  bool _isInitialized = false;
  RecitationState _state = RecitationState.idle;
  int _recordingSeconds = 0;

  String _spokenText = '';
  String? _expectedText;
  List<String> _expectedWords = [];
  int _revealedCount = 0;
  List<WordMatch> _wordMatches = [];

  // ✅ Wit.ai Token — ضع المفتاح في --dart-define=WIT_AI_TOKEN=...
  static const String _witAiToken = String.fromEnvironment(
    'WIT_AI_TOKEN',
    defaultValue: '',
  );

  // Callbacks
  Function(RecitationState)? onStateChanged;
  Function(String text)? onPartialResult;
  Function(RecitationResult)? onResult;
  Function(String error)? onError;
  Function(int count, List<WordMatch> matches)? onWordRevealed;
  Function(int seconds)? onRecordingTime;

  RecitationState get state => _state;
  String get spokenText => _spokenText;
  int get revealedWordCount => _revealedCount;
  List<WordMatch> get wordMatches => List.unmodifiable(_wordMatches);
  bool get isArabicAvailable => true;
  String? get arabicLocale => 'ar';
  int get recordingSeconds => _recordingSeconds;

  Future<bool> initialize({
    Function(double progress, String message)? onProgress,
  }) async {
    if (_isInitialized) return true;

    try {
      PermissionStatus status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }
      if (!status.isGranted) {
        onError?.call('يجب منح إذن الميكروفون');
        return false;
      }

      _channel.setMethodCallHandler(_handleNativeCall);
      await _channel.invokeMethod('initialize');

      _isInitialized = true;
      debugPrint('🎤 ✅ جاهز');
      return true;
    } catch (e) {
      debugPrint('🎤 ❌ $e');
      onError?.call('فشل تهيئة خدمة التسميع');
      return false;
    }
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onListeningStarted':
        debugPrint('🎤 ✅ بدأ التسجيل');
        _setState(RecitationState.recording);
        break;

      case 'onListeningStopped':
        debugPrint('🎤 توقف');
        break;

      case 'onRecordingTime':
        _recordingSeconds = call.arguments as int? ?? 0;
        onRecordingTime?.call(_recordingSeconds);
        break;

      case 'onResult':
        final text = call.arguments as String? ?? '';
        if (text.isNotEmpty) {
          _spokenText = text;
          onPartialResult?.call(text);
          _updateMatches();
          _finishListening();
        }
        break;

      case 'onError':
        final error = call.arguments as String? ?? '';
        debugPrint('🎤 خطأ: $error');
        _setState(RecitationState.idle);
        onError?.call(error);
        break;
    }
  }

  void resetInit() {
    _isInitialized = false;
  }

  Future<void> startForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final text = QuranTextService.getAyahText(surahNumber, ayahNumber);
    if (text == null) {
      onError?.call('لم يتم تحميل نص الآية بعد');
      return;
    }
    await _startRecording(text);
  }

  Future<void> startForPage({required int page}) async {
    final ayahs = QuranTextService.getPageAyahs(page);
    if (ayahs.isEmpty) {
      onError?.call('لم يتم تحميل نص الصفحة بعد');
      return;
    }
    final fullText = ayahs.map((a) => a['text'] as String).join(' ');
    await _startRecording(fullText);
  }

  Future<void> _startRecording(String expectedText) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    _expectedText = expectedText;
    _expectedWords = _clean(expectedText).split(RegExp(r'\s+'));
    _expectedWords.removeWhere((w) => w.isEmpty);

    if (_expectedWords.isEmpty) {
      onError?.call('لا يوجد نص للمقارنة');
      return;
    }

    _revealedCount = 0;
    _spokenText = '';
    _recordingSeconds = 0;

    _wordMatches = _expectedWords
        .map((w) => WordMatch(expectedWord: w, isCorrect: false, isRevealed: false))
        .toList();

    onWordRevealed?.call(0, List.from(_wordMatches));

    try {
      await _channel.invokeMethod('startRecording');
    } catch (e) {
      debugPrint('🎤 ❌ $e');
      onError?.call('فشل بدء التسجيل');
    }
  }

  Future<void> stop() async {
    if (_state != RecitationState.recording) return;

    try {
      final path = await _channel.invokeMethod<String>('stopRecording');

      if (path == null || !File(path).existsSync()) {
        _setState(RecitationState.idle);
        onError?.call('فشل حفظ التسجيل');
        return;
      }

      _setState(RecitationState.processing);
      onPartialResult?.call('��اري تحليل التلاوة...');

      final text = await _sendToWitAi(path);

      try { File(path).deleteSync(); } catch (_) {}

      if (text == null || text.isEmpty) {
        _setState(RecitationState.idle);
        onError?.call('فشل تحليل الصوت، حاول مرة أخرى');
        return;
      }

      _spokenText = text;
      onPartialResult?.call(_spokenText);
      _updateMatches();
      _finishListening();
    } catch (e) {
      debugPrint('🎤 ❌ $e');
      _setState(RecitationState.idle);
      onError?.call('حدث خطأ');
    }
  }

  Future<String?> _sendToWitAi(String audioPath) async {
    try {
      final file = File(audioPath);
      final bytes = await file.readAsBytes();

      debugPrint('🎤 إرسال ${bytes.length ~/ 1024} KB لـ Wit.ai');

      final request = http.Request(
        'POST',
        Uri.parse('https://api.wit.ai/speech?v=20240101'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_witAiToken',
        'Content-Type': 'audio/wav',
        'Transfer-Encoding': 'chunked',
      });

      request.bodyBytes = bytes;

      final streamedResponse = await http.Client().send(request)
          .timeout(const Duration(seconds: 30));

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🎤 Wit.ai status: ${response.statusCode}');
      debugPrint('🎤 Wit.ai body: ${response.body}');

      if (response.statusCode == 200) {
        // Wit.ai قد يرجع عدة JSON objects
        // نأخذ آخر واحد فيه text
        final lines = response.body.trim().split('\n');
        String resultText = '';

        for (final line in lines) {
          try {
            final data = jsonDecode(line.trim());
            if (data['text'] != null && data['text'].toString().isNotEmpty) {
              resultText = data['text'].toString();
            }
          } catch (_) {
            // تجاهل الأسطر غير JSON
          }
        }

        if (resultText.isNotEmpty) {
          debugPrint('🎤 ✅ نص: $resultText');
          return resultText;
        }

        // محاولة ثانية: JSON عادي
        try {
          final data = jsonDecode(response.body);
          return (data['text'] ?? '').toString().trim();
        } catch (_) {}

        return '';
      } else {
        debugPrint('🎤 ❌ Wit.ai error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('🎤 ❌ API error: $e');
      return null;
    }
  }

  Future<void> cancel() async {
    try {
      await _channel.invokeMethod('cancelRecording');
    } catch (_) {}
    _setState(RecitationState.idle);
    _spokenText = '';
    _revealedCount = 0;
    _recordingSeconds = 0;
  }

  void _updateMatches() {
    if (_expectedWords.isEmpty) return;
    final spokenWords = _clean(_spokenText).split(RegExp(r'\s+'));
    spokenWords.removeWhere((w) => w.isEmpty);

    List<WordMatch> newMatches = [];
    for (int i = 0; i < _expectedWords.length; i++) {
      if (i < spokenWords.length) {
        final isMatch = _fuzzyMatch(spokenWords[i], _expectedWords[i]);
        newMatches.add(WordMatch(
          expectedWord: _expectedWords[i],
          spokenWord: spokenWords[i],
          isCorrect: isMatch,
          isRevealed: true,
        ));
      } else {
        newMatches.add(WordMatch(expectedWord: _expectedWords[i], isCorrect: false, isRevealed: false));
      }
    }
    _wordMatches = newMatches;
    _revealedCount = spokenWords.length.clamp(0, _expectedWords.length);
    onWordRevealed?.call(_revealedCount, List.from(_wordMatches));
  }

  void _finishListening() {
    if (_expectedText == null) return;
    _updateMatches();

    int correct = _wordMatches.where((m) => m.isCorrect).length;
    int total = _expectedWords.length;
    double accuracy = total > 0 ? correct / total : 0;

    List<String> wrong = _wordMatches
        .where((m) => m.isRevealed && !m.isCorrect)
        .map((m) => m.expectedWord)
        .toList();

    final result = RecitationResult(
      spokenText: _spokenText,
      expectedText: _expectedText!,
      accuracy: accuracy,
      isCorrect: accuracy >= 0.60,
      incorrectWords: wrong,
      wordMatches: List.from(_wordMatches),
    );

    _setState(result.isCorrect ? RecitationState.correct : RecitationState.incorrect);
    onResult?.call(result);
  }

  bool _fuzzyMatch(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    if (na == nb) return true;
    if (na.isEmpty || nb.isEmpty) return false;
    if (na.contains(nb) || nb.contains(na)) return true;
    int matches = 0;
    int maxLen = na.length > nb.length ? na.length : nb.length;
    int minLen = na.length < nb.length ? na.length : nb.length;
    for (int i = 0; i < minLen; i++) {
      if (na[i] == nb[i]) matches++;
    }
    return maxLen > 0 && matches / maxLen >= 0.55;
  }

  String _clean(String t) => t
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll(RegExp(r'[۞۩﴿﴾⟨⟩ۖۗۘۙۚۛۜ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _normalize(String t) => _clean(t)
      .replaceAll('ٱ', 'ا').replaceAll('إ', 'ا')
      .replaceAll('أ', 'ا').replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي').replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');

  void _setState(RecitationState s) {
    _state = s;
    onStateChanged?.call(s);
  }

  void dispose() {
    cancel();
  }
}