// lib/screens/radio/widgets_recitations_screen/services/playlist_service.dart

import 'package:flutter/foundation.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/models/playlist_model.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';

class PlaylistService extends ChangeNotifier {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  List<PlaylistItem> _playlist = [];
  List<PlaylistItem> _allAvailableItems = []; // كل العناصر المتاحة للمصدر الحالي
  int _currentIndex = 0;
  bool _isRadioMode = false;
  String _playlistName = '';

  List<PlaylistItem> get playlist => _playlist;
  List<PlaylistItem> get allAvailableItems => _allAvailableItems;
  int get currentIndex => _currentIndex;
  bool get isRadioMode => _isRadioMode;
  String get playlistName => _playlistName;
  bool get hasPlaylist => _playlist.isNotEmpty;
  int get totalItems => _playlist.length;

  PlaylistItem? get currentItem =>
      _playlist.isNotEmpty && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  bool get hasNext => _playlist.length > 1 && (_currentIndex < _playlist.length - 1 || _isRadioMode);
  bool get hasPrevious => _playlist.length > 1 && (_currentIndex > 0 || _isRadioMode);



  // ═══════════════════════════════════════════════
  // بناء Playlist من عناصر فرعية
  // ═══════════════════════════════════════════════
  void buildFromSubItems({
    required RecitationItem parentItem,
    required ItemDownloadService downloadService,
    int startIndex = 0,
  }) {
    _allAvailableItems = [];
    _playlistName = parentItem.title;

    // ══ جلب كل العناصر (من subItems + subSections) ══
    final allSubs = parentItem.allSubItems;

    for (final sub in allSubs) {
      final tempItem = RecitationItem(
        title: sub.title,
        subtitle: sub.subtitle,
        emoji: sub.emoji,
        audioUrl: sub.audioUrl,
        imageUrl: sub.imageUrl ?? parentItem.imageUrl,
      );

      final itemId = ItemDownloadService.itemIdFromRecitationItem(tempItem);
      final localPath = downloadService.getLocalPath(itemId);

      _allAvailableItems.add(
        PlaylistItem.fromRecitationItem(
          tempItem,
          localPath: localPath,
        ),
      );
    }

    _playlist = List.from(_allAvailableItems);
    _currentIndex =
        startIndex.clamp(0, _playlist.isEmpty ? 0 : _playlist.length - 1);
    notifyListeners();
  }



  // ═══════════════════════════════════════════════
  // بناء Playlist من عناصر القسم (تلاوات مفردة)
  // ═══════════════════════════════════════════════
  void buildFromCategoryItems({
    required List<RecitationItem> items,
    required String categoryName,
    required ItemDownloadService downloadService,
    required RecitationItem currentItem,
  }) {
    _allAvailableItems = [];
    _playlistName = categoryName;

    for (final item in items) {
      if (item.audioUrl == null || item.audioUrl!.isEmpty) continue;

      final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
      final localPath = downloadService.getLocalPath(itemId);

      _allAvailableItems.add(
        PlaylistItem.fromRecitationItem(
          item,
          localPath: localPath,
        ),
      );
    }

    _playlist = List.from(_allAvailableItems);

    final idx = _playlist.indexWhere((e) =>
    e.title == currentItem.title &&
        e.subtitle == currentItem.subtitle);
    _currentIndex = idx >= 0 ? idx : 0;

    notifyListeners();
  }

  // ═══════════════════════════════════════════════
  // تخصيص Playlist للراديو
  // ═══════════════════════════════════════════════
  void setCustomRadioPlaylist(
      List<PlaylistItem> selectedItems, {
        int startIndex = 0,
      }) {
    if (selectedItems.isEmpty) return;
    _playlist = List.from(selectedItems);
    _currentIndex = startIndex.clamp(0, _playlist.length - 1);
    _isRadioMode = true;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════
  // العناصر المتاحة للراديو حسب الاتصال
  // ═══════════════════════════════════════════════
  List<PlaylistItem> getRadioCandidates({required bool offlineOnly}) {
    if (offlineOnly) {
      return _allAvailableItems.where((e) => e.isLocal).toList();
    }
    return List.from(_allAvailableItems);
  }

  PlaylistItem? next() {
    if (_playlist.isEmpty) return null;

    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    } else if (_isRadioMode) {
      _currentIndex = 0;
    } else {
      return null;
    }

    notifyListeners();
    return _playlist[_currentIndex];
  }

  PlaylistItem? previous() {
    if (_playlist.isEmpty) return null;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_isRadioMode) {
      _currentIndex = _playlist.length - 1;
    } else {
      return null;
    }

    notifyListeners();
    return _playlist[_currentIndex];
  }

  PlaylistItem? playAt(int index) {
    if (index < 0 || index >= _playlist.length) return null;
    _currentIndex = index;
    notifyListeners();
    return _playlist[_currentIndex];
  }

  void toggleRadioMode() {
    _isRadioMode = !_isRadioMode;
    notifyListeners();
  }

  void setRadioMode(bool value) {
    _isRadioMode = value;
    notifyListeners();
  }

  void clear() {
    _playlist = [];
    _allAvailableItems = [];
    _currentIndex = 0;
    _isRadioMode = false;
    _playlistName = '';
    notifyListeners();
  }
}