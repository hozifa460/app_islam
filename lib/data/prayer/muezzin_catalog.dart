import 'sheikhs_data.dart';

class MuezzinInfo {
  final String id;
  final String name;
  final String url;           // Online by default
  final String description;
  final String imageUrl;   // for cards
  final String localSoundName;
  final bool isBuiltIn; // ✅ أضف هذا

  const MuezzinInfo({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl,
    required this.localSoundName,
    this.isBuiltIn = false,
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
  // اذان الحرمين
  MuezzinCategory(
    id: 'haramain',
    name: 'أذان الحرمين',
    description: 'مكة والمدينة',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/makkah.jpeg',
    items: const [
      MuezzinInfo(
        id: 'haramain_1',
        name: 'اذان مكة المكرمة (افتراضي)',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/makkah.mp3',
        description: 'أذان مكة',
        imageUrl: 'https://i.pinimg.com/736x/cd/d2/6a/cdd26a5d12ca30f27a194e63d9a6dfb6.jpg',
        localSoundName: 'makkah',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'haramain_2',
        name: 'اذان المدينة المنورة',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/madinha.mp3',
        description: 'أذان المدينة',
        imageUrl: 'https://i.pinimg.com/1200x/90/8d/f3/908df34470ebe163e1c9e8d2510b160c.jpg',
        localSoundName: 'madinha',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'haramain_3',
        name: 'اذان الشيخ حمد الغريري',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/hamad_aldagrery.mp3',
        description: 'أذان الحرم المكي',
        imageUrl: 'https://surah.me/uploads/reciters/2023_04_30_10_24_44_491679.jpg',
        localSoundName: 'hamad_aldagrery',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'haramain_4',
        name: 'اذان الشيخ عبد المجيد السريحي',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alsrehi.mp3',
        description: 'أذان المدينة',
        imageUrl: 'https://i.ytimg.com/vi/FCu_QOajI-M/maxresdefault.jpg',
        localSoundName: 'alsrehi',
        isBuiltIn: false,
      ),

    ],
  ),

  // اذان مصر
  MuezzinCategory(
    id: 'egypt',
    name: 'أذان مصر',
    description: 'القاهرة والأزهر',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/cairo.jpg',
    items: const [
      MuezzinInfo(
        id: 'egypt_1',
        name: 'الشيخ محمد صديق المنشاوي',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/menshawy.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/b3/03/3f/b3033f63ee96b9d06a80abfb9ab47916.jpg',
        localSoundName: 'menshawy',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_2',
        name: 'الشيخ عبدالباسط عبد الصمد',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/abdalbaset.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/1200x/e4/27/59/e427591900e643ae21f75f6b75daf8fb.jpg',
        localSoundName: 'abdalbaset',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_3',
        name: 'الشيخ محمد رفعت',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/morefaat.mp3',
        description: '',
        imageUrl: 'https://3.bp.blogspot.com/-nxhSdMbLOHI/W7Xff-5GpAI/AAAAAAAAGro/-jD4TGkYny4PwsBH2oizSzI0qSc2g6UsACLcBGAs/s1600/mohammed-rif-at.JPG',
        localSoundName: 'morefaat',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_4',
        name: 'الشيخ مصطفى اسماعيل',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/moismail.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/1d/4b/7b/1d4b7b749e989a738c9bfcd03dbd3244.jpg',
        localSoundName: 'moismail',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_5',
        name: 'الشيخ محمود خليل الحصري',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alhosary.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/bb/3e/36/bb3e3635cb450812f910097a61fa1ce1.jpg',
        localSoundName: 'alhosary',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_6',
        name: 'الشيخ احمد نعينع',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/ahmedneana.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/fc/84/a9/fc84a95972fc6a123715d1a02a387b3d.jpg',
        localSoundName: 'ahmedneana',
        isBuiltIn: false,
      ),
    ],
  ),

  /// قسم المشايخ: مصدره من ملف sheikhs_data.dart
  MuezzinCategory(
    id: 'sheikhs',
    name: 'أذان المشايخ',
    description: 'اذان متنوع',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/meazna.jpg',
    items: [
      for (final s in sheikhsAdhanData)
        MuezzinInfo(
          id: s.id,
          name: s.name,
          url: s.url,
          description: s.description,
          imageUrl: s.imageUrl,
          localSoundName: '',
          isBuiltIn: false,
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