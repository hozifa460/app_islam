// lib/screens/radio/services/offline_radio_service.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart';
import '../models/surah_model.dart';
import '../data/quran_data.dart';
import 'audio_coordinator.dart';
import 'radio_download_service.dart';

enum OfflinePlayMode { radio, single }

class OfflineRadioService extends ChangeNotifier {
  static final OfflineRadioService _instance =
  OfflineRadioService._internal();
  factory OfflineRadioService() => _instance;
  OfflineRadioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final RadioDownloadService _downloadService = RadioDownloadService();

  IslamicRadioStation? _currentStation;
  SurahModel? _currentSurah;
  OfflinePlayMode _playMode = OfflinePlayMode.radio;
  bool _isPlaying = false;
  bool _isLoading = false;
  List<String> _playlist = [];
  List<int> _playlistSurahNumbers = [];
  int _currentIndex = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isShuffled = false;
  bool _isLooping = false;

  // Getters
  IslamicRadioStation? get currentStation => _currentStation;
  SurahModel? get currentSurah => _currentSurah;
  OfflinePlayMode get playMode => _playMode;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  int get totalSurahs => _playlist.length;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffled => _isShuffled;
  bool get isLooping => _isLooping;
  AudioPlayer get player => _player;

  String get currentSurahName {
    if (_currentSurah != null) return _currentSurah!.name;
    if (_playlistSurahNumbers.isEmpty) return '';
    if (_currentIndex >= _playlistSurahNumbers.length) return '';
    final num = _playlistSurahNumbers[_currentIndex];
    try {
      return QuranData.surahByNumber(num).name;
    } catch (_) {
      return '';
    }
  }

  int get currentSurahNumber {
    if (_playlistSurahNumbers.isEmpty) return 0;
    if (_currentIndex >= _playlistSurahNumbers.length) return 0;
    return _playlistSurahNumbers[_currentIndex];
  }

  // ══ تهيئة ══
  Future<void> init() async {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    DateTime _lastPositionNotify = DateTime.now();

    _player.positionStream.listen((pos) {
      _position = pos;

      // ✅ أبلغ المستمعين كل 500 مللي ثانية فقط
      final now = DateTime.now();
      if (now.difference(_lastPositionNotify).inMilliseconds >= 500) {
        _lastPositionNotify = now;
        notifyListeners();
      }
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onSurahCompleted();
      }
    });
  }

  void _onSurahCompleted() {
    if (_playMode == OfflinePlayMode.single) {
      if (_isLooping) {
        _player.seek(Duration.zero);
        _player.play();
      }
      return;
    }
    // وضع الراديو - انتقل للتالي تلقائياً
    _playNext();
  }

  // ══════════════════════════════════════════════════════
  // تشغيل وضع الراديو (دائري لا نهائي)
  // ══════════════════════════════════════════════════════

  Future<void> playRadioMode(IslamicRadioStation station) async {
    _isLoading = true;
    _currentStation = station;
    _playMode = OfflinePlayMode.radio;
    notifyListeners();

    final paths = await _downloadService.getDownloadedPaths(station.id);

    if (paths.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _playlist = paths;
    _playlistSurahNumbers = _extractSurahNumbers(paths);

    // ابدأ من نقطة عشوائية مثل الراديو الحقيقي
    _currentIndex = Random().nextInt(_playlist.length);

    await _playAtIndex(_currentIndex);
    _isLoading = false;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════
  // تشغيل سورة محددة (وضع المستمع)
  // ══════════════════════════════════════════════════════

  Future<void> playSingleSurah({
    required IslamicRadioStation station,
    required int surahNumber,
    bool playAllFromHere = false,
  }) async {
    _isLoading = true;
    _currentStation = station;
    _playMode = OfflinePlayMode.single;
    notifyListeners();

    if (playAllFromHere) {
      // شغّل كل السور المحملة ابتداءً من هذه السورة
      final paths = await _downloadService.getDownloadedPaths(station.id);
      _playlist = paths;
      _playlistSurahNumbers = _extractSurahNumbers(paths);
      _currentIndex = _playlistSurahNumbers.indexOf(surahNumber);
      if (_currentIndex < 0) _currentIndex = 0;
      _playMode = OfflinePlayMode.radio;
    } else {
      // شغّل السورة وحدها
      final path =
      await _downloadService.getSurahPath(station.id, surahNumber);
      if (path == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      _playlist = [path];
      _playlistSurahNumbers = [surahNumber];
      _currentIndex = 0;
    }

    try {
      _currentSurah = QuranData.surahByNumber(surahNumber);
    } catch (_) {
      _currentSurah = null;
    }

    await _playAtIndex(_currentIndex);
    _isLoading = false;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════
  // التحكم الأساسي
  // ══════════════════════════════════════════════════════

  Future<void> _playAtIndex(int index) async {
    if (_playlist.isEmpty || index >= _playlist.length) return;
    try {
      _currentIndex = index;
      await _player.stop();
      await _player.setFilePath(_playlist[index]);
      await _player.play();

      // تحديث السورة الحالية
      if (_playlistSurahNumbers.isNotEmpty &&
          index < _playlistSurahNumbers.length) {
        try {
          _currentSurah =
              QuranData.surahByNumber(_playlistSurahNumbers[index]);
        } catch (_) {
          _currentSurah = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ OfflineRadio._playAtIndex: $e');
      _playNext();
    }
  }

  Future<void> _playNext() async {
    if (_playlist.isEmpty) return;
    final next = (_currentIndex + 1) % _playlist.length;
    await _playAtIndex(next);
  }

  Future<void> playNext() => _playNext();

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    // إذا مضى أكثر من 3 ثواني أعد السورة من البداية
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final prev = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _playAtIndex(prev);
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}

    _currentStation = null;
    _currentSurah = null;
    _isPlaying = false;
    _isLoading = false;
    _playlist = [];
    _playlistSurahNumbers = [];
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  // ══ خلط وتكرار ══
  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _playlist.shuffle();
      _playlistSurahNumbers = _extractSurahNumbers(_playlist);
      _currentIndex = 0;
    }
    notifyListeners();
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  // ══ مساعدات ══
  List<int> _extractSurahNumbers(List<String> paths) {
    return paths.map((p) {
      final name = p.split('/').last.replaceAll('.mp3', '');
      return int.tryParse(name) ?? 0;
    }).toList();
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}