// lib/screens/radio/services/online_surah_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart';
import '../models/surah_model.dart';
import '../data/quran_data.dart';

class OnlineSurahService extends ChangeNotifier {
  static final OnlineSurahService _instance = OnlineSurahService._internal();
  factory OnlineSurahService() => _instance;
  OnlineSurahService._internal();

  AudioPlayer? _player;
  bool _initialized = false;
  bool _isDisposed = false;

  IslamicRadioStation? _currentStation;
  SurahModel? _currentSurah;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<int> _onlinePlaylist = [];
  int _currentIndex = 0;
  bool _isLooping = false;

  // ══ للتأكد من عدم تشغيل أكثر من طلب في نفس الوقت ══
  int _playRequestId = 0;

  IslamicRadioStation? get currentStation => _currentStation;
  SurahModel? get currentSurah => _currentSurah;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLooping => _isLooping;

  int get currentSurahNumber =>
      _onlinePlaylist.isNotEmpty && _currentIndex < _onlinePlaylist.length
          ? _onlinePlaylist[_currentIndex]
          : 0;

  String get currentSurahName => _currentSurah?.name ?? '';

  // ══ تهيئة المشغل ══
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _initPlayer();
  }

  Future<void> _initPlayer() async {
    // تأكد من عدم وجود مشغل قديم
    if (_player != null) {
      try {
        await _player!.stop();
        await _player!.dispose();
      } catch (_) {}
      _player = null;
    }

    // أنشئ مشغل جديد
    _player = AudioPlayer();

    _player!.playerStateStream.listen((state) {
      if (_isDisposed) return;
      _isPlaying = state.playing;
      _isBuffering =
          state.processingState == ProcessingState.buffering ||
              state.processingState == ProcessingState.loading;
      _safeNotify();
    });

    DateTime lastPosNotify = DateTime.now();

    _player!.positionStream.listen((pos) {
      if (_isDisposed) return;
      _position = pos;

      final now = DateTime.now();
      if (now.difference(lastPosNotify).inMilliseconds >= 500) {
        lastPosNotify = now;
        _safeNotify();
      }
    });

    _player!.durationStream.listen((dur) {
      if (_isDisposed || dur == null) return;
      _duration = dur;
      _safeNotify();
    });

    _player!.processingStateStream.listen((state) {
      if (_isDisposed) return;
      if (state == ProcessingState.completed) {
        _onSurahCompleted();
      }
    });
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  void _onSurahCompleted() {
    if (_isLooping) {
      _player?.seek(Duration.zero);
      _player?.play();
      return;
    }
    if (_onlinePlaylist.length > 1) {
      playNext();
    }
  }

  // ══ تشغيل سورة أونلاين ══
  Future<void> playSurahOnline({
    required IslamicRadioStation station,
    required int surahNumber,
  }) async {
    if (station.streamBaseUrl == null) {
      _error = 'هذا القارئ لا يدعم الاستماع المباشر';
      _safeNotify();
      return;
    }

    // زيادة ID الطلب لإلغاء أي طلب قديم
    final requestId = ++_playRequestId;

    _error = null;
    _isLoading = true;
    _isBuffering = true;
    _currentStation = station;
    _onlinePlaylist = [surahNumber];
    _currentIndex = 0;

    try {
      _currentSurah = QuranData.surahByNumber(surahNumber);
    } catch (_) {}

    _safeNotify();

    try {
      // أوقف المشغل الحالي أولاً
      if (_player != null) {
        try {
          await _player!.stop();
        } catch (_) {}
      }

      // تحقق إذا تم إلغاء الطلب
      if (requestId != _playRequestId) return;

      // تأكد من أن المشغل جاهز
      if (_player == null) {
        await _initPlayer();
      }

      final url = station.surahStreamUrl(surahNumber);
      if (url == null) throw Exception('رابط غير متاح');

      // تحقق مجدداً
      if (requestId != _playRequestId) return;

      await _player!.setUrl(url);

      // تحقق مجدداً قبل التشغيل
      if (requestId != _playRequestId) return;

      await _player!.play();

      if (requestId != _playRequestId) return;

      _isLoading = false;
      _safeNotify();
    } catch (e) {
      if (requestId != _playRequestId) return;

      _error = 'فشل تحميل السورة';
      _isLoading = false;
      _isBuffering = false;
      _safeNotify();
      debugPrint('❌ OnlineSurahService: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (_) {}
    _safeNotify();
  }

  Future<void> resume() async {
    try {
      await _player?.play();
    } catch (_) {}
    _safeNotify();
  }

  Future<void> stop() async {
    _playRequestId++;

    try {
      await _player?.stop();
    } catch (_) {}

    _currentStation = null;
    _currentSurah = null;
    _isPlaying = false;
    _isLoading = false;
    _isBuffering = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _onlinePlaylist = [];
    _error = null;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> playNext() async {
    if (_onlinePlaylist.isEmpty || _currentStation == null) return;
    final next = (_currentIndex + 1) % _onlinePlaylist.length;
    _currentIndex = next;
    final surahNum = _onlinePlaylist[next];

    try {
      _currentSurah = QuranData.surahByNumber(surahNum);
    } catch (_) {}

    await playSurahOnline(
      station: _currentStation!,
      surahNumber: surahNum,
    );
  }

  Future<void> playPrevious() async {
    if (_onlinePlaylist.isEmpty || _currentStation == null) return;

    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final prev =
        (_currentIndex - 1 + _onlinePlaylist.length) % _onlinePlaylist.length;
    _currentIndex = prev;
    final surahNum = _onlinePlaylist[prev];

    try {
      _currentSurah = QuranData.surahByNumber(surahNum);
    } catch (_) {}

    await playSurahOnline(
      station: _currentStation!,
      surahNumber: surahNum,
    );
  }

  Future<void> seek(Duration position) async {
    try {
      await _player?.seek(position);
    } catch (_) {}
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player?.setSpeed(speed);
    } catch (_) {}
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    _safeNotify();
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _player?.dispose();
    _player = null;
    super.dispose();
  }
}
