import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ChannelsScreen extends StatefulWidget {
  final Color primaryColor;
  const ChannelsScreen({super.key, required this.primaryColor});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ✅ البيانات
  final List<Map<String, dynamic>> channels = [
    {
      'name': 'قناة القرآن الكريم',
      'desc': 'بث مباشر 24 ساعة من الحرم المكي الشريف',
      'isLive': true,
      'url': 'https://www.youtube.com/@MakkahLive/streams',
      'color': const Color(0xFF1B5E20), // لون مميز للقناة
    },
    {
      'name':  'قناة الشيخ زين خير الله',
      'desc': 'قناة الشيخ على يويتيوب',
      'isLive': true,
      'url': 'https://www.youtube.com/@Zaink-r8q/streams',
      'color': const Color(0xFF006064),
    },
    {
      'name': 'إذاعة القرآن الكريم',
      'desc': 'تلاوات خاشعة وبرامج دينية من القاهرة',
      'isLive': true,
      'url': 'https://www.youtube.com/@QuranRadio/streams',
      'color': const Color(0xFF8D6E63),
    },
    {
      'name': 'قناة الشيخ عثمان الخميس',
      'desc': 'فتاوى ودروس ومحاضرات علمية',
      'isLive': false, // غير مباشر
      'url': 'https://www.youtube.com/@OthmanAlkamees/videos',
      'color': const Color(0xFF37474F),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openChannel(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView, // فتح داخل التطبيق
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
      );
    } catch (e) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // خلفية رمادية فاتحة جداً
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ================= 1. الهيدر المتحرك =================
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: widget.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'البث المباشر',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.primaryColor,
                        widget.primaryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // أيقونة خلفية كبيرة
                      Positioned(
                        right: -30, bottom: -30,
                        child: Icon(Icons.live_tv_rounded, size: 180, color: Colors.white.withOpacity(0.1)),
                      ),
                      // زخرفة
                      Positioned(
                        left: 20, top: 40,
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================= 2. القائمة =================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPremiumCard(channels[index]),
                  childCount: channels.length,
                ),
              ),
            ),

            // مساحة في الأسفل
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(Map<String, dynamic> channel) {
    bool isLive = channel['isLive'];
    Color cardColor = channel['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openChannel(channel['url']),
          child: Column(
            children: [
              // --- صورة الغلاف (Placeholder ملون) ---
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [cardColor, cardColor.withOpacity(0.7)],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.play_circle_fill_rounded, size: 60, color: Colors.white.withOpacity(0.9)),
                    ),
                  ),

                  // شارة "مباشر"
                  if (isLive)
                    Positioned(
                      top: 12, left: 12,
                      child: ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('مباشر الآن', style: GoogleFonts.cairo(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // --- التفاصيل ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // الشعار
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.tv, color: cardColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // النصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channel['name'],
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            channel['desc'],
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // سهم التوجيه
                    Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}