// lib/screens/radio/services/audio_coordinator.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/quran_data.dart';
import '../models/player_snapshot.dart';
import '../models/radio_station.dart';
import '../widgets_recitations_screen/models/playlist_model.dart';
import '../widgets_recitations_screen/services/playlist_service.dart';
import 'Radio_Intillegence.dart';
import 'listening_history_service.dart';
import 'offline_radio_service.dart';
import 'online_surah_service.dart';

enum ActivePlayer { none, online, offlineRadio, onlineSurah }

class AudioCoordinator extends ChangeNotifier {
  static final AudioCoordinator _instance = AudioCoordinator._internal();
  factory AudioCoordinator() => _instance;
  AudioCoordinator._internal() {
    // ✅ استمع لتغييرات كل service وأبلغ المستمعين
    _onlineRadio.addListener(_onServiceChanged);
    _offlineRadio.addListener(_onServiceChanged);
    _onlineSurah.addListener(_onServiceChanged);
  }

  // ✅ Throttle لتقليل عدد الإشعارات
  DateTime _lastNotify = DateTime.now();
  bool _notifyScheduled = false;

  void _onServiceChanged() {
    debugPrint('🔔 _onServiceChanged: _activePlayer=$_activePlayer');
    debugPrint('   online.current=${_onlineRadio.currentStation?.name}');
    debugPrint('   offline.current=${_offlineRadio.currentStation?.name}');
    debugPrint('   onlineSurah.current=${_onlineSurah.currentStation?.name}');
    debugPrint('   hasActivePlayer=$hasActivePlayer');

    notifyListeners();
  }

  final RadioIntillegence _onlineRadio = RadioIntillegence();
  final OfflineRadioService _offlineRadio = OfflineRadioService();
  final OnlineSurahService _onlineSurah = OnlineSurahService();

  ActivePlayer _activePlayer = ActivePlayer.none;
  bool _isSwitching = false;

  ActivePlayer get activePlayer => _activePlayer;
  RadioIntillegence get onlineRadio => _onlineRadio;
  OfflineRadioService get offlineRadio => _offlineRadio;
  OnlineSurahService get onlineSurah => _onlineSurah;

  int _requestId = 0;

  bool _isLatest(int requestId) => requestId == _requestId;

  // ══════════════════════════════════════════════════════
  // ✅ Snapshot موحد للمشغل الحالي
  // ══════════════════════════════════════════════════════

  PlayerSnapshot get snapshot {
    switch (_activePlayer) {
      case ActivePlayer.online:
        final station = _onlineRadio.currentStation;
        if (station == null) return PlayerSnapshot.empty;
        return PlayerSnapshot(
          hasActivePlayer: true,
          name: station.name,
          subtitle: station.category,
          emoji: station.iconEmoji,
          imageUrl: station.imageUrl,
          imageAsset: station.imageAsset,
          isPlaying: _onlineRadio.isPlaying,
          isBuffering: _onlineRadio.isBuffering,
          isOnline: true,
          sourceKey: 'online',
        );

      case ActivePlayer.offlineRadio:
        final station = _offlineRadio.currentStation;
        if (station == null) return PlayerSnapshot.empty;
        return PlayerSnapshot(
          hasActivePlayer: true,
          name: _offlineRadio.currentSurahName.isNotEmpty
              ? _offlineRadio.currentSurahName
              : station.name,
          subtitle: station.name,
          emoji: station.iconEmoji,
          imageUrl: station.imageUrl,
          imageAsset: station.imageAsset,
          isPlaying: _offlineRadio.isPlaying,
          isBuffering: false,
          isOnline: false,
          sourceKey: 'offline',
        );

      case ActivePlayer.onlineSurah:
        final station = _onlineSurah.currentStation;
        if (station == null) return PlayerSnapshot.empty;
        return PlayerSnapshot(
          hasActivePlayer: true,
          name: _onlineSurah.currentSurahName,
          subtitle: station.name,
          emoji: station.iconEmoji,
          imageUrl: station.imageUrl,
          imageAsset: station.imageAsset,
          isPlaying: _onlineSurah.isPlaying,
          isBuffering: _onlineSurah.isBuffering,
          isOnline: true,
          sourceKey: 'onlineSurah',
        );

      case ActivePlayer.none:
        return PlayerSnapshot.empty;
    }
  }

  bool get hasActivePlayer =>
      _activePlayer != ActivePlayer.none ||
          _onlineRadio.currentStation != null ||
          _offlineRadio.currentStation != null ||
          _onlineSurah.currentStation != null;
  String get currentName => snapshot.name;
  String get currentSubtitle => snapshot.subtitle;
  String get currentEmoji => snapshot.emoji;
  bool get isCurrentlyPlaying => snapshot.isPlaying;
  bool get isCurrentlyBuffering => snapshot.isBuffering;

  Future<void> _runSwitch(
      Future<void> Function(int requestId) action,
      ) async {
    final requestId = ++_requestId;
    _isSwitching = true;

    try {
      if (!_isLatest(requestId)) return;

      await action(requestId);
    } catch (e) {
      debugPrint('❌ AudioCoordinator _runSwitch: $e');

      if (_isLatest(requestId)) {
        _activePlayer = ActivePlayer.none;
        notifyListeners();
      }
    } finally {
      if (_isLatest(requestId)) {
        _isSwitching = false;
      }
    }
  }

  // ══ تشغيل راديو أونلاين ══
  Future<void> playOnlineRadio(dynamic station) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      // ✅ أوقف المشغلات الأخرى فقط (ليس online)
      await Future.wait([
        _quickStop(() => _offlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.online;
      notifyListeners();

      await _onlineRadio.playStation(station);

      if (!_isLatest(requestId)) return;

      _saveToHistory(station, 'radio');
      notifyListeners();
    });
  }

// ══ تشغيل راديو أوفلاين ══
  Future<void> playOfflineRadio(dynamic station) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      await Future.wait([
        _quickStop(() => _onlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.offlineRadio;
      notifyListeners();

      await _offlineRadio.playRadioMode(station);

      if (!_isLatest(requestId)) return;

      _saveToHistory(station, 'radio');
      notifyListeners();
    });
  }

// ══ تشغيل سورة أوفلاين ══
  Future<void> playOfflineSurah({
    required dynamic station,
    required int surahNumber,
    bool playAllFromHere = false,
  }) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      await Future.wait([
        _quickStop(() => _onlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.offlineRadio;
      notifyListeners();

      await _offlineRadio.playSingleSurah(
        station: station,
        surahNumber: surahNumber,
        playAllFromHere: playAllFromHere,
      );

      if (!_isLatest(requestId)) return;

      _saveToHistorySurah(station, surahNumber);
      notifyListeners();
    });
  }

// ══ تشغيل سورة أونلاين ══
  Future<void> playOnlineSurah({
    required dynamic station,
    required int surahNumber,
  }) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      await Future.wait([
        _quickStop(() => _onlineRadio.stop()),
        _quickStop(() => _offlineRadio.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.onlineSurah;
      notifyListeners();

      await _onlineSurah.playSurahOnline(
        station: station,
        surahNumber: surahNumber,
      );

      if (!_isLatest(requestId)) return;

      _saveToHistorySurah(station, surahNumber);
      notifyListeners();
    });
  }

// ══ تشغيل سورة (محلي أو أونلاين) ══
  Future<void> playSurahTrack({
    required IslamicRadioStation station,
    required int surahNumber,
    required bool isLocal,
    String? localPath,
  }) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      final surah = QuranData.surahByNumber(surahNumber);
      final source = isLocal
          ? (localPath ?? '')
          : (station.surahStreamUrl(surahNumber) ?? '');

      if (source.isEmpty) return;

      // ✅ أوقف المشغلات الأخرى فقط
      await Future.wait([
        _quickStop(() => _offlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.online;
      notifyListeners();

      final tempStation = IslamicRadioStation(
        id: source.hashCode.abs(),
        name: 'سورة ${surah.name}',
        nameEn: surah.name,
        url: source,
        category: station.name,
        categoryEn: 'Surah',
        description: station.name,
        descriptionEn: station.name,
        iconEmoji: station.iconEmoji,
        imageUrl: station.imageUrl,
        imageAsset: station.imageAsset,
      );

      // ✅ playStation يوقف القديم ويشغل الجديد تلقائياً
      if (isLocal) {
        await _onlineRadio.playLocalFile(tempStation);
      } else {
        await _onlineRadio.playStation(tempStation);
      }

      if (!_isLatest(requestId)) return;

      _saveToHistorySurah(station, surahNumber);
      notifyListeners();
    });
  }

// ══ تشغيل عنصر من القائمة ══
  Future<void> playPlaylistItem(dynamic item,) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      await Future.wait([
        _quickStop(() => _offlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      notifyListeners();

      _activePlayer = ActivePlayer.online;

      final station = IslamicRadioStation(
        id: (item.localPath ?? item.audioUrl).hashCode.abs(),
        name: item.title,
        nameEn: item.title,
        url: item.localPath ?? item.audioUrl,
        category: 'تلاوات',
        categoryEn: 'Recitations',
        description: item.subtitle,
        descriptionEn: item.subtitle,
        iconEmoji: item.emoji,
        imageUrl: item.imageUrl,
      );

      if (item.isLocal && item.localPath != null) {
        await _onlineRadio.playLocalFile(station);
      } else {
        await _onlineRadio.playStation(station);
      }

      if (!_isLatest(requestId)) return;

      _saveToHistory(station, 'recitation');

      notifyListeners();
    });
  }

// ══ تشغيل ملف محلي ══
  Future<void> playLocalItem({
    required dynamic station,
  }) {
    return _runSwitch((requestId) async {
      if (!_isLatest(requestId)) return;

      await Future.wait([
        _quickStop(() => _offlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);

      if (!_isLatest(requestId)) return;

      _activePlayer = ActivePlayer.online;
      notifyListeners();

      await _onlineRadio.playLocalFile(station);

      if (!_isLatest(requestId)) return;

      _saveToHistory(station, 'local');
      notifyListeners();
    });
  }

// ══ إيقاف الكل ══
  Future<void> stopAll() async {
    _requestId++;
    _isSwitching = true;

    try {
      await Future.wait([
        _quickStop(() => _onlineRadio.stop()),
        _quickStop(() => _offlineRadio.stop()),
        _quickStop(() => _onlineSurah.stop()),
      ]);
    } catch (_) {}

    _activePlayer = ActivePlayer.none;
    _isSwitching = false;
    notifyListeners();
  }

  Future<void> _quickStop(Future<void> Function() stopFn) async {
    try {
      await stopFn().timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {
          // ✅ تجاوز - لا ننتظر أكثر
        },
      );
    } catch (_) {}
  }

  // ══ تبديل تشغيل/إيقاف ══
  Future<void> togglePlayPause() async {
    switch (_activePlayer) {
      case ActivePlayer.online:
        await _onlineRadio.togglePlayPause();
        break;
      case ActivePlayer.offlineRadio:
        await _offlineRadio.togglePlayPause();
        break;
      case ActivePlayer.onlineSurah:
        await _onlineSurah.togglePlayPause();
        break;
      case ActivePlayer.none:
        break;
    }
    notifyListeners();
  }

  // ══ التالي ══
  Future<void> playNext() async {
    switch (_activePlayer) {
      case ActivePlayer.online:
        await _onlineRadio.playNext();
        break;
      case ActivePlayer.offlineRadio:
        await _offlineRadio.playNext();
        break;
      case ActivePlayer.onlineSurah:
        await _onlineSurah.playNext();
        break;
      case ActivePlayer.none:
        break;
    }
    notifyListeners();
  }

  // ══ السابق ══
  Future<void> playPrevious() async {
    switch (_activePlayer) {
      case ActivePlayer.online:
        await _onlineRadio.playPrevious();
        break;
      case ActivePlayer.offlineRadio:
        await _offlineRadio.playPrevious();
        break;
      case ActivePlayer.onlineSurah:
        await _onlineSurah.playPrevious();
        break;
      case ActivePlayer.none:
        break;
    }
    notifyListeners();
  }

  /// التالي في القائمة
  Future<void> playNextInPlaylist() async {
    final playlistService = PlaylistService();
    final nextItem = playlistService.next();
    if (nextItem != null) {
      await playPlaylistItem(nextItem);
    }
  }

  /// السابق في القائمة
  Future<void> playPreviousInPlaylist() async {
    final playlistService = PlaylistService();
    final prevItem = playlistService.previous();
    if (prevItem != null) {
      await playPlaylistItem(prevItem);
    }
  }

  void _saveToHistory(dynamic station, String type) {
    try {
      if (station is IslamicRadioStation) {
        debugPrint('══════════════════════');
        debugPrint('📝 حفظ في السجل:');
        debugPrint('   title: ${station.name}');
        debugPrint('   imageUrl: "${station.imageUrl}"');
        debugPrint('   imageAsset: "${station.imageAsset}"');
        debugPrint('   emoji: ${station.iconEmoji}');
        debugPrint('══════════════════════');

        ListeningHistoryService().addItem(
          ListeningHistoryItem(
            title: station.name,
            subtitle: station.description,
            emoji: station.iconEmoji,
            imageUrl: (station.imageUrl != null && station.imageUrl!.isNotEmpty)
                ? station.imageUrl
                : null,
            imageAsset: (station.imageAsset != null && station.imageAsset!.isNotEmpty)
                ? station.imageAsset
                : null,
            audioUrl: station.url,
            type: type,
            stationName: station.name,
            stationId: station.id,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _saveToHistory error: $e');
    }
  }

  void _saveToHistorySurah(dynamic station, int surahNumber) {
    try {
      if (station is IslamicRadioStation) {
        final surahName = surahNumber > 0 && surahNumber <= 114
            ? QuranData.surahByNumber(surahNumber).name
            : 'سورة $surahNumber';

        ListeningHistoryService().addItem(
          ListeningHistoryItem(
            title: 'سورة $surahName',
            subtitle: station.name,
            emoji: station.iconEmoji,
            imageUrl: (station.imageUrl != null && station.imageUrl!.isNotEmpty)
                ? station.imageUrl
                : null,
            imageAsset: (station.imageAsset != null && station.imageAsset!.isNotEmpty)
                ? station.imageAsset
                : null,
            audioUrl: station.url,
            type: 'surah',
            stationName: station.name,
            stationId: station.id,
            surahNumber: surahNumber,
          ),
        );
      }
    } catch (_) {}
  }

  void onPlayerStopped(ActivePlayer player) {
    if (_isSwitching) return;

    if (_activePlayer == player) {
      _activePlayer = ActivePlayer.none;
      notifyListeners();
    }
  }

}