// lib/screens/radio/services/radio_download_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_station.dart';
import '../models/surah_model.dart';
import '../data/quran_data.dart';

enum DownloadStatus { notDownloaded, downloading, downloaded, error }

class SurahDownloadState {
  final int surahNumber;
  bool isDownloaded;
  bool isDownloading;

  SurahDownloadState({
    required this.surahNumber,
    this.isDownloaded = false,
    this.isDownloading = false,
  });
}

class StationDownloadInfo {
  final int stationId;
  DownloadStatus status;
  int downloadedCount;
  int totalToDownload;
  double progress;
  String? error;
  bool isCancelled;
  // السور المحملة فعلياً
  Set<int> downloadedSurahs;

  StationDownloadInfo({
    required this.stationId,
    this.status = DownloadStatus.notDownloaded,
    this.downloadedCount = 0,
    this.totalToDownload = 0,
    this.progress = 0,
    this.error,
    this.isCancelled = false,
    Set<int>? downloadedSurahs,
  }) : downloadedSurahs = downloadedSurahs ?? {};

  bool get hasDownloads => downloadedSurahs.isNotEmpty;
}

class RadioDownloadService extends ChangeNotifier {
  static final RadioDownloadService _instance =
  RadioDownloadService._internal();
  factory RadioDownloadService() => _instance;
  RadioDownloadService._internal();

  final Map<int, StationDownloadInfo> _downloadInfo = {};
  final Map<int, bool> _cancelFlags = {};

  StationDownloadInfo? getInfo(int stationId) => _downloadInfo[stationId];

  DownloadStatus getStatus(int stationId) =>
      _downloadInfo[stationId]?.status ?? DownloadStatus.notDownloaded;

  double getProgress(int stationId) =>
      _downloadInfo[stationId]?.progress ?? 0;

  bool isSurahDownloaded(int stationId, int surahNumber) =>
      _downloadInfo[stationId]?.downloadedSurahs.contains(surahNumber) ?? false;

  Set<int> getDownloadedSurahs(int stationId) =>
      _downloadInfo[stationId]?.downloadedSurahs ?? {};

  // ══ تهيئة ══
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('downloaded_stations') ?? [];

    for (final idStr in downloaded) {
      final id = int.tryParse(idStr);
      if (id == null) continue;

      final dir = await _getStationDir(id);
      if (!await dir.exists()) continue;

      final files = dir.listSync().whereType<File>().toList();
      final surahNumbers = <int>{};

      for (final file in files) {
        final name = file.path.split('/').last.replaceAll('.mp3', '');
        final num = int.tryParse(name);
        if (num != null) surahNumbers.add(num);
      }

      if (surahNumbers.isNotEmpty) {
        _downloadInfo[id] = StationDownloadInfo(
          stationId: id,
          status: DownloadStatus.downloaded,
          downloadedCount: surahNumbers.length,
          downloadedSurahs: surahNumbers,
          progress: 1.0,
        );
      }
    }
    notifyListeners();
  }

  // ══ تحميل سور محددة ══
  Future<void> downloadSurahs({
    required IslamicRadioStation station,
    required List<int> surahNumbers,
  }) async {
    if (station.downloadBaseUrl == null) return;

    // السور التي تحتاج تحميل فعلي (غير موجودة)
    final existing = getDownloadedSurahs(station.id);
    final toDownload =
    surahNumbers.where((n) => !existing.contains(n)).toList();

    if (toDownload.isEmpty) return;

    _cancelFlags[station.id] = false;

    // تحديث الحالة
    if (_downloadInfo[station.id] == null) {
      _downloadInfo[station.id] = StationDownloadInfo(
        stationId: station.id,
        downloadedSurahs: Set.from(existing),
      );
    }

    _downloadInfo[station.id]!.status = DownloadStatus.downloading;
    _downloadInfo[station.id]!.totalToDownload = toDownload.length;
    _downloadInfo[station.id]!.downloadedCount = 0;
    _downloadInfo[station.id]!.progress = 0;
    notifyListeners();

    try {
      final dir = await _getStationDir(station.id);
      if (!await dir.exists()) await dir.create(recursive: true);

      int done = 0;

      for (final surahNum in toDownload) {
        if (_cancelFlags[station.id] == true) {
          _downloadInfo[station.id]!.status =
          _downloadInfo[station.id]!.downloadedSurahs.isNotEmpty
              ? DownloadStatus.downloaded
              : DownloadStatus.notDownloaded;
          notifyListeners();
          return;
        }

        final url = station.surahUrl(surahNum);
        if (url == null) continue;

        final fileName = '${surahNum.toString().padLeft(3, '0')}.mp3';
        final file = File('${dir.path}/$fileName');

        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 60));

          if (response.statusCode == 200 &&
              response.bodyBytes.length > 1000) {
            await file.writeAsBytes(response.bodyBytes);
            _downloadInfo[station.id]!.downloadedSurahs.add(surahNum);
            done++;
          }
        } catch (e) {
          debugPrint('❌ سورة $surahNum: $e');
        }

        _downloadInfo[station.id]!.downloadedCount = done;
        _downloadInfo[station.id]!.progress = done / toDownload.length;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 150));
      }

      _downloadInfo[station.id]!.status =
      _downloadInfo[station.id]!.downloadedSurahs.isNotEmpty
          ? DownloadStatus.downloaded
          : DownloadStatus.error;

      await _saveDownloadedStation(station.id);
    } catch (e) {
      _downloadInfo[station.id]!.status = DownloadStatus.error;
      _downloadInfo[station.id]!.error = e.toString();
    }

    notifyListeners();
  }

  // ══ تحميل جزء كامل ══
  Future<void> downloadJuz({
    required IslamicRadioStation station,
    required int juzNumber,
  }) async {
    final juz = QuranData.juzByNumber(juzNumber);
    final surahsInJuz = QuranData.surahsByJuz(juzNumber);
    final surahNumbers = surahsInJuz.map((s) => s.number).toList();
    await downloadSurahs(station: station, surahNumbers: surahNumbers);
  }

  // ══ تحميل سورة واحدة ══
  Future<void> downloadSingleSurah({
    required IslamicRadioStation station,
    required int surahNumber,
  }) async {
    await downloadSurahs(
      station: station,
      surahNumbers: [surahNumber],
    );
  }

  // ══ حذف سورة واحدة ══
  Future<void> deleteSurah(int stationId, int surahNumber) async {
    try {
      final dir = await _getStationDir(stationId);
      final fileName = '${surahNumber.toString().padLeft(3, '0')}.mp3';
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) await file.delete();

      _downloadInfo[stationId]?.downloadedSurahs.remove(surahNumber);

      if (_downloadInfo[stationId]?.downloadedSurahs.isEmpty == true) {
        _downloadInfo[stationId]!.status = DownloadStatus.notDownloaded;
        await _removeDownloadedStation(stationId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ حذف سورة: $e');
    }
  }

  // ══ حذف كل التحميلات ══
  Future<void> deleteAllDownloads(int stationId) async {
    try {
      final dir = await _getStationDir(stationId);
      if (await dir.exists()) await dir.delete(recursive: true);
      _downloadInfo.remove(stationId);
      await _removeDownloadedStation(stationId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ حذف كل التحميلات: $e');
    }
  }

  void cancelDownload(int stationId) {
    _cancelFlags[stationId] = true;
  }

  // ══ الملفات المحملة ══
  Future<List<String>> getDownloadedPaths(int stationId) async {
    try {
      final dir = await _getStationDir(stationId);
      if (!await dir.exists()) return [];
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.mp3'))
          .toList();
      files.sort((a, b) => a.path.compareTo(b.path));
      return files.map((f) => f.path).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> getSurahPath(int stationId, int surahNumber) async {
    final dir = await _getStationDir(stationId);
    final fileName = '${surahNumber.toString().padLeft(3, '0')}.mp3';
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) return file.path;
    return null;
  }

  // ══ حجم التخزين ══
  Future<String> getStorageSize(int stationId) async {
    try {
      final dir = await _getStationDir(stationId);
      if (!await dir.exists()) return '0 MB';
      int total = 0;
      for (final file in dir.listSync().whereType<File>()) {
        total += await file.length();
      }
      if (total < 1024 * 1024) {
        return '${(total / 1024).toStringAsFixed(1)} KB';
      }
      return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }

  Future<Directory> _getStationDir(int stationId) async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}/radio_offline/$stationId');
  }

  Future<void> _saveDownloadedStation(int stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('downloaded_stations') ?? [];
    if (!list.contains(stationId.toString())) {
      list.add(stationId.toString());
      await prefs.setStringList('downloaded_stations', list);
    }
  }

  Future<void> _removeDownloadedStation(int stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('downloaded_stations') ?? [];
    list.remove(stationId.toString());
    await prefs.setStringList('downloaded_stations', list);
  }
}