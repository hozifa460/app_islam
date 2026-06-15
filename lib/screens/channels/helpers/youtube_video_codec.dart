import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class YoutubeVideoCodec {
  static List<dynamic> toCompactList(YoutubeVideo v) => [
    v.id,
    v.title,
    v.description,
    v.thumbnail,
    v.channelTitle,
    v.channelId,
    v.publishedAt.toIso8601String(),
    v.viewCount,
    v.likeCount,
    v.commentCount,
    v.duration,
    v.url,
    v.type.index,
  ];

  static YoutubeVideo? fromCompactList(List<dynamic> j) {
    try {
      final rawType = j.length > 12 ? j[12] : 0;
      final typeIndex = ((rawType is num ? rawType.toInt() : 0))
          .clamp(0, VideoType.values.length - 1);

      return YoutubeVideo(
        id: j.length > 0 ? '${j[0] ?? ''}' : '',
        title: j.length > 1 ? '${j[1] ?? ''}' : '',
        description: j.length > 2 ? '${j[2] ?? ''}' : '',
        thumbnail: j.length > 3 ? '${j[3] ?? ''}' : '',
        channelTitle: j.length > 4 ? '${j[4] ?? ''}' : '',
        channelId: j.length > 5 ? '${j[5] ?? ''}' : '',
        publishedAt: DateTime.tryParse(
          j.length > 6 ? '${j[6] ?? ''}' : '',
        ) ??
            DateTime.now(),
        viewCount: j.length > 7 ? '${j[7] ?? '0'}' : '0',
        likeCount: j.length > 8 ? '${j[8] ?? '0'}' : '0',
        commentCount: j.length > 9 ? '${j[9] ?? '0'}' : '0',
        duration: j.length > 10 ? '${j[10] ?? ''}' : '',
        url: j.length > 11 ? '${j[11] ?? ''}' : '',
        type: VideoType.values[typeIndex],
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> toMap(YoutubeVideo v) => {
    'id': v.id,
    'title': v.title,
    'description': v.description,
    'thumbnail': v.thumbnail,
    'channelTitle': v.channelTitle,
    'channelId': v.channelId,
    'publishedAt': v.publishedAt.toIso8601String(),
    'viewCount': v.viewCount,
    'likeCount': v.likeCount,
    'commentCount': v.commentCount,
    'duration': v.duration,
    'url': v.url,
    'type': v.type.index,
  };

  static YoutubeVideo? fromMap(Map<String, dynamic> j) {
    try {
      final rawType = j['type'];
      final typeIndex = ((rawType is num ? rawType.toInt() : 0))
          .clamp(0, VideoType.values.length - 1);

      return YoutubeVideo(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        thumbnail: j['thumbnail'] ?? '',
        channelTitle: j['channelTitle'] ?? '',
        channelId: j['channelId'] ?? '',
        publishedAt: DateTime.tryParse(j['publishedAt'] ?? '') ?? DateTime.now(),
        viewCount: j['viewCount'] ?? '0',
        likeCount: j['likeCount'] ?? '0',
        commentCount: j['commentCount'] ?? '0',
        duration: j['duration'] ?? '',
        url: j['url'] ?? '',
        type: VideoType.values[typeIndex],
      );
    } catch (_) {
      return null;
    }
  }
}