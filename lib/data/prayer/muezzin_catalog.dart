import 'sheikhs_data.dart';

class MuezzinInfo {
  final String id;
  final String name;
  final String url;           // Online by default
  final String description;
  final String imageUrl;      // for cards

  const MuezzinInfo({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl,
  });
}

class MuezzinCategory {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // for category card
  final String? imageAsset; // for category card
  final List<MuezzinInfo> items;

  const MuezzinCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.items, this.imageAsset,
  });
}

/// الأقسام الأساسية (Online افتراضي)
final muezzinCatalog = <MuezzinCategory>[
  MuezzinCategory(
    id: 'haramain',
    name: 'أذان الحرمين',
    description: 'مكة والمدينة',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/makkah.jpeg',
    items: const [
      MuezzinInfo(
        id: 'haramain_1',
        name: 'مكة المكرمة (افتراضي)',
        url: 'https://ia600202.us.archive.org/11/items/AdhaN_M_up-by-muslem/019--1.mp3',
        description: 'أذان مكة',
        imageUrl: 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=900',
      ),
      MuezzinInfo(
        id: 'haramain_2',
        name: 'المدينة المنورة',
        url: 'https://example.com/madinah.mp3',
        description: 'أذان المدينة',
        imageUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=900',
      ),
    ],
  ),
  MuezzinCategory(
    id: 'egypt',
    name: 'أذان مصر',
    description: 'القاهرة والأزهر',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/cairo.jpg',
    items: const [
      MuezzinInfo(
        id: 'egypt_1',
        name: 'محمد صديق المنشاوي',
        url: 'https://ia600202.us.archive.org/11/items/AdhaN_M_up-by-muslem/048-.mp3',
        description: 'صوت مصري',
        imageUrl: 'https://images.unsplash.com/photo-1572949791660-6626e0e8e85e?w=900',
      ),
    ],
  ),

  /// قسم المشايخ: مصدره من ملف sheikhs_data.dart
  MuezzinCategory(
    id: 'sheikhs',
    name: 'أذان المشايخ',
    description: 'أضف/عدّل روابطك من ملف البيانات',
    imageUrl: '',
    imageAsset: '',
    items: [
      for (final s in sheikhsAdhanData)
        MuezzinInfo(
          id: s.id,
          name: s.name,
          url: s.url,
          description: s.description,
          imageUrl: s.imageUrl,
        ),
    ],
  ),
];

MuezzinInfo? findMuezzinById(String id) {
  for (final cat in muezzinCatalog) {
    for (final m in cat.items) {
      if (m.id == id) return m;
    }
  }
  return null;
}