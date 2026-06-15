import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class AdhanImageCacheService {
  static final AdhanImageCacheService instance = AdhanImageCacheService._();
  AdhanImageCacheService._();

  /// مجلد حفظ الصور
  Future<Directory> _dir() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/adhan_images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// ✅ اسم موحّد للملف
  String _fileName(String id) => 'adhan_image_$id.img';

  /// ✅ ملف يحفظ الرابط المرتبط بكل id (لكشف التغيير)
  String _urlFileName(String id) => 'adhan_image_${id}_url.txt';

  /// الحصول على المسار المحلي
  Future<String?> getLocalPath(String id) async {
    final d = await _dir();
    final file = File('${d.path}/${_fileName(id)}');
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    return null;
  }

  /// هل الصورة محمّلة؟
  Future<bool> isDownloaded(String id) async {
    return (await getLocalPath(id)) != null;
  }

  /// ✅ تحميل مباشر (بدون تحقق من الكاش)
  Future<String?> download({
    required String id,
    required String url,
  }) async {
    try {
      final d = await _dir();
      final filePath = '${d.path}/${_fileName(id)}';
      final urlFilePath = '${d.path}/${_urlFileName(id)}';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      await dio.download(url, filePath);

      final file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        // ✅ احفظ الرابط أيضاً
        await File(urlFilePath).writeAsString(url);
        return file.path;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error downloading image for $id: $e');
      return null;
    }
  }

  /// ✅ الدالة الرئيسية: جلب من الكاش أو تحميل (مع كشف تغيير الرابط)
  Future<String?> getOrDownload({
    required String id,
    required String url,
  }) async {
    final d = await _dir();
    final file = File('${d.path}/${_fileName(id)}');
    final urlFile = File('${d.path}/${_urlFileName(id)}');

    // ✅ إذا الملف موجود → تحقق هل الرابط تغيّر
    if (await file.exists() && await file.length() > 0) {
      if (await urlFile.exists()) {
        final savedUrl = await urlFile.readAsString();
        if (savedUrl == url) {
          return file.path; // ✅ نفس الرابط، استخدم الكاش
        }
      }
      // ❌ الرابط تغيّر → احذف القديم
      await file.delete();
      if (await urlFile.exists()) await urlFile.delete();
    }

    // ✅ حمّل الصورة الجديدة
    return await download(id: id, url: url);
  }

  /// مسح كاش صورة معينة
  Future<void> clearCache(String id) async {
    final d = await _dir();
    final file = File('${d.path}/${_fileName(id)}');
    final urlFile = File('${d.path}/${_urlFileName(id)}');
    if (await file.exists()) await file.delete();
    if (await urlFile.exists()) await urlFile.delete();
  }

  /// مسح كل الكاش
  Future<void> clearAll() async {
    final d = await _dir();
    if (await d.exists()) {
      await d.delete(recursive: true);
      await d.create(recursive: true);
    }
  }
}