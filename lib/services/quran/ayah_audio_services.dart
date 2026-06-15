// lib/services/ayah_audio_service.dart

import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'quran_text_service.dart';

class AyahAudioService {
  final AudioPlayer _player;
  String reciterId;

  // الحالة
  int _currentSurah = 0;
  int _currentAyah = 0;
  bool _isSequencePlaying = false;
  bool _isPaused = false;

  // Callbacks
  Function(int surah, int ayah)? onAyahStarted;
  Function()? onSequenceComplete;
  Function(bool isPlaying)? onPlayStateChanged;

  AyahAudioService({
    required AudioPlayer player,
    this.reciterId = 'ar.alafasy',
  }) : _player = player;

  int get currentAyah => _currentAyah;
  int get currentSurah => _currentSurah;
  bool get isPlaying => _isSequencePlaying && !_isPaused;
  bool get isPaused => _isPaused;

  /// ─── بناء رابط الصوت لآية ───
  String _ayahUrl(int globalNumber) {
    final paddedNum = globalNumber.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/$reciterId/$paddedNum.mp3';
  }

  /// ─── تشغيل آية واحدة ───
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;

      final global = QuranTextService.getGlobalAyahNumber(
          surahNumber, ayahNumber);

      await _player.setUrl(_ayahUrl(global));
      onAyahStarted?.call(surahNumber, ayahNumber);
      onPlayStateChanged?.call(true);
      await _player.play();

      // ✅ في playAyah:
      await _player.playerStateStream
          .firstWhere(
            (s) => s.processingState == ProcessingState.completed,
      )
          .timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          debugPrint('⏰ timeout في playAyah');
          return _player.playerState;
        },
      );

      onPlayStateChanged?.call(false);
    } catch (e) {
      debugPrint('playAyah error: $e');
      onPlayStateChanged?.call(false);
    }
  }

  // ✅ المصلح في ayah_audio_service.dart:
  Future<void> playPage({
    required int page,
    int startFromAyahIndex = 0,
  }) async {
    final ayahs = QuranTextService.getPageAyahs(page);
    if (ayahs.isEmpty) return;

    _isSequencePlaying = true;
    _isPaused = false;

    for (int i = startFromAyahIndex; i < ayahs.length; i++) {
      if (!_isSequencePlaying) break;

      while (_isPaused) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isSequencePlaying) return;
      }

      final ayah = ayahs[i];
      final surahNum = ayah['surahNumber'] as int;
      final ayahNum = ayah['numberInSurah'] as int;

      // ✅ استخدام الدالة بدلاً من القيمة المخزنة
      final globalNum = ayah['number'] as int? ??
          QuranTextService.getGlobalAyahNumber(surahNum, ayahNum);

      _currentSurah = surahNum;
      _currentAyah = ayahNum;

      onAyahStarted?.call(surahNum, ayahNum);
      onPlayStateChanged?.call(true);

      try {
        await _player.setUrl(_ayahUrl(globalNum));
        await _player.play();

        // ✅ وأيضاً في playPage داخل الحلقة:
        await _player.playerStateStream
            .firstWhere(
              (s) => s.processingState == ProcessingState.completed,
        )
            .timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            debugPrint('⏰ timeout في playPage');
            return _player.playerState;
          },
        );

      } catch (e) {
        debugPrint('playPage ayah $globalNum error: $e');
        break;
      }
    }


    _isSequencePlaying = false;
    onPlayStateChanged?.call(false);
    onSequenceComplete?.call();
  }

  /// ─── تكرار آية عدة مرات ───
  Future<void> repeatAyah({
    required int surahNumber,
    required int ayahNumber,
    int times = 3,
    Duration gap = const Duration(milliseconds: 600),
  }) async {
    _isSequencePlaying = true;

    for (int i = 0; i < times; i++) {
      if (!_isSequencePlaying) break;
      await playAyah(surahNumber, ayahNumber);
      if (i < times - 1) await Future.delayed(gap);
    }

    _isSequencePlaying = false;
    onPlayStateChanged?.call(false);
  }

  /// ─── تشغيل مقطع (من آية إلى آية) ───
  Future<void> playRange({
    required int surahNumber,
    required int fromAyah,
    required int toAyah,
    int repeatTimes = 1,
  }) async {
    _isSequencePlaying = true;

    for (int rep = 0; rep < repeatTimes; rep++) {
      if (!_isSequencePlaying) break;

      for (int ayah = fromAyah; ayah <= toAyah; ayah++) {
        if (!_isSequencePlaying) break;

        while (_isPaused) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!_isSequencePlaying) return;
        }

        await playAyah(surahNumber, ayah);
      }
    }

    _isSequencePlaying = false;
    onPlayStateChanged?.call(false);
    onSequenceComplete?.call();
  }

  /// ─── إيقاف مؤقت ───
  void pause() {
    _isPaused = true;
    _player.pause();
    onPlayStateChanged?.call(false);
  }

  /// ─── استئناف ───
  void resume() {
    _isPaused = false;
    _player.play();
    onPlayStateChanged?.call(true);
  }

  /// ─── إيقاف كامل ───
  void stop() {
    _isSequencePlaying = false;
    _isPaused = false;
    _player.stop();
    _currentAyah = 0;
    _currentSurah = 0;
    onPlayStateChanged?.call(false);
  }

  void dispose() {
    stop();
  }
}