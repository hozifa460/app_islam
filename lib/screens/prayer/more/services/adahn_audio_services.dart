import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class AdhanAudioService {
  static final AdhanAudioService instance = AdhanAudioService._();
  AdhanAudioService._();

  Future<Directory> _dir() async => getApplicationDocumentsDirectory();

  String _fileName(String id) => 'adhan_$id.mp3';

  Future<String?> getLocalPath(String id) async {
    try {
      final d = await _dir();
      final file = File('${d.path}/${_fileName(id)}');
      return (await file.exists()) ? file.path : null;
    } catch (e) {
      debugPrint('❌ Error getting local path for $id: $e');
      return null;
    }
  }

  Future<bool> isDownloaded(String id) async {
    return (await getLocalPath(id)) != null;
  }

  Future<String?> download({
    required String id,
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final d = await _dir();
      final filePath = '${d.path}/${_fileName(id)}';

      debugPrint('⬇️ Downloading: $url');
      debugPrint('📁 Saving to: $filePath');

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      debugPrint('✅ Download complete: $id');
      return filePath;
    } catch (e) {
      debugPrint('❌ Download error for $id: $e');
      return null;
    }
  }

  /// ✅ جديد: دالة مختصرة للتحميل والحفظ
  Future<String?> downloadAndSave(String id, String url) async {
    final existing = await getLocalPath(id);
    if (existing != null) {
      debugPrint('✅ Already downloaded: $id');
      return existing;
    }
    return download(id: id, url: url);
  }

  Future<void> deleteDownloaded(String id) async {
    try {
      final d = await _dir();
      final file = File('${d.path}/${_fileName(id)}');
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted: $id');
      }
    } catch (e) {
      debugPrint('❌ Error deleting $id: $e');
    }
  }

  /// ✅ جديد: حذف جميع ملفات الأذان
  Future<void> deleteAllDownloaded() async {
    try {
      final d = await _dir();
      final files = d.listSync();
      for (final file in files) {
        if (file.path.contains('adhan_') && file.path.endsWith('.mp3')) {
          await File(file.path).delete();
        }
      }
    } catch (e) {
      debugPrint('❌ Error deleting all: $e');
    }
  }
}