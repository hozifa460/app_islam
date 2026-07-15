import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:islamic_app/screens/channels/widgets/channels_theme.dart';

import 'features/favorites_manager.dart';
import 'video_player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FavoritesManager? _favManager;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _favManager?.removeListener(_onFavoritesChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    _favManager = await FavoritesManager.getInstance();
    _favManager?.addListener(_onFavoritesChanged);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ChannelsTheme(isDark: isDark);
    final w = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBg,
        appBar: AppBar(
          backgroundColor: theme.cardBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'المفضلة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.textColor,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: _buildTabBar(theme, w),
          ),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : TabBarView(
          controller: _tabController,
          children: [
            _buildFavoritesList(theme, w),
            _buildWatchLaterList(theme, w),
            _buildHistoryList(theme, w),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ChannelsTheme theme, double w) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
      height: 42,
      decoration: BoxDecoration(
        color: theme.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: theme.subtitleColor,
        labelStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, size: 16),
                const SizedBox(width: 6),
                Text('المفضلة (${_favManager?.favoriteVideosCount ?? 0})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.watch_later_rounded, size: 16),
                const SizedBox(width: 6),
                Text('لاحقاً (${_favManager?.watchLaterCount ?? 0})'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 16),
                SizedBox(width: 6),
                Text('السجل'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(ChannelsTheme theme, double w) {
    final favorites = _favManager?.favoriteVideos ?? [];

    if (favorites.isEmpty) {
      return _buildEmptyState(
        theme,
        w,
        Icons.favorite_border_rounded,
        'لا توجد فيديوهات مفضلة',
        'اضغط على ❤️ لإضافة فيديو للمفضلة',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(w * 0.04),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => SizedBox(height: w * 0.03),
      itemBuilder: (context, index) {
        final video = _favManager!.mapToVideo(favorites[index]);
        return _FavoriteVideoCard(
          video: video,
          theme: theme,
          w: w,
          onTap: () => _openVideo(video),
          onRemove: () => _favManager?.removeVideoFromFavorites(video.id),
        );
      },
    );
  }

  Widget _buildWatchLaterList(ChannelsTheme theme, double w) {
    final watchLater = _favManager?.watchLater ?? [];

    if (watchLater.isEmpty) {
      return _buildEmptyState(
        theme,
        w,
        Icons.watch_later_outlined,
        'قائمة المشاهدة لاحقاً فارغة',
        'احفظ فيديوهات لمشاهدتها لاحقاً',
      );
    }

    return Column(
      children: [
        // ط²ط± طھط´ط؛ظٹظ„ ط§ظ„ظƒظ„
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (watchLater.isNotEmpty) {
                      final video = _favManager!.mapToVideo(watchLater.first);
                      _openVideo(video);
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    'تشغيل الكل',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: w * 0.02),
              IconButton(
                onPressed: () => _showClearConfirmation(
                  context,
                  theme,
                  'مسح القائمة',
                  'هل تريد مسح قائمة المشاهدة لاحقاً؟',
                      () => _favManager?.clearWatchLater(),
                ),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.captionColor,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(w * 0.04),
            itemCount: watchLater.length,
            separatorBuilder: (_, __) => SizedBox(height: w * 0.03),
            itemBuilder: (context, index) {
              final video = _favManager!.mapToVideo(watchLater[index]);
              return _FavoriteVideoCard(
                video: video,
                theme: theme,
                w: w,
                onTap: () => _openVideo(video),
                onRemove: () => _favManager?.removeFromWatchLater(video.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(ChannelsTheme theme, double w) {
    final history = _favManager?.watchHistory ?? [];

    if (history.isEmpty) {
      return _buildEmptyState(
        theme,
        w,
        Icons.history_rounded,
        'سجل المشاهدة فارغ',
        'ستظهر هنا الفيديوهات التي شاهدتها',
      );
    }

    return Column(
      children: [
        // ط²ط± ظ…ط³ط­ ط§ظ„ط³ط¬ظ„
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showClearConfirmation(
                  context,
                  theme,
                  'مسح السجل',
                  'هل تريد مسح سجل المشاهدة؟',
                      () => _favManager?.clearHistory(),
                ),
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  size: 18,
                  color: theme.captionColor,
                ),
                label: Text(
                  'مسح السجل',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: theme.captionColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(w * 0.04),
            itemCount: history.length,
            separatorBuilder: (_, __) => SizedBox(height: w * 0.03),
            itemBuilder: (context, index) {
              final videoMap = history[index];
              final video = _favManager!.mapToVideo(videoMap);
              final progress = _favManager?.getWatchProgress(video.id);

              return _HistoryVideoCard(
                video: video,
                progress: progress,
                watchedAt: DateTime.tryParse(videoMap['watchedAt'] ?? ''),
                theme: theme,
                w: w,
                onTap: () => _openVideo(video),
                onRemove: () => _favManager?.removeFromHistory(video.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      ChannelsTheme theme,
      double w,
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.06),
            decoration: BoxDecoration(
              color: theme.chipBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: (w * 0.12).clamp(40.0, 60.0),
              color: theme.captionColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: w * 0.04),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: (w * 0.042).clamp(15.0, 19.0),
              fontWeight: FontWeight.w700,
              color: theme.textColor,
            ),
          ),
          SizedBox(height: w * 0.015),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: (w * 0.032).clamp(12.0, 15.0),
              color: theme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openVideo(YoutubeVideo video) {
    // ط¥ط¶ط§ظپط© ظ„ظ„ط³ط¬ظ„
    _favManager?.addToHistory(video);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: _timeAgo(video.publishedAt),
        ),
      ),
    );
  }

  void _showClearConfirmation(
      BuildContext context,
      ChannelsTheme theme,
      String title,
      String message,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: theme.textColor,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(color: theme.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: theme.subtitleColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'مسح',
              style: GoogleFonts.cairo(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return 'منذ ${diff.inDays ~/ 365} سنة';
    if (diff.inDays > 30) return 'منذ ${diff.inDays ~/ 30} شهر';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'الآن';
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ط¨ط·ط§ظ‚ط© ظپظٹط¯ظٹظˆ ظ…ظپط¶ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _FavoriteVideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteVideoCard({
    required this.video,
    required this.theme,
    required this.w,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(video.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onRemove();
      },
      child: Material(
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
                // ط§ظ„طµظˆط±ط©
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.thumbnail,
                        width: (w * 0.35).clamp(120.0, 160.0),
                        height: (w * 0.2).clamp(70.0, 95.0),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: theme.chipBg,
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            color: theme.captionColor,
                          ),
                        ),
                      ),
                      if (video.duration.isNotEmpty)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.duration,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.025),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.032).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w700,
                            color: theme.textColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: w * 0.01),
                        Text(
                          video.channelTitle,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.026).clamp(10.0, 12.0),
                            color: theme.subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: w * 0.005),
                        Row(
                          children: [
                            if (video.viewCount != '0') ...[
                              Text(
                                '${YoutubeService.formatViews(video.viewCount)} مشاهدة',
                                style: GoogleFonts.cairo(
                                  fontSize: (w * 0.024).clamp(9.0, 11.0),
                                  color: theme.captionColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ط²ط± ط§ظ„ط¥ط²ط§ظ„ط©
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onRemove();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.captionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ط¨ط·ط§ظ‚ط© ظپظٹط¯ظٹظˆ ط§ظ„ط³ط¬ظ„ ظ…ط¹ ظ…ط¤ط´ط± ط§ظ„طھظ‚ط¯ظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _HistoryVideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final double? progress;
  final DateTime? watchedAt;
  final ChannelsTheme theme;
  final double w;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryVideoCard({
    required this.video,
    this.progress,
    this.watchedAt,
    required this.theme,
    required this.w,
    required this.onTap,
    required this.onRemove,
  });

  String _formatWatchedAt() {
    if (watchedAt == null) return '';
    final diff = DateTime.now().difference(watchedAt!);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${diff.inDays ~/ 7} أسبوع';
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
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ط§ظ„طµظˆط±ط©
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: video.thumbnail,
                          width: (w * 0.35).clamp(120.0, 160.0),
                          height: (w * 0.2).clamp(70.0, 95.0),
                          fit: BoxFit.cover,
                        ),
                        if (video.duration.isNotEmpty)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                video.duration,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.025),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.032).clamp(12.0, 15.0),
                              fontWeight: FontWeight.w700,
                              color: theme.textColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: w * 0.01),
                          Text(
                            video.channelTitle,
                            style: GoogleFonts.cairo(
                              fontSize: (w * 0.026).clamp(10.0, 12.0),
                              color: theme.subtitleColor,
                            ),
                          ),
                          if (watchedAt != null) ...[
                            SizedBox(height: w * 0.005),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: theme.captionColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _formatWatchedAt(),
                                  style: GoogleFonts.cairo(
                                    fontSize: (w * 0.024).clamp(9.0, 11.0),
                                    color: theme.captionColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ط²ط± ط§ظ„ط¥ط²ط§ظ„ط©
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.captionColor,
                    ),
                  ),
                ],
              ),

              // ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ…
              if (progress != null && progress! > 0)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: LinearProgressIndicator(
                    value: progress!,
                    backgroundColor: theme.chipBg,
                    color: theme.primaryColor,
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}