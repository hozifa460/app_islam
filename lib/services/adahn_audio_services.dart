import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdhanAudioService {
  static final AdhanAudioService instance = AdhanAudioService._();
  AdhanAudioService._();

  Future<Directory> _dir() async => getApplicationDocumentsDirectory();

  String _fileName(String id) => 'adhan_$id.mp3';

  Future<String?> getLocalPath(String id) async {
    final d = await _dir();
    final file = File('${d.path}/${_fileName(id)}');
    return (await file.exists()) ? file.path : null;
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

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(received / total);
          }
        },
      );

      return filePath;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteDownloaded(String id) async {
    final d = await _dir();
    final file = File('${d.path}/${_fileName(id)}');
    if (await file.exists()) {
      await file.delete();
    }
  }
}