import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../models/fatwa_model.dart';
import 'gemini_service.dart';

class LocalSearchService {
  static final List<Fatwa> _fatawa = [];
  static final Set<String> _fatwaKeys = <String>{};
  static final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);
  static final ValueNotifier<int> remoteRevision = ValueNotifier<int>(0);
  static final Map<String, RemoteFileProgress> _remoteProgress = {};
  static final Set<String> _hydratedRemoteFiles = <String>{};
  static final Set<String> _pausedRemoteFiles = <String>{};
  static String? _priorityRemoteFile;
  static String? _activeRemoteFile;
  static int _remoteNotifyCounter = 0;
  static bool _loaded = false;
  static Future<void>? _loadingFuture;
  static Future<void>? _gitLabFuture;
  static Timer? _sourceRefreshTimer;
  static List<Fatwa> get allFatawa => List.unmodifiable(_fatawa);
  static List<RemoteFileProgress> get remoteFiles =>
      List.unmodifiable(_remoteProgress.values.toList());

  static Future<void> loadFatawa() {
    if (_loaded) {
      _startGitLabLoad();
      return Future.value();
    }
    final pending = _loadingFuture;
    if (pending != null) return pending;
    final future = _loadFatawa();
    _loadingFuture = future;
    future.whenComplete(() {
      if (identical(_loadingFuture, future)) _loadingFuture = null;
    });
    return future;
  }

  static Future<void> _loadFatawa() async {
    if (_loaded) return;

    try {
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      // 1. ظ…ط­ط§ظˆظ„ط© ظ‚ط±ط§ط،ط© ط§ظ„ظپظ‡ط±ط³
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      try {
        final indexJson = await rootBundle.loadString(
          'assets/fatawa/fatawa_index.json',
        );
        final indexData = jsonDecode(indexJson);
        final files = List<String>.from(indexData['files']);

        debugPrint('📂 تم العثور على ${files.length} ملف فتاوى');

        // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
        // 2. ظ‚ط±ط§ط،ط© ظƒظ„ ظ…ظ„ظپ
        // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
        for (final fileName in files) {
          try {
            final filePath = 'assets/fatawa/$fileName';
            final fileJson = await rootBundle.loadString(filePath);
            final fileData = await compute(_decodeJson, fileJson);

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // 3. ط¯ط¹ظ… ط´ظƒظ„ظٹظ† ظ…ظ† ط§ظ„ط¨ظٹط§ظ†ط§طھ
            // ط§ظ„ط´ظƒظ„ 1: {"fatawa": [...], "source": "..."}
            // ط§ظ„ط´ظƒظ„ 2: ظ…طµظپظˆظپط© ظ…ط¨ط§ط´ط±ط© [...]
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            List rawFatawa;
            String defaultSource;
            String defaultScholar;

            if (fileData is List) {
              // ط§ظ„ظ…ظ„ظپ ط¹ط¨ط§ط±ط© ط¹ظ† ظ…طµظپظˆظپط© ظ…ط¨ط§ط´ط±ط©
              rawFatawa = fileData;
              defaultSource = fileName
                  .replaceAll('.json', '')
                  .replaceAll('fatawa_', '');
              defaultScholar = defaultSource;
            } else if (fileData is Map) {
              // ط§ظ„ظ…ظ„ظپ ط¹ط¨ط§ط±ط© ط¹ظ† ظƒط§ط¦ظ† ظپظٹظ‡ ظ…طµظپظˆظپط© fatawa
              rawFatawa = fileData['fatawa'] as List? ?? [];
              defaultSource = fileData['source']?.toString() ?? fileName;
              defaultScholar = fileData['scholar']?.toString() ?? defaultSource;
            } else {
              debugPrint('  ⚠️ شكل غير معروف في $fileName');
              continue;
            }

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // 4. طھط­ظˆظٹظ„ ظƒظ„ ظپطھظˆظ‰ ظˆط¥ط¶ط§ظپط© ط§ظ„ظ‚ظٹظ… ط§ظ„ط§ظپطھط±ط§ط¶ظٹط©
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            int count = 0;
            for (final rawFatwa in rawFatawa) {
              if (rawFatwa is! Map<String, dynamic>) continue;

              // المعرّفات داخل ملفات المصادر تبدأ غالباً من 1. اجعلها
              // فريدة على مستوى القاعدة حتى لا تستبدل نتيجة مصدرٍ نتيجة مصدر آخر.
              final rawId = rawFatwa['id']?.toString().trim();
              rawFatwa['id'] =
                  '$fileName::${rawId?.isNotEmpty == true ? rawId : count + 1}';

              // ط¥ط¶ط§ظپط© ط§ظ„ظ…طµط¯ط± ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['source'] == null ||
                  rawFatwa['source'].toString().isEmpty) {
                rawFatwa['source'] = defaultSource;
              }

              // ط¥ط¶ط§ظپط© ط§ظ„ط¹ط§ظ„ظ… ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['scholar'] == null ||
                  rawFatwa['scholar'].toString().isEmpty) {
                rawFatwa['scholar'] = defaultScholar;
              }

              // ط¥ط¶ط§ظپط© ط§ظ„ظƒطھط§ط¨ ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['book'] == null ||
                  rawFatwa['book'].toString().isEmpty) {
                rawFatwa['book'] = defaultSource;
              }

              // طھط­ظˆظٹظ„ link ط¥ظ„ظ‰ url ط¥ط°ط§ ظ„ظ… ظٹظƒظ† url ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['url'] == null ||
                      rawFatwa['url'].toString().isEmpty) &&
                  rawFatwa['link'] != null) {
                rawFatwa['url'] = rawFatwa['link'];
              }

              // طھط­ظˆظٹظ„ title ط¥ظ„ظ‰ question ط¥ط°ط§ ظ„ظ… ظٹظƒظ† question ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['question'] == null ||
                      rawFatwa['question'].toString().isEmpty) &&
                  rawFatwa['title'] != null) {
                rawFatwa['question'] = rawFatwa['title'];
              }

              // ط§ط³طھط®ط±ط§ط¬ category ظ…ظ† categories ط¥ط°ط§ ظ„ظ… ظٹظƒظ† ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['category'] == null ||
                      rawFatwa['category'].toString().isEmpty) &&
                  rawFatwa['categories'] != null) {
                final cats = rawFatwa['categories'];
                if (cats is List && cats.isNotEmpty) {
                  rawFatwa['category'] = cats.first.toString();
                }
              }

              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              // 5. طھط­ظˆظٹظ„ ط¥ظ„ظ‰ ظƒط§ط¦ظ† Fatwa
              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              try {
                final fatwa = Fatwa.fromJson(rawFatwa);

                // طھط¬ط§ظ‡ظ„ ط§ظ„ظپطھط§ظˆظ‰ ط§ظ„ظپط§ط±ط؛ط© ط£ظˆ ط§ظ„ظ‚طµظٹط±ط© ط¬ط¯ط§ظ‹
                if (fatwa.question.length > 5 && fatwa.answer.length > 20) {
                  _addFatwa(fatwa);
                  count++;
                }
              } catch (e) {
                // طھط¬ط§ظ‡ظ„ ط§ظ„ظپطھظˆظ‰ ط§ظ„طھظٹ ظپط´ظ„ طھط­ظˆظٹظ„ظ‡ط§
                continue;
              }
            }

            debugPrint('  ✅ $fileName: $count فتوى ($defaultSource)');
          } catch (e) {
            debugPrint('  ⚠️ تعذر قراءة $fileName: $e');
          }
        }

        // مصدر GitLab مجاني ومتكامل، ويُستخدم بعد البيانات المضمنة مع
        // إزالة الفتاوى المطابقة حتى لا تتضاعف النتائج.
        _startGitLabLoad();

        _loaded = true;
        dataRevision.value++;
        debugPrint('📊 إجمالي الفتاوى المحملة: ${_fatawa.length}');
        return;
      } catch (e) {
        debugPrint('⚠️ لم يتم العثور على fatawa_index.json: $e');
      }

      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      // 6. Fallback: ظ‚ط±ط§ط،ط© ط§ظ„ظ…ظ„ظپ ط§ظ„ظ‚ط¯ظٹظ… ط§ظ„ظ…ظˆط­ط¯
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      try {
        debugPrint('🔄 محاولة تحميل fatawa.json القديم...');
        final json = await rootBundle.loadString(
          'assets/fatawa/fatawa_main.json',
        );
        final data = await compute(_decodeJson, json);

        List rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          rawList = data['fatawa'] as List? ?? [];
        } else {
          rawList = [];
        }

        for (final rawFatwa in rawList) {
          if (rawFatwa is! Map<String, dynamic>) continue;

          final rawId = rawFatwa['id']?.toString().trim();
          rawFatwa['id'] =
              'fatawa_main.json::${rawId?.isNotEmpty == true ? rawId : _fatawa.length + 1}';

          // ظ†ظپط³ ط§ظ„طھط­ظˆظٹظ„ط§طھ
          if ((rawFatwa['url'] == null || rawFatwa['url'].toString().isEmpty) &&
              rawFatwa['link'] != null) {
            rawFatwa['url'] = rawFatwa['link'];
          }
          if ((rawFatwa['question'] == null ||
                  rawFatwa['question'].toString().isEmpty) &&
              rawFatwa['title'] != null) {
            rawFatwa['question'] = rawFatwa['title'];
          }
          if ((rawFatwa['category'] == null ||
                  rawFatwa['category'].toString().isEmpty) &&
              rawFatwa['categories'] != null) {
            final cats = rawFatwa['categories'];
            if (cats is List && cats.isNotEmpty) {
              rawFatwa['category'] = cats.first.toString();
            }
          }

          try {
            final fatwa = Fatwa.fromJson(rawFatwa);
            if (fatwa.question.length > 5 && fatwa.answer.length > 20) {
              _addFatwa(fatwa);
            }
          } catch (_) {
            continue;
          }
        }

        _loaded = true;
        dataRevision.value++;
        debugPrint('📊 Fallback: ${_fatawa.length} فتوى');
      } catch (e) {
        debugPrint('❌ فشل تحميل fatawa.json: $e');
      }
    } catch (e) {
      debugPrint('❌ خطأ عام في loadFatawa: $e');
    }
    _startGitLabLoad();
  }

  static const String _gitLabIndexUrl =
      'https://gitlab.com/hazozahz-islamway/hazozahz-islamway/-/raw/main/fatawa/indexf.json?ref_type=heads';
  static const String _gitLabRawBase =
      'https://gitlab.com/hazozahz-islamway/hazozahz-islamway/-/raw/main/fatawa/';
  static const String _gitHubIndexUrl =
      'https://raw.githubusercontent.com/hozifa460/fatawa_database/refs/heads/main/fatawa_bibaz/fatawa_index.json';
  static const String _gitHubRawBase =
      'https://raw.githubusercontent.com/hozifa460/fatawa_database/main/fatawa_bibaz/';
  static bool _gitLabLoaded = false;

  static void _startGitLabLoad() {
    if (_gitLabLoaded || _gitLabFuture != null) return;
    final future = _loadGitLabFatawa();
    _gitLabFuture = future;
    future.whenComplete(() {
      if (identical(_gitLabFuture, future)) _gitLabFuture = null;
      _sourceRefreshTimer?.cancel();
      _sourceRefreshTimer = Timer(const Duration(minutes: 15), () {
        _gitLabLoaded = false;
        _startGitLabLoad();
      });
    });
  }

  static Future<void> refreshRemoteSources() async {
    final running = _gitLabFuture;
    if (running != null) await running;
    _gitLabLoaded = false;
    _startGitLabLoad();
    final refreshed = _gitLabFuture;
    if (refreshed != null) await refreshed;
  }

  /// إيقاف ملف بعينه مع الاحتفاظ بالجزء الذي تم تنزيله ليُستأنف لاحقاً.
  static Future<void> pauseRemoteFile(String progressKey) async {
    _pausedRemoteFiles.add(progressKey);
    final current = _remoteProgress[progressKey];
    if (current != null && current.status != 'مكتمل') {
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: current.fileName,
          status: 'متوقف مؤقتاً',
          downloadedBytes: current.downloadedBytes,
          totalBytes: current.totalBytes,
          parsedCount: current.parsedCount,
        ),
      );
    }
  }

  /// بدء/استئناف ملف محدد، مع إعطائه أولوية في دورة التنزيل التالية.
  static Future<void> startRemoteFile(String progressKey) async {
    final active = _activeRemoteFile;
    if (active != null && active != progressKey) {
      _pausedRemoteFiles.add(active);
      final activeProgress = _remoteProgress[active];
      if (activeProgress != null) {
        _setRemoteProgress(
          RemoteFileProgress(
            fileName: active,
            status: 'متوقف مؤقتاً',
            downloadedBytes: activeProgress.downloadedBytes,
            totalBytes: activeProgress.totalBytes,
            parsedCount: activeProgress.parsedCount,
          ),
        );
      }
    }
    _pausedRemoteFiles.remove(progressKey);
    _priorityRemoteFile = progressKey;
    final current = _remoteProgress[progressKey];
    if (current != null && current.status != 'مكتمل') {
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: current.fileName,
          status: 'استئناف',
          downloadedBytes: current.downloadedBytes,
          totalBytes: current.totalBytes,
          parsedCount: current.parsedCount,
        ),
      );
    }
    _gitLabLoaded = false;
    _startGitLabLoad();
  }

  static Future<void> resumeRemoteFile(String progressKey) =>
      startRemoteFile(progressKey);

  static Future<void> _loadGitLabFatawa() async {
    if (_gitLabLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${appDir.path}/fatwa_remote');
      await cacheDir.create(recursive: true);
      var processed = 0;
      var allCompleted = true;
      final sources = <_RemoteSourceConfig>[
        const _RemoteSourceConfig(
          id: 'gitlab',
          label: 'GitLab',
          indexUrl: _gitLabIndexUrl,
          rawBase: _gitLabRawBase,
        ),
        const _RemoteSourceConfig(
          id: 'github',
          label: 'GitHub',
          indexUrl: _gitHubIndexUrl,
          rawBase: _gitHubRawBase,
        ),
      ];

      // اقرأ فهارس جميع المصادر أولاً. بذلك تظهر ملفات GitHub في زر المصادر
      // فوراً، ولا تنتظر انتهاء تنزيل ملفات GitLab السابقة لها.
      final filesBySource = <String, List<String>>{};
      for (final source in sources) {
        final files = await _loadRemoteIndex(source, prefs);
        filesBySource[source.id] = files;
        if (files.isEmpty) {
          allCompleted = false;
          continue;
        }
        for (final filePath in files) {
          final progressKey = '${source.label}::$filePath';
          final safeName = progressKey.replaceAll(
            RegExp(r'[^a-zA-Z0-9._-]'),
            '_',
          );
          final prefix = 'fatwa_remote_${safeName}_';
          _setRemoteProgress(
            RemoteFileProgress(
              fileName: progressKey,
              status:
                  _pausedRemoteFiles.contains(progressKey)
                      ? 'متوقف مؤقتاً'
                      : 'في الانتظار',
              downloadedBytes: prefs.getInt('${prefix}downloaded') ?? 0,
              totalBytes: prefs.getInt('${prefix}total') ?? 0,
              parsedCount: prefs.getInt('${prefix}count') ?? 0,
            ),
          );
        }
      }

      for (final source in sources) {
        final files = filesBySource[source.id] ?? const <String>[];
        final orderedFiles = [...files];
        final priorityIndex = orderedFiles.indexWhere(
          (filePath) => '${source.label}::$filePath' == _priorityRemoteFile,
        );
        if (priorityIndex > 0) {
          final priorityFile = orderedFiles.removeAt(priorityIndex);
          orderedFiles.insert(0, priorityFile);
        }
        for (final filePath in orderedFiles) {
          final progressKey = '${source.label}::$filePath';
          if (_pausedRemoteFiles.contains(progressKey)) continue;
          _activeRemoteFile = progressKey;
          try {
            processed += await _downloadRemoteFile(
              source,
              filePath,
              cacheDir,
              prefs,
            );
          } finally {
            if (_activeRemoteFile == progressKey) _activeRemoteFile = null;
          }
        }
        allCompleted =
            allCompleted &&
            files.every((filePath) {
              return _remoteProgress['${source.label}::$filePath']?.status ==
                  'مكتمل';
            });
      }
      _priorityRemoteFile = null;

      _gitLabLoaded = allCompleted;
      remoteRevision.value++;
      debugPrint('📊 عولج من المصادر البعيدة: $processed فتوى');
    } catch (e) {
      debugPrint('⚠️ تعذر الوصول إلى المصادر البعيدة: $e');
    }
  }

  static Future<List<String>> _loadRemoteIndex(
    _RemoteSourceConfig source,
    SharedPreferences prefs,
  ) async {
    var files = <String>[];
    final cacheKey = 'fatwa_remote_${source.id}_files';
    try {
      final response = await http
          .get(Uri.parse(source.indexUrl))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final indexData = jsonDecode(response.body);
        if (indexData is Map && indexData['files'] is List) {
          files = List<String>.from(indexData['files']);
          await prefs.setStringList(cacheKey, files);
        }
      } else {
        debugPrint('⚠️ ${source.label} index status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ تعذر تحديث فهرس ${source.label}: $e');
    }
    return files.isNotEmpty
        ? files
        : prefs.getStringList(cacheKey) ?? <String>[];
  }

  static Future<int> _downloadRemoteFile(
    _RemoteSourceConfig source,
    String filePath,
    Directory cacheDir,
    SharedPreferences prefs,
  ) async {
    final progressKey = '${source.label}::$filePath';
    final safeName = progressKey.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final partFile = File('${cacheDir.path}/$safeName.part');
    final prefix = 'fatwa_remote_${safeName}_';
    var downloaded = 0;
    var parsedBytes = 0;
    var parsedCount = 0;
    var totalBytes = prefs.getInt('${prefix}total') ?? 0;

    if (_pausedRemoteFiles.contains(progressKey)) {
      final current = _remoteProgress[progressKey];
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: 'متوقف مؤقتاً',
          downloadedBytes: current?.downloadedBytes ?? 0,
          totalBytes: current?.totalBytes ?? totalBytes,
          parsedCount: current?.parsedCount ?? 0,
        ),
      );
      return 0;
    }

    if (await partFile.exists()) {
      downloaded = await partFile.length();
    }

    _setRemoteProgress(
      RemoteFileProgress(
        fileName: progressKey,
        status: downloaded > 0 ? 'استئناف' : 'في الانتظار',
        downloadedBytes: downloaded,
        totalBytes: totalBytes,
        parsedCount: prefs.getInt('${prefix}count') ?? 0,
      ),
    );

    if (_hydratedRemoteFiles.contains(progressKey) &&
        totalBytes > 0 &&
        downloaded >= totalBytes) {
      final count = prefs.getInt('${prefix}count') ?? 0;
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: 'مكتمل',
          downloadedBytes: downloaded,
          totalBytes: totalBytes,
          parsedCount: count,
        ),
      );
      return count;
    }

    final parser = RemoteFatwaStreamParser(
      parsedBytes: parsedBytes,
      onObject: (raw) {
        final fatwa = _fatwaFromRemote(
          raw,
          progressKey,
          source.label,
          parsedCount + 1,
        );
        if (fatwa == null) return;
        parsedCount++;
        _addFatwa(fatwa, notify: true);
        _setRemoteProgress(
          RemoteFileProgress(
            fileName: progressKey,
            status: 'يتم التحميل',
            downloadedBytes: downloaded,
            totalBytes: totalBytes,
            parsedCount: parsedCount,
          ),
        );
      },
    );

    if (await partFile.exists() && downloaded > 0) {
      await for (final chunk in partFile.openRead().transform(utf8.decoder)) {
        parser.add(chunk);
      }
      parsedBytes = parser.parsedBytes;
      await prefs.setInt('${prefix}parsed', parsedBytes);
      await prefs.setInt('${prefix}count', parsedCount);
    }

    if (totalBytes > 0 && downloaded >= totalBytes) {
      _hydratedRemoteFiles.add(progressKey);
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: 'مكتمل',
          downloadedBytes: downloaded,
          totalBytes: totalBytes,
          parsedCount: parsedCount,
        ),
      );
      dataRevision.value++;
      return parsedCount;
    }

    final request = http.Request(
      'GET',
      Uri.parse('${source.rawBase}$filePath'),
    );
    if (downloaded > 0) request.headers['Range'] = 'bytes=$downloaded-';
    final client = http.Client();
    try {
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 416 && downloaded > 0) {
        _setRemoteProgress(
          RemoteFileProgress(
            fileName: progressKey,
            status: 'مكتمل',
            downloadedBytes: downloaded,
            totalBytes: totalBytes > 0 ? totalBytes : downloaded,
            parsedCount: parsedCount,
          ),
        );
        return parsedCount;
      }
      if (downloaded > 0 && response.statusCode != 206) {
        await partFile.writeAsBytes(const <int>[]);
        downloaded = 0;
        parsedBytes = 0;
        parsedCount = 0;
        parser.reset();
      }
      if (response.statusCode != 200 && response.statusCode != 206) {
        _setRemoteProgress(
          RemoteFileProgress(
            fileName: progressKey,
            status: 'متوقف مؤقتاً',
            downloadedBytes: downloaded,
            totalBytes: totalBytes,
            parsedCount: parsedCount,
          ),
        );
        return 0;
      }

      final contentLength = int.tryParse(
        response.headers['content-length'] ?? '',
      );
      if (contentLength != null) {
        totalBytes =
            response.statusCode == 206
                ? downloaded + contentLength
                : contentLength;
      }
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: downloaded > 0 ? 'استئناف' : 'يتم التحميل',
          downloadedBytes: downloaded,
          totalBytes: totalBytes,
          parsedCount: parsedCount,
        ),
      );

      final sink = partFile.openWrite(
        mode: downloaded > 0 ? FileMode.append : FileMode.write,
      );
      var paused = false;
      try {
        await for (final chunk in response.stream
            .transform(utf8.decoder)
            .timeout(const Duration(seconds: 45))) {
          sink.write(chunk);
          await sink.flush();
          downloaded += utf8.encode(chunk).length;
          parser.add(chunk);
          parsedBytes = parser.parsedBytes;
          await prefs.setInt('${prefix}downloaded', downloaded);
          await prefs.setInt('${prefix}parsed', parsedBytes);
          await prefs.setInt('${prefix}count', parsedCount);
          await prefs.setInt('${prefix}total', totalBytes);
          if (_pausedRemoteFiles.contains(progressKey)) {
            paused = true;
            break;
          }
          _setRemoteProgress(
            RemoteFileProgress(
              fileName: progressKey,
              status: 'يتم التحميل',
              downloadedBytes: downloaded,
              totalBytes: totalBytes,
              parsedCount: parsedCount,
            ),
          );
        }
      } finally {
        await sink.close();
      }

      if (paused || _pausedRemoteFiles.contains(progressKey)) {
        await prefs.setInt('${prefix}downloaded', downloaded);
        await prefs.setInt('${prefix}parsed', parsedBytes);
        await prefs.setInt('${prefix}count', parsedCount);
        await prefs.setInt('${prefix}total', totalBytes);
        _setRemoteProgress(
          RemoteFileProgress(
            fileName: progressKey,
            status: 'متوقف مؤقتاً',
            downloadedBytes: downloaded,
            totalBytes: totalBytes,
            parsedCount: parsedCount,
          ),
        );
        return parsedCount;
      }

      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: 'مكتمل',
          downloadedBytes: downloaded,
          totalBytes: totalBytes,
          parsedCount: parsedCount,
        ),
      );
      _hydratedRemoteFiles.add(progressKey);
      dataRevision.value++;
      return parsedCount;
    } catch (e) {
      _setRemoteProgress(
        RemoteFileProgress(
          fileName: progressKey,
          status: 'متوقف مؤقتاً',
          downloadedBytes: downloaded,
          totalBytes: totalBytes,
          parsedCount: parsedCount,
        ),
      );
      debugPrint('⚠️ توقف تحميل $progressKey عند $downloaded بايت: $e');
      _hydratedRemoteFiles.add(progressKey);
      dataRevision.value++;
      return 0;
    } finally {
      client.close();
    }
  }

  static Fatwa? _fatwaFromRemote(
    Map<String, dynamic> value,
    String progressKey,
    String sourceLabel,
    int index,
  ) {
    final raw = Map<String, dynamic>.from(value);
    final source = '$sourceLabel: ${progressKey.split('/').last}';
    final rawId = raw['id']?.toString().trim();
    raw['id'] =
        'remote:$progressKey::${rawId?.isNotEmpty == true ? rawId : index}';
    raw['source'] =
        raw['source']?.toString().trim().isNotEmpty == true
            ? raw['source']
            : source;
    raw['scholar'] =
        raw['scholar']?.toString().trim().isNotEmpty == true
            ? raw['scholar']
            : source;
    raw['book'] =
        raw['book']?.toString().trim().isNotEmpty == true
            ? raw['book']
            : source;
    if ((raw['url'] == null || raw['url'].toString().trim().isEmpty) &&
        raw['link'] != null) {
      raw['url'] = raw['link'];
    }
    if ((raw['question'] == null ||
            raw['question'].toString().trim().isEmpty) &&
        raw['title'] != null) {
      raw['question'] = raw['title'];
    }
    if ((raw['category'] == null ||
            raw['category'].toString().trim().isEmpty) &&
        raw['categories'] is List &&
        (raw['categories'] as List).isNotEmpty) {
      raw['category'] = (raw['categories'] as List).first.toString();
    }
    try {
      final fatwa = Fatwa.fromJson(raw);
      return fatwa.question.length > 5 && fatwa.answer.length > 20
          ? fatwa
          : null;
    } catch (_) {
      return null;
    }
  }

  static void _setRemoteProgress(RemoteFileProgress progress) {
    _remoteProgress[progress.fileName] = progress;
    remoteRevision.value++;
  }

  static void _addFatwa(Fatwa fatwa, {bool notify = false}) {
    final key =
        fatwa.url.trim().isNotEmpty
            ? 'url:${fatwa.url.trim()}'
            : 'text:${_normalize(fatwa.question)}|${_normalize(fatwa.answer)}';
    if (_fatwaKeys.add(key)) {
      _fatawa.add(fatwa);
      if (notify) {
        _remoteNotifyCounter++;
        if (_remoteNotifyCounter == 1 || _remoteNotifyCounter % 25 == 0) {
          dataRevision.value++;
        }
      }
    }
  }

  static Future<ChatMessage> search(
    String userQuestion, {
    List<Fatwa>? fatawa,
  }) async {
    await loadFatawa();
    final corpus = fatawa != null && fatawa.isNotEmpty ? fatawa : _fatawa;

    if (corpus.isEmpty) {
      return ChatMessage.fromAssistantText('لم يتم تحميل قاعدة الفتاوى.');
    }

    final queries = await GeminiService.generateSearchQueries(userQuestion);
    final results = _searchLocal(queries, corpus);

    if (results.isEmpty) {
      return ChatMessage.fromAssistantText(
        'لم أجد فتوى مطابقة لسؤالك.\n\n'
        '💡 جرب صياغة مختلفة أو اسأل أهل العلم.\n\nجزاك الله خيراً 🤲',
      );
    }

    final bySource = _groupBySource(results);

    if (bySource.length == 1) {
      return await _buildResponse(userQuestion, bySource.first, []);
    }

    return ChatMessage.chooseSource(sources: bySource);
  }

  static List<_Scored> _searchLocal(List<String> queries, List<Fatwa> corpus) {
    final scores = <String, _Scored>{};

    for (final query in queries) {
      final words = _tokenize(query);
      final normalized = _normalize(query);

      for (final fatwa in corpus) {
        final score = _calcScore(fatwa, words, normalized);
        if (score > 5) {
          if (!scores.containsKey(fatwa.id) ||
              score > scores[fatwa.id]!.score) {
            scores[fatwa.id] = _Scored(fatwa: fatwa, score: score);
          }
        }
      }
    }

    return scores.values.toList()..sort((a, b) => b.score.compareTo(a.score));
  }

  static double _calcScore(Fatwa fatwa, List<String> words, String fullQuery) {
    final q = _normalize(fatwa.question);
    final t = _normalize(fatwa.title);
    final a = _normalize(fatwa.answer);
    final k = fatwa.keywords.map(_normalize).join(' ');
    final c = fatwa.categories.map(_normalize).join(' ');
    double score = 0;
    int matched = 0;

    // طھط·ط§ط¨ظ‚ ط§ظ„ط¹ط¨ط§ط±ط© ط§ظ„ظƒط§ظ…ظ„ط©
    if (q.contains(fullQuery)) score += 25;
    if (t.contains(fullQuery)) score += 20;

    for (final w in words) {
      if (w.length < 2) continue;
      bool found = false;

      // ط§ظ„ط³ط¤ط§ظ„ (ط£ظ‡ظ… ط´ظٹط،)
      if (q.contains(w)) {
        score += 8;
        found = true;
      }

      // ط§ظ„ط¹ظ†ظˆط§ظ†
      if (t.contains(w)) {
        score += 7;
        found = true;
      }

      // ط§ظ„طھطµظ†ظٹظپط§طھ
      if (c.contains(w)) {
        score += 6;
        found = true;
      }

      // ط§ظ„ظƒظ„ظ…ط§طھ ط§ظ„ظ…ظپطھط§ط­ظٹط©
      if (k.contains(w)) {
        score += 5;
        found = true;
      }

      // ط§ظ„ط¬ظˆط§ط¨
      if (a.contains(w)) {
        score += 3;
        found = true;
      }

      // ط¨ط­ط« ط¨ط§ظ„ط¬ط°ط±
      if (!found && w.length >= 4) {
        final root = w.substring(0, 4);
        if (q.contains(root) || t.contains(root)) {
          score += 3;
          found = true;
        } else if (a.contains(root)) {
          score += 1;
          found = true;
        }
      }

      if (found) matched++;
    }

    // ظ…ظƒط§ظپط£ط© ظ†ط³ط¨ط© ط§ظ„طھط·ط§ط¨ظ‚
    if (words.isNotEmpty) {
      final ratio = matched / words.length;
      if (ratio >= 0.8) {
        score += 15;
      } else if (ratio >= 0.6) {
        score += 10;
      } else if (ratio >= 0.4) {
        score += 5;
      } else if (ratio < 0.2) {
        score -= 5;
      }
    }

    return score;
  }

  static List<SourceOption> _groupBySource(List<_Scored> results) {
    final map = <String, _Scored>{};
    for (final r in results.take(15)) {
      final src = r.fatwa.book;
      if (!map.containsKey(src) || r.score > map[src]!.score) {
        map[src] = r;
      }
    }

    return map.entries.map((e) {
        final f = e.value.fatwa;
        return SourceOption(
          sourceName: f.book,
          title: f.question,
          answer: f.answer,
          url: f.id,
          relevance: e.value.score,
          fatwa: f,
        );
      }).toList()
      ..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  static Future<ChatMessage> _buildResponse(
    String question,
    SourceOption option,
    List<SourceOption> others,
  ) async {
    String answer = option.answer;
    try {
      answer = await GeminiService.summarizeFatwa(
        userQuestion: question,
        fatwaText: option.answer,
        source: option.sourceName,
      );
    } catch (_) {}

    return ChatMessage.fromAssistantWithSource(
      introText:
          'وجدت لك الجواب من ${option.sourceName}:\n\n📖 ${option.title}',
      fatwa: option.fatwa,
      extractedAnswer: answer,
      confidence: AnswerConfidence.high,
      otherSources: others,
    );
  }

  static Future<ChatMessage> onSourceSelected(
    String question,
    SourceOption selected,
    List<SourceOption> all,
  ) async {
    final others =
        all.where((o) => o.sourceName != selected.sourceName).toList();
    return await _buildResponse(question, selected, others);
  }

  static String _normalize(String t) =>
      t
          .toLowerCase()
          .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
          .replaceAll('ى', 'ي')
          .replaceAll('ة', 'ه')
          .replaceAll('ؤ', 'و')
          .replaceAll('ئ', 'ي')
          .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
          .replaceAll(
            RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF0-9\s]'),
            ' ',
          )
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  static List<String> _tokenize(String t) {
    const stop = {
      'هل',
      'ما',
      'من',
      'في',
      'على',
      'عن',
      'يجوز',
      'حكم',
      'كيف',
      'ظ‡ظˆ',
      'هي',
      'ان',
      'كان',
      'لا',
      'لم',
      'قد',
      'الله',
      'رسول',
      'النبي',
      'صلى',
      'عليه',
      'وسلم',
      'الى',
      'مع',
      'هذا',
      'هذه',
      'بين',
      'عند',
    };
    return _normalize(t)
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stop.contains(w))
        .toList();
  }
}

dynamic _decodeJson(String source) => jsonDecode(source);

class _RemoteSourceConfig {
  final String id;
  final String label;
  final String indexUrl;
  final String rawBase;

  const _RemoteSourceConfig({
    required this.id,
    required this.label,
    required this.indexUrl,
    required this.rawBase,
  });
}

class RemoteFileProgress {
  final String fileName;
  final String status;
  final int downloadedBytes;
  final int totalBytes;
  final int parsedCount;

  const RemoteFileProgress({
    required this.fileName,
    required this.status,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.parsedCount,
  });

  double get fraction =>
      totalBytes <= 0 ? 0 : (downloadedBytes / totalBytes).clamp(0.0, 1.0);

  String get sourceName =>
      fileName.contains('::')
          ? fileName.substring(0, fileName.indexOf('::'))
          : 'مصدر بعيد';

  String get displayName => fileName.split('::').last.split('/').last;
}

@visibleForTesting
class RemoteFatwaStreamParser {
  final void Function(Map<String, dynamic> value) onObject;
  String _buffer = '';
  int parsedBytes;
  bool _inString = false;
  bool _escaped = false;
  int _depth = 0;
  int _objectStart = -1;
  int _scanIndex = 0;

  RemoteFatwaStreamParser({required this.parsedBytes, required this.onObject});

  void add(String chunk) {
    if (chunk.isEmpty) return;
    _buffer += chunk;
    _drain();
  }

  void reset() {
    _buffer = '';
    _inString = false;
    _escaped = false;
    _depth = 0;
    _objectStart = -1;
    _scanIndex = 0;
    parsedBytes = 0;
  }

  void _drain() {
    if (_objectStart < 0) {
      _objectStart = _buffer.indexOf('{');
      if (_objectStart < 0) {
        _scanIndex = 0;
        return;
      }
      _scanIndex = _objectStart;
    }

    for (var i = _scanIndex; i < _buffer.length; i++) {
      final char = _buffer[i];
      if (_inString) {
        if (_escaped) {
          _escaped = false;
        } else if (char == r'\') {
          _escaped = true;
        } else if (char == '"') {
          _inString = false;
        }
        continue;
      }
      if (char == '"') {
        _inString = true;
      } else if (char == '{') {
        _depth++;
      } else if (char == '}') {
        _depth--;
        if (_depth == 0) {
          final end = i + 1;
          final objectText = _buffer.substring(_objectStart, end);
          final consumedText = _buffer.substring(0, end);
          _buffer = _buffer.substring(end);
          _objectStart = -1;
          _scanIndex = 0;
          _inString = false;
          _escaped = false;
          parsedBytes += utf8.encode(consumedText).length;
          try {
            final value = jsonDecode(objectText);
            if (value is Map) {
              onObject(Map<String, dynamic>.from(value));
            }
          } catch (_) {
            // لا نوقف الملف كله بسبب سجل واحد غير صالح.
          }
          _drain();
          return;
        }
      }
    }
    _scanIndex = _buffer.length;
  }
}

class _Scored {
  final Fatwa fatwa;
  final double score;
  const _Scored({required this.fatwa, required this.score});
}
