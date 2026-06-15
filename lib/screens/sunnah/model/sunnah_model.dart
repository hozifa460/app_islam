class SunnahModel {
  final int id;
  final String name;
  final String description;
  final String timeCategory;
  final String type;
  final int rakaat;
  final String importance;
  final String hadith;
  final String icon;
  final String color;
  final int startOffsetMinutes;
  final int endOffsetMinutes;
  bool isCompleted;

  SunnahModel({
    required this.id,
    required this.name,
    required this.description,
    required this.timeCategory,
    required this.type,
    required this.rakaat,
    required this.importance,
    required this.hadith,
    required this.icon,
    required this.color,
    required this.startOffsetMinutes,
    required this.endOffsetMinutes,
    this.isCompleted = false,
  });

  factory SunnahModel.fromJson(Map<String, dynamic> json) {
    return SunnahModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      timeCategory: json['time_category'],
      type: json['type'],
      rakaat: json['rakaat'],
      importance: json['importance'],
      hadith: json['hadith'],
      icon: json['icon'],
      color: json['color'],
      startOffsetMinutes: json['start_offset_minutes'],
      endOffsetMinutes: json['end_offset_minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'time_category': timeCategory,
      'type': type,
      'rakaat': rakaat,
      'importance': importance,
      'hadith': hadith,
      'icon': icon,
      'color': color,
      'start_offset_minutes': startOffsetMinutes,
      'end_offset_minutes': endOffsetMinutes,
      'is_completed': isCompleted,
    };
  }
}

class PrayerTimeCategory {
  final String key;
  final String label;
  final int approxHour;

  PrayerTimeCategory({
    required this.key,
    required this.label,
    required this.approxHour,
  });

  factory PrayerTimeCategory.fromJson(String key, Map<String, dynamic> json) {
    return PrayerTimeCategory(
      key: key,
      label: json['label'],
      approxHour: json['approx_hour'],
    );
  }
}