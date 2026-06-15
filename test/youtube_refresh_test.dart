// Test for the new _refreshLiveYouTube function and _parseYouTubeRss helper.
//
// The refresh button should:
// 1. Read youtube_channels.json (manifest) — get list of channels
// 2. For each channel, fetch live RSS from YouTube
// 3. Parse RSS to a list of RecitationItems
// 4. Update categories in memory
//
// This file tests the pure parsing logic only (no HTTP). The HTTP-driven
// `_refreshLiveYouTube` is tested in widget_test.dart (with mocked http).

import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/screens/radio/models/recitation_models.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';

void main() {
  group('_parseYouTubeRss', () {
    test('extracts videoId, title, builds one group with subItems', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>yt:video:abc123</id>
    <title>First Video</title>
    <link rel="alternate" href="https://www.youtube.com/watch?v=abc123"/>
  </entry>
  <entry>
    <id>yt:video:def456</id>
    <title>Second Video</title>
    <link rel="alternate" href="https://www.youtube.com/watch?v=def456"/>
  </entry>
</feed>''';

      final items = RecitationCategoriesData.parseYouTubeRss(
        xmlBody: xml,
        channelName: 'Test Channel',
        limit: 15,
      );

      expect(items, hasLength(1));
      expect(items[0].subItems, hasLength(2));
      expect(items[0].subItems![0].title, 'First Video');
      expect(items[0].subItems![0].audioUrl,
          'https://www.youtube.com/watch?v=abc123');
      expect(items[0].subItems![0].videoSource, VideoSource.youtube);
      expect(items[0].subItems![0].mediaType, MediaType.both);
      expect(items[0].subItems![1].title, 'Second Video');
    });

    test('separates shorts into own group (title has #shorts)', () {
      const xml = '''<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><id>yt:video:s1</id><title>Short clip #shorts</title></entry>
  <entry><id>yt:video:s2</id><title>شورتس إسلامي</title></entry>
  <entry><id>yt:video:v1</id><title>Regular video</title></entry>
</feed>''';
      final items = RecitationCategoriesData.parseYouTubeRss(
        xmlBody: xml,
        channelName: 'X',
        limit: 15,
      );
      // Expect at least 2 groups: shorts + videos
      final shortsGroup = items.firstWhere(
        (i) => i.title.contains('شورتس'),
        orElse: () => items.first,
      );
      final videosGroup = items.firstWhere(
        (i) => i.title.contains('فيديوهات'),
        orElse: () => items.first,
      );
      expect(shortsGroup.subItems, hasLength(2));
      expect(videosGroup.subItems, hasLength(1));
    });

    test('separates live broadcasts into own group', () {
      const xml = '''<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><id>yt:video:l1</id><title>البث المباشر الآن</title></entry>
  <entry><id>yt:video:l2</id><title>Live stream with Sheikh</title></entry>
  <entry><id>yt:video:l3</id><title>بث طاريء: رسالة عاجلة</title></entry>
  <entry><id>yt:video:l4</id><title>بث عاجل : هل المسيح الدجال</title></entry>
  <entry><id>yt:video:v1</id><title>Recorded lecture</title></entry>
</feed>''';
      final items = RecitationCategoriesData.parseYouTubeRss(
        xmlBody: xml,
        channelName: 'X',
        limit: 15,
      );
      final liveGroup = items.firstWhere(
        (i) => i.title.contains('بث') || i.title.contains('Live'),
        orElse: () => items.first,
      );
      final videosGroup = items.firstWhere(
        (i) => i.title.contains('فيديوهات'),
        orElse: () => items.first,
      );
      expect(liveGroup.subItems, hasLength(4));
      expect(videosGroup.subItems, hasLength(1));
    });

    test('negation: "not live" goes to videos, not live', () {
      const xml = '''<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><id>yt:video:hl1</id><title>Highlights - not live</title></entry>
  <entry><id>yt:video:l1</id><title>بث مباشر</title></entry>
</feed>''';
      final items = RecitationCategoriesData.parseYouTubeRss(
        xmlBody: xml,
        channelName: 'X',
        limit: 15,
      );
      final liveGroup = items.firstWhere(
        (i) => i.title.contains('بث'),
        orElse: () => items.first,
      );
      final videosGroup = items.firstWhere(
        (i) => i.title.contains('فيديوهات'),
        orElse: () => items.first,
      );
      expect(liveGroup.subItems, hasLength(1));
      expect(videosGroup.subItems, hasLength(1));
      expect(videosGroup.subItems!.first.title, 'Highlights - not live');
    });

    test('respects limit parameter', () {
      const xml = '''<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><id>yt:video:v1</id><title>V1</title></entry>
  <entry><id>yt:video:v2</id><title>V2</title></entry>
  <entry><id>yt:video:v3</id><title>V3</title></entry>
  <entry><id>yt:video:v4</id><title>V4</title></entry>
  <entry><id>yt:video:v5</id><title>V5</title></entry>
</feed>''';

      final items = RecitationCategoriesData.parseYouTubeRss(
        xmlBody: xml,
        channelName: 'X',
        limit: 2,
      );
      expect(items, hasLength(1));
      expect(items[0].subItems, hasLength(2));
    });

    test('returns empty list for empty/malformed xml', () {
      expect(
        RecitationCategoriesData.parseYouTubeRss(
          xmlBody: '',
          channelName: 'X',
          limit: 15,
        ),
        isEmpty,
      );
      expect(
        RecitationCategoriesData.parseYouTubeRss(
          xmlBody: 'not xml',
          channelName: 'X',
          limit: 15,
        ),
        isEmpty,
      );
    });
  });

  group('_mergeYouTubeItems', () {
    test('keeps new items first, adds old items not in new', () {
      // New RSS returns [V2, V3, V4]
      // Old cache had [V1, V2, V3]
      // Result: [V2, V3, V4, V1] (V4 is new, V1 is preserved)
      final oldUrls = ['V1', 'V2', 'V3'];
      final newUrls = ['V2', 'V3', 'V4'];

      final merged = RecitationCategoriesData.mergeYouTubeItems(
        oldVideoIds: oldUrls,
        newVideoIds: newUrls,
      );

      expect(merged, ['V2', 'V3', 'V4', 'V1']);
    });

    test('does not duplicate items present in both', () {
      final merged = RecitationCategoriesData.mergeYouTubeItems(
        oldVideoIds: ['A', 'B', 'C'],
        newVideoIds: ['B', 'C', 'D'],
      );
      expect(merged, ['B', 'C', 'D', 'A']);
    });

    test('handles empty old list', () {
      expect(
        RecitationCategoriesData.mergeYouTubeItems(
          oldVideoIds: [],
          newVideoIds: ['A', 'B'],
        ),
        ['A', 'B'],
      );
    });

    test('handles empty new list (returns old as-is)', () {
      expect(
        RecitationCategoriesData.mergeYouTubeItems(
          oldVideoIds: ['A', 'B'],
          newVideoIds: [],
        ),
        ['A', 'B'],
      );
    });
  });

  group('classifyBucketByMetadata', () {
    test('isLive=true goes to live even without live keyword in title', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'اتصالات المسلمين',
        isLive: true,
        duration: null,
      );
      expect(bucket, 'live');
    });

    test('live_status=was_live goes to live', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'حوار مع ملحد',
        liveStatus: 'was_live',
        duration: null,
      );
      expect(bucket, 'live');
    });

    test('long duration (>1h) + no live keyword → live (recorded broadcast)', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'حوار مع النصارى والملحدين',
        liveStatus: 'not_live',
        duration: const Duration(hours: 1, minutes: 5),
      );
      expect(bucket, 'live');
    });

    test('short duration (<1h) + no live keyword → videos', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'شرح قصير',
        liveStatus: 'not_live',
        duration: const Duration(minutes: 10),
      );
      expect(bucket, 'videos');
    });

    test('no metadata + بث keyword → live (title fallback)', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'بث طاريء: رسالة عاجلة',
        liveStatus: null,
        duration: null,
      );
      expect(bucket, 'live');
    });

    test('no metadata + no live keyword → videos', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'رضاع الكبير في الإسلام والنصراني مصدوم من الرد',
        liveStatus: null,
        duration: null,
      );
      expect(bucket, 'videos');
    });

    test('shorts keyword overrides metadata', () {
      final bucket = RecitationCategoriesData.classifyBucketByMetadata(
        title: 'دعاء قصير #shorts',
        liveStatus: 'not_live',
        duration: const Duration(seconds: 60),
      );
      expect(bucket, 'shorts');
    });

    test('broad title keywords like حوارات/اتصالات/لقاء are NOT live without metadata', () {
      final titles = [
        'حوار مع نصراني مضحك جدا',
        'اتصالات المسلمين',
        'لقاء مع الشيخ أبي مالك',
        'حوارات مع النصارى والملحدين',
        'مكالمة مع متدين نصراني',
      ];
      for (final title in titles) {
        final bucket = RecitationCategoriesData.classifyBucketByMetadata(
          title: title,
          liveStatus: null,
          duration: null,
        );
        expect(bucket, 'videos',
            reason: '"$title" should be videos, not live');
      }
    });

    test('core live keywords like بث مباشر/لايف/مباشر ARE live', () {
      final titles = [
        'بث مباشر — الشيخ زين خير الله',
        'البث الحي الآن',
        'لايف مع المشاهدين',
        'مباشر — اتصالات المسلمين',
      ];
      for (final title in titles) {
        final bucket = RecitationCategoriesData.classifyBucketByMetadata(
          title: title,
          liveStatus: null,
          duration: null,
        );
        expect(bucket, 'live',
            reason: '"$title" should be live');
      }
    });
  });

  group('YouTube items ordering', () {
    test('mergeYouTubeItems puts new video IDs first', () {
      final merged = RecitationCategoriesData.mergeYouTubeItems(
        oldVideoIds: ['old1', 'old2', 'old3', 'new1', 'new2'],
        newVideoIds: ['new1', 'new2', 'new3'],
      );
      expect(merged.first, 'new1');
      expect(merged[1], 'new2');
      expect(merged[2], 'new3');
      expect(merged, containsAll(['old1', 'old2', 'old3']));
    });

    test('_mergeGroupSubItems puts new subItems first', () {
      final oldSubs = [
        RecitationSubItem(
          title: 'Old 1',
          subtitle: 'channel',
          emoji: '',
          audioUrl: 'https://www.youtube.com/watch?v=old1',
        ),
        RecitationSubItem(
          title: 'Old 2',
          subtitle: 'channel',
          emoji: '',
          audioUrl: 'https://www.youtube.com/watch?v=old2',
        ),
      ];
      final newSubs = [
        RecitationSubItem(
          title: 'New 1',
          subtitle: 'channel',
          emoji: '',
          audioUrl: 'https://www.youtube.com/watch?v=new1',
        ),
        RecitationSubItem(
          title: 'New 2',
          subtitle: 'channel',
          emoji: '',
          audioUrl: 'https://www.youtube.com/watch?v=new2',
        ),
      ];

      final merged = RecitationCategoriesData.mergeGroupSubItemsForTest(
        oldSubItems: oldSubs,
        newSubItems: newSubs,
      );

      expect(merged.length, 4);
      expect(merged[0].title, 'New 1');
      expect(merged[1].title, 'New 2');
      expect(merged[2].title, 'Old 1');
      expect(merged[3].title, 'Old 2');
    });
  });

  group('classifySubItem — metadata-based classification', () {
    test('isLive=true → live', () {
      final item = RecitationSubItem(
        title: 'اتصالات المسلمين',
        subtitle: 'channel',
        emoji: '',
        audioUrl: 'https://www.youtube.com/watch?v=abc',
        isLive: true,
      );
      expect(RecitationCategoriesData.classifySubItem(item), 'live');
    });

    test('isLive absent + title heuristic → live (بث مباشر)', () {
      final item = RecitationSubItem(
        title: 'بث مباشر — الشيخ زين',
        subtitle: 'channel',
        emoji: '',
        audioUrl: 'https://www.youtube.com/watch?v=abc',
      );
      expect(RecitationCategoriesData.classifySubItem(item), 'live');
    });

    test('isLive absent + broad title → videos (not live)', () {
      final item = RecitationSubItem(
        title: 'حوار مع نصراني مضحك',
        subtitle: 'channel',
        emoji: '',
        audioUrl: 'https://www.youtube.com/watch?v=abc',
      );
      expect(RecitationCategoriesData.classifySubItem(item), 'videos');
    });

    test('no metadata + title with بث مباشر → live (fallback)', () {
      final item = RecitationSubItem(
        title: 'بث مباشر — الشيخ زين',
        subtitle: 'channel',
        emoji: '',
        audioUrl: 'https://www.youtube.com/watch?v=abc',
      );
      expect(RecitationCategoriesData.classifySubItem(item), 'live');
    });

    test('no metadata + broad title keywords → videos (not live)', () {
      final item = RecitationSubItem(
        title: 'حوار مع نصراني مضحك',
        subtitle: 'channel',
        emoji: '',
        audioUrl: 'https://www.youtube.com/watch?v=abc',
      );
      expect(RecitationCategoriesData.classifySubItem(item), 'videos');
    });
  });
}
