// lib/screens/radio/video/video_launcher.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/recitation_categories_data.dart';
import '../video_feed_screen.dart';
import '../video_player_screen.dart';

class VideoLauncher {
  VideoLauncher._();

  /// فتح فيديو واحد
  static void openSingle({
    required BuildContext context,
    required RecitationSubItem item,
    required Color primary,
  }) {
    if (item.isYouTube) {
      _openYouTube(item.videoUrl!);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          item: item,
          primary: primary,
        ),
      ),
    );
  }

  /// فتح Feed مثل TikTok
  static void openFeed({
    required BuildContext context,
    required List<RecitationSubItem> videos,
    required Color primary,
    required String categoryTitle,
    int initialIndex = 0,
  }) {
    // ✅ فلتر العناصر المرئية فقط
    final videoItems = videos.where((v) => v.hasVideo).toList();

    if (videoItems.isEmpty) return;

    // ✅ YouTube يفتح خارجياً
    // ✅ Direct videos تفتح في الـ Feed
    final directVideos = videoItems
        .where((v) => v.isDirectVideo)
        .toList();

    if (directVideos.isEmpty && videoItems.first.isYouTube) {
      _openYouTube(videoItems.first.videoUrl!);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoFeedScreen(
          videos: directVideos.isNotEmpty ? directVideos : videoItems,
          initialIndex: initialIndex.clamp(
            0,
            (directVideos.isNotEmpty ? directVideos : videoItems).length - 1,
          ),
          primary: primary,
          categoryTitle: categoryTitle,
        ),
      ),
    );
  }

  static Future<void> _openYouTube(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to open YouTube: $e');
    }
  }
}