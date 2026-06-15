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
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'طھط­ظ…ظٹظ„ ط§ظ„ظ„ط؛ط© ط§ظ„ط¹ط±ط¨ظٹط© ظ…ط·ظ„ظˆط¨',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ظ„طھظپط¹ظٹظ„ ط§ظ„طھط³ظ…ظٹط¹ ط¨ط§ظ„ط¹ط±ط¨ظٹط©طŒ طھط­طھط§ط¬ طھط­ظ…ظٹظ„ ط­ط²ظ…ط© ط§ظ„طھط¹ط±ظپ ط¹ظ„ظ‰ ط§ظ„ظƒظ„ط§ظ… ط§ظ„ط¹ط±ط¨ظٹط©.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // ط§ظ„ط·ط±ظٹظ‚ط© 1
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.looks_one, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ط§ظ„ط·ط±ظٹظ‚ط© ط§ظ„ط£ط³ظ‡ظ„:',
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
                      'ظ،. ط§ظپطھط­ طھط·ط¨ظٹظ‚ Google ط¹ظ„ظ‰ ظ‡ط§طھظپظƒ\n'
                          'ظ¢. ط§ط¶ط؛ط· ط¹ظ„ظ‰ ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ† ًںژ¤\n'
                          'ظ£. طھط­ط¯ط« ط¨ط§ظ„ط¹ط±ط¨ظٹط© (ظ…ط«ظ„ط§ظ‹: ط¨ط³ظ… ط§ظ„ظ„ظ‡)\n'
                          'ظ¤. ط¥ط°ط§ ط·ظ„ط¨ طھط­ظ…ظٹظ„ ط§ظ„ظ„ط؛ط© â†’ ظˆط§ظپظ‚\n'
                          'ظ¥. ط§ط±ط¬ط¹ ظˆط¬ط±ط¨ ظ…ط±ط© ط£ط®ط±ظ‰',
                      style: GoogleFonts.cairo(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ط§ظ„ط·ط±ظٹظ‚ط© 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.looks_two, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ظ…ظ† ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ:',
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
                      'ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ â†’ ط§ظ„ظ†ط¸ط§ظ… â†’ ط§ظ„ظ„ط؛ط© ظˆط§ظ„ط¥ط¯ط®ط§ظ„\n'
                          'â†’ ط§ظ„طھط¹ط±ظپ ط¹ظ„ظ‰ ط§ظ„ظƒظ„ط§ظ… ط¨ظ„ط§ ط¥ظ†طھط±ظ†طھ\n'
                          'â†’ طھط­ظ…ظٹظ„ "ط§ظ„ط¹ط±ط¨ظٹط©"',
                      style: GoogleFonts.cairo(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ط§ظ„ط£ط²ط±ط§ط±
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
                      label: Text('ظ„ط§ط­ظ‚ط§ظ‹', style: GoogleFonts.cairo()),
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
                        'ظپطھط­ ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ط²ط± Google
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
                    'ظپطھط­ طھط·ط¨ظٹظ‚ Google ظپظٹ ط§ظ„ظ…طھط¬ط±',
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