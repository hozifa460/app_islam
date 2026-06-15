import 'package:flutter/material.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/shorts_player_screen.dart';
import 'package:islamic_app/screens/channels/video_player_screen.dart';

class VideoNavigationHelper {
  static Future<void> openVideo({
    required BuildContext context,
    required YoutubeVideo video,
    required List<YoutubeVideo> shortsList,
    required String publishedAtText,
  }) async {
    final isShort = YoutubeService.isLikelyShortVideo(video);

    if (isShort) {
      final source = shortsList.isNotEmpty ? shortsList : [video];
      final index = source.indexWhere((v) => v.id == video.id);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShortsPlayerScreen(
            shorts: source,
            initialIndex: index >= 0 ? index : 0,
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: publishedAtText,
        ),
      ),
    );
  }
}