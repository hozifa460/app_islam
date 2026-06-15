import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' hide CacheManager;
import 'package:islamic_app/screens/channels/helpers/performance_monitor.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import '../cache/cache_manager.dart' as app_cache;
import '../cache/image_cache_config.dart';
import '../services/channels_prefetch_service.dart';
import '../services/youtube_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  تهيئة التطبيق وإعدادات الأداء
/// ═══════════════════════════════════════════════════════════════
class AppInitializer {
  static bool _initialized = false;

  /// تهيئة التطبيق (استدعها في main.dart)
  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🚀 Initializing app...');

    // 1) تنظيف كاش flutter_cache_manager الافتراضي
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      debugPrint('⚠️ Default image cache clear failed: $e');
    }

    // 2) تنظيف كاش الصور المخصص لدينا
    try {
      await ImageCacheConfig.clearCache();
    } catch (e) {
      debugPrint('⚠️ Custom image cache clear failed: $e');
    }

    // 3) تهيئة إعدادات كاش الصور
    ImageCacheConfig.configure();

    // 4) تهيئة مدير الكاش الداخلي للتطبيق
    final cache = await app_cache.CacheManager.getInstance();
    await cache.clearExpired();

    // 5) تهيئة history/progress
    await VideoHistoryService.init();

    // 6) تهيئة usage signals
    await ChannelUsageService.init();

    // 7) بدء prefetch خفيف للقنوات في الخلفية
    Future.microtask(() async {
      try {
        await ChannelsPrefetchService.prefetchIfNeeded();
      } catch (e) {
        debugPrint('❌ Channels prefetch init error: $e');
      }
    });

    // 8) بدء مراقبة الأداء (Debug فقط)
    if (kDebugMode) {
      PerformanceMonitor.instance.startMonitoring();
    }

    _initialized = true;
    debugPrint('✅ App initialized');
  }

  /// تنظيف عند إغلاق التطبيق
  static Future<void> cleanup() async {
    PerformanceMonitor.instance.stopMonitoring();
    YoutubeService.clearMemoryCache();
    debugPrint('🧹 App cleanup done');
  }
}