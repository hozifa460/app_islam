import 'package:islamic_app/screens/prophet_sunnah/models/sunnah_item.dart';

class SunnahCategory {
  final int id;
  final String name;
  final String icon;
  final String color;
  final List<SunnahItem> sunnahs;

  SunnahCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.sunnahs,
  });

  factory SunnahCategory.fromJson(Map<String, dynamic> json) {
    return SunnahCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      sunnahs: (json['sunnahs'] as List)
          .map((e) => SunnahItem.fromJson(e))
          .toList(),
    );
  }
}