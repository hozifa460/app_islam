import 'package:just_audio/just_audio.dart';

class QuranRadioService {
  static final AudioPlayer player = AudioPlayer();

  static final List<Map<String, String>> reciters = [
    {'id': 'afs', 'name': 'مشاري العفاسي', 'url': 'https://server8.mp3quran.net/afs/001.mp3'},
    {'id': 'basit', 'name': 'عبدالباسط عبدالصمد', 'url': 'https://server7.mp3quran.net/basit/001.mp3'},
    {'id': 'husr', 'name': 'محمود الحصري', 'url': 'https://server11.mp3quran.net/husr/001.mp3'},
    {'id': 'minshawi', 'name': 'المنشاوي', 'url': 'https://server12.mp3quran.net/minshawi/001.mp3'},
  ];

  static Future<void> play(String url) async {
    await player.setUrl(url);
    await player.play();
  }

  static Future<void> stop() async {
    await player.stop();
  }
}