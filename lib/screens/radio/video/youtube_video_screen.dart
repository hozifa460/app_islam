import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// مشغل يوتيوب محلي داخل صفحة مستقلة.
/// لا ينقل المتحكم إلى مشغل عام ولا يمرر رابط يوتيوب إلى just_audio.
class YoutubeVideoScreen extends StatefulWidget {
  final String url;
  final String title;
  final String subtitle;
  final Color primary;

  const YoutubeVideoScreen({
    super.key,
    required this.url,
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  YoutubePlayerController? _controller;
  String? _error;
  bool _wasFullScreen = false;

  @override
  void initState() {
    super.initState();
    final id = YoutubePlayer.convertUrlToId(widget.url);
    if (id == null || id.isEmpty) {
      _error = 'رابط فيديو يوتيوب غير صالح';
      return;
    }
    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    )..addListener(_syncFullscreenState);
  }

  void _syncFullscreenState() {
    final isFullScreen = _controller?.value.isFullScreen ?? false;
    if (isFullScreen == _wasFullScreen) return;
    _wasFullScreen = isFullScreen;
    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _restorePortraitMode();
    }
  }

  void _restorePortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller?.removeListener(_syncFullscreenState);
    _controller?.dispose();
    _restorePortraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF17171A);
    final muted = isDark ? Colors.white60 : const Color(0xFF64646D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مشغل يوتيوب', style: GoogleFonts.cairo(fontSize: 17)),
        ),
        body:
            _error != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(color: muted),
                    ),
                  ),
                )
                : ListView(
                  children: [
                    YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: widget.primary,
                      progressColors: ProgressBarColors(
                        playedColor: widget.primary,
                        handleColor: widget.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.cairo(
                              color: foreground,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.cairo(color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
