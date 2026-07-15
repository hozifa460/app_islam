import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../languages/app_localizations.dart';
import '../../languages/locale_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  // â•گâ•گâ•گ ظ‚ط§ط¦ظ…ط© ط§ظ„ظ„ط؛ط§طھ ظ…ط¹ ط£ط³ظ…ط§ط¦ظ‡ط§ ط§ظ„ط£طµظ„ظٹط© ظˆط§ظ„ط£ط¹ظ„ط§ظ… â•گâ•گâ•گ
  static const List<Map<String, String>> languages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'Franأ§ais', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'Espaأ±ol', 'flag': '🇪🇸'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguأھs', 'flag': '🇧🇷'},
    {'code': 'nl', 'name': 'Nederlands', 'flag': '🇳🇱'},
    {'code': 'ru', 'name': 'ذ رƒرپرپذ؛ذ¸ذ¹', 'flag': '🇷🇺'},
    {'code': 'tr', 'name': 'Tأ¼rkأ§e', 'flag': '🇹🇷'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'hi', 'name': 'à¤¹à¤؟à¤¨à¥چà¤¦à¥€', 'flag': '🇮🇳'},
    {'code': 'ja', 'name': 'و—¥وœ¬èھ‍', 'flag': '🇯🇵'},
    {'code': 'zh', 'name': 'ن¸­و–‡', 'flag': '🇨🇳'},
    {'code': 'uz', 'name': 'Oت»zbekcha', 'flag': '🇺🇿'},
    {'code': 'sw', 'name': 'Kiswahili', 'flag': '🇹🇿'},
    {'code': 'ha', 'name': 'Hausa', 'flag': '🇳🇬'},
    {'code': 'am', 'name': 'لٹ لˆ›لˆ­لٹ›', 'flag': '🇪🇹'},
    {'code': 'so', 'name': 'Soomaali', 'flag': '🇸🇴'},
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;
    final tr = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr.t('chooseLanguage'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = lang['code'] == currentCode;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Text(
                lang['flag']!,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                lang['name']!,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                lang['code']!.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              trailing: isSelected
                  ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              )
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () {
                localeProvider.setLocale(lang['code']!);

                // ط±ط³ط§ظ„ط© طھط£ظƒظٹط¯
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${lang['flag']} ${lang['name']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}