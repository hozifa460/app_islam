import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

class ImageCacheService {
  static const _kImagePath = 'profile_image_path';
  static const _kBase64Key = 'profile_image_base64';

  // ═══ المسار الدائم ═══
  static Future<String> _permanentPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/profile_photo.jpg';
  }

  // ═══════════════════════════════════════════
  // حفظ صورة جديدة - فوري ومضمون
  // ═══════════════════════════════════════════
  static Future<String?> saveNewImage(
      String sourcePath,
      AuthService auth,
      ) async {
    try {
      final dest = await _permanentPath();

      // احذف القديمة
      final old = File(dest);
      if (old.existsSync()) await old.delete();

      // انسخ الجديدة
      final saved = await File(sourcePath).copy(dest);

      // احفظ المسار
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kImagePath, saved.path);

      debugPrint('✅ حُفظت الصورة محلياً: ${saved.path}');

      // ارفع للسحابة
      if (!(auth.user?.isGuest ?? true)) {
        await _uploadToCloud(saved.path, auth);
      }

      return saved.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ الصورة: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // رفع للسحابة - ينتظر حتى ينتهي
  // ═══════════════════════════════════════════
  static Future<bool> _uploadToCloud(
      String path,
      AuthService auth,
      ) async {
    try {
      final bytes = await File(path).readAsBytes();
      final base64Str = base64Encode(bytes);

      if (base64Str.length > 900000) {
        debugPrint('❌ الصورة كبيرة جداً للسحابة');
        return false;
      }

      // احفظ في Firestore مباشرة
      await auth.saveProgress(_kBase64Key, base64Str);
      debugPrint('✅ تم رفع الصورة للسحابة بنجاح');
      return true;
    } catch (e) {
      debugPrint('❌ فشل رفع الصورة: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // تحميل الصورة - محلي ثم سحابي
  // ═══════════════════════════════════════════
  static Future<String?> loadImage(AuthService auth) async {
    // 1. تحقق من المكان الدائم أولاً
    final dest = await _permanentPath();
    if (File(dest).existsSync()) {
      debugPrint('✅ وُجدت الصورة محلياً');
      return dest;
    }

    // 2. تحقق من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kImagePath);
    if (saved != null && File(saved).existsSync()) {
      // انسخها للمكان الدائم
      await File(saved).copy(dest);
      debugPrint('✅ نُسخت الصورة للمكان الدائم');
      return dest;
    }

    // 3. حمّل من السحابة
    if (auth.user?.isGuest ?? true) return null;

    debugPrint('📥 جاري تحميل الصورة من السحابة...');
    try {
      final base64Str = await auth.loadProgress(_kBase64Key);

      if (base64Str == null || base64Str.toString().isEmpty) {
        debugPrint('⚠️ لا توجد صورة في السحابة');
        return null;
      }

      // حوّل Base64 لملف
      final bytes = base64Decode(base64Str.toString());
      final file = File(dest);
      await file.writeAsBytes(bytes);

      await prefs.setString(_kImagePath, dest);
      debugPrint('✅ تم تحميل الصورة من السحابة');
      return dest;
    } catch (e) {
      debugPrint('❌ فشل تحميل الصورة من السحابة: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // حذف الصورة
  // ═══════════════════════════════════════════
  static Future<void> deleteImage(AuthService auth) async {
    try {
      final dest = await _permanentPath();
      if (File(dest).existsSync()) await File(dest).delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kImagePath);

      if (!(auth.user?.isGuest ?? true)) {
        await auth.saveProgress(_kBase64Key, '');
      }
      debugPrint('✅ تم حذف الصورة');
    } catch (e) {
      debugPrint('❌ فشل حذف الصورة: $e');
    }
  }

  // ═══ الحصول على المسار المحفوظ فوراً ═══
  static Future<String?> getSavedPath() async {
    final dest = await _permanentPath();
    if (File(dest).existsSync()) return dest;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kImagePath);
    if (saved != null && File(saved).existsSync()) return saved;

    return null;
  }
}