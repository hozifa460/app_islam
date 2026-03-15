import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SimpleAdhanService {
  static final SimpleAdhanService _instance = SimpleAdhanService._internal();
  factory SimpleAdhanService() => _instance;
  SimpleAdhanService._internal();

  // ✅ نسخ الملف من assets/adahn/ (مع n)
  Future<String?> getAdhanPath(String muezzinId) async {
    try {
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/adhan_$muezzinId.mp3');

      // إذا كان موجوداً، نرجعه
      if (await localFile.exists()) {
        return localFile.path;
      }

      // ✅ المحاولة 1: البحث مباشرة في assets/adahn/
      try {
        final byteData = await rootBundle.load('assets/adahn/$muezzinId.mp3');
        await localFile.writeAsBytes(byteData.buffer.asUint8List());
        print('✅ Loaded from assets/adahn/$muezzinId.mp3');
        return localFile.path;
      } catch (e) {
        print('❌ Not found: assets/adahn/$muezzinId.mp3');
      }

      // ✅ المحاولة 2: إذا كان ID = 'menshawy' والملف 'menshawy.wav'
      if (muezzinId == 'menshawy') {
        try {
          final byteData = await rootBundle.load('assets/adahn/menshawy.wav');
          await localFile.writeAsBytes(byteData.buffer.asUint8List());
          print('✅ Loaded: assets/adahn/menshawy.wav');
          return localFile.path;
        } catch (e) {
          print('❌ Not found: assets/adahn/menshawy.wav');
        }
      }

      return null;

    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
}