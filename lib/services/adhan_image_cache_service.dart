import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdhanImageCacheService {
  static final AdhanImageCacheService instance = AdhanImageCacheService._();
  AdhanImageCacheService._();

  Future<Directory> _dir() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/adhan_images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileName(String id) => 'adhan_image_$id.img';

  Future<String?> getLocalPath(String id) async {
    final d = await _dir();
    final path = '${d.path}/${_fileName(id)}';
    final file = File(path);

    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    return null;
  }

  Future<bool> isDownloaded(String id) async {
    return (await getLocalPath(id)) != null;
  }

  Future<String?> download({
    required String id,
    required String url,
  }) async {
    try {
      final d = await _dir();
      final filePath = '${d.path}/${_fileName(id)}';
      final file = File(filePath);

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      await dio.download(url, filePath);

      if (await file.exists() && await file.length() > 0) {
        return file.path;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getOrDownload({
    required String id,
    required String url,
  }) async {
    final existing = await getLocalPath(id);
    if (existing != null) return existing;

    return await download(id: id, url: url);
  }

  Future<void> clearAll() async {
    final d = await _dir();
    if (await d.exists()) {
      await d.delete(recursive: true);
      await d.create(recursive: true);
    }
  }
}