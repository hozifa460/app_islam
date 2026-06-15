// lib/screens/radio/services/playback_position_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PlaybackPositionService {
  static final PlaybackPositionService _instance =
  PlaybackPositionService._internal();
  factory PlaybackPositionService() => _instance;
  PlaybackPositionService._internal();

  final Map<String, int> _memCache = {};

  static String _stableId(String key) {
    int hash = 5381;
    for (int i = 0; i < key.length; i++) {
      hash = ((hash << 5) + hash) + key.codeUnitAt(i);
      hash &= 0x7FFFFFFF;
    }
    return 'p_$hash';
  }

  Future<void> savePosition(String key, Duration position) async {
    if (key.isEmpty || position.inSeconds <= 0) return;

    final id = _stableId(key);
    _memCache[id] = position.inMilliseconds;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('playpos_$id', position.inMilliseconds);
    } catch (_) {}
  }

  Duration getPosition(String key) {
    if (key.isEmpty) return Duration.zero;

    final id = _stableId(key);
    final cached = _memCache[id];
    if (cached != null) return Duration(milliseconds: cached);

    return Duration.zero;
  }

  Future<Duration> getPositionAsync(String key) async {
    if (key.isEmpty) return Duration.zero;

    final id = _stableId(key);

    if (_memCache.containsKey(id)) {
      return Duration(milliseconds: _memCache[id]!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt('playpos_$id');
      if (ms != null && ms > 0) {
        _memCache[id] = ms;
        return Duration(milliseconds: ms);
      }
    } catch (_) {}

    return Duration.zero;
  }

  Future<void> clearPosition(String key) async {
    if (key.isEmpty) return;
    final id = _stableId(key);
    _memCache.remove(id);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('playpos_$id');
    } catch (_) {}
  }
}