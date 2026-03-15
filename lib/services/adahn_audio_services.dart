import 'dart:io';
import 'package:http/http.dart' as http;
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

  Future<bool> isDownloaded(String id) async => (await getLocalPath(id)) != null;

  /// تحميل mp3 وتخزينه محليًا
  Future<String?> download({
    required String id,
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final d = await _dir();
      final file = File('${d.path}/${_fileName(id)}');

      final req = http.Request('GET', Uri.parse(url));
      final res = await http.Client().send(req);

      if (res.statusCode != 200) return null;

      final total = res.contentLength ?? 0;
      var received = 0;

      final sink = file.openWrite();
      await for (final chunk in res.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.flush();
      await sink.close();

      onProgress?.call(1.0);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}