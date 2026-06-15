class DeedModel {
  final String title;
  final String reward;
  final String hadith;
  final String source;
  final String type;
  final String icon;
  final int target;
  final int color;
  final int? hasanaValue;

  DeedModel({
    required this.title,
    required this.reward,
    required this.hadith,
    required this.source,
    required this.type,
    required this.icon,
    required this.target,
    required this.color,
    this.hasanaValue,
  });

  factory DeedModel.fromJson(Map<String, dynamic> json) {
    return DeedModel(
      title: json['title'] as String,
      reward: json['reward'] as String,
      hadith: json['hadith'] as String,
      source: json['source'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      target: json['target'] as int,
      color: int.parse(json['color'] as String),
      hasanaValue: json['hasanaValue'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'reward': reward,
      'hadith': hadith,
      'source': source,
      'type': type,
      'icon': icon,
      'target': target,
      'color': '0x${color.toRadixString(16).toUpperCase()}',
      if (hasanaValue != null) 'hasanaValue': hasanaValue,
    };
  }
}