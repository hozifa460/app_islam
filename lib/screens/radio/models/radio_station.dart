// lib/screens/radio/models/radio_station.dart

import 'package:flutter/material.dart';

class IslamicRadioStation {
  final int id;
  final String name;
  final String nameEn;
  final String url;
  final String category;
  final String categoryEn;
  final String description;
  final String descriptionEn;
  final String iconEmoji;
  final Color? accentColor;
  final String? streamBaseUrl;    // للاستماع أونلاين بدون تحميل ← جديد

  // ══ رابط تحميل التلاوات (mp3quran.net) ══
  final String? downloadBaseUrl;
  // عدد السور المتاحة للشيخ
  final int surahCount;

  // ══ الصور - يدعم المسار المحلي أو رابط الإنترنت ══
  final String? imageUrl;      // رابط إنترنت
  final String? imageAsset;

  const IslamicRadioStation({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.url,
    required this.category,
    required this.categoryEn,
    required this.description,
    required this.descriptionEn,
    required this.iconEmoji,
    this.accentColor,
    this.downloadBaseUrl,
    this.surahCount = 114, this.imageUrl, this.imageAsset, this.streamBaseUrl,
  });

  bool get supportsStream => streamBaseUrl != null;  // ← جديد

  // رابط استماع سورة معينة أونلاين
  String? surahStreamUrl(int surahNumber) {
    if (streamBaseUrl == null) return null;
    final num = surahNumber.toString().padLeft(3, '0');
    return '$streamBaseUrl/$num.mp3';
  }

  // رابط تحميل سورة معينة
  String? surahUrl(int surahNumber) {
    if (downloadBaseUrl == null) return null;
    final num = surahNumber.toString().padLeft(3, '0');
    return '$downloadBaseUrl/$num.mp3';
  }

  /// هل تحتوي على صورة؟
  bool get hasImage => imageUrl != null || imageAsset != null;

  /// هل الصورة من الإنترنت؟
  bool get isNetworkImage =>
      imageUrl != null &&
          imageUrl!.isNotEmpty &&
          (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  // هل يدعم التحميل؟
  bool get supportsDownload => downloadBaseUrl != null;


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameEn': nameEn,
    'url': url,
    'category': category,
    'categoryEn': categoryEn,
    'description': description,
    'descriptionEn': descriptionEn,
    'iconEmoji': iconEmoji,
    'downloadBaseUrl': downloadBaseUrl,
    'surahCount': surahCount,
  };

  factory IslamicRadioStation.fromJson(Map<String, dynamic> json) {
    return IslamicRadioStation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      categoryEn: json['categoryEn'] ?? '',
      description: json['description'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '📻',
      imageUrl: json['imageUrl'],
      imageAsset: json['imageAsset'],
      streamBaseUrl: json['streamBaseUrl'],
      downloadBaseUrl: json['downloadBaseUrl'],
      surahCount: json['surahCount'] ?? 114,
    );
  }
}