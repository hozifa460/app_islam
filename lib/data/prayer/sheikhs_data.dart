class SheikhAdhan {
  final String id;          // unique
  final String name;
  final String url;         // direct mp3/stream
  final String description;
  final String imageUrl;    // background image for card (optional)
  final String localSoundName;

  const SheikhAdhan({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl, required this.localSoundName,
  });
}

/// عدّل هنا وأضف روابطك أنت
const sheikhsAdhanData = <SheikhAdhan>[
  SheikhAdhan(
    id: 'sheikh_alefasi',
    name: 'الشيخ مشاري راشد العفاسي',
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alefasi.mp3',
    description: '',
    imageUrl: 'https://i.pinimg.com/736x/95/7b/d2/957bd24465492c83d9b50fe0df761436.jpg',
    localSoundName: 'alefasi',
  ),
  SheikhAdhan(
    id: 'sheikh_nasser_elkatami',
    name: 'الشيخ ناصر القطامي',
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/nasser.mp3',
    description: '',
    imageUrl: 'https://i.pinimg.com/736x/0c/89/82/0c898289cc93a09fa3b1e7a3fc45d410.jpg',
    localSoundName: 'nasser',
  ),


];