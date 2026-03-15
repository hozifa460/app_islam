import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/prayer/muezzin_catalog.dart';
import '../../services/adahn_audio_services.dart';
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
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  Map<String, bool> _isDownloading = {};
  Map<String, bool> _isDownloaded = {};

  late MuezzinCategory _category;

  @override
  void initState() {
    super.initState();
    _category = muezzinCatalog.firstWhere((c) => c.id == widget.categoryId);
    _checkDownloads();
  }

  Future<void> _checkDownloads() async {
    for (final m in _category.items) {
      final downloaded = await AdhanAudioService.instance.isDownloaded(m.id);
      if (mounted) {
        setState(() {
          _isDownloaded[m.id] = downloaded;
        });
      }
    }
  }

  Future<void> _downloadMuezzin(MuezzinInfo m) async {
    setState(() => _isDownloading[m.id] = true);

    final path = await AdhanAudioService.instance.download(
      id: m.id,
      url: m.url,
      onProgress: (_) {},
    );

    if (!mounted) return;

    setState(() {
      _isDownloading[m.id] = false;
      _isDownloaded[m.id] = path != null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path != null ? 'تم تحميل ${m.name} بنجاح' : 'فشل تحميل ${m.name}',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: path != null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _deleteMuezzin(MuezzinInfo m) async {
    await AdhanAudioService.instance.deleteDownloaded(m.id);
    if (!mounted) return;
    setState(() => _isDownloaded[m.id] = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف ${m.name} من الهاتف', style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _previewMuezzin(MuezzinInfo m) async {
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

  Future<void> _selectAsDefault(MuezzinInfo m) async {
    await MuezzinStore.setDefault(m, resetAllCustom: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار ${m.name} كمؤذن افتراضي لكل الصلوات', style: GoogleFonts.cairo()),
        backgroundColor: _gold,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textColorMain,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: _category.items.length,
          itemBuilder: (context, index) {
            final m = _category.items[index];
            final downloading = _isDownloading[m.id] == true;
            final downloaded = _isDownloaded[m.id] == true;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: cardGradient),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(m.imageUrl),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.35),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.graphic_eq_rounded, color: _gold, size: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: GoogleFonts.amiri(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColorMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.description,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: textColorSub,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'معاينة',
                                onPressed: () => _previewMuezzin(m),
                                icon: Icon(Icons.play_circle_fill_rounded, color: _gold, size: 32),
                              ),
                              const SizedBox(width: 4),

                              if (downloading)
                                const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else if (downloaded)
                                GestureDetector(
                                  onTap: () => _deleteMuezzin(m),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      'Offline',
                                      style: GoogleFonts.cairo(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                IconButton(
                                  tooltip: 'تحميل',
                                  onPressed: () => _downloadMuezzin(m),
                                  icon: Icon(Icons.download_rounded, color: textColorSub, size: 28),
                                ),

                              const SizedBox(width: 4),

                              ElevatedButton(
                                onPressed: () => _selectAsDefault(m),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _gold.withOpacity(0.2),
                                  foregroundColor: _gold,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: _gold.withOpacity(0.3)),
                                  ),
                                ),
                                child: Text(
                                  'اختيار',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}