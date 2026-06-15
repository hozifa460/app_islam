import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../auth/services/auth_service.dart';
import '../services/image_cache_service.dart';

class ProfileImageProvider extends ChangeNotifier {
  final AuthService _auth;
  String? _imagePath;
  bool _initialized = false;
  bool _isUploading = false;

  ProfileImageProvider(this._auth);

  String? get imagePath {
    if (_imagePath != null && !File(_imagePath!).existsSync()) {
      _imagePath = null;
    }
    return _imagePath;
  }

  bool get hasImage => imagePath != null;
  bool get isUploading => _isUploading;

  // ═══ تهيئة ═══
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // تحميل فوري من المحلي
    final local = await ImageCacheService.getSavedPath();
    if (local != null) {
      _imagePath = local;
      notifyListeners();
      debugPrint('✅ Provider: صورة محلية موجودة');
      return;
    }

    // إذا لم توجد → حمّل من السحابة
    await _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    if (_auth.user?.isGuest ?? true) return;

    debugPrint('📥 Provider: جاري تحميل من السحابة...');
    _isUploading = true;
    notifyListeners();

    final path = await ImageCacheService.loadImage(_auth);
    _imagePath = path;
    _isUploading = false;
    notifyListeners();

    if (path != null) {
      debugPrint('✅ Provider: تم التحميل من السحابة');
    }
  }

  // ═══ أظهر الصورة فوراً (بدون await) ═══
  void setImageImmediately(String path) {
    _imagePath = path;
    notifyListeners();
  }

// ═══ عدّل updateImage - لا تنتظر ═══
  Future<void> updateImage(String sourcePath) async {
    // احفظ في الخلفية فقط
    final savedPath = await ImageCacheService.saveNewImage(
      sourcePath,
      _auth,
    );

    // حدّث بالمسار الدائم بعد الحفظ
    if (savedPath != null && savedPath != _imagePath) {
      _imagePath = savedPath;
      notifyListeners();
    }
  }

  // ═══ حذف الصورة ═══
  Future<void> removeImage() async {
    _imagePath = null;
    notifyListeners();
    await ImageCacheService.deleteImage(_auth);
  }

  // ═══ إعادة تحميل ═══
  Future<void> refresh() async {
    _imagePath = null;
    _initialized = false;
    await initialize();
  }
}