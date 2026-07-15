// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/recitations_screen.dart';
import 'package:islamic_app/screens/radio/search_screen.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_cache_manager.dart';
import 'package:islamic_app/screens/radio/video/video_feed_tab.dart';
import 'package:islamic_app/screens/radio/video/widgets/smart_video_thumbnail.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/recent_listening_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/back_button_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/category_section_widge.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/favorites_section_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/hero_header_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/radio_tab_bar_widget.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/night_sky_background.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_animations.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:provider/provider.dart';
import 'data/radio_data.dart';
import 'data/recitation_categories_data.dart';
import 'helpers/radio_animation_manager.dart';

class RadioScreen extends StatefulWidget {
  final Color primaryColor;
  const RadioScreen({super.key, required this.primaryColor});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with TickerProviderStateMixin {

  // âœ… Controllers
  late final AnimationController _equalizerController;
  late final AnimationController _bgController;
  late final AnimationController _headerController;

  // âœ… Animations
  late final Animation<double> _headerFadeAnim;

  late final Widget _radioTabPage;
  late final Widget _recitationsTabPage;
  late final Widget _videosTabPage;

  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  // âœ… Cache
  late final List<RecitationCategory> _categories;
  late final List<String> _stationCategories;

  Widget? _recitationsScreen;

  // âœ… Overlay styles ظ…ط­ط³ظˆط¨ط© ظ…ط±ط© ظˆط§ط­ط¯ط©
  static const _darkStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  );
  static const _lightStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );

  Color get _primary => widget.primaryColor;

  AnimationController get equalizerController => _equalizerController;
  AnimationController get bgController => _bgController;
  Animation<double> get headerFadeAnim => _headerFadeAnim;

  @override
  void initState() {
    super.initState();

    _categories = RecitationCategoriesData.build();
    _stationCategories = RadioStationsData.categories;

    // âœ… ظ‡ظٹظ‘ط¦ ط§ظ„ظ€ controllers ط£ظˆظ„ط§ظ‹
    _equalizerController = RadioAnimationManager.createEqualizer(this);
    _bgController = RadioAnimationManager.createBackground(this);
    _headerController = RadioAnimationManager.createHeaderFade(this);

    _headerFadeAnim = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _tabController = TabController(length: 3, vsync: this);

    // âœ… ط¨ط¹ط¯ ط°ظ„ظƒ ط£ظ†ط´ط¦ طµظپط­ط§طھ ط§ظ„طھط¨ظˆظٹط¨ط§طھ
    _radioTabPage = _RadioTab(
      primary: _primary,
      isTablet: MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).size.width > 600,
      safePadding: MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).padding,
      equalizerController: _equalizerController,
      stationCategories: _stationCategories,
      onStationPlayed: () {},
    );

    _recitationsTabPage = RecitationsScreen(
      primary: _primary,
      embedded: true,
    );

    _videosTabPage = VideoFeedTab(
      primary: _primary,
    );
  }

  @override
  void dispose() {
    VideoCacheManager().pauseAll();
    _equalizerController.dispose();
    _bgController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final safePadding = mediaQuery.padding;
    final isTablet = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? _darkStyle : _lightStyle,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadioColors.background(context),
        body: Stack(
          children: [
            // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
            Positioned.fill(
              child: RepaintBoundary(
                child: NightSkyBackground(
                  controller: _bgController,
                  primary: _primary,
                ),
              ),
            ),

            // â•گâ•گ ط§ظ„ظ…ط­طھظˆظ‰ â•گâ•گ
            Column(
              children: [
                SizedBox(height: safePadding.top + 10),

                // â•گâ•گ ط²ط± ط§ظ„ط±ط¬ظˆط¹ â•گâ•گ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [RadioBackButton(primary: _primary)],
                  ),
                ),

                // â•گâ•گ ط§ظ„ظ‡ظٹط¯ط± â•گâ•گ
                RadioFadeSlideTransition(
                  animation: _headerFadeAnim,
                  child: HeroHeaderWidget(
                    primary: _primary,
                    isTablet: isTablet,
                  ),
                ),

                // â•گâ•گ ط§ظ„طھط¨ظˆظٹط¨ط§طھ â•گâ•گ
                RadioTabBarWidget(
                  tabController: _tabController,
                  primary: _primary,
                  isTablet: isTablet,
                ),

                // â•گâ•گ ط§ظ„ط¨ط­ط« â•گâ•گ
                _buildSearchBar(),

                // â•گâ•گ ط§ظ„ظ…ط­طھظˆظ‰ â•گâ•گ
                Expanded(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (_, __) {
                      return IndexedStack(
                        index: _tabController.index,
                        children: [
                          _radioTabPage,
                          _recitationsTabPage,
                          _videosTabPage,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // â•گâ•گ ط§ظ„ظ…ط´ط؛ظ„ ط§ظ„ط³ظپظ„ظٹ â•گâ•گ
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer3<RadioIntillegence, OfflineRadioService, OnlineSurahService>(
                builder: (_, online, offline, onlineSurah, __) {
                  final hasAny = online.currentStation != null ||
                      offline.currentStation != null ||
                      onlineSurah.currentStation != null;

                  if (!hasAny) {
                    return const SizedBox.shrink();
                  }

                  return RepaintBoundary(
                    child: ModernBottomPlayer(
                      primary: _primary,
                      isTablet: isTablet,
                      safePadding: safePadding,
                      equalizerController: _equalizerController,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // اقرأ القائمة الحية عند الضغط، لا snapshot شاشة الراديو القديم.
        final categories = RecitationCategoriesData.current.isNotEmpty
            ? RecitationCategoriesData.current
            : _categories;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecSearchScreen(
              primary: _primary,
              categories: categories,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        height: 44,
        decoration: BoxDecoration(
          color: RadioColors.searchBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: RadioColors.searchBorder(context, _primary),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 18,
              color: _primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'ابحث عن قارئ، سورة، حفلة...',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: RadioColors.searchHint(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatefulWidget {
  final TabController tabController;
  final Color primary;
  final bool isTablet;
  final EdgeInsets safePadding;
  final AnimationController equalizerController;
  final List<String> stationCategories;
  final VoidCallback onStationPlayed;

  const _TabContent({
    required this.tabController,
    required this.primary,
    required this.isTablet,
    required this.safePadding,
    required this.equalizerController,
    required this.stationCategories,
    required this.onStationPlayed,
  });

  @override
  State<_TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<_TabContent> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabController.index;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // âœ… IndexedStack ظٹط¨ظ‚ظٹ ظƒظ„ط§ ط§ظ„طھط¨ظˆظٹط¨ظٹظ† ظپظٹ ط§ظ„ط°ط§ظƒط±ط©
    // âœ… ظ„ط§ ظٹط¹ظٹط¯ ط¨ظ†ط§ط، ط£ظٹ ظ…ظ†ظ‡ظ…ط§ ط¹ظ†ط¯ ط§ظ„طھط¨ط¯ظٹظ„
    return IndexedStack(
      index: _currentIndex,
      children: [
        _RadioTab(
          primary: widget.primary,
          isTablet: widget.isTablet,
          safePadding: widget.safePadding,
          equalizerController: widget.equalizerController,
          stationCategories: widget.stationCategories,
          onStationPlayed: widget.onStationPlayed,
        ),
        RecitationsScreen(
          primary: widget.primary,
          embedded: true,
        ),
        VideoFeedTab(
          primary: widget.primary,
        ),
      ],
    );
  }
}

class _RadioTab extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final EdgeInsets safePadding;
  final AnimationController equalizerController;
  final List<String> stationCategories;
  final VoidCallback onStationPlayed;

  const _RadioTab({
    required this.primary,
    required this.isTablet,
    required this.safePadding,
    required this.equalizerController,
    required this.stationCategories,
    required this.onStationPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 110 + safePadding.bottom),
      children: [
        RecentListeningWidget(
          primary: primary,
          isTablet: isTablet,
          equalizerController: equalizerController,
          onStationPlayed: onStationPlayed,
        ),

        ...stationCategories.map((cat) {
          final stations = RadioStationsData.byCategory(cat);
          if (stations.isEmpty) return const SizedBox.shrink();
          return CategorySectionWidge(
            category: cat,
            stations: stations,
            primary: primary,
            isTablet: isTablet,
            equalizerController: equalizerController,
            onStationPlayed: onStationPlayed,
          );
        }),

        FavoritesSectionWidget(
          primary: primary,
          isTablet: isTablet,
          equalizerController: equalizerController,
          onStationPlayed: onStationPlayed,
        ),
      ],
    );
  }
}
