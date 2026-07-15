import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/channels/cache/image_cache_config.dart';
import 'package:islamic_app/screens/channels/helpers/time_format_helper.dart';
import 'package:islamic_app/screens/channels/scholar_profile_tiktok_screen.dart';
import 'package:islamic_app/screens/channels/scholar_profile_youtube_screen.dart';
import 'package:islamic_app/screens/channels/services/channel_background_sync_service.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/channels_feed_recommender_service.dart';
import 'package:islamic_app/screens/channels/services/feed_cache_service.dart';
import 'package:islamic_app/screens/channels/services/search_ranking_service.dart';
import 'package:islamic_app/screens/channels/services/user_interest_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/shorts_player_screen.dart';
import 'package:islamic_app/screens/channels/video_player_screen.dart';
import 'package:islamic_app/screens/channels/widgets/channels_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelsScreen extends StatefulWidget {
  final Color? primaryColor;

  const ChannelsScreen({super.key, this.primaryColor});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen>
    with TickerProviderStateMixin {
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // State
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<Map<String, dynamic>> _scholars = [];
  List<YoutubeVideo> _allVideos = [];
  List<YoutubeVideo> _shortsVideos = [];
  List<Map<String, dynamic>> _tiktokEntries = [];

  final List<YoutubeVideo> _videoPool = [];
  final List<YoutubeVideo> _shortsPool = [];
  final Set<String> _loadedVideoIds = {};

  bool _loading = true;
  bool _loadingVideos = true;
  bool _loadingMore = false;
  bool _hasMoreVideos = true;
  bool _showingRecent = true;

  int _loadAttempts = 0;
  int _selectedCategory = 0;
  int _feedSessionSeed = 0;

  String _searchQuery = '';
  bool _searchFocused = false;
  bool _isSearching = false;
  List<YoutubeVideo> _searchResults = [];

  bool _screenInitialized = false;
  bool _refreshInProgress = false;
  bool _suspendProgressiveUpdates = false;

  List<String> _categories = ['الكل'];

  List<Widget> _cachedFeedItems = [];
  int _cachedFeedVersion = -1;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Controllers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _feedScrollController = ScrollController();

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Performance helpers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final ValueNotifier<int> _feedVersion = ValueNotifier<int>(0);
  Timer? _feedRebuildDebounce;
  Timer? _searchDebounce;

  bool _progressiveRunning = false;

  List<YoutubeVideo> _lastBuiltVideos = [];
  List<YoutubeVideo> _lastBuiltShorts = [];
  bool _lastBuiltShowingRecent = true;

  bool _prefetchingNextBatch = false;

  List<YoutubeVideo> _prefetchedRegularVideos = [];
  List<YoutubeVideo> _prefetchedShortsVideos = [];

  static const int _initialFeedBatchSize = 12;
  static const int _nextFeedBatchSize = 8;

  @override
  void initState() {
    super.initState();

    _feedSessionSeed = DateTime.now().millisecondsSinceEpoch;

    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    // âœ… ظ…ط­ط³ظ‘ظ† - Throttle ظ„ظ…ظ†ط¹ ط§ط³طھط¯ط¹ط§ط،ط§طھ ظƒط«ظٹط±ط©
    _feedScrollController.addListener(_onFeedScrollThrottled);

    // âœ… ط¥ظٹظ‚ط§ظپ ط§ظ„طھط­ط¯ظٹط«ط§طھ ط£ط«ظ†ط§ط، ط§ظ„طھظ…ط±ظٹط±
    _feedScrollController.addListener(() {
      if (_feedScrollController.position.isScrollingNotifier.value) {
        _suspendProgressiveUpdates = true;
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          _suspendProgressiveUpdates = false;
        });
      }
    });

    _initAndLoad();
  }

// âœ… Throttle ظ„ظ„ظ€ scroll listener
  DateTime _lastScrollCheck = DateTime.now();

  void _onFeedScrollThrottled() {
    final now = DateTime.now();
    // طھط­ظ‚ظ‚ ظƒظ„ 200ms ظپظ‚ط·
    if (now.difference(_lastScrollCheck).inMilliseconds < 200) return;
    _lastScrollCheck = now;
    _onFeedScroll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _feedScrollController.removeListener(_onFeedScrollThrottled); // âœ…
    _feedScrollController.dispose();
    _searchDebounce?.cancel();
    _feedRebuildDebounce?.cancel();
    _feedVersion.dispose();
    super.dispose();
  }

  bool _hasBuiltInitialFeed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String? _extractProvidedChannelId(Map<String, dynamic> scholar) {
    final platforms = scholar['platforms'] as List<dynamic>? ?? [];
    for (final p in platforms) {
      final pm = Map<String, dynamic>.from(p);
      if (pm['icon'] == 'youtube') {
        final id = pm['channelId']?.toString();
        if (id != null && id.isNotEmpty && id.startsWith('UC')) {
          return id;
        }
      }
    }
    return null;
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Init / Load
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _initAndLoad() async {
    if (_screenInitialized) return;
    _screenInitialized = true;

    // âœ… طھظ‡ظٹط¦ط© ظ…طھظˆط§ط²ظٹط©
    await Future.wait([
      VideoHistoryService.init(),
      ChannelUsageService.init(),
      ChannelBackgroundSyncService.init(),
      UserInterestService.init(),  // âœ… ط¬ط¯ظٹط¯
    ]);

    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/json/channels.json');
      final List<dynamic> data = json.decode(jsonStr);
      final scholars = data.map((e) => Map<String, dynamic>.from(e)).toList();

      final cats = <String>{'الكل'};
      final tiktoks = <Map<String, dynamic>>[];

      for (final s in scholars) {
        if (s['category'] != null) {
          cats.add(s['category'].toString());
        }

        final platforms = s['platforms'] as List<dynamic>? ?? [];
        for (final p in platforms) {
          final pm = Map<String, dynamic>.from(p);
          if (pm['icon'] == 'tiktok') {
            tiktoks.add({
              'scholarName': s['name'],
              'scholarImage': s['image'],
              'flag': s['flag'],
              ...pm,
            });
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _scholars = scholars;
        _categories = cats.toList();
        _tiktokEntries = tiktoks;
        _loading = false;
      });

      Future.microtask(() => _scheduleBackgroundSyncForScholars(scholars));

      final cached = await FeedCacheService.loadFeed();

      if (cached != null &&
          (cached.videos.isNotEmpty || cached.shorts.isNotEmpty)) {
        _videoPool
          ..clear()
          ..addAll(cached.videos);

        _shortsPool
          ..clear()
          ..addAll(cached.shorts);

        _loadedVideoIds
          ..clear()
          ..addAll({
            ...cached.videos.map((e) => e.id),
            ...cached.shorts.map((e) => e.id),
          });

        _feedSessionSeed = DateTime.now().millisecondsSinceEpoch;

        if (!mounted) return;

        setState(() {
          _loadingVideos = false;
          _showingRecent = cached.showingRecent;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _allVideos = List<YoutubeVideo>.from(cached.videos);
            _shortsVideos = List<YoutubeVideo>.from(cached.shorts);
          });
          _notifyFeedChanged();
        });

        _lastBuiltVideos = List<YoutubeVideo>.from(cached.videos);
        _lastBuiltShorts = List<YoutubeVideo>.from(cached.shorts);
        _lastBuiltShowingRecent = cached.showingRecent;
        _hasBuiltInitialFeed = true;
        _notifyFeedChanged();

        await ChannelsFeedRecommenderService.trackTopFeedExposure(
          _allVideos.take(7).toList(),
        );

        await VideoHistoryService.markManyAsShown(
          _allVideos.take(20).map((v) => v.id).toList(),
        );

        unawaited(_precacheInitialFeedImages(
          videos: _allVideos,
          shorts: _shortsVideos,
        ));

        unawaited(_prefetchNextBatch());

        Future.delayed(const Duration(milliseconds: 2500), () {
          if (!mounted) return;
          _refreshFeed();
        });

        return;
      }

      await _fetchAllVideos(scholars);
    } catch (e) {
      debugPrint('❌ ChannelsScreen load error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingVideos = false;
      });
    }
  }

  Future<void> _precacheInitialFeedImages({
    required List<YoutubeVideo> videos,
    required List<YoutubeVideo> shorts,
  }) async {
    if (!mounted) return;

    // âœ… ظپظ‚ط· ط£ظˆظ„ 5 ظپظٹط¯ظٹظˆظ‡ط§طھ ظˆ 2 shorts
    final items = <YoutubeVideo>[
      ...videos.take(5),
      ...shorts.take(2),
    ];

    for (final video in items) {
      if (!mounted) return;
      if (video.thumbnail.trim().isEmpty) continue;

      try {
        await precacheImage(
          CachedNetworkImageProvider(
            video.thumbnail,
            cacheManager: ImageCacheConfig.customCacheManager,
          ),
          context,
        );
      } catch (_) {}
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Background sync
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _setDisplayedFeedFromPool({bool reset = false}) {
    final sourceVideos = List<YoutubeVideo>.from(_videoPool);
    final sourceShorts = List<YoutubeVideo>.from(_shortsPool);

    final targetCount = reset
        ? min(_initialFeedBatchSize, sourceVideos.length)
        : min(_allVideos.length + _nextFeedBatchSize, sourceVideos.length);

    // âœ… ط¥ط²ط§ظ„ط© ظ…ظƒط±ط±ط§طھ
    final seenIds = <String>{};
    var rawVideos = sourceVideos
        .where((v) => v.id.isNotEmpty && seenIds.add(v.id))
        .take(targetCount)
        .toList();

    // âœ… ظپط±ط¶ ط§ظ„طھظ†ظˆط¹ ظˆط§ظ„طھظˆط²ظٹط¹
    rawVideos = _enforceChannelDiversityInDisplay(rawVideos);

    // âœ… ظ…ظ†ط¹ ط§ظ„طھطھط§ط¨ط¹ ظ…ظ† ظ†ظپط³ ط§ظ„ظ‚ظ†ط§ط©
    rawVideos = _preventConsecutiveSameChannel(rawVideos);

    // ط´ظˆط±طھط³
    final seenShortIds = <String>{};
    final shortsCount = min(12, sourceShorts.length);
    var rawShorts = sourceShorts
        .where((v) => v.id.isNotEmpty && seenShortIds.add(v.id))
        .take(shortsCount)
        .toList();
    rawShorts = _preventConsecutiveSameChannel(rawShorts);

    setState(() {
      _allVideos = rawVideos;
      _shortsVideos = rawShorts;
    });

    _lastBuiltVideos = List<YoutubeVideo>.from(_allVideos);
    _lastBuiltShorts = List<YoutubeVideo>.from(_shortsVideos);
    _notifyFeedChanged();

    // طھط³ط¬ظٹظ„ ط§ظ„ط¸ظ‡ظˆط±
    for (final v in rawVideos.take(10)) {
      UserInterestService.trackExposure(
        channelId: v.channelId,
        channelTitle: v.channelTitle,
      );
    }
    unawaited(UserInterestService.saveExposures());
  }

// âœ… ظپط±ط¶ ط§ظ„طھظ†ظˆط¹ ظپظٹ ط§ظ„ط¹ط±ط¶
  List<YoutubeVideo> _enforceChannelDiversityInDisplay(
      List<YoutubeVideo> videos) {
    if (videos.length <= 4) return videos;

    // ط­ط³ط§ط¨ ط­ط¯ ظƒظ„ ظ‚ظ†ط§ط© ط¨ظ†ط§ط،ظ‹ ط¹ظ„ظ‰ ط¹ط¯ط¯ ط§ظ„ظ‚ظ†ظˆط§طھ
    final channelCount =
        videos.map((v) => v.channelId.isNotEmpty ? v.channelId : v.channelTitle)
            .toSet()
            .length;

    final maxPerChannel = max(2, (videos.length / max(1, channelCount)).ceil());
    final effectiveMax = min(maxPerChannel, 3); // ظ„ط§ طھطھط¬ط§ظˆط² 3 ظ„ط£ظٹ ظ‚ظ†ط§ط©

    final counts = <String, int>{};
    final result = <YoutubeVideo>[];
    final deferred = <YoutubeVideo>[];

    for (final v in videos) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      final count = counts[ch] ?? 0;

      if (count < effectiveMax) {
        result.add(v);
        counts[ch] = count + 1;
      } else {
        deferred.add(v);
      }
    }

    // ط£ط¶ظپ ط§ظ„ظ…ط¤ط¬ظ„ط© ظپظٹ ظ†ظ‡ط§ظٹط© ط§ظ„ظ‚ط§ط¦ظ…ط©
    result.addAll(deferred);

    return result;
  }

  /// âœ… ظٹظ…ظ†ط¹ ط¸ظ‡ظˆط± ظپظٹط¯ظٹظˆظ‡ظٹظ† ظ…طھطھط§ظ„ظٹظٹظ† ظ…ظ† ظ†ظپط³ ط§ظ„ظ‚ظ†ط§ط©
  List<YoutubeVideo> _preventConsecutiveSameChannel(List<YoutubeVideo> videos) {
    if (videos.length <= 2) return videos;

    final result = <YoutubeVideo>[videos.first];
    final skipped = <YoutubeVideo>[];

    for (int i = 1; i < videos.length; i++) {
      final prevCh = result.last.channelId.isNotEmpty
          ? result.last.channelId
          : result.last.channelTitle;
      final currCh = videos[i].channelId.isNotEmpty
          ? videos[i].channelId
          : videos[i].channelTitle;

      if (currCh == prevCh) {
        skipped.add(videos[i]);
      } else {
        // ظ‚ط¨ظ„ ط§ظ„ط¥ط¶ط§ظپط©طŒ ط­ط§ظˆظ„ ط¥ط¯ط®ط§ظ„ ظˆط§ط­ط¯ ظ…ظ† ط§ظ„ظ…طھط®ط·ظٹظ†
        if (skipped.isNotEmpty) {
          final insertable = skipped.indexWhere((s) {
            final sCh = s.channelId.isNotEmpty ? s.channelId : s.channelTitle;
            return sCh != currCh && sCh != prevCh;
          });

          if (insertable >= 0) {
            result.add(skipped.removeAt(insertable));
          }
        }
        result.add(videos[i]);
      }
    }

    // ط£ط¶ظپ ط§ظ„ظ…طھط®ط·ظٹظ† ظپظٹ ط§ظ„ظ†ظ‡ط§ظٹط© ظ…ط¹ طھظˆط²ظٹط¹
    for (final s in skipped) {
      // ط§ط¨ط­ط« ط¹ظ† ظ…ظƒط§ظ† ظ…ظ†ط§ط³ط¨
      bool inserted = false;
      final sCh = s.channelId.isNotEmpty ? s.channelId : s.channelTitle;

      for (int i = 1; i < result.length; i++) {
        final prevCh = result[i - 1].channelId.isNotEmpty
            ? result[i - 1].channelId
            : result[i - 1].channelTitle;
        final nextCh = result[i].channelId.isNotEmpty
            ? result[i].channelId
            : result[i].channelTitle;

        if (sCh != prevCh && sCh != nextCh) {
          result.insert(i, s);
          inserted = true;
          break;
        }
      }

      if (!inserted) {
        result.add(s);
      }
    }

    return result;
  }

  Future<void> _prefetchNextBatch() async {
    if (_prefetchingNextBatch || !_hasMoreVideos || _scholars.isEmpty) return;
    _prefetchingNextBatch = true;

    try {
      final shuffled = List<Map<String, dynamic>>.from(_scholars)
        ..shuffle(Random());

      shuffled.sort((a, b) {
        final aChannel = _extractYoutubeChannelIdentity(a);
        final bChannel = _extractYoutubeChannelIdentity(b);
        final aScore = ChannelUsageService.getPriorityScore(aChannel.$1);
        final bScore = ChannelUsageService.getPriorityScore(bChannel.$1);
        return bScore.compareTo(aScore);
      });

      final nextRegular = <YoutubeVideo>[];
      final nextShorts = <YoutubeVideo>[];
      final usedChannelsThisRound = <String>{};
      final existingIds = <String>{
        ..._loadedVideoIds,
        ..._allVideos.map((v) => v.id),
      };

      final terms = [
        '', 'محاضرة', 'درس', 'خطبة', 'تفسير', 'فتوى',
        'شرح', 'فقه', 'حديث', 'قرآن', 'دعاء', 'موعظة',
      ];

      final baseIndex = _loadAttempts % terms.length;

      // âœ… طھط­ظ…ظٹظ„ ظ…طھظˆط§ط²ظٹ ط¨ط¯ظپط¹ط§طھ
      final candidates = <Map<String, dynamic>>[];
      for (final scholar in shuffled) {
        final identity = _extractYoutubeChannelIdentity(scholar);
        if (identity.$1.isEmpty) continue;
        if (usedChannelsThisRound.contains(identity.$1)) continue;
        usedChannelsThisRound.add(identity.$1);
        candidates.add(scholar);
        if (candidates.length >= 6) break;
      }

      await Future.wait(candidates.asMap().entries.map((entry) async {
        final i = entry.key;
        final scholar = entry.value;
        final platforms = scholar['platforms'] as List<dynamic>? ?? [];

        for (final p in platforms) {
          final pm = Map<String, dynamic>.from(p);
          if (pm['icon'] == 'youtube') {
            try {
              final term = terms[(baseIndex + i) % terms.length];

              final vids = term.isEmpty
                  ? await YoutubeService.getChannelLatestBatch(
                channelUrl: pm['url'] ?? '',
                handle: pm['handle'],
                channelId: pm['channelId']?.toString(),
                maxResults: 6,
              )
                  : await YoutubeService.searchInChannelByUrl(
                channelUrl: pm['url'] ?? '',
                handle: pm['handle'],
                channelId: pm['channelId']?.toString(),
                query: term,
                maxResults: 6,
              );

              int added = 0;
              for (final v in vids) {
                if (v.id.isEmpty || v.title.trim().isEmpty) continue;
                if (existingIds.contains(v.id)) continue;
                if (nextRegular.any((e) => e.id == v.id) ||
                    nextShorts.any((e) => e.id == v.id)) continue;

                if (YoutubeService.isLikelyShortVideo(v)) {
                  nextShorts.add(v);
                } else {
                  nextRegular.add(v);
                }

                added++;
                if (added >= 2) break;
              }
            } catch (_) {}
            break;
          }
        }
      }));

      // âœ… طھط±طھظٹط¨ ظ…ط¹ طھظ†ظˆظٹط¹
      nextRegular.sort((a, b) {
        final aScore = ChannelUsageService.getPriorityScore(
          a.channelId.isNotEmpty ? a.channelId : a.channelTitle,
        );
        final bScore = ChannelUsageService.getPriorityScore(
          b.channelId.isNotEmpty ? b.channelId : b.channelTitle,
        );

        final scoreCompare = bScore.compareTo(aScore);
        if (scoreCompare != 0) return scoreCompare;
        return b.publishedAt.compareTo(a.publishedAt);
      });

      // âœ… ط­ط¯ ظ„ظƒظ„ ظ‚ظ†ط§ط©
      _prefetchedRegularVideos = _limitPerChannel(
        nextRegular,
        maxPerChannel: 2,
      );
      _prefetchedShortsVideos = _limitPerChannel(
        nextShorts,
        maxPerChannel: 2,
      );
    } catch (e) {
      debugPrint('❌ _prefetchNextBatch error: $e');
    } finally {
      _prefetchingNextBatch = false;
    }
  }

  Future<void> _consumePrefetchedBatch() async {
    if (_loadingMore) return;

    // ط¥ط°ط§ ط§ظ„ظ€ pool ظ„ط¯ظٹظ‡ ط§ظ„ظ…ط²ظٹط¯طŒ ط§ط¹ط±ط¶ظ‡ ط£ظˆظ„ط§ظ‹
    if (_allVideos.length < _videoPool.length) {
      _setDisplayedFeedFromPool(reset: false);
      unawaited(_prefetchNextBatch());
      return;
    }

    // ط¥ط°ط§ ظ„ط§ ظٹظˆط¬ط¯ prefetchedطŒ ط­ظ…ظ‘ظ„
    if (_prefetchedRegularVideos.isEmpty &&
        _prefetchedShortsVideos.isEmpty) {
      await _loadMoreVideos();
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final newRegular = List<YoutubeVideo>.from(_prefetchedRegularVideos);
      final newShorts = List<YoutubeVideo>.from(_prefetchedShortsVideos);

      _prefetchedRegularVideos = [];
      _prefetchedShortsVideos = [];

      // âœ… ط¥ط²ط§ظ„ط© ظ…ظƒط±ط±ط§طھ ظ…ط¹ ط§ظ„ظ…ظˆط¬ظˆط¯
      final existingIds = {
        ..._loadedVideoIds,
        ..._allVideos.map((v) => v.id),
        ..._videoPool.map((v) => v.id),
      };

      final filteredRegular = newRegular
          .where((v) => !existingIds.contains(v.id))
          .toList();
      final filteredShorts = newShorts
          .where((v) => !existingIds.contains(v.id))
          .toList();

      if (filteredRegular.isEmpty && filteredShorts.isEmpty) {
        // ظ„ط§ ظٹظˆط¬ط¯ ط¬ط¯ظٹط¯طŒ ط§ط¬ظ„ط¨ ط§ظ„ظ…ط²ظٹط¯
        setState(() => _loadingMore = false);
        await _loadMoreVideos();
        return;
      }

      // âœ… طھظ†ظˆظٹط¹ ظ‚ط¨ظ„ ط§ظ„ط¥ط¶ط§ظپط© ظ„ظ„ظ€ pool
      final diversifiedRegular = _diversifyBeforeAdding(
        existing: _videoPool,
        newVideos: filteredRegular,
      );

      for (final v in diversifiedRegular) {
        _loadedVideoIds.add(v.id);
        _videoPool.add(v);
      }

      for (final v in filteredShorts) {
        _loadedVideoIds.add(v.id);
        _shortsPool.add(v);
      }

      if (mounted) {
        _setDisplayedFeedFromPool(reset: false);
      }

      unawaited(FeedCacheService.saveFeed(
        videos: _videoPool,
        shorts: _shortsPool,
        showingRecent: _showingRecent,
      ));

      unawaited(_prefetchNextBatch());
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _scheduleBackgroundSyncForScholars(
      List<Map<String, dynamic>> scholars,
      ) async {
    final requests = <ChannelSyncRequest>[];

    for (final scholar in scholars) {
      final platforms = scholar['platforms'] as List<dynamic>? ?? [];
      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          final url = pm['url']?.toString() ?? '';
          final handle = pm['handle']?.toString();

          if (url.isEmpty) break;

          final providedChannelId = pm['channelId']?.toString();

          final channelId = await YoutubeService.resolveChannelId(
            providedChannelId: providedChannelId,
            channelUrl: url,
            handle: handle,
          );

          if (channelId != null && channelId.isNotEmpty) {
            requests.add(
              ChannelSyncRequest(
                channelId: channelId,
                channelUrl: url,
                handle: handle,
                priorityKey: channelId,
                maxResults: 40,
                mode: ChannelSyncMode.latest,
              ),
            );
          }
          break;
        }
      }
    }

    if (requests.isEmpty) return;

    await ChannelBackgroundSyncService.enqueueChannels(
      requests,
      prioritizeByUsage: true,
    );

    final archiveRequests = requests.take(2).map((e) {
      return ChannelSyncRequest(
        channelId: e.channelId,
        channelUrl: e.channelUrl,
        handle: e.handle,
        priorityKey: e.priorityKey,
        maxResults: 120,
        mode: ChannelSyncMode.archive,
      );
    }).toList();

    await ChannelBackgroundSyncService.enqueueChannels(
      archiveRequests,
      prioritizeByUsage: true,
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Helpers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _sameVideoIds(List<YoutubeVideo> a, List<YoutubeVideo> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _notifyFeedChanged() {
    // âœ… ط£ط¨ط·ظ„ ط§ظ„ظ€ cache ط¹ظ†ط¯ ط§ظ„طھط؛ظٹظٹط±
    _cachedFeedVersion = -1;
    _feedVersion.value++;
  }

  void _scheduleRebuildFeed({bool immediate = false}) {
    if (_refreshInProgress) return;

    _feedRebuildDebounce?.cancel();

    if (_loadingVideos && _allVideos.isEmpty && _shortsVideos.isEmpty) {
      return;
    }

    // âœ… طھط£ط®ظٹط± ط£ط·ظˆظ„ ظ„طھط¬ظ†ط¨ ط§ظ„طھط¹ظ„ظٹظ‚ ط£ط«ظ†ط§ط، ط§ظ„طھظ…ط±ظٹط±
    final delay = immediate
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 800);

    _feedRebuildDebounce = Timer(delay, () {
      if (!mounted) return;
      // âœ… طھط­ظ‚ظ‚ ط£ظ† ط§ظ„ظ…ط³طھط®ط¯ظ… ظ„ط§ ظٹطھظ…ط±ط±
      if (_feedScrollController.hasClients &&
          _feedScrollController.position.isScrollingNotifier.value) {
        // ط£ط¬ظ‘ظ„ ط¥ط°ط§ ظƒط§ظ† ظٹطھظ…ط±ط±
        _scheduleRebuildFeed(immediate: false);
        return;
      }
      _applyBuiltFeed();
    });
  }

  Future<void> _applyBuiltFeed() async {
    if (_videoPool.isEmpty && _shortsPool.isEmpty) return;

    // âœ… ط¨ظ†ط§ط، ط§ظ„ظپظٹط¯ ظپظٹ isolate ظ…ظ†ظپطµظ„ ط¨ط¯ظˆظ† طھط¹ظ„ظٹظ‚
    final feed = await compute(_buildFeedInBackground, {
      'videos': _videoPool.map((v) => v.id).toList(),
      'shorts': _shortsPool.map((v) => v.id).toList(),
    }).then((_) async {
      return await ChannelsFeedRecommenderService.buildSmartFeed(
        pool: List.from(_videoPool),
        shortsPool: List.from(_shortsPool),
        sessionSeed: _feedSessionSeed,
      );
    });

    final newVideos = feed.videos;
    final newShorts = feed.shorts;
    final newShowingRecent = feed.showingRecent;

    if (!mounted) return;

    final changed =
        !_sameVideoIds(_lastBuiltVideos, newVideos) ||
            !_sameVideoIds(_lastBuiltShorts, newShorts) ||
            _lastBuiltShowingRecent != newShowingRecent;

    if (!changed) return;

    final similarMainFeed = _isFeedSimilar(_lastBuiltVideos, newVideos);
    final similarShortsFeed = _isFeedSimilar(
      _lastBuiltShorts,
      newShorts,
      sample: 6,
      minSame: 4,
    );

    if (similarMainFeed &&
        similarShortsFeed &&
        _lastBuiltShowingRecent == newShowingRecent) {
      return;
    }

    _lastBuiltVideos = List<YoutubeVideo>.from(newVideos);
    _lastBuiltShorts = List<YoutubeVideo>.from(newShorts);
    _lastBuiltShowingRecent = newShowingRecent;
    _hasBuiltInitialFeed = true;

    _videoPool
      ..clear()
      ..addAll(newVideos);

    _shortsPool
      ..clear()
      ..addAll(newShorts);

    // âœ… طھط­ط¯ظٹط« ظپظٹ ط§ظ„ظ€ next frame ظ„طھط¬ظ†ط¨ ط§ظ„طھط¹ظ„ظٹظ‚
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showingRecent = newShowingRecent;
      });
      _setDisplayedFeedFromPool(reset: true);
    });

    unawaited(ChannelsFeedRecommenderService.trackTopFeedExposure(
      _allVideos.take(7).toList(),
    ));

    unawaited(_precacheInitialFeedImages(
      videos: newVideos.take(5).toList(),
      shorts: newShorts.take(2).toList(),
    ));
  }

// âœ… ط¯ط§ظ„ط© ظ…ط³ط§ط¹ط¯ط© ظ„ظ„ظ€ compute (ظٹط¬ط¨ ط£ظ† طھظƒظˆظ† top-level)
  static Map<String, dynamic> _buildFeedInBackground(
      Map<String, dynamic> _) {
    return {};
  }

  List<YoutubeVideo> _limitPerChannel(
      List<YoutubeVideo> videos, {
        int maxPerChannel = 2, // âœ… ظƒط§ظ† 3 â†’ 2
      }) {
    final counts = <String, int>{};
    final seen = <String>{};
    final result = <YoutubeVideo>[];

    for (final video in videos) {
      // âœ… ط¥ط²ط§ظ„ط© ط§ظ„ظ…ظƒط±ط±ط§طھ
      if (!seen.add(video.id)) continue;

      final channelKey =
      video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

      if (channelKey.isEmpty) {
        result.add(video);
        continue;
      }

      final current = counts[channelKey] ?? 0;
      if (current >= maxPerChannel) continue;

      counts[channelKey] = current + 1;
      result.add(video);
    }

    return result;
  }

  void _updatePools({
    required List<YoutubeVideo> videos,
    required List<YoutubeVideo> shorts,
    required Set<String> ids,
  }) {
    _videoPool
      ..clear()
      ..addAll(videos);

    _shortsPool
      ..clear()
      ..addAll(shorts);

    _loadedVideoIds
      ..clear()
      ..addAll(ids);
  }

  (String, String?) _extractYoutubeChannelIdentity(Map<String, dynamic> scholar) {
    final platforms = scholar['platforms'] as List<dynamic>? ?? [];
    for (final p in platforms) {
      final pm = Map<String, dynamic>.from(p);
      if (pm['icon'] == 'youtube') {
        final key = (pm['url']?.toString().isNotEmpty == true)
            ? pm['url'].toString()
            : (pm['handle']?.toString() ?? scholar['name']?.toString() ?? '');
        return (key, pm['handle']?.toString());
      }
    }
    return (scholar['name']?.toString() ?? '', null);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Fetch: first paint / progressive / background
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _fetchFirstPaintVideos(List<Map<String, dynamic>> scholars) async {
    final allVids = <YoutubeVideo>[];
    final shorts = <YoutubeVideo>[];
    final seenIds = <String>{};

    // âœ… طھط±طھظٹط¨ ط­ط³ط¨ Usage Score
    final prioritized = List<Map<String, dynamic>>.from(scholars)
      ..sort((a, b) {
        final aChannel = _extractYoutubeChannelIdentity(a);
        final bChannel = _extractYoutubeChannelIdentity(b);
        final aScore = ChannelUsageService.getPriorityScore(aChannel.$1);
        final bScore = ChannelUsageService.getPriorityScore(bChannel.$1);
        return bScore.compareTo(aScore);
      });

    // âœ… ط£ط®ط° ط£ط¹ظ„ظ‰ 3 ظ‚ظ†ظˆط§طھ ظپظ‚ط· ظ„ظ„ط³ط±ط¹ط© ط§ظ„ظ‚طµظˆظ‰
    final topFew = prioritized.take(3).toList();

    // âœ… طھط­ظ…ظٹظ„ ظ…طھظˆط§ط²ظٹ ط¨ط¯ظ„ طھط³ظ„ط³ظ„ظٹ
    await Future.wait(topFew.map((scholar) async {
      final platforms = scholar['platforms'] as List<dynamic>? ?? [];
      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          try {
            final vids = await YoutubeService.getChannelVideos(
              channelUrl: pm['url'] ?? '',
              handle: pm['handle'],
              channelId: pm['channelId']?.toString(),
              maxResults: 4,
            );

            for (final v in vids) {
              if (v.id.isEmpty || v.title.trim().isEmpty) continue;
              if (seenIds.add(v.id)) {
                if (YoutubeService.isLikelyShortVideo(v)) {
                  shorts.add(v);
                } else {
                  allVids.add(v);
                }
              }
            }
          } catch (_) {}
          break;
        }
      }
    }));

    if (allVids.isEmpty && shorts.isEmpty) return;

    allVids.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    shorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // âœ… ط­ط¯ 2 ظپظٹط¯ظٹظˆ ظ„ظƒظ„ ظ‚ظ†ط§ط©
    final limitedRegular = _limitPerChannel(allVids, maxPerChannel: 2);
    final limitedShorts = _limitPerChannel(shorts, maxPerChannel: 2);

    _updatePools(videos: limitedRegular, shorts: limitedShorts, ids: seenIds);

    // âœ… ط§ط³طھط®ط¯ظ… buildFastFeed ط¨ط¯ظ„ buildSmartFeed ظ„ظ„ط³ط±ط¹ط©
    final feed = await ChannelsFeedRecommenderService.buildFastFeed(
      pool: List.from(_videoPool),
      shortsPool: List.from(_shortsPool),
      sessionSeed: _feedSessionSeed,
    );

    if (!mounted) return;

    _lastBuiltVideos = List<YoutubeVideo>.from(feed.videos);
    _lastBuiltShorts = List<YoutubeVideo>.from(feed.shorts);
    _lastBuiltShowingRecent = feed.showingRecent;

    setState(() {
      _allVideos = feed.videos;
      _shortsVideos = feed.shorts;
      _showingRecent = feed.showingRecent;
      _loadingVideos = false;
    });

    _notifyFeedChanged();

    // âœ… precache ظپظٹ ط§ظ„ط®ظ„ظپظٹط©
    unawaited(_precacheInitialFeedImages(
      videos: feed.videos,
      shorts: feed.shorts,
    ));

    unawaited(_prefetchNextBatch());

    // âœ… Track
    unawaited(ChannelsFeedRecommenderService.trackTopFeedExposure(
      feed.videos.take(7).toList(),
    ));

    unawaited(VideoHistoryService.markManyAsShown(
      feed.videos.take(12).map((v) => v.id).toList(),
    ));
  }

  Future<void> _fetchAllVideos(List<Map<String, dynamic>> scholars) async {
    await _fetchFirstPaintVideos(scholars);

    Future.delayed(const Duration(milliseconds: 700), () async {
      if (!mounted) return;
      await _fetchAllVideosProgressive(scholars);
    });
  }

  Future<void> _fetchAllVideosProgressive(
      List<Map<String, dynamic>> scholars,
      ) async {
    if (_progressiveRunning) return;
    _progressiveRunning = true;

    final initialPoolCount = _videoPool.length + _shortsPool.length;

    final allVids = List<YoutubeVideo>.from(_videoPool);
    final shorts = List<YoutubeVideo>.from(_shortsPool);
    final seenIds = Set<String>.from(_loadedVideoIds);

    try {
      final shuffled = List<Map<String, dynamic>>.from(scholars)
        ..shuffle(Random());

      shuffled.sort((a, b) {
        final aChannel = _extractYoutubeChannelIdentity(a);
        final bChannel = _extractYoutubeChannelIdentity(b);
        final aScore = ChannelUsageService.getPriorityScore(aChannel.$1);
        final bScore = ChannelUsageService.getPriorityScore(bChannel.$1);
        return bScore.compareTo(aScore);
      });

      // âœ… ط¯ظپط¹ط§طھ ط£ظƒط¨ط± = ط·ظ„ط¨ط§طھ ط´ط¨ظƒط© ط£ظ‚ظ„
      for (int i = 0; i < shuffled.length; i += 4) {
        final batch = shuffled.skip(i).take(4).toList();

        await Future.wait(batch.map((s) async {
          final platforms = s['platforms'] as List<dynamic>? ?? [];
          for (final p in platforms) {
            final pm = Map<String, dynamic>.from(p);
            if (pm['icon'] == 'youtube') {
              try {
                final vids = await YoutubeService.getChannelLatestBatch(
                  channelUrl: pm['url'] ?? '',
                  handle: pm['handle'],
                  channelId: pm['channelId']?.toString(),
                  maxResults: 10, // âœ… ظƒط§ظ† 15 â†’ 10
                );

                for (final v in vids) {
                  if (v.id.isEmpty || v.title.trim().isEmpty) continue;
                  if (seenIds.add(v.id)) {
                    if (YoutubeService.isLikelyShortVideo(v)) {
                      shorts.add(v);
                    } else {
                      allVids.add(v);
                    }
                  }
                }
              } catch (_) {}
              break;
            }
          }
        }));

        // âœ… طھط±طھظٹط¨ ظˆطھط­ط¯ظٹط« ظƒظ„ 12 ظ‚ظ†ط§ط© ط¨ط¯ظ„ 9
        if (i > 0 && i % 12 == 0) {
          allVids.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
          shorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

          final limitedRegular = _limitPerChannel(allVids, maxPerChannel: 2);
          final limitedShorts = _limitPerChannel(shorts, maxPerChannel: 2);

          _updatePools(
            videos: limitedRegular,
            shorts: limitedShorts,
            ids: seenIds,
          );

          // âœ… ظ„ط§ طھط­ط¯ظ‘ط« ط¥ط°ط§ ط§ظ„ظ…ط³طھط®ط¯ظ… ظٹطھظ…ط±ط±
          if (i > 0 && i % 12 == 0 && !_suspendProgressiveUpdates) {
            _scheduleRebuildFeed();
          }

        }

        // âœ… طھط£ط®ظٹط± ط£ظ‚ظ„
        await Future.delayed(const Duration(milliseconds: 50));
      }

      allVids.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      shorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      final limitedRegular = _limitPerChannel(allVids, maxPerChannel: 2);
      final limitedShorts = _limitPerChannel(shorts, maxPerChannel: 2);

      _updatePools(
        videos: limitedRegular,
        shorts: limitedShorts,
        ids: seenIds,
      );

      if ((_videoPool.isNotEmpty || _shortsPool.isNotEmpty) && mounted) {
        await FeedCacheService.saveFeed(
          videos: _videoPool,
          shorts: _shortsPool,
        );
      }

      final finalPoolCount = _videoPool.length + _shortsPool.length;
      if (finalPoolCount - initialPoolCount >= 4) {
        await _applyBuiltFeed();
      }
    } finally {
      _progressiveRunning = false;
      if (mounted) {
        setState(() {
          _loadingVideos = false;
        });
      }
    }
  }

  Future<void> _fetchAllVideosBackground(
      List<Map<String, dynamic>> scholars,
      ) async {
    try {
      final oldCount = _videoPool.length + _shortsPool.length;

      final result = await _collectVideosFromScholars(
        scholars: scholars,
        maxPerChannel: 15,
      );

      if (result.$1.isEmpty && result.$2.isEmpty) return;

      await FeedCacheService.saveFeed(
        videos: result.$1,
        shorts: result.$2,
      );

      final limitedRegular = _limitPerChannel(result.$1, maxPerChannel: 3);
      final limitedShorts = _limitPerChannel(result.$2, maxPerChannel: 3);

      _updatePools(
        videos: limitedRegular,
        shorts: limitedShorts,
        ids: result.$3,
      );

      final newCount = _videoPool.length + _shortsPool.length;

      final oldTopIds = _allVideos.take(8).map((e) => e.id).toSet();
      final newTopIds = limitedRegular.take(8).map((e) => e.id).toSet();

      bool topChanged = false;
      for (final id in newTopIds) {
        if (!oldTopIds.contains(id)) {
          topChanged = true;
          break;
        }
      }

      if ((newCount - oldCount >= 6) || topChanged) {
        final fastFeed = await ChannelsFeedRecommenderService.buildFastFeed(
          pool: List.from(_videoPool),
          shortsPool: List.from(_shortsPool),
          sessionSeed: DateTime.now().millisecondsSinceEpoch,
        );

        if (!mounted) return;

        final similarMainFeed = _isFeedSimilar(_allVideos, fastFeed.videos);
        final similarShortsFeed = _isFeedSimilar(
          _shortsVideos,
          fastFeed.shorts,
          sample: 6,
          minSame: 4,
        );

        if (!(similarMainFeed &&
            similarShortsFeed &&
            _showingRecent == fastFeed.showingRecent)) {
          setState(() {
            _allVideos = fastFeed.videos;
            _shortsVideos = fastFeed.shorts;
            _showingRecent = fastFeed.showingRecent;
          });

          _lastBuiltVideos = List<YoutubeVideo>.from(fastFeed.videos);
          _lastBuiltShorts = List<YoutubeVideo>.from(fastFeed.shorts);
          _lastBuiltShowingRecent = fastFeed.showingRecent;
          _notifyFeedChanged();
        }
      }
    } catch (e) {
      debugPrint('❌ Background fetch error: $e');
    }
  }

  Future<(List<YoutubeVideo>, List<YoutubeVideo>, Set<String>)>
  _collectVideosFromScholars({
    required List<Map<String, dynamic>> scholars,
    int maxPerChannel = 8,
  }) async {
    final allVids = <YoutubeVideo>[];
    final shorts = <YoutubeVideo>[];
    final seenIds = <String>{};

    final shuffled = List<Map<String, dynamic>>.from(scholars)..shuffle(Random());

    shuffled.sort((a, b) {
      final aChannel = _extractYoutubeChannelIdentity(a);
      final bChannel = _extractYoutubeChannelIdentity(b);

      final aScore = ChannelUsageService.getPriorityScore(aChannel.$1);
      final bScore = ChannelUsageService.getPriorityScore(bChannel.$1);

      return bScore.compareTo(aScore);
    });

    for (final s in shuffled.take(3)) {
      final platforms = s['platforms'] as List<dynamic>? ?? [];
      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          try {
            final vids = await YoutubeService.getChannelVideos(
              channelUrl: pm['url'] ?? '',
              handle: pm['handle'],
              channelId: pm['channelId']?.toString(),
              maxResults: maxPerChannel,
            );

            for (final v in vids) {
              if (v.id.isEmpty || v.title.trim().isEmpty) continue;

              if (seenIds.add(v.id)) {
                if (YoutubeService.isLikelyShortVideo(v)) {
                  shorts.add(v);
                } else {
                  allVids.add(v);
                }
              }
            }
          } catch (_) {}
          break;
        }
      }
    }

    allVids.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    shorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return (allVids, shorts, seenIds);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Refresh / Load more
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _refreshFeed() async {
    if (_refreshInProgress) return;
    _refreshInProgress = true;

    try {
      if (_scholars.isEmpty) return;

      final sampled = List<Map<String, dynamic>>.from(_scholars)
        ..shuffle(Random());
      final selected = sampled.take(3).toList();

      final result = await _collectVideosFromScholars(
        scholars: selected,
        maxPerChannel: 4,
      );

      if (result.$1.isEmpty && result.$2.isEmpty) return;

      final currentIds = <String>{
        ..._videoPool.map((e) => e.id),
        ..._shortsPool.map((e) => e.id),
      };

      final mergedVideos = <YoutubeVideo>[
        ...result.$1.where((v) => !currentIds.contains(v.id)),
        ..._videoPool,
      ];

      final mergedShorts = <YoutubeVideo>[
        ...result.$2.where((v) => !currentIds.contains(v.id)),
        ..._shortsPool,
      ];

      mergedVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      mergedShorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      final built = await ChannelsFeedRecommenderService.buildFastFeed(
        pool: mergedVideos.take(80).toList(),
        shortsPool: mergedShorts.take(30).toList(),
        sessionSeed: DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;

      final similarMainFeed = _isFeedSimilar(_allVideos, built.videos);
      final similarShortsFeed = _isFeedSimilar(
        _shortsVideos,
        built.shorts,
        sample: 6,
        minSame: 4,
      );

      // âœ… ظ„ط§ طھط­ط¯ظ‘ط« ط¥ط°ط§ ط§ظ„طھط؛ظٹظٹط± ط·ظپظٹظپ
      if (similarMainFeed &&
          similarShortsFeed &&
          _showingRecent == built.showingRecent) {
        return;
      }

      _videoPool
        ..clear()
        ..addAll(built.videos);

      _shortsPool
        ..clear()
        ..addAll(built.shorts);

      _loadedVideoIds
        ..clear()
        ..addAll({
          ...built.videos.map((e) => e.id),
          ...built.shorts.map((e) => e.id),
        });

      // âœ… طھط­ط¯ظٹط« ظپظٹ ط§ظ„ظ€ next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _allVideos = List<YoutubeVideo>.from(built.videos);
          _shortsVideos = List<YoutubeVideo>.from(built.shorts);
          _showingRecent = built.showingRecent;
        });

        _lastBuiltVideos = List<YoutubeVideo>.from(built.videos);
        _lastBuiltShorts = List<YoutubeVideo>.from(built.shorts);
        _lastBuiltShowingRecent = built.showingRecent;
        _notifyFeedChanged();
      });

      unawaited(ChannelsFeedRecommenderService.trackTopFeedExposure(
        built.videos.take(7).toList(),
      ));

      unawaited(_precacheInitialFeedImages(
        videos: built.videos.take(5).toList(),
        shorts: built.shorts.take(2).toList(),
      ));

      unawaited(FeedCacheService.saveFeed(
        videos: built.videos,
        shorts: built.shorts,
        showingRecent: built.showingRecent,
      ));
    } catch (e) {
      debugPrint('❌ refreshFeed error: $e');
    } finally {
      _refreshInProgress = false;
    }
  }

  void _onFeedScroll() {
    if (_tabController.index != 0) return;
    if (!_feedScrollController.hasClients) return;
    if (_loadingVideos) return;

    final pos = _feedScrollController.position;
    final max = pos.maxScrollExtent;
    final cur = pos.pixels;

    if (max <= 0) return;

    final ratio = cur / max;

    // âœ… Prefetch ظ…ط¨ظƒط± ط¬ط¯ط§ظ‹ ط¹ظ†ط¯ 50%
    if (!_prefetchingNextBatch &&
        _prefetchedRegularVideos.isEmpty &&
        ratio >= 0.50) {
      unawaited(_prefetchNextBatch());
    }

    // âœ… طھط­ظ…ظٹظ„ طھظ„ظ‚ط§ط¦ظٹ ط¹ظ†ط¯ 75% ط¨ط¯ظˆظ† ط¶ط؛ط·
    if (!_loadingMore && _hasMoreVideos && ratio >= 0.75) {
      unawaited(_autoLoadMore());
    }
  }

// âœ… طھط­ظ…ظٹظ„ طھظ„ظ‚ط§ط¦ظٹ ط­ظ‚ظٹظ‚ظٹ
  Future<void> _autoLoadMore() async {
    if (_loadingMore || !_hasMoreVideos) return;

    // ط£ظˆظ„ط§ظ‹ ط§ط³طھظ‡ظ„ظƒ ظ…ط§ طھظ… ط¬ظ„ط¨ظ‡ ظ…ط³ط¨ظ‚ط§ظ‹
    if (_prefetchedRegularVideos.isNotEmpty ||
        _prefetchedShortsVideos.isNotEmpty) {
      await _consumePrefetchedBatch();
      return;
    }

    // ط¥ط°ط§ ظ„ط§ ظٹظˆط¬ط¯ prefetchطŒ ط­ظ…ظ‘ظ„ ظ…ط¨ط§ط´ط±ط©
    await _loadMoreVideos();
  }

  Future<void> _loadMoreVideos() async {
    if (_loadingMore || !_hasMoreVideos || !mounted) return;

    if (_loadAttempts >= 5) {
      if (mounted) setState(() => _hasMoreVideos = false);
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final newRegular = <YoutubeVideo>[];
      final newShorts = <YoutubeVideo>[];

      final existingIds = <String>{
        ..._loadedVideoIds,
        ..._allVideos.map((v) => v.id),
      };

      // âœ… ط§ط®طھط§ط± ظ‚ظ†ظˆط§طھ ظ…طھظ†ظˆط¹ط© ط°ظƒظٹط§ظ‹
      final selectedScholars = _selectDiverseScholars(count: 6);

      // âœ… طھط­ظ…ظٹظ„ ظ…طھظˆط§ط²ظٹ
      await Future.wait(
        selectedScholars.asMap().entries.map((entry) async {
          final i = entry.key;
          final scholar = entry.value;
          final platforms = scholar['platforms'] as List<dynamic>? ?? [];

          for (final p in platforms) {
            final pm = Map<String, dynamic>.from(p);
            if (pm['icon'] != 'youtube') continue;

            try {
              final terms = [
                '', 'محاضرة', 'درس', 'تفسير', 'فتوى',
                'شرح', 'حديث', 'قرآن', 'موعظة', 'سيرة',
              ];
              final term = terms[(_loadAttempts * 2 + i) % terms.length];

              final vids = term.isEmpty
                  ? await YoutubeService.getChannelLatestBatch(
                channelUrl: pm['url'] ?? '',
                handle: pm['handle'],
                channelId: pm['channelId']?.toString(),
                maxResults: 8,
              )
                  : await YoutubeService.searchInChannelByUrl(
                channelUrl: pm['url'] ?? '',
                handle: pm['handle'],
                channelId: pm['channelId']?.toString(),
                query: term,
                maxResults: 6,
              );

              int added = 0;
              for (final v in vids) {
                if (v.id.isEmpty || v.title.trim().isEmpty) continue;
                if (existingIds.contains(v.id)) continue;
                existingIds.add(v.id);

                if (YoutubeService.isLikelyShortVideo(v)) {
                  newShorts.add(v);
                } else {
                  newRegular.add(v);
                }

                added++;
                if (added >= 3) break;
              }
            } catch (_) {}
            break;
          }
        }),
      );

      if (newRegular.isEmpty && newShorts.isEmpty) {
        _loadAttempts++;
        if (_loadAttempts >= 5 && mounted) {
          setState(() => _hasMoreVideos = false);
        }
        return;
      }

      _loadAttempts = 0;

      // âœ… طھظ†ظˆظٹط¹ ظ‚ط¨ظ„ ط§ظ„ط¥ط¶ط§ظپط©
      final diversified = _diversifyBeforeAdding(
        existing: _videoPool,
        newVideos: newRegular,
      );

      for (final v in diversified) {
        _loadedVideoIds.add(v.id);
        _videoPool.add(v);
      }

      for (final v in _limitPerChannel(newShorts, maxPerChannel: 2)) {
        _loadedVideoIds.add(v.id);
        _shortsPool.add(v);
      }

      if (mounted) {
        _setDisplayedFeedFromPool(reset: false);
      }

      unawaited(FeedCacheService.saveFeed(
        videos: _videoPool,
        shorts: _shortsPool,
        showingRecent: _showingRecent,
      ));
    } catch (e) {
      debugPrint('❌ _loadMoreVideos error: $e');
      _loadAttempts++;
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // âœ… ط§ط®طھظٹط§ط± ظ‚ظ†ظˆط§طھ ظ…طھظ†ظˆط¹ط© ط°ظƒظٹط§ظ‹
  List<Map<String, dynamic>> _selectDiverseScholars({required int count}) {
    if (_scholars.isEmpty) return [];

    // طھط±طھظٹط¨ ط¹ط´ظˆط§ط¦ظٹ ظ…ط¹ ط£ظˆظ„ظˆظٹط© ظ„ظ„ط§ط³طھط®ط¯ط§ظ…
    final shuffled = List<Map<String, dynamic>>.from(_scholars)
      ..shuffle(Random());

    // ظپطµظ„ ط§ظ„ظ‚ظ†ظˆط§طھ ط­ط³ط¨ ط§ظ„ط§ط³طھط®ط¯ط§ظ…
    final highUsage = <Map<String, dynamic>>[];
    final mediumUsage = <Map<String, dynamic>>[];
    final lowUsage = <Map<String, dynamic>>[];

    for (final scholar in shuffled) {
      final identity = _extractYoutubeChannelIdentity(scholar);
      final score = ChannelUsageService.getPriorityScore(identity.$1);

      if (score >= 8) {
        highUsage.add(scholar);
      } else if (score >= 3) {
        mediumUsage.add(scholar);
      } else {
        lowUsage.add(scholar);
      }
    }

    // âœ… طھظˆط²ظٹط¹: 30% ط¹ط§ظ„ظٹ + 40% ظ…طھظˆط³ط· + 30% ظ…ظ†ط®ظپط¶
    // ظٹط¶ظ…ظ† ط§ظ„طھظ†ظˆط¹ ظˆظٹظ…ظ†ط¹ ط§ظ„ط³ظٹط·ط±ط©
    final result = <Map<String, dynamic>>[];

    final highCount = max(1, (count * 0.30).round());
    final medCount = max(1, (count * 0.40).round());
    final lowCount = count - highCount - medCount;

    result.addAll(highUsage.take(highCount));
    result.addAll(mediumUsage.take(medCount));
    result.addAll(lowUsage.take(max(1, lowCount)));

    // ط£ظƒظ…ظ„ ط¥ط°ط§ ظ„ظ… ظٹظƒطھظ…ظ„ ط§ظ„ط¹ط¯ط¯
    if (result.length < count) {
      final remaining = [...highUsage, ...mediumUsage, ...lowUsage]
          .where((s) => !result.contains(s))
          .take(count - result.length);
      result.addAll(remaining);
    }

    // âœ… ط£ط²ظ„ ط§ظ„ظ‚ظ†ظˆط§طھ ط§ظ„ظ…ط³ظٹط·ط±ط© ظ…ظ† ط¢ط®ط± ط¹ط±ط¶
    final recentChannels = _allVideos
        .take(6)
        .map((v) => v.channelId.isNotEmpty ? v.channelId : v.channelTitle)
        .toSet();

    result.sort((a, b) {
      final aId = _extractYoutubeChannelIdentity(a).$1;
      final bId = _extractYoutubeChannelIdentity(b).$1;
      final aRecent = recentChannels.contains(aId) ? 1 : 0;
      final bRecent = recentChannels.contains(bId) ? 1 : 0;
      return aRecent.compareTo(bRecent); // ط§ظ„ط£ظ‚ظ„ ط¸ظ‡ظˆط±ط§ظ‹ ط£ظˆظ„ط§ظ‹
    });

    return result.take(count).toList();
  }

// âœ… طھظ†ظˆظٹط¹ ط§ظ„ظپظٹط¯ظٹظˆظ‡ط§طھ ط§ظ„ط¬ط¯ظٹط¯ط© ظ…ط¹ ط§ظ„ظ…ظˆط¬ظˆط¯ط©
  List<YoutubeVideo> _diversifyBeforeAdding({
    required List<YoutubeVideo> existing,
    required List<YoutubeVideo> newVideos,
  }) {
    if (newVideos.isEmpty) return [];

    // ط­ط³ط§ط¨ ط¹ط¯ط¯ ط§ظ„ظپظٹط¯ظٹظˆظ‡ط§طھ ظ„ظƒظ„ ظ‚ظ†ط§ط© ظپظٹ ط§ظ„ظ€ pool ط§ظ„ط­ط§ظ„ظٹ
    final channelCounts = <String, int>{};
    for (final v in existing) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      channelCounts[ch] = (channelCounts[ch] ?? 0) + 1;
    }

    // âœ… ط§ظ„ط­ط¯ ط§ظ„ظ…ط³ظ…ظˆط­ ط¨ظ‡ ط­ط³ط¨ ط­ط¬ظ… ط§ظ„ظ€ pool
    final poolSize = max(1, existing.length);
    final channelCount = max(1, channelCounts.keys.length);
    final idealMax = max(3, (poolSize / channelCount).ceil());
    final hardMax = min(idealMax, 4); // ط­ط¯ ظ…ط·ظ„ظ‚ 4

    // ط£ظˆظ„ظˆظٹط© ظ„ظ„ظ‚ظ†ظˆط§طھ ط§ظ„ط£ظ‚ظ„ طھظ…ط«ظٹظ„ط§ظ‹
    final sorted = List<YoutubeVideo>.from(newVideos)..sort((a, b) {
      final aCh = a.channelId.isNotEmpty ? a.channelId : a.channelTitle;
      final bCh = b.channelId.isNotEmpty ? b.channelId : b.channelTitle;
      final aCount = channelCounts[aCh] ?? 0;
      final bCount = channelCounts[bCh] ?? 0;
      return aCount.compareTo(bCount); // ط§ظ„ط£ظ‚ظ„ ط£ظˆظ„ط§ظ‹
    });

    final result = <YoutubeVideo>[];
    final addedCounts = <String, int>{};

    for (final v in sorted) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      final existingCount = channelCounts[ch] ?? 0;
      final addedCount = addedCounts[ch] ?? 0;

      if (existingCount + addedCount < hardMax) {
        result.add(v);
        addedCounts[ch] = addedCount + 1;
      }
    }

    // ط¥ط°ط§ ظ„ظ… ظٹط¶ظپ ط´ظٹط، (ظƒظ„ ط§ظ„ظ‚ظ†ظˆط§طھ ظپط§ظ‚طھ ط§ظ„ط­ط¯)طŒ ط£ط¶ظپ ط£ظ‚ظ„ظ‡ط§
    if (result.isEmpty && sorted.isNotEmpty) {
      result.add(sorted.first);
    }

    return result;
  }

  bool _isFeedSimilar(
      List<YoutubeVideo> oldList,
      List<YoutubeVideo> newList, {
        int sample = 10,
        int minSame = 7,
      }) {
    if (oldList.isEmpty || newList.isEmpty) return false;

    final oldIds = oldList.take(sample).map((e) => e.id).toSet();
    final newIds = newList.take(sample).map((e) => e.id).toSet();

    int same = 0;
    for (final id in oldIds) {
      if (newIds.contains(id)) same++;
    }

    return same >= minSame;
  }

  Future<List<YoutubeVideo>> _fetchLimitedVideosFromChannel({
    required Map<String, dynamic> platform,
    required int maxResults,
    required int maxAccepted,
    String query = '',
  }) async {
    try {
      final List<YoutubeVideo> raw;

      if (query.isEmpty) {
        raw = await YoutubeService.getChannelLatestBatch(
          channelUrl: platform['url'] ?? '',
          handle: platform['handle'],
          channelId: platform['channelId']?.toString(),
          maxResults: maxResults,
        );
      } else {
        raw = await YoutubeService.searchInChannelByUrl(
          channelUrl: platform['url'] ?? '',
          handle: platform['handle'],
          channelId: platform['channelId']?.toString(),
          query: query,
          maxResults: maxResults,
        );
      }

      if (raw.isEmpty) return [];

      final out = <YoutubeVideo>[];
      for (final v in raw) {
        out.add(v);
        if (out.length >= maxAccepted) break;
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Search
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() => _searchQuery = value);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (value.isNotEmpty && _tabController.index == 0) {
        _performSearch();
      } else if (value.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _searchResults.clear();
      _isSearching = false;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    if (mounted) {
      setState(() => _isSearching = true);
    }

    try {
      final rawResults = await YoutubeService.searchVideos(
        query: _searchQuery,
        maxResults: 40,
      );

      final ranked = SearchRankingService.rankResults(
        query: _searchQuery,
        results: rawResults,
      );

      for (final v in ranked.take(10)) {
        final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
        if (ch.isNotEmpty) {
          await ChannelUsageService.markSearchHit(ch);
        }
      }

      if (!mounted) return;
      setState(() {
        _searchResults = ranked;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Resume watching
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<YoutubeVideo> _buildResumeWatchingVideos() {
    final resumeIds = VideoHistoryService.getResumeVideoIds(limit: 12);
    if (resumeIds.isEmpty) return [];

    final map = <String, YoutubeVideo>{};

    for (final v in _videoPool) {
      map[v.id] = v;
    }
    for (final v in _shortsPool) {
      map[v.id] = v;
    }
    for (final v in _allVideos) {
      map[v.id] = v;
    }
    for (final v in _shortsVideos) {
      map[v.id] = v;
    }

    final items = <YoutubeVideo>[];
    for (final id in resumeIds) {
      final video = map[id];
      if (video != null && !YoutubeService.isLikelyShortVideo(video)) {
        items.add(video);
      }
    }

    return items;
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Navigation
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _openVideoPlayer(YoutubeVideo video) async {
    // âœ… طھط³ط¬ظٹظ„ ط§ظ„ط¶ط؛ط· ظپظٹ ظ†ط¸ط§ظ… ط§ظ„ط§ظ‡طھظ…ط§ظ…ط§طھ
    unawaited(UserInterestService.trackVideoClick(
      videoId: video.id,
      channelId: video.channelId,
      channelTitle: video.channelTitle,
      videoTitle: video.title,
      description: video.description,
    ));

    final topVisibleIds = _allVideos.take(7).map((v) => v.id).toSet();
    if (topVisibleIds.contains(video.id)) {
      unawaited(ChannelsFeedRecommenderService.trackTopFeedClick(video));
    }

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

    await ChannelUsageService.markVideoStarted(
      channelId: channelKey,
      videoId: video.id,
    );

    final isShort = YoutubeService.isLikelyShortVideo(video);

    if (isShort) {
      final shortsList = _shortsVideos.isNotEmpty ? _shortsVideos : [video];
      final index = shortsList.indexWhere((v) => v.id == video.id);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShortsPlayerScreen(
            shorts: shortsList,
            initialIndex: index >= 0 ? index : 0,
          ),
        ),
      );

      if (mounted && !_loadingVideos) setState(() {});
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: TimeFormatHelper.shortTimeAgoArabic(video.publishedAt),
        ),
      ),
    );

    if (mounted && !_loadingVideos) setState(() {});
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Build
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = ChannelsTheme(isDark: isDark);
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: t.scaffoldBg,
          body: SafeArea(
            child: _loading
                ? _LoadingView(theme: t)
                : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _Header(
                      theme: t,
                      w: w,
                      count: _scholars.length,
                      onBack: () => Navigator.pop(context),
                    ),
                    _SearchBar(
                      theme: t,
                      w: w,
                      controller: _searchController,
                      focused: _searchFocused,
                      query: _searchQuery,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                      onFocusChanged: (f) {
                        if (!mounted) return;
                        setState(() => _searchFocused = f);
                      },
                      onSubmit: _performSearch,
                    ),
                    SizedBox(height: w * 0.015),
                    _TabBar(theme: t, w: w, controller: _tabController),
                    SizedBox(height: w * 0.01),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildYoutubeTab(t, w),
                          _buildTiktokTab(t, w),
                          _buildScholarsTab(t, w),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Tabs
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildYoutubeTab(ChannelsTheme t, double w) {
    if (_loadingVideos && _allVideos.isEmpty && _shortsVideos.isEmpty) {
      return _VideoShimmer(theme: t, w: w);
    }

    if (_isSearching) {
      return Center(child: CircularProgressIndicator(color: t.primaryColor));
    }

    final videos = _searchQuery.isNotEmpty && _searchResults.isNotEmpty
        ? _searchResults
        : _allVideos;

    final resumeWatching =
    _searchQuery.isEmpty ? _buildResumeWatchingVideos() : <YoutubeVideo>[];

    if (videos.isEmpty && _shortsVideos.isEmpty) {
      return _EmptyView(theme: t, w: w, title: 'لا توجد فيديوهات');
    }

    // âœ… ط¨ظ†ط§ط، ظ‚ط§ط¦ظ…ط© ظ…ط³ط·ط­ط© ظ…ط±ط© ظˆط§ط­ط¯ط©
    final flatItems = _buildFlatFeedList(videos, t, w);

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: t.primaryColor,
      strokeWidth: 2,
      displacement: 28,
      child: CustomScrollView(
        controller: _feedScrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        cacheExtent: 800,
        slivers: [

          // â•گâ•گâ•گ Header â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: _FeedHeader(
              theme: t,
              w: w,
              isLoading: _loadingVideos && !_refreshInProgress,
              showingRecent: _showingRecent,
              watchedCount: VideoHistoryService.watchedCount,
              resumeWatching: resumeWatching,
              onVideoTap: _openVideoPlayer,
            ),
          ),

          // â•گâ•گâ•گ Feed Items â•گâ•گâ•گ
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= flatItems.length) return null;
                return flatItems[index];
              },
              childCount: flatItems.length,
              // âœ… طھظ‚ط¯ظٹط± ط§ظ„ط§ط±طھظپط§ط¹ ظ„طھط¬ظ†ط¨ ط§ظ„ط­ط³ط§ط¨ط§طھ
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              addSemanticIndexes: false,
            ),
          ),

          // â•گâ•گâ•گ Footer â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: _FeedFooter(
              isLoading: _loadingMore,
              hasMore: _hasMoreVideos,
              theme: t,
              w: w,
              onRefresh: _refreshFeed,
              onLoadMore: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_loadingMore && _hasMoreVideos) {
                    unawaited(_autoLoadMore());
                  }
                });
              },
            ),
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: w * 0.08)),
        ],
      ),
    );
  }

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط¨ظ†ط§ط، ظ‚ط§ط¦ظ…ط© ظ…ط³ط·ط­ط© - ط¨ط¯ظˆظ† ظ†ط³طھط¯ ظˆط¯ظˆظ† ط¥ط¹ط§ط¯ط© ط¨ظ†ط§ط،
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  List<Widget> _buildFlatFeedList(
      List<YoutubeVideo> videos,
      ChannelsTheme t,
      double w,
      ) {
    // âœ… ط§ط³طھط®ط¯ظ… ط§ظ„ظ€ cache ط¥ط°ط§ ظ„ظ… ظٹطھط؛ظٹط± ط§ظ„ظپظٹط¯
    if (_cachedFeedVersion == _feedVersion.value &&
        _cachedFeedItems.isNotEmpty) {
      return _cachedFeedItems;
    }

    // ط¥ط²ط§ظ„ط© ط§ظ„ظ…ظƒط±ط±ط§طھ
    final seenIds = <String>{};
    final uniqueVideos = <YoutubeVideo>[];
    for (final v in videos) {
      if (v.id.isNotEmpty && seenIds.add(v.id)) {
        uniqueVideos.add(v);
      }
    }

    final seenShortIds = <String>{};
    final uniqueShorts = <YoutubeVideo>[];
    for (final v in _shortsVideos) {
      if (v.id.isNotEmpty && seenShortIds.add(v.id)) {
        uniqueShorts.add(v);
      }
    }

    final items = <Widget>[];
    int shortsIndex = 0;
    bool firstShortsShown = false;

    for (int i = 0; i < uniqueVideos.length; i++) {
      final video = uniqueVideos[i];

      items.add(
        RepaintBoundary(
          child: _YTVideoCard(
            key: ValueKey('v_${video.id}'),
            video: video,
            theme: t,
            w: w,
            onTap: () => _openVideoPlayer(video),
            timeAgo: TimeFormatHelper.timeAgoArabic,
          ),
        ),
      );

      if ((i + 1) % 5 == 0 && shortsIndex < uniqueShorts.length) {
        if (!firstShortsShown) {
          firstShortsShown = true;
          final take = min(4, uniqueShorts.length - shortsIndex);
          if (take > 0) {
            items.add(
              RepaintBoundary(
                child: _ShortsSection(
                  key: ValueKey('sg_$i'),
                  shorts: uniqueShorts.skip(shortsIndex).take(take).toList(),
                  isGrid: true,
                  theme: t,
                  w: w,
                  onVideoTap: _openVideoPlayer,
                ),
              ),
            );
            shortsIndex += take;
          }
        } else {
          final take = min(2, uniqueShorts.length - shortsIndex);
          if (take > 0) {
            items.add(
              RepaintBoundary(
                child: _ShortsSection(
                  key: ValueKey('sg_$i'),
                  shorts: uniqueShorts.skip(shortsIndex).take(take).toList(),
                  isGrid: true,
                  theme: t,
                  w: w,
                  onVideoTap: _openVideoPlayer,
                ),
              ),
            );
            shortsIndex += take;
          }
        }
      }
    }

    // âœ… ط§ط­ظپط¸ ظپظٹ ط§ظ„ظ€ cache
    _cachedFeedItems = items;
    _cachedFeedVersion = _feedVersion.value;

    return items;
  }

  Widget _buildTiktokTab(ChannelsTheme t, double w) {
    final list = _searchQuery.isEmpty
        ? _tiktokEntries
        : _tiktokEntries
        .where((e) => (e['scholarName'] ?? '')
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();

    if (list.isEmpty) {
      return _EmptyView(theme: t, w: w, title: 'لا توجد حسابات');
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.02),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: w * 0.025),
      itemBuilder: (_, i) => _TiktokCard(
        data: list[i],
        theme: t,
        w: w,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScholarProfileTiktokScreen(tiktokData: list[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildScholarsTab(ChannelsTheme t, double w) {
    var list = _scholars;

    if (_selectedCategory > 0 && _selectedCategory < _categories.length) {
      list = list
          .where((s) => s['category'] == _categories[_selectedCategory])
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((s) => (s['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        SizedBox(
          height: (w * 0.09).clamp(36.0, 42.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => SizedBox(width: w * 0.02),
            itemBuilder: (_, i) {
              final sel = i == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  if (!mounted) return;
                  setState(() => _selectedCategory = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.035),
                  decoration: BoxDecoration(
                    color: sel ? t.primaryColor : t.chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? t.primaryColor : t.chipBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _categories[i],
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.03).clamp(11.0, 14.0),
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? Colors.white : t.chipText,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: w * 0.015),
        Expanded(
          child: list.isEmpty
              ? _EmptyView(theme: t, w: w, title: 'لا توجد نتائج')
              : ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: w * 0.01,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: w * 0.025),
            itemBuilder: (_, i) => _ScholarCard(
              scholar: list[i],
              theme: t,
              w: w,
              onTap: () async {
                final platforms = list[i]['platforms'] as List<dynamic>? ?? [];
                final hasYT = platforms.any(
                      (p) => Map<String, dynamic>.from(p)['icon'] == 'youtube',
                );

                if (hasYT) {
                  final channelIdentity = _extractYoutubeChannelIdentity(list[i]);
                  if (channelIdentity.$1.isNotEmpty) {
                    await ChannelUsageService.markChannelOpened(channelIdentity.$1);
                  }

                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ScholarProfileYoutubeScreen(scholar: list[i]),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Feed items
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<Widget> _buildFeedItems(
      List<YoutubeVideo> videos,
      ChannelsTheme t,
      double w,
      ) {
    final items = <Widget>[];
    int shortsIndex = 0;
    bool firstShortsShown = false;

    // âœ… ط¥ط²ط§ظ„ط© ظƒظ„ ط§ظ„ظ…ظƒط±ط±ط§طھ ظˆط¶ظ…ط§ظ† ط¹ط¯ظ… ط§ظ„طھطھط§ط¨ط¹
    final seenIds = <String>{};
    final cleanVideos = <YoutubeVideo>[];
    String lastChannelKey = '';

    for (final v in videos) {
      if (v.id.isEmpty || !seenIds.add(v.id)) continue;

      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;

      // âœ… ط¥ط°ط§ ظ†ظپط³ ط§ظ„ظ‚ظ†ط§ط© ط§ظ„ط³ط§ط¨ظ‚ط©طŒ ط£ط¬ظ‘ظ„
      if (ch == lastChannelKey && cleanVideos.length > 1) {
        // ط§ط¨ط­ط« ط¹ظ† ظ…ظƒط§ظ† ظ„ط§ط­ظ‚
        continue; // ط³ظٹطھظ… ط¥ط¶ط§ظپطھظ‡ ظ„ط§ط­ظ‚ط§ظ‹ ط¹ط¨ط± _preventConsecutiveSameChannel
      }

      cleanVideos.add(v);
      lastChannelKey = ch;
    }

    // âœ… ط´ظˆط±طھط³ ظ†ط¸ظٹظپط©
    final seenShortIds = <String>{};
    final cleanShorts = <YoutubeVideo>[];
    for (final v in _shortsVideos) {
      if (v.id.isNotEmpty && seenShortIds.add(v.id)) {
        cleanShorts.add(v);
      }
    }

    for (int i = 0; i < cleanVideos.length; i++) {
      items.add(
        RepaintBoundary(
          child: _YTVideoCard(
            key: ValueKey('vid_${cleanVideos[i].id}'),
            video: cleanVideos[i],
            theme: t,
            w: w,
            onTap: () => _openVideoPlayer(cleanVideos[i]),
            timeAgo: TimeFormatHelper.timeAgoArabic,
          ),
        ),
      );

      if ((i + 1) % 4 == 0 && shortsIndex < cleanShorts.length) {
        if (!firstShortsShown) {
          firstShortsShown = true;
          final take = min(4, cleanShorts.length - shortsIndex);
          if (take > 0) {
            items.add(
              RepaintBoundary(
                child: _ShortsSection(
                  key: ValueKey('shorts_grid_$i'),
                  shorts: cleanShorts.skip(shortsIndex).take(take).toList(),
                  isGrid: true,
                  theme: t,
                  w: w,
                  onVideoTap: _openVideoPlayer,
                ),
              ),
            );
            shortsIndex += take;
          }
        } else {
          final take = min(2, cleanShorts.length - shortsIndex);
          if (take > 0) {
            items.add(
              RepaintBoundary(
                child: _ShortsSection(
                  key: ValueKey('shorts_single_$i'),
                  shorts: cleanShorts.skip(shortsIndex).take(take).toList(),
                  isGrid: false,
                  theme: t,
                  w: w,
                  onVideoTap: _openVideoPlayer,
                ),
              ),
            );
            shortsIndex += take;
          }
        }
      }
    }

    return items;
  }

}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Widgets
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _YTVideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;
  final String Function(DateTime) timeAgo;

  const _YTVideoCard({
    super.key,
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final thumbH = w * 9 / 16;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          // âœ… ط¨ط¯ظˆظ† splash ظ„ط£ظ†ظ‡ ظٹط³ط¨ط¨ ط¥ط¹ط§ط¯ط© ط±ط³ظ…
          splashColor: Colors.transparent,
          highlightColor: theme.isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // â•گâ•گâ•گ Thumbnail â•گâ•گâ•گ
              SizedBox(
                width: double.infinity,
                height: thumbH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // âœ… Thumbnail ظ…ط­ط³ظ‘ظ†
                    _VideoThumbnail(
                      url: video.thumbnail,
                      videoId: video.id,
                      theme: theme,
                    ),

                    // âœ… ظ…ط¯ط© ط§ظ„ظپظٹط¯ظٹظˆ
                    if (video.duration.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _DurationBadge(duration: video.duration, w: w),
                      ),
                  ],
                ),
              ),

              // â•گâ•گâ•گ Info â•گâ•گâ•گ
              Padding(
                padding: EdgeInsets.fromLTRB(
                  w * 0.03, w * 0.025, w * 0.025, w * 0.03,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    _ChannelAvatar(
                      channelTitle: video.channelTitle,
                      theme: theme,
                      w: w,
                    ),

                    SizedBox(width: w * 0.025),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            video.title,
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.038).clamp(13.0, 15.0),
                              fontWeight: FontWeight.w600,
                              color: theme.textColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _buildSubtitle(),
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.029).clamp(10.0, 12.0),
                              color: theme.captionColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: w * 0.01),

                    Icon(
                      Icons.more_vert_rounded,
                      color: theme.captionColor,
                      size: (w * 0.05).clamp(18.0, 22.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (video.channelTitle.isNotEmpty) parts.add(video.channelTitle);

    if (video.viewCount != '0' && video.viewCount.isNotEmpty) {
      parts.add('${YoutubeService.formatViews(video.viewCount)} مشاهدة');
    }

    final progress = VideoHistoryService.getProgress(video.id);
    if (progress > 0 && progress < 0.9) {
      parts.add('${(progress * 100).round()}%');
    }

    parts.add(timeAgo(video.publishedAt));
    return parts.join(' آ· ');
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Thumbnail ظ…ظ†ظپطµظ„ - ظٹظڈط¹ط§ط¯ ط§ط³طھط®ط¯ط§ظ…ظ‡
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _VideoThumbnail extends StatelessWidget {
  final String url;
  final String videoId;
  final ChannelsTheme theme;

  const _VideoThumbnail({
    required this.url,
    required this.videoId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;

    return ImageCacheConfig.videoThumbnail(
      url: url.isNotEmpty
          ? url
          : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
      fit: BoxFit.cover,
      placeholder: ColoredBox(
        color: isDark
            ? const Color(0xFF1E2530)
            : const Color(0xFFE2E8F0),
      ),
      errorWidget: ColoredBox(
        color: isDark
            ? const Color(0xFF1E2530)
            : const Color(0xFFE2E8F0),
        child: Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            size: 36,
            color: isDark
                ? const Color(0xFF475569)
                : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Duration Badge - const
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DurationBadge extends StatelessWidget {
  final String duration;
  final double w;

  const _DurationBadge({required this.duration, required this.w});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: (w * 0.028).clamp(9.0, 11.0),
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Channel Avatar - const
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ChannelAvatar extends StatelessWidget {
  final String channelTitle;
  final ChannelsTheme theme;
  final double w;

  const _ChannelAvatar({
    required this.channelTitle,
    required this.theme,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    final size = (w * 0.09).clamp(32.0, 40.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryLight,
      ),
      child: Center(
        child: Text(
          channelTitle.isNotEmpty ? channelTitle[0] : 'طں',
          style: GoogleFonts.cairo(
            fontSize: (w * 0.038).clamp(13.0, 16.0),
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Feed Header - widget ظ…ظ†ظپطµظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _FeedHeader extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final bool isLoading;
  final bool showingRecent;
  final int watchedCount;
  final List<YoutubeVideo> resumeWatching;
  final Function(YoutubeVideo) onVideoTap;

  const _FeedHeader({
    required this.theme,
    required this.w,
    required this.isLoading,
    required this.showingRecent,
    required this.watchedCount,
    required this.resumeWatching,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: w * 0.015,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Text(
                  'جاري تحديث الفيديوهات...',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 11.0),
                    color: theme.captionColor,
                  ),
                ),
              ],
            ),
          ),

        _FeedModeBanner(
          theme: theme,
          w: w,
          isRecent: showingRecent,
          watchedCount: watchedCount,
        ),

        if (resumeWatching.isNotEmpty)
          _ResumeWatchingSection(
            theme: theme,
            w: w,
            videos: resumeWatching,
            onTap: onVideoTap,
          ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Feed Footer - widget ظ…ظ†ظپطµظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _FeedFooter extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;

  const _FeedFooter({
    required this.isLoading,
    required this.hasMore,
    required this.theme,
    required this.w,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LoadMoreIndicator(theme: theme, w: w);
    }

    if (!hasMore) {
      return _EndOfFeed(theme: theme, w: w, onRefresh: onRefresh);
    }

    // âœ… Trigger ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„طھظ„ظ‚ط§ط¦ظٹ
    onLoadMore();

    return _LoadMoreIndicator(theme: theme, w: w);
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// _ShortsSection - ظ…ط­ط³ظ‘ظ† ط¨ط§ظ„ظƒط§ظ…ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShortsSection extends StatelessWidget {
  final List<YoutubeVideo> shorts;
  final ChannelsTheme theme;
  final double w;
  final bool isGrid;
  final Function(YoutubeVideo) onVideoTap;

  const _ShortsSection({
    super.key,
    required this.shorts,
    required this.theme,
    required this.w,
    required this.isGrid,
    required this.onVideoTap,
  });

  // âœ… Gradient ط«ط§ط¨طھ - ظٹظڈط­ط³ط¨ ظ…ط±ط© ظˆط§ط­ط¯ط© ظپظ‚ط·
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.transparent,
      Color(0xD9000000),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const _gradientDecoration = BoxDecoration(
    gradient: _gradient,
  );

  @override
  Widget build(BuildContext context) {
    if (shorts.isEmpty) return const SizedBox.shrink();

    final hPad = w * 0.035;
    final gapW = w * 0.02;

    // âœ… ط­ط³ط§ط¨ ط§ظ„ط§ط±طھظپط§ط¹ ظ…ط±ط© ظˆط§ط­ط¯ط© ط¨ط¯ظˆظ† AspectRatio
    final cardW = (w - hPad * 2 - gapW) / 2;
    final cardH = cardW * 16 / 9;

    final dividerColor = theme.isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFDDDDDD);

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 0.5, color: dividerColor),
          SizedBox(height: w * 0.04),

          // â•گâ•گâ•گ Header â•گâ•گâ•گ
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: _ShortsSectionHeader(theme: theme, w: w),
          ),

          SizedBox(height: w * 0.035),

          // â•گâ•گâ•گ Cards â•گâ•گâ•گ
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: isGrid
                ? _buildGrid(cardW, cardH, gapW)
                : _buildSingle(cardW, cardH, gapW),
          ),

          SizedBox(height: w * 0.04),
          Divider(height: 1, thickness: 0.5, color: dividerColor),
          SizedBox(height: w * 0.02),
        ],
      ),
    );
  }

  Widget _buildGrid(double cardW, double cardH, double gapW) {
    final items = shorts.take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(
          left: items[0],
          right: items.length > 1 ? items[1] : null,
          cardW: cardW,
          cardH: cardH,
          gapW: gapW,
        ),
        if (items.length > 2) ...[
          SizedBox(height: gapW),
          _buildRow(
            left: items.length > 2 ? items[2] : null,
            right: items.length > 3 ? items[3] : null,
            cardW: cardW,
            cardH: cardH,
            gapW: gapW,
          ),
        ],
      ],
    );
  }

  Widget _buildSingle(double cardW, double cardH, double gapW) {
    return _buildRow(
      left: shorts[0],
      right: shorts.length > 1 ? shorts[1] : null,
      cardW: cardW,
      cardH: cardH,
      gapW: gapW,
    );
  }

  Widget _buildRow({
    required YoutubeVideo? left,
    required YoutubeVideo? right,
    required double cardW,
    required double cardH,
    required double gapW,
  }) {
    return Row(
      children: [
        SizedBox(
          width: cardW,
          height: cardH,
          child: left != null
              ? _ShortCard(
            video: left,
            theme: theme,
            gradient: _gradientDecoration,
            onTap: () => onVideoTap(left),
          )
              : const SizedBox.shrink(),
        ),
        SizedBox(width: gapW),
        SizedBox(
          width: cardW,
          height: cardH,
          child: right != null
              ? _ShortCard(
            video: right,
            theme: theme,
            gradient: _gradientDecoration,
            onTap: () => onVideoTap(right),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// Header ظ…ظ†ظپطµظ„ - ظٹظڈط¹ط§ط¯ ط§ط³طھط®ط¯ط§ظ…ظ‡
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShortsSectionHeader extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;

  const _ShortsSectionHeader({
    required this.theme,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (w * 0.075).clamp(26.0, 32.0);

    return Row(
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: (w * 0.055).clamp(18.0, 24.0),
            ),
          ),
        ),
        SizedBox(width: w * 0.025),
        Text(
          'Shorts',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: (w * 0.055).clamp(18.0, 26.0),
            fontWeight: FontWeight.w800,
            color: theme.textColor,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.more_vert_rounded,
          color: theme.captionColor,
          size: (w * 0.055).clamp(18.0, 22.0),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// _ShortCard - ظ…ط­ط³ظ‘ظ† ط¨ط§ظ„ظƒط§ظ…ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShortCard extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final BoxDecoration gradient;
  final VoidCallback onTap;

  const _ShortCard({
    required this.video,
    required this.theme,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // âœ… ط¨ط¯ظˆظ† LayoutBuilder - ط§ظ„ط­ط¬ظ… ظ…ط­ط³ظˆط¨ ظ…ظ† ط§ظ„ط£ط¨
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick(); // âœ… ط£ط®ظپ ظ…ظ† lightImpact
          onTap();
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // â•گâ•گâ•گ Thumbnail â•گâ•گâ•گ
              _ShortThumbnail(url: video.thumbnail, theme: theme),

              // â•گâ•گâ•گ Gradient - ط«ط§ط¨طھ ظ…ظ† ط§ظ„ط£ط¨ â•گâ•گâ•گ
              DecoratedBox(decoration: gradient),

              // â•گâ•گâ•گ New Badge â•گâ•گâ•گ
              if (_isNew())
                const Positioned(
                  top: 8,
                  left: 8,
                  child: _NewBadge(),
                ),

              // â•گâ•گâ•گ Menu Icon â•گâ•گâ•گ
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),

              // â•گâ•گâ•گ Info â•گâ•گâ•گ
              Positioned(
                left: 8,
                right: 8,
                bottom: 10,
                child: _ShortCardInfo(video: video),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isNew() =>
      DateTime.now().difference(video.publishedAt).inDays < 3;
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// Thumbnail ظ…ظ†ظپطµظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShortThumbnail extends StatelessWidget {
  final String url;
  final ChannelsTheme theme;

  const _ShortThumbnail({
    required this.url,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // âœ… shortThumbnail ط§ظ„ظ…ط®طµطµ ط¨ط­ط¬ظ… ط«ط§ط¨طھ
    return ImageCacheConfig.shortThumbnail(
      url: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// New Badge - const
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          'New',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// Short Card Info - ظ…ظ†ظپطµظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShortCardInfo extends StatelessWidget {
  final YoutubeVideo video;

  const _ShortCardInfo({required this.video});

  @override
  Widget build(BuildContext context) {
    final hasViews =
        video.viewCount.isNotEmpty && video.viewCount != '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          video.title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.25,
            fontFamily: 'Cairo',
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (hasViews) ...[
          const SizedBox(height: 3),
          Text(
            '${YoutubeService.formatViews(video.viewCount)} مشاهدة',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xCCFFFFFF),
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final int count;
  final VoidCallback onBack;

  const _Header({
    required this.theme,
    required this.w,
    required this.count,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.02, w * 0.04, w * 0.01),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: EdgeInsets.all(w * 0.025),
              decoration: BoxDecoration(
                color: theme.headerIconBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: (w * 0.045).clamp(16.0, 20.0),
                color: theme.textColor,
              ),
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'القنوات العلمية',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.05).clamp(18.0, 26.0),
                    fontWeight: FontWeight.w800,
                    color: theme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count من العلماء والدعاة',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 13.0),
                    color: theme.subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.02),
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              gradient:
              LinearGradient(colors: theme.avatarRingGradient.take(2).toList()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.mosque_rounded,
              size: (w * 0.055).clamp(20.0, 26.0),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final TextEditingController controller;
  final bool focused;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSubmit;

  const _SearchBar({
    required this.theme,
    required this.w,
    required this.controller,
    required this.focused,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.onFocusChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.01, w * 0.04, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: (w * 0.12).clamp(44.0, 54.0),
        decoration: BoxDecoration(
          color: focused ? theme.searchBgFocused : theme.searchBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused ? theme.searchBorderFocused : theme.searchBorder,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: w * 0.035),
            Icon(
              Icons.search_rounded,
              color: focused ? theme.primaryColor : theme.searchHint,
              size: (w * 0.05).clamp(18.0, 22.0),
            ),
            SizedBox(width: w * 0.02),
            Expanded(
              child: Focus(
                onFocusChange: onFocusChanged,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.035).clamp(13.0, 16.0),
                    color: theme.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن شيخ أو فيديو...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: (w * 0.033).clamp(12.0, 15.0),
                      color: theme.searchHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.all(w * 0.02),
                  child: Icon(
                    Icons.close_rounded,
                    color: theme.captionColor,
                    size: (w * 0.04).clamp(14.0, 18.0),
                  ),
                ),
              ),
            SizedBox(width: w * 0.02),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final TabController controller;

  const _TabBar({
    required this.theme,
    required this.w,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.play_circle_fill_rounded, 'يوتيوب', const Color(0xFFFF0000)),
      (Icons.music_note_rounded, 'تيك توك', const Color(0xFFEE1D52)),
      (Icons.people_alt_rounded, 'المشايخ', theme.primaryColor),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Container(
        height: (w * 0.115).clamp(42.0, 50.0),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.chipBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: theme.cardBg,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          tabs: tabs.asMap().entries.map((e) {
            final sel = controller.index == e.key;
            final t = e.value;
            return Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.$1,
                      size: (w * 0.04).clamp(14.0, 18.0),
                      color: sel ? t.$3 : theme.inactiveTabText,
                    ),
                    SizedBox(width: w * 0.01),
                    Flexible(
                      child: Text(
                        t.$2,
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.028).clamp(10.0, 14.0),
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? theme.textColor : theme.inactiveTabText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final ChannelsTheme theme;

  const _LoadingView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: theme.primaryColor,
        strokeWidth: 3,
      ),
    );
  }
}

class _VideoShimmer extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;

  const _VideoShimmer({required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: w * 9 / 16,
            color: theme.chipBg,
          ),
          Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: Row(
              children: [
                Container(
                  width: (w * 0.09).clamp(32.0, 40.0),
                  height: (w * 0.09).clamp(32.0, 40.0),
                  decoration: BoxDecoration(
                    color: theme.chipBg,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: w * 0.025),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, color: theme.chipBg),
                      SizedBox(height: w * 0.015),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(height: 12, color: theme.chipBg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: w * 0.02),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final String title;

  const _EmptyView({
    required this.theme,
    required this.w,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: (w * 0.12).clamp(40.0, 55.0),
              color: theme.captionColor.withValues(alpha: 0.3),
            ),
            SizedBox(height: w * 0.03),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.04).clamp(14.0, 18.0),
                color: theme.subtitleColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;

  const _LoadMoreIndicator({required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(w * 0.05),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _EndOfFeed extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onRefresh;

  const _EndOfFeed({
    required this.theme,
    required this.w,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: (w * 0.07).clamp(24.0, 32.0),
            color: theme.captionColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: w * 0.01),
          Text(
            'تم عرض جميع الفيديوهات',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.03).clamp(11.0, 13.0),
              color: theme.captionColor,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: onRefresh,
            child: Text(
              'تحديث',
              style: GoogleFonts.cairo(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TiktokCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _TiktokCard({
    required this.data,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['scholarName']?.toString() ?? '';
    final handle = data['handle']?.toString() ?? '';
    final subs = data['subscribers']?.toString() ?? '';
    final img = data['channel_image']?.toString() ??
        data['scholarImage']?.toString() ??
        '';

    final avatarSize = (w * 0.13).clamp(44.0, 60.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.cardBorder),
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF69C9D0),
                    Color(0xFFEE1D52),
                    Color(0xFF69C9D0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: img.isNotEmpty
                        ? ImageCacheConfig.channelAvatar(
                      url: img,
                      size: avatarSize,
                      errorWidget: _fb(name, theme, w),
                    )
                        : _fb(name, theme, w),
                  ),
                ),
              ),
            ),
            SizedBox(width: w * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.035).clamp(13.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (handle.isNotEmpty)
                    Text(
                      handle,
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.026).clamp(9.0, 12.0),
                        color: theme.captionColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subs.isNotEmpty) ...[
                    SizedBox(height: w * 0.008),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.015,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE1D52).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$subs متابع',
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.024).clamp(8.0, 11.0),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEE1D52),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: w * 0.015),
            Flexible(
              flex: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.025,
                  vertical: w * 0.018,
                ),
                decoration: BoxDecoration(
                  color: theme.tiktokBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: (w * 0.035).clamp(12.0, 16.0),
                      color: theme.tiktokText,
                    ),
                    SizedBox(width: w * 0.008),
                    Text(
                      'فتح',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.026).clamp(9.0, 12.0),
                        fontWeight: FontWeight.w700,
                        color: theme.tiktokText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fb(String name, ChannelsTheme theme, double w) => Container(
    color: theme.chipBg,
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0] : 'طں',
        style: GoogleFonts.cairo(
          fontSize: (w * 0.055).clamp(18.0, 24.0),
          fontWeight: FontWeight.w700,
          color: theme.primaryColor,
        ),
      ),
    ),
  );
}

class _ScholarCard extends StatelessWidget {
  final Map<String, dynamic> scholar;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _ScholarCard({
    required this.scholar,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = scholar['name']?.toString() ?? '';
    final title = scholar['title']?.toString() ?? '';
    final category = scholar['category']?.toString() ?? '';
    final country = scholar['country']?.toString() ?? '';
    final flag = scholar['flag']?.toString() ?? '';
    final image = scholar['image']?.toString() ?? '';
    final platforms = (scholar['platforms'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e))
        .toList() ??
        [];

    final avatarSize = (w * 0.14).clamp(46.0, 64.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.cardBorder),
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: SweepGradient(colors: [...theme.avatarRingGradient]),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: image.isNotEmpty
                        ? ImageCacheConfig.channelAvatar(
                      url: image,
                      size: avatarSize,
                      errorWidget: _avatarFb(name, theme, w),
                    )
                        : _avatarFb(name, theme, w),
                  ),
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.038).clamp(14.0, 17.0),
                      fontWeight: FontWeight.w700,
                      color: theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.028).clamp(10.0, 13.0),
                        color: theme.subtitleColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: w * 0.01),
                  Wrap(
                    spacing: w * 0.01,
                    runSpacing: w * 0.008,
                    children: [
                      if (flag.isNotEmpty && country.isNotEmpty)
                        _chip(
                          '$flag $country',
                          theme.chipBg,
                          theme.captionColor,
                          w,
                        ),
                      if (category.isNotEmpty)
                        _chip(category, theme.primaryLight, theme.primaryColor, w),
                    ],
                  ),
                  SizedBox(height: w * 0.012),
                  Wrap(
                    spacing: w * 0.01,
                    runSpacing: w * 0.008,
                    children: platforms.map((p) {
                      final icon = p['icon']?.toString() ?? '';
                      final isYT = icon == 'youtube';
                      final isTT = icon == 'tiktok';
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.018,
                          vertical: w * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: (isYT
                              ? Colors.red
                              : isTT
                              ? const Color(0xFFEE1D52)
                              : theme.primaryColor)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isYT
                                  ? Icons.play_circle_fill_rounded
                                  : isTT
                                  ? Icons.music_note_rounded
                                  : Icons.link_rounded,
                              size: (w * 0.03).clamp(11.0, 14.0),
                              color: isYT
                                  ? Colors.red
                                  : isTT
                                  ? const Color(0xFFEE1D52)
                                  : theme.primaryColor,
                            ),
                            SizedBox(width: w * 0.008),
                            Flexible(
                              child: Text(
                                p['name']?.toString() ?? '',
                                style: GoogleFonts.cairo(
                                  fontSize: (w * 0.024).clamp(8.0, 11.0),
                                  fontWeight: FontWeight.w600,
                                  color: theme.textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              size: (w * 0.04).clamp(14.0, 18.0),
              color: theme.captionColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color textColor, double w) => Container(
    padding: EdgeInsets.symmetric(horizontal: w * 0.015, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: (w * 0.024).clamp(8.0, 11.0),
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _avatarFb(String name, ChannelsTheme theme, double w) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: theme.avatarRingGradient.take(2).toList(),
      ),
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0] : 'طں',
        style: GoogleFonts.cairo(
          fontSize: (w * 0.055).clamp(18.0, 24.0),
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class _FeedModeBanner extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final bool isRecent;
  final int watchedCount;

  const _FeedModeBanner({
    required this.theme,
    required this.w,
    required this.isRecent,
    required this.watchedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.02, w * 0.04, w * 0.01),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.03,
                vertical: w * 0.015,
              ),
              decoration: BoxDecoration(
                color: isRecent
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRecent
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRecent
                        ? Icons.fiber_new_rounded
                        : Icons.local_fire_department_rounded,
                    size: (w * 0.04).clamp(14.0, 18.0),
                    color: isRecent ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: w * 0.015),
                  Flexible(
                    child: Text(
                      isRecent ? 'فيديوهات حديثة' : 'الأكثر مشاهدة',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.03).clamp(11.0, 13.0),
                        fontWeight: FontWeight.w600,
                        color: isRecent ? Colors.green : Colors.orange,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (watchedCount > 0) ...[
            SizedBox(width: w * 0.02),
            Text(
              'شاهدت $watchedCount',
              style: GoogleFonts.cairo(
                fontSize: (w * 0.028).clamp(10.0, 12.0),
                color: theme.captionColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResumeWatchingSection extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final List<YoutubeVideo> videos;
  final Function(YoutubeVideo) onTap;

  const _ResumeWatchingSection({
    required this.theme,
    required this.w,
    required this.videos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    final cardWidth = (w * 0.62).clamp(200.0, 280.0);
    final thumbHeight = (cardWidth * 0.5).clamp(90.0, 140.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, 0, w * 0.04, w * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'أكمل المشاهدة',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.04).clamp(14.0, 18.0),
              fontWeight: FontWeight.w800,
              color: theme.textColor,
            ),
          ),
          SizedBox(height: w * 0.025),
          SizedBox(
            height: thumbHeight + (w * 0.18).clamp(60.0, 80.0),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: videos.length,
              separatorBuilder: (_, __) => SizedBox(width: w * 0.025),
              itemBuilder: (_, i) {
                final video = videos[i];
                final progress = VideoHistoryService.getProgress(video.id);

                return GestureDetector(
                  onTap: () => onTap(video),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: video.thumbnail,
                                width: double.infinity,
                                height: thumbHeight,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  height: thumbHeight,
                                  color: theme.chipBg,
                                  child: Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: theme.captionColor,
                                  ),
                                ),
                              ),
                              if (video.duration.isNotEmpty)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      video.duration,
                                      style: GoogleFonts.cairo(
                                        fontSize: (w * 0.025).clamp(9.0, 11.0),
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: Colors.white24,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: w * 0.015),
                        Flexible(
                          child: Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.032).clamp(11.0, 14.0),
                              fontWeight: FontWeight.w700,
                              color: theme.textColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(height: w * 0.005),
                        Text(
                          '${(progress * 100).round()}% آ· ${video.channelTitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.026).clamp(9.0, 12.0),
                            color: theme.captionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}