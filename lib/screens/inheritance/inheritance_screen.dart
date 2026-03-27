// screens/inheritance_screen.dart

import 'package:flutter/material.dart';
import '../../models/inheritance_models.dart';
import '../../services/inheritance/inheritance_calculator.dart';
import '../../services/inheritance/land_calculator.dart';

class InheritanceScreen extends StatefulWidget {
  final List<Color> appColors;
  final int selectedColorIndex;
  final bool isDarkMode;
  const InheritanceScreen({Key? key,
    required this.appColors,
    required this.selectedColorIndex,
    required this.isDarkMode
  }) : super(key: key);

  @override
  State<InheritanceScreen> createState() => _InheritanceScreenState();
}

class _InheritanceScreenState extends State<InheritanceScreen> {

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

  // State
  InheritanceResult? _result;
  FullInheritanceResult? _fullResult;
  bool _isMaleDeceased = true;
  EstateType _estateType = EstateType.money;
  late List<SelectedHeir> _availableHeirs;

  @override
  void initState() {
    super.initState();
    _updateAvailableHeirs();
  }

  void _updateAvailableHeirs() {
    _availableHeirs = _isMaleDeceased
        ? [
      SelectedHeir(type: HeirType.wife, nameAr: 'الزوجة'),
      SelectedHeir(type: HeirType.mother, nameAr: 'الأم'),
      SelectedHeir(type: HeirType.father, nameAr: 'الأب'),
      SelectedHeir(type: HeirType.grandmother, nameAr: 'الجدة'),
      SelectedHeir(type: HeirType.grandfather, nameAr: 'الجد'),
      SelectedHeir(type: HeirType.son, nameAr: 'الابن'),
      SelectedHeir(type: HeirType.daughter, nameAr: 'البنت'),
      SelectedHeir(type: HeirType.sonOfSon, nameAr: 'ابن الابن'),
      SelectedHeir(type: HeirType.sonsDaughter, nameAr: 'بنت الابن'),
      SelectedHeir(type: HeirType.brother, nameAr: 'الأخ الشقيق'),
      SelectedHeir(type: HeirType.sister, nameAr: 'الأخت الشقيقة'),
      SelectedHeir(
          type: HeirType.halfBrotherFather, nameAr: 'الأخ لأب'),
      SelectedHeir(
          type: HeirType.halfSisterFather, nameAr: 'الأخت لأب'),
      SelectedHeir(
          type: HeirType.halfBrotherMother, nameAr: 'الأخ لأم'),
      SelectedHeir(
          type: HeirType.halfSisterMother, nameAr: 'الأخت لأم'),
      SelectedHeir(
          type: HeirType.sonOfBrother, nameAr: 'ابن الأخ الشقيق'),
      SelectedHeir(
          type: HeirType.sonOfHalfBrotherFather,
          nameAr: 'ابن الأخ لأب'),
      SelectedHeir(type: HeirType.uncle, nameAr: 'العم الشقيق'),
      SelectedHeir(
          type: HeirType.halfUncleFather, nameAr: 'العم لأب'),
      SelectedHeir(
          type: HeirType.sonOfUncle, nameAr: 'ابن العم الشقيق'),
      SelectedHeir(
          type: HeirType.sonOfHalfUncleFather,
          nameAr: 'ابن العم لأب'),
    ]
        : [
      SelectedHeir(type: HeirType.husband, nameAr: 'الزوج'),
      SelectedHeir(type: HeirType.mother, nameAr: 'الأم'),
      SelectedHeir(type: HeirType.father, nameAr: 'الأب'),
      SelectedHeir(type: HeirType.grandmother, nameAr: 'الجدة'),
      SelectedHeir(type: HeirType.grandfather, nameAr: 'الجد'),
      SelectedHeir(type: HeirType.son, nameAr: 'الابن'),
      SelectedHeir(type: HeirType.daughter, nameAr: 'البنت'),
      SelectedHeir(type: HeirType.sonOfSon, nameAr: 'ابن الابن'),
      SelectedHeir(type: HeirType.sonsDaughter, nameAr: 'بنت الابن'),
      SelectedHeir(type: HeirType.brother, nameAr: 'الأخ الشقيق'),
      SelectedHeir(type: HeirType.sister, nameAr: 'الأخت الشقيقة'),
      SelectedHeir(
          type: HeirType.halfBrotherFather, nameAr: 'الأخ لأب'),
      SelectedHeir(
          type: HeirType.halfSisterFather, nameAr: 'الأخت لأب'),
      SelectedHeir(
          type: HeirType.halfBrotherMother, nameAr: 'الأخ لأم'),
      SelectedHeir(
          type: HeirType.halfSisterMother, nameAr: 'الأخت لأم'),
      SelectedHeir(
          type: HeirType.sonOfBrother, nameAr: 'ابن الأخ الشقيق'),
      SelectedHeir(
          type: HeirType.sonOfHalfBrotherFather,
          nameAr: 'ابن الأخ لأب'),
      SelectedHeir(type: HeirType.uncle, nameAr: 'العم الشقيق'),
      SelectedHeir(
          type: HeirType.halfUncleFather, nameAr: 'العم لأب'),
      SelectedHeir(
          type: HeirType.sonOfUncle, nameAr: 'ابن العم الشقيق'),
      SelectedHeir(
          type: HeirType.sonOfHalfUncleFather,
          nameAr: 'ابن العم لأب'),
    ];
  }

  // ============ عدد الورثة المختارين ============
  int get _selectedHeirsCount =>
      _availableHeirs.where((h) => h.isSelected).length;

  // ============ الحساب ============
  void _calculateInheritance() {
    List<SelectedHeir> selectedHeirs =
    _availableHeirs.where((h) => h.isSelected).toList();
    if (selectedHeirs.isEmpty) {
      _showError('الرجاء اختيار الورثة');
      return;
    }

    double moneyAmount = 0;
    LandEstate? landEstate;

    if (_estateType == EstateType.money || _estateType == EstateType.both) {
      moneyAmount = double.tryParse(_estateController.text) ?? 0;
      if (_estateType == EstateType.money && moneyAmount <= 0) {
        _showError('الرجاء إدخال قيمة التركة النقدية');
        return;
      }
    }

    if (_estateType == EstateType.land || _estateType == EstateType.both) {
      int feddans = int.tryParse(_feddanController.text) ?? 0;
      int qirats = int.tryParse(_qiratController.text) ?? 0;
      int sahms = int.tryParse(_sahmController.text) ?? 0;

      String? landError =
      LandCalculator.validateLandInput(feddans, qirats, sahms);
      if (_estateType == EstateType.land && landError != null) {
        _showError(landError);
        return;
      }
      if (_estateType == EstateType.both &&
          feddans == 0 &&
          qirats == 0 &&
          sahms == 0 &&
          moneyAmount <= 0) {
        _showError('الرجاء إدخال قيمة التركة');
        return;
      }

      landEstate =
          LandEstate(feddans: feddans, qirats: qirats, sahms: sahms);
    }

    double estateForCalc =
    _estateType == EstateType.land ? 100 : moneyAmount;
    if (estateForCalc <= 0) estateForCalc = 100;

    List<Heir> heirsList = selectedHeirs
        .map((sh) =>
        Heir(type: sh.type, nameAr: sh.nameAr, count: sh.count))
        .toList();

    InheritanceResult result =
    _calculator.calculate(heirsList, estateForCalc);

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

    // التمرير إلى النتائج
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _canHaveMultiple(HeirType type) {
    return ![
      HeirType.husband,
      HeirType.mother,
      HeirType.father,
      HeirType.grandmother,
      HeirType.grandfather,
    ].contains(type);
  }

  // ============ البناء الرئيسي ============
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDarkMode? Colors.black : Color(0xFFF5F5F0),
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'حاسبة المواريث الإسلامية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 40 : 12,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBismillah(),
                        const SizedBox(height: 12),
                        _buildDeceasedGender(),
                        const SizedBox(height: 12),
                        _buildEstateTypeSelector(),
                        const SizedBox(height: 12),
                        _buildEstateInputSection(),
                        const SizedBox(height: 12),

                        // ===== اختيار الورثة (قابل للطي) =====
                        _buildCollapsibleHeirsSelection(),
                        const SizedBox(height: 16),

                        _buildCalculateButton(),
                        const SizedBox(height: 16),

                        // ===== النتائج =====
                        if (_fullResult != null)
                          Container(
                            key: _resultsKey,
                            child: _buildResultsSection(),
                          ),

                        const SizedBox(height: 12),

                        // ===== جدول التحويل (قابل للطي) =====
                        _buildUnitConversionCard(),
                        const SizedBox(height: 12),

                        // ===== التنبيهات الشرعية (قابلة للطي) =====
                        _buildCollapsibleShariaWarnings(),
                        const SizedBox(height: 12),

                        // ===== المصادر (قابلة للطي) =====
                        _buildCollapsibleReferences(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============ البسملة ============
  Widget _buildBismillah() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '﴿ يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ ۖ لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ ﴾',
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          Text(
            'سورة النساء - آية 11',
            style: TextStyle(fontSize: 11, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============ جنس المتوفى ============
  Widget _buildDeceasedGender() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Color(0xFFF8F8F8), size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'جنس المتوفى',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildGenderButton(
                    icon: Icons.male,
                    label: 'ذكر',
                    isSelected: _isMaleDeceased,
                    color: _primary,
                    onTap: () => setState(() {
                      _isMaleDeceased = true;
                      _updateAvailableHeirs();
                      _result = null;
                      _fullResult = null;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGenderButton(
                    icon: Icons.female,
                    label: 'أنثى',
                    isSelected: !_isMaleDeceased,
                    color: const Color(0xFF880E4F),
                    onTap: () => setState(() {
                      _isMaleDeceased = false;
                      _updateAvailableHeirs();
                      _result = null;
                      _fullResult = null;
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ نوع التركة ============
  Widget _buildEstateTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Colors.white , size: 20),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'نوع التركة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFECF3ED),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  // شاشة صغيرة: عمودي
                  return Column(
                    children: [
                      _buildTypeOption(
                        icon: Icons.attach_money,
                        label: 'مال نقدي',
                        type: EstateType.money,
                        color: const Color(0xFF1B5E20),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeOption(
                        icon: Icons.landscape,
                        label: 'أرض زراعية',
                        type: EstateType.land,
                        color: const Color(0xFF795548),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeOption(
                        icon: Icons.account_balance,
                        label: 'الاثنان معاً',
                        type: EstateType.both,
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  );
                }
                // شاشة عادية: أفقي
                return Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        icon: Icons.attach_money,
                        label: 'مال نقدي',
                        type: EstateType.money,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildTypeOption(
                        icon: Icons.landscape,
                        label: 'أرض زراعية',
                        type: EstateType.land,
                        color: const Color(0xFF795548),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildTypeOption(
                        icon: Icons.account_balance,
                        label: 'الاثنان',
                        type: EstateType.both,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required EstateType type,
    required Color color,
  }) {
    bool isSelected = _estateType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _estateType = type;
        _result = null;
        _fullResult = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 22),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ إدخال التركة ============
  Widget _buildEstateInputSection() {
    return Column(
      children: [
        if (_estateType == EstateType.money ||
            _estateType == EstateType.both)
          _buildMoneyInput(),
        if (_estateType == EstateType.both) const SizedBox(height: 10),
        if (_estateType == EstateType.land ||
            _estateType == EstateType.both)
          _buildLandInput(),
      ],
    );
  }

  Widget _buildMoneyInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payments, color: Color(0xFFFAFDFA), size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'المال النقدي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE1E8E1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'بعد خصم الديون والوصايا وتكاليف التجهيز',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _estateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ',
                prefixIcon: const Icon(Icons.attach_money, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(color: Color(0xFF1B5E20), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.landscape,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مساحة الأرض',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF795548),
                        ),
                      ),
                      Text(
                        '1 فدان = 24 قيراط | 1 قيراط = 24 سهم',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double fieldWidth =
                    (constraints.maxWidth - 20) / 3;
                return Row(
                  children: [
                    Expanded(
                      child: _buildLandField(
                        controller: _feddanController,
                        label: 'فدان',
                        icon: '🌾',
                        hint: '0',
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLandField(
                        controller: _qiratController,
                        label: 'قيراط',
                        icon: '📐',
                        hint: '0-23',
                        color: const Color(0xFF795548),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLandField(
                        controller: _sahmController,
                        label: 'سهم',
                        icon: '📏',
                        hint: '0-23',
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _buildLiveConversion(),
          ],
        ),
      ),
    );
  }

  Widget _buildLandField({
    required TextEditingController controller,
    required String label,
    required String icon,
    required String hint,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$icon $label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.withOpacity(0.5)),
            ),
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveConversion() {
    int feddans = int.tryParse(_feddanController.text) ?? 0;
    int qirats = int.tryParse(_qiratController.text) ?? 0;
    int sahms = int.tryParse(_sahmController.text) ?? 0;

    if (feddans == 0 && qirats == 0 && sahms == 0) return const SizedBox();

    LandEstate estate =
    LandEstate(feddans: feddans, qirats: qirats, sahms: sahms);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF795548).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: const Color(0xFF795548).withOpacity(0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          _buildConvChip('بالقراريط',
              '${estate.totalInQirats.toStringAsFixed(2)} ق'),
          _buildConvChip(
              'بالأسهم', '${estate.totalInSahms.toStringAsFixed(0)} س'),
          _buildConvChip(
              'بالمتر²', '${estate.totalInMeters.toStringAsFixed(1)} م²'),
          _buildConvChip('بالفدان',
              '${estate.totalInFeddans.toStringAsFixed(4)} ف'),
        ],
      ),
    );
  }

  Widget _buildConvChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border:
        Border.all(color: const Color(0xFF795548).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548))),
        ],
      ),
    );
  }

  // ============ اختيار الورثة (قابل للطي) ============
  Widget _buildCollapsibleHeirsSelection() {
    Map<String, List<int>> categories = _categorizeHeirs();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading:
          const Icon(Icons.people, color: Color(0xFF1B5E20), size: 24),
          title: Row(
            children: [
              const Flexible(
                child: Text(
                  'اختر الورثة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedHeirsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_selectedHeirsCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: _selectedHeirsCount > 0
              ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _availableHeirs
                  .where((h) => h.isSelected)
                  .map((h) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${h.nameAr}${h.count > 1 ? " (${h.count})" : ""}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ))
                  .toList(),
            ),
          )
              : const Text(
            'اضغط لاختيار الورثة',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: categories.entries
                    .where((e) => e.value.isNotEmpty)
                    .map((entry) =>
                    _buildHeirCategory(entry.key, entry.value))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Map<String, List<int>> _categorizeHeirs() {
    Map<String, List<int>> categories = {
      'الزوج / الزوجة': [],
      'الأصول': [],
      'الفروع': [],
      'الإخوة والأخوات': [],
      'بقية العصبات': [],
    };
    for (int i = 0; i < _availableHeirs.length; i++) {
      var h = _availableHeirs[i];
      if (h.type == HeirType.husband || h.type == HeirType.wife) {
        categories['الزوج / الزوجة']!.add(i);
      } else if ([
        HeirType.father,
        HeirType.mother,
        HeirType.grandfather,
        HeirType.grandmother
      ].contains(h.type)) {
        categories['الأصول']!.add(i);
      } else if ([
        HeirType.son,
        HeirType.daughter,
        HeirType.sonOfSon,
        HeirType.sonsDaughter
      ].contains(h.type)) {
        categories['الفروع']!.add(i);
      } else if ([
        HeirType.brother,
        HeirType.sister,
        HeirType.halfBrotherFather,
        HeirType.halfSisterFather,
        HeirType.halfBrotherMother,
        HeirType.halfSisterMother
      ].contains(h.type)) {
        categories['الإخوة والأخوات']!.add(i);
      } else {
        categories['بقية العصبات']!.add(i);
      }
    }
    return categories;
  }

  Widget _buildHeirCategory(String title, List<int> indices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...indices.map((i) => _buildHeirTile(_availableHeirs[i])),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeirTile(SelectedHeir heir) {
    bool canMulti = _canHaveMultiple(heir.type);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: heir.isSelected
            ? const Color(0xFF1B5E20).withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: heir.isSelected
              ? const Color(0xFF1B5E20).withOpacity(0.5)
              : Colors.grey[300]!,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() {
          heir.isSelected = !heir.isSelected;
          if (!heir.isSelected) heir.count = 1;
          _result = null;
          _fullResult = null;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: heir.isSelected,
                  activeColor: const Color(0xFF1B5E20),
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                  onChanged: (v) => setState(() {
                    heir.isSelected = v ?? false;
                    if (!heir.isSelected) heir.count = 1;
                    _result = null;
                    _fullResult = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heir.nameAr,
                  style: TextStyle(
                    fontWeight: heir.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (heir.isSelected && canMulti)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCountButton(
                      icon: Icons.remove,
                      color: Colors.red,
                      onTap: heir.count > 1
                          ? () => setState(() {
                        heir.count--;
                        _result = null;
                        _fullResult = null;
                      })
                          : null,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${heir.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildCountButton(
                      icon: Icons.add,
                      color: const Color(0xFF1B5E20),
                      onTap: () => setState(() {
                        heir.count++;
                        _result = null;
                        _fullResult = null;
                      }),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap != null ? color : Colors.grey[300]!,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? color : Colors.grey[300],
        ),
      ),
    );
  }

  // ============ زر الحساب ============
  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calculateInheritance,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calculate, size: 24),
            SizedBox(width: 10),
            Text(
              'حساب المواريث',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ============ النتائج ============
  Widget _buildResultsSection() {
    return Column(
      children: [
        _buildCaseTypeCard(),
        const SizedBox(height: 10),
        if (_fullResult!.moneyAmount != null &&
            _fullResult!.moneyAmount! > 0) ...[
          _buildMoneyResults(),
          const SizedBox(height: 10),
        ],
        if (_fullResult!.landShares != null &&
            _fullResult!.landShares!.isNotEmpty) ...[
          _buildLandResults(),
          const SizedBox(height: 10),
        ],
        _buildBlockedHeirs(),
      ],
    );
  }

  Widget _buildCaseTypeCard() {
    Color caseColor;
    IconData caseIcon;
    switch (_result!.caseType) {
      case 'عول':
        caseColor = Colors.orange;
        caseIcon = Icons.trending_up;
        break;
      case 'رد':
        caseColor = Colors.blue;
        caseIcon = Icons.trending_down;
        break;
      default:
        caseColor = const Color(0xFF1B5E20);
        caseIcon = Icons.check_circle;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
              colors: [caseColor.withOpacity(0.1), Colors.white]),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(caseIcon, color: caseColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'نوع المسألة: ${_result!.caseType}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: caseColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _result!.explanation,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 16),
            Text(
              'أصل المسألة: ${_result!.baseDenominator}',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ============ نتائج المال ============
  Widget _buildMoneyResults() {
    List<Heir> activeHeirs = _result!.heirs
        .where((h) => !h.isBlocked && h.actualShare > 0)
        .toList();
    double totalMoney = _fullResult!.moneyAmount!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.payments,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أنصبة المال (${totalMoney.toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...activeHeirs.map((heir) {
              double share = heir.actualShare * totalMoney;
              double perPerson = share / heir.count;
              return _buildMoneyShareTile(heir, share, perPerson);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyShareTile(
      Heir heir, double total, double perPerson) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${heir.nameAr}${heir.count > 1 ? " (${heir.count})" : ""}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      heir.shareDescription,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      total.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  Text(
                    '${(heir.actualShare * 100).toStringAsFixed(2)}%',
                    style:
                    TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          if (heir.count > 1) ...[
            const Divider(height: 10),
            Text(
              'نصيب كل واحد: ${perPerson.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============ نتائج الأراضي ============
  Widget _buildLandResults() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.landscape,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أنصبة الأرض الزراعية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF795548),
                        ),
                      ),
                      Text(
                        'الكلي: ${_fullResult!.totalLand!.formatted}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ..._fullResult!.landShares!.map((share) {
              return _buildLandShareTile(share);
            }),
            const Divider(height: 16, thickness: 2),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF795548).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المجموع:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Flexible(
                    child: Text(
                      _fullResult!.totalLand!.formatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF795548),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildLandShareTile(HeirLandShare share) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: const Color(0xFF795548).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم الوارث والنسبة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${share.heirName}${share.count > 1 ? " (${share.count})" : ""}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${share.percentage.toStringAsFixed(1)}%',
                style:
                TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // فدان - قيراط - سهم
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLandChip('فدان',
                  '${share.landShare.feddans}', const Color(0xFF2E7D32)),
              _buildLandChip('قيراط',
                  '${share.landShare.qirats}', const Color(0xFF795548)),
              _buildLandChip('سهم',
                  '${share.landShare.sahms}', const Color(0xFFE65100)),
              _buildLandChip(
                  'م²',
                  share.landShare.totalInMeters.toStringAsFixed(1),
                  Colors.blueGrey),
            ],
          ),

          // نصيب كل فرد
          if (share.count > 1) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '👤 نصيب كل واحد: ${share.perPersonShare.formatted}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLandChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  // ============ المحجوبون ============
  Widget _buildBlockedHeirs() {
    List<Heir> blocked =
    _result!.heirs.where((h) => h.isBlocked).toList();
    if (blocked.isEmpty) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: const Icon(Icons.block, color: Colors.red, size: 22),
          title: Row(
            children: [
              const Flexible(
                child: Text(
                  'الورثة المحجوبون',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${blocked.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: [
            ...blocked.map((h) => Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_off,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${h.nameAr} - محجوب',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ============ جدول تحويل الوحدات (قابل للطي) ============
  Widget _buildUnitConversionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading:
          const Icon(Icons.swap_horiz, color: Color(0xFF795548), size: 22),
          title: const Text(
            'جدول تحويل وحدات المساحة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF795548),
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildConversionTable(),
                  const SizedBox(height: 10),
                  _buildCommonAreasNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionTable() {
    final rows = [
      ['1 فدان', '24 قيراط'],
      ['1 فدان', '576 سهم'],
      ['1 فدان', '4,200.83 م²'],
      ['1 قيراط', '24 سهم'],
      ['1 قيراط', '175.035 م²'],
      ['1 سهم', '7.293 م²'],
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF795548),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    child: Text('الوحدة',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('تساوي',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...rows.asMap().entries.map((e) {
            int i = e.key;
            var r = e.value;
            return Container(
              padding: const EdgeInsets.all(8),
              color: i % 2 == 0
                  ? Colors.brown.withOpacity(0.03)
                  : Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: Text(r[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center)),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: Color(0xFF795548)),
                  Expanded(
                      child: Text(r[1],
                          style: const TextStyle(
                              color: Color(0xFF795548), fontSize: 13),
                          textAlign: TextAlign.center)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommonAreasNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text('ملاحظات:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 13)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '• 1 دونم = 1000 م² ≈ 0.238 فدان\n'
                '• 1 هكتار = 10000 م² ≈ 2.381 فدان',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============ التنبيهات الشرعية (قابلة للطي) ============
  Widget _buildCollapsibleShariaWarnings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFE65100), size: 24),
          title: const Text(
            'تنبيهات شرعية مهمة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
              fontSize: 14,
            ),
          ),
          subtitle: const Text(
            '10 تنبيهات يجب معرفتها',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildWarningItem(
                    number: '١',
                    icon: Icons.account_balance,
                    title: 'سداد الديون والوصايا أولاً',
                    content:
                    'التركة لا تُوزع إلا بعد:\n'
                        '• تجهيز الميت (الغسل والتكفين والدفن)\n'
                        '• سداد جميع الديون\n'
                        '• تنفيذ الوصايا (في حدود الثلث لغير وارث)\n\n'
                        '﴿مِن بَعْدِ وَصِيَّةٍ يُوصِي بِهَا أَوْ دَيْنٍ﴾ [النساء: 11]',
                    color: const Color(0xFF1565C0),
                  ),
                  _buildWarningItem(
                    number: '٢',
                    icon: Icons.dangerous,
                    title: 'القاتل لا يرث',
                    content:
                    'قال ﷺ: «لَيْسَ لِلْقَاتِلِ مِيرَاثٌ» [رواه النسائي]\n'
                        'سواء كان القتل عمداً أو خطأً عند الجمهور.',
                    color: Colors.red,
                  ),
                  _buildWarningItem(
                    number: '٣',
                    icon: Icons.compare_arrows,
                    title: 'اختلاف الدين مانع',
                    content:
                    'قال ﷺ: «لَا يَرِثُ الْمُسْلِمُ الْكَافِرَ، '
                        'وَلَا يَرِثُ الْكَافِرُ الْمُسْلِمَ» [متفق عليه]',
                    color: const Color(0xFF6A1B9A),
                  ),
                  _buildWarningItem(
                    number: '٤',
                    icon: Icons.link_off,
                    title: 'الرق مانع من الإرث',
                    content:
                    'الرقيق لا يرث ولا يُورث (إجماع)\n'
                        'وقد زال هذا المانع في عصرنا بحمد الله.',
                    color: Colors.brown,
                  ),
                  _buildWarningItem(
                    number: '٥',
                    icon: Icons.pregnant_woman,
                    title: 'ميراث الحمل',
                    content:
                    '• يُوقف للحمل أكبر النصيبين\n'
                        '• لا تُقسم التركة نهائياً حتى يُولد\n'
                        '• يشترط أن يُولد حياً ليرث\n\n'
                        'قال ﷺ: «إِذَا اسْتَهَلَّ الصَّبِيُّ وُرِّثَ» [رواه أبو داود]',
                    color: const Color(0xFF00695C),
                  ),
                  _buildWarningItem(
                    number: '٦',
                    icon: Icons.person_search,
                    title: 'ميراث المفقود',
                    content:
                    '• يُعتبر حياً بالنسبة لماله\n'
                        '• يُوقف نصيبه من تركة غيره\n'
                        '• يحكم القاضي بوفاته بعد مدة معينة',
                    color: const Color(0xFF37474F),
                  ),
                  _buildWarningItem(
                    number: '٧',
                    icon: Icons.help_outline,
                    title: 'الخنثى المشكل',
                    content:
                    '• يُعطى أقل النصيبين احتياطاً\n'
                        '• أو يُوقف الفرق حتى يتبين حاله\n'
                        '• في عصرنا يمكن تحديد الجنس بالفحوصات',
                    color: const Color(0xFF4E342E),
                  ),
                  _buildWarningItem(
                    number: '٨',
                    icon: Icons.description,
                    title: 'لا وصية لوارث',
                    content:
                    'قال ﷺ: «إِنَّ اللَّهَ قَدْ أَعْطَى كُلَّ ذِي حَقٍّ حَقَّهُ، '
                        'فَلَا وَصِيَّةَ لِوَارِثٍ» [رواه أبو داود والترمذي]\n\n'
                        'إلا بإذن بقية الورثة. والوصية لغير الوارث في حدود الثلث.',
                    color: const Color(0xFFAD1457),
                  ),
                  _buildWarningItem(
                    number: '٩',
                    icon: Icons.gavel,
                    title: 'تحريم تغيير الفرائض',
                    content:
                    '﴿تِلْكَ حُدُودُ اللَّهِ ۚ وَمَن يُطِعِ اللَّهَ وَرَسُولَهُ '
                        'يُدْخِلْهُ جَنَّاتٍ﴾\n'
                        '﴿وَمَن يَعْصِ اللَّهَ وَرَسُولَهُ وَيَتَعَدَّ حُدُودَهُ '
                        'يُدْخِلْهُ نَارًا﴾ [النساء: 13-14]',
                    color: const Color(0xFFB71C1C),
                  ),
                  _buildWarningItem(
                    number: '١٠',
                    icon: Icons.school,
                    title: 'وجوب مراجعة عالم متخصص',
                    content:
                    '• هذا البرنامج للاستئناس والتعلم فقط\n'
                        '• لا يُغني عن مراجعة عالم شرعي متخصص\n'
                        '• يُنصح بعرض كل حالة على المحكمة الشرعية\n\n'
                        '﴿فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ﴾ [النحل: 43]',
                    color: const Color(0xFF1B5E20),
                  ),
                  const SizedBox(height: 12),
                  _buildInheritanceBlockersBox(),
                  const SizedBox(height: 10),
                  _buildInheritanceConditionsBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem({
    required String number,
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        color: color.withOpacity(0.02),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                content,
                style: const TextStyle(
                    fontSize: 13, height: 1.7, color: Color(0xFF333333)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInheritanceBlockersBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red.withOpacity(0.03),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                const Icon(Icons.block, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'موانع الإرث الثلاثة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBlockerRow('١', 'القتل', 'القاتل لا يرث'),
          _buildBlockerRow(
              '٢', 'اختلاف الدين', 'لا توارث بين مسلم وكافر'),
          _buildBlockerRow('٣', 'الرق', 'الرقيق لا يرث (زال في عصرنا)'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '«ويمنعُ الشخصَ من الميراثِ\n'
                  'واحدةٌ من علل ثلاثِ\n'
                  'رقٌّ وقتلٌ واختلافُ دينِ\n'
                  'فافهمْ فليس الشكُّ كاليقينِ»',
              style: TextStyle(
                  fontSize: 12, fontStyle: FontStyle.italic, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerRow(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: Colors.red, shape: BoxShape.circle),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInheritanceConditionsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF1B5E20).withOpacity(0.03),
        border:
        Border.all(color: const Color(0xFF1B5E20).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'شروط الإرث',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCondRow('١', 'تحقق وفاة المورث', 'حقيقةً أو حكماً'),
          _buildCondRow('٢', 'حياة الوارث', 'عند الوفاة حقيقةً أو تقديراً'),
          _buildCondRow('٣', 'العلم بجهة الإرث', 'معرفة صلة القرابة'),
          _buildCondRow('٤', 'عدم وجود مانع', 'انتفاء الموانع الثلاثة'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'أسباب الإرث:\n❶ النسب (القرابة)\n❷ النكاح (الزوجية)\n❸ الولاء (العتق)',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCondRow(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: Color(0xFF1B5E20), shape: BoxShape.circle),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20)),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ المصادر (قابلة للطي) ============
  Widget _buildCollapsibleReferences() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading:
          const Icon(Icons.menu_book, color: Color(0xFF1B5E20), size: 22),
          title: const Text(
            'المصادر والأدلة الشرعية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRefSection(
                    icon: Icons.auto_stories,
                    title: 'القرآن الكريم',
                    items: [
                      'سورة النساء - الآية 11: أنصبة الأولاد والوالدين',
                      'سورة النساء - الآية 12: أنصبة الزوجين والإخوة لأم',
                      'سورة النساء - الآية 176: الكلالة',
                      'سورة النساء - الآيتان 13-14: حدود الله',
                    ],
                  ),
                  const Divider(height: 16),
                  _buildRefSection(
                    icon: Icons.mosque,
                    title: 'السنة النبوية',
                    items: [
                      '«أَلْحِقُوا الفَرَائِضَ بِأَهْلِهَا فَمَا بَقِيَ فَهُوَ لِأَوْلَى رَجُلٍ ذَكَرٍ» [متفق عليه]',
                      '«لَا يَرِثُ الْمُسْلِمُ الْكَافِرَ» [متفق عليه]',
                      '«لَيْسَ لِلْقَاتِلِ مِيرَاثٌ» [النسائي]',
                      '«فَلَا وَصِيَّةَ لِوَارِثٍ» [أبو داود والترمذي]',
                      '«تَعَلَّمُوا الفَرَائِضَ فَإِنَّهُ نِصْفُ العِلْمِ» [ابن ماجه]',
                    ],
                  ),
                  const Divider(height: 16),
                  _buildRefSection(
                    icon: Icons.book,
                    title: 'المراجع الفقهية',
                    items: [
                      'الرحبية في علم الفرائض - الإمام الرحبي',
                      'السراجية في المواريث - السجاوندي',
                      'المغني - ابن قدامة المقدسي',
                      'الفقه الإسلامي وأدلته - د. وهبة الزحيلي',
                      'التحقيقات المرضية - صالح الفوزان',
                      'تسهيل الفرائض - د. محمد العثيمين',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B5E20),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  @override
  void dispose() {
    _estateController.dispose();
    _feddanController.dispose();
    _qiratController.dispose();
    _sahmController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}