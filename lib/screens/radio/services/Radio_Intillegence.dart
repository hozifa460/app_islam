// lib/screens/radio/services/radio_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/radio_data.dart';
import '../models/radio_station.dart';

class RadioIntillegence extends ChangeNotifier {
  static final RadioIntillegence _instance = RadioIntillegence._internal();
  factory RadioIntillegence() => _instance;
  RadioIntillegence._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  IslamicRadioStation? _currentStation;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  String? _error;
  List<int> _favorites = [];
  List<int> _recentlyPlayed = [];
  Duration _listenDuration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _listenTimer;

  // ══ Getters ══
  IslamicRadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  String? get error => _error;
  List<int> get favorites => _favorites;
  List<int> get recentlyPlayed => _recentlyPlayed;
  Duration get listenDuration => _listenDuration;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  // ══ تفويض البيانات لملف البيانات ══
  static List<IslamicRadioStation> get allStations => RadioStationsData.all;
  static List<String> get categories => RadioStationsData.categories;
  static List<IslamicRadioStation> stationsByCategory(String cat) =>
      RadioStationsData.byCategory(cat);

  bool get _isCurrentSourceLocal {
    final url = _currentStation?.url ?? '';
    if (url.isEmpty) return false;

    // يعتبر محلياً إذا لم يبدأ بـ http/https
    return !(url.startsWith('http://') || url.startsWith('https://'));
  }

  // ══ تهيئة ══
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFavorites();
    await _loadRecentlyPlayed();

    _player.playerStateStream.listen((state) {
      final newPlaying = state.playing;
      final newBuffering =
          state.processingState == ProcessingState.buffering ||
              state.processingState == ProcessingState.loading;

      // ✅ فقط إذا تغيرت الحالة فعلاً
      if (newPlaying != _isPlaying || newBuffering != _isBuffering) {
        _isPlaying = newPlaying;
        _isBuffering = newBuffering;

        if (state.processingState == ProcessingState.idle) {
          _isPlaying = false;
        }

        notifyListeners();
      }
    });

    _player.playbackEventStream.listen(
          (_) {},
      onError: (e, st) {
        _error = 'حدث خطأ في التشغيل';
        _isLoading = false;
        _isPlaying = false;
        notifyListeners();
      },
    );

    DateTime lastPositionNotify = DateTime.now();
    _player.positionStream.listen((position) {
      _position = position;
      final now = DateTime.now();
      if (now.difference(lastPositionNotify).inMilliseconds >= 500) {
        lastPositionNotify = now;
        notifyListeners();
      }
    });
    _player.durationStream.listen((duration) {
      if (duration == null) return;
      _duration = duration;
      notifyListeners();
    });
  }

  // ══ تشغيل محطة ══
  // في دالة playStation أضف try-catch أقوى

  Future<void> playStation(IslamicRadioStation station) async {
    try {
      _error = null;
      _isLoading = true;
      _isBuffering = true;
      _currentStation = station;
      _stopListenTimer();
      notifyListeners();

      try {
        await _player.stop();
      } catch (_) {}

      await _player.setUrl(station.url);
      await _player.play();

      _isLoading = false;
      _isBuffering = false;
      _isPlaying = true;

      _addToRecentlyPlayed(station.id);
      _startListenTimer();
      notifyListeners();

      debugPrint('✅ online station playing');
    } catch (e) {
      _error = 'تعذّر الاتصال بالمحطة';
      _isLoading = false;
      _isBuffering = false;
      _isPlaying = false;
      _stopListenTimer();
      notifyListeners();
      debugPrint('❌ RadioIntillegence.playStation: $e');
    }
  }

// في دالة stop
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}

    _currentStation = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    _isLoading = false;
    _isBuffering = false;
    _stopListenTimer();
    notifyListeners();
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('❌ pause error: $e');
    }

    _isPlaying = false;
    _stopListenTimer();
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentStation == null) return;

    try {
      await _player.play();
      _isPlaying = true;
      _isLoading = false;
      _isBuffering = false;
      _startListenTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ resume fallback: $e');

      // ✅ فرق مهم: إذا المصدر محلي أعد تشغيله محلياً
      if (_isCurrentSourceLocal) {
        await playLocalFile(_currentStation!);
      } else {
        await playStation(_currentStation!);
      }
    }
  }

  // في Radio_Intillegence.dart أضف:

  // في Radio_Intillegence.dart

  Future<void> playLocalFile(IslamicRadioStation station) async {
    try {
      _error = null;
      _isLoading = true;
      _isBuffering = false;
      _currentStation = station;
      _stopListenTimer();
      notifyListeners();

      debugPrint('🎵 RadioIntillegence.playLocalFile: ${station.url}');

      // أوقف أي تشغيل سابق
      try {
        await _player.stop();
      } catch (_) {}

      final file = File(station.url);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: ${station.url}');
      }

      debugPrint('📄 الملف موجود: ${await file.length()} bytes');

      await _player.setFilePath(station.url);
      await _player.play();

      _isLoading = false;
      _isBuffering = false;
      _isPlaying = true;
      _startListenTimer();
      notifyListeners();

      debugPrint('✅ local file playing');
    } catch (e) {
      _error = 'فشل تشغيل الملف';
      _isLoading = false;
      _isBuffering = false;
      _isPlaying = false;
      _stopListenTimer();
      notifyListeners();
      debugPrint('❌ playLocalFile error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> playNext() async {
    if (_currentStation == null) return;
    final list = RadioStationsData.all;
    final idx = list.indexWhere((s) => s.id == _currentStation!.id);
    final next = (idx + 1) % list.length;
    await playStation(list[next]);
  }

  Future<void> playPrevious() async {
    if (_currentStation == null) return;
    final list = RadioStationsData.all;
    final idx = list.indexWhere((s) => s.id == _currentStation!.id);
    final prev = (idx - 1 + list.length) % list.length;
    await playStation(list[prev]);
  }

  // ══ المفضلة ══
  bool isFavorite(int id) => _favorites.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    await _saveFavorites();
    notifyListeners();
  }

  List<IslamicRadioStation> get favoriteStations =>
      RadioStationsData.all
          .where((s) => _favorites.contains(s.id))
          .toList();

  // ══ الأخيرة ══
  List<IslamicRadioStation> get recentStations {
    return _recentlyPlayed
        .map((id) {
      try {
        return RadioStationsData.all.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    })
        .whereType<IslamicRadioStation>()
        .take(6)
        .toList();
  }

  void _addToRecentlyPlayed(int id) async {
    _recentlyPlayed.remove(id);
    _recentlyPlayed.insert(0, id);
    if (_recentlyPlayed.length > 10) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 10);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'radio_recent',
        _recentlyPlayed.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  // ══ التخزين المحلي ══
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('radio_favorites') ?? [];
      _favorites = list.map((e) => int.tryParse(e) ?? 0).toList();
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'radio_favorites',
        _favorites.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  Future<void> _loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('radio_recent') ?? [];
      _recentlyPlayed = list.map((e) => int.tryParse(e) ?? 0).toList();
    } catch (_) {}
  }

  // ══ مؤقت الاستماع ══
  void _startListenTimer() {
    _stopListenTimer();
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _listenDuration += const Duration(seconds: 1);
    });
  }

  void _stopListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = null;
  }

  @override
  void dispose() {
    _player.dispose();
    _listenTimer?.cancel();
    super.dispose();
  }
}
