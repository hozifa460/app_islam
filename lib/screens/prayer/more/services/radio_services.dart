import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class RadioService {
  static final AudioPlayer player = AudioPlayer();
  static const String radioUrl = 'https://n06.radiojar.com/8s5u5tpdtwzuv?1710007804961=.mp3'; // رابط بديل إذا لم يعمل الأول

  static Future<void> initRadio() async {
    // إعداد الجلسة الصوتية ليعمل في الخلفية
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  static Future<void> toggleRadio() async {
    try {
      if (player.playing) {
        await player.stop();
      } else {
        // إذا لم يكن المشغل مهيأ، هيئه
        if (player.audioSource == null) {
          await player.setUrl(radioUrl);
        }
        await player.play();
      }
    } catch (e) {
      print("خطأ في تشغيل الراديو: $e");
    }
  }
}