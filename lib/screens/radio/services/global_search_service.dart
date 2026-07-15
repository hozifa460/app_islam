// lib/screens/radio/widgets_recitations_screen/services/global_search_service.dart

import 'package:islamic_app/screens/radio/data/quran_data.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/radio_data.dart';

// ══ أنواع النتائج ══
enum SearchResultType {
  reciter,      // قارئ
  surah,        // سورة لقارئ معين
  category,     // قسم (حفلات، تلاوات خاشعة...)
  subItem,      // تلاوة مفردة (حفلة، تلاوة...)
  subSection,   // قسم فرعي داخل تلاوات متعددة
  radioStation, // محطة راديو
}

class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String emoji;
  final String? imageUrl;

  // ══ بيانات للتنقل ══
  final IslamicRadioStation? station;        // للقارئ أو المحطة
  final SurahModel? surah;                   // للسورة
  final RecitationItem? recitationItem;      // للتلاوة
  final RecitationCategory? category;        // للقسم
  final RecitationSubItem? subItem;          // للعنصر الفرعي
  final RecitationItem? parentItem;          // الأب (للعناصر الفرعية)
  final int? surahNumber;                    // رقم السورة

  static bool _cacheReady = false;
  static bool _recentLoaded = false;

  static late final List<IslamicRadioStation> _recitersCache;
  static late final List<IslamicRadioStation> _radioStationsOnlyCache;
  static late final List<SurahModel> _surahsCache;

  const SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.imageUrl,
    this.station,
    this.surah,
    this.recitationItem,
    this.category,
    this.subItem,
    this.parentItem,
    this.surahNumber,
  });

  // ══ لون حسب النوع ══
  String get typeLabel {
    switch (type) {
      case SearchResultType.reciter:
        return 'قارئ';
      case SearchResultType.surah:
        return 'سورة';
      case SearchResultType.category:
        return 'قسم';
      case SearchResultType.subItem:
        return 'تلاوة';
      case SearchResultType.subSection:
        return 'مجموعة';
      case SearchResultType.radioStation:
        return 'محطة';
    }
  }
}

class GlobalSearchService {
  GlobalSearchService._();

  // ══════════════════════════════════════════════════════
  // Cache
  // ══════════════════════════════════════════════════════
  static bool _cacheReady = false;
  static bool _recentLoaded = false;

  static late final List<IslamicRadioStation> _recitersCache;
  static late final List<IslamicRadioStation> _radioStationsOnlyCache;
  static late final List<SurahModel> _surahsCache;

  static List<SearchResult> search(
      String query, {
        List<RecitationCategory>? categories,
      }) {
    _ensureCache();

    final q = _normalize(query);
    if (q.isEmpty) return [];

    final results = <SearchResult>[];
    final seen = <String>{};

    void addResult(SearchResult result) {
      final key = '${result.type}_${result.title}_${result.subtitle}';
      if (seen.add(key)) {
        results.add(result);
      }
    }

    // ══ 1. بحث في القراء ══
    _searchReciters(q, results);

    // ══ 2. بحث في السور ══
    _searchSurahs(q, results);

    // ══ 3. بحث في أقسام التلاوات ══
    if (categories != null) {
      _searchCategories(q, categories, results);
    }

    // ══ 4. بحث في محطات الراديو ══
    _searchRadioStations(q, results);

    _searchJuz(q, results);

    // في search() أضف ترتيباً بعد جمع النتائج:
    results.sort((a, b) {
      // القراء أولاً
      if (a.type == SearchResultType.reciter) return -1;
      if (b.type == SearchResultType.reciter) return 1;
      // ثم السور
      if (a.type == SearchResultType.surah) return -1;
      if (b.type == SearchResultType.surah) return 1;
      return 0;
    });

    if (results.length > 50) {
      return results.sublist(0, 50);
    }

    return results;
  }

  static void _searchJuz(String q, List<SearchResult> results) {
    // بحث بالرقم
    final num = int.tryParse(q);
    if (num != null && num >= 1 && num <= 30) {
      final juz = QuranData.juzByNumber(num);
      results.add(SearchResult(
        type: SearchResultType.category,
        title: juz.name,
        subtitle: 'من سورة ${QuranData.surahByNumber(juz.startSurah).name} إلى ${QuranData.surahByNumber(juz.endSurah).name}',
        emoji: '📚',
      ));
    }

    // بحث بالاسم
    if (q.contains('جزء') || q.contains('عم') || q.contains('تبارك')) {
      for (final juz in QuranData.juzList) {
        if (juz.name.toLowerCase().contains(q)) {
          results.add(SearchResult(
            type: SearchResultType.category,
            title: juz.name,
            subtitle: 'من سورة ${QuranData.surahByNumber(juz.startSurah).name} إلى ${QuranData.surahByNumber(juz.endSurah).name}',
            emoji: '📚',
          ));
        }
      }
    }
  }

  // ══ بحث في القراء ══
  static void _searchReciters(String q, List<SearchResult> results) {
    for (final station in _recitersCache) {
      if (_containsNormalized(station.name, q) ||
          _containsNormalized(station.nameEn, q) ||
          _containsNormalized(station.description, q)) {
        results.add(SearchResult(
          type: SearchResultType.reciter,
          title: station.name,
          subtitle: station.description,
          emoji: station.iconEmoji,
          imageUrl: station.imageUrl,
          station: station,
        ));
      }
    }
  }

  // ══ بحث في السور ══
  static void _searchSurahs(String q, List<SearchResult> results) {
    final reciters = _recitersCache;

    for (final surah in _surahsCache) {
      if (_containsNormalized(surah.name, q) ||
          _containsNormalized(surah.nameEn, q)) {
        // أضف نتيجة واحدة للسورة مع أول قارئ
        if (reciters.isNotEmpty) {
          results.add(SearchResult(
            type: SearchResultType.surah,
            title: 'سورة ${surah.name}',
            subtitle:
            '${surah.versesCount} آية • ${surah.isMakki ? "مكية" : "مدنية"} • الجزء ${surah.juzNumber}',
            emoji: '📖',
            surah: surah,
            surahNumber: surah.number,
            station: reciters.first,
          ));
        }
      }
    }
    // في _searchSurahs أضف:
    if (int.tryParse(q) != null) {
      final num = int.parse(q);
      if (num >= 1 && num <= 114) {
        final surah = QuranData.surahByNumber(num);
        results.add(SearchResult(
          type: SearchResultType.surah,
          title: 'سورة ${surah.name} - رقم $num',
          subtitle: '${surah.versesCount} آية',
          emoji: '📖',
          surah: surah,
          surahNumber: num,
          station: reciters.first,
        ));
      }
    }
    // في _searchSurahs أضف:
    if (q == 'مكية' || q == 'مكي') {
      for (final surah in QuranData.surahs.where((s) => s.isMakki)) {
        results.add(SearchResult(
          type: SearchResultType.surah,
          title: 'سورة ${surah.name}',
          subtitle: 'مكية • ${surah.versesCount} آية',
          emoji: '📖',
          surah: surah,
          surahNumber: surah.number,
          station: reciters.isNotEmpty ? reciters.first : null,
        ));
      }
    } else if (q == 'مدنية' || q == 'مدني') {
      for (final surah in QuranData.surahs.where((s) => !s.isMakki)) {
        results.add(SearchResult(
          type: SearchResultType.surah,
          title: 'سورة ${surah.name}',
          subtitle: 'مدنية • ${surah.versesCount} آية',
          emoji: '📖',
          surah: surah,
          surahNumber: surah.number,
          station: reciters.isNotEmpty ? reciters.first : null,
        ));
      }
    }
    // في _searchSurahs أضف:
    if (q.contains('جزء') || q.contains('عم') || q.contains('تبارك')) {
      int? juzNum;
      if (q.contains('عم') || q.contains('30')) juzNum = 30;
      if (q.contains('تبارك') || q.contains('29')) juzNum = 29;
      // أضف بقية الأجزاء...

      if (juzNum != null) {
        final surahsInJuz = QuranData.surahsByJuz(juzNum);
        for (final surah in surahsInJuz) {
          results.add(SearchResult(
            type: SearchResultType.surah,
            title: 'سورة ${surah.name}',
            subtitle: 'الجزء $juzNum • ${surah.versesCount} آية',
            emoji: '📚',
            surah: surah,
            surahNumber: surah.number,
            station: reciters.isNotEmpty ? reciters.first : null,
          ));
        }
      }
    }

    // في _searchSurahs
// المستخدم يكتب "العفاسي الفاتحة"

    final words = q.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      // ابحث عن قارئ + سورة
      IslamicRadioStation? matchedReciter;
      SurahModel? matchedSurah;

      for (final word in words) {
        // بحث في القراء
        for (final r in reciters) {
          if (r.name.toLowerCase().contains(word)) {
            matchedReciter = r;
            break;
          }
        }
        // بحث في السور
        for (final s in QuranData.surahs) {
          if (s.name.toLowerCase().contains(word)) {
            matchedSurah = s;
            break;
          }
        }
      }

      if (matchedReciter != null && matchedSurah != null) {
        results.insert(
          0, // أضفها في البداية
          SearchResult(
            type: SearchResultType.surah,
            title: 'سورة ${matchedSurah.name} - ${matchedReciter.name}',
            subtitle:
            '${matchedSurah.versesCount} آية • بصوت ${matchedReciter.name}',
            emoji: matchedReciter.iconEmoji,
            surah: matchedSurah,
            surahNumber: matchedSurah.number,
            station: matchedReciter,
          ),
        );
      }
    }

  }

  // في GlobalSearchService أضف:
  static List<SearchResult> getInstantSuggestions(String firstChar) {
    if (firstChar.isEmpty) return [];

    return QuranData.surahs
        .where((s) => s.name.startsWith(firstChar))
        .take(5)
        .map((surah) => SearchResult(
      type: SearchResultType.surah,
      title: 'سورة ${surah.name}',
      subtitle: '${surah.versesCount} آية',
      emoji: '📖',
      surah: surah,
      surahNumber: surah.number,
    ))
        .toList();
  }

  static void _ensureCache() {
    if (_cacheReady) return;

    _recitersCache = RadioStationsData.all
        .where((s) => s.supportsDownload)
        .toList();

    _radioStationsOnlyCache = RadioStationsData.all
        .where((s) => !s.supportsDownload)
        .toList();

    _surahsCache = QuranData.surahs;

    _cacheReady = true;
  }

  static String _normalize(String input) {
    var text = input.trim().toLowerCase();

    // إزالة التشكيل
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // توحيد الهمزات
    text = text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    // توحيد الياء
    text = text.replaceAll('ى', 'ي');

    // تقليل المسافات
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  static bool _containsNormalized(String source, String query) {
    return _normalize(source).contains(query);
  }

  // ══ بحث في الأقسام والتلاوات ══
  static void _searchCategories(
      String q,
      List<RecitationCategory> categories,
      List<SearchResult> results,
      ) {
    for (final cat in categories) {
      // بحث في عنوان القسم
      if (_containsNormalized(cat.title, q) ||
          _containsNormalized(cat.description, q)) {
        results.add(SearchResult(
          type: SearchResultType.category,
          title: cat.title,
          subtitle: cat.description,
          emoji: cat.emoji,
          category: cat,
        ));
      }

      // بحث في عناصر القسم
      for (final item in cat.items) {
        if (_containsNormalized(item.title, q) ||
            _containsNormalized(item.subtitle, q)) {
          results.add(SearchResult(
            type: item.hasSubItems
                ? SearchResultType.subSection
                : SearchResultType.subItem,
            title: item.title,
            subtitle: '${cat.title} • ${item.subtitle}',
            emoji: item.emoji,
            imageUrl: item.imageUrl,
            recitationItem: item,
            station: item.station,
            category: cat,
          ));
        }

        // بحث في العناصر الفرعية
        for (final sub in item.allSubItems) {
          if (_containsNormalized(sub.title, q) ||
              _containsNormalized(sub.subtitle, q)) {
            results.add(SearchResult(
              type: SearchResultType.subItem,
              title: sub.title,
              subtitle: '${item.title} • ${sub.subtitle}',
              emoji: sub.emoji,
              imageUrl: sub.imageUrl ?? item.imageUrl,
              subItem: sub,
              parentItem: item,
            ));
          }
        }
      }
    }
  }

  // ══ بحث في محطات الراديو ══
  static void _searchRadioStations(
      String q, List<SearchResult> results) {
    for (final station in _radioStationsOnlyCache) {
      if (_containsNormalized(station.name, q) ||
          _containsNormalized(station.nameEn, q) ||
          _containsNormalized(station.category, q)) {
        results.add(SearchResult(
          type: SearchResultType.radioStation,
          title: station.name,
          subtitle: station.category,
          emoji: station.iconEmoji,
          imageUrl: station.imageUrl,
          station: station,
        ));
      }
    }
  }

  // ══ اقتراحات سريعة ══
  static List<String> getSuggestions() {
    return [
      'الفاتحة',
      'البقرة',
      'يس',
      'الكهف',
      'الرحمن',
      'الملك',
      'العفاسي',
      'السديس',
      'المنشاوي',
      'الحصري',
      'حفلات',
      'تلاوات خاشعة',
      'رقية',
      'الحرم المكي',
    ];
  }

  // ══ بحث أخير ══
  static List<String> _recentSearches = [];

  static List<String> get recentSearches => _recentSearches;

  static Future<void> initRecentSearches() async {
    if (_recentLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    _recentLoaded = true;
  }

  static Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    await initRecentSearches();

    _recentSearches.remove(q);
    _recentSearches.insert(0, q);

    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  static Future<List<String>> getRecentSearches() async {
    await initRecentSearches();
    return _recentSearches;
  }

  static Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }
}
