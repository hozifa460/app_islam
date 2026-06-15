import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/tiktok_service.dart';
import '../widgets/channels_theme.dart';

class TikTokProfileView extends StatefulWidget {
  final String username;
  final String? handle;

  const TikTokProfileView({
    super.key,
    required this.username,
    this.handle,
  });

  @override
  State<TikTokProfileView> createState() => _TikTokProfileViewState();
}

class _TikTokProfileViewState extends State<TikTokProfileView>
    with TickerProviderStateMixin {
  TikTokProfile? _profile;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final username = widget.handle ?? widget.username;
    final profile = await TikTokService.getUserProfile(username);

    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ChannelsTheme(isDark: isDark);
    final w = MediaQuery.of(context).size.width;

    if (_loading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFFEE1D52),
                strokeWidth: 3,
              ),
              SizedBox(height: w * 0.04),
              Text(
                'ط¬ط§ط±ظٹ طھط­ظ…ظٹظ„ TikTok...',
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.035).clamp(13.0, 16.0),
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 60, color: Colors.white38),
              SizedBox(height: w * 0.03),
              Text(
                'طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„ط¨ظٹط§ظ†ط§طھ',
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.038).clamp(14.0, 17.0),
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: w * 0.02),
              ElevatedButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE1D52),
                ),
                child: Text('ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000),
            Color(0xFF0A0A0A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          //  ط§ظ„ظ‡ظٹط¯ط± ظ…ط¹ ط§ظ„طµظˆط±ط© ظˆط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          SliverToBoxAdapter(
            child: _buildHeader(theme, w),
          ),

          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          //  ط§ظ„طھط¨ظˆظٹط¨ط§طھ
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          SliverPersistentHeader(
            pinned: true,
            delegate: _TikTokTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: GoogleFonts.cairo(
                  fontSize: (w * 0.032).clamp(12.0, 15.0),
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.grid_on_rounded, size: 20),
                    text: 'ط§ظ„ظپظٹط¯ظٹظˆظ‡ط§طھ',
                  ),
                  Tab(
                    icon: Icon(Icons.favorite_border_rounded, size: 20),
                    text: 'ط§ظ„ظ…ظپط¶ظ„ط©',
                  ),
                ],
              ),
            ),
          ),

          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          //  ط§ظ„ظ…ط­طھظˆظ‰
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideosGrid(theme, w),
                _buildFavoritesTab(theme, w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ظ‡ظٹط¯ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildHeader(ChannelsTheme theme, double w) {
    final p = _profile!;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, w * 0.04),
      child: Column(
        children: [
          // ط§ظ„طµظˆط±ط©
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFF69C9D0),
                  Color(0xFFEE1D52),
                  Color(0xFFFE2C55),
                  Color(0xFF69C9D0),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: SizedBox(
                  width: (w * 0.24).clamp(85.0, 110.0),
                  height: (w * 0.24).clamp(85.0, 110.0),
                  child: p.avatar.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: p.avatar,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        _avatarFallback(p.nickname, w),
                  )
                      : _avatarFallback(p.nickname, w),
                ),
              ),
            ),
          ),

          SizedBox(height: w * 0.03),

          // ط§ظ„ط§ط³ظ…
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  p.nickname,
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.05).clamp(18.0, 24.0),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (p.verified) ...[
                SizedBox(width: w * 0.015),
                Icon(Icons.verified_rounded,
                    color: const Color(0xFF20D5EC), size: 20),
              ],
            ],
          ),

          SizedBox(height: w * 0.005),

          // Username
          Text(
            '@${p.username}',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.032).clamp(12.0, 15.0),
              color: Colors.white60,
            ),
          ),

          SizedBox(height: w * 0.025),

          // ط§ظ„ط¥ط­طµط§ط¦ظٹط§طھ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statItem('ظ…طھط§ط¨ظگط¹', p.following, w),
              _divider(w),
              _statItem('ظ…طھط§ط¨ظگط¹ظˆظ†', p.followers, w),
              _divider(w),
              _statItem('ط¥ط¹ط¬ط§ط¨', p.likes, w),
            ],
          ),

          // Bio
          if (p.signature.isNotEmpty) ...[
            SizedBox(height: w * 0.025),
            Text(
              p.signature,
              style: GoogleFonts.cairo(
                fontSize: (w * 0.03).clamp(11.0, 14.0),
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: w * 0.03),

          // ط£ط²ط±ط§ط±
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ط²ط± ط§ظ„ظ…طھط§ط¨ط¹ط©
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () => _openUrl(
                      'https://www.tiktok.com/@${p.username}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE1D52),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_rounded, size: 18),
                      SizedBox(width: w * 0.015),
                      Text(
                        'ظ…طھط§ط¨ط¹ط©',
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.035).clamp(13.0, 16.0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: w * 0.02),

              // ط²ط± TikTok
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openUrl(
                      'https://www.tiktok.com/@${p.username}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.music_note_rounded, size: 20),
                ),
              ),

              SizedBox(width: w * 0.02),

              // ط²ط± ط§ظ„ظ…ط´ط§ط±ظƒط©
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.share_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, double w) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TikTokService.formatCount(value),
          style: GoogleFonts.cairo(
            fontSize: (w * 0.042).clamp(15.0, 20.0),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: (w * 0.028).clamp(10.0, 13.0),
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _divider(double w) {
    return Container(
      width: 1,
      height: (w * 0.08).clamp(28.0, 36.0),
      margin: EdgeInsets.symmetric(horizontal: w * 0.04),
      color: Colors.white12,
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  Grid ط§ظ„ظپظٹط¯ظٹظˆظ‡ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildVideosGrid(ChannelsTheme theme, double w) {
    final videos = _profile!.videos;

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined,
                size: 60, color: Colors.white24),
            SizedBox(height: w * 0.03),
            Text('ظ„ط§ طھظˆط¬ط¯ ظپظٹط¯ظٹظˆظ‡ط§طھ',
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.035).clamp(13.0, 16.0),
                  color: Colors.white38,
                )),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(w * 0.005),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: w * 0.005,
        mainAxisSpacing: w * 0.005,
      ),
      itemCount: videos.length,
      itemBuilder: (_, i) => _TikTokVideoThumbnail(
        video: videos[i],
        w: w,
        onTap: () => _openUrl(videos[i].url),
      ),
    );
  }

  Widget _buildFavoritesTab(ChannelsTheme theme, double w) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, size: 60, color: Colors.white24),
          SizedBox(height: w * 0.03),
          Text('ط§ظ„ظ…ظپط¶ظ„ط© ط®ط§طµط©',
              style: GoogleFonts.cairo(
                fontSize: (w * 0.035).clamp(13.0, 16.0),
                color: Colors.white38,
              )),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name, double w) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'طں',
          style: GoogleFonts.cairo(
            fontSize: (w * 0.08).clamp(28.0, 40.0),
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEE1D52),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  Thumbnail ط§ظ„ظپظٹط¯ظٹظˆ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _TikTokVideoThumbnail extends StatelessWidget {
  final TikTokVideo video;
  final double w;
  final VoidCallback onTap;

  const _TikTokVideoThumbnail({
    required this.video,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ط§ظ„طµظˆط±ط©
          video.cover.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: video.cover,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              color: const Color(0xFF1A1A1A),
              child: Icon(Icons.play_circle_outline_rounded,
                  size: 40, color: Colors.white38),
            ),
          )
              : Container(
            color: const Color(0xFF1A1A1A),
            child: Icon(Icons.play_circle_outline_rounded,
                size: 40, color: Colors.white38),
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          // ط§ظ„ظ…ط´ط§ظ‡ط¯ط§طھ
          Positioned(
            bottom: 6,
            left: 6,
            child: Row(
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                SizedBox(width: 3),
                Text(
                  TikTokService.formatCount(video.playCount),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  Delegate ط§ظ„طھط¨ظˆظٹط¨ط§طھ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _TikTokTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TikTokTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TikTokTabBarDelegate oldDelegate) => false;
}