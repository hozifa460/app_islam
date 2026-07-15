// lib/screens/radio/recitations_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/helpers/radio_animation_manager.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_category_section.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_mini_player.dart';
import 'package:provider/provider.dart';
import 'data/recitation_categories_data.dart';
import 'services/offline_radio_service.dart';

class RecitationsScreen extends StatefulWidget {
  final Color primary;
  final bool embedded;

  const RecitationsScreen({
    super.key,
    required this.primary,
    this.embedded = false,
  });

  @override
  State<RecitationsScreen> createState() => _RecitationsScreenState();
}

class _RecitationsScreenState extends State<RecitationsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<RecitationCategory> _categories = const [];
  late final AnimationController _equalizerController;
  StreamSubscription<List<RecitationCategory>>? _categoriesSubscription;

  static const double _playerSpace = 120;
  static const double _normalBottomSpace = 40;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _categories = RecitationCategoriesData.build();
    _categoriesSubscription = RecitationCategoriesData.stream.listen((cats) {
      if (!mounted) return;
      setState(() => _categories = cats);
    });
    _equalizerController = RadioAnimationManager.createEqualizer(this);
    unawaited(_initializeRecitations());
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _equalizerController.dispose();
    super.dispose();
  }

  Future<void> _initializeRecitations() async {
    try {
      debugPrint('🔄 RecitationsScreen: initializing remote categories');
      await RecitationCategoriesData.initialize();
      debugPrint(
        '✅ RecitationsScreen: categories ready (${RecitationCategoriesData.current.length})',
      );
    } catch (e) {
      debugPrint('❌ RecitationsScreen: categories initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final safePadding = mediaQuery.padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child:
          widget.embedded
              ? _buildScrollContent(
                isTablet: isTablet,
                safePadding: safePadding,
              )
              : Scaffold(
                backgroundColor: RadioColors.background(context),
                body: Stack(
                  children: [
                    _buildScrollContent(
                      isTablet: isTablet,
                      safePadding: safePadding,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomPlayer(
                        isTablet: isTablet,
                        safePadding: safePadding,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildScrollContent({
    required bool isTablet,
    required EdgeInsets safePadding,
  }) {
    return CustomScrollView(
      key: PageStorageKey('recitations-scroll-${widget.embedded}'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Selector<OfflineRadioService, bool>(
            selector: (_, offline) => offline.currentStation != null,
            builder: (_, hasStation, __) {
              if (!hasStation) return const SizedBox.shrink();
              return Consumer<OfflineRadioService>(
                builder:
                    (_, offline, __) => RepaintBoundary(
                      child: RecMiniPlayer(
                        offline: offline,
                        primary: widget.primary,
                      ),
                    ),
              );
            },
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RecCategorySection(
                category: _categories[index],
                primary: widget.primary,
                isTablet: isTablet,
              ),
              childCount: _categories.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // بطاقتان على الهاتف حتى تبقى صورة واسم التصنيف مقروءين.
              crossAxisCount: isTablet ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // ارتفاع إضافي للهاتف يمنع تكدس الصورة والعنوان والشارة.
              childAspectRatio: isTablet ? 0.95 : 0.80,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Selector<AudioCoordinator, bool>(
            selector: (_, c) => c.hasActivePlayer,
            builder: (_, hasPlayer, __) {
              final height =
                  widget.embedded
                      ? _playerSpace + safePadding.bottom
                      : (hasPlayer ? _playerSpace : _normalBottomSpace) +
                          safePadding.bottom;
              return SizedBox(height: height);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPlayer({
    required bool isTablet,
    required EdgeInsets safePadding,
  }) {
    if (widget.embedded) return const SizedBox.shrink();

    return Consumer3<
      RadioIntillegence,
      OfflineRadioService,
      OnlineSurahService
    >(
      builder: (_, online, offline, onlineSurah, __) {
        final hasAny =
            online.currentStation != null ||
            offline.currentStation != null ||
            onlineSurah.currentStation != null;

        if (!hasAny) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: ModernBottomPlayer(
            primary: widget.primary,
            isTablet: isTablet,
            safePadding: safePadding,
            equalizerController: _equalizerController,
          ),
        );
      },
    );
  }
}
