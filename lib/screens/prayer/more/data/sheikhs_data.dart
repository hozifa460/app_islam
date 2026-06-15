class SheikhAdhan {
  final String id;
  final String name;
  final String url;
  final String description;
  final String imageUrl;
  final String localSoundName;

  const SheikhAdhan({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl,
    required this.localSoundName,
  });
}

const sheikhsAdhanData = <SheikhAdhan>[
  SheikhAdhan(
    id: 'sheikh_alefasi',
    name: 'sheikhAlafasy', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/alefasi.mp3',
    description: '',
    imageUrl: 'https://i.pinimg.com/736x/95/7b/d2/957bd24465492c83d9b50fe0df761436.jpg',
    localSoundName: 'alefasi',
  ),
  SheikhAdhan(
    id: 'sheikh_nasser_elkatami',
    name: 'sheikhNasser', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios@main/nasser.mp3',
    description: '',
    imageUrl: 'https://i.pinimg.com/736x/0c/89/82/0c898289cc93a09fa3b1e7a3fc45d410.jpg',
    localSoundName: 'nasser',
  ),
  SheikhAdhan(
    id: 'ahmed_elemadi',
    name: 'الشيخ احمد العمادي', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/ahmed_elemadi.mp3',
    description: '',
    imageUrl: 'https://archive.org/download/00012131440/00012131440.thumbs/0001%20%20%20%20%EF%B4%BF%D9%8A%D9%8E%D8%A7%20%D9%82%D9%8E%D9%88%D9%92%D9%85%D9%8E%D9%86%D9%8E%D8%A7%20%D8%A3%D9%8E%D8%AC%D9%90%D9%8A%D8%A8%D9%8F%D9%88%D8%A7%20%D8%AF%D9%8E%D8%A7%D8%B9%D9%90%D9%8A%D9%8E%20%D8%A7%D9%84%D9%84%D9%8E%D9%91%D9%87%D9%90%EF%B4%BE%20%D8%B9%D8%B4%D8%A7%D8%A6%D9%8A%D8%A9%20%D8%A8%D8%AF%D9%8A%D8%B9%D8%A9%20%D9%84%D9%84%D8%B4%D9%8A%D8%AE%20%D9%86%D8%A7%D8%B5%D8%B1%20%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A%20%2021-3-1440_000027.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'ahmed_eltarabolsi_qwiet',
    name: 'الشيخ احمد الطرابلسي', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/ahmed_eltarabolsi_qwiet.mp3',
    description: '',
    imageUrl: 'https://alziadiq8.com/wp-content/uploads/2023/03/unnamed-file-1024x576.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'anwar_doman_turkey',
    name: 'الشيخ انور دومان', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/anwar_doman_turkey.mp3',
    description: '',
    imageUrl: 'https://i.ytimg.com/vi/xNhZFmLhgM4/oar2.jpg?sqp=-oaymwEkCJIDENAFSFqQAgHyq4qpAxMIARUAAAAAJQAAyEI9AICiQ3gB&rs=AOn4CLCodyYJuQLazWj8QETBayVpE3tAEw',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'essam-bikhari_madina',
    name: 'الشيخ عصام البخارى', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/essam-bikhari_madina.mp3',
    description: '',
    imageUrl: 'https://i.ytimg.com/vi/SYhPPT7ps0Q/maxresdefault.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'gorgia',
    name: 'اذان جورجيا', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/gorgia.mp3',
    description: '',
    imageUrl: 'https://img.freepik.com/fotos-premium/mezquita-narikala-jumah-famosos-balcones-coloridos-antiguo-distrito-historico-abanotubani-exterior-bano-publico-azufre-tbilisi-georgia-buen-ejemplo-estilo-arquitectonico-islamico_180731-6092.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'mohamed_naser_elden_elaalbani',
    name: 'الشيخ محمد ناصر الدين الالباني', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/mohamed_naser_elden_elaalbani.mp3',
    description: '',
    imageUrl: 'https://tipyan.com/wp-content/uploads/2017/04/%D8%A7%D9%84%D8%B4%D9%8A%D8%AE-%D9%86%D8%A7%D8%B5%D8%B1-%D8%A7%D9%84%D8%AF%D9%8A%D9%86-%D8%A7%D9%84%D8%A3%D9%84%D8%A8%D8%A7%D9%86%D9%8A.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'nagi_kazaz',
    name: 'الشيخ ناجي القزاز', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/nagi_kazaz.mp3',
    description: '',
    imageUrl: 'https://i.ytimg.com/vi/u4qCQQQ_ptA/maxresdefault.jpg',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'pakistan',
    name: 'اذان باكستان', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/pakistan.mp3',
    description: '',
    imageUrl: 'https://tse4.mm.bing.net/th/id/OIP.hhUNWZUqXk7PpfrP3q7arQHaEV?rs=1&pid=ImgDetMain&o=7&rm=3',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'waleed_mehsas',
    name: 'اذان وليد مهساس', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/waleed_mehsas.mp3',
    description: '',
    imageUrl: 'https://i.ytimg.com/vi/8pgwfGErDXY/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgZShlMA8=&rs=AOn4CLBOYEFHDU_yBssAaBV-1XsLsV2H8Q',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'waleed_mehsas2',
    name: ' اذان وليد مهساس 2', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/waleed_mehsas_algeria.mp3',
    description: '',
    imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.QkDIGMEy_0CHN8qukjdlAQHaEo?rs=1&pid=ImgDetMain&o=7&rm=3',
    localSoundName: '',
  ),
  SheikhAdhan(
    id: 'yaser_eldosari',
    name: ' الشيخ ياسر الدوسري', // مفتاح الترجمة
    url: 'https://cdn.jsdelivr.net/gh/hozifa460/islamic-audios/adahn/yaser_eldosari.mp3',
    description: '',
    imageUrl: 'https://i.pinimg.com/736x/d0/8b/ff/d08bff3d6037e440bbf3ea4e4a5cd630.jpg',
    localSoundName: '',
  ),
];