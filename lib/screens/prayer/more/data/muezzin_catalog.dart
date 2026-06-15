import 'sheikhs_data.dart';

class MuezzinInfo {
  final String id;
  final String name;
  final String url;
  final String description;
  final String imageUrl;
  final String localSoundName;
  final bool isBuiltIn;

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
  final String imageUrl;
  final String? imageAsset;
  final List<MuezzinInfo> items;

  const MuezzinCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.items,
    this.imageAsset,
  });
}

final muezzinCatalog = <MuezzinCategory>[
  MuezzinCategory(
    id: 'haramain',
    name: 'catHaramainName', // مفتاح
    description: 'catHaramainDesc', // مفتاح
    imageUrl: '',
    imageAsset: 'assets/adahn_images/makkah.jpeg',
    items: const [
      MuezzinInfo(
        id: 'haramain_1',
        name: 'makkahDefault',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/makkah.mp3',
        description: 'makkahAdhan',
        imageUrl: 'https://i.pinimg.com/736x/cd/d2/6a/cdd26a5d12ca30f27a194e63d9a6dfb6.jpg',
        localSoundName: 'makkah',
        isBuiltIn: true,
      ),
      MuezzinInfo(
        id: 'haramain_2',
        name: 'madinahAdhan',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/madinha.mp3',
        description: 'madinahAdhanDesc',
        imageUrl: 'https://i.pinimg.com/1200x/90/8d/f3/908df34470ebe163e1c9e8d2510b160c.jpg',
        localSoundName: 'madinha',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'haramain_3',
        name: 'sheikhHamad',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/hamad_aldagrery.mp3',
        description: 'makkahHaramAdhan',
        imageUrl: 'https://surah.me/uploads/reciters/2023_04_30_10_24_44_491679.jpg',
        localSoundName: 'hamad_aldagrery',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'haramain_4',
        name: 'sheikhAbdulmajeed',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alsrehi.mp3',
        description: 'madinahAdhanDesc',
        imageUrl: 'https://i.ytimg.com/vi/FCu_QOajI-M/maxresdefault.jpg',
        localSoundName: 'alsrehi',
        isBuiltIn: false,
      ),
    ],
  ),

  MuezzinCategory(
    id: 'egypt',
    name: 'catEgyptName',
    description: 'catEgyptDesc',
    imageUrl: '',
    imageAsset: 'assets/adahn_images/cairo.jpg',
    items: const [
      MuezzinInfo(
        id: 'egypt_1',
        name: 'sheikhMenshawy',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/menshawy.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/b3/03/3f/b3033f63ee96b9d06a80abfb9ab47916.jpg',
        localSoundName: 'menshawy',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_2',
        name: 'sheikhAbdalbaset',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/abdalbaset.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/1200x/e4/27/59/e427591900e643ae21f75f6b75daf8fb.jpg',
        localSoundName: 'abdalbaset',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_3',
        name: 'sheikhRifaat',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/morefaat.mp3',
        description: '',
        imageUrl: 'https://3.bp.blogspot.com/-nxhSdMbLOHI/W7Xff-5GpAI/AAAAAAAAGro/-jD4TGkYny4PwsBH2oizSzI0qSc2g6UsACLcBGAs/s1600/mohammed-rif-at.JPG',
        localSoundName: 'morefaat',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_4',
        name: 'sheikhMustafaIsmail',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/moismail.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/1d/4b/7b/1d4b7b749e989a738c9bfcd03dbd3244.jpg',
        localSoundName: 'moismail',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_5',
        name: 'sheikhAlhosary',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alhosary.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/bb/3e/36/bb3e3635cb450812f910097a61fa1ce1.jpg',
        localSoundName: 'alhosary',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_6',
        name: 'sheikhNeana',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/ahmedneana.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/fc/84/a9/fc84a95972fc6a123715d1a02a387b3d.jpg',
        localSoundName: 'ahmedneana',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_7',
        name: 'الشيخ نصر الدين طوبار',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/nasr_eldin_tobar.mpeg',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/13/37/f3/1337f33bda7b53618a6c3a1299ee820c.jpg',
        localSoundName: '',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_8',
        name: 'الشيخ عبد الباسط 2',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/abdelbaset2.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/6d/af/ba/6dafbaca9d297e69b71d73ac538e92c0.jpg',
        localSoundName: '',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_9',
        name: 'الشيخ ابو العينين شعيشع',
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/aboelenin_sheasha.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/1200x/84/c6/60/84c660a229541970760b3318afe20f39.jpg',
        localSoundName: '',
        isBuiltIn: false,
      ),
      MuezzinInfo(
        id: 'egypt_10',
        name: 'الشيخ محمود الطوخي', // مفتاح الترجمة
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/mahmoud_eltokhi.mp3',
        description: '',
        imageUrl: 'https://i.ytimg.com/vi/CZsisTlbR2g/maxresdefault.jpg',
        localSoundName: '',
      ),
      MuezzinInfo(
        id: 'egypt_11',
        name: 'الشيخ محمود على البنا', // مفتاح الترجمة
        url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/moamed_ali_albana.mp3',
        description: '',
        imageUrl: 'https://i.pinimg.com/736x/35/26/90/352690ed059ae7465d4d7fc1d41e2a29.jpg',
        localSoundName: '',
      ),
    ],
  ),

  MuezzinCategory(
    id: 'sheikhs',
    name: 'catSheikhsName',
    description: 'catSheikhsDesc',
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