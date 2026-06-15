// lib/screens/radio/widgets_recitations/rec_category_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_animations.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_detail_background.dart';
import 'package:provider/provider.dart';
import '../services/Radio_Intillegence.dart';
import '../services/audio_coordinator.dart';
import '../services/offline_radio_service.dart';
import '../services/online_surah_service.dart';
import 'rec_detail_app_bar.dart';
import 'rec_search_bar.dart';
import 'rec_reciters_list.dart';

/// ══════════════════════════════════════════════════════════════
/// شاشة تفاصيل التصنيف (See all)
/// ══════════════════════════════════════════════════════════════
class RecCategoryDetailScreen extends StatefulWidget {
  final RecitationCategory category;
  final Color primary;

  const RecCategoryDetailScreen({
    super.key,
    required this.category,
    required this.primary,
  });

  @override
  State<RecCategoryDetailScreen> createState() =>
      _RecCategoryDetailScreenState();
}

class _RecCategoryDetailScreenState extends State<RecCategoryDetailScreen>
    with TickerProviderStateMixin {

  // ✅ Helper بدل Mixin
  final RecDetailAnimationHelper _animHelper = RecDetailAnimationHelper();

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<RecitationItem> get _filtered {
    if (_searchQuery.isEmpty) return widget.category.items;

    return widget.category.items.where((item) {
      // ══ بحث في العنوان والوصف ══
      final matchesMain = item.title.contains(_searchQuery) ||
          item.subtitle.contains(_searchQuery);

      // ══ بحث داخل العناصر الفرعية ══
      final matchesSub = item.hasSubItems &&
          item.subItems!.any((sub) =>
          sub.title.contains(_searchQuery) ||
              sub.subtitle.contains(_searchQuery));

      return matchesMain || matchesSub;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animHelper.init(this);
  }

  @override
  void dispose() {
    _animHelper.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final isTablet = size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RecColors.background(context),
        body: Stack(
          children: [
            // ══ الخلفية ══
            Positioned.fill(
              child: RecDetailBackground(
                controller: _animHelper.bgController,
                colors: widget.category.gradientColors,
              ),
            ),

            // ══ المحتوى ══
            Column(
              children: [
                SizedBox(height: safePadding.top),

                RecDetailAppBar(
                  category: widget.category,
                  isTablet: isTablet,
                  onBack: () => Navigator.pop(context),
                ),

                RecSearchBar(
                  controller: _searchController,
                  primary: widget.primary,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),

                Expanded(
                  child: RecRecitersList(
                    items: _filtered,
                    primary: widget.primary,
                    gradientColors: widget.category.gradientColors,
                    isTablet: isTablet,
                    categoryId: widget.category.id,
                  ),
                ),
              ],
            ),

            // ══ المشغل السفلي ══
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
                      primary: widget.primary,
                      isTablet: isTablet,
                      safePadding: safePadding,
                      equalizerController: _animHelper.equalizerController,
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
}