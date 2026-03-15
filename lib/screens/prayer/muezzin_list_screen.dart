import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/prayer/muezzin_catalog.dart';
import '../../services/adahn_audio_services.dart';
import '../../services/adhan_manager.dart';
import '../../services/muazzin_store.dart';
import 'adhan_player_screen.dart';

class MuezzinListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color primaryColor;

  const MuezzinListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.primaryColor,
  });

  @override
  State<MuezzinListScreen> createState() => _MuezzinListScreenState();
}

class _MuezzinListScreenState extends State<MuezzinListScreen> {
  final _gold = const Color(0xFFE6B325);
  final _bgDark = const Color(0xFF0A0E17);
  final _bgCard = const Color(0xFF151B26);

  final _previewPlayer = AudioPlayer();
  String? _playingId;

  final Map<String, bool> _downloading = {};
  final Map<String, bool> _downloaded = {};

  // جلب بيانات القسم الحالي (للحصول على الصورة والبيانات)
  late MuezzinCategory _currentCategory;

  List<MuezzinInfo> get _items => _currentCategory.items;

  @override
  void initState() {
    super.initState();
    _currentCategory = muezzinCatalog.firstWhere((c) => c.id == widget.categoryId);
    _loadDownloaded();
  }

  Future<void> _loadDownloaded() async {
    for (final m in _items) {
      final ok = await AdhanAudioService.instance.isDownloaded(m.id);
      if (!mounted) return;
      setState(() => _downloaded[m.id] = ok);
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  // ================== المنطق (لم يتم تغييره) ==================

  Future<void> _togglePreview(MuezzinInfo m) async {
    try {
      if (_playingId == m.id) {
        await _previewPlayer.stop();
        setState(() => _playingId = null);
        return;
      }

      await _previewPlayer.stop();
      setState(() => _playingId = m.id);

      final local = await AdhanAudioService.instance.getLocalPath(m.id);
      if (local != null) {
        await _previewPlayer.setFilePath(local);
      } else {
        await _previewPlayer.setUrl(m.url);
      }
      await _previewPlayer.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _playingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التشغيل: تأكد من أن الرابط مباشر mp3', style: GoogleFonts.cairo()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _downloadOffline(MuezzinInfo m) async {
    if (_downloading[m.id] == true) return;

    setState(() => _downloading[m.id] = true);

    final path = await AdhanAudioService.instance.download(
      id: m.id,
      url: m.url,
      onProgress: (_) {},
    );

    if (!mounted) return;

    setState(() {
      _downloading[m.id] = false;
      _downloaded[m.id] = path != null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(path != null ? 'تم التحميل Offline' : 'فشل التحميل', style: GoogleFonts.cairo()),
        backgroundColor: path != null ? Colors.green : Colors.red,
      ),
    );
  }

  // داخل MuezzinListScreen.dart

  Future<void> _selectAsDefault(MuezzinInfo m) async {
    // 1. حفظ المؤذن كافتراضي وإزالة تخصيصات الصلوات الفردية (كما كانت)
    await MuezzinStore.setDefault(m, resetAllCustom: true);

    // ✅ 2. الخطوة الجديدة: إعادة جدولة الأذان بالصوت الجديد
    final prefs = await SharedPreferences.getInstance();
    final adhanEnabled = prefs.getBool('adhan_enabled') ?? false;

    if (adhanEnabled) {
      // استدعاء العقل المدبر ليعيد ضبط التنبيهات بصوت المؤذن الجديد
      await AdhanManager.schedulePrayersForNextWeek();
    }

    if (!mounted) return;

    // 3. عرض رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('تم اختيار ${m.name} كمؤذن افتراضي لكل الصلوات', style: GoogleFonts.cairo()),
          backgroundColor: _gold // تأكد أن _gold معرفة عندك
      ),
    );

    // 4. العودة للصفحة السابقة
    Navigator.pop(context);
  }

  void _openPlayer(MuezzinInfo m) async {
    final local = await AdhanAudioService.instance.getLocalPath(m.id);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdhanPlayerScreen(
          primaryColor: widget.primaryColor,
          prayerName: 'معاينة',
          muezzinName: m.name,
          url: m.url,
          localPath: local,
        ),
      ),
    );
  }

  // ================== واجهة المستخدم الاحترافية ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ✅ هيدر علوي احترافي يختفي عند النزول
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: _bgDark,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.categoryName,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 10)],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة القسم في الخلفية
                  Image.network(
                    _currentCategory.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: _bgCard),
                  ),
                  // تدرج لوني داكن فوق الصورة للقراءة الواضحة
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _bgDark.withOpacity(0.8),
                          _bgDark,
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ قائمة المؤذنين
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final m = _items[index];
                  final isPlaying = _playingId == m.id;
                  final isDownloaded = _downloaded[m.id] == true;
                  final isDownloading = _downloading[m.id] == true;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildProfessionalCard(m, isPlaying, isDownloaded, isDownloading),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تصميم البطاقة الاحترافي الجديد
  Widget _buildProfessionalCard(MuezzinInfo m, bool isPlaying, bool isDownloaded, bool isDownloading) {
    return GestureDetector(
      onTap: () => _openPlayer(m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isPlaying ? _gold.withOpacity(0.08) : _bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPlaying ? _gold.withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: isPlaying ? 2 : 1,
          ),
          boxShadow: [
            if (isPlaying)
              BoxShadow(
                color: _gold.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            // الجزء العلوي: المعلومات وزر التشغيل
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // أيقونة المايكروفون/المؤذن
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPlaying
                            ? [_gold, const Color(0xFFF4D03F)]
                            : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isPlaying ? [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)] : null,
                    ),
                    child: Icon(
                      Icons.mic_external_on_rounded,
                      color: isPlaying ? Colors.black : _gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: GoogleFonts.amiri(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.description,
                          style: GoogleFonts.cairo(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // زر المعاينة (Play/Pause)
                  GestureDetector(
                    onTap: () => _togglePreview(m),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.red.withOpacity(0.2) : _gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPlaying ? Colors.red.withOpacity(0.5) : _gold.withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isPlaying ? Colors.redAccent : _gold,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // خط فاصل شفاف
            Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 16, endIndent: 16),

            // الجزء السفلي: أزرار التحكم (تحميل & تعيين كافتراضي)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // زر التحميل / حالة التحميل
                  Expanded(
                    child: isDownloaded
                        ? _buildActionButton(
                      icon: Icons.offline_pin_rounded,
                      label: 'متاح بدون إنترنت',
                      color: Colors.green,
                      bgColor: Colors.green.withOpacity(0.1),
                      onTap: null, // لا شيء
                    )
                        : isDownloading
                        ? _buildActionButton(
                      icon: Icons.downloading,
                      label: 'جاري التحميل...',
                      color: _gold,
                      bgColor: _gold.withOpacity(0.1),
                      onTap: null,
                      isSpinning: true,
                    )
                        : _buildActionButton(
                      icon: Icons.cloud_download_rounded,
                      label: 'تحميل للصلاة',
                      color: Colors.white70,
                      bgColor: Colors.white.withOpacity(0.05),
                      onTap: () => _downloadOffline(m),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // زر التعيين كافتراضي
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'تعيين للكل',
                      color: _gold,
                      bgColor: _gold.withOpacity(0.15),
                      onTap: () => _selectAsDefault(m),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ زر أنيق مبني خصيصاً للتصميم الجديد
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback? onTap,
    bool isSpinning = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSpinning)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              )
            else
              Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}