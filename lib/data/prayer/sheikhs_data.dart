class SheikhAdhan {
  final String id;          // unique
  final String name;
  final String url;         // direct mp3/stream
  final String description;
  final String imageUrl;    // background image for card (optional)

  const SheikhAdhan({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl,
  });
}

/// عدّل هنا وأضف روابطك أنت
const sheikhsAdhanData = <SheikhAdhan>[
  SheikhAdhan(
    id: 'sheikh_sudais',
    name: 'عبدالرحمن السديس',
    url: 'https://example.com/sudais.mp3',
    description: 'الحرم المكي',
    imageUrl: 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=800',
  ),
  SheikhAdhan(
    id: 'sheikh_sary',
    name: 'عبدالمجيد السريح',
    url: 'https://example.com/sary.mp3',
    description: 'الحرم المدني',
    imageUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=800',
  ),
];