import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'model/sunnah_model.dart';
import 'services/sunnah_service.dart';
import 'widgets/sunnah_theme.dart';
import 'widgets/sunnah_splash.dart';
import 'widgets/sunnah_header.dart';
import 'widgets/sunnah_tab_bar_widget.dart';
import 'widgets/sunnah_current_tab.dart';
import 'widgets/sunnah_all_tab.dart';
import 'widgets/sunnah_details_sheet.dart';

class SunnahTrackerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const SunnahTrackerScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<SunnahTrackerScreen> createState() => _SunnahTrackerScreenState();
}

class _SunnahTrackerScreenState extends State<SunnahTrackerScreen>
    with TickerProviderStateMixin {
  final SunnahService _service = SunnahService();
  bool _isLoading = true;
  late Timer _timer;

  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  late AnimationController _fadeInController;

  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _floatingAnim;
  late Animation<double> _fadeInAnim;

  late TabController _tabController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['الكل', 'مؤكدة', 'مستحبة', 'غير مكتملة'];

  late SunnahTheme _theme;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _initAnimations() {
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeInController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    _floatingAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _fadeInAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadData() async {
    await _service.loadData();
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeInController.forward();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    _fadeInController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showDetails(SunnahModel sunnah) {
    final size = MediaQuery.of(context).size;
    SunnahDetailsSheet.show(
      context: context,
      sunnah: sunnah,
      size: size,
      theme: _theme,
      service: _service,
      onStateChanged: () => setState(() {}),
    );
  }

  Future<void> _toggleCompletion(int id) async {
    await _service.toggleCompletion(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _theme = SunnahTheme(isDark: widget.isDarkMode);
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _theme.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: _theme.bg,
          body: _isLoading
              ? SunnahSplash(
            size: size,
            padding: padding,
            theme: _theme,
            pulseController: _pulseController,
            pulseAnim: _pulseAnim,
          )
              : _buildBody(size, padding),
        ),
      ),
    );
  }

  Widget _buildBody(Size size, EdgeInsets padding) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Column(
        children: [
          SunnahHeader(
            size: size,
            theme: _theme,
            service: _service,
            pulseController: _pulseController,
            pulseAnim: _pulseAnim,
            shimmerAnim: _shimmerAnim,
            onToggleTheme: widget.onToggleTheme,
          ),
          SunnahTabBarWidget(
            size: size,
            theme: _theme,
            service: _service,
            tabController: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SunnahCurrentTab(
                  size: size,
                  theme: _theme,
                  service: _service,
                  pulseController: _pulseController,
                  pulseAnim: _pulseAnim,
                  floatingController: _floatingController,
                  floatingAnim: _floatingAnim,
                  tabController: _tabController,
                  onRefresh: _loadData,
                  onShowDetails: _showDetails,
                  onToggle: _toggleCompletion,
                ),
                SunnahAllTab(
                  size: size,
                  theme: _theme,
                  service: _service,
                  selectedFilterIndex: _selectedFilterIndex,
                  filters: _filters,
                  pulseController: _pulseController,
                  pulseAnim: _pulseAnim,
                  onRefresh: _loadData,
                  onFilterChanged: (i) =>
                      setState(() => _selectedFilterIndex = i),
                  onShowDetails: _showDetails,
                  onToggle: _toggleCompletion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}