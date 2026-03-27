import 'dart:convert';
import 'package:flutter/services.dart';

class GreatMuslim {
  final String id;
  final String name;
  final String title;
  final String category;
  final String desc;
  final String details;
  final String quote;
  final List<String> achievements;
  final String image;
  final String era;
  final String birthYear;
  final String deathYear;
  final bool featured;

  const GreatMuslim({
    required this.id,
    required this.name,
    required this.title,
    required this.category,
    required this.desc,
    required this.details,
    required this.quote,
    required this.achievements,
    required this.image,
    required this.era,
    required this.birthYear,
    required this.deathYear,
    required this.featured,
  });

  factory GreatMuslim.fromJson(Map<String, dynamic> json) {
    return GreatMuslim(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      desc: json['desc'] ?? '',
      details: json['details'] ?? '',
      quote: json['quote'] ?? '',
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      image: json['image'] ?? '',
      era: json['era'] ?? '',
      birthYear: json['birthYear'] ?? '',
      deathYear: json['deathYear'] ?? '',
      featured: json['featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'category': category,
    'desc': desc,
    'details': details,
    'quote': quote,
    'achievements': achievements,
    'image': image,
    'era': era,
    'birthYear': birthYear,
    'deathYear': deathYear,
    'featured': featured,
  };

  /// للتوافق مع الكود القديم الذي يستخدم Map<String, String>
  Map<String, String> toOldMap() => {
    'name': name,
    'title': title,
    'desc': desc,
    'details': details,
    'quote': quote,
    'achievements': achievements.map((e) => '• $e').join('\n'),
    'image': image,
  };
}

class GreatMuslimsService {
  static List<GreatMuslim>? _cache;

  static Future<List<GreatMuslim>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/json/great_muslims.json');
    final List<dynamic> data = json.decode(jsonString);

    _cache = data.map((e) => GreatMuslim.fromJson(e)).toList();
    return _cache!;
  }

  static void clearCache() => _cache = null;

  static List<GreatMuslim> filterByCategory(
      List<GreatMuslim> list,
      String category,
      ) {
    if (category == 'الكل') return list;
    return list.where((p) => p.category == category).toList();
  }

  static List<GreatMuslim> search(
      List<GreatMuslim> list,
      String query,
      ) {
    if (query.isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.title.toLowerCase().contains(q) ||
          p.desc.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.era.toLowerCase().contains(q);
    }).toList();
  }

  static List<GreatMuslim> getFeatured(List<GreatMuslim> list) {
    return list.where((p) => p.featured).toList();
  }

  static List<String> getCategories(List<GreatMuslim> list) {
    final cats = list.map((p) => p.category).toSet().toList();
    return ['الكل', ...cats];
  }
}