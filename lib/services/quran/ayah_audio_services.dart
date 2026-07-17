import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'quran_text_service.dart';

class AyahAudioService {
  static const Map<String, int> _preferredBitrates = {
    'ar.alafasy': 128,
    'ar.husary': 128,
    'ar.abdulsamad': 64,
    'ar.mahermuaiqly': 128,
    'ar.abdurrahmaansudais': 192,
    'ar.saoodshuraym': 64,
    'ar.hudhaify': 128,
    'ar.muhammadayyoub': 128,
    'ar.ahmedajamy': 128,
    'ar.shaatree': 128,
    'ar.hanirifai': 192,
    'ar.ibrahimakhbar': 32,
    'ar.muhammadjibreel': 128,
    'ar.abdullahbasfar': 192,
    'ar.husarymujawwad': 128,
    'ar.minshawi': 128,
    'ar.minshawimujawwad': 64,
  };

  final AudioPlayer _player;
  String reciterId;

  int _currentSurah = 0;
  int _currentAyah = 0;
  bool _isSequencePlaying = false;
  bool _isPaused = false;

  void Function(int surah, int ayah)? onAyahStarted;
  VoidCallback? onSequenceComplete;
  ValueChanged<bool>? onPlayStateChanged;
  ValueChanged<String>? onError;

  AyahAudioService({required AudioPlayer player, this.reciterId = 'ar.alafasy'})
    : _player = player;

  int get currentAyah => _currentAyah;
  int get currentSurah => _currentSurah;
  bool get isPlaying => _isSequencePlaying && !_isPaused;
  bool get isPaused => _isPaused;

  /// Each edition has an official preferred bitrate. The remaining bitrates
  /// and regional mirror are tried automatically if that source is down.
  List<String> _ayahUrls(int globalNumber) {
    final preferred = _preferredBitrates[reciterId] ?? 128;
    final bitrates = <int>{preferred, 128, 64, 192};
    return [
      for (final bitrate in bitrates)
        'https://cdn.islamic.network/quran/audio/$bitrate/$reciterId/$globalNumber.mp3',
      for (final bitrate in bitrates)
        'https://cdn.alislam.ru/quran/audio/$bitrate/$reciterId/$globalNumber.mp3',
    ];
  }

  Future<void> _loadAyah(int globalNumber) async {
    Object? lastError;
    for (final url in _ayahUrls(globalNumber)) {
      try {
        await _player.setUrl(url).timeout(const Duration(seconds: 18));
        return;
      } catch (error) {
        lastError = error;
        debugPrint('Ayah audio source failed: $url — $error');
      }
    }
    throw StateError('All audio sources failed: $lastError');
  }

  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    final globalNumber = QuranTextService.getGlobalAyahNumber(
      surahNumber,
      ayahNumber,
    );

    try {
      await _loadAyah(globalNumber);
      onAyahStarted?.call(surahNumber, ayahNumber);
      onPlayStateChanged?.call(true);
      await _player.play();
      await _waitForCompletion();
      onPlayStateChanged?.call(false);
    } catch (error) {
      debugPrint('playAyah $globalNumber error: $error');
      onPlayStateChanged?.call(false);
      onError?.call('تعذر تشغيل التلاوة. تحقق من اتصال الإنترنت.');
    }
  }

  Future<void> playPage({required int page, int startFromAyahIndex = 0}) async {
    final ayahs = QuranTextService.getPageAyahs(page);
    if (ayahs.isEmpty) return;

    _isSequencePlaying = true;
    _isPaused = false;

    for (
      var index = startFromAyahIndex;
      index < ayahs.length && _isSequencePlaying;
      index++
    ) {
      while (_isPaused && _isSequencePlaying) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (!_isSequencePlaying) break;

      final ayah = ayahs[index];
      final surahNumber = ayah['surahNumber'] as int;
      final ayahNumber = ayah['numberInSurah'] as int;
      final globalNumber =
          ayah['number'] as int? ??
          QuranTextService.getGlobalAyahNumber(surahNumber, ayahNumber);
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;

      try {
        await _loadAyah(globalNumber);
        if (!_isSequencePlaying) break;
        onAyahStarted?.call(surahNumber, ayahNumber);
        onPlayStateChanged?.call(true);
        await _player.play();
        await _waitForCompletion();
      } catch (error) {
        debugPrint('playPage ayah $globalNumber error: $error');
        onError?.call(
          'تعذر تشغيل ${_displayReciterError()}. تم تجربة الروابط الاحتياطية.',
        );
        break;
      }
    }

    _isSequencePlaying = false;
    _isPaused = false;
    onPlayStateChanged?.call(false);
    onSequenceComplete?.call();
  }

  Future<void> _waitForCompletion() async {
    await _player.playerStateStream
        .firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        )
        .timeout(const Duration(minutes: 3));
  }

  String _displayReciterError() => 'تلاوة القارئ المحدد';

  Future<void> repeatAyah({
    required int surahNumber,
    required int ayahNumber,
    int times = 3,
    Duration gap = const Duration(milliseconds: 600),
  }) async {
    _isSequencePlaying = true;
    for (var count = 0; count < times && _isSequencePlaying; count++) {
      await playAyah(surahNumber, ayahNumber);
      if (count < times - 1) await Future<void>.delayed(gap);
    }
    _isSequencePlaying = false;
    onPlayStateChanged?.call(false);
  }

  void pause() {
    _isPaused = true;
    _player.pause();
    onPlayStateChanged?.call(false);
  }

  void resume() {
    _isPaused = false;
    _player.play();
    onPlayStateChanged?.call(true);
  }

  void stop() {
    _isSequencePlaying = false;
    _isPaused = false;
    _player.stop();
    _currentAyah = 0;
    _currentSurah = 0;
    onPlayStateChanged?.call(false);
  }

  void dispose() => stop();
}
