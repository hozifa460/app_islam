// lib/screens/radio/video/video_feed_tab.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/video/services/video_cache_manager.dart';
import 'package:islamic_app/screens/radio/video/services/video_download_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_watch_history_service.dart';
import 'package:islamic_app/screens/radio/video/widgets/smart_video_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../data/recitation_categories_data.dart';
import '../services/listening_history_service.dart';
import '../widgets/radio_image_widget.dart';
import 'helpers/video_launcher.dart';
import 'helpers/video_recommendation_engine.dart';
import 'video_feed_screen.dart';

class VideoFeedTab extends StatefulWidget {
  final Color primary;

  const VideoFeedTab({
    super.key,
    required this.primary,
  });

  @override
  State<VideoFeedTab> createState() => _VideoFeedTabState();
}

class _VideoFeedTabState extends State<VideoFeedTab>
    with AutomaticKeepAliveClientMixin {

  late List<RecitationCategory> _categories;
  List<_VideoSection> _sections = [];
  List<RecitationSubItem> _forYouVideos = [];
  bool _built = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // âœ… ط£ط¬ظ‘ظ„ ظƒظ„ ط´ظٹط، ط«ظ‚ظٹظ„ ط­طھظ‰ ط¨ط¹ط¯ ط±ط³ظ… ط§ظ„ط´ط§ط´ط©
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _categories = RecitationCategoriesData.build();
      _buildContent();
      setState(() {});
      _preloadFirstVideos();
    });
  }

  void _buildContent() {
    _sections = [];

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // 1) ط¨ظ†ط§ط، ط§ظ„ط£ظ‚ط³ط§ظ… ط§ظ„ط¹ط§ط¯ظٹط©
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    for (final cat in _categories) {
      final videoItems = <_VideoEntry>[];

      for (final item in cat.items) {
        if (item.hasVideo) {
          videoItems.add(_VideoEntry(
            title: item.title,
            subtitle: item.subtitle,
            emoji: item.emoji,
            imageUrl: item.imageUrl,
            videoUrl: item.videoUrl!,
            videoSource: item.videoSource ?? VideoSource.direct,
            subItem: RecitationSubItem(
              title: item.title,
              subtitle: item.subtitle,
              emoji: item.emoji,
              audioUrl: item.audioUrl ?? '',
              imageUrl: item.imageUrl,
              videoUrl: item.videoUrl,
              videoSource: item.videoSource,
              mediaType: item.mediaType,
            ),
          ));
        }

        for (final sub in item.allSubItems) {
          if (sub.hasVideo) {
            videoItems.add(_VideoEntry(
              title: sub.title,
              subtitle: '${item.title} • ${sub.subtitle}',
              emoji: sub.emoji,
              imageUrl: sub.imageUrl ?? item.imageUrl,
              videoUrl: sub.videoUrl!,
              videoSource: sub.videoSource ?? VideoSource.direct,
              subItem: sub,
            ));
          }
        }
      }

      if (videoItems.isNotEmpty) {
        _sections.add(_VideoSection(
          title: cat.title,
          emoji: cat.emoji,
          gradientColors: cat.gradientColors,
          videos: videoItems,
        ));
      }
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // 2) ط¨ظ†ط§ط، "ظ„ظƒ" ط¨ط§ظ„طھظˆطµظٹط§طھ ط§ظ„ط°ظƒظٹط©
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    _buildForYou();

    _built = true;
  }

  void _buildForYou() {
    final watchHistory = VideoWatchHistoryService();
    final listenHistory = context.read<ListeningHistoryService>();

    final scored = VideoRecommendationEngine.recommend(
      categories: _categories,
      watchHistory: watchHistory,
      listenHistory: listenHistory,
    );

    _forYouVideos = scored.map((s) => s.subItem).toList();
  }

  void _refreshForYou() {
    setState(() {
      _buildForYou();
    });
  }

  void _preloadFirstVideos() {
    // âœ… ط¬ظ…ط¹ ط£ظˆظ„ 3 ظپظٹط¯ظٹظˆظ‡ط§طھ ظ…ط¨ط§ط´ط±ط© ظ…ظ† ظƒظ„ ط§ظ„ط£ظ‚ط³ط§ظ…
    final urls = <String>[];

    for (final section in _sections) {
      for (final entry in section.directVideos) {
        if (urls.length >= 3) break;
        urls.add(entry.videoUrl);
      }
      if (urls.length >= 3) break;
    }

    // âœ… ط£ط¶ظپ ط£ظˆظ„ 2 ظ…ظ† "ظ„ظƒ" ط¥ط°ط§ ظ„ظ… ظ†طµظ„ 3
    for (final video in _forYouVideos) {
      if (urls.length >= 3) break;
      if (video.videoUrl != null &&
          video.videoUrl!.isNotEmpty &&
          !video.isYouTube &&
          !urls.contains(video.videoUrl)) {
        urls.add(video.videoUrl!);
      }
    }

    // âœ… ط­ظ…ظ‘ظ„ظ‡ظ… ظپظٹ ط§ظ„ط®ظ„ظپظٹط© ط¨ط¯ظˆظ† ط§ظ†طھط¸ط§ط±
    final cacheManager = VideoCacheManager();
    for (final url in urls) {
      cacheManager.ensureController(url).catchError((e) {
        debugPrint('⚠️ Preload failed: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasVideos = _sections.isNotEmpty || _forYouVideos.isNotEmpty;

    if (!hasVideos) return _buildEmpty(isDark);

    return RefreshIndicator(
      onRefresh: () async {
        _refreshForYou();
      },
      color: widget.primary,
      child: ListView(
        key: const PageStorageKey('video-feed-tab'),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          // âœ… ظ‚ط³ظ… "ظ„ظƒ" - ط§ظ„طھظˆطµظٹط§طھ ط§ظ„ط°ظƒظٹط©
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          if (_forYouVideos.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildForYouSection(isDark),
          ],

          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          // âœ… ط´ط§ظ‡ط¯ ط§ظ„ظƒظ„ ظƒظ€ Feed
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          if (_forYouVideos.length > 3) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openFeed(_forYouVideos, 'مقترحة لك');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primary,
                        widget.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'شاهد الكل (${_forYouVideos.length})',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          // âœ… ط§ظ„ط£ظ‚ط³ط§ظ…
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          ..._sections.map((s) => _buildSection(s, isDark)),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… ظ‚ط³ظ… "ظ„ظƒ"
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildForYouSection(bool isDark) {
    final displayVideos = _forYouVideos.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // âœ… ط¹ظ†ظˆط§ظ† ط§ظ„ظ‚ط³ظ…
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.primary, widget.primary.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مقترحة لك',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'بناءً على اهتماماتك',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              // âœ… ط²ط± طھط­ط¯ظٹط«
              GestureDetector(
                onTap: _refreshForYou,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: widget.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // âœ… ط§ظ„ظپظٹط¯ظٹظˆظ‡ط§طھ
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 16),
            itemCount: displayVideos.length,
            itemBuilder: (_, i) => _VideoCard(
              subItem: displayVideos[i],
              subtitle: '',
              primary: widget.primary,
              isDark: isDark,
              allVideos: _forYouVideos,
              indexInList: i,
              sectionTitle: 'مقترحة لك',
            ),
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… ظ‚ط³ظ… ط¹ط§ط¯ظٹ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildSection(_VideoSection section, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // âœ… ط¹ظ†ظˆط§ظ†
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: section.gradientColors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    section.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${section.videos.length} مقطع مرئي',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              if (section.directVideos.length > 1)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _openFeed(
                      section.directVideos.map((e) => e.subItem).toList(),
                      section.title,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_rounded,
                          size: 14,
                          color: widget.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'شاهد الكل',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // âœ… ط§ظ„ط¨ط·ط§ظ‚ط§طھ
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 16),
            itemCount: section.videos.length,
            itemBuilder: (_, i) => _VideoCard(
              subItem: section.videos[i].subItem,
              subtitle: section.videos[i].subtitle,
              primary: widget.primary,
              isDark: isDark,
              allVideos: section.directVideos
                  .map((e) => e.subItem)
                  .toList(),
              indexInList: i,
              sectionTitle: section.title,
            ),
          ),
        ),
      ],
    );
  }

  void _openFeed(List<RecitationSubItem> videos, String title) {
    final directVideos = videos
        .where((v) => v.hasVideo && !v.isYouTube)
        .toList();

    if (directVideos.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoFeedScreen(
          videos: directVideos,
          primary: widget.primary,
          categoryTitle: title,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 14),
          Text(
            'لا توجد مقاطع مرئية حالياً',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سيتم إضافة تلاوات مرئية قريباً',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط¨ط·ط§ظ‚ط© ظپظٹط¯ظٹظˆ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _VideoCard extends StatelessWidget {
  final RecitationSubItem subItem;
  final String subtitle;
  final Color primary;
  final bool isDark;
  final List<RecitationSubItem> allVideos;
  final int indexInList;
  final String sectionTitle;

  const _VideoCard({
    required this.subItem,
    required this.subtitle,
    required this.primary,
    required this.isDark,
    required this.allVideos,
    required this.indexInList,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final videoId =
    VideoDownloadService.videoIdFromUrl(subItem.videoUrl ?? '');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();

        if (subItem.isYouTube) {
          VideoLauncher.openSingle(
            context: context,
            item: subItem,
            primary: primary,
          );
        } else if (allVideos.length > 1) {
          final directVideos = allVideos
              .where((v) => v.hasVideo && !v.isYouTube)
              .toList();

          final adjustedIndex = indexInList.clamp(
            0,
            directVideos.isEmpty ? 0 : directVideos.length - 1,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoFeedScreen(
                videos: directVideos.isNotEmpty ? directVideos : [subItem],
                initialIndex: adjustedIndex,
                primary: primary,
                categoryTitle: sectionTitle,
              ),
            ),
          );
        } else {
          VideoLauncher.openSingle(
            context: context,
            item: subItem,
            primary: primary,
          );
        }
      },
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // âœ… ط§ظ„طµظˆط±ط©
            Expanded(
              child: Stack(
                children: [
                  // ط§ظ„طµظˆط±ط©
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      child: SmartVideoThumbnail(
                        imageUrl: subItem.imageUrl,
                        videoUrl: subItem.videoUrl,
                        emoji: subItem.emoji,
                        primary: primary,
                        size: 165,
                        borderRadius: BorderRadius.circular(14),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // طھط¯ط±ط¬
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14),
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // âœ… ط²ط± ط§ظ„طھط´ط؛ظٹظ„
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  // âœ… ط´ط§ط±ط© ط§ظ„ظ†ظˆط¹
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            subItem.isYouTube
                                ? Icons.smart_display_rounded
                                : Icons.videocam_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            subItem.isYouTube ? 'YouTube' : 'مرئي',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // âœ… ط´ط§ط±ط© ظ…ط­ظ…ظ‘ظ„
                  Selector<VideoDownloadService, bool>(
                    selector: (_, dl) => dl.isDownloaded(videoId),
                    builder: (_, isDownloaded, __) {
                      if (!isDownloaded) return const SizedBox.shrink();

                      return Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_done_rounded,
                                size: 9,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'محمّل',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // âœ… ط§ظ„ط¹ظ†ظˆط§ظ†
            Text(
              subItem.title,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            Text(
              subtitle.isNotEmpty ? subtitle : subItem.subtitle,
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.2),
            primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subItem.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Icon(
              Icons.videocam_rounded,
              color: primary.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String? videoUrl;
  final String? imageUrl;
  final String emoji;
  final Color primary;

  const _VideoThumbnail({
    required this.videoUrl,
    required this.imageUrl,
    required this.emoji,
    required this.primary,
  });

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _thumbController;
  bool _ready = false;
  bool _loading = false;
  bool _createdLocally = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void dispose() {
    if (_thumbController != null && _createdLocally) {
      _thumbController?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) return;

    final url = widget.videoUrl;
    if (url == null || url.isEmpty) return;
    if (_loading) return;
    _loading = true;

    final cacheManager = VideoCacheManager();

    // âœ… 1. ظ…ظ† ط§ظ„ظƒط§ط´ (ظپظˆط±ظٹ)
    if (cacheManager.isInitialized(url)) {
      final controller = cacheManager.getController(url);
      if (controller != null && mounted) {
        setState(() {
          _thumbController = controller;
          _ready = true;
        });
      }
      return;
    }

    // âœ… 2. ط­ط¯ط¯ ط§ظ„ظ…طµط¯ط± (ظ…ط­ظ„ظٹ ط£ظˆ ط´ط¨ظƒط©)
    final localPath = _getLocalPath(url);
    VideoPlayerController controller;

    if (localPath != null) {
      controller = VideoPlayerController.file(File(localPath));
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Accept': '*/*',
        },
      );
    }

    try {
      await controller.initialize();
      if (!mounted) { controller.dispose(); return; }

      // âœ… 3. ط§ط°ظ‡ط¨ ظ„ظ„ط«ط§ظ†ظٹط© 3 ط¨ط¯ظ„ ط£ظˆظ„ frame (ظ„طھط¬ظ†ط¨ ط§ظ„ط´ط§ط´ط© ط§ظ„ط³ظˆط¯ط§ط،)
      final targetPos = controller.value.duration.inSeconds > 5
          ? const Duration(seconds: 6)
          : Duration(milliseconds: (controller.value.duration.inMilliseconds * 0.1).toInt());

      await controller.seekTo(targetPos);

      // âœ… 4. ط§ظ†طھط¸ط± ظ„ط­ط¸ط© ط­طھظ‰ ظٹط±ط³ظ… ط§ظ„ظ€ frame
      await Future.delayed(const Duration(milliseconds: 200));

      await controller.pause();

      if (!mounted) { controller.dispose(); return; }

      setState(() {
        _thumbController = controller;
        _ready = true;
        _createdLocally = true;
      });
    } catch (_) {
      controller.dispose();
    }
  }

  String? _getLocalPath(String url) {
    try {
      final videoId = VideoDownloadService.videoIdFromUrl(url);
      final downloadService =
      Provider.of<VideoDownloadService>(context, listen: false);
      final path = downloadService.getLocalPath(videoId);

      if (path != null && File(path).existsSync()) {
        return path;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // âœ… ط¥ط°ط§ ظٹظˆط¬ط¯ طµظˆط±ط© ظ…ط®طµطµط©
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return RadioImageWidget(
        imageUrl: widget.imageUrl,
        emoji: widget.emoji,
        primary: widget.primary,
        size: 165,
        borderRadius: BorderRadius.circular(14),
        fit: BoxFit.cover,
      );
    }

    // âœ… ط¥ط°ط§ ط§ظ„ظپظٹط¯ظٹظˆ ط¬ط§ظ‡ط²طŒ ط§ط¹ط±ط¶ ط£ظˆظ„ frame
    if (_ready && _thumbController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _thumbController!.value.size.width,
              height: _thumbController!.value.size.height,
              child: VideoPlayer(_thumbController!),
            ),
          ),
        ),
      );
    }

    // âœ… Fallback
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primary.withValues(alpha: 0.2),
            widget.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Icon(
              Icons.videocam_rounded,
              color: widget.primary.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// Models ط¯ط§ط®ظ„ظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _VideoSection {
  final String title;
  final String emoji;
  final List<Color> gradientColors;
  final List<_VideoEntry> videos;

  const _VideoSection({
    required this.title,
    required this.emoji,
    required this.gradientColors,
    required this.videos,
  });

  List<_VideoEntry> get directVideos =>
      videos.where((v) => v.videoSource == VideoSource.direct).toList();
}

class _VideoEntry {
  final String title;
  final String subtitle;
  final String emoji;
  final String? imageUrl;
  final String videoUrl;
  final VideoSource videoSource;
  final RecitationSubItem subItem;

  const _VideoEntry({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.imageUrl,
    required this.videoUrl,
    required this.videoSource,
    required this.subItem,
  });
}