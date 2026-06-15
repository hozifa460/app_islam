// lib/screens/radio/data/recitation_categories_data.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/recitation_models.dart';
import 'radio_data.dart';

class RecitationCategoriesData {
  RecitationCategoriesData._();

  static const String _indexUrl =
      'https://raw.githubusercontent.com/hozifa460/fatawa_database/refs/heads/main/radio_database/index.json';
  static const String _baseUrl =
      'https://raw.githubusercontent.com/hozifa460/fatawa_database/refs/heads/main/radio_database/';
  static const String _gitLabIndexUrl =
      'https://gitlab.com/hazozahz-islamway/hazozahz-islamway/-/raw/main/radio_islam/index.json';
  static const String _gitLabBaseUrl =
      'https://gitlab.com/hazozahz-islamway/hazozahz-islamway/-/raw/main/radio_islam/';
  static const String _localJsonFolder = 'assets/json/recitations/';
  static const String _cacheDir = 'recitations_cache';

  static const int _maxCategories = 30;

  // ✅ القائمة الحية - تُحدَّث واحدة واحدة
  static final List<RecitationCategory> _liveList = [];
  static bool _initialized = false;
  static bool _initializing = false;
  static Completer<void>? _initCompleter;
  static DateTime? _lastRemoteSync;
  static const Duration _remoteCooldown = Duration(minutes: 60);

  static DateTime? _lastYouTubeSync;
  static const Duration _youTubeCooldown = Duration(hours: 1);

  // ✅ Stream يُرسل كل كاتيغوري فور تحميلها
  static final StreamController<List<RecitationCategory>> _streamController =
  StreamController<List<RecitationCategory>>.broadcast();

  static Stream<List<RecitationCategory>> get stream =>
      _streamController.stream;

  // ✅ القائمة الحالية دائماً
  static List<RecitationCategory> get current =>
      List.unmodifiable(_liveList);

  // ══════════════════════════════════════════════════════
  // البناء الأولي (فوري - من الكاش)
  // ══════════════════════════════════════════════════════
  static List<RecitationCategory> build() {
    if (_liveList.isEmpty) {
      return [_buildRecitersCategory()];
    }
    return List.unmodifiable(_liveList);
  }

  // ══════════════════════════════════════════════════════
  // ✅ التهيئة التدريجية - تُضيف كاتيغوري واحدة واحدة
  // ══════════════════════════════════════════════════════
  static Future<void> initialize({bool refreshRemote = false}) async {
    if (_initialized && !refreshRemote) return;
    if (_initializing) {
      await _initCompleter?.future;
      return;
    }
    _initializing = true;
    _initCompleter = Completer<void>();

    // ✅ أضف القراء فوراً
    _addCategory(_buildRecitersCategory());

    try {
      // ✅ 1) جرب الكاش أولاً (تدريجي)
      await _loadCachedCategoriesStreaming();

      // ✅ 2) fallback للـ assets (تدريجي)
      await _loadLocalAssetsStreaming();

      // ✅ 2b) استعادة كاش يوتيوب (يتجاوز بيانات assets القديمة)
      await _loadCachedYouTubeCategories();

      // ✅ 3) المزامنة مع الإنترنت (GitHub + GitLab) — دائماً
      final now = DateTime.now();
      final shouldSync = refreshRemote ||
          _lastRemoteSync == null ||
          now.difference(_lastRemoteSync!) > _remoteCooldown;
      if (shouldSync) {
        _lastRemoteSync = now;
        await _syncWithRemoteStreaming();
      }

      // ✅ 4) YouTube videos (GitHub → GitLab) — يومياً
      final shouldSyncYouTube = refreshRemote ||
          _lastYouTubeSync == null ||
          now.difference(_lastYouTubeSync!) > _youTubeCooldown;
      if (shouldSyncYouTube) {
        _lastYouTubeSync = now;
        await _fetchYouTubeChannels();
      }

      _initialized = true;
    } finally {
      _initializing = false;
      if (!_initCompleter!.isCompleted) _initCompleter!.complete();
    }
    debugPrint('✅ Total: ${_liveList.length} categories');
  }

  // ══ إضافة كاتيغوري وإشعار المستمعين فوراً ══
  static void _trimIfNeeded() {
    while (_liveList.length > _maxCategories) {
      _liveList.removeAt(0);
    }
  }

  static void _addCategory(RecitationCategory cat) {
    final idx = _liveList.indexWhere((c) => c.id == cat.id);
    if (idx >= 0) {
      // ✅ استبدل البيانات القديمة بالأحدث (مثلاً من remote)
      _liveList[idx] = cat;
    } else {
      _liveList.add(cat);
    }
    _trimIfNeeded();
    if (!_streamController.isClosed) {
      _streamController.add(List.unmodifiable(_liveList));
    }
  }

  static void _addCategories(List<RecitationCategory> cats) {
    bool changed = false;
    for (final cat in cats) {
      final idx = _liveList.indexWhere((c) => c.id == cat.id);
      if (idx >= 0) {
        _liveList[idx] = cat; // ✅ استبدل
        changed = true;
      } else {
        _liveList.add(cat);
        changed = true;
      }
    }
    _trimIfNeeded();
    if (changed && !_streamController.isClosed) {
      _streamController.add(List.unmodifiable(_liveList));
    }
  }

  // ══════════════════════════════════════════════════════
  // ✅ تحميل الكاش تدريجياً - ملف ملف
  // ══════════════════════════════════════════════════════
  static Future<bool> _loadCachedCategoriesStreaming() async {
    try {
      final dir = await _getCacheDir();
      if (!await dir.exists()) return false;

      final entities = await dir.list().toList();
      final files = entities
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      if (files.isEmpty) return false;

      for (final file in files) {
        try {
          final raw = await file.readAsString();
          if (raw.trim().isEmpty) continue; // ✅ تخطي الملفات الفارغة
          final decoded = jsonDecode(raw);
          final cats = _parseJson(decoded);
          if (cats.isNotEmpty) {
            _addCategories(cats);
            await Future.delayed(const Duration(milliseconds: 16));
          }
        } catch (e) {
          debugPrint('⚠️ Cache load failed [${file.path}]: $e');
        }
      }

      debugPrint('📦 From cache: ${_liveList.length}');
      return _liveList.length > 1;
    } catch (e) {
      debugPrint('⚠️ Cache load error: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════
  // ✅ تحميل كاش يوتيوب (بعد assets — يتجاوز القديم)
  // ══════════════════════════════════════════════════════
  static Future<void> _loadCachedYouTubeCategories() async {
    try {
      final dir = await _getCacheDir();
      if (!await dir.exists()) return;
      final entities = await dir.list().toList();
      for (final file in entities.whereType<File>()) {
        final name = file.path.split(Platform.pathSeparator).last;
        if (!name.startsWith('youtube_') || !name.endsWith('.json')) continue;
        try {
          final raw = await file.readAsString();
          if (raw.trim().isEmpty) continue;
          final decoded = jsonDecode(raw);
          final cats = _parseJson(decoded);
          if (cats.isNotEmpty) _addCategories(cats);
        } catch (e) {
          debugPrint('⚠️ YouTube cache load failed [$name]: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ YouTube cache load error: $e');
    }
  }

  // ══════════════════════════════════════════════════════
  // ✅ تحميل الـ Assets تدريجياً
  // ══════════════════════════════════════════════════════
  static Future<void> _loadLocalAssetsStreaming() async {
    List<String> files = [];

    // ✅ الطريقة الأولى: AssetManifest
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      files = manifest
          .listAssets()
          .where(
            (p) => p.startsWith(_localJsonFolder) && p.endsWith('.json'),
      )
          .toList()
        ..sort();
    } catch (e) {
      debugPrint('⚠️ AssetManifest failed: $e');
    }

    // ✅ الطريقة الثانية: قائمة يدوية كـ fallback
    if (files.isEmpty) {
      files = [
        'assets/json/recitations/1_menshawy.json',
        'assets/json/recitations/2_abd_el_baset.json',
        'assets/json/recitations/3_majd_channel.json',
        'assets/json/recitations/4_social_videos.json',
        'assets/json/recitations/5_alshaarawy.json',
        'assets/json/recitations/6_abo_ishak_alhowini.json',
        'assets/json/recitations/zein_khair_allah.json',
      ];
    }

    for (final path in files) {
      try {
        final raw = await rootBundle.loadString(path);
        if (raw.trim().isEmpty) continue; // ✅ تخطي الملفات الفارغة
        final decoded = jsonDecode(raw);
        final cats = _parseJson(decoded);
        if (cats.isNotEmpty) {
          _addCategories(cats);
          await Future.delayed(const Duration(milliseconds: 16));
        }
      } catch (e) {
        debugPrint('⚠️ Asset load failed [$path]: $e');
      }
    }
    debugPrint('📂 From assets: ${_liveList.length}');
  }

  // ══════════════════════════════════════════════════════
  // ✅ المزامنة مع الإنترنت - تدريجية تماماً
  // ══════════════════════════════════════════════════════
  static Future<void> _syncWithRemoteStreaming() async {
    final sources = [
      {'key': 'github', 'indexUrl': _indexUrl, 'baseUrl': _baseUrl},
      {
        'key': 'gitlab',
        'indexUrl': _gitLabIndexUrl,
        'baseUrl': _gitLabBaseUrl,
      },
    ];

    final currentFiles = <String>[];

    for (final source in sources) {
      final sourceKey = source['key']!;
      final indexUrl = source['indexUrl']!;
      final baseUrl = source['baseUrl']!;

      try {
        final indexResponse = await http
            .get(
          // ✅ cache-busting: timestamp يضمن URL فريد في كل طلب
          Uri.parse('$indexUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
          headers: {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        )
            .timeout(
          Duration(seconds: sourceKey == 'gitlab' ? 20 : 10),
        );

        if (indexResponse.statusCode != 200) continue;

        final decoded = await compute(jsonDecode, indexResponse.body);
        List<dynamic> fileNames;

        if (decoded is Map<String, dynamic>) {
          fileNames = decoded['files'] as List? ?? [];
        } else if (decoded is List) {
          fileNames = decoded;
        } else {
          continue;
        }

        debugPrint('📋 [$sourceKey] ${fileNames.length} files');

        // ✅ حمّل كل ملف على حدة وأضفه فوراً
        for (final name in fileNames) {
          final fileName = name.toString();

          // ✅ ملفات YouTube تتولاها _fetchYouTubeChannels (دمج صحيح)
          // تتخطى 3 ملفات الجديدة: .live.json / .videos.json / .shorts.json
          // + القديمة .youtube.json (لفترة انتقالية)
          if (fileName.endsWith('.youtube.json') ||
              fileName.endsWith('.live.json') ||
              fileName.endsWith('.videos.json') ||
              fileName.endsWith('.shorts.json')) {
            continue;
          }

          final url = '$baseUrl$fileName';
          final safeName =
              '${sourceKey}_${fileName.replaceAll('/', '_')}';
          currentFiles.add(safeName);

          try {
            final response = await http
                .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Cache-Control': 'no-cache, no-store',
              },
            )
                .timeout(
              Duration(
                seconds: sourceKey == 'gitlab' ? 40 : 15,
              ),
            );

            if (response.statusCode == 200) {
              try {
                final fileDecoded = await compute(jsonDecode, response.body);
                final cats = _parseJson(fileDecoded);

                // ✅ أضف فوراً بدون انتظار
                _addCategories(cats);
                await _cacheFile(safeName, response.body);
                debugPrint('✅ [$sourceKey] $safeName (+${cats.length})');
              } catch (e) {
                // parse error → جرب الكاش
                final cached = await _loadSingleCacheFile(safeName);
                if (cached != null) _addCategories(cached);
              }
            } else {
              final cached = await _loadSingleCacheFile(safeName);
              if (cached != null) _addCategories(cached);
            }
          } catch (e) {
            debugPrint('❌ [$sourceKey] $safeName: $e');
            final cached = await _loadSingleCacheFile(safeName);
            if (cached != null) _addCategories(cached);
          }

          // ✅ إعطاء Flutter فرصة للرسم بين كل ملف
          await Future.delayed(const Duration(milliseconds: 8));
        }
      } catch (e) {
        debugPrint('❌ [$sourceKey] Sync error: $e');
      }
    }

    await _cleanupRemovedFiles(currentFiles);
  }

  // ══════════════════════════════════════════════════════
  // Parse مشترك
  // ══════════════════════════════════════════════════════
  static List<RecitationCategory> _parseJson(dynamic decoded) {
    final cats = <RecitationCategory>[];
    try {
      if (decoded is Map<String, dynamic>) {
        cats.add(RecitationCategory.fromJson(decoded));
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            cats.add(
              RecitationCategory.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ _parseJson error: $e');
    }
    return cats;
  }

  // ══════════════════════════════════════════════════════
  // reload و forceRefresh
  // ══════════════════════════════════════════════════════
  static Future<void> reload() async {
    _initialized = false;
    _liveList.clear();
    await initialize(refreshRemote: true);
  }

  static Future<void> forceRefresh() async {
    try {
      final dir = await _getCacheDir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
    _initialized = false;
    _liveList.clear();
    await initialize(refreshRemote: true);
  }

  // ══════════════════════════════════════════════════════
  // Cache helpers (نفس الكود القديم)
  // ══════════════════════════════════════════════════════
  static Future<Directory> _getCacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_cacheDir');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<void> _cacheFile(String name, String content) async {
    try {
      final dir = await _getCacheDir();
      await File('${dir.path}/$name').writeAsString(content);
    } catch (_) {}
  }

  static Future<List<RecitationCategory>?> _loadSingleCacheFile(
      String name,
      ) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/$name');
      if (!await file.exists()) return null;
      final decoded = await compute(jsonDecode, await file.readAsString());
      return _parseJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cacheYouTubeCategory(String categoryId) async {
    try {
      final idx = _liveList.indexWhere((c) => c.id == categoryId);
      if (idx < 0) return;
      final json = jsonEncode(_liveList[idx].toJson());
      await _cacheFile('youtube_$categoryId.json', json);
    } catch (_) {}
  }

  static Future<void> _cleanupRemovedFiles(
      List<dynamic> currentFiles,
      ) async {
    try {
      final dir = await _getCacheDir();
      if (!await dir.exists()) return;
      final current = currentFiles.map((f) => f.toString()).toSet();
      final entities = await dir.list().toList();
      for (final file in entities.whereType<File>()) {
        final name = file.path.split(Platform.pathSeparator).last;
        if (name.startsWith('youtube_')) continue; // يحتفظ بكاش يوتيوب
        if (!current.contains(name)) {
          await file.delete();
          debugPrint('🗑️ $name');
        }
      }
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════
  // القراء
  // ══════════════════════════════════════════════════════
  static RecitationCategory _buildRecitersCategory() {
    final reciters =
    RadioStationsData.all.where((s) => s.supportsDownload).toList();
    return RecitationCategory(
      id: 'reciters',
      title: 'القراء',
      emoji: '📖',
      description: 'استمع وحمّل تلاوات كبار القراء',
      gradientColors: const [Color(0xFF2D1B69), Color(0xFF7C3AED)],
      items: reciters
          .map(
            (s) => RecitationItem(
          title: s.name,
          subtitle: s.description,
          emoji: s.iconEmoji,
          imageUrl: s.imageUrl,
          imageAsset: s.imageAsset,
          station: s,
        ),
      )
          .toList(),
    );
  }

  // ✅ أضف هذه الدالة في RecitationCategoriesData
// للتحديث بدون إعادة بناء كل شيء

  static Future<void> addOrUpdateCategory(
      RecitationCategory newCat,
      ) async {
    final idx = _liveList.indexWhere((c) => c.id == newCat.id);
    if (idx >= 0) {
      // ✅ تحديث الموجود
      _liveList[idx] = newCat;
    } else {
      // ✅ إضافة جديد
      _liveList.add(newCat);
    }

    // ✅ أبلغ المستمعين
    if (!_streamController.isClosed) {
      _streamController.add(List.unmodifiable(_liveList));
    }

    // ✅ احفظ في الكاش
    try {
      final content = jsonEncode(newCat.toJson());
      await _cacheFile('local_${newCat.id}.json', content);
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════
  // YouTube live refresh — يجلب RSS مباشرة لكل قناة في الـ manifest
  // (لا يعتمد على ملفات .youtube.json الثابتة)
  // ══════════════════════════════════════════════════════

  /// يحوّل نص XML لـ RSS feed لقائمة عناصر (RecitationItem واحد أو أكثر)
  /// العناصر تُصنَّف إلى 3 مجموعات: بثوث مباشرة / فيديوهات / شورتس
  /// [xmlBody] نص الـ XML من YouTube
  /// [channelName] اسم القناة (يظهر في subtitle)
  /// [limit] أقصى عدد فيديوهات لكل نوع
  @visibleForTesting
  static List<RecitationItem> parseYouTubeRss({
    required String xmlBody,
    required String channelName,
    required int limit,
  }) {
    if (xmlBody.trim().isEmpty) return [];
    final videoRegex = RegExp(
      r'<entry>(.*?)</entry>',
      multiLine: true,
      dotAll: true,
    );
    final idRegex = RegExp(r'<id>\s*yt:video:([A-Za-z0-9_-]+)\s*</id>');
    final titleRegex = RegExp(r'<title>(.*?)</title>', dotAll: true);

    final liveItems = <RecitationSubItem>[];
    final videoItems = <RecitationSubItem>[];
    final shortsItems = <RecitationSubItem>[];

    for (final entryMatch in videoRegex.allMatches(xmlBody)) {
      final entry = entryMatch.group(1) ?? '';
      final idMatch = idRegex.firstMatch(entry);
      final titleMatch = titleRegex.firstMatch(entry);
      if (idMatch == null || titleMatch == null) continue;
      final videoId = idMatch.group(1) ?? '';
      final title = _stripXmlEntities(titleMatch.group(1) ?? '').trim();
      if (videoId.isEmpty || title.isEmpty) continue;

      final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
      final subItem = RecitationSubItem(
        title: title,
        subtitle: channelName,
        emoji: '',
        audioUrl: youtubeUrl,
        imageUrl: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
        videoUrl: youtubeUrl,
        videoSource: VideoSource.youtube,
        mediaType: MediaType.both,
      );

      // تصنيف: shorts أولاً (أدق)، ثم live (مع النفي)، ثم videos
      if (_isShorts(title)) {
        if (shortsItems.length < limit) shortsItems.add(subItem);
      } else if (_isLive(title)) {
        if (liveItems.length < limit) liveItems.add(subItem);
      } else {
        if (videoItems.length < limit) videoItems.add(subItem);
      }
    }

    final groups = <RecitationItem>[];
    if (liveItems.isNotEmpty) {
      groups.add(RecitationItem(
        title: 'بثوث مباشرة — $channelName',
        subtitle: 'يوتيوب',
        emoji: '🔴',
        imageUrl: '',
        audioUrl: '',
        subItems: liveItems,
      ));
    }
    if (videoItems.isNotEmpty) {
      groups.add(RecitationItem(
        title: 'فيديوهات $channelName',
        subtitle: 'يوتيوب',
        emoji: '🎙️',
        imageUrl: '',
        audioUrl: '',
        subItems: videoItems,
      ));
    }
    if (shortsItems.isNotEmpty) {
      groups.add(RecitationItem(
        title: 'شورتس — $channelName',
        subtitle: 'يوتيوب',
        emoji: '📱',
        imageUrl: '',
        audioUrl: '',
        subItems: shortsItems,
      ));
    }
    return groups;
  }

  /// يصنّف فيديو إلى bucket بناءً على metadata حقيقية (YouTube Data API / yt-dlp)
  /// + fallback للـ title heuristic لو الـ metadata مش متوفر.
  /// [title] عنوان الفيديو
  /// [isLive] true لو الفيديو بث مباشر (حالي) — من youtube_explode_dart أو yt-dlp
  /// [liveStatus] 'is_live' / 'was_live' / 'not_live' / 'is_upcoming' (من yt-dlp)
  /// [duration] مدة الفيديو (Duration object)
  /// [isShort] true لو الفيديو شورت رسمياً
  /// Returns: 'live' / 'videos' / 'shorts'
  ///
  /// الأولوية:
  /// 1. isLive=true أو liveStatus ∈ {is_live, was_live} → 'live'
  /// 2. isShort=true أو shorts في العنوان → 'shorts'
  /// 3. liveStatus='not_live' + مدة > ساعة → 'live' (بثوث مسجلة)
  /// 4. liveStatus='not_live' + مدة ≤ ساعة → 'videos'
  /// 5. لا metadata: ارجع للـ title heuristic (بث keyword → 'live')
  /// 6. افتراضي → 'videos'
  @visibleForTesting
  static String classifyBucketByMetadata({
    required String title,
    bool? isLive,
    String? liveStatus,
    Duration? duration,
    bool isShort = false,
  }) {
    // 1. Shorts wins everything (even over isLive metadata)
    if (isShort || _isShorts(title)) return 'shorts';
    // 2. Real metadata: live
    if (isLive == true ||
        (liveStatus != null &&
            (liveStatus == 'is_live' || liveStatus == 'was_live'))) {
      return 'live';
    }
    // 3. Long video + not_live = recorded broadcast
    if (liveStatus == 'not_live' &&
        duration != null &&
        duration.inSeconds > 3600) {
      return 'live';
    }
    // 4. Title-based live (fallback)
    if (_isLive(title)) return 'live';
    // 5. Default
    return 'videos';
  }

  /// يصنّف subItem باستخدام metadata المخزّنة فيه (isLive, durationSeconds)
  /// ثم fallback للعنوان. يُستخدم عند قراءة ملفات JSON من GitHub.
  /// isLive=true في JSON يعني: بث مباشر أو بث مسجل (was_live).
  /// isLive=false أو غائب: يستخدم العنوان كـ fallback.
  @visibleForTesting
  static String classifySubItem(RecitationSubItem item) {
    // isLive=true من CI = live مؤكد (live أو was_live)
    if (item.isLive) return 'live';
    // isLive=false أو غائب: fallback للعنوان
    return classifyBucketByMetadata(
      title: item.title,
      isLive: null,
      liveStatus: null,
      duration: item.durationSeconds != null
          ? Duration(seconds: item.durationSeconds!)
          : null,
    );
  }

  /// يحدد إذا كان العنوان يشير لـ Shorts
  static bool _isShorts(String title) {
    final lower = title.toLowerCase();
    return RegExp(r'(?:^|#|-\s*)shorts?\b|#short|شورتس|شورت')
        .hasMatch(lower);
  }

  /// يحدد إذا كان العنوان يشير لـ Live (مع احترام النفي مثل "not live")
  /// بث ككلمة مستقلة: يطابق "بث طاريء" / "بث عاجل" / "بث مباشر" / "البث" / "بث حي"
  /// مطابق لـ Python `_is_live` في sync_youtube.py
  static bool _isLive(String title) {
    final lower = title.toLowerCase();
    // نفي: "not live" / "ليس بث" / "لا بث" / "غير مباشر"
    if (RegExp(r'not\s+live|ليس\s+بث|لا\s+بث|غير\s*مباشر').hasMatch(lower)) {
      return false;
    }
    return RegExp(
            r'\b(live|streaming|live\s*now|live\s*stream|on\s*air|stream)\b'
            r'|(?<!\p{L})بث(?!\p{L})'
            r'|ال\s*بث'
            r'|لايف'
            r'|مباشر'
            r'|على\s*الهواء',
            unicode: true)
        .hasMatch(lower);
  }

  static String _stripXmlEntities(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  /// يستخرج videoId من YouTube watch URL
  /// مثال: https://www.youtube.com/watch?v=abc123 → abc123
  static String _videoIdFromUrl(String url) {
    final m = RegExp(r'[?&]v=([A-Za-z0-9_-]+)').firstMatch(url);
    return m?.group(1) ?? '';
  }

  /// يدمج subItems من group قديم مع group جديد (للحفاظ على التراكم)
  /// الـ new في المقدمة، ثم الـ old غير الموجودة في new
  static List<RecitationSubItem> _mergeGroupSubItems({
    required List<RecitationSubItem> oldSubItems,
    required List<RecitationSubItem> newSubItems,
  }) {
    final oldIds = oldSubItems
        .map((s) => _videoIdFromUrl(s.audioUrl))
        .where((id) => id.isNotEmpty)
        .toList();
    final newIds = newSubItems
        .map((s) => _videoIdFromUrl(s.audioUrl))
        .where((id) => id.isNotEmpty)
        .toList();
    final mergedIds = mergeYouTubeItems(
      oldVideoIds: oldIds,
      newVideoIds: newIds,
    );
    final newIdsSet = newIds.toSet();
    final result = <RecitationSubItem>[];
    for (final id in mergedIds) {
      if (newIdsSet.contains(id)) {
        result.add(newSubItems.firstWhere(
          (s) => _videoIdFromUrl(s.audioUrl) == id,
          orElse: () => newSubItems.first,
        ));
      } else {
        result.add(oldSubItems.firstWhere(
          (s) => _videoIdFromUrl(s.audioUrl) == id,
          orElse: () => oldSubItems.first,
        ));
      }
    }
    return result;
  }

  @visibleForTesting
  static List<RecitationSubItem> mergeGroupSubItemsForTest({
    required List<RecitationSubItem> oldSubItems,
    required List<RecitationSubItem> newSubItems,
  }) =>
      _mergeGroupSubItems(oldSubItems: oldSubItems, newSubItems: newSubItems);

  /// يدمج IDs فيديوهات جديدة (من RSS) مع القديمة (من الكاش):
  /// - الـ IDs الجديدة أولاً (بالترتيب اللي جاءت به من RSS = الأحدث أولاً)
  /// - ثم الـ IDs القديمة غير الموجودة في الجديدة (للحفاظ على تراكم)
  /// - بدون تكرار
  @visibleForTesting
  static List<String> mergeYouTubeItems({
    required List<String> oldVideoIds,
    required List<String> newVideoIds,
  }) {
    final newSet = newVideoIds.toSet();
    final result = <String>[...newVideoIds];
    for (final old in oldVideoIds) {
      if (!newSet.contains(old)) result.add(old);
    }
    return result;
  }

  // ══════════════════════════════════════════════════════
  // YouTube sync — يقرأ <categoryId>.youtube.json من index.json
  // ويدمجها مع الكاتيغوري الموجودة (نفس الـ id) بدلاً من استبدالها
  // ══════════════════════════════════════════════════════
  static Future<bool> _fetchYouTubeChannels() async {
    var totalAdded = 0;
    final sources = [
      {'key': 'github', 'indexUrl': _indexUrl, 'baseUrl': _baseUrl},
      {'key': 'gitlab', 'indexUrl': _gitLabIndexUrl, 'baseUrl': _gitLabBaseUrl},
    ];

    for (final source in sources) {
      final sourceKey = source['key']!;
      final indexUrl = source['indexUrl']!;
      final baseUrl = source['baseUrl']!;

      // 1) اقرأ index.json من المصدر الحالي
      final indexData = await _fetchJsonFromSources([indexUrl]);
      if (indexData == null) continue;

      final files = (indexData['files'] as List?)?.cast<String>() ?? [];
      // ✅ 3 ملفات لكل قناة YouTube (جميعها نفس الـ categoryId)
      // .live.json / .videos.json / .shorts.json
      // + .youtube.json (القديم — فترة انتقالية)
      final youtubeFiles = files
          .where(
            (f) =>
                f.endsWith('.youtube.json') ||
                f.endsWith('.live.json') ||
                f.endsWith('.videos.json') ||
                f.endsWith('.shorts.json'),
          )
          .toList();
      if (youtubeFiles.isEmpty) continue;

      debugPrint('🎥 [$sourceKey] ${youtubeFiles.length} YouTube file(s) in index');

      // 2) لكل ملف YouTube، حمّله وادمج
      for (final file in youtubeFiles) {
        final url = '$baseUrl$file';
        final data = await _fetchJsonFromSources([url]);
        if (data == null) continue;

        final cats = _parseJson(data);
        if (cats.isEmpty) continue;
        final youTubeCat = cats.first;

        // 3) ادمج مع الكاتيغوري الموجودة (نفس الـ id)
        // 3 ملفات (live/videos/shorts) لها نفس الـ id → concatenate items
        final idx = _liveList.indexWhere((c) => c.id == youTubeCat.id);
        if (idx < 0) {
          _liveList.add(youTubeCat);
          _trimIfNeeded();
          totalAdded += youTubeCat.items.length;
          await _cacheYouTubeCategory(youTubeCat.id);
        } else {
          final existing = _liveList[idx];
          final nonYouTubeItems = existing.items
              .where((i) => !_isYouTubeGroupItem(i))
              .toList();
          final existingYouTubeGroups = existing.items
              .where((i) => _isYouTubeGroupItem(i))
              .toList();

          final mergedGroups = <RecitationItem>[];
          for (final newGroup in youTubeCat.items) {
            final oldGroup = existingYouTubeGroups.firstWhere(
              (g) => g.emoji == newGroup.emoji,
              orElse: () => newGroup,
            );
            final mergedSubs = _mergeGroupSubItems(
              oldSubItems: (oldGroup.emoji == newGroup.emoji)
                  ? (oldGroup.subItems ?? const [])
                  : const [],
              newSubItems: newGroup.subItems ?? const [],
            );
            mergedGroups.add(RecitationItem(
              title: newGroup.title,
              subtitle: newGroup.subtitle,
              emoji: newGroup.emoji,
              imageUrl: newGroup.imageUrl,
              audioUrl: newGroup.audioUrl,
              subItems: mergedSubs,
            ));
          }
          // احتفظ بمجموعات يوتيوب القديمة التي ليس لها نظير في الجديد
          for (final oldGroup in existingYouTubeGroups) {
            final hasMatch = youTubeCat.items.any((g) => g.emoji == oldGroup.emoji);
            if (!hasMatch) mergedGroups.add(oldGroup);
          }

          final combined = <RecitationItem>[...mergedGroups, ...nonYouTubeItems];
          _liveList[idx] = RecitationCategory(
            id: existing.id,
            title: existing.title,
            emoji: existing.emoji,
            description: existing.description,
            gradientColors: existing.gradientColors,
            imageUrl: existing.imageUrl,
            items: combined,
          );
          totalAdded += youTubeCat.items.length;
          await _cacheYouTubeCategory(existing.id);
        }

        if (!_streamController.isClosed) {
          _streamController.add(List.unmodifiable(_liveList));
        }
        debugPrint('🎥 [$sourceKey] ${youTubeCat.id} (+${youTubeCat.items.length} group) ← $file');
      }
    }
    return totalAdded > 0;
  }

  // هل الـ item هو مجموعة YouTube (تحتوي subItems مع videoSource=youtube)؟
  static bool _isYouTubeGroupItem(RecitationItem item) {
    if (item.videoSource == VideoSource.youtube) return true;
    return item.subItems?.any((s) => s.videoSource == VideoSource.youtube) ??
        false;
  }

  // جلب JSON من قائمة URLs (الأول ينجح يكفي)
  static Future<Map<String, dynamic>?> _fetchJsonFromSources(
    List<String> urls,
  ) async {
    // ✅ cache-busting: timestamp فريد لكل طلب
    final cb = DateTime.now().millisecondsSinceEpoch;
    for (final url in urls) {
      try {
        final sep = url.contains('?') ? '&' : '?';
        final response = await http
            .get(
          Uri.parse('$url${sep}t=$cb'),
          headers: {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          debugPrint('  ✓ YouTube fetch OK: $url');
          return decoded;
        }
      } catch (e) {
        debugPrint('  ✗ YouTube fetch fail: $url ($e)');
        // تخطي — جرب المصدر التالي
      }
    }
    return null;
  }

  // ══════════════════════════════════════════════════════
  // Force refresh — يجلب YouTube الآن (يتجاوز الـ cooldown)
  // يرجع true لو تم جلب عنصر واحد على الأقل، false في حالة الفشل الكامل
  // ══════════════════════════════════════════════════════

  // عناوين manifest القنوات (يُستخدم للـ live refresh فقط)
  static const String _youTubeManifestUrl =
      'https://raw.githubusercontent.com/hozifa460/fatawa_database/refs/heads/main/radio_database/youtube_channels.json';
  static const String _gitLabYouTubeManifestUrl =
      'https://gitlab.com/hazozahz-islamway/hazozahz-islamway/-/raw/main/radio_islam/youtube_channels.json';

  // ✅ LIVE refresh — يجلب RSS لكل قناة في الـ manifest مباشرة
  // يُحدّث الكاتيغوريز في الذاكرة فوراً (لا يعتمد على CI)
  static Future<bool> _refreshLiveYouTube({int limit = 15}) async {
    var totalAdded = 0;

    // 1) اقرأ manifest (قائمة القنوات)
    final manifest = await _fetchJsonFromSources(
      [_youTubeManifestUrl, _gitLabYouTubeManifestUrl],
    );
    if (manifest == null) {
      debugPrint('❌ YouTube live: manifest not found');
      return false;
    }

    final channels = (manifest['channels'] as List?) ?? [];
    if (channels.isEmpty) {
      debugPrint('ℹ️  YouTube live: no channels in manifest');
      return false;
    }
    debugPrint('🎥 YouTube live: ${channels.length} channel(s) in manifest');

    // 2) لكل قناة: اجلب RSS مباشرة، حلّل، ادمج
    for (final raw in channels) {
      if (raw is! Map) continue;
      final ch = Map<String, dynamic>.from(raw);
      final categoryId = ch['categoryId']?.toString() ?? '';
      final channelId = ch['channelId']?.toString() ?? '';
      final channelName = ch['channelName']?.toString() ?? categoryId;

      if (categoryId.isEmpty ||
          channelId.isEmpty ||
          channelId.contains('xxxxx')) {
        debugPrint('⏭️  $categoryId: incomplete config, skipping');
        continue;
      }

      try {
        final rssUrl =
            'https://www.youtube.com/feeds/videos.xml?channel_id=$channelId';
        final cb = DateTime.now().millisecondsSinceEpoch;
        final response = await http
            .get(
          Uri.parse('$rssUrl&t=$cb'),
          headers: const {
            'Accept': 'application/atom+xml, application/xml, text/xml',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          debugPrint('❌ $categoryId: RSS fetch failed (${response.statusCode})');
          continue;
        }

        final items = parseYouTubeRss(
          xmlBody: response.body,
          channelName: channelName,
          limit: limit,
        );
        if (items.isEmpty) {
          debugPrint('⚠️  $categoryId: RSS returned 0 videos');
          continue;
        }

        // ادمج في الكاتيغوري (لكل نوع: live/videos/shorts على حدة)
        final idx = _liveList.indexWhere((c) => c.id == categoryId);
        if (idx < 0) {
          _liveList.add(
            RecitationCategory(
              id: categoryId,
              title: channelName,
              emoji: '🎥',
              description: 'فيديوهات يوتيوب',
              gradientColors: const [Color(0xFF8B0000), Color(0xFFFF6347)],
              items: items,
            ),
          );
          _trimIfNeeded();
          await _cacheYouTubeCategory(categoryId);
        } else {
          final existing = _liveList[idx];
          final nonYouTubeItems = existing.items
              .where((i) => !_isYouTubeGroupItem(i))
              .toList();

          final mergedGroups = <RecitationItem>[];
          for (final newGroup in items) {
            final oldGroup = existing.items.firstWhere(
              (i) => _isYouTubeGroupItem(i) && i.emoji == newGroup.emoji,
              orElse: () => newGroup, // fallback إذا ما في old
            );
            final mergedSubs = _mergeGroupSubItems(
              oldSubItems: (oldGroup.emoji == newGroup.emoji)
                  ? (oldGroup.subItems ?? const [])
                  : const [],
              newSubItems: newGroup.subItems ?? const [],
            );
            mergedGroups.add(RecitationItem(
              title: newGroup.title,
              subtitle: newGroup.subtitle,
              emoji: newGroup.emoji,
              imageUrl: newGroup.imageUrl,
              audioUrl: newGroup.audioUrl,
              subItems: mergedSubs,
            ));
          }

          final combined = <RecitationItem>[...mergedGroups, ...nonYouTubeItems];
          _liveList[idx] = RecitationCategory(
            id: existing.id,
            title: existing.title,
            emoji: existing.emoji,
            description: existing.description,
            gradientColors: existing.gradientColors,
            imageUrl: existing.imageUrl,
            items: combined,
          );
          await _cacheYouTubeCategory(existing.id);
        }
        if (!_streamController.isClosed) {
          _streamController.add(List.unmodifiable(_liveList));
        }
        final newSubCount = items.fold<int>(
            0, (acc, g) => acc + (g.subItems?.length ?? 0));
        final totalSubCount = idx >= 0
            ? _liveList[idx].items.fold<int>(
                0, (acc, g) => acc + (g.subItems?.length ?? 0))
            : newSubCount;
        totalAdded += newSubCount;
        debugPrint(
          '🎥 $categoryId: +$newSubCount new, total now $totalSubCount across ${items.length} group(s)',
        );
      } catch (e) {
        debugPrint('❌ $categoryId: live fetch exception: $e');
      }
    }

    if (totalAdded > 0) {
      debugPrint('✅ YouTube live: $totalAdded videos added across ${channels.length} channel(s)');
    }
    return totalAdded > 0;
  }

  static Future<bool> forceRefreshYouTube() async {
    debugPrint('🔄 YouTube force refresh requested (live mode)');
    _lastYouTubeSync = null;
    final ok = await _refreshLiveYouTube();
    debugPrint(
        ok ? '✅ YouTube force refresh done' : '❌ YouTube force refresh failed (no items)');
    return ok;
  }
}