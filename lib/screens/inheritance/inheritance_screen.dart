import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../languages/app_localizations.dart';
import '../../models/inheritance_models.dart';
import '../../services/inheritance/inheritance_calculator.dart';
import '../../services/inheritance/land_calculator.dart';

// Import widgets
import 'widgets/inheritance_header_widget.dart';
import 'widgets/deceased_gender_widget.dart';
import 'widgets/estate_type_widget.dart';
import 'widgets/estate_input_widget.dart';
import 'widgets/heirs_selection_widget.dart';
import 'widgets/inheritance_results_widget.dart';
import 'widgets/unit_conversion_widget.dart';
import 'widgets/sharia_warnings_widget.dart';
import 'widgets/references_widget.dart';

class InheritanceScreen extends StatefulWidget {
  final List<Color> appColors;
  final int selectedColorIndex;
  final bool isDarkMode;

  const InheritanceScreen({
    Key? key,
    required this.appColors,
    required this.selectedColorIndex,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<InheritanceScreen> createState() => _InheritanceScreenState();
}

class _InheritanceScreenState extends State<InheritanceScreen>
    with TickerProviderStateMixin {
  Color get _primary => widget.appColors[widget.selectedColorIndex];
  bool get isDarkMode => widget.isDarkMode;

  // Controllers
  final TextEditingController _estateController = TextEditingController();
  final TextEditingController _feddanController = TextEditingController();
  final TextEditingController _qiratController = TextEditingController();
  final TextEditingController _sahmController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultsKey = GlobalKey();

  final InheritanceCalculator _calculator = InheritanceCalculator();

  // Animation
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnimation;

  // State
  InheritanceResult? _result;
  FullInheritanceResult? _fullResult;
  bool _isMaleDeceased = true;
  EstateType _estateType = EstateType.money;
  late List<SelectedHeir> _availableHeirs;

  final Color _gold = const Color(0xFFD4A847);

  @override
  void initState() {
    super.initState();
    _updateAvailableHeirs();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _estateController.dispose();
    _feddanController.dispose();
    _qiratController.dispose();
    _sahmController.dispose();
    _scrollController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  void _updateAvailableHeirs() {
    _availableHeirs = _isMaleDeceased
        ? [
      SelectedHeir(type: HeirType.wife, nameAr: ''),
      SelectedHeir(type: HeirType.mother, nameAr: ''),
      SelectedHeir(type: HeirType.father, nameAr: ''),
      SelectedHeir(type: HeirType.grandmother, nameAr: ''),
      SelectedHeir(type: HeirType.grandfather, nameAr: ''),
      SelectedHeir(type: HeirType.son, nameAr: ''),
      SelectedHeir(type: HeirType.daughter, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfSon, nameAr: ''),
      SelectedHeir(type: HeirType.sonsDaughter, nameAr: ''),
      SelectedHeir(type: HeirType.brother, nameAr: ''),
      SelectedHeir(type: HeirType.sister, nameAr: ''),
      SelectedHeir(type: HeirType.halfBrotherFather, nameAr: ''),
      SelectedHeir(type: HeirType.halfSisterFather, nameAr: ''),
      SelectedHeir(type: HeirType.halfBrotherMother, nameAr: ''),
      SelectedHeir(type: HeirType.halfSisterMother, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfBrother, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfHalfBrotherFather, nameAr: ''),
      SelectedHeir(type: HeirType.uncle, nameAr: ''),
      SelectedHeir(type: HeirType.halfUncleFather, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfUncle, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfHalfUncleFather, nameAr: ''),
    ]
        : [
      SelectedHeir(type: HeirType.husband, nameAr: ''),
      SelectedHeir(type: HeirType.mother, nameAr: ''),
      SelectedHeir(type: HeirType.father, nameAr: ''),
      SelectedHeir(type: HeirType.grandmother, nameAr: ''),
      SelectedHeir(type: HeirType.grandfather, nameAr: ''),
      SelectedHeir(type: HeirType.son, nameAr: ''),
      SelectedHeir(type: HeirType.daughter, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfSon, nameAr: ''),
      SelectedHeir(type: HeirType.sonsDaughter, nameAr: ''),
      SelectedHeir(type: HeirType.brother, nameAr: ''),
      SelectedHeir(type: HeirType.sister, nameAr: ''),
      SelectedHeir(type: HeirType.halfBrotherFather, nameAr: ''),
      SelectedHeir(type: HeirType.halfSisterFather, nameAr: ''),
      SelectedHeir(type: HeirType.halfBrotherMother, nameAr: ''),
      SelectedHeir(type: HeirType.halfSisterMother, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfBrother, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfHalfBrotherFather, nameAr: ''),
      SelectedHeir(type: HeirType.uncle, nameAr: ''),
      SelectedHeir(type: HeirType.halfUncleFather, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfUncle, nameAr: ''),
      SelectedHeir(type: HeirType.sonOfHalfUncleFather, nameAr: ''),
    ];
  }

  String _getHeirName(BuildContext context, HeirType type) {
    switch (type) {
      case HeirType.husband:
        return context.tr.husband;
      case HeirType.wife:
        return context.tr.wife;
      case HeirType.mother:
        return context.tr.mother;
      case HeirType.father:
        return context.tr.father;
      case HeirType.grandmother:
        return context.tr.grandmother;
      case HeirType.grandfather:
        return context.tr.grandfather;
      case HeirType.son:
        return context.tr.son;
      case HeirType.daughter:
        return context.tr.daughter;
      case HeirType.sonOfSon:
        return context.tr.sonOfSon;
      case HeirType.sonsDaughter:
        return context.tr.sonsDaughter;
      case HeirType.brother:
        return context.tr.brother;
      case HeirType.sister:
        return context.tr.sister;
      case HeirType.halfBrotherFather:
        return context.tr.halfBrotherFather;
      case HeirType.halfSisterFather:
        return context.tr.halfSisterFather;
      case HeirType.halfBrotherMother:
        return context.tr.halfBrotherMother;
      case HeirType.halfSisterMother:
        return context.tr.halfSisterMother;
      case HeirType.sonOfBrother:
        return context.tr.sonOfBrother;
      case HeirType.sonOfHalfBrotherFather:
        return context.tr.sonOfHalfBrotherFather;
      case HeirType.uncle:
        return context.tr.uncle;
      case HeirType.halfUncleFather:
        return context.tr.halfUncleFather;
      case HeirType.sonOfUncle:
        return context.tr.sonOfUncle;
      case HeirType.sonOfHalfUncleFather:
        return context.tr.sonOfHalfUncleFather;
      default:
        return '';
    }
  }

  int get _selectedHeirsCount => _availableHeirs.where((h) => h.isSelected).length;

  void _calculateInheritance() {
    List<SelectedHeir> selectedHeirs = _availableHeirs.where((h) => h.isSelected).toList();
    if (selectedHeirs.isEmpty) {
      _showError(context.tr.pleaseSelectHeirs);
      return;
    }

    double moneyAmount = 0;
    LandEstate? landEstate;

    if (_estateType == EstateType.money || _estateType == EstateType.both) {
      moneyAmount = double.tryParse(_estateController.text) ?? 0;
      if (_estateType == EstateType.money && moneyAmount <= 0) {
        _showError(context.tr.pleaseEnterMoneyAmount);
        return;
      }
    }

    if (_estateType == EstateType.land || _estateType == EstateType.both) {
      int feddans = int.tryParse(_feddanController.text) ?? 0;
      int qirats = int.tryParse(_qiratController.text) ?? 0;
      int sahms = int.tryParse(_sahmController.text) ?? 0;

      String? landError = LandCalculator.validateLandInput(feddans, qirats, sahms);
      if (_estateType == EstateType.land && landError != null) {
        _showError(landError);
        return;
      }
      if (_estateType == EstateType.both && feddans == 0 && qirats == 0 && sahms == 0 && moneyAmount <= 0) {
        _showError(context.tr.pleaseEnterEstateValue);
        return;
      }

      landEstate = LandEstate(feddans: feddans, qirats: qirats, sahms: sahms);
    }

    double estateForCalc = _estateType == EstateType.land ? 100 : moneyAmount;
    if (estateForCalc <= 0) estateForCalc = 100;

    List<Heir> heirsList = selectedHeirs
        .map((sh) => Heir(type: sh.type, nameAr: _getHeirName(context, sh.type), count: sh.count))
        .toList();

    InheritanceResult result = _calculator.calculate(heirsList, estateForCalc);

    List<HeirLandShare>? landShares;
    if (landEstate != null && landEstate.totalInQirats > 0) {
      landShares = LandCalculator.calculateLandShares(landEstate, result);
    }

    setState(() {
      _result = result;
      _fullResult = FullInheritanceResult(
        baseResult: result,
        totalLand: landEstate,
        landShares: landShares,
        moneyAmount: moneyAmount > 0 ? moneyAmount : null,
        estateType: _estateType,
      );
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_resultsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultsKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onGenderChanged(bool isMale) {
    setState(() {
      _isMaleDeceased = isMale;
      _updateAvailableHeirs();
      _result = null;
      _fullResult = null;
    });
  }

  void _onEstateTypeChanged(EstateType type) {
    setState(() {
      _estateType = type;
      _result = null;
      _fullResult = null;
    });
  }

  void _onHeirsChanged() {
    setState(() {
      _result = null;
      _fullResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0A0E17) : const Color(0xFFF5F3EE);
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar
            _buildSliverAppBar(context),

            // Content
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 40 : 16,
                vertical: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bismillah Header
                        InheritanceHeaderWidget(
                          primaryColor: _primary,
                          isDarkMode: isDarkMode,
                          animation: _headerAnimation,
                        ),
                        const SizedBox(height: 16),

                        // Deceased Gender
                        DeceasedGenderWidget(
                          isMaleDeceased: _isMaleDeceased,
                          primaryColor: _primary,
                          isDarkMode: isDarkMode,
                          onGenderChanged: _onGenderChanged,
                        ),
                        const SizedBox(height: 16),

                        // Estate Type
                        EstateTypeWidget(
                          estateType: _estateType,
                          isDarkMode: isDarkMode,
                          onTypeChanged: _onEstateTypeChanged,
                        ),
                        const SizedBox(height: 16),

                        // Estate Input
                        EstateInputWidget(
                          estateType: _estateType,
                          estateController: _estateController,
                          feddanController: _feddanController,
                          qiratController: _qiratController,
                          sahmController: _sahmController,
                          isDarkMode: isDarkMode,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        // Heirs Selection
                        HeirsSelectionWidget(
                          availableHeirs: _availableHeirs,
                          selectedCount: _selectedHeirsCount,
                          isDarkMode: isDarkMode,
                          primaryColor: _primary,
                          onHeirsChanged: _onHeirsChanged,
                        ),
                        const SizedBox(height: 20),

                        // Calculate Button
                        _buildCalculateButton(context),
                        const SizedBox(height: 20),

                        // Results
                        if (_fullResult != null)
                          Container(
                            key: _resultsKey,
                            child: InheritanceResultsWidget(
                              result: _result!,
                              fullResult: _fullResult!,
                              isDarkMode: isDarkMode,
                              primaryColor: _primary,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Unit Conversion
                        UnitConversionWidget(isDarkMode: isDarkMode),
                        const SizedBox(height: 16),

                        // Sharia Warnings
                        ShariaWarningsWidget(isDarkMode: isDarkMode),
                        const SizedBox(height: 16),

                        // References
                        ReferencesWidget(isDarkMode: isDarkMode),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = (screenHeight * 0.18).clamp(100.0, 160.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      floating: false,
      backgroundColor: _primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
          final expandRatio = ((top - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
          final isCollapsed = expandRatio < 0.3;

          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: isCollapsed
                ? Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.tr.inheritanceCalculatorTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            )
                : null,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primary,
                        _primary.withOpacity(0.85),
                        isDarkMode ? const Color(0xFF0D3B2E) : _primary.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),

                // Pattern
                Opacity(
                  opacity: expandRatio,
                  child: CustomPaint(
                    painter: _IslamicPatternPainter(color: Colors.white.withOpacity(0.03)),
                  ),
                ),

                // Content
                SafeArea(
                  child: Opacity(
                    opacity: expandRatio,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: _gold.withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.balance_rounded,
                              color: _gold,
                              size: (expandedHeight * 0.18).clamp(20.0, 28.0),
                            ),
                          ),
                          SizedBox(height: expandedHeight * 0.05),
                          // Title
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.tr.islamicInheritanceCalc,
                              style: TextStyle(
                                fontSize: (expandedHeight * 0.14).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Curve
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0A0E17) : const Color(0xFFF5F3EE),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [_primary, _primary.withOpacity(0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _calculateInheritance,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr.calculateInheritance,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Islamic Pattern Painter
class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 40.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawOctagon(canvas, Offset(x, y), spacing * 0.3, paint);
      }
    }
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}