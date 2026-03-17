import '../data/prayer/muezzin_catalog.dart';
import 'adhan_image_cache_service.dart';

class AdhanImagePreloadService {
  static Future<bool> preloadAllImages() async {
    bool allSuccess = true;

    for (final category in muezzinCatalog) {
      for (final m in category.items) {
        if (m.imageUrl.isEmpty) continue;

        final path = await AdhanImageCacheService.instance.getOrDownload(
          id: m.id,
          url: m.imageUrl,
        );

        if (path == null || path.isEmpty) {
          allSuccess = false;
        }
      }
    }

    return allSuccess;
  }
}