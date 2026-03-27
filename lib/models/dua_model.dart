class DuaCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final List<Dua> duas;

  DuaCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.duas,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'favorite',
      color: json['color'] ?? '#E6B325',
      duas: (json['duas'] as List<dynamic>?)
          ?.map((d) => Dua.fromJson(d))
          .toList() ??
          [],
    );
  }
}

class Dua {
  final String title;
  final String text;
  final String source;
  final String reward;

  Dua({
    required this.title,
    required this.text,
    required this.source,
    required this.reward,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      source: json['source'] ?? '',
      reward: json['reward'] ?? '',
    );
  }
}