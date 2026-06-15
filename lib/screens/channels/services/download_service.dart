import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../services/youtube_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  خدمة تحميل الفيديوهات
/// ═══════════════════════════════════════════════════════════════
class DownloadService {
  static final Dio _dio = Dio();
  static final Map<String, DownloadTask> _activeDownloads = {};

  /// الحصول على مسار التحميل
  static Future<String> get _downloadPath async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir?.path}/IslamicChannels');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    }
  }

  /// التحقق من الأذونات
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// تحميل صورة مصغرة
  static Future<String?> downloadThumbnail(YoutubeVideo video) async {
    try {
      if (!await _requestPermissions()) {
        debugPrint('❌ Storage permission denied');
        return null;
      }

      final path = await _downloadPath;
      final fileName = 'thumb_${video.id}.jpg';
      final filePath = '$path/$fileName';

      // التحقق إذا كانت موجودة
      if (await File(filePath).exists()) {
        return filePath;
      }

      await _dio.download(
        video.thumbnail,
        filePath,
      );

      debugPrint('✅ Thumbnail downloaded: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Thumbnail download error: $e');
      return null;
    }
  }

  /// تحميل فيديو (يحتاج خدمة خارجية)
  static Future<DownloadTask?> downloadVideo({
    required YoutubeVideo video,
    required Function(double) onProgress,
    required Function(String) onComplete,
    required Function(String) onError,
  }) async {
    try {
      if (!await _requestPermissions()) {
        onError('لم يتم منح إذن التخزين');
        return null;
      }

      // ملاحظة: تحميل فيديوهات YouTube يحتاج خدمة خارجية
      // هنا نوفر الهيكل فقط

      final task = DownloadTask(
        videoId: video.id,
        title: video.title,
        status: DownloadStatus.pending,
      );

      _activeDownloads[video.id] = task;

      // محاكاة التحميل (استبدل بالتنفيذ الفعلي)
      task.status = DownloadStatus.downloading;

      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        task.progress = i / 100;
        onProgress(task.progress);
      }

      task.status = DownloadStatus.completed;
      onComplete('تم تحميل الفيديو بنجاح');

      return task;
    } catch (e) {
      onError('فشل التحميل: $e');
      return null;
    }
  }

  /// إلغاء التحميل
  static void cancelDownload(String videoId) {
    final task = _activeDownloads[videoId];
    if (task != null) {
      task.cancelToken?.cancel('Cancelled by user');
      task.status = DownloadStatus.cancelled;
      _activeDownloads.remove(videoId);
    }
  }

  /// الحصول على التحميلات النشطة
  static List<DownloadTask> get activeDownloads => _activeDownloads.values.toList();

  /// التحقق إذا كان الفيديو محمّل
  static Future<bool> isVideoDownloaded(String videoId) async {
    final path = await _downloadPath;
    final file = File('$path/video_$videoId.mp4');
    return file.exists();
  }

  /// حذف فيديو محمّل
  static Future<void> deleteDownload(String videoId) async {
    final path = await _downloadPath;
    final file = File('$path/video_$videoId.mp4');
    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑️ Deleted: video_$videoId.mp4');
    }
  }

  /// حجم التحميلات
  static Future<int> getDownloadsSize() async {
    final path = await _downloadPath;
    final dir = Directory(path);

    if (!await dir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  /// تنسيق الحجم
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// ═══════════════════════════════════════════════════════════════
///  نموذج مهمة التحميل
/// ═══════════════════════════════════════════════════════════════
class DownloadTask {
  final String videoId;
  final String title;
  DownloadStatus status;
  double progress;
  String? filePath;
  CancelToken? cancelToken;

  DownloadTask({
    required this.videoId,
    required this.title,
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.filePath,
  }) {
    cancelToken = CancelToken();
  }
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}