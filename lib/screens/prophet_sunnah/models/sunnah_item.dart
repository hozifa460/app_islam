class SunnahItem {
  final int id;
  final String title;
  final String description;
  final String hadith;
  final String source;
  final String hadithNumber;
  final String narrator;
  final String authenticity;

  SunnahItem({
    required this.id,
    required this.title,
    required this.description,
    required this.hadith,
    required this.source,
    required this.hadithNumber,
    required this.narrator,
    required this.authenticity,
  });

  factory SunnahItem.fromJson(Map<String, dynamic> json) {
    return SunnahItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      hadith: json['hadith'],
      source: json['source'],
      hadithNumber: json['hadith_number'],
      narrator: json['narrator'],
      authenticity: json['authenticity'],
    );
  }
}