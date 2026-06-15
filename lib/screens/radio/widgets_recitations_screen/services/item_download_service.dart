// lib/screens/radio/services/item_download_service.dart

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/recitation_categories_data.dart';
import '../../models/radio_station.dart';
import '../models/downloadable_item.dart';

class ItemDownloadService extends ChangeNotifier {
  static final ItemDownloadService _instance =
  ItemDownloadService._internal();
  factory ItemDownloadService() => _instance;
  ItemDownloadService._internal();

  final Queue<_QueuedDownloadTask> _queue = Queue<_QueuedDownloadTask>();
  final Set<String> _queuedOrActive = {};
  bool _isProcessingQueue = false;
  String? _activeTaskId;

  // خريطة حالات التحميل - المفتاح هو id العنصر
  final Map<String, DownloadableItemInfo> _downloads = {};
  final Map<String, bool> _cancelFlags = {};

  // Getters
  DownloadableItemInfo? getInfo(String itemId) => _downloads[itemId];

  ItemDownloadStatus getStatus(String itemId) =>
      _downloads[itemId]?.status ?? ItemDownloadStatus.notDownloaded;

  double getProgress(String itemId) => _downloads[itemId]?.progress ?? 0;

  bool isDownloaded(String itemId) =>
      _downloads[itemId]?.status == ItemDownloadStatus.downloaded;

  String? getLocalPath(String itemId) => _downloads[itemId]?.localPath;

  // ══ تهيئة ══
  Future<void> init() async {
    await _loadSavedDownloads();
  }

  // ══ تحميل عنصر ══

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Android 13+
        final audioStatus = await Permission.audio.request();
        return audioStatus.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  /// تحميل مع مجلد واسم مخصص
  Future<void> downloadItem(
      RecitationItem item, {
        String? customDir,
        String? customFileName,
      }) async {
    final itemId = _itemId(item);

    if (item.audioUrl == null || item.audioUrl!.isEmpty) return;

    // ✅ إذا كان في الطابور أو جاري التحميل
    if (_queuedOrActive.contains(itemId)) return;

    _cancelFlags[itemId] = false;
    _queuedOrActive.add(itemId);

    _downloads[itemId] = DownloadableItemInfo(
      itemId: itemId,
      status: ItemDownloadStatus.downloading,
      progress: 0,
    );

    _queue.add(
      _QueuedDownloadTask(
        item: item,
        itemId: itemId,
        customDir: customDir,
        customFileName: customFileName,
      ),
    );

    notifyListeners();
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_queue.isNotEmpty) {
      final task = _queue.removeFirst();
      _activeTaskId = task.itemId;

      if (_cancelFlags[task.itemId] == true) {
        _markAsNotDownloaded(task.itemId);
        _queuedOrActive.remove(task.itemId);
        continue;
      }

      await _performDownload(task);

      _queuedOrActive.remove(task.itemId);
      _activeTaskId = null;

      // تهدئة خفيفة بين التحميلات
      if (_queue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
    }

    _isProcessingQueue = false;
  }

  Future<void> _performDownload(_QueuedDownloadTask task) async {
    final item = task.item;
    final itemId = task.itemId;

    try {
      final Directory dir;
      if (task.customDir != null) {
        final baseDir = await _getItemDir();
        dir = Directory('${baseDir.path}/${task.customDir}');
      } else {
        dir = await _getItemDir();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final String fileName;
      if (task.customFileName != null && task.customFileName!.isNotEmpty) {
        fileName = '${task.customFileName}.mp3';
      } else {
        final safeName = item.title
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .trim();
        fileName = safeName.isNotEmpty ? '$safeName.mp3' : '$itemId.mp3';
      }

      final file = File('${dir.path}/$fileName');

      // ✅ إذا الملف موجود سابقاً
      if (await file.exists()) {
        final existingSize = await file.length();
        if (existingSize > 1000) {
          _downloads[itemId]!.status = ItemDownloadStatus.downloaded;
          _downloads[itemId]!.progress = 1.0;
          _downloads[itemId]!.localPath = file.path;
          await _saveDownload(itemId, file.path);
          notifyListeners();
          return;
        }
      }

      final request = http.Request('GET', Uri.parse(item.audioUrl!));
      request.headers.addAll({
        'User-Agent': 'Mozilla/5.0',
        'Accept': '*/*',
      });

      final client = http.Client();
      final response = await client.send(request).timeout(
        const Duration(minutes: 30),
      );

      if (response.statusCode != 200) {
        client.close();
        throw Exception('فشل التحميل: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        if (_cancelFlags[itemId] == true) {
          await sink.flush();
          await sink.close();
          client.close();

          if (await file.exists()) {
            await file.delete();
          }

          _markAsNotDownloaded(itemId);
          notifyListeners();
          return;
        }

        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes > 0) {
          _downloads[itemId]!.progress = receivedBytes / totalBytes;
          notifyListeners();
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      final savedSize = await file.length();
      if (savedSize < 1000) {
        if (await file.exists()) await file.delete();
        throw Exception('الملف المحمّل غير صالح');
      }

      _downloads[itemId]!.status = ItemDownloadStatus.downloaded;
      _downloads[itemId]!.progress = 1.0;
      _downloads[itemId]!.localPath = file.path;

      await _saveDownload(itemId, file.path);
      notifyListeners();
    } catch (e) {
      if (_cancelFlags[itemId] == true) {
        _markAsNotDownloaded(itemId);
      } else {
        _downloads[itemId]!.status = ItemDownloadStatus.error;
        _downloads[itemId]!.error = e.toString();
      }
      notifyListeners();
    }
  }

  void _markAsNotDownloaded(String itemId) {
    _downloads[itemId]?.status = ItemDownloadStatus.notDownloaded;
    _downloads[itemId]?.progress = 0;
    _downloads[itemId]?.localPath = null;
    _downloads[itemId]?.error = null;
  }


  // في item_download_service.dart أضف

  Future<bool> verifyDownload(String itemId) async {
    final path = _downloads[itemId]?.localPath;
    if (path == null) {
      debugPrint('❌ verify: لا يوجد مسار لـ $itemId');
      return false;
    }

    final file = File(path);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;

    debugPrint('🔍 verify: $itemId');
    debugPrint('   path: $path');
    debugPrint('   exists: $exists');
    debugPrint('   size: $size bytes');

    return exists && size > 1000;
  }

  // ══ إلغاء التحميل ══
  void cancelDownload(String itemId) {
    _cancelFlags[itemId] = true;

    // ✅ إذا لم يبدأ بعد، أخرجه من الطابور فوراً
    if (_activeTaskId != itemId) {
      _queue.removeWhere((task) => task.itemId == itemId);
      _queuedOrActive.remove(itemId);
      _markAsNotDownloaded(itemId);
      notifyListeners();
    }
  }

  // ══ حذف التحميل ══
  Future<void> deleteDownload(String itemId) async {
    try {
      final path = _downloads[itemId]?.localPath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      _downloads.remove(itemId);
      await _removeDownload(itemId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ خطأ حذف: $e');
    }
  }

  // ══ حجم الملف ══
  Future<String> getFileSize(String itemId) async {
    try {
      final path = _downloads[itemId]?.localPath;
      if (path == null) return '0 MB';
      final file = File(path);
      if (!await file.exists()) return '0 MB';
      final bytes = await file.length();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }

  // ══ ID العنصر ══
  static String itemIdFromRecitationItem(RecitationItem item) =>
      _itemId(item);

  static String _itemId(RecitationItem item) =>
      '${item.title}_${item.audioUrl ?? ''}'.hashCode.abs().toString();

  // ══ مجلد التحميل ══

  Future<Directory> _getItemDir() async {
    if (Platform.isAndroid) {
      // ══ مجلد Downloads العام ══
      final dir = Directory('/storage/emulated/0/Download/تلاوات');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }

    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/items_offline');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ══ حفظ واسترجاع ══
  // في item_download_service.dart - استبدل _loadSavedDownloads

  Future<void> _loadSavedDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('item_downloads_keys') ?? [];

      debugPrint('📂 تحميل ${keys.length} عناصر محفوظة...');

      for (final key in keys) {
        final path = prefs.getString('item_path_$key');
        debugPrint('   key=$key path=$path');

        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            final size = await file.length();
            debugPrint('   ✅ موجود: $size bytes');

            _downloads[key] = DownloadableItemInfo(
              itemId: key,
              status: ItemDownloadStatus.downloaded,
              progress: 1.0,
              localPath: path,
            );
          } else {
            debugPrint('   ❌ الملف غير موجود!');
            // نظف المفتاح
            await prefs.remove('item_path_$key');
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ خطأ تحميل البيانات المحفوظة: $e');
    }
  }

  Future<String> getDownloadDirectory() async {
    // ══ Android: يحفظ في مجلد التطبيق الداخلي ══
    // المسار: /data/data/com.example.app/files/items_offline/
    final dir = await _getItemDir();
    return dir.path;
  }

// ══ أو إذا أردت حفظه في مجلد Downloads العام ══
// يحتاج إضافة permission في AndroidManifest
  Future<String> getPublicDownloadPath(String fileName) async {
    if (Platform.isAndroid) {
      // مجلد Downloads العام
      return '/storage/emulated/0/Download/$fileName';
    } else if (Platform.isIOS) {
      // iOS لا يدعم مجلد عام - يحفظ داخل التطبيق
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  Future<void> _saveDownload(String itemId, String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('item_downloads_keys') ?? [];
      if (!keys.contains(itemId)) {
        keys.add(itemId);
        await prefs.setStringList('item_downloads_keys', keys);
      }
      await prefs.setString('item_path_$itemId', path);
    } catch (_) {}
  }

  Future<void> _removeDownload(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('item_downloads_keys') ?? [];
      keys.remove(itemId);
      await prefs.setStringList('item_downloads_keys', keys);
      await prefs.remove('item_path_$itemId');
    } catch (_) {}
  }

  // في item_download_service.dart
// أضف هذه الدالة الجديدة

  /// تحميل سورة لقارئ معين مع تنظيم المجلدات
  Future<void> downloadSurah({
    required IslamicRadioStation station,
    required int surahNumber,
    required String surahName,
  }) async {
    final audioUrl = station.surahStreamUrl(surahNumber);
    if (audioUrl == null || audioUrl.isEmpty) return;

    // إنشاء RecitationItem للتوافق مع النظام الموجود
    final item = RecitationItem(
      title: surahName,
      subtitle: station.name,
      emoji: station.iconEmoji,
      audioUrl: audioUrl,
      imageUrl: station.imageUrl,
    );

    // استخدام نفس منطق التحميل الموجود
    await downloadItem(
      item,
      customDir: '${station.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}',
      customFileName: surahName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'),
    );
  }


}

class _QueuedDownloadTask {
  final RecitationItem item;
  final String itemId;
  final String? customDir;
  final String? customFileName;

  _QueuedDownloadTask({
    required this.item,
    required this.itemId,
    this.customDir,
    this.customFileName,
  });
}