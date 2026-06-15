import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/hasanat/services/deeds_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../languages/app_localizations.dart';
import '../auth/services/auth_service.dart';
import 'models/deed_model.dart';
import 'widgets/hasanat_stats_section.dart';
import 'widgets/hasanat_deed_card.dart';
import 'widgets/hasanat_dialogs.dart';

class HasanatScreen extends StatefulWidget {
  const HasanatScreen({super.key});

  @override
  State<HasanatScreen> createState() => _HasanatScreenState();
}

class _HasanatScreenState extends State<HasanatScreen>
    with TickerProviderStateMixin {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  int palmTrees = 0;
  int palaces = 0;
  int hasanat = 0;
  int jewels = 0;
  int lights = 0;
  int doors = 0;
  int shields = 0;
  int scales = 0;

  Map<String, int> progressCounters = {
    'palace': 0,
    'door': 0,
    'jewel': 0,
    'palm': 0,
    'shield': 0,
    'scale': 0,
  };

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  int _lastTappedIndex = -1;
  ScaffoldMessengerState? _scaffoldMessenger;

  List<DeedModel> deeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaffoldMessenger = null; // ظ†ط¸ظ‘ظپ ط§ظ„ظ…ط±ط¬ط¹
    super.dispose();
  }

  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ط§ط­ظپط¸ ظ…ط±ط¬ط¹ ScaffoldMessenger ظ‡ظ†ط§ ط¨ط£ظ…ط§ظ†
    _scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!_dataLoaded) {
      _dataLoaded = true;
      _initData();
    }
  }

  Future<void> _initData() async {
    // 1. ط¬ظ„ط¨ ظ„ط؛ط© ط§ظ„طھط·ط¨ظٹظ‚ ط§ظ„ط­ط§ظ„ظٹط© (طھط£ظƒط¯ ظ…ظ† ظˆط¬ظˆط¯ ط§ط³طھط¯ط¹ط§ط، ظ…ظ„ظپ ط§ظ„طھط±ط¬ظ…ط© ط£ط¹ظ„ظ‰ ط§ظ„ط´ط§ط´ط©)
    final String currentLang = context.tr.locale.languageCode;

    final prefs = await SharedPreferences.getInstance();

    // â•گâ•گâ•گ ط­ظ…ظ‘ظ„ ظ…ط­ظ„ظٹط§ظ‹ ط£ظˆظ„ط§ظ‹ â•گâ•گâ•گ
    setState(() {
      palmTrees = prefs.getInt('palmTrees') ?? 0;
      palaces = prefs.getInt('palaces') ?? 0;
      hasanat = prefs.getInt('hasanat') ?? 0;
      jewels = prefs.getInt('jewels') ?? 0;
      lights = prefs.getInt('lights') ?? 0;
      doors = prefs.getInt('doors') ?? 0;
      shields = prefs.getInt('shields') ?? 0;
      scales = prefs.getInt('scales') ?? 0;
      for (final key in progressCounters.keys) {
        progressCounters[key] = prefs.getInt('prog_$key') ?? 0;
      }
    });

    // â•گâ•گâ•گ ط­ظ…ظ‘ظ„ ط§ظ„ط£ط¹ظ…ط§ظ„ + ط£ط¸ظ‡ط± ط§ظ„ط´ط§ط´ط© ظپظˆط±ط§ظ‹ â•گâ•گâ•گ
    // 2. ظ†ظ…ط±ط± ط§ظ„ظ„ط؛ط© ط§ظ„ط­ط§ظ„ظٹط© ظ„ط®ط¯ظ…ط© ط§ظ„ط¨ظٹط§ظ†ط§طھ ظ‡ظ†ط§ ًں‘‡
    final loadedDeeds = await DeedsService.loadDeeds(currentLang);

    if (!mounted) return;

    setState(() {
      deeds = loadedDeeds;
      _isLoading = false; // â†گ ط£ط¸ظ‡ط± ط§ظ„ط´ط§ط´ط© ظپظˆط±ط§ظ‹
    });

    // â•گâ•گâ•گ ط­ظ…ظ‘ظ„ ظ…ظ† ط§ظ„ط³ط­ط§ط¨ط© ظپظٹ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گâ•گ
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    try {
      final cloud = await auth.loadProgress('hasanat');
      if (cloud == null || cloud is! Map || !mounted) return;

      final cloudHasanat = cloud['hasanat'] as int? ?? 0;
      if (cloudHasanat > hasanat) {
        setState(() {
          palmTrees = cloud['palmTrees'] as int? ?? palmTrees;
          palaces = cloud['palaces'] as int? ?? palaces;
          hasanat = cloudHasanat;
          jewels = cloud['jewels'] as int? ?? jewels;
          lights = cloud['lights'] as int? ?? lights;
          doors = cloud['doors'] as int? ?? doors;
          shields = cloud['shields'] as int? ?? shields;
          scales = cloud['scales'] as int? ?? scales;

          if (cloud['progressCounters'] is Map) {
            final cp = Map<String, dynamic>.from(
                cloud['progressCounters']);
            for (final key in progressCounters.keys) {
              progressCounters[key] = cp[key] as int? ?? 0;
            }
          }
        });

        final prefs = await SharedPreferences.getInstance();
        await _saveLocal(prefs);
      }
    } catch (_) {}
  }

// â•گâ•گâ•گ ط­ظپط¸ ظ…ط­ظ„ظٹ â•گâ•گâ•گ
  Future<void> _saveLocal(SharedPreferences prefs) async {
    await prefs.setInt('palmTrees', palmTrees);
    await prefs.setInt('palaces', palaces);
    await prefs.setInt('hasanat', hasanat);
    await prefs.setInt('jewels', jewels);
    await prefs.setInt('lights', lights);
    await prefs.setInt('doors', doors);
    await prefs.setInt('shields', shields);
    await prefs.setInt('scales', scales);
    for (final entry in progressCounters.entries) {
      await prefs.setInt('prog_${entry.key}', entry.value);
    }
  }

// â•گâ•گâ•گ ط­ظپط¸ ظ…ط­ظ„ظٹ + ط³ط­ط§ط¨ظٹ â•گâ•گâ•گ
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveLocal(prefs);

    // ط§ظ„ط³ط­ط§ط¨ط©
    if (!mounted) return;
    final auth = context.read<AuthService>();
    if (auth.user?.isGuest ?? true) return;

    try {
      await auth.saveProgress('hasanat', {
        'palmTrees': palmTrees,
        'palaces': palaces,
        'hasanat': hasanat,
        'jewels': jewels,
        'lights': lights,
        'doors': doors,
        'shields': shields,
        'scales': scales,
        'progressCounters': progressCounters,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  void _addDeed(int index) {
    HapticFeedback.mediumImpact();
    _bounceController.forward().then((_) => _bounceController.reverse());

    final deed = deeds[index];
    final type = deed.type;
    final target = deed.target;
    String? rewardMessage;

    setState(() {
      _lastTappedIndex = index;

      if (type == 'hasana') {
        final val = deed.hasanaValue ?? 10;
        hasanat += val;

        if (target > 1) {
          progressCounters[type] = (progressCounters[type] ?? 0) + 1;
          if (progressCounters[type]! >= target) {
            progressCounters[type] = 0;
            rewardMessage = deed.reward;
          }
        } else {
          rewardMessage = deed.reward;
        }
      } else if (target > 1) {
        progressCounters[type] = (progressCounters[type] ?? 0) + 1;
        if (progressCounters[type]! >= target) {
          progressCounters[type] = 0;
          _incrementType(type);
          rewardMessage = deed.reward;
        }
      } else {
        _incrementType(type);
        rewardMessage = deed.reward;
      }
    });

    _saveData();

    // âœ… ط§ظ„ط­ظ„ ط§ظ„طµط­ظٹط­ - ط¨ط¹ط¯ Frame ظˆط¨ط¯ظˆظ† context
    if (rewardMessage != null) {
      final msg = rewardMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionSnackbar(msg);
      });
    }
  }

  void _incrementType(String type) {
    switch (type) {
      case 'palm':
        palmTrees++;
        break;
      case 'palace':
        palaces++;
        break;
      case 'jewel':
        jewels++;
        break;
      case 'light':
        lights++;
        break;
      case 'door':
        doors++;
        break;
      case 'shield':
        shields++;
        break;
      case 'scale':
        scales++;
        break;
    }
  }

  void _showCompletionSnackbar(String message) {
    // âœ… ط§ط³طھط®ط¯ظ… ط§ظ„ظ…ط±ط¬ط¹ ط§ظ„ظ…ط­ظپظˆط¸ ط¨ط¯ظ„ط§ظ‹ ظ…ظ† context
    final messenger = _scaffoldMessenger;
    if (messenger == null) return;

    try {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: _gold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {}
  }

  void _resetAll() {
    HasanatDialogs.showResetDialog(
      context: context,
      bgCard: _bgCard,
      gold: _gold,
      onReset: () async {
        setState(() {
          palmTrees = 0;
          palaces = 0;
          hasanat = 0;
          jewels = 0;
          lights = 0;
          doors = 0;
          shields = 0;
          scales = 0;
          progressCounters = {
            'palace': 0,
            'door': 0,
            'jewel': 0,
            'palm': 0,
            'shield': 0,
            'scale': 0,
          };
        });
        await _saveData(); // ظٹط­ظپط¸ ط§ظ„طµظپط± ظ…ط­ظ„ظٹط§ظ‹ ظˆط³ط­ط§ط¨ظٹط§ظ‹
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Directionality(
      textDirection: context.tr.textDirection, // ًں‘ˆ طھظ…طھ ط§ظ„ط¥ط¶ط§ظپط© ظ„ظٹط¯ط¹ظ… LTR
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.tr.hasanatHarvestTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: textColor,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh,
                    color: Colors.redAccent, size: 20),
                onPressed: _resetAll,
                tooltip: context.tr.resetTooltip,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // âœ… ظ‚ط³ظ… ط§ظ„ط¥ط­طµط§ط¦ظٹط§طھ
              SliverToBoxAdapter(
                child: HasanatStatsSection(
                  isDark: isDark,
                  isSmall: isSmall,
                  textColor: textColor,
                  gold: _gold,
                  bgCard: _bgCard,
                  palmTrees: palmTrees,
                  palaces: palaces,
                  hasanat: hasanat,
                  jewels: jewels,
                  lights: lights,
                  doors: doors,
                  shields: shields,
                  scales: scales,
                  bounceAnim: _bounceAnim,
                  lastTappedIndex: _lastTappedIndex,
                  deeds: deeds,
                ),
              ),

              // âœ… ط¹ظ†ظˆط§ظ† ط§ظ„ظ‚ط³ظ…
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr.deedsAndRewards, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                          style: GoogleFonts.cairo(
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.tr.azkarCount(deeds.length), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: _gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // âœ… ظ‚ط§ط¦ظ…ط© ط§ظ„ط£ط¹ظ…ط§ظ„
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => HasanatDeedCard(
                      index: index,
                      deed: deeds[index],
                      isDark: isDark,
                      isSmall: isSmall,
                      textColor: textColor,
                      subColor: subColor,
                      progressCounters: progressCounters,
                      onAddDeed: _addDeed,
                    ),
                    childCount: deeds.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }
}