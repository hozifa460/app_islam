import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/prayer/muzzin_settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(int) onColorChanged;
  final bool isDarkMode;
  final int selectedColorIndex;
  final List<Color> appColors;
  final List<String> colorNames;
  final Color primaryColor;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.selectedColorIndex,
    required this.appColors,
    required this.colorNames,
    required this.primaryColor,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _tempSelectedColor;
  late bool _tempIsDarkMode;

  final Color _gold = const Color(0xFFE6B325);

  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedColor = widget.selectedColorIndex;
    _tempIsDarkMode = widget.isDarkMode;
  }

  void _shareApp() async {
    setState(() => _isSharing = true);

    try {
      final apkPath = await _getApkPath();

      if (apkPath != null && await File(apkPath).exists()) {
        await Share.shareXFiles(
          [XFile(apkPath)],
          text: '🕌 تطبيق طريق الإسلام\nجرب هذا التطبيق الرائع للعبادة!',
          subject: 'تطبيق طريق الإسلام',
        );
      } else {
        _showShareOptions();
      }
    } catch (e) {
      _showShareOptions();
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<String?> _getApkPath() async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      final apkFile = File('${downloadDir.path}/app-release.apk');
      if (await apkFile.exists()) return apkFile.path;

      final appDir = await getApplicationSupportDirectory();
      final appApk = File('${appDir.path}/app-release.apk');
      if (await appApk.exists()) return appApk.path;

      return null;
    } catch (e) {
      return null;
    }
  }

  void _showShareOptions() {
    // ✅ كشف الوضع الحالي
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSheetBg = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bottomSheetBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _gold.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share, color: _gold, size: 48),
            const SizedBox(height: 16),
            Text(
              'مشاركة التطبيق',
              style: GoogleFonts.cairo(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'التطبيق غير منشور على المتجر بعد. يمكنك:',
              style: GoogleFonts.cairo(color: subTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.copy, color: _gold),
              ),
              title: Text('نسخ رسالة الدعوة',
                  style: GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text('مع رابط تحميل يدوي',
                  style: GoogleFonts.cairo(color: subTextColor, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _copyShareText();
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info, color: _gold),
              ),
              title: Text('كيفية المشاركة',
                  style: GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text('خطوات إرسال APK يدوياً',
                  style: GoogleFonts.cairo(color: subTextColor, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showHowToShare(isDark, bottomSheetBg, textColor, subTextColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyShareText() {
    final text = '''
🕌 تطبيق طريق الإسلام - رفيقك في العبادة

✨ المميزات:
• مواقيت الصلاة الدقيقة
• القرآن الكريم كاملاً
• الأذان بأصوات مشهورة
• الأذكار والتسبيح
• اتجاه القبلة

📲 للتحميل:
تواصل معي للحصول على ملف APK

تم التطوير بواسطة: حذيفة محمد ضرغام
''';

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ رسالة الدعوة', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );

    Share.share(text, subject: 'تطبيق طريق الإسلام');
  }

  void _showHowToShare(bool isDark, Color dialogBg, Color textColor, Color subTextColor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('كيفية مشاركة APK',
            style: GoogleFonts.cairo(color: textColor)),
        content: Text(
          '1. شغل Terminal واكتب: flutter build apk\n'
              '2. ستجد الملف في: build/app/outputs/flutter-apk/\n'
              '3. انقل الملف إلى هاتفك\n'
              '4. أرسله لصديقك عبر Telegram أو Bluetooth\n\n'
              'أو شارك ملف app-release.apk من مجلد Downloads',
          style: GoogleFonts.cairo(color: subTextColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(color: _gold)),
          ),
        ],
      ),
    );
  }

  void _openMuezzinSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuezzinSettingsScreen(primaryColor: widget.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. كشف الوضع الحالي
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. الألوان الديناميكية
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;

    // تدرج البطاقات وحوافها
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

    if (_isSharing) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textColorMain,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // المشاركة
              _buildSectionTitle('مشاركة التطبيق', textColorMain),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: Icons.share_rounded,
                title: 'مشاركة مع الأصدقاء',
                subtitle: 'دعوة الآخرين لاستخدام التطبيق',
                iconColor: const Color(0xFF25D366),
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                cardGradient: cardGradient,
                borderColor: borderColor,
                shadowColor: shadowColor,
                onTap: _shareApp,
              ),

              const SizedBox(height: 30),

              // المؤذن
              _buildSectionTitle('إعدادات الأذان', textColorMain),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: Icons.settings_voice,
                title: 'اختيار المؤذن',
                subtitle: 'تغيير صوت الأذان الافتراضي',
                iconColor: _gold,
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                cardGradient: cardGradient,
                borderColor: borderColor,
                shadowColor: shadowColor,
                onTap: _openMuezzinSettings,
              ),

              const SizedBox(height: 30),

              // الوضع الداكن
              _buildSectionTitle('المظهر العام', textColorMain),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: _tempIsDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'الوضع الداكن',
                subtitle: _tempIsDarkMode ? 'مفعل' : 'معطل',
                iconColor: Colors.blue,
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                cardGradient: cardGradient,
                borderColor: borderColor,
                shadowColor: shadowColor,
                onTap: () {
                  setState(() {
                    _tempIsDarkMode = !_tempIsDarkMode;
                  });
                  widget.onThemeChanged(_tempIsDarkMode);
                },
                trailing: Switch(
                  value: _tempIsDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _tempIsDarkMode = value;
                    });
                    widget.onThemeChanged(value);
                  },
                  activeColor: _gold,
                ),
              ),

              const SizedBox(height: 30),

              // الألوان
              _buildSectionTitle('لون التطبيق', textColorMain),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cardGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اللون الحالي: ${widget.colorNames[_tempSelectedColor]}',
                      style: GoogleFonts.cairo(
                        color: textColorSub,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: widget.appColors.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _tempSelectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _tempSelectedColor = index;
                            });
                            widget.onColorChanged(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              color: widget.appColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.transparent,
                                width: isSelected ? 3 : 0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: widget.appColors[index].withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ]
                                  : [],
                            ),
                            child: isSelected
                                ? Icon(
                              Icons.check,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 24,
                            )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // حول
              _buildSectionTitle('حول التطبيق', textColorMain),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: Icons.info,
                title: 'الإصدار',
                subtitle: '1.0.0',
                iconColor: Colors.grey,
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                cardGradient: cardGradient,
                borderColor: borderColor,
                shadowColor: shadowColor,
              ),
              const SizedBox(height: 12),
              _buildGlassTile(
                icon: Icons.code,
                title: 'المطور',
                subtitle: 'حذيفة محمد ضرغام',
                iconColor: Colors.green,
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                cardGradient: cardGradient,
                borderColor: borderColor,
                shadowColor: shadowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ دالة _buildSectionTitle مع لون النص
  Widget _buildSectionTitle(String title, Color textColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // ✅ دالة _buildGlassTile تستقبل الألوان لتتكيف تلقائياً
  Widget _buildGlassTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color textColorMain,
    required Color textColorSub,
    required List<Color> cardGradient,
    required Color borderColor,
    required Color shadowColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: textColorMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: textColorSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.arrow_back_ios_new,
              color: textColorSub.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}