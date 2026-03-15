import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  // ✅ روابط فيديوهات تجريبية بصيغة MP4 (يمكنك تغييرها لاحقاً بروابط من سيرفرك أو Firebase)
  final List<Map<String, String>> reelsData = [
    {
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // استبدل برابط فيديو إسلامي 1
      'title': 'التوكل على الله',
      'speaker': 'د. محمد راتب النابلسي',
    },
    {
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // استبدل برابط فيديو إسلامي 2
      'title': 'أهمية الصلاة في وقتها',
      'speaker': 'الشيخ عثمان الخميس',
    },
    // أضف المزيد من الروابط هنا...
  ];

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // خلفية تيك توك تكون سوداء
        body: Stack(
          children: [
            // ================= 1. PageView (التمرير العمودي) =================
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical, // التمرير لأعلى وأسفل
              itemCount: reelsData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return ReelVideoPlayer(
                  videoUrl: reelsData[index]['url']!,
                  title: reelsData[index]['title']!,
                  speaker: reelsData[index]['speaker']!,
                  // لا يتم تشغيل الفيديو إلا إذا كان هو المعروض حالياً
                  isPlay: _currentIndex == index,
                );
              },
            ),

            // ================= 2. زر الرجوع (أعلى الشاشة) =================
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🎬 كلاس مخصص لتشغيل كل فيديو على حدة
// ==========================================
class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String speaker;
  final bool isPlay;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.speaker,
    required this.isPlay,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // تهيئة الفيديو من الرابط
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          // تشغيل الفيديو تلقائياً إذا كان هو المعروض وتكراره (Loop)
          _controller.setLooping(true);
          if (widget.isPlay) {
            _controller.play();
          }
        });
      });
  }

  // التحكم في التشغيل والإيقاف عند تمرير الشاشة
  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isPlay) {
        _controller.play();
      } else {
        _controller.pause();
        _controller.seekTo(Duration.zero); // إرجاع الفيديو للبداية عند مغادرته
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // الإيقاف/التشغيل عند النقر على الشاشة
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ================= مشغل الفيديو =================
        GestureDetector(
          onTap: _togglePlayPause, // ضغطة لإيقاف/تشغيل الفيديو
          child: _isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover, // ملء الشاشة بالكامل (قد يقطع الأطراف قليلاً حسب نسبة العرض)
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : const Center(
            child: CircularProgressIndicator(color: Colors.white), // دائرة تحميل
          ),
        ),

        // ================= أيقونة الإيقاف المؤقت (في المنتصف) =================
        if (_isInitialized && !_controller.value.isPlaying)
          Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
          ),

        // ================= معلومات الفيديو (الأسفل) =================
        Positioned(
          bottom: 40,
          left: 20,
          right: 80, // ترك مساحة للأزرار الجانبية
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.speaker,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black54, blurRadius: 5)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [const Shadow(color: Colors.black54, blurRadius: 5)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ================= الأزرار الجانبية (يمين الشاشة) =================
        Positioned(
          bottom: 40,
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSideButton(Icons.favorite, 'إعجاب'),
              const SizedBox(height: 20),
              _buildSideButton(Icons.share, 'مشاركة'),
              const SizedBox(height: 20),
              // يمكنك تفعيل زر التحميل لاحقاً ببرمجة دالة تحميل
              _buildSideButton(Icons.download, 'تحميل'),
            ],
          ),
        ),
      ],
    );
  }

  // تصميم الأزرار الجانبية
  Widget _buildSideButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 35, shadows: const [Shadow(color: Colors.black54, blurRadius: 5)]),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 5)],
          ),
        ),
      ],
    );
  }
}