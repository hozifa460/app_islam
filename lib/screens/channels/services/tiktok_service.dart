import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TikTokService {
  // ═══════════════════════════════════════════════════════
  //  جلب بيانات حساب TikTok
  // ═══════════════════════════════════════════════════════
  static Future<TikTokProfile?> getUserProfile(String username) async {
    try {
      final cleanUsername =
      username.startsWith('@') ? username.substring(1) : username;

      debugPrint('📱 Fetching TikTok: @$cleanUsername');

      // نحاول أولاً من صفحة الويب الرسمية
      final profile = await _fetchFromOfficialPage(cleanUsername);
      if (profile != null && profile.videos.isNotEmpty) {
        debugPrint('✅ Official page success');
        return profile;
      }

      // احتياطي: TikWM
      final tikwmProfile = await _fetchFromTikWM(cleanUsername);
      if (tikwmProfile != null && tikwmProfile.videos.isNotEmpty) {
        debugPrint('✅ TikWM success');
        return tikwmProfile;
      }
    } catch (e) {
      debugPrint('❌ TikTokService error: $e');
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════
  //  المصدر الأول: صفحة TikTok الرسمية
  // ═══════════════════════════════════════════════════════
  static Future<TikTokProfile?> _fetchFromOfficialPage(String username) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.tiktok.com/@$username'),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
          'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('❌ Official page status: ${response.statusCode}');
        return null;
      }

      return _parseOfficialHtml(response.body, username);
    } catch (e) {
      debugPrint('❌ Official page error: $e');
      return null;
    }
  }

  static TikTokProfile? _parseOfficialHtml(String html, String username) {
    try {
      // 1) محاولة قراءة UNIVERSAL_DATA
      final universalRegex = RegExp(
        r'<script id="__UNIVERSAL_DATA_FOR_REHYDRATION__"[^>]*>([\s\S]*?)</script>',
        caseSensitive: false,
      );

      final universalMatch = universalRegex.firstMatch(html);
      if (universalMatch != null) {
        final jsonStr = universalMatch.group(1);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final data = json.decode(jsonStr);
          final parsed = _parseUniversalData(data, username);
          if (parsed != null && parsed.videos.isNotEmpty) {
            return parsed;
          }
        }
      }

      // 2) محاولة قراءة SIGI_STATE
      final sigiRegex = RegExp(
        r'<script id="SIGI_STATE"[^>]*>([\s\S]*?)</script>',
        caseSensitive: false,
      );

      final sigiMatch = sigiRegex.firstMatch(html);
      if (sigiMatch != null) {
        final jsonStr = sigiMatch.group(1);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final data = json.decode(jsonStr);
          final parsed = _parseSigiState(data, username);
          if (parsed != null && parsed.videos.isNotEmpty) {
            return parsed;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Parse official html error: $e');
    }

    return null;
  }

  static TikTokProfile? _parseUniversalData(
      Map<String, dynamic> data,
      String username,
      ) {
    try {
      final scope = data['__DEFAULT_SCOPE__'];
      final userDetail = scope?['webapp.user-detail'];
      if (userDetail == null) return null;

      final userInfo = userDetail['userInfo'];
      final user = userInfo?['user'] ?? {};
      final stats = userInfo?['stats'] ?? {};

      final videos = <TikTokVideo>[];
      final itemList = userDetail['itemList'] as List? ?? [];

      for (final item in itemList) {
        try {
          final cover = item['video']?['cover']?.toString() ??
              item['video']?['dynamicCover']?.toString() ??
              '';

          final id = item['id']?.toString() ?? '';
          if (id.isEmpty || cover.isEmpty) continue;

          final createTime =
              int.tryParse(item['createTime']?.toString() ?? '0') ?? 0;

          videos.add(
            TikTokVideo(
              id: id,
              description: item['desc']?.toString() ?? '',
              cover: cover,
              downloadUrl: item['video']?['downloadAddr']?.toString() ?? '',
              duration: item['video']?['duration']?.toString() ?? '0',
              playCount: item['stats']?['playCount']?.toString() ?? '0',
              likeCount: item['stats']?['diggCount']?.toString() ?? '0',
              commentCount: item['stats']?['commentCount']?.toString() ?? '0',
              shareCount: item['stats']?['shareCount']?.toString() ?? '0',
              publishedAt: DateTime.fromMillisecondsSinceEpoch(
                createTime * 1000,
              ),
              url: 'https://www.tiktok.com/@$username/video/$id',
            ),
          );
        } catch (e) {
          debugPrint('⚠️ Universal item parse error: $e');
        }
      }

      return TikTokProfile(
        username: username,
        nickname: user['nickname']?.toString() ?? username,
        avatar: user['avatarLarger']?.toString() ??
            user['avatarMedium']?.toString() ??
            '',
        signature: user['signature']?.toString() ?? '',
        verified: user['verified'] == true,
        followers: stats['followerCount']?.toString() ?? '0',
        following: stats['followingCount']?.toString() ?? '0',
        likes: stats['heartCount']?.toString() ?? '0',
        videoCount: stats['videoCount']?.toString() ?? videos.length.toString(),
        videos: videos,
      );
    } catch (e) {
      debugPrint('❌ Parse universal data error: $e');
      return null;
    }
  }

  static TikTokProfile? _parseSigiState(
      Map<String, dynamic> data,
      String username,
      ) {
    try {
      final userModule = data['UserModule'] ?? {};
      final users = userModule['users'] ?? {};
      final statsMap = userModule['stats'] ?? {};

      Map<String, dynamic> userData = {};
      Map<String, dynamic> userStats = {};

      if (users is Map && users.isNotEmpty) {
        if (users[username] != null) {
          userData = Map<String, dynamic>.from(users[username]);
        } else {
          userData = Map<String, dynamic>.from(users.values.first);
        }
      }

      if (statsMap is Map && statsMap.isNotEmpty) {
        if (statsMap[username] != null) {
          userStats = Map<String, dynamic>.from(statsMap[username]);
        } else {
          userStats = Map<String, dynamic>.from(statsMap.values.first);
        }
      }

      final videos = <TikTokVideo>[];
      final itemModule = data['ItemModule'] as Map<String, dynamic>? ?? {};

      for (final entry in itemModule.entries) {
        try {
          final item = entry.value;
          final id = item['id']?.toString() ?? entry.key;
          final cover = item['video']?['cover']?.toString() ?? '';
          if (id.isEmpty || cover.isEmpty) continue;

          final createTime =
              int.tryParse(item['createTime']?.toString() ?? '0') ?? 0;

          videos.add(
            TikTokVideo(
              id: id,
              description: item['desc']?.toString() ?? '',
              cover: cover,
              downloadUrl: item['video']?['downloadAddr']?.toString() ?? '',
              duration: item['video']?['duration']?.toString() ?? '0',
              playCount: item['stats']?['playCount']?.toString() ?? '0',
              likeCount: item['stats']?['diggCount']?.toString() ?? '0',
              commentCount: item['stats']?['commentCount']?.toString() ?? '0',
              shareCount: item['stats']?['shareCount']?.toString() ?? '0',
              publishedAt: DateTime.fromMillisecondsSinceEpoch(
                createTime * 1000,
              ),
              url: 'https://www.tiktok.com/@$username/video/$id',
            ),
          );
        } catch (e) {
          debugPrint('⚠️ SIGI item parse error: $e');
        }
      }

      return TikTokProfile(
        username: username,
        nickname: userData['nickname']?.toString() ?? username,
        avatar: userData['avatarLarger']?.toString() ??
            userData['avatarMedium']?.toString() ??
            '',
        signature: userData['signature']?.toString() ?? '',
        verified: userData['verified'] == true,
        followers: userStats['followerCount']?.toString() ?? '0',
        following: userStats['followingCount']?.toString() ?? '0',
        likes: userStats['heartCount']?.toString() ?? '0',
        videoCount:
        userStats['videoCount']?.toString() ?? videos.length.toString(),
        videos: videos,
      );
    } catch (e) {
      debugPrint('❌ Parse SIGI error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  //  المصدر الاحتياطي: TikWM
  // ═══════════════════════════════════════════════════════
  static Future<TikTokProfile?> _fetchFromTikWM(String username) async {
    try {
      debugPrint('🔄 Trying TikWM fallback...');

      final response = await http.post(
        Uri.parse('https://www.tikwm.com/api/user/posts'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {
          'unique_id': username,
          'count': '30',
          'cursor': '0',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['data'] != null) {
          return _parseTikWMResponse(data['data'], username);
        }
      }

      debugPrint('❌ TikWM failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ TikWM error: $e');
    }
    return null;
  }

  static TikTokProfile? _parseTikWMResponse(
      Map<String, dynamic> data,
      String username,
      ) {
    try {
      final videos = <TikTokVideo>[];
      final videoList = data['videos'] as List? ?? [];

      for (final item in videoList) {
        try {
          final id = item['video_id']?.toString() ?? '';
          final cover = item['cover']?.toString() ??
              item['origin_cover']?.toString() ??
              '';

          if (id.isEmpty || cover.isEmpty) continue;

          videos.add(
            TikTokVideo(
              id: id,
              description: item['title']?.toString() ?? '',
              cover: cover,
              downloadUrl: item['play']?.toString() ?? '',
              duration: item['duration']?.toString() ?? '0',
              playCount: item['play_count']?.toString() ?? '0',
              likeCount: item['digg_count']?.toString() ?? '0',
              commentCount: item['comment_count']?.toString() ?? '0',
              shareCount: item['share_count']?.toString() ?? '0',
              publishedAt: DateTime.fromMillisecondsSinceEpoch(
                ((item['create_time'] ?? 0) as int) * 1000,
              ),
              url: 'https://www.tiktok.com/@$username/video/$id',
            ),
          );
        } catch (e) {
          debugPrint('⚠️ TikWM item parse error: $e');
        }
      }

      debugPrint('✅ TikWM: Found ${videos.length} videos');

      return TikTokProfile(
        username: username,
        nickname: data['nickname']?.toString() ?? username,
        avatar: data['avatar']?.toString() ?? '',
        signature: data['signature']?.toString() ?? '',
        verified: data['verified'] == true,
        followers: data['follower_count']?.toString() ?? '0',
        following: data['following_count']?.toString() ?? '0',
        likes: data['total_favorited']?.toString() ?? '0',
        videoCount:
        data['video_count']?.toString() ?? videos.length.toString(),
        videos: videos,
      );
    } catch (e) {
      debugPrint('❌ Parse TikWM error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  //  أدوات مساعدة
  // ═══════════════════════════════════════════════════════
  static String formatCount(String count) {
    final n = int.tryParse(count) ?? 0;
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)}B';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String formatDuration(String seconds) {
    final s = int.tryParse(seconds) ?? 0;
    final minutes = s ~/ 60;
    final secs = s % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }
}

// ════════════════════════════════════════════════════════
//  النماذج
// ════════════════════════════════════════════════════════

class TikTokProfile {
  final String username;
  final String nickname;
  final String avatar;
  final String signature;
  final bool verified;
  final String followers;
  final String following;
  final String likes;
  final String videoCount;
  final List<TikTokVideo> videos;

  TikTokProfile({
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.signature,
    required this.verified,
    required this.followers,
    required this.following,
    required this.likes,
    required this.videoCount,
    required this.videos,
  });
}

class TikTokVideo {
  final String id;
  final String description;
  final String cover;
  final String downloadUrl;
  final String duration;
  final String playCount;
  final String likeCount;
  final String commentCount;
  final String shareCount;
  final DateTime publishedAt;
  final String url;

  TikTokVideo({
    required this.id,
    required this.description,
    required this.cover,
    required this.downloadUrl,
    required this.duration,
    required this.playCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.publishedAt,
    required this.url,
  });
}