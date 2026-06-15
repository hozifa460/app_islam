import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/widgets/channels_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'video_player_screen.dart';

class ScholarProfileScreen extends StatefulWidget {
  final Map<String, dynamic> scholar;

  const ScholarProfileScreen({
    super.key,
    required this.scholar,
  });

  @override
  State<ScholarProfileScreen> createState() => _ScholarProfileScreenState();
}

class _ScholarProfileScreenState extends State<ScholarProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  List<YoutubeVideo> _videos = [];
  bool _loadingVideos = true;
  bool _loadingMore = false;
  int _currentPage = 1;

  ChannelInfo? _channelInfo;
  String? _youtubeChannelId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final platforms = widget.scholar['platforms'] as List<dynamic>? ?? [];

    for (final p in platforms) {
      final pm = Map<String, dynamic>.from(p);
      if (pm['icon'] == 'youtube') {
        try {
          // ← استخدام الدالة الجديدة
          final vids = await YoutubeService.getAllChannelVideos(
            channelUrl: pm['url'] ?? '',
            handle: pm['handle'],
            maxResults: 150, // زيادة الحد
          );

          debugPrint('📥 Loaded ${vids.length} videos for ${widget.scholar['name']}');

          // جلب معلومات القناة
          final channelUrl = pm['url']?.toString() ?? '';
          if (channelUrl.contains('/channel/')) {
            final parts = channelUrl.split('/channel/');
            if (parts.length > 1) {
              _youtubeChannelId = parts[1].split('/').first;
              final info =
              await YoutubeService.getChannelInfo(_youtubeChannelId!);
              if (mounted) {
                setState(() => _channelInfo = info);
              }
            }
          }

          if (mounted) {
            setState(() {
              _videos = vids;
              _loadingVideos = false;
            });
          }
          break;
        } catch (e) {
          debugPrint('❌ Load error: $e');
        }
      }
    }

    if (mounted && _loadingVideos) {
      setState(() => _loadingVideos = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_loadingMore || _videos.isEmpty) return;

    setState(() => _loadingMore = true);

    try {
      final platforms = widget.scholar['platforms'] as List<dynamic>? ?? [];
      for (final p in platforms) {
        final pm = Map<String, dynamic>.from(p);
        if (pm['icon'] == 'youtube') {
          // جلب دفعة جديدة
          final moreVids = await YoutubeService.getAllChannelVideos(
            channelUrl: pm['url'] ?? '',
            handle: pm['handle'],
            maxResults: 200, // زيادة أكثر
          );

          final existingIds = _videos.map((v) => v.id).toSet();
          final uniqueVids =
          moreVids.where((v) => !existingIds.contains(v.id)).toList();

          if (uniqueVids.isNotEmpty && mounted) {
            setState(() {
              _videos.addAll(uniqueVids);
              _currentPage++;
            });
            debugPrint('➕ Added ${uniqueVids.length} more videos');
          } else {
            debugPrint('⚠️ No new videos found');
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ Load more error: $e');
    }

    if (mounted) {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _openVideoPlayer(YoutubeVideo video) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: _timeAgo(video.publishedAt),
        ),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) {
      final y = diff.inDays ~/ 365;
      return 'منذ $y ${y == 1 ? 'سنة' : 'سنوات'}';
    }
    if (diff.inDays > 30) {
      final m = diff.inDays ~/ 30;
      return 'منذ $m ${m == 1 ? 'شهر' : 'أشهر'}';
    }
    if (diff.inDays > 7) {
      final w = diff.inDays ~/ 7;
      return 'منذ $w ${w == 1 ? 'أسبوع' : 'أسابيع'}';
    }
    if (diff.inDays > 0) return 'منذ ${diff.inDays} ${diff.inDays == 1 ? 'يوم' : 'أيام'}';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ${diff.inHours == 1 ? 'ساعة' : 'ساعات'}';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ChannelsTheme(isDark: isDark);
    final w = MediaQuery.of(context).size.width;

    final name = widget.scholar['name']?.toString() ?? '';
    final title = widget.scholar['title']?.toString() ?? '';
    final category = widget.scholar['category']?.toString() ?? '';
    final country = widget.scholar['country']?.toString() ?? '';
    final flag = widget.scholar['flag']?.toString() ?? '';
    final image = widget.scholar['image']?.toString() ?? '';
    final platforms = (widget.scholar['platforms'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e))
        .toList() ??
        [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: theme.cardBg,
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // ══════════════════════════════
                //  الهيدر المتحرك
                // ══════════════════════════════
                SliverAppBar(
                  expandedHeight: w * 0.7,
                  floating: false,
                  pinned: true,
                  backgroundColor: theme.cardBg,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // الخلفية المتدرجة
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: theme.avatarRingGradient,
                            ),
                          ),
                        ),

                        // Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),

                        // المحتوى
                        Positioned(
                          bottom: w * 0.05,
                          left: w * 0.05,
                          right: w * 0.05,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // الصورة
                              Container(
                                width: (w * 0.28).clamp(90.0, 130.0),
                                height: (w * 0.28).clamp(90.0, 130.0),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: image.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: image,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _avatarFallback(name, theme, w),
                                  )
                                      : _avatarFallback(name, theme, w),
                                ),
                              ),
                              SizedBox(height: w * 0.03),

                              // الاسم
                              Text(
                                name,
                                style: GoogleFonts.cairo(
                                  fontSize: (w * 0.055).clamp(20.0, 28.0),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              if (title.isNotEmpty) ...[
                                SizedBox(height: w * 0.01),
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: (w * 0.032).clamp(12.0, 16.0),
                                    color: Colors.white.withOpacity(0.9),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],

                              SizedBox(height: w * 0.02),

                              // البلد والتصنيف
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: w * 0.02,
                                children: [
                                  if (flag.isNotEmpty && country.isNotEmpty)
                                    _infoChip(
                                      '$flag $country',
                                      Colors.white.withOpacity(0.2),
                                      Colors.white,
                                      w,
                                    ),
                                  if (category.isNotEmpty)
                                    _infoChip(
                                      category,
                                      Colors.white.withOpacity(0.3),
                                      Colors.white,
                                      w,
                                    ),
                                ],
                              ),

                              // معلومات القناة
                              if (_channelInfo != null) ...[
                                SizedBox(height: w * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _statBox(
                                      YoutubeService.formatCount(
                                          _channelInfo!.subscriberCount),
                                      'مشترك',
                                      w,
                                    ),
                                    SizedBox(width: w * 0.04),
                                    _statBox(
                                      YoutubeService.formatCount(
                                          _channelInfo!.videoCount),
                                      'فيديو',
                                      w,
                                    ),
                                    SizedBox(width: w * 0.04),
                                    _statBox(
                                      '${_videos.length}',
                                      'محمّل',
                                      w,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ══════════════════════════════
                //  التبويبات الثابتة
                // ══════════════════════════════
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: theme.primaryColor,
                      indicatorWeight: 3,
                      labelColor: theme.primaryColor,
                      unselectedLabelColor: theme.subtitleColor,
                      labelStyle: GoogleFonts.cairo(
                        fontSize: (w * 0.035).clamp(13.0, 16.0),
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: GoogleFonts.cairo(
                        fontSize: (w * 0.035).clamp(13.0, 16.0),
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'الفيديوهات'),
                        Tab(text: 'المنصات'),
                      ],
                    ),
                    theme.cardBg,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // ══════════════════════════════
                //  تبويب الفيديوهات
                // ══════════════════════════════
                _buildVideosTab(theme, w),

                // ══════════════════════════════
                //  تبويب المنصات
                // ══════════════════════════════
                _buildPlatformsTab(theme, w, platforms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  تبويب الفيديوهات
  // ══════════════════════════════════════════
  Widget _buildVideosTab(ChannelsTheme theme, double w) {
    if (_loadingVideos) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            SizedBox(height: w * 0.03),
            Text(
              'جاري التحميل...',
              style: GoogleFonts.cairo(
                fontSize: (w * 0.035).clamp(12.0, 15.0),
                color: theme.subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined,
                size: (w * 0.15).clamp(50.0, 70.0),
                color: theme.captionColor.withOpacity(0.3)),
            SizedBox(height: w * 0.03),
            Text(
              'لا توجد فيديوهات',
              style: GoogleFonts.cairo(
                fontSize: (w * 0.04).clamp(14.0, 18.0),
                fontWeight: FontWeight.w700,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.02, w * 0.04, w * 0.08),
      itemCount: _videos.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: w * 0.025),
      itemBuilder: (_, i) {
        if (i == _videos.length) {
          return Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.primaryColor,
                ),
              ),
            ),
          );
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + i * 40),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - v)),
              child: child,
            ),
          ),
          child: _VideoItemCard(
            video: _videos[i],
            theme: theme,
            w: w,
            onTap: () => _openVideoPlayer(_videos[i]),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════
  //  تبويب المنصات
  // ══════════════════════════════════════════
  Widget _buildPlatformsTab(
      ChannelsTheme theme, double w, List<Map<String, dynamic>> platforms) {
    if (platforms.isEmpty) {
      return Center(
        child: Text(
          'لا توجد منصات',
          style: GoogleFonts.cairo(
            fontSize: (w * 0.035).clamp(12.0, 15.0),
            color: theme.subtitleColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(w * 0.04),
      itemCount: platforms.length,
      separatorBuilder: (_, __) => SizedBox(height: w * 0.02),
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.95 + 0.05 * v,
              child: child,
            ),
          ),
          child: _PlatformCard(
            platform: platforms[i],
            theme: theme,
            w: w,
            onTap: () => _openUrl(platforms[i]['url'] ?? ''),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════
  //  عناصر مساعدة
  // ══════════════════════════════════════════
  Widget _avatarFallback(String name, ChannelsTheme theme, double w) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.avatarRingGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.cairo(
            fontSize: (w * 0.1).clamp(32.0, 50.0),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color bg, Color textColor, double w) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: w * 0.008),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: (w * 0.028).clamp(10.0, 13.0),
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, double w) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: (w * 0.04).clamp(14.0, 18.0),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: (w * 0.026).clamp(9.0, 12.0),
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
//  بطاقة الفيديو
// ══════════════════════════════════════════════════
class _VideoItemCard extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _VideoItemCard({
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return 'منذ ${diff.inDays ~/ 30} شهر';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'الآن';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnail,
                      width: (w * 0.4).clamp(140.0, 180.0),
                      height: (w * 0.25).clamp(90.0, 110.0),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: (w * 0.4).clamp(140.0, 180.0),
                        height: (w * 0.25).clamp(90.0, 110.0),
                        color: theme.chipBg,
                        child: Icon(Icons.play_circle_outline_rounded,
                            size: 40, color: theme.captionColor),
                      ),
                    ),

                    // المدة
                    if (video.duration.isNotEmpty)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.duration,
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.024).clamp(9.0, 11.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // المعلومات
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(w * 0.025),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        video.title,
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.032).clamp(12.0, 15.0),
                          fontWeight: FontWeight.w700,
                          color: theme.textColor,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: w * 0.015),

                      // المشاهدات والتاريخ
                      Row(
                        children: [
                          if (video.viewCount != '0') ...[
                            Icon(Icons.visibility_rounded,
                                size: (w * 0.03).clamp(11.0, 14.0),
                                color: theme.captionColor),
                            SizedBox(width: w * 0.008),
                            Text(
                              YoutubeService.formatViews(video.viewCount),
                              style: GoogleFonts.cairo(
                                fontSize: (w * 0.026).clamp(9.0, 12.0),
                                color: theme.captionColor,
                              ),
                            ),
                            SizedBox(width: w * 0.015),
                          ],
                          Icon(Icons.access_time_rounded,
                              size: (w * 0.03).clamp(11.0, 14.0),
                              color: theme.captionColor),
                          SizedBox(width: w * 0.008),
                          Flexible(
                            child: Text(
                              _timeAgo(video.publishedAt),
                              style: GoogleFonts.cairo(
                                fontSize: (w * 0.026).clamp(9.0, 12.0),
                                color: theme.captionColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  بطاقة المنصة
// ══════════════════════════════════════════════════
class _PlatformCard extends StatelessWidget {
  final Map<String, dynamic> platform;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;

  const _PlatformCard({
    required this.platform,
    required this.theme,
    required this.w,
    required this.onTap,
  });

  IconData _getIcon(String key) {
    switch (key.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_fill_rounded;
      case 'tiktok':
        return Icons.music_note_rounded;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'telegram':
        return Icons.send_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  Color _getColor(String key, String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return theme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = platform['name']?.toString() ?? '';
    final iconKey = platform['icon']?.toString() ?? '';
    final colorStr = platform['color']?.toString() ?? '#00897B';
    final subs = platform['subscribers']?.toString() ?? '';

    final color = _getColor(iconKey, colorStr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            color: theme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: (w * 0.14).clamp(50.0, 64.0),
                height: (w * 0.14).clamp(50.0, 64.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(_getIcon(iconKey),
                    size: (w * 0.07).clamp(26.0, 34.0), color: Colors.white),
              ),
              SizedBox(width: w * 0.03),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.038).clamp(14.0, 17.0),
                        fontWeight: FontWeight.w700,
                        color: theme.textColor,
                      ),
                    ),
                    if (subs.isNotEmpty) ...[
                      SizedBox(height: w * 0.005),
                      Text(
                        '$subs متابع',
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.028).clamp(10.0, 13.0),
                          color: theme.subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(Icons.arrow_back_ios_rounded,
                  size: (w * 0.04).clamp(14.0, 18.0), color: theme.captionColor),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  Delegate للتبويبات الثابتة
// ══════════════════════════════════════════════════
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;

  _SliverTabBarDelegate(this.tabBar, this.bgColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}