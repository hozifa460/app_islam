import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SimpleAdhanService {
  static final SimpleAdhanService _instance = SimpleAdhanService._internal();
  factory SimpleAdhanService() => _instance;
  SimpleAdhanService._internal();

  // âœ… ظ†ط³ط® ط§ظ„ظ…ظ„ظپ ظ…ظ† assets/adahn/ (ظ…ط¹ n)
  Future<String?> getAdhanPath(String muezzinId) async {
    try {
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/adhan_$muezzinId.mp3');

      // ط¥ط°ط§ ظƒط§ظ† ظ…ظˆط¬ظˆط¯ط§ظ‹طŒ ظ†ط±ط¬ط¹ظ‡
      if (await localFile.exists()) {
        return localFile.path;
      }

      // âœ… ط§ظ„ظ…ط­ط§ظˆظ„ط© 1: ط§ظ„ط¨ط­ط« ظ…ط¨ط§ط´ط±ط© ظپظٹ assets/adahn/
      try {
        final byteData = await rootBundle.load('assets/adahn/$muezzinId.mp3');
        await localFile.writeAsBytes(byteData.buffer.asUint8List());
        debugPrint('✅ Loaded from assets/adahn/$muezzinId.mp3');
        return localFile.path;
      } catch (e) {
        debugPrint('❌ Not found: assets/adahn/$muezzinId.mp3');
      }

      // âœ… ط§ظ„ظ…ط­ط§ظˆظ„ط© 2: ط¥ط°ط§ ظƒط§ظ† ID = 'menshawy' ظˆط§ظ„ظ…ظ„ظپ 'menshawy.mp3'
      if (muezzinId == 'menshawy') {
        try {
          final byteData = await rootBundle.load('assets/adahn/menshawy.mp3');
          await localFile.writeAsBytes(byteData.buffer.asUint8List());
          debugPrint('✅ Loaded: assets/adahn/menshawy.mp3');
          return localFile.path;
        } catch (e) {
          debugPrint('❌ Not found: assets/adahn/menshawy.mp3');
        }
      }

      return null;

    } catch (e) {
      debugPrint('❌ Error: $e');
      return null;
    }
  }
}