
// lib/screens/radio/video/video_download_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VideoDownloadStatus { none, downloading, downloaded, error }

class VideoDownloadInfo {
  VideoDownloadStatus status;
  double progress;
  String? localPath;
  String? error;

  VideoDownloadInfo({
    this.status = VideoDownloadStatus.none,
    this.progress = 0,
    this.localPath,
    this.error,
  });
}

class VideoDownloadService extends ChangeNotifier {
  static final VideoDownloadService _instance =
  VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  final Map<String, VideoDownloadInfo> _downloads = {};
  final Map<String, bool> _cancelFlags = {};
  final Map<String, double> _lastNotifiedProgress = {};

  VideoDownloadInfo? getInfo(String videoId) => _downloads[videoId];

  VideoDownloadStatus getStatus(String videoId) =>
      _downloads[videoId]?.status ?? VideoDownloadStatus.none;

  double getProgress(String videoId) =>
      _downloads[videoId]?.progress ?? 0;

  bool isDownloaded(String videoId) =>
      _downloads[videoId]?.status == VideoDownloadStatus.downloaded;

  String? getLocalPath(String videoId) =>
      _downloads[videoId]?.localPath;

  static String videoIdFromUrl(String url) {
    int hash = 5381;
    for (int i = 0; i < url.length; i++) {
      hash = ((hash << 5) + hash) + url.codeUnitAt(i);
      hash &= 0x7FFFFFFF;
    }
    return 'v_$hash';
  }

  // ══════════════════════════════════════════════════════
  // تهيئة
  // ══════════════════════════════════════════════════════

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('video_downloads_keys') ?? [];

      for (final key in keys) {
        final path = prefs.getString('video_path_$key');
        if (path != null) {
          final file = File(path);
          if (await file.exists() && await file.length() > 1000) {
            _downloads[key] = VideoDownloadInfo(
              status: VideoDownloadStatus.downloaded,
              progress: 1.0,
              localPath: path,
            );
          } else {
            await prefs.remove('video_path_$key');
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ VideoDownloadService init: $e');
    }
  }

  // ══════════════════════════════════════════════════════
  // تحميل
  // ══════════════════════════════════════════════════════

  Future<void> downloadVideo({
    required String videoUrl,
    required String title,
    String? customDir,
  }) async {
    final videoId = videoIdFromUrl(videoUrl);

    if (_downloads[videoId]?.status == VideoDownloadStatus.downloading) {
      return;
    }

    _cancelFlags[videoId] = false;
    _downloads[videoId] = VideoDownloadInfo(
      status: VideoDownloadStatus.downloading,
    );
    notifyListeners();

    try {
      final dir = await _getVideoDir(customDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final safeName = title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .trim();

      final fileName =
      safeName.isNotEmpty ? '$safeName.mp4' : '$videoId.mp4';
      final file = File('${dir.path}/$fileName');

      if (await file.exists() && await file.length() > 1000) {
        _downloads[videoId] = VideoDownloadInfo(
          status: VideoDownloadStatus.downloaded,
          progress: 1.0,
          localPath: file.path,
        );
        await _saveDownload(videoId, file.path);
        notifyListeners();
        return;
      }

      final request = http.Request('GET', Uri.parse(videoUrl));
      request.headers.addAll({
        'User-Agent': 'Mozilla/5.0',
        'Accept': '*/*',
      });

      final client = http.Client();
      try {
        final response = await client.send(request).timeout(
          const Duration(minutes: 30),
        );

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;

        final sink = file.openWrite();

        await for (final chunk in response.stream) {
          if (_cancelFlags[videoId] == true) {
            await sink.flush();
            await sink.close();
            if (await file.exists()) await file.delete();
            _downloads[videoId]!.status = VideoDownloadStatus.none;
            _downloads[videoId]!.progress = 0;
            _cancelFlags.remove(videoId);
            _lastNotifiedProgress.remove(videoId);
            notifyListeners();
            return;
          }

          receivedBytes += chunk.length;
          sink.add(chunk);

          if (totalBytes > 0) {
            final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
            final lastNotified = _lastNotifiedProgress[videoId] ?? -1.0;
            if (progress - lastNotified >= 0.01 || progress >= 1.0) {
              _downloads[videoId]!.progress = progress;
              _lastNotifiedProgress[videoId] = progress;
              notifyListeners();
            }
          }
        }

        await sink.flush();
        await sink.close();
      } finally {
        client.close();
      }

      _downloads[videoId] = VideoDownloadInfo(
        status: VideoDownloadStatus.downloaded,
        progress: 1.0,
        localPath: file.path,
      );

      await _saveDownload(videoId, file.path);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Video download error: $e');
      if (_cancelFlags[videoId] != true) {
        _downloads[videoId] = VideoDownloadInfo(
          status: VideoDownloadStatus.error,
          error: e.toString(),
        );
      }
      _cancelFlags.remove(videoId);
      _lastNotifiedProgress.remove(videoId);
      notifyListeners();
    }
  }

  void cancelDownload(String videoId) {
    _cancelFlags[videoId] = true;
  }

  Future<void> deleteDownload(String videoId) async {
    final path = _downloads[videoId]?.localPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    _downloads.remove(videoId);
    _cancelFlags.remove(videoId);
    _lastNotifiedProgress.remove(videoId);
    await _removeDownload(videoId);
    notifyListeners();
  }

  Future<String> getFileSize(String videoId) async {
    final path = _downloads[videoId]?.localPath;
    if (path == null) return '0 MB';
    final file = File(path);
    if (!await file.exists()) return '0 MB';
    final bytes = await file.length();
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<Directory> _getVideoDir([String? customDir]) async {
    if (Platform.isAndroid) {
      final base = Directory('/storage/emulated/0/Download/مرئيات');
      if (customDir != null) {
        return Directory('${base.path}/$customDir');
      }
      return base;
    }
    final base = await getApplicationDocumentsDirectory();
    if (customDir != null) {
      return Directory('${base.path}/videos_offline/$customDir');
    }
    return Directory('${base.path}/videos_offline');
  }

  Future<void> _saveDownload(String videoId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('video_downloads_keys') ?? [];
    if (!keys.contains(videoId)) {
      keys.add(videoId);
      await prefs.setStringList('video_downloads_keys', keys);
    }
    await prefs.setString('video_path_$videoId', path);
  }

  Future<void> _removeDownload(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('video_downloads_keys') ?? [];
    keys.remove(videoId);
    await prefs.setStringList('video_downloads_keys', keys);
    await prefs.remove('video_path_$videoId');
  }
}