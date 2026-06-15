import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ArabicLanguageGuide {
  static void show(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF171A1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'تحميل اللغة العربية مطلوب',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لتفعيل التسميع بالعربية، تحتاج تحميل حزمة التعرف على الكلام العربية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // الطريقة 1
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.looks_one, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'الطريقة الأسهل:',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '١. افتح تطبيق Google على هاتفك\n'
                          '٢. اضغط على الميكروفون 🎤\n'
                          '٣. تحدث بالعربية (مثلاً: بسم الله)\n'
                          '٤. إذا طلب تحميل اللغة → وافق\n'
                          '٥. ارجع وجرب مرة أخرى',
                      style: GoogleFonts.cairo(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // الطريقة 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.looks_two, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'من الإعدادات:',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الإعدادات → النظام → اللغة والإدخال\n'
                          '→ التعرف على الكلام بلا إنترنت\n'
                          '→ تحميل "العربية"',
                      style: GoogleFonts.cairo(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text('لاحقاً', style: GoogleFonts.cairo()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await openAppSettings();
                      },
                      icon: const Icon(Icons.settings, size: 18),
                      label: Text(
                        'فتح الإعدادات',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // زر Google
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await launchUrl(
                        Uri.parse('market://details?id=com.google.android.googlequicksearchbox'),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {
                      await launchUrl(
                        Uri.parse('https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox'),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: Icon(Icons.open_in_new, size: 16, color: Colors.blue.shade700),
                  label: Text(
                    'فتح تطبيق Google في المتجر',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}