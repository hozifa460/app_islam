import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class VideoSortHelper {
  static List<YoutubeVideo> sortRegularForDisplay(List<YoutubeVideo> videos) {
    final list = List<YoutubeVideo>.from(videos);

    list.sort((a, b) {
      final aCompleted = VideoHistoryService.isCompleted(a.id);
      final bCompleted = VideoHistoryService.isCompleted(b.id);

      final aPartial = VideoHistoryService.isPartiallyWatched(a.id);
      final bPartial = VideoHistoryService.isPartiallyWatched(b.id);

      if (aPartial != bPartial) return aPartial ? -1 : 1;
      if (aCompleted != bCompleted) return aCompleted ? 1 : -1;

      final dateCompare = b.publishedAt.compareTo(a.publishedAt);
      if (dateCompare != 0) return dateCompare;

      final vA = int.tryParse(a.viewCount) ?? 0;
      final vB = int.tryParse(b.viewCount) ?? 0;
      return vB.compareTo(vA);
    });

    return list;
  }

  static List<YoutubeVideo> sortShortsForDisplay(List<YoutubeVideo> videos) {
    final list = List<YoutubeVideo>.from(videos);

    list.sort((a, b) {
      final aCompleted = VideoHistoryService.isCompleted(a.id);
      final bCompleted = VideoHistoryService.isCompleted(b.id);

      if (aCompleted != bCompleted) {
        return aCompleted ? 1 : -1;
      }

      return b.publishedAt.compareTo(a.publishedAt);
    });

    return list;
  }

  static List<YoutubeVideo> sortLiveForDisplay(List<YoutubeVideo> videos) {
    final list = List<YoutubeVideo>.from(videos);
    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return list;
  }
}