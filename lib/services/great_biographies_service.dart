import 'dart:convert';
import 'package:flutter/services.dart';

// ==========================================================
// ======================== MODELS ==========================
// ==========================================================

class BiographySource {
  final String name;
  final String author;
  final String? volume;
  final String? page;
  final String? hadithNumber;
  final String? type;
  final String? description;

  BiographySource({
    required this.name,
    required this.author,
    this.volume,
    this.page,
    this.hadithNumber,
    this.type,
    this.description,
  });

  factory BiographySource.fromJson(Map<String, dynamic> json) {
    return BiographySource(
      name: json['name']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      volume: json['volume']?.toString(),
      page: json['page']?.toString(),
      hadithNumber: json['hadithNumber']?.toString(),
      type: json['type']?.toString(),
      description: json['description']?.toString(),
    );
  }

  String get fullReference {
    final parts = <String>[name];
    if (author.isNotEmpty) parts.add('- $author');
    if (volume != null && volume!.isNotEmpty) parts.add('(جـ$volume)');
    if (page != null && page!.isNotEmpty) parts.add('ص$page');
    if (hadithNumber != null && hadithNumber!.isNotEmpty) parts.add('حديث $hadithNumber');
    return parts.join(' ');
  }
}

class BiographySection {
  final String title;
  final String content;
  final List<BiographySource> sources;

  BiographySection({
    required this.title,
    required this.content,
    required this.sources,
  });

  factory BiographySection.fromJson(Map<String, dynamic> json) {
    return BiographySection(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      sources: (json['sources'] as List? ?? [])
          .map((e) => BiographySource.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class BiographyQuote {
  final String text;
  final String source;

  BiographyQuote({required this.text, required this.source});

  factory BiographyQuote.fromJson(Map<String, dynamic> json) {
    return BiographyQuote(
      text: json['text']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }
}

class GreatPersonBiography {
  final int id;
  final String name;
  final String fullName;
  final String title;
  final String category;
  final String era;
  final String? birthYear;
  final String? deathYear;
  final String? birthPlace;
  final String? deathPlace;
  final String image;
  final String shortDesc;
  final String intro;
  final List<BiographySection> sections;
  final List<String> achievements;
  final List<BiographyQuote> quotes;
  final List<BiographyQuote> virtues;
  final List<BiographySource> mainSources;
  final List<int> relatedPersons;

  GreatPersonBiography({
    required this.id,
    required this.name,
    required this.fullName,
    required this.title,
    required this.category,
    required this.era,
    this.birthYear,
    this.deathYear,
    this.birthPlace,
    this.deathPlace,
    required this.image,
    required this.shortDesc,
    required this.intro,
    required this.sections,
    required this.achievements,
    required this.quotes,
    required this.virtues,
    required this.mainSources,
    required this.relatedPersons,
  });

  factory GreatPersonBiography.fromJson(Map<String, dynamic> json) {
    final bio = Map<String, dynamic>.from(json['biography'] ?? {});
    return GreatPersonBiography(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      era: json['era']?.toString() ?? '',
      birthYear: json['birthYear']?.toString(),
      deathYear: json['deathYear']?.toString(),
      birthPlace: json['birthPlace']?.toString(),
      deathPlace: json['deathPlace']?.toString(),
      image: json['image']?.toString() ?? '',
      shortDesc: json['shortDesc']?.toString() ?? '',
      intro: bio['intro']?.toString() ?? '',
      sections: (bio['sections'] as List? ?? [])
          .map((e) => BiographySection.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      achievements: (json['achievements'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      quotes: (json['quotes'] as List? ?? [])
          .map((e) => BiographyQuote.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      virtues: (json['virtues'] as List? ?? [])
          .map((e) => BiographyQuote.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      mainSources: (json['mainSources'] as List? ?? [])
          .map((e) => BiographySource.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      relatedPersons: (json['relatedPersons'] as List? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e != 0)
          .toList(),
    );
  }

  int get totalSourcesCount {
    int count = mainSources.length;
    count += quotes.length;
    count += virtues.length;
    for (final s in sections) {
      count += s.sources.length;
    }
    return count;
  }

  String get lifeSpan {
    final b = birthYear ?? '';
    final d = deathYear ?? '';
    if (b.isEmpty && d.isEmpty) return '';
    if (b.isEmpty) return 'ت $d';
    if (d.isEmpty) return 'و $b';
    return '$b - $d';
  }
}

// ==========================================================
// ======================== SERVICE =========================
// ==========================================================

class GreatBiographiesService {
  static List<GreatPersonBiography>? _cache;
  static String _version = '';
  static String _lastUpdated = '';

  static String get version => _version;
  static String get lastUpdated => _lastUpdated;

  static Future<List<GreatPersonBiography>> load() async {
    if (_cache != null) return _cache!;

    try {
      final raw = await rootBundle.loadString('assets/json/siar_greats.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      _version = decoded['version']?.toString() ?? '';
      _lastUpdated = decoded['lastUpdated']?.toString() ?? '';

      final persons = (decoded['persons'] as List? ?? [])
          .map((e) => GreatPersonBiography.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _cache = persons;
      return persons;
    } catch (e) {
      return [];
    }
  }

  static void clearCache() {
    _cache = null;
  }

  static List<String> getCategories(List<GreatPersonBiography> persons) {
    return ['الكل', ...persons.map((e) => e.category).toSet().toList()];
  }

  static List<GreatPersonBiography> filterByCategory(
      List<GreatPersonBiography> persons,
      String category,
      ) {
    if (category == 'الكل') return persons;
    return persons.where((p) => p.category == category).toList();
  }

  static List<GreatPersonBiography> search(
      List<GreatPersonBiography> persons,
      String query,
      ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return persons;
    return persons.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.fullName.toLowerCase().contains(q) ||
          p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.era.toLowerCase().contains(q) ||
          p.shortDesc.toLowerCase().contains(q);
    }).toList();
  }

  static GreatPersonBiography? getById(List<GreatPersonBiography> persons, int id) {
    try {
      return persons.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GreatPersonBiography> getRelated(
      List<GreatPersonBiography> persons,
      GreatPersonBiography current,
      ) {
    return current.relatedPersons
        .map((id) => getById(persons, id))
        .whereType<GreatPersonBiography>()
        .toList();
  }
}