class TasbihModel {
  final String text;
  final int target;
  final String translation;
  final String transliteration;

  TasbihModel({
    required this.text,
    required this.target,
    required this.translation,
    required this.transliteration,
  });

  factory TasbihModel.fromJson(Map<String, dynamic> json) {
    return TasbihModel(
      text: json['text'] as String,
      target: json['target'] as int,
      translation: json['translation'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'target': target,
      'translation': translation,
      'transliteration': transliteration,
    };
  }
}