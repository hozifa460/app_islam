import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../language_screen.dart';
import '../locale_provider.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  static const _gold = Color(0xFFD4AF37);

  static const Map<String, String> _flags = {
    'ar': '🇸🇦',
    'en': '🇺🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'es': '🇪🇸',
    'it': '🇮🇹',
    'pt': '🇧🇷',
    'nl': '🇳🇱',
    'ru': '🇷🇺',
    'tr': '🇹🇷',
    'ur': '🇵🇰',
    'id': '🇮🇩',
    'ms': '🇲🇾',
    'hi': '🇮🇳',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
    'uz': '🇺🇿',
    'sw': '🇹🇿',
    'ha': '🇳🇬',
    'am': '🇪🇹',
    'so': '🇸🇴',
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;
    final flag = _flags[currentCode] ?? '🌐';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.7),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : _gold.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(isDark ? 0.1 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                currentCode.toUpperCase(),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}