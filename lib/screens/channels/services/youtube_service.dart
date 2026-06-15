import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import '../helpers/error_handler.dart';
import '../helpers/video_cache_helper.dart';

class YoutubeService {
  static const String _apiKey = '';

  static final Map<String, String> _channelIdCache = {};
  static final LinkedHashMap<String, _CacheEntry<List<YoutubeVideo>>> _memoryCache =
  LinkedHashMap();

  static const int _maxMemoryCacheSize = 50;
  static const Duration _memoryCacheDuration = Duration(minutes: 10);
  static const Duration _cacheDuration = Duration(hours: 6);

  static int _apiCallsToday = 0;
  static DateTime _lastApiReset = DateTime.now();
  static const int _dailyLimit = 9000;

  static Future<Object> getChannelVideosSafe({
    required String channelUrl,
    String? handle,
    int maxResults = 15,
  }) async {
    return ErrorHandler.instance.runSafe(
      operationName: 'getChannelVideos',
      retries: 2,
      retryDelay: const Duration(seconds: 1),
      fallback: <YoutubeVideo>[],
      operation: () => getChannelVideos(
        channelUrl: channelUrl,
        handle: handle,
        maxResults: maxResults,
      ),
    ) ??
        [];
  }

  static Future<Object> searchVideosSafe({
    required String query,
    int maxResults = 30,
  }) async {
    return ErrorHandler.instance.runSafe(
      operationName: 'searchVideos',
      retries: 2,
      fallback: <YoutubeVideo>[],
      operation: () => searchVideos(
        query: query,
        maxResults: maxResults,
      ),
    ) ??
        [];
  }

  static Future<VideoDetails?> getVideoDetailsSafe(String videoId) async {
    return ErrorHandler.instance.runSafe(
      operationName: 'getVideoDetails',
      retries: 1,
      fallback: null,
      operation: () => getVideoFullDetails(videoId),
    );
  }

  static Future<String?> getChannelIdPublic({
    required String channelUrl,
    String? handle,
  }) async {
    return _getChannelId(channelUrl, handle);
  }

  static Future<http.Response?> safeChannelPage(Uri url) async {
    try {
      return await _safeGet(url);
    } catch (_) {
      return null;
    }
  }

  static List<YoutubeVideo> parseChannelPagePublic(
      String html,
      String channelId,
      int maxResults,
      ) {
    return _parseChannelVideosPage(html, channelId, maxResults);
  }

  static bool isLikelyShortVideo(YoutubeVideo v) {
    if (v.type == VideoType.shorts) return true;

    final lower = v.title.toLowerCase();
    if (lower.contains('#shorts') ||
        lower.contains('shorts') ||
        lower.contains('#short')) {
      return true;
    }

    if (v.duration.isNotEmpty) {
      final parts = v.duration.split(':');
      if (parts.length == 2) {
        final mins = int.tryParse(parts[0]) ?? 0;
        final secs = int.tryParse(parts[1]) ?? 0;
        if (mins == 0 && secs <= 60) return true;
      }
    }

    return false;
  }

  static Future<bool> _checkApiQuota() async {
    final now = DateTime.now();
    if (now.difference(_lastApiReset).inHours >= 24) {
      _apiCallsToday = 0;
      _lastApiReset = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('api_calls_today', 0);
      await prefs.setString('api_reset_date', now.toIso8601String());
    }
    return _apiCallsToday < _dailyLimit;
  }

  static void _incrementApiCalls(int units) {
    _apiCallsToday += units;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('api_calls_today', _apiCallsToday);
    });
  }

  static Future<List<YoutubeVideo>> getChannelVideosSmart({
    required String channelId,
    required String channelUrl,
    String? handle,
    int maxResults = 200,
  }) async {
    if (_apiKey.isNotEmpty) {
      final hasQuota = await _checkApiQuota();
      if (hasQuota) {
        try {
          final videos = await getChannelVideosWithApi(
            channelId: channelId,
            maxResults: maxResults,
          );
          if (videos.isNotEmpty) {
            await _saveToLocalCache(channelId, videos);
            return videos;
          }
        } catch (e) {
          debugPrint('⚠️ API failed, fallback: $e');
        }
      }
    }

    final cached = await _loadFromLocalCache(channelId);
    if (cached.isNotEmpty) {
      _updateCacheInBackground(channelId, channelUrl, handle);
      return cached;
    }

    return _getFreeVideos(
      channelId: channelId,
      channelUrl: channelUrl,
      handle: handle,
      maxResults: maxResults,
    );
  }

  static Future<List<YoutubeVideo>> _getFreeVideos({
    required String channelId,
    required String channelUrl,
    String? handle,
    int maxResults = 200,
  }) async {
    final allVideos = <YoutubeVideo>[];
    final seenIds = <String>{};

    try {
      final rss = await getChannelVideos(
        channelUrl: channelUrl,
        handle: handle,
        maxResults: 15,
      );
      for (final v in rss) {
        if (seenIds.add(v.id)) {
          allVideos.add(v);
        }
      }
    } catch (_) {}

    try {
      final page = await getAllChannelVideos(
        channelUrl: channelUrl,
        handle: handle,
        maxResults: 100,
      );
      for (final v in page) {
        if (seenIds.add(v.id)) {
          allVideos.add(v);
        }
      }
    } catch (_) {}

    allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allVideos.take(maxResults).toList();
  }

  static Future<void> _saveToLocalCache(
      String channelId, List<YoutubeVideo> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'videos': videos
            .map((v) => {
          'id': v.id,
          'title': v.title,
          'thumbnail': v.thumbnail,
          'channelTitle': v.channelTitle,
          'channelId': v.channelId,
          'publishedAt': v.publishedAt.toIso8601String(),
          'viewCount': v.viewCount,
          'likeCount': v.likeCount,
          'duration': v.duration,
          'url': v.url,
          'type': v.type.index,
        })
            .toList(),
      };
      await prefs.setString('channel_cache_$channelId', jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Cache save: $e');
    }
  }

  static Future<List<YoutubeVideo>> _loadFromLocalCache(String channelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('channel_cache_$channelId');
      if (cached == null) return [];

      final data = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.tryParse(data['timestamp'] ?? '');

      if (timestamp == null ||
          DateTime.now().difference(timestamp) > _cacheDuration) {
        return [];
      }

      return (data['videos'] as List)
          .map((v) => YoutubeVideo(
        id: v['id'],
        title: v['title'],
        description: '',
        thumbnail: v['thumbnail'],
        channelTitle: v['channelTitle'],
        channelId: v['channelId'],
        publishedAt:
        DateTime.tryParse(v['publishedAt']) ?? DateTime.now(),
        viewCount: v['viewCount'],
        likeCount: v['likeCount'],
        duration: v['duration'],
        url: v['url'],
        type: VideoType.values[v['type'] ?? 0],
      ))
          .toList();
    } catch (e) {
      debugPrint('❌ Cache load: $e');
      return [];
    }
  }

  static void _updateCacheInBackground(
      String channelId, String channelUrl, String? handle) {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final videos = await _getFreeVideos(
          channelId: channelId,
          channelUrl: channelUrl,
          handle: handle,
        );
        if (videos.isNotEmpty) {
          await _saveToLocalCache(channelId, videos);
        }
      } catch (_) {}
    });
  }

  static Future<http.Response> _safeGet(
      Uri url, {
        Map<String, String>? headers,
        Duration timeout = const Duration(seconds: 15),
      }) async {
    final response = await http.get(url, headers: headers).timeout(timeout);

    if (response.statusCode == 429) {
      throw HttpException('Rate limited', uri: url);
    }

    if (response.statusCode >= 500) {
      throw HttpException('Server error: ${response.statusCode}', uri: url);
    }

    return response;
  }

  static Future<List<YoutubeVideo>> getChannelVideos({
    required String channelUrl,
    String? handle,
    String? channelId,
    int maxResults = 15,
  }) async {
    try {
      final resolvedChannelId = await resolveChannelId(
        providedChannelId: channelId,
        channelUrl: channelUrl,
        handle: handle,
      );

      if (resolvedChannelId == null) return [];

      final rssUrl = Uri.parse(
        'https://www.youtube.com/feeds/videos.xml?channel_id=$resolvedChannelId',
      );

      final response = await _safeGet(
        rssUrl,
        timeout: const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return _parseRssFeed(response.body, resolvedChannelId, maxResults);
      }

      return [];
    } catch (e, stack) {
      ErrorHandler.instance.handleException(e, stack);
      return [];
    }
  }

  static Future<List<YoutubeVideo>> getChannelVideosWithCache({
    required String channelUrl,
    String? handle,
    int maxResults = 15,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${channelUrl}_$handle';

    if (!forceRefresh) {
      final memCached = _getFromMemoryCache(cacheKey);
      if (memCached != null) return memCached;
    }

    if (!forceRefresh) {
      final diskCached = await VideoCacheHelper.getCachedVideos(cacheKey);
      if (diskCached != null && diskCached.isNotEmpty) {
        _addToMemoryCache(cacheKey, diskCached);
        return diskCached;
      }
    }

    final videos = await getChannelVideos(
      channelUrl: channelUrl,
      handle: handle,
      maxResults: maxResults,
    );

    if (videos.isNotEmpty) {
      _addToMemoryCache(cacheKey, videos);
      await VideoCacheHelper.cacheVideos(cacheKey, videos);
    }

    return videos;
  }

  static Future<List<YoutubeVideo>> searchVideosWithCache({
    required String query,
    int maxResults = 30,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await VideoCacheHelper.getCachedSearchResults(query);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final results = await searchVideos(query: query, maxResults: maxResults);

    if (results.isNotEmpty) {
      await VideoCacheHelper.cacheSearchResults(query, results);
    }

    return results;
  }

  static void _addToMemoryCache(String key, List<YoutubeVideo> videos) {
    while (_memoryCache.length >= _maxMemoryCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }

    _memoryCache[key] = _CacheEntry(
      data: videos,
      timestamp: DateTime.now(),
    );
  }

  static List<YoutubeVideo>? _getFromMemoryCache(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) > _memoryCacheDuration) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.data;
  }

  static void clearMemoryCache() {
    _memoryCache.clear();
  }

  static Future<List<YoutubeVideo>> getMultipleChannelsVideos({
    required List<Map<String, dynamic>> channels,
    int videosPerChannel = 5,
    int maxConcurrent = 3,
  }) async {
    final allVideos = <YoutubeVideo>[];

    for (int i = 0; i < channels.length; i += maxConcurrent) {
      final batch = channels.skip(i).take(maxConcurrent);

      final batchFutures = batch.map((channel) async {
        try {
          return await getChannelVideosWithCache(
            channelUrl: channel['url'] ?? '',
            handle: channel['handle'],
            maxResults: videosPerChannel,
          );
        } catch (_) {
          return <YoutubeVideo>[];
        }
      });

      final results = await Future.wait(batchFutures);
      for (final videos in results) {
        allVideos.addAll(videos);
      }

      if (i + maxConcurrent < channels.length) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    return allVideos;
  }

  static Future<T?> _withRetry<T>({
    required Future<T?> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int retries = 0;
    Duration delay = initialDelay;

    while (retries < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) rethrow;
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    return null;
  }

  static Future<List<YoutubeVideo>> searchVideos({
    required String query,
    int maxResults = 30,
    bool sortByViews = true,
  }) async {
    try {
      final sortParam = sortByViews ? 'CAMSAhAB' : 'CAASAhAB';

      final searchUrl = Uri.parse(
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}&sp=$sortParam',
      );

      final response = await http.get(
        searchUrl,
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'ar,en;q=0.9',
        },
      );

      if (response.statusCode == 200) {
        return _parseSearchResults(response.body, maxResults);
      }
    } catch (e) {
      debugPrint('❌ Search Error: $e');
    }
    return [];
  }

  static Future<List<YoutubeVideo>> searchVideosWithPagination({
    required String query,
    required int page,
    int maxResults = 20,
  }) async {
    try {
      final sortOptions = ['CAMSAhAB', 'CAASAhAB', 'CAESAhAB'];
      final sortFilter = sortOptions[page % sortOptions.length];
      final extraTerms = ['', ' شرح', ' تفسير', ' فتوى', ' محاضرة'];
      final extraTerm = extraTerms[page % extraTerms.length];
      final finalQuery = query + extraTerm;

      final searchUrl = Uri.parse(
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(finalQuery)}&sp=$sortFilter',
      );

      final response = await http.get(
        searchUrl,
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'ar,en;q=0.9',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        return _parseSearchResults(response.body, maxResults);
      }
    } catch (e) {
      debugPrint('❌ Pagination Error: $e');
    }
    return [];
  }

  static Future<List<YoutubeVideo>> searchInChannel({
    required String channelId,
    required String query,
    int maxResults = 20,
  }) async {
    try {
      final searchUrl = Uri.parse(
        'https://www.youtube.com/channel/$channelId/search?query=${Uri.encodeComponent(query)}',
      );

      final response = await _safeGet(
        searchUrl,
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'ar,en;q=0.9',
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final results = _parseSearchResults(response.body, maxResults);
        if (results.isNotEmpty) {
          return results;
        }
      }
    } catch (e) {
      debugPrint('❌ Channel Search Error: $e');
    }
    return [];
  }

  static Future<List<YoutubeVideo>> searchInChannelByUrl({
    required String channelUrl,
    required String query,
    String? handle,
    String? channelId,
    int maxResults = 15,
  }) async {
    try {
      final resolvedChannelId = await resolveChannelId(
        providedChannelId: channelId,
        channelUrl: channelUrl,
        handle: handle,
      );
      if (resolvedChannelId == null) return [];

      final collected = <YoutubeVideo>[];
      final seen = <String>{};

      if (query.trim().isEmpty) {
        final urls = [
          Uri.parse('https://www.youtube.com/channel/$resolvedChannelId/videos'),
          Uri.parse('https://www.youtube.com/channel/$resolvedChannelId/streams'),
          Uri.parse('https://www.youtube.com/channel/$resolvedChannelId/shorts'),
        ];

        for (final url in urls) {
          try {
            final response = await _safeGet(
              url,
              headers: {
                'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept-Language': 'ar,en;q=0.9',
              },
              timeout: const Duration(seconds: 15),
            );

            if (response.statusCode == 200) {
              final parsed = _parseChannelVideosPage(
                response.body,
                resolvedChannelId,
                maxResults,
              );

              for (final v in parsed) {
                if (v.id.isNotEmpty && seen.add(v.id)) {
                  collected.add(v);
                }
              }
            }
          } catch (_) {}
        }

        collected.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return collected.take(maxResults).toList();
      }

      return await searchInChannel(
        channelId: resolvedChannelId,
        query: query,
        maxResults: maxResults,
      );
    } catch (_) {
      return [];
    }
  }

  static Future<List<YoutubeVideo>> getChannelLatestBatch({
    required String channelUrl,
    String? handle,
    String? channelId,
    int maxResults = 40,
  }) async {
    final all = <YoutubeVideo>[];
    final seen = <String>{};

    try {
      final rss = await getChannelVideos(
        channelUrl: channelUrl,
        handle: handle,
        channelId: channelId,
        maxResults: 15,
      );

      for (final v in rss) {
        if (v.id.isNotEmpty && seen.add(v.id)) {
          all.add(v);
        }
      }

      final pageVideos = await getAllChannelVideos(
        channelUrl: channelUrl,
        handle: handle,
        channelId: channelId,
        maxResults: max(maxResults, 80),
      );

      for (final v in pageVideos) {
        if (v.id.isNotEmpty && seen.add(v.id)) {
          all.add(v);
        }
      }

      all.sort((a, b) {
        final dateCompare = b.publishedAt.compareTo(a.publishedAt);
        if (dateCompare != 0) return dateCompare;

        final viewA = int.tryParse(a.viewCount) ?? 0;
        final viewB = int.tryParse(b.viewCount) ?? 0;
        return viewB.compareTo(viewA);
      });

      return all.take(maxResults).toList();
    } catch (e) {
      debugPrint('❌ getChannelLatestBatch error: $e');
      return all;
    }
  }

  static Future<List<YoutubeVideo>> getChannelVideosWithApi({
    required String channelId,
    int maxResults = 500,
  }) async {
    final allVideos = <YoutubeVideo>[];
    String? nextPageToken;

    try {
      do {
        final params = {
          'part': 'snippet',
          'channelId': channelId,
          'maxResults': '50',
          'order': 'date',
          'type': 'video',
          'key': _apiKey,
          if (nextPageToken != null) 'pageToken': nextPageToken,
        };

        final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search',
        ).replace(queryParameters: params);

        final response = await http.get(url);

        if (response.statusCode == 200) {
          _incrementApiCalls(100);

          final data = json.decode(response.body);
          final items = data['items'] as List? ?? [];
          nextPageToken = data['nextPageToken'] as String?;

          final videoIds = items
              .map((i) => i['id']?['videoId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .join(',');

          if (videoIds.isNotEmpty) {
            final detailsUrl = Uri.parse(
              'https://www.googleapis.com/youtube/v3/videos',
            ).replace(queryParameters: {
              'part': 'contentDetails,statistics,snippet',
              'id': videoIds,
              'key': _apiKey,
            });

            final detailsResponse = await http.get(detailsUrl);

            if (detailsResponse.statusCode == 200) {
              _incrementApiCalls(1);

              final detailsData = json.decode(detailsResponse.body);
              final detailItems = detailsData['items'] as List? ?? [];

              for (final item in detailItems) {
                final video = _parseApiVideoItem(item, channelId);
                if (video != null) allVideos.add(video);
              }
            }
          }
        } else if (response.statusCode == 403) {
          break;
        } else {
          break;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      } while (nextPageToken != null && allVideos.length < maxResults);

      return allVideos;
    } catch (e) {
      debugPrint('❌ API error: $e');
      return allVideos;
    }
  }

  static Future<List<YoutubeVideo>> getChannelShortsWithApi({
    required String channelId,
  }) async {
    final allShorts = <YoutubeVideo>[];
    String? nextPageToken;

    try {
      do {
        final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search',
        ).replace(queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'maxResults': '50',
          'order': 'date',
          'type': 'video',
          'videoDuration': 'short',
          'key': _apiKey,
          if (nextPageToken != null) 'pageToken': nextPageToken,
        });

        final response = await http.get(url);

        if (response.statusCode == 200) {
          _incrementApiCalls(100);

          final data = json.decode(response.body);
          final items = data['items'] as List? ?? [];
          nextPageToken = data['nextPageToken'] as String?;

          for (final item in items) {
            final videoId = item['id']?['videoId']?.toString() ?? '';
            if (videoId.isEmpty) continue;

            final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
            allShorts.add(
              YoutubeVideo(
                id: videoId,
                title: snippet['title'] ?? '',
                description: snippet['description'] ?? '',
                thumbnail: snippet['thumbnails']?['high']?['url'] ??
                    'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
                channelTitle: snippet['channelTitle'] ?? '',
                channelId: channelId,
                publishedAt:
                DateTime.tryParse(snippet['publishedAt'] ?? '') ??
                    DateTime.now(),
                viewCount: '0',
                likeCount: '0',
                duration: '',
                url: 'https://www.youtube.com/shorts/$videoId',
                type: VideoType.shorts,
              ),
            );
          }
        } else {
          break;
        }
      } while (nextPageToken != null && allShorts.length < 200);

      return allShorts;
    } catch (e) {
      debugPrint('❌ Shorts API error: $e');
      return allShorts;
    }
  }

  static YoutubeVideo? _parseApiVideoItem(
      Map<String, dynamic> item, String channelId) {
    try {
      final id = item['id'] as String;
      final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
      final contentDetails =
          item['contentDetails'] as Map<String, dynamic>? ?? {};
      final statistics = item['statistics'] as Map<String, dynamic>? ?? {};

      final isoDuration = contentDetails['duration']?.toString() ?? '';
      final duration = _parseIsoDuration(isoDuration);

      return YoutubeVideo(
        id: id,
        title: snippet['title'] ?? '',
        description: snippet['description'] ?? '',
        thumbnail: snippet['thumbnails']?['maxres']?['url'] ??
            snippet['thumbnails']?['high']?['url'] ??
            'https://i.ytimg.com/vi/$id/maxresdefault.jpg',
        channelTitle: snippet['channelTitle'] ?? '',
        channelId: snippet['channelId']?.toString() ?? channelId,
        publishedAt:
        DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
        viewCount: statistics['viewCount']?.toString() ?? '0',
        likeCount: statistics['likeCount']?.toString() ?? '0',
        commentCount: statistics['commentCount']?.toString() ?? '0',
        duration: duration,
        url: 'https://www.youtube.com/watch?v=$id',
      );
    } catch (_) {
      return null;
    }
  }

  static YoutubeVideo _hydrateVideoWithFallbackData(
      YoutubeVideo video, {
        String? fallbackTitle,
        String? fallbackChannelTitle,
        String? fallbackThumbnail,
        String? fallbackViewCount,
        DateTime? fallbackPublishedAt,
      }) {
    return YoutubeVideo(
      id: video.id,
      title: video.title.trim().isNotEmpty
          ? video.title
          : (fallbackTitle?.trim().isNotEmpty == true ? fallbackTitle!.trim() : video.title),
      description: video.description,
      thumbnail: video.thumbnail.trim().isNotEmpty
          ? video.thumbnail
          : (fallbackThumbnail?.trim().isNotEmpty == true
          ? fallbackThumbnail!.trim()
          : video.thumbnail),
      channelTitle: video.channelTitle.trim().isNotEmpty
          ? video.channelTitle
          : (fallbackChannelTitle?.trim().isNotEmpty == true
          ? fallbackChannelTitle!.trim()
          : video.channelTitle),
      channelId: video.channelId,
      publishedAt: video.publishedAt.year > 2000
          ? video.publishedAt
          : (fallbackPublishedAt ?? video.publishedAt),
      viewCount: (video.viewCount.trim().isNotEmpty && video.viewCount != '0')
          ? video.viewCount
          : ((fallbackViewCount?.trim().isNotEmpty == true)
          ? fallbackViewCount!.trim()
          : video.viewCount),
      likeCount: video.likeCount,
      commentCount: video.commentCount,
      duration: video.duration,
      url: video.url,
      type: video.type,
    );
  }

  static Map<String, dynamic>? _extractFallbackVideoDataFromHtml(
      String html,
      String videoId,
      ) {
    try {
      final marker = '"videoId":"$videoId"';
      final start = html.indexOf(marker);
      if (start == -1) return null;

      final end = (start + 6000 < html.length) ? start + 6000 : html.length;
      final chunk = html.substring(start, end);

      String title = '';
      String channelTitle = '';
      String viewCount = '0';
      DateTime? publishedAt;

      final titleMarker = '"title":{"runs":[{"text":"';
      final titleStart = chunk.indexOf(titleMarker);
      if (titleStart != -1) {
        final from = titleStart + titleMarker.length;
        final to = chunk.indexOf('"', from);
        if (to != -1) {
          title = _decodeHtmlEntities(chunk.substring(from, to)).trim();
        }
      }

      const ownerMarkers = [
        '"ownerText":{"runs":[{"text":"',
        '"longBylineText":{"runs":[{"text":"',
        '"shortBylineText":{"runs":[{"text":"',
      ];

      for (final m in ownerMarkers) {
        final idx = chunk.indexOf(m);
        if (idx != -1) {
          final from = idx + m.length;
          final to = chunk.indexOf('"', from);
          if (to != -1) {
            channelTitle = _decodeHtmlEntities(chunk.substring(from, to)).trim();
            break;
          }
        }
      }

      const viewMarkers = [
        '"viewCountText":{"simpleText":"',
        '"shortViewCountText":{"simpleText":"',
        '"viewCountText":{"runs":[{"text":"',
        '"shortViewCountText":{"runs":[{"text":"',
      ];

      for (final m in viewMarkers) {
        final idx = chunk.indexOf(m);
        if (idx != -1) {
          final from = idx + m.length;
          final to = chunk.indexOf('"', from);
          if (to != -1) {
            final raw = chunk.substring(from, to).trim();
            if (raw.isNotEmpty) {
              viewCount = _extractNumber(raw);
              break;
            }
          }
        }
      }

      const dateMarkers = [
        '"publishedTimeText":{"simpleText":"',
        '"publishedTimeText":{"runs":[{"text":"',
      ];

      for (final m in dateMarkers) {
        final idx = chunk.indexOf(m);
        if (idx != -1) {
          final from = idx + m.length;
          final to = chunk.indexOf('"', from);
          if (to != -1) {
            final raw = chunk.substring(from, to).trim();
            if (raw.isNotEmpty) {
              publishedAt = _parseRelativeDate(raw);
              break;
            }
          }
        }
      }

      return {
        'title': title,
        'channelTitle': channelTitle,
        'viewCount': viewCount,
        'thumbnail': 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
        'publishedAt': publishedAt,
      };
    } catch (_) {
      return null;
    }
  }

  static String _parseIsoDuration(String iso) {
    try {
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(iso);
      if (match == null) return '';

      final h = int.tryParse(match.group(1) ?? '') ?? 0;
      final m = int.tryParse(match.group(2) ?? '') ?? 0;
      final s = int.tryParse(match.group(3) ?? '') ?? 0;

      if (h > 0) {
        return '${h.toString().padLeft(2, '0')}:'
            '${m.toString().padLeft(2, '0')}:'
            '${s.toString().padLeft(2, '0')}';
      }
      return '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  static Future<ChannelInfo?> getChannelInfoWithApi(String channelId) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/channels',
      ).replace(queryParameters: {
        'part': 'snippet,statistics',
        'id': channelId,
        'key': _apiKey,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        _incrementApiCalls(1);

        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        if (items.isEmpty) return null;

        final item = items.first as Map<String, dynamic>;
        final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
        final statistics = item['statistics'] as Map<String, dynamic>? ?? {};

        return ChannelInfo(
          title: snippet['title'] ?? '',
          description: snippet['description'] ?? '',
          thumbnail: snippet['thumbnails']?['high']?['url'] ?? '',
          subscriberCount: statistics['subscriberCount']?.toString() ?? '0',
          videoCount: statistics['videoCount']?.toString() ?? '0',
        );
      }
    } catch (e) {
      debugPrint('❌ Channel info API: $e');
    }
    return null;
  }

  static List<YoutubeVideo> _parseSearchResults(String html, int maxResults) {
    final videos = <YoutubeVideo>[];

    try {
      final regex = RegExp(r'var ytInitialData = ({.+?});</script>');
      final match = regex.firstMatch(html);

      if (match != null) {
        final jsonStr = match.group(1)!;
        final data = json.decode(jsonStr);
        final contents = _findVideoContents(data);

        for (final content in contents.take(maxResults)) {
          final video = _extractVideoFromContent(content);
          if (video != null) videos.add(video);
        }
      } else {
        videos.addAll(_parseSearchResultsSimple(html, maxResults));
      }
    } catch (_) {
      videos.addAll(_parseSearchResultsSimple(html, maxResults));
    }

    return videos;
  }

  static List<dynamic> _findVideoContents(Map<String, dynamic> data) {
    final results = <dynamic>[];

    void search(dynamic obj) {
      if (obj is Map<String, dynamic>) {
        if (obj.containsKey('videoRenderer')) {
          results.add(obj['videoRenderer']);
        } else if (obj.containsKey('gridVideoRenderer')) {
          results.add(obj['gridVideoRenderer']);
        } else if (obj.containsKey('compactVideoRenderer')) {
          results.add(obj['compactVideoRenderer']);
        } else if (obj.containsKey('reelItemRenderer')) {
          results.add(obj['reelItemRenderer']);
        } else {
          for (final value in obj.values) {
            search(value);
          }
        }
      } else if (obj is List) {
        for (final item in obj) {
          search(item);
        }
      }
    }

    search(data);
    return results;
  }


  static Future<List<YoutubeVideo>> getAllChannelVideos({
    required String channelUrl,
    String? handle,
    String? channelId,
    int maxResults = 200,
  }) async {
    final allVideos = <YoutubeVideo>[];
    final seenIds = <String>{};

    try {
      final resolvedChannelId = await resolveChannelId(
        providedChannelId: channelId,
        channelUrl: channelUrl,
        handle: handle,
      );
      if (resolvedChannelId == null) return [];

      try {
        final rssUrl =
            'https://www.youtube.com/feeds/videos.xml?channel_id=$resolvedChannelId';
        final rssResponse = await _safeGet(
          Uri.parse(rssUrl),
          headers: {
            'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept-Language': 'ar,en;q=0.9',
          },
          timeout: const Duration(seconds: 12),
        );

        if (rssResponse.statusCode == 200) {
          final rssVideos =
          _parseRssFeed(rssResponse.body, resolvedChannelId, 20);
          for (final v in rssVideos) {
            if (v.id.isNotEmpty && seenIds.add(v.id)) {
              allVideos.add(v);
            }
          }
        }
      } catch (_) {}

      final pages = [
        'https://www.youtube.com/channel/$resolvedChannelId/videos',
        'https://www.youtube.com/channel/$resolvedChannelId/streams',
        'https://www.youtube.com/channel/$resolvedChannelId/shorts',
      ];

      for (final page in pages) {
        try {
          final response = await _safeGet(
            Uri.parse(page),
            headers: {
              'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept-Language': 'ar,en;q=0.9',
            },
            timeout: const Duration(seconds: 15),
          );

          if (response.statusCode == 200) {
            final pageVideos =
            _parseChannelVideosPage(response.body, resolvedChannelId, 120);

            for (final v in pageVideos) {
              if (v.id.isNotEmpty && seenIds.add(v.id)) {
                allVideos.add(v);
              }
            }
          }
        } catch (_) {}
      }

      final searchTerms = [
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
        'حج',
        'عمرة',
        'توبة',
        'سيرة',
        'أخلاق',
        'رقائق',
        'عقيدة',
        'إيمان',
        'توحيد',
        'سنن',
        'قراءة',
        'مجلس',
        'موعظة',
        'جواب',
        'سؤال',
      ];

      for (final term in searchTerms) {
        if (allVideos.length >= maxResults) break;

        try {
          final results = term.isEmpty
              ? await searchInChannelByUrl(
            channelUrl: channelUrl,
            query: '',
            handle: handle,
            channelId: resolvedChannelId,
            maxResults: 25,
          )
              : await searchInChannel(
            channelId: resolvedChannelId,
            query: term,
            maxResults: 25,
          );

          for (final v in results) {
            if (v.id.isNotEmpty && seenIds.add(v.id)) {
              allVideos.add(v);
            }
          }

          await Future.delayed(const Duration(milliseconds: 140));
        } catch (_) {}
      }

      allVideos.sort((a, b) {
        final dateCompare = b.publishedAt.compareTo(a.publishedAt);
        if (dateCompare != 0) return dateCompare;

        final viewA = int.tryParse(a.viewCount) ?? 0;
        final viewB = int.tryParse(b.viewCount) ?? 0;
        return viewB.compareTo(viewA);
      });

      return allVideos.take(maxResults).toList();
    } catch (e) {
      debugPrint('❌ getAllChannelVideos error: $e');
      return allVideos;
    }
  }

  static YoutubeVideo? _extractVideoFromContent(Map<String, dynamic> renderer) {
    try {
      final videoId = renderer['videoId'] as String? ??
          renderer['navigationEndpoint']?['watchEndpoint']?['videoId'] as String?;
      if (videoId == null || videoId.isEmpty) return null;

      final titleRuns = renderer['title']?['runs'] as List?;
      final title = titleRuns
          ?.map((r) => r['text']?.toString() ?? '')
          .join('')
          .trim() ??
          '';

      final channelRuns = renderer['ownerText']?['runs'] as List? ??
          renderer['longBylineText']?['runs'] as List? ??
          renderer['shortBylineText']?['runs'] as List?;

      final channelTitle = channelRuns
          ?.map((r) => r['text']?.toString() ?? '')
          .join('')
          .trim() ??
          '';

      final channelNav = (channelRuns != null && channelRuns.isNotEmpty)
          ? (channelRuns.first['navigationEndpoint']?['browseEndpoint']?['browseId']
          ?.toString() ??
          '')
          : '';

      final viewCountText = renderer['viewCountText']?['simpleText']?.toString() ??
          renderer['viewCountText']?['runs']
              ?.map((r) => r['text']?.toString() ?? '')
              .join('') ??
          renderer['shortViewCountText']?['simpleText']?.toString() ??
          renderer['shortViewCountText']?['runs']
              ?.map((r) => r['text']?.toString() ?? '')
              .join('') ??
          '';

      final viewCount =
      viewCountText.isNotEmpty ? _extractNumber(viewCountText) : '0';

      final durationText = renderer['lengthText']?['simpleText']?.toString() ??
          renderer['lengthText']?['runs']
              ?.map((r) => r['text']?.toString() ?? '')
              .join('') ??
          '';

      final thumbnails = renderer['thumbnail']?['thumbnails'] as List? ?? [];
      String thumbnail = '';
      if (thumbnails.isNotEmpty) {
        thumbnail = thumbnails.last['url']?.toString() ?? '';
      }
      if (thumbnail.startsWith('//')) {
        thumbnail = 'https:$thumbnail';
      }
      if (thumbnail.isEmpty) {
        thumbnail = 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';
      }

      DateTime publishedAt = DateTime.now().subtract(const Duration(days: 30));
      bool foundDate = false;

      final publishedTimeText = renderer['publishedTimeText'];
      if (publishedTimeText is Map<String, dynamic>) {
        final simpleText = publishedTimeText['simpleText']?.toString();
        if (simpleText != null && simpleText.isNotEmpty) {
          publishedAt = _parseRelativeDate(simpleText);
          foundDate = true;
        }

        if (!foundDate) {
          final runs = publishedTimeText['runs'] as List?;
          if (runs != null && runs.isNotEmpty) {
            final dateText =
            runs.map((r) => r['text']?.toString() ?? '').join('').trim();
            if (dateText.isNotEmpty) {
              publishedAt = _parseRelativeDate(dateText);
              foundDate = true;
            }
          }
        }
      }

      if (!foundDate) {
        final metadata = renderer['metadataText'];
        if (metadata is Map<String, dynamic>) {
          final simpleText = metadata['simpleText']?.toString();
          if (simpleText != null && simpleText.isNotEmpty) {
            publishedAt = _parseRelativeDate(simpleText);
          }
        }
      }

      String description = '';

      if (renderer['detailedMetadataSnippets'] is List) {
        final snippets = renderer['detailedMetadataSnippets'] as List;
        if (snippets.isNotEmpty) {
          final firstSnippet = snippets.first;
          if (firstSnippet is Map<String, dynamic>) {
            final snippetText = firstSnippet['snippetText'];
            if (snippetText is Map<String, dynamic>) {
              final runs = snippetText['runs'] as List? ?? [];
              description =
                  runs.map((r) => r['text']?.toString() ?? '').join('');
            }
          }
        }
      }

      if (description.isEmpty) {
        final descRuns = renderer['descriptionSnippet']?['runs'] as List? ?? [];
        description =
            descRuns.map((r) => r['text']?.toString() ?? '').join('');
      }

      return YoutubeVideo(
        id: videoId,
        title: title,
        description: description,
        thumbnail: thumbnail,
        channelTitle: channelTitle,
        channelId: channelNav,
        publishedAt: publishedAt,
        viewCount: viewCount,
        likeCount: '0',
        commentCount: '0',
        duration: durationText,
        url: 'https://www.youtube.com/watch?v=$videoId',
      );
    } catch (_) {
      return null;
    }
  }

  static List<YoutubeVideo> _parseSearchResultsSimple(
      String html, int maxResults) {
    final videos = <YoutubeVideo>[];

    try {
      final videoIdRegex = RegExp(r'"videoId":"([a-zA-Z0-9_-]{11})"');
      final titleRegex = RegExp(r'"title":\{"runs":\[\{"text":"([^"]+)"');
      final channelRegex =
      RegExp(r'"ownerText":\{"runs":\[\{"text":"([^"]+)"');
      final viewsRegex =
      RegExp(r'"viewCountText":\{"simpleText":"([^"]+)"');
      final dateRegex = RegExp(
        r'"publishedTimeText":\{"simpleText":"([^"]+)"\}|"publishedTimeText":\{"runs":\[\{"text":"([^"]+)"\}',
      );

      final videoIds = videoIdRegex
          .allMatches(html)
          .map((m) => m.group(1)!)
          .toSet()
          .take(maxResults)
          .toList();

      final titles = titleRegex.allMatches(html).map((m) => m.group(1)!).toList();
      final channels =
      channelRegex.allMatches(html).map((m) => m.group(1)!).toList();
      final views = viewsRegex.allMatches(html).map((m) => m.group(1)!).toList();
      final dates = dateRegex
          .allMatches(html)
          .map((m) => m.group(1) ?? m.group(2) ?? '')
          .where((d) => d.isNotEmpty)
          .toList();

      for (var i = 0; i < videoIds.length; i++) {
        final dateStr = i < dates.length ? dates[i] : '';

        videos.add(
          YoutubeVideo(
            id: videoIds[i],
            title: i < titles.length ? _decodeHtmlEntities(titles[i]) : '',
            description: '',
            thumbnail: 'https://i.ytimg.com/vi/${videoIds[i]}/hqdefault.jpg',
            channelTitle:
            i < channels.length ? _decodeHtmlEntities(channels[i]) : '',
            channelId: '',
            publishedAt: dateStr.isNotEmpty
                ? _parseRelativeDate(dateStr)
                : DateTime.now().subtract(Duration(days: i + 1)),
            viewCount: i < views.length ? _extractNumber(views[i]) : '0',
            likeCount: '0',
            duration: '',
            url: 'https://www.youtube.com/watch?v=${videoIds[i]}',
          ),
        );
      }
    } catch (_) {}

    return videos;
  }

  static List<YoutubeVideo> _parseChannelVideosPage(
      String html,
      String channelId,
      int maxResults,
      ) {
    final videos = <YoutubeVideo>[];
    final seenIds = <String>{};

    try {
      final dataRegex = RegExp(r'var ytInitialData = ({.+?});</script>');
      final match = dataRegex.firstMatch(html);

      if (match != null) {
        try {
          final data = json.decode(match.group(1)!);
          final contents = _findVideoContents(data);

          for (final content in contents) {
            final rawVideo = _extractVideoFromContent(content);
            if (rawVideo == null || rawVideo.id.isEmpty) continue;

            final fallback = _extractFallbackVideoDataFromHtml(html, rawVideo.id);

            final video = _hydrateVideoWithFallbackData(
              rawVideo,
              fallbackTitle: fallback?['title']?.toString(),
              fallbackChannelTitle: fallback?['channelTitle']?.toString(),
              fallbackThumbnail: fallback?['thumbnail']?.toString(),
              fallbackViewCount: fallback?['viewCount']?.toString(),
              fallbackPublishedAt: fallback?['publishedAt'] as DateTime?,
            );

            if (video.title.trim().isEmpty) continue;

            if (seenIds.add(video.id)) {
              videos.add(video);
            }

            if (videos.length >= maxResults) break;
          }
        } catch (_) {}
      }
    } catch (_) {}

    return videos.take(maxResults).toList();
  }

  static Future<VideoDetails?> getVideoFullDetails(String videoId) async {
    try {
      final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');

      final response = await _safeGet(
        url,
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'ar,en;q=0.9',
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        return _parseVideoPage(response.body, videoId);
      }
    } catch (e) {
      debugPrint('❌ getVideoFullDetails error: $e');
    }
    return null;
  }

  static VideoDetails? _parseVideoPage(String html, String videoId) {
    try {
      final playerRegex = RegExp(r'var ytInitialPlayerResponse = ({.+?});');
      final playerMatch = playerRegex.firstMatch(html);

      String title = '';
      String description = '';
      String channelTitle = '';
      String channelId = '';
      String viewCount = '0';
      String likeCount = '0';
      String commentCount = '0';
      String duration = '';
      List<String> tags = [];
      DateTime publishedAt = DateTime.now();

      if (playerMatch != null) {
        final playerData = json.decode(playerMatch.group(1)!);
        final videoDetails = playerData['videoDetails'];

        if (videoDetails is Map<String, dynamic>) {
          title = videoDetails['title']?.toString() ?? '';
          channelId = videoDetails['channelId']?.toString() ?? '';
          channelTitle = videoDetails['author']?.toString() ?? '';
          viewCount = videoDetails['viewCount']?.toString() ?? '0';
          description = videoDetails['shortDescription']?.toString() ?? '';

          final lengthSeconds = videoDetails['lengthSeconds'];
          if (lengthSeconds != null) {
            duration =
                _formatSeconds(int.tryParse(lengthSeconds.toString()) ?? 0);
          }

          final keywords = videoDetails['keywords'];
          if (keywords is List) {
            tags = keywords.map((e) => e.toString()).toList();
          }
        }

        try {
          final microformat =
          playerData['microformat']?['playerMicroformatRenderer'];
          if (microformat is Map<String, dynamic>) {
            final publishDateStr = microformat['publishDate']?.toString() ?? '';
            if (publishDateStr.isNotEmpty) {
              publishedAt =
                  DateTime.tryParse(publishDateStr) ?? publishedAt;
            }

            if (description.isEmpty) {
              description = microformat['description']?['simpleText']?.toString() ??
                  description;
            }
          }
        } catch (_) {}
      }

      final publishDateMatch =
      RegExp(r'"publishDate":"([^"]+)"').firstMatch(html);
      if (publishDateMatch != null) {
        publishedAt = DateTime.tryParse(publishDateMatch.group(1) ?? '') ??
            publishedAt;
      }

      final ownerMatch = RegExp(
        r'"ownerChannelName":"([^"]+)"',
      ).firstMatch(html);
      if (ownerMatch != null && channelTitle.isEmpty) {
        channelTitle = _decodeHtmlEntities(ownerMatch.group(1) ?? '');
      }

      final likeMatch = RegExp(
        r'"label":"([\d,\.]+)\s+likes?"',
        caseSensitive: false,
      ).firstMatch(html);
      if (likeMatch != null) {
        likeCount = _extractNumber(likeMatch.group(1) ?? '');
      }

      final commentMatch = RegExp(
        r'"commentCount":"(\d+)"',
        caseSensitive: false,
      ).firstMatch(html);
      if (commentMatch != null) {
        commentCount = commentMatch.group(1) ?? '0';
      }

      if (title.trim().isEmpty) {
        final titleHtmlMatch = RegExp(r'<title>([^<]+)</title>').firstMatch(html);
        if (titleHtmlMatch != null) {
          title = titleHtmlMatch.group(1)?.replaceAll(' - YouTube', '').trim() ?? '';
        }
      }

      return VideoDetails(
        title: title,
        description: description,
        channelTitle: channelTitle,
        channelId: channelId,
        publishedAt: publishedAt,
        viewCount: viewCount,
        likeCount: likeCount,
        commentCount: commentCount,
        duration: duration,
        tags: tags,
        categoryId: '',
        definition: 'hd',
        thumbnailHigh: 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
      );
    } catch (e) {
      debugPrint('❌ _parseVideoPage error: $e');
      return null;
    }
  }

  static Future<List<YoutubeComment>> getVideoComments(String videoId,
      {int maxResults = 20}) async {
    return [];
  }

  static Future<ChannelInfo?> getChannelInfo(String channelId) async {
    try {
      final urls = [
        Uri.parse('https://www.youtube.com/channel/$channelId'),
        Uri.parse('https://www.youtube.com/channel/$channelId/videos'),
        Uri.parse('https://www.youtube.com/channel/$channelId/about'),
      ];

      for (final url in urls) {
        try {
          final response = await _safeGet(
            url,
            headers: {
              'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept-Language': 'ar,en;q=0.9',
            },
            timeout: const Duration(seconds: 15),
          );

          if (response.statusCode == 200) {
            final parsed = _parseChannelPage(response.body);
            if (parsed != null && parsed.title.trim().isNotEmpty) {
              return parsed;
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('❌ getChannelInfo error: $e');
    }
    return null;
  }

  static ChannelInfo? _parseChannelPage(String html) {
    try {
      final dataRegex = RegExp(r'var ytInitialData = ({.+?});</script>');
      final match = dataRegex.firstMatch(html);

      String title = '';
      String description = '';
      String thumbnail = '';
      String subscriberCount = '0';
      String videoCount = '0';

      if (match != null) {
        try {
          final data = json.decode(match.group(1)!);

          void search(dynamic obj, {int depth = 0}) {
            if (depth > 12 || obj == null) return;

            if (obj is Map<String, dynamic>) {
              if (obj.containsKey('channelMetadataRenderer')) {
                final meta = obj['channelMetadataRenderer'];
                if (meta is Map<String, dynamic>) {
                  title = meta['title']?.toString() ?? title;
                  description =
                      meta['description']?.toString() ?? description;

                  final avatar = meta['avatar'];
                  if (avatar is Map<String, dynamic>) {
                    final thumbs = avatar['thumbnails'] as List?;
                    if (thumbs != null && thumbs.isNotEmpty) {
                      thumbnail = thumbs.last['url']?.toString() ?? thumbnail;
                    }
                  }
                }
              }

              if (obj.containsKey('subscriberCountText')) {
                final sub = obj['subscriberCountText'];
                if (sub is Map<String, dynamic>) {
                  final simpleText = sub['simpleText']?.toString() ?? '';
                  if (simpleText.isNotEmpty) {
                    subscriberCount = _extractNumber(simpleText);
                  } else {
                    final runs = sub['runs'] as List?;
                    if (runs != null && runs.isNotEmpty) {
                      final text =
                      runs.map((r) => r['text']?.toString() ?? '').join('');
                      if (text.isNotEmpty) {
                        subscriberCount = _extractNumber(text);
                      }
                    }
                  }
                }
              }

              if (obj.containsKey('videosCountText')) {
                final vids = obj['videosCountText'];
                if (vids is Map<String, dynamic>) {
                  final simpleText = vids['simpleText']?.toString() ?? '';
                  if (simpleText.isNotEmpty) {
                    videoCount = _extractNumber(simpleText);
                  } else {
                    final runs = vids['runs'] as List?;
                    if (runs != null && runs.isNotEmpty) {
                      final text =
                      runs.map((r) => r['text']?.toString() ?? '').join('');
                      if (text.isNotEmpty) {
                        videoCount = _extractNumber(text);
                      }
                    }
                  }
                }
              }

              for (final value in obj.values) {
                search(value, depth: depth + 1);
              }
            } else if (obj is List) {
              for (final item in obj) {
                search(item, depth: depth + 1);
              }
            }
          }

          search(data);
        } catch (_) {}
      }

      if (title.isEmpty) {
        final metaTitleMatch = RegExp(
          r'<meta property="og:title" content="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        if (metaTitleMatch != null) {
          title = _decodeHtmlEntities(metaTitleMatch.group(1) ?? '').trim();
        }
      }

      if (description.isEmpty) {
        final metaDescMatch = RegExp(
          r'<meta property="og:description" content="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        if (metaDescMatch != null) {
          description =
              _decodeHtmlEntities(metaDescMatch.group(1) ?? '').trim();
        }
      }

      if (thumbnail.isEmpty) {
        final metaImageMatch = RegExp(
          r'<meta property="og:image" content="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        if (metaImageMatch != null) {
          thumbnail = metaImageMatch.group(1)?.trim() ?? '';
        }
      }

      if (subscriberCount == '0') {
        final subMatch = RegExp(
          r'"subscriberCountText":\{"simpleText":"([^"]+)"',
        ).firstMatch(html);
        if (subMatch != null) {
          subscriberCount = _extractNumber(subMatch.group(1) ?? '');
        }
      }

      if (title.isNotEmpty) {
        return ChannelInfo(
          title: title,
          description: description,
          thumbnail: thumbnail,
          subscriberCount: subscriberCount,
          videoCount: videoCount,
        );
      }
    } catch (e) {
      debugPrint('❌ _parseChannelPage error: $e');
    }

    return null;
  }

  static Future<String?> resolveChannelId({
    String? providedChannelId,
    required String channelUrl,
    String? handle,
  }) async {
    if (providedChannelId != null &&
        providedChannelId.isNotEmpty &&
        providedChannelId.startsWith('UC') &&
        providedChannelId.length >= 24) {
      return providedChannelId;
    }

    final cleanUrl = cleanYoutubeUrl(channelUrl);
    final normalizedHandle = handle?.trim().isNotEmpty == true
        ? (handle!.startsWith('@') ? handle.trim() : '@${handle.trim()}')
        : null;

    final stableKey = '$cleanUrl|${normalizedHandle ?? ''}';

    if (_channelIdCache.containsKey(stableKey)) {
      return _channelIdCache[stableKey];
    }

    final result = await _getChannelId(cleanUrl, normalizedHandle);

    if (result != null && result.isNotEmpty) {
      _channelIdCache[stableKey] = result;
    }

    return result;
  }

  /// تنظيف أي YouTube URL
  static String cleanYoutubeUrl(String url) {
    var clean = url.trim();

    clean = clean.replaceAll(RegExp(r'\s+'), '');

    while (clean.contains('www.www.')) {
      clean = clean.replaceAll('www.www.', 'www.');
    }

    clean = clean.replaceAll('https://https://', 'https://');
    clean = clean.replaceAll('http://http://', 'http://');
    clean = clean.replaceAll('https://http://', 'https://');
    clean = clean.replaceAll('http://https://', 'https://');

    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      if (clean.startsWith('www.')) {
        clean = 'https://$clean';
      } else if (clean.startsWith('youtube.com')) {
        clean = 'https://www.$clean';
      } else if (clean.startsWith('@')) {
        clean = 'https://www.youtube.com/$clean';
      }
    }

    clean = clean.replaceFirst('http://', 'https://');

    if (clean.contains('youtube.com/youtube.com')) {
      clean = clean.replaceAll('youtube.com/youtube.com', 'youtube.com');
    }

    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }

    return clean;
  }

  static Future<String?> _getChannelId(String channelUrl, String? handle) async {
    final cleanUrl = cleanYoutubeUrl(channelUrl);
    final normalizedHandle = handle?.trim().isNotEmpty == true
        ? (handle!.startsWith('@') ? handle.trim() : '@${handle.trim()}')
        : null;

    final cacheKey = '$cleanUrl|${normalizedHandle ?? ''}';

    if (_channelIdCache.containsKey(cacheKey)) {
      return _channelIdCache[cacheKey];
    }

    String? channelId;

    final uri = Uri.tryParse(cleanUrl);
    final path = uri?.path ?? '';
    final segments = uri?.pathSegments ?? const <String>[];

    if (segments.contains('channel')) {
      final idx = segments.indexOf('channel');
      if (idx + 1 < segments.length) {
        final maybeId = segments[idx + 1];
        if (maybeId.startsWith('UC') && maybeId.length >= 24) {
          channelId = maybeId;
        }
      }
    }

    if (channelId == null && path.startsWith('/@')) {
      final correctUrl = 'https://www.youtube.com$path';
      channelId = await _getChannelIdFromPage(correctUrl);
    }

    if (channelId == null && normalizedHandle != null) {
      final handleUrl = 'https://www.youtube.com/$normalizedHandle';
      channelId = await _getChannelIdFromPage(handleUrl);
    }

    if (channelId == null && cleanUrl.isNotEmpty) {
      channelId = await _getChannelIdFromPage(cleanUrl);
    }

    if (channelId != null && channelId.isNotEmpty) {
      _channelIdCache[cacheKey] = channelId;

      if (normalizedHandle != null) {
        _channelIdCache['https://www.youtube.com/$normalizedHandle|$normalizedHandle'] =
            channelId;
      }
    }

    return channelId;
  }

  static Future<String?> _getChannelIdFromPage(String url) async {
    try {
      var cleanUrl = cleanYoutubeUrl(url);

      final response = await _safeGet(
        Uri.parse(cleanUrl),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept-Language': 'ar,en;q=0.9',
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode != 200) return null;

      final body = response.body;

      final canonicalMatch = RegExp(
        r'<link rel="canonical" href="https://www\.youtube\.com/channel/(UC[a-zA-Z0-9_-]{22})"',
        caseSensitive: false,
      ).firstMatch(body);

      if (canonicalMatch != null) {
        return canonicalMatch.group(1);
      }

      final externalIdMatch = RegExp(
        r'"externalId":"(UC[a-zA-Z0-9_-]{22})"',
      ).firstMatch(body);

      if (externalIdMatch != null) {
        return externalIdMatch.group(1);
      }

      final ownerMatch = RegExp(
        r'"channelUrl":"https?:\\/\\/www\.youtube\.com\\/channel\\/(UC[a-zA-Z0-9_-]{22})"',
      ).firstMatch(body);

      if (ownerMatch != null) {
        return ownerMatch.group(1);
      }

      final patterns = [
        RegExp(r'"channelId":"(UC[a-zA-Z0-9_-]{22})"'),
        RegExp(r'/channel/(UC[a-zA-Z0-9_-]{22})'),
        RegExp(r'channel_id=(UC[a-zA-Z0-9_-]{22})'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(body);
        if (match != null) {
          return match.group(1);
        }
      }
    } catch (e) {
      debugPrint('❌ _getChannelIdFromPage error: $e');
    }

    return null;
  }

  static List<YoutubeVideo> _parseRssFeed(
      String xmlBody, String channelId, int maxResults) {
    final videos = <YoutubeVideo>[];

    try {
      final document = xml.XmlDocument.parse(xmlBody);
      final entries = document.findAllElements('entry').take(maxResults);

      for (final entry in entries) {
        try {
          final videoId = entry.findElements('yt:videoId').first.innerText;
          final title = entry.findElements('title').first.innerText;
          final published = entry.findElements('published').first.innerText;
          final channelName = entry
              .findElements('author')
              .first
              .findElements('name')
              .first
              .innerText;

          final mediaGroup = entry.findElements('media:group').first;
          final thumbnail = mediaGroup
              .findElements('media:thumbnail')
              .firstOrNull
              ?.getAttribute('url') ??
              'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';

          final description = mediaGroup
              .findElements('media:description')
              .firstOrNull
              ?.innerText ??
              '';

          String viewCount = '0';
          try {
            final community =
                mediaGroup.findElements('media:community').firstOrNull;
            if (community != null) {
              viewCount = community
                  .findElements('media:statistics')
                  .first
                  .getAttribute('views') ??
                  '0';
            }
          } catch (_) {}

          VideoType videoType = VideoType.regular;
          final lowerTitle = title.toLowerCase();
          final lowerDesc = description.toLowerCase();

          if (lowerTitle.contains('#shorts') ||
              lowerTitle.contains('shorts') ||
              lowerTitle.contains('#short') ||
              lowerDesc.contains('#shorts') ||
              lowerDesc.contains('#short')) {
            videoType = VideoType.shorts;
          }

          try {
            final linkEl = entry.findElements('link').firstOrNull;
            final href = linkEl?.getAttribute('href') ?? '';
            if (href.contains('/shorts/')) {
              videoType = VideoType.shorts;
            }
          } catch (_) {}

          videos.add(
            YoutubeVideo(
              id: videoId,
              title: title,
              description: description,
              thumbnail: thumbnail,
              channelTitle: channelName,
              channelId: channelId,
              publishedAt: DateTime.tryParse(published) ?? DateTime.now(),
              viewCount: viewCount,
              likeCount: '0',
              commentCount: '0',
              duration: '',
              url: 'https://www.youtube.com/watch?v=$videoId',
              type: videoType,
            ),
          );
        } catch (_) {}
      }
    } catch (_) {}

    return videos;
  }

  static String _extractNumber(String text) {
    final arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String converted = text;
    arabicToEnglish.forEach((ar, en) {
      converted = converted.replaceAll(ar, en);
    });

    final numRegex = RegExp(r'[\d,\.]+');
    final match = numRegex.firstMatch(converted);
    if (match == null) return '0';

    var numStr = match.group(0)!.replaceAll(',', '');
    var num = double.tryParse(numStr) ?? 0;

    final lower = text.toLowerCase();
    if (lower.contains('مليار') || lower.contains('b')) {
      num *= 1000000000;
    } else if (lower.contains('مليون') || lower.contains('m')) {
      num *= 1000000;
    } else if (lower.contains('ألف') ||
        lower.contains('الف') ||
        lower.contains('k')) {
      num *= 1000;
    }

    return num.toInt().toString();
  }

  static DateTime _parseRelativeDate(String text) {
    final now = DateTime.now();

    if (text.trim().isEmpty) {
      return now.subtract(const Duration(days: 30));
    }

    String cleaned = text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll('تم النشر منذ', '')
        .replaceAll('تم البث منذ', '')
        .replaceAll('تم عرضه منذ', '')
        .replaceAll('منذ', '')
        .replaceAll('قبل', '')
        .replaceAll('ago', '')
        .replaceAll('streamed', '')
        .replaceAll('published', '')
        .replaceAll('premiered', '')
        .trim();

    final directParsed = DateTime.tryParse(text.trim());
    if (directParsed != null) {
      return directParsed;
    }

    final num = _extractNumberSafe(cleaned);
    final value = num == 0 ? 1 : num;

    if (_containsAny(cleaned, ['ثانية', 'ثوان', 'ثواني'])) {
      return now.subtract(Duration(seconds: value));
    }
    if (_containsAny(cleaned, ['دقيقة', 'دقائق'])) {
      return now.subtract(Duration(minutes: value));
    }
    if (_containsAny(cleaned, ['ساعة', 'ساعات'])) {
      return now.subtract(Duration(hours: value));
    }
    if (_containsAny(cleaned, ['يوم', 'أيام', 'ايام'])) {
      return now.subtract(Duration(days: value));
    }
    if (_containsAny(cleaned, ['أسبوع', 'اسبوع', 'أسابيع', 'اسابيع'])) {
      return now.subtract(Duration(days: value * 7));
    }
    if (_containsAny(cleaned, ['شهر', 'أشهر', 'اشهر', 'شهور'])) {
      return now.subtract(Duration(days: value * 30));
    }
    if (_containsAny(cleaned, ['سنة', 'سنوات', 'عام', 'أعوام', 'اعوام'])) {
      return now.subtract(Duration(days: value * 365));
    }

    if (_containsAny(cleaned, ['second', 'seconds', 'sec'])) {
      return now.subtract(Duration(seconds: value));
    }
    if (_containsAny(cleaned, ['minute', 'minutes', 'min'])) {
      return now.subtract(Duration(minutes: value));
    }
    if (_containsAny(cleaned, ['hour', 'hours', 'hr'])) {
      return now.subtract(Duration(hours: value));
    }
    if (_containsAny(cleaned, ['day', 'days'])) {
      return now.subtract(Duration(days: value));
    }
    if (_containsAny(cleaned, ['week', 'weeks'])) {
      return now.subtract(Duration(days: value * 7));
    }
    if (_containsAny(cleaned, ['month', 'months'])) {
      return now.subtract(Duration(days: value * 30));
    }
    if (_containsAny(cleaned, ['year', 'years'])) {
      return now.subtract(Duration(days: value * 365));
    }

    final datePattern = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})');
    final dateMatch = datePattern.firstMatch(cleaned);
    if (dateMatch != null) {
      try {
        return DateTime(
          int.parse(dateMatch.group(1)!),
          int.parse(dateMatch.group(2)!),
          int.parse(dateMatch.group(3)!),
        );
      } catch (_) {}
    }

    return now.subtract(const Duration(days: 30));
  }

  static bool _containsAny(String text, List<String> patterns) {
    for (final p in patterns) {
      if (text.contains(p)) return true;
    }
    return false;
  }

  static int _extractNumberSafe(String text) {
    final arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String converted = text;
    arabicToEnglish.forEach((ar, en) {
      converted = converted.replaceAll(ar, en);
    });

    final match = RegExp(r'[\d\.]+').firstMatch(converted);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '0')?.toInt() ?? 0;
  }

  static String _formatSeconds(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  static String formatViews(String viewCount) {
    final n = int.tryParse(viewCount) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String formatCount(String count) => formatViews(count);
}

class YoutubeVideo {
  final String id, title, description, thumbnail;
  final String channelTitle, channelId;
  final DateTime publishedAt;
  final String viewCount, likeCount, commentCount, duration, url;
  final VideoType type;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.channelTitle,
    this.channelId = '',
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    this.commentCount = '0',
    required this.duration,
    required this.url,
    VideoType? type,
  }) : type = type ?? _detectVideoType(duration, title);

  static VideoType _detectVideoType(String duration, String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('بث مباشر') ||
        lowerTitle.contains('live') ||
        lowerTitle.contains('مباشر')) {
      return VideoType.live;
    }

    if (duration.isNotEmpty) {
      final parts = duration.split(':');
      if (parts.length == 2) {
        final mins = int.tryParse(parts[0]) ?? 0;
        final secs = int.tryParse(parts[1]) ?? 0;
        if (mins == 0 && secs <= 60) {
          return VideoType.shorts;
        }
      }
    }

    if (lowerTitle.contains('#shorts') ||
        lowerTitle.contains('shorts') ||
        lowerTitle.contains('#short')) {
      return VideoType.shorts;
    }

    return VideoType.regular;
  }
}

enum VideoType {
  regular,
  shorts,
  live,
}

class VideoDetails {
  final String title, description, channelTitle, channelId;
  final DateTime publishedAt;
  final String viewCount, likeCount, commentCount, duration;
  final List<String> tags;
  final String categoryId, definition, thumbnailHigh;

  VideoDetails({
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.duration,
    required this.tags,
    required this.categoryId,
    required this.definition,
    required this.thumbnailHigh,
  });
}

class YoutubeComment {
  final String authorName, authorImage, text;
  final int likeCount, totalReplyCount;
  final DateTime publishedAt;

  YoutubeComment({
    required this.authorName,
    required this.authorImage,
    required this.text,
    required this.likeCount,
    required this.publishedAt,
    this.totalReplyCount = 0,
  });
}

class ChannelInfo {
  final String title, description, thumbnail;
  final String subscriberCount, videoCount;

  ChannelInfo({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.subscriberCount,
    required this.videoCount,
  });
}

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}