import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/screens/tasbih/widgets/tasbih_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../auth/services/auth_service.dart';
import 'models/tasbih_model.dart';
import 'services/tasbih_data_service.dart';
import 'widgets/tasbih_theme.dart';
import 'widgets/tasbih_selector.dart';
import 'widgets/tasbih_card.dart';
import 'widgets/tasbih_total_bar.dart';
import 'widgets/tasbih_dialogs.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  // حالة التسبيح
  int counter = 0;
  int round = 1;
  int totalCount = 0;
  int selectedIndex = 0;
  bool _isLoading = true;

  // البيانات
  List<TasbihModel> tasbihList = [];

  // Animation
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  // مفاتيح الحفظ
  static const _kTotal = 'totalTasbih';
  static const _kSelected = 'tasbih_selectedIndex';
  static const _kCounter = 'tasbih_counter';
  static const _kRound = 'tasbih_round';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 130),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      _initData();
    }
  }

  Future<void> _initData() async {
    // ═══ حمّل البيانات المحلية أولاً (سريع جداً) ═══
    final prefs = await SharedPreferences.getInstance();

    // حمّل الإعدادات المحفوظة محلياً بدون انتظار
    setState(() {
      totalCount = prefs.getInt(_kTotal) ?? 0;
      selectedIndex = prefs.getInt(_kSelected) ?? 0;
      counter = prefs.getInt(_kCounter) ?? 0;
      round = prefs.getInt(_kRound) ?? 1;
      if (round < 1) round = 1;
    });

    // ═══ حمّل قائمة التسبيح + أظهر الشاشة فوراً ═══
    final loaded = await TasbihDataService.loadTasbihList();
    if (!mounted) return;

    setState(() {
      tasbihList = loaded;

      // تصحيح selectedIndex بعد تحميل القائمة
      if (selectedIndex < 0 || selectedIndex >= tasbihList.length) {
        selectedIndex = 0;
      }

      _isLoading = false; // ← أظهر الشاشة فوراً
    });

    // ═══ حمّل من السحابة في الخلفية (لا يوقف الشاشة) ═══
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    try {
      final cloud = await auth.loadProgress('tasbih');
      if (cloud == null || cloud is! Map || !mounted) return;

      final cloudTotal = cloud['totalCount'] as int? ?? 0;
      if (cloudTotal > totalCount) {
        setState(() {
          totalCount = cloudTotal;
          selectedIndex = cloud['selectedIndex'] as int? ?? selectedIndex;
          counter = cloud['counter'] as int? ?? counter;
          round = cloud['round'] as int? ?? round;

          if (round < 1) round = 1;
          if (selectedIndex < 0 || selectedIndex >= tasbihList.length) {
            selectedIndex = 0;
          }
        });

        // زامن مع المحلي
        final prefs = await SharedPreferences.getInstance();
        await _saveLocal(prefs);
      }
    } catch (_) {}
  }

// ═══ حفظ محلي ═══
  Future<void> _saveLocal(SharedPreferences prefs) async {
    await prefs.setInt(_kTotal, totalCount);
    await prefs.setInt(_kSelected, selectedIndex);
    await prefs.setInt(_kCounter, counter);
    await prefs.setInt(_kRound, round);
  }

// ═══ حفظ محلي + سحابي ═══
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveLocal(prefs);

    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    try {
      await auth.saveProgress('tasbih', {
        'totalCount': totalCount,
        'selectedIndex': selectedIndex,
        'counter': counter,
        'round': round,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // -------------------------
  // Actions
  // -------------------------
  void _increment() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());

    final target = tasbihList[selectedIndex].target;

    setState(() {
      counter++;
      totalCount++;
    });

    _saveState();

    if (counter >= target) {
      HapticFeedback.heavyImpact();
      _showCompletedDialog(target);
    }
  }

  void _resetCurrent() {
    setState(() {
      counter = 0;
      round = 1;
    });
    _saveState();
  }

  void _switchTasbih(int index) {
    setState(() {
      selectedIndex = index;
      counter = 0;
      round = 1;
    });
    _saveState();
  }

  void _showCompletedDialog(int target) {
    final primary = Theme.of(context).colorScheme.primary;
    TasbihDialogs.showCompletedDialog(
      context: context,
      target: target,
      primaryColor: primary,
      onReset: () {
        setState(() {
          counter = 0;
          round = 1;
        });
        _saveState();
      },
      onNewRound: () {
        setState(() {
          counter = 0;
          round += 1;
        });
        _saveState();
      },
    );
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading || tasbihList.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    final target = tasbihList[selectedIndex].target;
    final progress = (target == 0) ? 0.0 : (counter / target).clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('التسبيح', style: TasbihTheme.appBarTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'إعادة ضبط',
              icon: const Icon(Icons.refresh),
              onPressed: _resetCurrent,
            ),
          ],
        ),
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(decoration: const BoxDecoration(gradient: TasbihTheme.backgroundGradient)),

            // ظل مسجد
            Positioned(
              left: -40,
              bottom: -20,
              child: Icon(Icons.mosque,
                  size: 240, color: TasbihTheme.mosqueOverlay),
            ),
            Positioned(
              right: -30,
              bottom: 40,
              child: Icon(Icons.mosque,
                  size: 200, color: TasbihTheme.mosqueOverlay2),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ✅ الهيدر
                  const TasbihHeader(),
                  const SizedBox(height: 14),

                  // ✅ شريط الاختيار
                  TasbihSelector(
                    tasbihList: tasbihList,
                    selectedIndex: selectedIndex,
                    onSelected: _switchTasbih,
                  ),
                  const SizedBox(height: 16),

                  // ✅ الكارت والإجمالي
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // الكارت الرئيسي
                          TasbihCard(
                            currentTasbih: tasbihList[selectedIndex],
                            counter: counter,
                            round: round,
                            progress: progress,
                            primaryColor: primary,
                            scaleAnimation: _scaleAnimation,
                            onTap: _increment,
                          ),
                          const SizedBox(height: 14),

                          // شريط الإجمالي
                          TasbihTotalBar(
                            totalCount: totalCount,
                            primaryColor: primary,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
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
}