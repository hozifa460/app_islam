import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class RadioService {
  static final AudioPlayer player = AudioPlayer();

  // The previous RadioJar endpoint returns 404. This free Shoutcast stream is
  // a Quran recitation station and does not require a paid provider or API key.
  static const String radioUrl =
      'https://qurango.net/radio/mahmoud_khalil_alhussary_warsh';
  static final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);
  static final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  static bool _initialized = false;
  static String? _activeUrl;

  static Future<void> initRadio() async {
    if (_initialized) return;
    _initialized = true;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stack) {
        isLoading.value = false;
        lastError.value = 'تعذر تشغيل إذاعة القرآن. اضغط للمحاولة مرة أخرى.';
        debugPrint('Radio playback error: $error');
      },
    );
  }

  static Future<void> toggleRadio() async {
    await initRadio();
    if (player.playing) {
      await player.stop();
      return;
    }

    lastError.value = null;
    isLoading.value = true;
    try {
      if (_activeUrl == radioUrl && player.audioSource != null) {
        await player.play();
        return;
      }
      await player.setUrl(radioUrl);
      _activeUrl = radioUrl;
      await player.play();
    } catch (error) {
      _activeUrl = null;
      lastError.value = 'تعذر الاتصال بمصدر الإذاعة. اضغط للمحاولة مرة أخرى.';
      debugPrint('Radio error: $error');
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> dispose() async {
    await player.dispose();
    lastError.dispose();
    isLoading.dispose();
  }
}
