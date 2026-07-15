import 'dart:ui';

import 'radio_station.dart';

// ══════════════════════════════════════════════════════
// أنواع المحتوى
// ══════════════════════════════════════════════════════

enum MediaType { audio, video, both }

enum VideoSource { direct, youtube, tiktok }

// ══════════════════════════════════════════════════════
// نموذج القسم
// ══════════════════════════════════════════════════════

class RecitationCategory {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<Color> gradientColors;
  final List<RecitationItem> items;
  final String? imageUrl;

  const RecitationCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradientColors,
    required this.items,
    this.imageUrl,
  });

  factory RecitationCategory.fromJson(Map<String, dynamic> json) {
    return RecitationCategory(
      id: _str(json['id']),
      title: _str(json['title']),
      emoji: _str(json['emoji']),
      description: _str(json['description']),
      gradientColors: _parseColors(json['gradientColors']),
      imageUrl: _strOrNull(json['imageUrl']),
      items: _parseList(
        json['items'],
            (e) => RecitationItem.fromJson(e),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'emoji': emoji,
    'description': description,
    'gradientColors': gradientColors
        .map((c) => '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}')
        .toList(),
    'imageUrl': imageUrl,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

// ══════════════════════════════════════════════════════
// نموذج القسم الفرعي
// ══════════════════════════════════════════════════════

class RecitationSubSection {
  final String title;
  final String emoji;
  final List<RecitationSubItem> items;

  const RecitationSubSection({
    required this.title,
    required this.emoji,
    required this.items,
  });

  int get itemsCount => items.length;

  factory RecitationSubSection.fromJson(Map<String, dynamic> json) {
    return RecitationSubSection(
      title: _str(json['title']),
      emoji: _str(json['emoji']),
      items: _parseList(
        json['items'],
            (e) => RecitationSubItem.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'emoji': emoji,
    'items': items.map((i) => i.toJson()).toList(),
  };

}

// ══════════════════════════════════════════════════════
// نموذج العنصر الرئيسي
// ══════════════════════════════════════════════════════

class RecitationItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String? imageUrl;
  final String? imageAsset;
  final IslamicRadioStation? station;
  final String? audioUrl;
  final String? playlistUrl;
  final List<RecitationSubItem>? subItems;
  final List<RecitationSubSection>? subSections;

  // حقول الفيديو
  final String? videoUrl;
  final VideoSource? videoSource;
  final MediaType mediaType;

  RecitationItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.imageUrl,
    this.imageAsset,
    this.station,
    this.audioUrl,
    this.playlistUrl,
    this.subItems,
    this.subSections,
    this.videoUrl,
    this.videoSource,
    this.mediaType = MediaType.audio,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  bool get isVideoOnly => mediaType == MediaType.video;
  bool get isAudioOnly => mediaType == MediaType.audio;
  bool get hasBothMediaTypes => mediaType == MediaType.both;
  bool get isYouTube => videoSource == VideoSource.youtube;
  bool get isDirectVideo => videoSource == VideoSource.direct;
  bool get isTikTok => videoSource == VideoSource.tiktok;

  bool get hasSubItems {
    return (subItems != null && subItems!.isNotEmpty) ||
        (subSections != null && subSections!.isNotEmpty);
  }

  int get subItemsCount {
    int count = subItems?.length ?? 0;
    if (subSections != null) {
      for (final section in subSections!) {
        count += section.items.length;
      }
    }
    return count;
  }

  List<RecitationSubItem>? _cachedAllSubItems;
  List<RecitationSubItem> get allSubItems {
    if (_cachedAllSubItems != null) return _cachedAllSubItems!;
    final all = <RecitationSubItem>[];
    if (subItems != null) all.addAll(subItems!);
    if (subSections != null) {
      for (final section in subSections!) {
        all.addAll(section.items);
      }
    }
    _cachedAllSubItems = all;
    return all;
  }

  List<RecitationSubItem> get videoSubItems {
    return allSubItems.where((s) => s.hasVideo).toList();
  }

  List<RecitationSubItem> get audioSubItems {
    return allSubItems.where((s) => s.hasAudio).toList();
  }

  factory RecitationItem.fromJson(Map<String, dynamic> json) {
    final rawSubItems = json['subItems'] as List?;
    final rawSubSections = json['subSections'] as List?;
    final videoUrl = _strOrNull(json['videoUrl']);

    return RecitationItem(
      title: _str(json['title']),
      subtitle: _str(json['subtitle']),
      emoji: _str(json['emoji']),
      imageUrl: _strOrNull(json['imageUrl']) ?? youtubeThumbnailUrl(videoUrl),
      imageAsset: _strOrNull(json['imageAsset']),
      station: null, // JSON لا يحمل station — يُضاف برمجيًا إذا لزم
      audioUrl: _strOrNull(json['audioUrl']),
      playlistUrl: _strOrNull(json['playlistUrl']),
      videoUrl: videoUrl,
      videoSource: _parseVideoSource(json['videoSource']),
      mediaType: _parseMediaType(json['mediaType']),
      subItems: rawSubItems == null || rawSubItems.isEmpty
          ? null
          : rawSubItems
          .map((e) =>
          RecitationSubItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subSections: rawSubSections == null || rawSubSections.isEmpty
          ? null
          : rawSubSections
          .map((e) =>
          RecitationSubSection.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'emoji': emoji,
    'imageUrl': imageUrl,
    'imageAsset': imageAsset,
    'audioUrl': audioUrl,
    'playlistUrl': playlistUrl,
    'videoUrl': videoUrl,
    'videoSource': videoSource?.name,
    'mediaType': mediaType.name,
    'subItems': subItems?.map((s) => s.toJson()).toList(),
    'subSections': subSections?.map((s) => s.toJson()).toList(),
  };
}

// ══════════════════════════════════════════════════════
// نموذج العنصر الفرعي
// ══════════════════════════════════════════════════════

class RecitationSubItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String audioUrl;
  final String? imageUrl;
  final int? durationSeconds;
  final bool isLive;

  // حقول الفيديو
  final String? videoUrl;
  final VideoSource? videoSource;
  final MediaType mediaType;

  const RecitationSubItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.audioUrl,
    this.imageUrl,
    this.durationSeconds,
    this.isLive = false,
    this.videoUrl,
    this.videoSource,
    this.mediaType = MediaType.audio,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl.isNotEmpty;

  bool get isVideoOnly => mediaType == MediaType.video;
  bool get isYouTube => videoSource == VideoSource.youtube;
  bool get isDirectVideo => videoSource == VideoSource.direct;
  bool get isTikTok => videoSource == VideoSource.tiktok;

  String get bestPlayUrl {
    if (hasVideo) return videoUrl!;
    return audioUrl;
  }

  String get mediaEmoji {
    if (isVideoOnly) return '🎬';
    if (hasVideo) return '🎙️';
    return emoji;
  }

  String get durationStr {
    if (durationSeconds == null) return '';
    final m = (durationSeconds! ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds! % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory RecitationSubItem.fromJson(Map<String, dynamic> json) {
    final videoUrl = _strOrNull(json['videoUrl']);
    return RecitationSubItem(
      title: _str(json['title']),
      subtitle: _str(json['subtitle']),
      emoji: _str(json['emoji']),
      audioUrl: _str(json['audioUrl']),
      imageUrl: _strOrNull(json['imageUrl']) ?? youtubeThumbnailUrl(videoUrl),
      durationSeconds: json['durationSeconds'] == null
          ? null
          : (json['durationSeconds'] is int
          ? json['durationSeconds']
          : int.tryParse(json['durationSeconds'].toString())),
      isLive: json['isLive'] == true,
      videoUrl: videoUrl,
      videoSource: _parseVideoSource(json['videoSource']),
      mediaType: _parseMediaType(json['mediaType']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'emoji': emoji,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'durationSeconds': durationSeconds,
    if (isLive) 'isLive': true,
    'videoUrl': videoUrl,
    'videoSource': videoSource?.name,
    'mediaType': mediaType.name,
  };

}

// ══════════════════════════════════════════════════════
// دوال مساعدة مشتركة
// ══════════════════════════════════════════════════════

String _str(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _strOrNull(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<T> _parseList<T>(dynamic raw, T Function(dynamic) mapper) {
  if (raw is! List) return const [];
  return raw.map(mapper).toList();
}

List<Color> _parseColors(dynamic raw) {
  if (raw is! List || raw.isEmpty) {
    return const [Color(0xFF1F2937), Color(0xFF374151)];
  }

  return raw.map<Color>((e) {
    if (e is int) return Color(e);
    return _tryParseColor(e.toString()) ?? const Color(0xFF1F2937);
  }).toList();
}

Color? _tryParseColor(String value) {
  try {
    var hex = value.trim().toUpperCase();
    hex = hex.replaceAll('#', '').replaceAll('0X', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) return null;
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return null;
  }
}

VideoSource? _parseVideoSource(dynamic value) {
  switch ((value ?? '').toString().toLowerCase()) {
    case 'direct':
      return VideoSource.direct;
    case 'youtube':
      return VideoSource.youtube;
    case 'tiktok':
      return VideoSource.tiktok;
    default:
      return null;
  }
}

/// ✅ كشف تلقائي لنوع الفيديو من الرابط
VideoSource detectVideoSource(String? url) {
  if (url == null || url.isEmpty) return VideoSource.direct;

  final lower = url.toLowerCase();

  if (lower.contains('youtube.com') ||
      lower.contains('youtu.be') ||
      lower.contains('youtube')) {
    return VideoSource.youtube;
  }

  if (lower.contains('tiktok.com') ||
      lower.contains('vm.tiktok') ||
      lower.contains('vt.tiktok')) {
    return VideoSource.tiktok;
  }

  return VideoSource.direct;
}

MediaType _parseMediaType(dynamic value) {
  switch ((value ?? '').toString().toLowerCase()) {
    case 'video':
      return MediaType.video;
    case 'both':
      return MediaType.both;
    case 'audio':
    default:
      return MediaType.audio;
  }
}

/// يولد رابط الصورة الرسمية من يوتيوب عند غيابها من JSON.
/// لا يغيّر الصور المكتوبة في البيانات؛ يستخدم فقط كبديل موثوق لفيديوهات يوتيوب.
String? youtubeThumbnailUrl(String? url) {
  if (url == null || url.trim().isEmpty ||
      detectVideoSource(url) != VideoSource.youtube) {
    return null;
  }

  final uri = Uri.tryParse(url);
  String? id;
  if (uri != null) {
    if (uri.host.contains('youtu.be')) {
      id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else {
      id = uri.queryParameters['v'];
      if ((id == null || id.isEmpty) && uri.pathSegments.length >= 2) {
        final first = uri.pathSegments.first;
        if (first == 'shorts' || first == 'embed' || first == 'live') {
          id = uri.pathSegments[1];
        }
      }
    }
  }

  if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) {
    return null;
  }
  return 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}
