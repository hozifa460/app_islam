import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A reading is a self-contained text/layout edition.  It must never share
/// Hafs page numbers or audio metadata, because those are edition-specific.
enum QuranReading { hafs, warshAnNafiAzraq }

extension QuranReadingInfo on QuranReading {
  String get id => switch (this) {
    QuranReading.hafs => 'hafs-an-asim',
    QuranReading.warshAnNafiAzraq => 'warsh-an-nafi-tariq-al-azraq',
  };

  String get label => switch (this) {
    QuranReading.hafs => 'حفص عن عاصم',
    QuranReading.warshAnNafiAzraq => 'ورش عن نافع — طريق الأزرق',
  };

  int get pageCount => switch (this) {
    QuranReading.hafs => 604,
    QuranReading.warshAnNafiAzraq => 603,
  };

  bool get supportsHafsAudio => this == QuranReading.hafs;

  static QuranReading fromId(String? id) =>
      id == QuranReading.warshAnNafiAzraq.id
          ? QuranReading.warshAnNafiAzraq
          : QuranReading.hafs;
}

class QuranReadingService {
  static const _warshAsset = 'assets/json/quran_warsh_nafi_text_pages.v1.json';
  static List<String>? _warshPages;

  static bool isReady(QuranReading reading) =>
      reading == QuranReading.hafs || _warshPages != null;

  static Future<bool> ensureLoaded(QuranReading reading) async {
    if (reading == QuranReading.hafs) return true;
    if (_warshPages != null) return true;
    try {
      final decoded = jsonDecode(await rootBundle.loadString(_warshAsset));
      if (decoded is! Map<String, dynamic> ||
          decoded['reading'] != QuranReading.warshAnNafiAzraq.id ||
          decoded['pageCount'] != QuranReading.warshAnNafiAzraq.pageCount ||
          decoded['pages'] is! List) {
        return false;
      }
      final pages = (decoded['pages'] as List)
          .whereType<String>()
          .map(_sanitizeWarshPage)
          .toList(growable: false);
      if (pages.length != QuranReading.warshAnNafiAzraq.pageCount ||
          pages.any((page) => page.isEmpty)) {
        return false;
      }
      _warshPages = pages;
      return true;
    } catch (error, stackTrace) {
      debugPrint('Warsh reading asset error: $error\n$stackTrace');
      return false;
    }
  }

  static String? pageText(QuranReading reading, int page) {
    if (reading != QuranReading.warshAnNafiAzraq ||
        page < 1 ||
        page > QuranReading.warshAnNafiAzraq.pageCount) {
      return null;
    }
    final pages = _warshPages;
    return pages == null ? null : pages[page - 1];
  }

  /// The source contains typographic stop symbols (not Qur'anic text). A few
  /// Android fonts draw them as solid black circles. Keep only the two marks
  /// that the reader renders itself: rubʿ al-hizb and place of sajdah.
  static String _sanitizeWarshPage(String page) =>
      String.fromCharCodes(
        page.runes.where(
          (rune) =>
              rune < 0x06D6 ||
              rune > 0x06ED ||
              rune == 0x06DE ||
              rune == 0x06E9,
        ),
      ).trim();
}
