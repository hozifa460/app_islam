import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islamic_app/screens/channels/services/channel_background_sync_service.dart';
import 'package:islamic_app/screens/channels/services/channel_memory_cache_service.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/channel_videos_cache_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/shorts_player_screen.dart';
import 'package:islamic_app/screens/channels/widgets/channels_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cache/image_cache_config.dart';
import 'helpers/time_format_helper.dart';
import 'helpers/video_sort_helper.dart';
import 'video_player_screen.dart';
import 'scholar_profile_tiktok_screen.dart';

class ScholarProfileYoutubeScreen extends StatefulWidget {
  final Map<String, dynamic> scholar;

  const ScholarProfileYoutubeScreen({super.key, required this.scholar});

  @override
  State<ScholarProfileYoutubeScreen> createState() =>
      _ScholarProfileYoutubeScreenState();
}

class _ScholarProfileYoutubeScreenState
    extends State<ScholarProfileYoutubeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  List<YoutubeVideo> _allVideos = [];
  List<YoutubeVideo> _regularVideos = [];
  List<YoutubeVideo> _shortsVideos = [];
  List<YoutubeVideo> _liveVideos = [];

  bool _loadingVideos = true;
  bool _loadingMore = false;
  bool _loadingShorts = false;
  bool _loadingLive = false;

  bool _shortsLoadedOnce = false;
  bool _liveLoadedOnce = false;

  bool _reachedEnd = false;
  int _loadMoreRound = 0;
  int _emptyLoadMoreHits = 0;

  ChannelInfo? _channelInfo;
  String? _youtubeChannelId;
  String? _youtubeChannelUrl;
  String? _youtubeHandle;
  String? _channelCacheId;

  final ValueNotifier<int> _contentVersion = ValueNotifier<int>(0);

  Timer? _rebuildDebounce;
  bool _syncInProgress = false;

  List<YoutubeVideo> _lastRegularBuilt = [];
  List<YoutubeVideo> _lastShortsBuilt = [];
  List<YoutubeVideo> _lastLiveBuilt = [];

  String get _usageChannelKey {
    if (_youtubeChannelId != null && _youtubeChannelId!.isNotEmpty) {
      return _youtubeChannelId!;
    }
    if (_youtubeChannelUrl != null && _youtubeChannelUrl!.isNotEmpty) {
      return _youtubeChannelUrl!;
    }
    return widget.scholar['name']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_onScroll);
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await VideoHistoryService.init();
    await ChannelUsageService.init();
    await ChannelBackgroundSyncService.init();
    await _loadData();
  }

  Future<void> _scheduleCurrentChannelSync({
    bool includeArchive = false,
  }) async {
    if (_youtubeChannelId == null ||
        _youtubeChannelUrl == null ||
        _youtubeChannelId!.isEmpty ||
        _youtubeChannelUrl!.isEmpty) {
      return;
    }

    await ChannelBackgroundSyncService.enqueueChannel(
      ChannelSyncRequest(
        channelId: _youtubeChannelId!,
        channelUrl: _youtubeChannelUrl!,
        handle: _youtubeHandle,
        priorityKey: _usageChannelKey,
        maxResults: 40,
        mode: ChannelSyncMode.latest,
      ),
    );

    if (includeArchive) {
      await ChannelBackgroundSyncService.enqueueChannel(
        ChannelSyncRequest(
          channelId: _youtubeChannelId!,
          channelUrl: _youtubeChannelUrl!,
          handle: _youtubeHandle,
          priorityKey: _usageChannelKey,
          maxResults: 140,
          mode: ChannelSyncMode.archive,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    _rebuildDebounce?.cancel();
    _contentVersion.dispose();
    super.dispose();
  }

  bool _sameIds(List<YoutubeVideo> a, List<YoutubeVideo> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _notifyContentChanged() {
    _contentVersion.value++;
  }

  void _scheduleLightRebuild({bool immediate = false}) {
    _rebuildDebounce?.cancel();

    if (immediate) {
      _applyOptimizedLists();
      return;
    }

    _rebuildDebounce = Timer(const Duration(milliseconds: 100), () {
      _applyOptimizedLists();
    });
  }

  void _applyOptimizedLists() {
    final regular = VideoSortHelper.sortRegularForDisplay(
      List.from(_regularVideos),
    );
    final shorts = VideoSortHelper.sortShortsForDisplay(
      List.from(_shortsVideos),
    );
    final live = VideoSortHelper.sortLiveForDisplay(List.from(_liveVideos));

    final changed =
        !_sameIds(_lastRegularBuilt, regular) ||
        !_sameIds(_lastShortsBuilt, shorts) ||
        !_sameIds(_lastLiveBuilt, live);

    if (!changed) return;

    _lastRegularBuilt = List<YoutubeVideo>.from(regular);
    _lastShortsBuilt = List<YoutubeVideo>.from(shorts);
    _lastLiveBuilt = List<YoutubeVideo>.from(live);

    if (!mounted) return;

    setState(() {
      _regularVideos = regular;
      _shortsVideos = shorts;
      _liveVideos = live;
      _allVideos = [..._regularVideos, ..._shortsVideos, ..._liveVideos];
    });

    _notifyContentChanged();
  }

  void _replaceAllLists({
    required List<YoutubeVideo> regular,
    required List<YoutubeVideo> shorts,
    required List<YoutubeVideo> live,
    bool immediate = true,
  }) {
    _regularVideos = List<YoutubeVideo>.from(regular);
    _shortsVideos = List<YoutubeVideo>.from(shorts);
    _liveVideos = List<YoutubeVideo>.from(live);

    if (immediate) {
      _applyOptimizedLists();
    } else {
      _scheduleLightRebuild();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_tabController.index == 4) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.80) {
      if (!_loadingMore && !_reachedEnd) {
        _loadMore();
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    if (_tabController.index == 2 && !_shortsLoadedOnce && !_loadingShorts) {
      _loadShortsOnly(handle: _youtubeHandle);
    }

    if (_tabController.index == 3 && !_liveLoadedOnce && !_loadingLive) {
      _loadLiveOnly(handle: _youtubeHandle);
    }
  }

  bool _hasTiktok() {
    final platforms = widget.scholar['platforms'] as List<dynamic>? ?? [];
    return platforms.any(
      (p) => Map<String, dynamic>.from(p)['icon'] == 'tiktok',
    );
  }

  Map<String, dynamic>? _getTiktokData() {
    final platforms = widget.scholar['platforms'] as List<dynamic>? ?? [];
    try {
      final tiktok = platforms.firstWhere(
        (p) => Map<String, dynamic>.from(p)['icon'] == 'tiktok',
      );
      return {
        'scholarName': widget.scholar['name'],
        'scholarImage': widget.scholar['image'],
        'flag': widget.scholar['flag'],
        ...Map<String, dynamic>.from(tiktok),
      };
    } catch (_) {
      return null;
    }
  }

  void _openTiktokPage() {
    final tiktokData = _getTiktokData();
    if (tiktokData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScholarProfileTiktokScreen(tiktokData: tiktokData),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _loadingVideos = true);

    _loadMoreRound = 0;
    _emptyLoadMoreHits = 0;
    _reachedEnd = false;

    try {
      final platforms = widget.scholar['platforms'] as List<dynamic>? ?? [];

      String? url;
      String? handle;

      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          url = pm['url']?.toString();
          handle = pm['handle']?.toString();
          break;
        }
      }

      if (url == null || url.isEmpty) {
        if (mounted) setState(() => _loadingVideos = false);
        return;
      }

      _youtubeChannelUrl = url;
      _youtubeHandle = handle;

      String? providedChannelId;

      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          url = pm['url']?.toString();
          handle = pm['handle']?.toString();
          providedChannelId = pm['channelId']?.toString();
          break;
        }
      }


    _youtubeChannelId = await YoutubeService.resolveChannelId(
    providedChannelId: providedChannelId,
    channelUrl: url!,
    handle: handle,
    );

      if (_youtubeChannelId == null) {
        if (mounted) setState(() => _loadingVideos = false);
        return;
      }

      _channelCacheId = _youtubeChannelId;

      await ChannelUsageService.markChannelOpened(_usageChannelKey);

      final memory = ChannelMemoryCacheService.get(_channelCacheId!);
      if (memory != null) {
        _replaceAllLists(
          regular: memory.regularVideos,
          shorts: memory.shortsVideos,
          live: memory.liveVideos,
        );

        _channelInfo = memory.channelInfo;
        _reachedEnd = memory.reachedEnd;
        _shortsLoadedOnce = memory.shortsLoadedOnce;
        _liveLoadedOnce = memory.liveLoadedOnce;
        _loadMoreRound = memory.loadMoreRound;
        _emptyLoadMoreHits = memory.emptyLoadMoreHits;

        if (mounted) {
          setState(() => _loadingVideos = false);
        }

        Future.microtask(() => _syncLatestOnly(handle: handle));
        Future.microtask(() => _syncOpenedTabs(handle: handle));
        Future.microtask(_loadChannelInfo);
        Future.microtask(
          () => _scheduleCurrentChannelSync(includeArchive: false),
        );
        return;
      }

      final cache = await ChannelVideosCacheService.loadChannelData(
        _channelCacheId!,
      );

      if (cache != null) {
        final initialRegular =
            cache.latestRegularVideos.isNotEmpty
                ? cache.latestRegularVideos
                : cache.regularVideos;

        final initialShorts =
            cache.latestShortsVideos.isNotEmpty
                ? cache.latestShortsVideos
                : cache.shortsVideos;

        final initialLive =
            cache.latestLiveVideos.isNotEmpty
                ? cache.latestLiveVideos
                : cache.liveVideos;

        _replaceAllLists(
          regular: initialRegular,
          shorts: initialShorts,
          live: initialLive,
        );

        _shortsLoadedOnce = _shortsVideos.isNotEmpty;
        _liveLoadedOnce = _liveVideos.isNotEmpty;
        _reachedEnd = cache.reachedEnd;
        _loadMoreRound = cache.loadMoreRound;
        _emptyLoadMoreHits = cache.emptyLoadMoreHits;

        if (mounted) {
          setState(() => _loadingVideos = false);
        }

        Future.microtask(() => _syncLatestOnly(handle: handle));
        Future.microtask(() => _syncOpenedTabs(handle: handle));
        Future.microtask(_loadChannelInfo);
        Future.microtask(
          () => _scheduleCurrentChannelSync(includeArchive: true),
        );
        _saveToMemoryCache();
        return;
      }

      final latest = await YoutubeService.getChannelLatestBatch(
        channelUrl: url,
        handle: handle,
        channelId: _youtubeChannelId,
        maxResults: 50,
      );

      final regular = <YoutubeVideo>[];
      final shorts = <YoutubeVideo>[];
      final live = <YoutubeVideo>[];

      for (final v in latest) {
        _classifyVideo(v, regular, shorts, live);
      }

      await _loadChannelInfo();

      _replaceAllLists(regular: regular, shorts: shorts, live: live);

      _shortsLoadedOnce = shorts.isNotEmpty;
      _liveLoadedOnce = live.isNotEmpty;

      if (mounted) {
        setState(() => _loadingVideos = false);
      }

      await _saveCacheIfChanged(
        oldRegular: const [],
        oldShorts: const [],
        oldLive: const [],
        newRegular: _regularVideos,
        newShorts: _shortsVideos,
        newLive: _liveVideos,
      );

      _saveToMemoryCache();
      Future.microtask(() => _scheduleCurrentChannelSync(includeArchive: true));
    } catch (e) {
      debugPrint('❌ _loadData error: $e');
      if (mounted) setState(() => _loadingVideos = false);
    }
  }

  Future<void> _loadChannelInfo() async {
    if (_youtubeChannelId == null) return;

    try {
      final info = await YoutubeService.getChannelInfo(_youtubeChannelId!);
      if (info != null && mounted) {
        setState(() {
          _channelInfo = info;
        });
      }
    } catch (e) {
      debugPrint('❌ _loadChannelInfo error: $e');
    }
  }

  Future<void> _syncLatestOnly({String? handle}) async {
    if (_youtubeChannelUrl == null) return;

    try {
      final oldRegular = List<YoutubeVideo>.from(_regularVideos);
      final oldShorts = List<YoutubeVideo>.from(_shortsVideos);
      final oldLive = List<YoutubeVideo>.from(_liveVideos);

      final latestBatch = await YoutubeService.getChannelVideos(
        channelUrl: _youtubeChannelUrl!,
        handle: handle,
        channelId: _youtubeChannelId,
        maxResults: 20,
      );

      if (latestBatch.isEmpty) return;

      final existingIds = _allVideos.map((e) => e.id).toSet();

      final newRegular = <YoutubeVideo>[];
      final newShorts = <YoutubeVideo>[];
      final newLive = <YoutubeVideo>[];

      for (final v in latestBatch) {
        if (!existingIds.contains(v.id)) {
          _classifyVideo(v, newRegular, newShorts, newLive);
        }
      }

      if (newRegular.isEmpty && newShorts.isEmpty && newLive.isEmpty) {
        return;
      }

      final mergedRegular = [...newRegular, ..._regularVideos];
      final mergedShorts = [...newShorts, ..._shortsVideos];
      final mergedLive = [...newLive, ..._liveVideos];

      _replaceAllLists(
        regular: mergedRegular,
        shorts: mergedShorts,
        live: mergedLive,
        immediate: false,
      );

      await _saveCacheIfChanged(
        oldRegular: oldRegular,
        oldShorts: oldShorts,
        oldLive: oldLive,
        newRegular: mergedRegular,
        newShorts: mergedShorts,
        newLive: mergedLive,
      );

      _saveToMemoryCache();
    } catch (e) {
      debugPrint('❌ _syncLatestOnly error: $e');
    }
  }

  Future<void> _loadShortsOnly({String? handle}) async {
    if (_loadingShorts || _youtubeChannelUrl == null) return;

    setState(() => _loadingShorts = true);

    try {
      final oldShorts = List<YoutubeVideo>.from(_shortsVideos);
      final existingIds = _shortsVideos.map((e) => e.id).toSet();

      final latest = await YoutubeService.getChannelLatestBatch(
        channelUrl: _youtubeChannelUrl!,
        handle: handle,
        channelId: _youtubeChannelId,
        maxResults: 40,
      );

      final newShorts = <YoutubeVideo>[];

      for (final v in latest) {
        if (!existingIds.contains(v.id) &&
            YoutubeService.isLikelyShortVideo(v)) {
          newShorts.add(v);
          existingIds.add(v.id);
        }
      }

      if (_shortsVideos.isEmpty || newShorts.length < 4) {
        final fetched = await YoutubeService.getAllChannelVideos(
          channelUrl: _youtubeChannelUrl!,
          handle: handle,
          channelId: _youtubeChannelId,
          maxResults: 120,
        );

        for (final v in fetched) {
          if (!existingIds.contains(v.id) &&
              YoutubeService.isLikelyShortVideo(v)) {
            newShorts.add(v);
            existingIds.add(v.id);
          }
        }
      }

      _replaceAllLists(
        regular: _regularVideos,
        shorts: [...newShorts, ..._shortsVideos],
        live: _liveVideos,
        immediate: false,
      );

      _shortsLoadedOnce = true;

      await _saveCacheIfChanged(
        oldRegular: _regularVideos,
        oldShorts: oldShorts,
        oldLive: _liveVideos,
        newRegular: _regularVideos,
        newShorts: _shortsVideos,
        newLive: _liveVideos,
      );

      _saveToMemoryCache();
    } catch (e) {
      debugPrint('❌ _loadShortsOnly error: $e');
    }

    if (mounted) setState(() => _loadingShorts = false);
  }

  Future<void> _loadLiveOnly({String? handle}) async {
    if (_loadingLive ||
        _youtubeChannelUrl == null ||
        _youtubeChannelId == null) {
      return;
    }

    setState(() => _loadingLive = true);

    try {
      final oldLive = List<YoutubeVideo>.from(_liveVideos);
      final existingIds = _liveVideos.map((e) => e.id).toSet();
      final newLive = <YoutubeVideo>[];

      final latest = await YoutubeService.getChannelLatestBatch(
        channelUrl: _youtubeChannelUrl!,
        handle: handle,
        channelId: _youtubeChannelId,
        maxResults: 40,
      );

      for (final v in latest) {
        final lower = v.title.toLowerCase();
        if (!existingIds.contains(v.id) &&
            (v.type == VideoType.live ||
                lower.contains('live') ||
                lower.contains('مباشر') ||
                lower.contains('بث'))) {
          newLive.add(v);
          existingIds.add(v.id);
        }
      }

      if (_liveVideos.isEmpty || newLive.length < 3) {
        final streamsUrl = Uri.parse(
          'https://www.youtube.com/channel/$_youtubeChannelId/streams',
        );

        final response = await YoutubeService.safeChannelPage(streamsUrl);

        if (response != null && response.statusCode == 200) {
          final parsed = YoutubeService.parseChannelPagePublic(
            response.body,
            _youtubeChannelId!,
            80,
          );

          for (final v in parsed) {
            final lower = v.title.toLowerCase();
            if (!existingIds.contains(v.id) &&
                (v.type == VideoType.live ||
                    lower.contains('live') ||
                    lower.contains('مباشر') ||
                    lower.contains('بث'))) {
              newLive.add(v);
              existingIds.add(v.id);
            }
          }
        }
      }

      _replaceAllLists(
        regular: _regularVideos,
        shorts: _shortsVideos,
        live: [...newLive, ..._liveVideos],
        immediate: false,
      );

      _liveLoadedOnce = true;

      await _saveCacheIfChanged(
        oldRegular: _regularVideos,
        oldShorts: _shortsVideos,
        oldLive: oldLive,
        newRegular: _regularVideos,
        newShorts: _shortsVideos,
        newLive: _liveVideos,
      );

      _saveToMemoryCache();
    } catch (e) {
      debugPrint('❌ _loadLiveOnly error: $e');
    }

    if (mounted) setState(() => _loadingLive = false);
  }

  Future<void> _syncOpenedTabs({String? handle}) async {
    final futures = <Future<void>>[];

    if (_shortsLoadedOnce) {
      futures.add(_loadShortsOnly(handle: handle));
    }

    if (_liveLoadedOnce) {
      futures.add(_loadLiveOnly(handle: handle));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _youtubeChannelUrl == null || _reachedEnd) return;

    setState(() => _loadingMore = true);

    try {
      final oldRegular = List<YoutubeVideo>.from(_regularVideos);
      final oldShorts = List<YoutubeVideo>.from(_shortsVideos);
      final oldLive = List<YoutubeVideo>.from(_liveVideos);
      final existingIds = _allVideos.map((v) => v.id).toSet();

      if (_channelCacheId != null) {
        final cache = await ChannelVideosCacheService.loadChannelData(
          _channelCacheId!,
        );
        if (cache != null) {
          final pendingArchiveRegular =
              cache.archiveRegularVideos
                  .where((v) => !existingIds.contains(v.id))
                  .take(20)
                  .toList();

          final pendingArchiveShorts =
              cache.archiveShortsVideos
                  .where((v) => !existingIds.contains(v.id))
                  .take(10)
                  .toList();

          final pendingArchiveLive =
              cache.archiveLiveVideos
                  .where((v) => !existingIds.contains(v.id))
                  .take(6)
                  .toList();

          if (pendingArchiveRegular.isNotEmpty ||
              pendingArchiveShorts.isNotEmpty ||
              pendingArchiveLive.isNotEmpty) {
            final reg = List<YoutubeVideo>.from(_regularVideos)
              ..addAll(pendingArchiveRegular);
            final sh = List<YoutubeVideo>.from(_shortsVideos)
              ..addAll(pendingArchiveShorts);
            final li = List<YoutubeVideo>.from(_liveVideos)
              ..addAll(pendingArchiveLive);

            _replaceAllLists(
              regular: reg,
              shorts: sh,
              live: li,
              immediate: false,
            );

            _saveToMemoryCache();

            setState(() => _loadingMore = false);

            Future.microtask(
              () => _scheduleCurrentChannelSync(includeArchive: true),
            );
            return;
          }
        }
      }

      final terms = [
        '',
        'محاضرة',
        'درس',
        'خطبة',
        'تفسير',
        'فتوى',
        'شرح',
        'فقه',
        'حديث',
        'قرآن',
        'دعاء',
        'ذكر',
        'صلاة',
        'صيام',
        'زكاة',
        'توبة',
        'سيرة',
        'أخلاق',
        'رقائق',
        'عقيدة',
        'سنن',
        'توحيد',
        'إيمان',
        'قراءة',
        'مجلس',
        'موعظة',
      ];

      final term = terms[_loadMoreRound % terms.length];
      _loadMoreRound++;

      final fetched = <YoutubeVideo>[];
      final seenFetched = <String>{};

      try {
        final searchResults = await YoutubeService.searchInChannelByUrl(
          channelUrl: _youtubeChannelUrl!,
          query: term,
          channelId: _youtubeChannelId,
          maxResults: 40,
        );

        for (final v in searchResults) {
          if (seenFetched.add(v.id)) {
            fetched.add(v);
          }
        }
      } catch (e) {
        debugPrint('⚠️ searchInChannelByUrl error: $e');
      }

      if (_loadMoreRound % 3 == 0) {
        try {
          final allResults = await YoutubeService.getAllChannelVideos(
            channelUrl: _youtubeChannelUrl!,
            handle: _youtubeHandle,
            channelId: _youtubeChannelId,
            maxResults: min(_allVideos.length + 60, 250),
          );

          for (final v in allResults) {
            if (seenFetched.add(v.id)) {
              fetched.add(v);
            }
          }
        } catch (e) {
          debugPrint('⚠️ getAllChannelVideos error: $e');
        }
      }

      if (_loadMoreRound % 4 == 0) {
        try {
          final latestBatch = await YoutubeService.getChannelLatestBatch(
            channelUrl: _youtubeChannelUrl!,
            handle: _youtubeHandle,
            channelId: _youtubeChannelId,
            maxResults: 50,
          );

          for (final v in latestBatch) {
            if (seenFetched.add(v.id)) {
              fetched.add(v);
            }
          }
        } catch (e) {
          debugPrint('⚠️ getChannelLatestBatch error: $e');
        }
      }

      final newOnes =
          fetched.where((v) => !existingIds.contains(v.id)).toList();

      if (newOnes.isEmpty) {
        _emptyLoadMoreHits++;
        if (_emptyLoadMoreHits >= 6 && _loadMoreRound >= terms.length) {
          _reachedEnd = true;
        }

        if (mounted) setState(() => _loadingMore = false);
        _saveToMemoryCache();
        return;
      }

      _emptyLoadMoreHits = 0;

      final reg = List<YoutubeVideo>.from(_regularVideos);
      final sh = List<YoutubeVideo>.from(_shortsVideos);
      final li = List<YoutubeVideo>.from(_liveVideos);

      for (final v in newOnes) {
        _classifyVideo(v, reg, sh, li);
      }

      _replaceAllLists(regular: reg, shorts: sh, live: li, immediate: false);

      await _saveCacheIfChanged(
        oldRegular: oldRegular,
        oldShorts: oldShorts,
        oldLive: oldLive,
        newRegular: _regularVideos,
        newShorts: _shortsVideos,
        newLive: _liveVideos,
      );

      _saveToMemoryCache();
    } catch (e) {
      debugPrint('❌ _loadMore error: $e');
    }

    if (mounted) setState(() => _loadingMore = false);
  }

  Future<void> _refreshAll() async {
    if (_channelCacheId != null) {
      await ChannelVideosCacheService.clearChannel(_channelCacheId!);
      ChannelMemoryCacheService.remove(_channelCacheId!);
    }

    setState(() {
      _allVideos.clear();
      _regularVideos.clear();
      _shortsVideos.clear();
      _liveVideos.clear();
      _reachedEnd = false;
      _loadMoreRound = 0;
      _emptyLoadMoreHits = 0;
      _shortsLoadedOnce = false;
      _liveLoadedOnce = false;
      _loadingVideos = true;
    });

    _lastRegularBuilt = [];
    _lastShortsBuilt = [];
    _lastLiveBuilt = [];
    _notifyContentChanged();

    await _loadData();
    await _scheduleCurrentChannelSync(includeArchive: true);
  }

  Future<void> _refreshLatestOnly() async {
    await _syncLatestOnly(handle: _youtubeHandle);

    if (_shortsLoadedOnce) {
      await _loadShortsOnly(handle: _youtubeHandle);
    }

    if (_liveLoadedOnce) {
      await _loadLiveOnly(handle: _youtubeHandle);
    }

    await _loadChannelInfo();
    await _scheduleCurrentChannelSync(includeArchive: false);
  }

  Future<void> _saveCacheIfChanged({
    required List<YoutubeVideo> oldRegular,
    required List<YoutubeVideo> oldShorts,
    required List<YoutubeVideo> oldLive,
    required List<YoutubeVideo> newRegular,
    required List<YoutubeVideo> newShorts,
    required List<YoutubeVideo> newLive,
  }) async {
    if (_channelCacheId == null) return;

    final shouldSave = ChannelVideosCacheService.shouldSave(
      oldRegular: oldRegular,
      oldShorts: oldShorts,
      oldLive: oldLive,
      newRegular: newRegular,
      newShorts: newShorts,
      newLive: newLive,
    );

    if (!shouldSave) return;

    await ChannelVideosCacheService.saveChannelData(
      channelId: _channelCacheId!,
      regularVideos: newRegular,
      shortsVideos: newShorts,
      liveVideos: newLive,
      latestVideoId: _allVideos.isNotEmpty ? _allVideos.first.id : null,
      reachedEnd: _reachedEnd,
      loadMoreRound: _loadMoreRound,
      emptyLoadMoreHits: _emptyLoadMoreHits,
    );
  }

  void _saveToMemoryCache() {
    if (_channelCacheId == null) return;

    ChannelMemoryCacheService.save(
      channelId: _channelCacheId!,
      regularVideos: _regularVideos,
      shortsVideos: _shortsVideos,
      liveVideos: _liveVideos,
      channelInfo: _channelInfo,
      reachedEnd: _reachedEnd,
      shortsLoadedOnce: _shortsLoadedOnce,
      liveLoadedOnce: _liveLoadedOnce,
      loadMoreRound: _loadMoreRound,
      emptyLoadMoreHits: _emptyLoadMoreHits,
    );
  }

  void _classifyVideo(
    YoutubeVideo v,
    List<YoutubeVideo> videos,
    List<YoutubeVideo> shorts,
    List<YoutubeVideo> live,
  ) {
    if (v.type == VideoType.live) {
      live.add(v);
    } else if (YoutubeService.isLikelyShortVideo(v)) {
      shorts.add(v);
    } else {
      videos.add(v);
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openVideoPlayer(YoutubeVideo video) async {
    await ChannelUsageService.markVideoStarted(
      channelId: _usageChannelKey,
      videoId: video.id,
    );

    final isShort = YoutubeService.isLikelyShortVideo(video);

    if (isShort) {
      final shortsList = _shortsVideos.isNotEmpty ? _shortsVideos : [video];
      final index = shortsList.indexWhere((v) => v.id == video.id);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ShortsPlayerScreen(
                shorts: shortsList,
                initialIndex: index >= 0 ? index : 0,
              ),
        ),
      ).then((_) {
        if (mounted) {
          _scheduleLightRebuild(immediate: true);
        }
      });
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => VideoPlayerScreen(
              videoId: video.id,
              title: video.title,
              channelTitle: video.channelTitle,
              channelId: video.channelId,
              viewCount: YoutubeService.formatViews(video.viewCount),
              publishedAt: TimeFormatHelper.shortTimeAgoArabic(
                video.publishedAt,
              ),
            ),
      ),
    ).then((_) {
      if (mounted) {
        _scheduleLightRebuild(immediate: true);
      }
    });
  }

  Widget _withRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  BUILD
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ChannelsTheme(isDark: isDark);
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    final name = widget.scholar['name']?.toString() ?? '';
    final image = widget.scholar['image']?.toString() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            isDark
                ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
                : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                ),
        child: Scaffold(
          backgroundColor: theme.cardBg,
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: _channelHeaderHeight(w, mq),
                  floating: false,
                  pinned: true,
                  backgroundColor: theme.cardBg,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.textColor,
                      size: (w * 0.05).clamp(18.0, 22.0),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    if (_hasTiktok())
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all((w * 0.015).clamp(4.0, 8.0)),
                          decoration: BoxDecoration(
                            gradient: const SweepGradient(
                              colors: [
                                Color(0xFF69C9D0),
                                Color(0xFFEE1D52),
                                Color(0xFF69C9D0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: (w * 0.04).clamp(14.0, 18.0),
                          ),
                        ),
                        onPressed: _openTiktokPage,
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: theme.textColor,
                        size: (w * 0.055).clamp(20.0, 24.0),
                      ),
                      onPressed: _refreshLatestOnly,
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.textColor,
                        size: (w * 0.06).clamp(22.0, 26.0),
                      ),
                      onSelected: (value) {
                        if (value == 'full_refresh') {
                          _refreshAll();
                        }
                      },
                      itemBuilder:
                          (_) => [
                            const PopupMenuItem(
                              value: 'full_refresh',
                              child: Text('تحديث كامل'),
                            ),
                          ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildChannelHeader(theme, w, name, image, mq),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: theme.primaryColor,
                      indicatorWeight: 2.5,
                      labelColor: theme.textColor,
                      unselectedLabelColor: theme.subtitleColor,
                      labelStyle: GoogleFonts.cairo(
                        fontSize: (w * 0.033).clamp(11.0, 15.0),
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: GoogleFonts.cairo(
                        fontSize: (w * 0.033).clamp(11.0, 15.0),
                        fontWeight: FontWeight.w500,
                      ),
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        const Tab(text: 'الرئيسية'),
                        Tab(text: 'الفيديوهات (${_regularVideos.length})'),
                        Tab(text: 'Shorts (${_shortsVideos.length})'),
                        Tab(text: 'بث مباشر (${_liveVideos.length})'),
                        const Tab(text: 'حول'),
                      ],
                    ),
                    theme.cardBg,
                    theme.dividerColor,
                  ),
                ),
              ];
            },
            body:
                _loadingVideos
                    ? _buildLoading(theme, w)
                    : ValueListenableBuilder<int>(
                      valueListenable: _contentVersion,
                      builder: (context, _, __) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _withRefresh(
                              onRefresh: _refreshLatestOnly,
                              child: _buildHomeTab(theme, w),
                            ),
                            _withRefresh(
                              onRefresh: _refreshLatestOnly,
                              child: _buildVideosTab(_regularVideos, theme, w),
                            ),
                            _withRefresh(
                              onRefresh: _refreshLatestOnly,
                              child: _buildShortsTab(_shortsVideos, theme, w),
                            ),
                            _withRefresh(
                              onRefresh: _refreshLatestOnly,
                              child: _buildLiveTab(_liveVideos, theme, w),
                            ),
                            _withRefresh(
                              onRefresh: _refreshLatestOnly,
                              child: _buildAboutTab(theme, w),
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

  /// ط­ط³ط§ط¨ ط§ط±طھظپط§ط¹ ط§ظ„ظ‡ظٹط¯ط± ط¯ظٹظ†ط§ظ…ظٹظƒظٹط§ظ‹ ط­ط³ط¨ ط­ط¬ظ… ط§ظ„ط´ط§ط´ط©
  double _channelHeaderHeight(double w, MediaQueryData mq) {
    final baseH = w * 0.55;
    final minH = 220.0;
    final maxH = 380.0;

    // ط¥ط°ط§ ظƒط§ظ†طھ ط§ظ„ط´ط§ط´ط© ظ‚طµظٹط±ط© ط¬ط¯ط§ظ‹ (landscape ط£ظˆ ط£ط¬ظ‡ط²ط© طµط؛ظٹط±ط©)
    final availableH = mq.size.height - mq.padding.top - kToolbarHeight;
    final safeMax = availableH * 0.55;

    return baseH.clamp(minH, min(maxH, safeMax));
  }

  Widget _buildChannelHeader(
    ChannelsTheme theme,
    double w,
    String name,
    String image,
    MediaQueryData mq,
  ) {
    final avatarSize = (w * 0.2).clamp(64.0, 100.0);
    final headerH = _channelHeaderHeight(w, mq);
    // ط­ط³ط§ط¨ ظ…ط§ ط¥ط°ط§ ظƒط§ظ† ط§ظ„ظ‡ظٹط¯ط± ط¶ظٹظ‚ط§ظ‹
    final isCompact = headerH < 260;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.chipBg, theme.cardBg],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.cardBg, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      image.isNotEmpty
                          ? ImageCacheConfig.channelAvatar(
                            url: image,
                            size: avatarSize,
                            errorWidget: _avatarFallback(name, theme, w),
                          )
                          : _avatarFallback(name, theme, w),
                ),
              ),
              SizedBox(height: isCompact ? w * 0.015 : w * 0.03),
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.045).clamp(16.0, 24.0),
                  fontWeight: FontWeight.w800,
                  color: theme.textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isCompact) SizedBox(height: w * 0.005),
              if (_channelInfo != null)
                Text(
                  '@${_channelInfo!.title}',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 13.0),
                    color: theme.subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: isCompact ? w * 0.008 : w * 0.015),
              if (_channelInfo != null)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: w * 0.015,
                  runSpacing: w * 0.005,
                  children: [
                    Text(
                      '${YoutubeService.formatCount(_channelInfo!.subscriberCount)} مشترك',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.026).clamp(9.0, 13.0),
                        color: theme.captionColor,
                      ),
                    ),
                    Text(
                      '•',
                      style: GoogleFonts.cairo(
                        color: theme.captionColor,
                        fontSize: (w * 0.026).clamp(9.0, 13.0),
                      ),
                    ),
                    Text(
                      '${_allVideos.length} فيديو',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.026).clamp(9.0, 13.0),
                        color: theme.captionColor,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: isCompact ? w * 0.012 : w * 0.025),
              // ط§ظ„ط£ط²ط±ط§ط± - طھطھظƒظٹظپ ظ…ط¹ ط§ظ„ط¹ط±ط¶ ط§ظ„ظ…طھط§ط­
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_youtubeChannelId != null) {
                          _openUrl(
                            'https://www.youtube.com/channel/$_youtubeChannelId?sub_confirmation=1',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: (w * 0.05).clamp(16.0, 28.0),
                          vertical: (w * 0.02).clamp(8.0, 14.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            size: (w * 0.04).clamp(14.0, 20.0),
                          ),
                          SizedBox(width: (w * 0.012).clamp(4.0, 8.0)),
                          Text(
                            'اشتراك',
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.03).clamp(11.0, 15.0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasTiktok()) ...[
                      SizedBox(width: (w * 0.015).clamp(4.0, 10.0)),
                      OutlinedButton(
                        onPressed: _openTiktokPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEE1D52),
                          side: const BorderSide(color: Color(0xFFEE1D52)),
                          padding: EdgeInsets.symmetric(
                            horizontal: (w * 0.035).clamp(12.0, 20.0),
                            vertical: (w * 0.02).clamp(8.0, 14.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: (w * 0.04).clamp(14.0, 20.0),
                            ),
                            SizedBox(width: (w * 0.008).clamp(2.0, 6.0)),
                            Text(
                              'TikTok',
                              style: GoogleFonts.cairo(
                                fontSize: (w * 0.026).clamp(9.0, 13.0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: isCompact ? w * 0.015 : w * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(ChannelsTheme theme, double w) {
    return ListView(
      cacheExtent: 1000,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(w * 0.04),
      children: [
        if (_hasTiktok()) ...[
          _buildTiktokBanner(theme, w),
          SizedBox(height: w * 0.04),
        ],
        if (_regularVideos.isNotEmpty) ...[
          _buildSectionHeader('آخر فيديو', theme, w),
          SizedBox(height: w * 0.02),
          RepaintBoundary(
            child: _YoutubeVideoCardLarge(
              video: _regularVideos.first,
              theme: theme,
              w: w,
              onTap: () => _openVideoPlayer(_regularVideos.first),
            ),
          ),
          SizedBox(height: w * 0.05),
        ],
        if (_shortsVideos.isNotEmpty) ...[
          _buildSectionHeader('Shorts', theme, w),
          SizedBox(height: w * 0.02),
          SizedBox(
            height: (w * 0.55).clamp(180.0, 280.0),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: min(_shortsVideos.length, 10),
              separatorBuilder: (_, __) => SizedBox(width: w * 0.02),
              itemBuilder:
                  (_, i) => RepaintBoundary(
                    child: _ShortsCard(
                      video: _shortsVideos[i],
                      theme: theme,
                      w: w,
                      onTap: () => _openVideoPlayer(_shortsVideos[i]),
                    ),
                  ),
            ),
          ),
          SizedBox(height: w * 0.05),
        ],
        if (_regularVideos.length > 1) ...[
          _buildSectionHeader('فيديوهات شائعة', theme, w),
          SizedBox(height: w * 0.02),
          ...(_regularVideos
              .skip(1)
              .take(5)
              .map(
                (v) => Padding(
                  padding: EdgeInsets.only(bottom: w * 0.02),
                  child: RepaintBoundary(
                    child: _YoutubeVideoCardSmall(
                      video: v,
                      theme: theme,
                      w: w,
                      onTap: () => _openVideoPlayer(v),
                    ),
                  ),
                ),
              )),
        ],
        SizedBox(height: w * 0.08),
      ],
    );
  }

  Widget _buildVideosTab(
    List<YoutubeVideo> videos,
    ChannelsTheme theme,
    double w,
  ) {
    if (videos.isEmpty) {
      return _buildEmptyState('لا توجد فيديوهات', theme, w);
    }

    return ListView.separated(
      cacheExtent: 1000,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(w * 0.04),
      itemCount: videos.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: w * 0.025),
      itemBuilder: (_, i) {
        if (i == videos.length) {
          return _BottomLoadMoreSection(
            theme: theme,
            w: w,
            loading: _loadingMore,
            reachedEnd: _reachedEnd,
            onTap: _loadMore,
          );
        }

        return RepaintBoundary(
          child: _YoutubeVideoCardSmall(
            video: videos[i],
            theme: theme,
            w: w,
            onTap: () => _openVideoPlayer(videos[i]),
          ),
        );
      },
    );
  }

  Widget _buildShortsTab(
    List<YoutubeVideo> shorts,
    ChannelsTheme theme,
    double w,
  ) {
    if (_loadingShorts && shorts.isEmpty) {
      return _buildLoading(theme, w);
    }

    if (!_shortsLoadedOnce && shorts.isEmpty) {
      return _buildLazyHint(
        title: 'Shorts',
        subtitle: 'سيتم تحميل الفيديوهات القصيرة عند فتح هذا التبويب',
        icon: Icons.play_circle_fill_rounded,
        theme: theme,
        w: w,
      );
    }

    if (shorts.isEmpty) {
      return _buildEmptyState('لا توجد Shorts', theme, w);
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(w * 0.02),
      itemCount: shorts.length + 1,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: w * 0.02,
        mainAxisSpacing: w * 0.02,
      ),
      itemBuilder: (_, i) {
        if (i == shorts.length) {
          return _BottomLoadMoreSection(
            theme: theme,
            w: w,
            loading: _loadingMore,
            reachedEnd: _reachedEnd,
            onTap: _loadMore,
          );
        }

        return RepaintBoundary(
          child: _ShortsCard(
            video: shorts[i],
            theme: theme,
            w: w,
            onTap: () => _openVideoPlayer(shorts[i]),
          ),
        );
      },
    );
  }

  Widget _buildLiveTab(
    List<YoutubeVideo> liveVideos,
    ChannelsTheme theme,
    double w,
  ) {
    if (_loadingLive && liveVideos.isEmpty) {
      return _buildLoading(theme, w);
    }

    if (!_liveLoadedOnce && liveVideos.isEmpty) {
      return _buildLazyHint(
        title: 'البث المباشر',
        subtitle: 'سيتم تحميل البثوث عند فتح هذا التبويب',
        icon: Icons.wifi_tethering_rounded,
        theme: theme,
        w: w,
      );
    }

    if (liveVideos.isEmpty) {
      return _buildEmptyState('لا توجد بثوث مباشرة', theme, w);
    }

    return ListView.separated(
      cacheExtent: 1000,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(w * 0.04),
      itemCount: liveVideos.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: w * 0.025),
      itemBuilder: (_, i) {
        if (i == liveVideos.length) {
          return _BottomLoadMoreSection(
            theme: theme,
            w: w,
            loading: _loadingMore,
            reachedEnd: _reachedEnd,
            onTap: _loadMore,
          );
        }

        return RepaintBoundary(
          child: _YoutubeVideoCardSmall(
            video: liveVideos[i],
            theme: theme,
            w: w,
            onTap: () => _openVideoPlayer(liveVideos[i]),
            isLive: true,
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(ChannelsTheme theme, double w) {
    final title = widget.scholar['title']?.toString() ?? '';
    final category = widget.scholar['category']?.toString() ?? '';
    final country = widget.scholar['country']?.toString() ?? '';
    final flag = widget.scholar['flag']?.toString() ?? '';

    return ListView(
      cacheExtent: 600,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(w * 0.04),
      children: [
        if (_hasTiktok()) ...[
          _buildTiktokBanner(theme, w),
          SizedBox(height: w * 0.04),
        ],
        if (_channelInfo != null && _channelInfo!.description.isNotEmpty) ...[
          _buildSectionHeader('الوصف', theme, w),
          SizedBox(height: w * 0.02),
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorder),
            ),
            child: Text(
              _channelInfo!.description,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.032).clamp(12.0, 15.0),
                color: theme.textColor,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: w * 0.04),
        ],
        _buildSectionHeader('التفاصيل', theme, w),
        SizedBox(height: w * 0.02),
        if (title.isNotEmpty) _buildInfoRow('اللقب', title, theme, w),
        if (category.isNotEmpty) _buildInfoRow('التصنيف', category, theme, w),
        if (country.isNotEmpty)
          _buildInfoRow('البلد', '$flag $country', theme, w),
        if (_channelInfo != null) ...[
          _buildInfoRow(
            'المشتركين',
            YoutubeService.formatCount(_channelInfo!.subscriberCount),
            theme,
            w,
          ),
          _buildInfoRow('عدد الفيديوهات', _channelInfo!.videoCount, theme, w),
        ],
        _buildInfoRow('إجمالي المحمّل', '${_allVideos.length}', theme, w),
        SizedBox(height: w * 0.08),
      ],
    );
  }

  Widget _buildTiktokBanner(ChannelsTheme theme, double w) {
    final tiktokData = _getTiktokData();
    final subs = tiktokData?['subscribers']?.toString() ?? '';

    return GestureDetector(
      onTap: _openTiktokPage,
      child: Container(
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF010101), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF69C9D0).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEE1D52).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all((w * 0.025).clamp(8.0, 14.0)),
              decoration: BoxDecoration(
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFF69C9D0),
                    Color(0xFFEE1D52),
                    Color(0xFF69C9D0),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: (w * 0.055).clamp(20.0, 28.0),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تابعنا على TikTok',
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.035).clamp(13.0, 17.0),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subs.isNotEmpty)
                    Text(
                      '$subs متابع',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.026).clamp(9.0, 13.0),
                        color: Colors.white60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: w * 0.01),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white54,
              size: (w * 0.04).clamp(14.0, 20.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ChannelsTheme theme, double w) {
    return Row(
      children: [
        Container(
          width: (w * 0.01).clamp(3.0, 5.0),
          height: (w * 0.045).clamp(14.0, 20.0),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: w * 0.02),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: (w * 0.04).clamp(14.0, 18.0),
              fontWeight: FontWeight.w800,
              color: theme.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLazyHint({
    required String title,
    required String subtitle,
    required IconData icon,
    required ChannelsTheme theme,
    required double w,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: (w * 0.14).clamp(42.0, 64.0),
              color: theme.primaryColor.withValues(alpha: 0.75),
            ),
            SizedBox(height: w * 0.03),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.042).clamp(14.0, 18.0),
                fontWeight: FontWeight.w800,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: w * 0.015),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.03).clamp(10.0, 13.5),
                color: theme.subtitleColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ChannelsTheme theme,
    double w,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (w * 0.28).clamp(90.0, 130.0),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.032).clamp(11.0, 15.0),
                color: theme.subtitleColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.032).clamp(11.0, 15.0),
                color: theme.textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, ChannelsTheme theme, double w) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: (w * 0.14).clamp(46.0, 70.0),
              color: theme.captionColor.withValues(alpha: 0.3),
            ),
            SizedBox(height: w * 0.03),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.035).clamp(12.0, 16.0),
                color: theme.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(ChannelsTheme theme, double w) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          SizedBox(height: w * 0.03),
          Text(
            'جاري التحميل...',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.035).clamp(12.0, 15.0),
              color: theme.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name, ChannelsTheme theme, double w) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: theme.avatarRingGradient),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'طں',
          style: GoogleFonts.cairo(
            fontSize: (w * 0.07).clamp(24.0, 40.0),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WIDGET: _YoutubeVideoCardLarge
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _YoutubeVideoCardLarge extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _YoutubeVideoCardLarge({
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = VideoHistoryService.getProgress(video.id);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCacheConfig.videoThumbnail(
                    url: video.thumbnail,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: theme.chipBg,
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        size: (w * 0.14).clamp(46.0, 64.0),
                        color: theme.captionColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.024).clamp(9.0, 11.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (progress > 0 && progress < 0.9)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.024).clamp(9.0, 11.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: w * 0.025),
          Text(
            video.title,
            style: GoogleFonts.cairo(
              fontSize: (w * 0.037).clamp(13.0, 17.0),
              fontWeight: FontWeight.w700,
              color: theme.textColor,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: w * 0.01),
          Wrap(
            spacing: w * 0.015,
            runSpacing: w * 0.005,
            children: [
              if (video.viewCount != '0')
                Text(
                  '${YoutubeService.formatViews(video.viewCount)} مشاهدة',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 13.0),
                    color: theme.subtitleColor,
                  ),
                ),
              if (video.viewCount != '0')
                Text(
                  '•',
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: (w * 0.028).clamp(10.0, 13.0),
                  ),
                ),
              Text(
                TimeFormatHelper.shortTimeAgoArabic(video.publishedAt),
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.028).clamp(10.0, 13.0),
                  color: theme.subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WIDGET: _YoutubeVideoCardSmall
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _YoutubeVideoCardSmall extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;
  final bool isLive;

  const _YoutubeVideoCardSmall({
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = VideoHistoryService.getProgress(video.id);
    final thumbW = (w * 0.4).clamp(130.0, 190.0);
    final thumbH = thumbW * (9 / 16);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: thumbW,
              height: thumbH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCacheConfig.videoThumbnail(
                    url: video.thumbnail,
                    width: thumbW,
                    height: thumbH,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: theme.chipBg,
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        size: (w * 0.08).clamp(28.0, 40.0),
                        color: theme.captionColor,
                      ),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: (w * 0.015).clamp(5.0, 10.0),
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: (w * 0.015).clamp(5.0, 7.0),
                              height: (w * 0.015).clamp(5.0, 7.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: (w * 0.008).clamp(2.0, 5.0)),
                            Flexible(
                              child: Text(
                                'بث مباشر',
                                style: GoogleFonts.cairo(
                                  fontSize: (w * 0.02).clamp(7.0, 10.0),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (video.duration.isNotEmpty && !isLive)
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
                            fontSize: (w * 0.022).clamp(8.0, 10.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (!isLive && progress > 0 && progress < 0.9)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.022).clamp(8.0, 10.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
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
                  video.title,
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.033).clamp(11.0, 15.0),
                    fontWeight: FontWeight.w700,
                    color: theme.textColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: w * 0.01),
                if (video.viewCount != '0')
                  Text(
                    '${YoutubeService.formatViews(video.viewCount)} مشاهدة',
                    style: GoogleFonts.cairo(
                      fontSize: (w * 0.025).clamp(9.0, 12.0),
                      color: theme.subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: w * 0.005),
                Text(
                  TimeFormatHelper.shortTimeAgoArabic(video.publishedAt),
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.025).clamp(9.0, 12.0),
                    color: theme.subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert_rounded,
            size: (w * 0.04).clamp(14.0, 20.0),
            color: theme.captionColor,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WIDGET: _ShortsCard
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ShortsCard extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _ShortsCard({
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = VideoHistoryService.getProgress(video.id);
    final cardW = (w * 0.38).clamp(120.0, 170.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardW,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cW = constraints.maxWidth;
                    final badgeFontSize = (cW * 0.06).clamp(7.0, 10.0);
                    final viewsFontSize = (cW * 0.07).clamp(8.0, 12.0);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageCacheConfig.videoThumbnail(
                          url: video.thumbnail,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: theme.chipBg,
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              size: (cW * 0.3).clamp(30.0, 54.0),
                              color: theme.captionColor,
                            ),
                          ),
                        ),
                        Container(
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: (cW * 0.09).clamp(10.0, 16.0),
                                ),
                                SizedBox(width: (cW * 0.01).clamp(1.0, 3.0)),
                                Text(
                                  'Shorts',
                                  style: GoogleFonts.cairo(
                                    fontSize: badgeFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (video.viewCount != '0')
                          Positioned(
                            bottom: 8,
                            right: 8,
                            left: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: (cW * 0.09).clamp(10.0, 16.0),
                                ),
                                SizedBox(width: (cW * 0.02).clamp(2.0, 5.0)),
                                Flexible(
                                  child: Text(
                                    YoutubeService.formatViews(video.viewCount),
                                    style: GoogleFonts.cairo(
                                      fontSize: viewsFontSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (progress > 0 && progress < 0.9)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: GoogleFonts.cairo(
                                  fontSize: badgeFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all((w * 0.02).clamp(6.0, 10.0)),
              child: Text(
                video.title,
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.028).clamp(10.0, 13.0),
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WIDGET: _BottomLoadMoreSection
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BottomLoadMoreSection extends StatelessWidget {
  final ChannelsTheme theme;
  final double w;
  final bool loading;
  final bool reachedEnd;
  final VoidCallback onTap;

  const _BottomLoadMoreSection({
    required this.theme,
    required this.w,
    required this.loading,
    required this.reachedEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: w * 0.05),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: theme.primaryColor,
            ),
          ),
        ),
      );
    }

    if (reachedEnd) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: w * 0.05),
        child: Center(
          child: Text(
            'تم عرض جميع الفيديوهات',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.03).clamp(10.0, 13.0),
              color: theme.subtitleColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.04),
      child: Center(
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: theme.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: (w * 0.06).clamp(20.0, 30.0),
              vertical: (w * 0.025).clamp(8.0, 14.0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.cardBorder),
            ),
          ),
          child: Text(
            'تحميل المزيد',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.032).clamp(11.0, 14.0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// DELEGATE: _SliverTabBarDelegate
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;
  final Color dividerColor;

  _SliverTabBarDelegate(this.tabBar, this.bgColor, this.dividerColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
