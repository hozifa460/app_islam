import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/channels/cache/image_cache_config.dart';
import 'package:islamic_app/screens/channels/features/favorites_manager.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/feed_cache_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/video_player_screen.dart';
// â‌Œ ط£ط²ظ„ظ†ط§: import 'package:visibility_detector/visibility_detector.dart';
// â‌Œ ط£ط²ظ„ظ†ط§: import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../services/home_preview_cache_service.dart';
import '../services/home_preview_settings_service.dart';
import 'home_card_skeleton.dart';

class HomeChannelsPreviewCard extends StatefulWidget {
  final Color primary;
  final Color gold;
  final bool isDark;
  final Color cardColor;

  const HomeChannelsPreviewCard({
    super.key,
    required this.primary,
    required this.gold,
    required this.isDark,
    required this.cardColor,
  });

  @override
  State<HomeChannelsPreviewCard> createState() =>
      _HomeChannelsPreviewCardState();
}

class _HomeChannelsPreviewCardState extends State<HomeChannelsPreviewCard>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  YoutubeVideo? _selectedVideo;
  FavoritesManager? _favoritesManager;

  bool _loading = true;
  bool _hasError = false;
  bool _isDisposed = false;
  bool _offlineThumbnailOnly = false;

  bool _previewEnabled = true;

  String _selectionReason = 'ط§ظ‚طھط±ط§ط­ ظ„ظƒ';
  String? _thumbnailLocalPath;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _favoritesManager = await FavoritesManager.getInstance();
    _previewEnabled = await HomePreviewSettingsService.isEnabled();

    if (_previewEnabled) {
      await _loadPreviewVideo();
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طھط­ظ…ظٹظ„ ط§ظ„ظپظٹط¯ظٹظˆ (ظ†ظپط³ ط§ظ„ظ…ظ†ط·ظ‚ ط¨ط¯ظˆظ† طھط؛ظٹظٹط±)
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _loadPreviewVideo({bool forceNew = false}) async {
    try {
      await VideoHistoryService.init();
      await ChannelUsageService.init();
      _favoritesManager ??= await FavoritesManager.getInstance();

      if (mounted) {
        setState(() {
          _loading = true;
          _hasError = false;
        });
      }

      // 1) session video
      if (!forceNew) {
        final sessionVideoId =
        await HomePreviewCacheService.getSessionVideoId();
        if (sessionVideoId != null && sessionVideoId.isNotEmpty) {
          final restored = await _findVideoById(sessionVideoId);
          if (restored != null) {
            _thumbnailLocalPath =
            await HomePreviewCacheService.getThumbnailLocalPath();

            if (!mounted || _isDisposed) return;
            setState(() {
              _selectedVideo = restored;
              _loading = false;
              _hasError = false;
              _offlineThumbnailOnly = false;
              _selectionReason = _detectReason(restored);
            });
            return;
          }
        }
      }

      // 2) cached preview
      if (!forceNew) {
        final cached = await HomePreviewCacheService.getCachedPreviewVideo();
        if (cached != null) {
          await HomePreviewCacheService.setSessionVideoId(cached.id);
          _thumbnailLocalPath =
          await HomePreviewCacheService.getThumbnailLocalPath();

          if (!mounted || _isDisposed) return;
          setState(() {
            _selectedVideo = cached;
            _loading = false;
            _hasError = false;
            _offlineThumbnailOnly = false;
            _selectionReason = _detectReason(cached);
          });

          Future.microtask(() => _refreshPreviewInBackground());
          return;
        }
      }

      // 3) live source
      await _pickAndUseBestSourceVideo(forceNew: forceNew);
    } catch (_) {
      final fallback =
      await HomePreviewCacheService.getAnyCachedPreviewVideo();
      _thumbnailLocalPath =
      await HomePreviewCacheService.getThumbnailLocalPath();

      if (!mounted || _isDisposed) return;

      if (fallback != null) {
        setState(() {
          _selectedVideo = fallback;
          _loading = false;
          _hasError = false;
          _offlineThumbnailOnly = true;
          _selectionReason = 'ظ…ظ† ط¢ط®ط± ظ…ط¹ط§ظٹظ†ط© ظ…ط­ظپظˆط¸ط©';
        });
      } else {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _refreshPreviewInBackground() async {
    try {
      final candidates = await _collectCandidateVideosBestSource();
      if (candidates.isEmpty) return;

      final smart = await _pickSmartVideo(candidates);
      if (smart == null) return;

      await _cacheThumbnailLocally(smart.video.thumbnail);

      await HomePreviewCacheService.savePreviewVideo(
        smart.video,
        thumbnailLocalPath: _thumbnailLocalPath,
      );
    } catch (_) {}
  }

  Future<void> _pickAndUseBestSourceVideo({bool forceNew = false}) async {
    final candidates = await _collectCandidateVideosBestSource();

    if (candidates.isEmpty) {
      final fallback =
      await HomePreviewCacheService.getAnyCachedPreviewVideo();
      _thumbnailLocalPath =
      await HomePreviewCacheService.getThumbnailLocalPath();

      if (!mounted || _isDisposed) return;

      if (fallback != null) {
        setState(() {
          _selectedVideo = fallback;
          _selectionReason = 'ظ…ظ† ط¢ط®ط± ظ…ط¹ط§ظٹظ†ط© ظ…ط­ظپظˆط¸ط©';
          _loading = false;
          _hasError = false;
          _offlineThumbnailOnly = true;
        });
      } else {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
      return;
    }

    final selected = await _pickSmartVideo(candidates);

    if (selected == null) {
      final fallback =
      await HomePreviewCacheService.getAnyCachedPreviewVideo();
      _thumbnailLocalPath =
      await HomePreviewCacheService.getThumbnailLocalPath();

      if (!mounted || _isDisposed) return;

      if (fallback != null) {
        setState(() {
          _selectedVideo = fallback;
          _selectionReason = 'ظ…ظ† ط¢ط®ط± ظ…ط¹ط§ظٹظ†ط© ظ…ط­ظپظˆط¸ط©';
          _loading = false;
          _hasError = false;
          _offlineThumbnailOnly = true;
        });
      } else {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
      return;
    }

    await HomePreviewCacheService.setLastVideoId(selected.video.id);
    await HomePreviewCacheService.setSessionVideoId(selected.video.id);

    await _cacheThumbnailLocally(selected.video.thumbnail);

    await HomePreviewCacheService.savePreviewVideo(
      selected.video,
      thumbnailLocalPath: _thumbnailLocalPath,
    );

    if (!mounted || _isDisposed) return;
    setState(() {
      _selectedVideo = selected.video;
      _selectionReason = selected.reason;
      _loading = false;
      _hasError = false;
      _offlineThumbnailOnly = false;
    });
  }

  Future<void> _cacheThumbnailLocally(String url) async {
    try {
      if (url.isEmpty) return;

      final File file =
      await ImageCacheConfig.customCacheManager.getSingleFile(url);

      if (await file.exists()) {
        _thumbnailLocalPath = file.path;
        await HomePreviewCacheService.setThumbnailLocalPath(file.path);
      }
    } catch (_) {}
  }

  Future<List<YoutubeVideo>> _collectCandidateVideosBestSource() async {
    final feed = await FeedCacheService.loadFeed();
    if (feed != null) {
      final fromFeed = _filterPreviewCandidates(feed.videos);
      if (fromFeed.isNotEmpty) {
        return fromFeed;
      }
    }

    return _collectCandidateVideosFromChannelsJson();
  }

  List<YoutubeVideo> _filterPreviewCandidates(List<YoutubeVideo> videos) {
    final seen = <String>{};
    final filtered = <YoutubeVideo>[];

    for (final video in videos) {
      final isShort = YoutubeService.isLikelyShortVideo(video);
      final isLive = video.type == VideoType.live;

      if (!isShort &&
          !isLive &&
          video.id.isNotEmpty &&
          video.thumbnail.isNotEmpty &&
          seen.add(video.id)) {
        filtered.add(video);
      }
    }

    filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return filtered.take(50).toList();
  }

  Future<List<YoutubeVideo>> _collectCandidateVideosFromChannelsJson() async {
    final jsonStr = await rootBundle.loadString('assets/json/channels.json');
    final List<dynamic> data = json.decode(jsonStr);

    final scholars = data
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..shuffle(Random());

    final collected = <YoutubeVideo>[];
    final seen = <String>{};

    for (final scholar in scholars.take(10)) {
      final platforms = scholar['platforms'] as List<dynamic>? ?? [];

      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          try {
            final videos = await YoutubeService.getChannelLatestBatch(
              channelUrl: pm['url'] ?? '',
              handle: pm['handle'],
              channelId: pm['channelId']?.toString(),
              maxResults: 6,
            );

            for (final video in videos) {
              final isShort = YoutubeService.isLikelyShortVideo(video);
              final isLive = video.type == VideoType.live;

              if (!isShort &&
                  !isLive &&
                  video.id.isNotEmpty &&
                  video.thumbnail.isNotEmpty &&
                  seen.add(video.id)) {
                collected.add(video);
              }
            }
          } catch (_) {}
          break;
        }
      }

      if (collected.length >= 24) break;
    }

    collected.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return collected;
  }

  Future<YoutubeVideo?> _findVideoById(String targetId) async {
    final list = await _collectCandidateVideosBestSource();
    try {
      return list.firstWhere((v) => v.id == targetId);
    } catch (_) {
      return null;
    }
  }

  Future<_SmartPreviewPick?> _pickSmartVideo(
      List<YoutubeVideo> candidates,
      ) async {
    if (candidates.isEmpty) return null;

    final lastVideoId = await HomePreviewCacheService.getLastVideoId();
    final filtered = candidates.where((v) => v.id != lastVideoId).toList();
    final source = filtered.isNotEmpty ? filtered : candidates;

    final scored = source
        .map(
          (video) => _SmartPreviewPick(
        video: video,
        score: _scoreVideo(video),
        reason: _detectReason(video),
      ),
    )
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final top = scored.take(min(8, scored.length)).toList()..shuffle(Random());
    return top.first;
  }

  double _scoreVideo(YoutubeVideo video) {
    double score = 0;

    final progress = VideoHistoryService.getProgress(video.id);
    final completed = VideoHistoryService.isCompleted(video.id);
    final shown = VideoHistoryService.isShown(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final usageScore = ChannelUsageService.getPriorityScore(channelKey);

    final days = DateTime.now().difference(video.publishedAt).inDays;
    final views = int.tryParse(video.viewCount) ?? 0;

    final isFavorite = _favoritesManager?.isVideoFavorite(video.id) ?? false;
    final isWatchLater = _favoritesManager?.isInWatchLater(video.id) ?? false;

    if (isWatchLater) score += 55;
    if (isFavorite) score += 28;
    if (partial) score += 45;

    if (progress > 0 && progress < 0.9) {
      score += 20 + (progress * 12);
    }

    if (completed) score -= 35;
    score += usageScore * 1.25;

    if (days <= 1) {
      score += 18;
    } else if (days <= 3) {
      score += 14;
    } else if (days <= 7) {
      score += 10;
    } else if (days <= 30) {
      score += 5;
    }

    if (!shown) score += 12;

    if (views > 0) {
      score += views.toString().length * 1.5;
    }

    return score;
  }

  String _detectReason(YoutubeVideo video) {
    final progress = VideoHistoryService.getProgress(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);
    final shown = VideoHistoryService.isShown(video.id);

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final usageScore = ChannelUsageService.getPriorityScore(channelKey);

    final isFavorite = _favoritesManager?.isVideoFavorite(video.id) ?? false;
    final isWatchLater = _favoritesManager?.isInWatchLater(video.id) ?? false;

    final days = DateTime.now().difference(video.publishedAt).inDays;

    if (isWatchLater) return 'ظ…ظ† ط§ظ„ظ…ط´ط§ظ‡ط¯ط© ظ„ط§ط­ظ‚ظ‹ط§';
    if (partial || (progress > 0 && progress < 0.9)) return 'ط£ظƒظ…ظ„ ط§ظ„ظ…ط´ط§ظ‡ط¯ط©';
    if (isFavorite) return 'ظ…ظ† ط§ظ„ظ…ظپط¶ظ„ط©';
    if (!shown && days <= 7) return 'ظپظٹط¯ظٹظˆ ط¬ط¯ظٹط¯ ظ„ظƒ';
    if (!shown) return 'ط§ظ‚طھط±ط§ط­ ط¬ط¯ظٹط¯ ظ„ظƒ';
    return 'ط§ظ‚طھط±ط§ط­ ظ„ظƒ';
  }

  void _openFullVideo() {
    final video = _selectedVideo;
    if (video == null) return;

    if (_offlineThumbnailOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ظ„ط§ ظٹظˆط¬ط¯ ط§طھطµط§ظ„ ط¨ط§ظ„ط¥ظ†طھط±ظ†طھطŒ ظ‡ط°ظ‡ ظ…ط¹ط§ظٹظ†ط© ظ…ط­ظپظˆط¸ط© ظپظ‚ط·',
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: '',
        ),
      ),
    );
  }

  Future<void> _showQuickSettingsSheet() async {
    bool enabled = _previewEnabled;

    await showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF1A1F2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: widget.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„ظ…ط¹ط§ظٹظ†ط©',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      value: enabled,
                      onChanged: (v) async {
                        await HomePreviewSettingsService.setEnabled(v);
                        setModalState(() => enabled = v);
                      },
                      title: Text(
                        'ط¥ط¸ظ‡ط§ط± ط¨ط·ط§ظ‚ط© ط§ظ„ظ…ط¹ط§ظٹظ†ط©',
                        style:
                        GoogleFonts.cairo(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _previewEnabled = enabled;
                          if (!enabled) {
                            if (mounted) {
                              setState(() {
                                _selectedVideo = null;
                              });
                            }
                          } else if (_selectedVideo == null) {
                            await _loadPreviewVideo();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primary,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'طھط·ط¨ظٹظ‚ ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… ط§ظ„طµظˆط±ط© ط§ظ„ظ…طµط؛ط±ط© ط¹ط§ظ„ظٹط© ط§ظ„ط¬ظˆط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  String _getMaxResThumbnail(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  String _getHqThumbnail(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  Widget _buildThumbnail(YoutubeVideo video) {
    // â•گâ•گâ•گ ظ…ط­ظپظˆط¸ ظ…ط­ظ„ظٹط§ظ‹ â•گâ•گâ•گ
    if (_offlineThumbnailOnly &&
        _thumbnailLocalPath != null &&
        File(_thumbnailLocalPath!).existsSync()) {
      return Image.file(
        File(_thumbnailLocalPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // â•گâ•گâ•گ طµظˆط±ط© ط¨ط£ط¹ظ„ظ‰ ط¬ظˆط¯ط© ظ…ظ† YouTube â•گâ•گâ•گ
    final maxResUrl = _getMaxResThumbnail(video.id);
    final hqUrl = _getHqThumbnail(video.id);

    return ImageCacheConfig.videoThumbnail(
      url: maxResUrl,
      fit: BoxFit.cover,
      placeholder: Container(
        color: widget.isDark
            ? const Color(0xFF24312D)
            : const Color(0xFFF1EADC),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: ImageCacheConfig.videoThumbnail(
        url: hqUrl,
        fit: BoxFit.cover,
        placeholder: Container(
          color: widget.isDark
              ? const Color(0xFF24312D)
              : const Color(0xFFF1EADC),
        ),
        errorWidget: ImageCacheConfig.videoThumbnail(
          url: video.thumbnail,
          fit: BoxFit.cover,
          placeholder: Container(
            color: widget.isDark
                ? const Color(0xFF24312D)
                : const Color(0xFFF1EADC),
          ),
          errorWidget: Container(
            color: widget.isDark
                ? const Color(0xFF24312D)
                : const Color(0xFFF1EADC),
            child: Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                color:
                widget.isDark ? Colors.white54 : Colors.black45,
                size: 38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subColor) {
    // ظ‡ظٹط¯ط± ظ…ظڈط¯ظ…ط¬ طµط؛ظٹط± ط¬ط¯ط§ظ‹
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.primary, widget.gold],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.live_tv_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'ط§ظ‚طھط±ط§ط­ ط°ظƒظٹ',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const Spacer(),
          if (_offlineThumbnailOnly)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: subColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ',
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  color: subColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_previewEnabled) return const SizedBox.shrink();

    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE6DED0);

    final textColor =
    widget.isDark ? Colors.white : const Color(0xFF1F1A14);

    final subColor =
    widget.isDark ? Colors.white54 : const Color(0xFF6E6253);

    if (_loading) {
      return HomeCardSkeleton(
        isDark: widget.isDark,
        height: 230,
        borderRadius: BorderRadius.circular(16),
      );
    }

    if (_hasError || _selectedVideo == null) {
      return _HomePreviewErrorCard(
        isDark: widget.isDark,
        cardColor: widget.cardColor,
        borderColor: borderColor,
        onRetry: () => _loadPreviewVideo(forceNew: true),
      );
    }

    final video = _selectedVideo!;

    // â”€â”€ ط¨ظٹط§ظ†ط§طھ ط§ظ„ظپظٹط¯ظٹظˆ â”€â”€
    final views = int.tryParse(video.viewCount) ?? 0;
    final viewsStr = views > 0
        ? YoutubeService.formatViews(video.viewCount)
        : '';
    final days =
        DateTime.now().difference(video.publishedAt).inDays;
    final timeAgo = days == 0
        ? 'ط§ظ„ظٹظˆظ…'
        : days == 1
        ? 'ط£ظ…ط³'
        : days < 7
        ? 'ظ…ظ†ط° $days ط£ظٹط§ظ…'
        : days < 30
        ? 'ظ…ظ†ط° ${(days / 7).floor()} ط£ط³ط§ط¨ظٹط¹'
        : days < 365
        ? 'ظ…ظ†ط° ${(days / 30).floor()} ط£ط´ظ‡ط±'
        : 'ظ…ظ†ط° ${(days / 365).floor()} ط³ظ†ظˆط§طھ';

    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: widget.isDark ? 0.16 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // âœ… ط§ظ„طµظˆط±ط© - ط¨ط¯ظˆظ† ظ‡ظٹط¯ط± ظپظˆظ‚ظ‡ط§
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            GestureDetector(
              onTap: _openFullVideo,
              child: Stack(
                children: [
                  // ط§ظ„طµظˆط±ط©
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildThumbnail(video),
                  ),

                  // طھط¯ط±ط¬ ط³ظپظ„ظٹ
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.28),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // â”€â”€ ط²ط± ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ - ط£ط¹ظ„ظ‰ ظٹط³ط§ط± â”€â”€
                  if (!_offlineThumbnailOnly)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showQuickSettingsSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // â”€â”€ ط¨ط§ط¯ط¬ ط£ط¹ظ„ظ‰ ظٹظ…ظٹظ† â”€â”€
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _offlineThumbnailOnly
                            ? Colors.black.withValues(alpha: 0.72)
                            : Colors.red.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _offlineThumbnailOnly
                            ? 'ظ…ط­ظپظˆط¸'
                            : 'ط§ظ‚طھط±ط§ط­ ط°ظƒظٹ',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // â”€â”€ ط²ط± طھط´ط؛ظٹظ„ ظپظٹ ط§ظ„ظ…ظ†طھطµظپ â”€â”€
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  // â”€â”€ ظ…ط¯ط©/ظ†ظˆط¹ - ط£ط³ظپظ„ ظٹظ…ظٹظ† (ظٹظˆطھظٹظˆط¨ ط³طھط§ظٹظ„) â”€â”€
                  Positioned(
                    bottom: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _offlineThumbnailOnly ? 'ظ…ط­ظپظˆط¸' : 'â–¶ ط´ط§ظ‡ط¯',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // âœ… ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ظپظٹط¯ظٹظˆ - ظٹظˆطھظٹظˆط¨ ط³طھط§ظٹظ„ ط¨ط§ظ„ط¶ط¨ط·
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // â”€â”€ طµظˆط±ط© ط§ظ„ظ‚ظ†ط§ط© ط§ظ„ط¯ط§ط¦ط±ظٹط© â”€â”€
                  GestureDetector(
                    onTap: _openFullVideo,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [widget.primary, widget.gold],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          video.channelTitle.isNotEmpty
                              ? video.channelTitle[0].toUpperCase()
                              : 'طں',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  // â”€â”€ ط§ظ„ط¹ظ†ظˆط§ظ† + ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط«ط§ظ†ظˆظٹط© â”€â”€
                  Expanded(
                    child: GestureDetector(
                      onTap: _openFullVideo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ط¹ظ†ظˆط§ظ† ط§ظ„ظپظٹط¯ظٹظˆ
                          Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 3),

                          // â”€â”€ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط«ط§ظ†ظˆظٹط© - ظٹظˆطھظٹظˆط¨ ط³طھط§ظٹظ„ â”€â”€
                          Text(
                            [
                              video.channelTitle,
                              if (viewsStr.isNotEmpty)
                                '$viewsStr ظ…ط´ط§ظ‡ط¯ط©',
                              timeAgo,
                            ].join(' â€¢ '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              color: subColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // â”€â”€ ط«ظ„ط§ط« ظ†ظ‚ط§ط· â”€â”€
                  GestureDetector(
                    onTap: () => _loadPreviewVideo(forceNew: true),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: subColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط§ظ„ظƒظ„ط§ط³ط§طھ ط§ظ„ظ…ط³ط§ط¹ط¯ط© (ط¨ط¯ظˆظ† طھط؛ظٹظٹط±)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _SmartPreviewPick {
  final YoutubeVideo video;
  final double score;
  final String reason;

  _SmartPreviewPick({
    required this.video,
    required this.score,
    required this.reason,
  });
}

class _HomePreviewSkeleton extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _HomePreviewSkeleton({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final shimmer =
    isDark ? const Color(0xFF24312D) : const Color(0xFFF1EADC);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ط§ظ„طµظˆط±ط© skeleton
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: shimmer),
            ),

            // ظ…ط¹ظ„ظˆظ…ط§طھ skeleton - ظٹظˆطھظٹظˆط¨ ط³طھط§ظٹظ„
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ط¯ط§ط¦ط±ط© ط§ظ„ظ‚ظ†ط§ط©
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shimmer,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 13,
                          decoration: BoxDecoration(
                            color: shimmer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 13,
                          width: 180,
                          decoration: BoxDecoration(
                            color: shimmer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 10,
                          width: 130,
                          decoration: BoxDecoration(
                            color: shimmer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    color: shimmer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePreviewErrorCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onRetry;

  const _HomePreviewErrorCard({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
    isDark ? Colors.white : const Color(0xFF1F1A14);
    final subColor =
    isDark ? Colors.white60 : const Color(0xFF6E6253);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.live_tv_outlined, size: 32, color: subColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„ظ…ط¹ط§ظٹظ†ط©',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  'ظٹظ…ظƒظ†ظƒ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'ط¥ط¹ط§ط¯ط©',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}