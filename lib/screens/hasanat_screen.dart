import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final List<Map<String, dynamic>> deeds = [
    {
      'title': 'ط³ظڈط¨ظ’ط­ظژط§ظ†ظژ ط§ظ„ظ„ظژظ‘ظ‡ظگ ظˆظژط¨ظگط­ظژظ…ظ’ط¯ظگظ‡ظگ',
      'reward': 'طھظڈط؛ط±ط³ ظ†ط®ظ„ط© ظپظٹ ط§ظ„ط¬ظ†ط©',
      'hadith': 'ظ…ظ† ظ‚ط§ظ„ ط³ط¨ط­ط§ظ† ط§ظ„ظ„ظ‡ ظˆط¨ط­ظ…ط¯ظ‡ ط؛ظڈط±ط³طھ ظ„ظ‡ ظ†ط®ظ„ط© ظپظٹ ط§ظ„ط¬ظ†ط©',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„طھط±ظ…ط°ظٹ ظˆطµط­ط­ظ‡ ط§ظ„ط£ظ„ط¨ط§ظ†ظٹ',
      'type': 'palm',
      'icon': 'ًںŒ´',
      'target': 1,
      'color': 0xFF4CAF50,
    },
    {
      'title': 'ط³ظڈط¨ظ’ط­ظژط§ظ†ظژ ط§ظ„ظ„ظژظ‘ظ‡ظگ ط§ظ„ط¹ظژط¸ظگظٹظ…ظگ ظˆظژط¨ظگط­ظژظ…ظ’ط¯ظگظ‡ظگ',
      'reward': 'ط«ظ‚ظٹظ„طھط§ظ† ظپظٹ ط§ظ„ظ…ظٹط²ط§ظ†',
      'hadith':
      'ظƒظ„ظ…طھط§ظ† ط®ظپظٹظپطھط§ظ† ط¹ظ„ظ‰ ط§ظ„ظ„ط³ط§ظ†طŒ ط«ظ‚ظٹظ„طھط§ظ† ظپظٹ ط§ظ„ظ…ظٹط²ط§ظ†طŒ ط­ط¨ظٹط¨طھط§ظ† ط¥ظ„ظ‰ ط§ظ„ط±ط­ظ…ظ†: ط³ط¨ط­ط§ظ† ط§ظ„ظ„ظ‡ ظˆط¨ط­ظ…ط¯ظ‡طŒ ط³ط¨ط­ط§ظ† ط§ظ„ظ„ظ‡ ط§ظ„ط¹ط¸ظٹظ…',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„ط¨ط®ط§ط±ظٹ ظˆظ…ط³ظ„ظ…',
      'type': 'scale',
      'icon': 'âڑ–ï¸ڈ',
      'target': 1,
      'color': 0xFF9C27B0,
    },
    {
      'title': 'ط³ظڈط¨ظ’ط­ظژط§ظ†ظژ ط§ظ„ظ„ظژظ‘ظ‡ظگ ظˆظژط¨ظگط­ظژظ…ظ’ط¯ظگظ‡ظگ (100 ظ…ط±ط©)',
      'reward': 'ط­ط· ط§ظ„ط®ط·ط§ظٹط§ ظˆط¥ظ† ظƒط§ظ†طھ ظƒط²ط¨ط¯ ط§ظ„ط¨ط­ط±',
      'hadith':
      'ظ…ظ† ظ‚ط§ظ„ ط³ط¨ط­ط§ظ† ط§ظ„ظ„ظ‡ ظˆط¨ط­ظ…ط¯ظ‡ ظپظٹ ظٹظˆظ… ظ…ط§ط¦ط© ظ…ط±ط© ط­ظڈط·ظ‘طھ ط®ط·ط§ظٹط§ظ‡ ظˆط¥ظ† ظƒط§ظ†طھ ظ…ط«ظ„ ط²ط¨ط¯ ط§ظ„ط¨ط­ط±',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„ط¨ط®ط§ط±ظٹ ظˆظ…ط³ظ„ظ…',
      'type': 'hasana',
      'icon': 'ًںŒٹ',
      'target': 100,
      'hasanaValue': 1,
      'color': 0xFF00BCD4,
    },
    {
      'title': 'ظ‚ظگط±ظژط§ط،ظژط©ظڈ ط³ظڈظˆط±ظژط©ظگ ط§ظ„ط¥ظگط®ظ’ظ„ظژط§طµظگ (10 ظ…ط±ط§طھ)',
      'reward': 'ظٹظڈط¨ظ†ظ‰ ظ„ظƒ ظ‚طµط± ظپظٹ ط§ظ„ط¬ظ†ط©',
      'hadith':
      'ظ…ظ† ظ‚ط±ط£ ظ‚ظ„ ظ‡ظˆ ط§ظ„ظ„ظ‡ ط£ط­ط¯ ط¹ط´ط± ظ…ط±ط§طھ ط¨ظ†ظ‰ ط§ظ„ظ„ظ‡ ظ„ظ‡ ظ‚طµط±ظ‹ط§ ظپظٹ ط§ظ„ط¬ظ†ط©',
      'source': 'ط±ظˆط§ظ‡ ط£ط­ظ…ط¯ ظˆطµط­ط­ظ‡ ط§ظ„ط£ظ„ط¨ط§ظ†ظٹ',
      'type': 'palace',
      'icon': 'ًںڈ°',
      'target': 10,
      'color': 0xFFFF9800,
    },
    {
      'title': 'ظ„ظژط§ ط­ظژظˆظ’ظ„ظژ ظˆظژظ„ظژط§ ظ‚ظڈظˆظژظ‘ط©ظژ ط¥ظگظ„ظژظ‘ط§ ط¨ظگط§ظ„ظ„ظژظ‘ظ‡ظگ',
      'reward': 'ظƒظ†ط² ظ…ظ† ظƒظ†ظˆط² ط§ظ„ط¬ظ†ط©',
      'hadith':
      'ط£ظ„ط§ ط£ط¯ظ„ظƒ ط¹ظ„ظ‰ ظƒظ„ظ…ط© ظ‡ظٹ ظƒظ†ط² ظ…ظ† ظƒظ†ظˆط² ط§ظ„ط¬ظ†ط©طں ظ„ط§ ط­ظˆظ„ ظˆظ„ط§ ظ‚ظˆط© ط¥ظ„ط§ ط¨ط§ظ„ظ„ظ‡',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„ط¨ط®ط§ط±ظٹ ظˆظ…ط³ظ„ظ…',
      'type': 'jewel',
      'icon': 'ًں’ژ',
      'target': 1,
      'color': 0xFF2196F3,
    },
    {
      'title':
      'ظ„ظژط§ ط¥ظگظ„ظژظ‡ظژ ط¥ظگظ„ظژظ‘ط§ ط§ظ„ظ„ظژظ‘ظ‡ظڈ ظˆظژط­ظ’ط¯ظژظ‡ظڈ ظ„ظژط§ ط´ظژط±ظگظٹظƒظژ ظ„ظژظ‡ظڈطŒ ظ„ظژظ‡ظڈ ط§ظ„ظ’ظ…ظڈظ„ظ’ظƒظڈ ظˆظژظ„ظژظ‡ظڈ ط§ظ„ظ’ط­ظژظ…ظ’ط¯ظڈ ظˆظژظ‡ظڈظˆظژ ط¹ظژظ„ظژظ‰ ظƒظڈظ„ظگظ‘ ط´ظژظٹظ’ط،ظچ ظ‚ظژط¯ظگظٹط±ظŒ',
      'reward': '100 ط­ط³ظ†ط© ظˆط­ط· 100 ط³ظٹط¦ط© ظˆط­ط±ط² ظ…ظ† ط§ظ„ط´ظٹط·ط§ظ†',
      'hadith':
      'ظ…ظ† ظ‚ط§ظ„ظ‡ط§ ظپظٹ ظٹظˆظ… ظ…ط§ط¦ط© ظ…ط±ط© ظƒط§ظ†طھ ظ„ظ‡ ط¹ط¯ظ„ ط¹ط´ط± ط±ظ‚ط§ط¨طŒ ظˆظƒظڈطھط¨طھ ظ„ظ‡ ظ…ط§ط¦ط© ط­ط³ظ†ط©طŒ ظˆظ…ظڈط­ظٹطھ ط¹ظ†ظ‡ ظ…ط§ط¦ط© ط³ظٹط¦ط©طŒ ظˆظƒط§ظ†طھ ظ„ظ‡ ط­ط±ط²ظ‹ط§ ظ…ظ† ط§ظ„ط´ظٹط·ط§ظ†',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„ط¨ط®ط§ط±ظٹ ظˆظ…ط³ظ„ظ…',
      'type': 'hasana',
      'icon': 'ًں“؟',
      'target': 1,
      'hasanaValue': 100,
      'color': 0xFF009688,
    },
    {
      'title': 'ط§ظ„طµظژظ‘ظ„ظژط§ط©ظڈ ط¹ظژظ„ظژظ‰ ط§ظ„ظ†ظژظ‘ط¨ظگظٹظگظ‘ ï·؛',
      'reward': '10 طµظ„ظˆط§طھ ظ…ظ† ط§ظ„ظ„ظ‡ ظˆط­ط· 10 ط³ظٹط¦ط§طھ ظˆط±ظپط¹ 10 ط¯ط±ط¬ط§طھ',
      'hadith':
      'ظ…ظ† طµظ„ظ‘ظ‰ ط¹ظ„ظٹظ‘ طµظ„ط§ط© ظˆط§ط­ط¯ط© طµظ„ظ‘ظ‰ ط§ظ„ظ„ظ‡ ط¹ظ„ظٹظ‡ ط¹ط´ط± طµظ„ظˆط§طھطŒ ظˆط­ظڈط·ظ‘طھ ط¹ظ†ظ‡ ط¹ط´ط± ط®ط·ظٹط¦ط§طھطŒ ظˆط±ظڈظپط¹طھ ظ„ظ‡ ط¹ط´ط± ط¯ط±ط¬ط§طھ',
      'source': 'ط±ظˆط§ظ‡ ظ…ط³ظ„ظ… ظˆط§ظ„ظ†ط³ط§ط¦ظٹ',
      'type': 'light',
      'icon': 'âœ¨',
      'target': 1,
      'color': 0xFFFFC107,
    },
    {
      'title': 'ط£ظژط³ظ’طھظژط؛ظ’ظپظگط±ظڈ ط§ظ„ظ„ظژظ‘ظ‡ظژ ظˆظژط£ظژطھظڈظˆط¨ظڈ ط¥ظگظ„ظژظٹظ’ظ‡ظگ',
      'reward': 'ظپط±ط¬ ظ…ظ† ظƒظ„ ط¶ظٹظ‚ ظˆظ…ط®ط±ط¬ ظ…ظ† ظƒظ„ ظ‡ظ…',
      'hadith':
      'ظ…ظ† ظ„ط²ظ… ط§ظ„ط§ط³طھط؛ظپط§ط± ط¬ط¹ظ„ ط§ظ„ظ„ظ‡ ظ„ظ‡ ظ…ظ† ظƒظ„ ظ‡ظ…ظ‘ ظپط±ط¬ظ‹ط§طŒ ظˆظ…ظ† ظƒظ„ ط¶ظٹظ‚ ظ…ط®ط±ط¬ظ‹ط§طŒ ظˆط±ط²ظ‚ظ‡ ظ…ظ† ط­ظٹط« ظ„ط§ ظٹط­طھط³ط¨',
      'source': 'ط±ظˆط§ظ‡ ط£ط¨ظˆ ط¯ط§ظˆط¯ ظˆط§ط¨ظ† ظ…ط§ط¬ظ‡',
      'type': 'hasana',
      'icon': 'ًں¤²',
      'target': 1,
      'hasanaValue': 10,
      'color': 0xFF8BC34A,
    },
    {
      'title': 'ظ‚ظگط±ظژط§ط،ظژط©ظڈ ط¢ظٹظژط©ظگ ط§ظ„ظƒظڈط±ظ’ط³ظگظٹظگظ‘ ط¨ط¹ط¯ ظƒظ„ طµظ„ط§ط©',
      'reward': 'ظ„ظ… ظٹظ…ظ†ط¹ظ‡ ظ…ظ† ط¯ط®ظˆظ„ ط§ظ„ط¬ظ†ط© ط¥ظ„ط§ ط£ظ† ظٹظ…ظˆطھ',
      'hadith':
      'ظ…ظ† ظ‚ط±ط£ ط¢ظٹط© ط§ظ„ظƒط±ط³ظٹ ط¯ط¨ط± ظƒظ„ طµظ„ط§ط© ظ…ظƒطھظˆط¨ط© ظ„ظ… ظٹظ…ظ†ط¹ظ‡ ظ…ظ† ط¯ط®ظˆظ„ ط§ظ„ط¬ظ†ط© ط¥ظ„ط§ ط£ظ† ظٹظ…ظˆطھ',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„ظ†ط³ط§ط¦ظٹ ظˆطµط­ط­ظ‡ ط§ظ„ط£ظ„ط¨ط§ظ†ظٹ',
      'type': 'door',
      'icon': 'ًںڑھ',
      'target': 5,
      'color': 0xFF795548,
    },
    {
      'title':
      'ط³ظڈط¨ظ’ط­ظژط§ظ†ظژ ط§ظ„ظ„ظژظ‘ظ‡ظگطŒ ظˆظژط§ظ„ط­ظژظ…ظ’ط¯ظڈ ظ„ظگظ„ظژظ‘ظ‡ظگطŒ ظˆظژظ„ظژط§ ط¥ظگظ„ظژظ‡ظژ ط¥ظگظ„ظژظ‘ط§ ط§ظ„ظ„ظژظ‘ظ‡ظڈطŒ ظˆظژط§ظ„ظ„ظژظ‘ظ‡ظڈ ط£ظژظƒظ’ط¨ظژط±ظڈ',
      'reward': 'ط£ط­ط¨ ط§ظ„ظƒظ„ط§ظ… ط¥ظ„ظ‰ ط§ظ„ظ„ظ‡',
      'hadith':
      'ط£ط­ط¨ ط§ظ„ظƒظ„ط§ظ… ط¥ظ„ظ‰ ط§ظ„ظ„ظ‡ ط£ط±ط¨ط¹: ط³ط¨ط­ط§ظ† ط§ظ„ظ„ظ‡طŒ ظˆط§ظ„ط­ظ…ط¯ ظ„ظ„ظ‡طŒ ظˆظ„ط§ ط¥ظ„ظ‡ ط¥ظ„ط§ ط§ظ„ظ„ظ‡طŒ ظˆط§ظ„ظ„ظ‡ ط£ظƒط¨ط±',
      'source': 'ط±ظˆط§ظ‡ ظ…ط³ظ„ظ…',
      'type': 'scale',
      'icon': 'âڑ–ï¸ڈ',
      'target': 1,
      'color': 0xFFE91E63,
    },
    {
      'title':
      'ط³ظڈط¨ظ’ط­ظژط§ظ†ظژ ط§ظ„ظ„ظژظ‘ظ‡ظگ (33) ظˆظژط§ظ„ط­ظژظ…ظ’ط¯ظڈ ظ„ظگظ„ظژظ‘ظ‡ظگ (33) ظˆظژط§ظ„ظ„ظژظ‘ظ‡ظڈ ط£ظژظƒظ’ط¨ظژط±ظڈ (34)',
      'reward': 'طھظڈط؛ظپط± ط°ظ†ظˆط¨ظ‡ ظˆط¥ظ† ظƒط§ظ†طھ ظ…ط«ظ„ ط²ط¨ط¯ ط§ظ„ط¨ط­ط±',
      'hadith':
      'ظ…ظ† ط³ط¨ظ‘ط­ ط§ظ„ظ„ظ‡ ظپظٹ ط¯ط¨ط± ظƒظ„ طµظ„ط§ط© ط«ظ„ط§ط«ظ‹ط§ ظˆط«ظ„ط§ط«ظٹظ†طŒ ظˆط­ظ…ط¯ ط§ظ„ظ„ظ‡ ط«ظ„ط§ط«ظ‹ط§ ظˆط«ظ„ط§ط«ظٹظ†طŒ ظˆظƒط¨ظ‘ط± ط§ظ„ظ„ظ‡ ط«ظ„ط§ط«ظ‹ط§ ظˆط«ظ„ط§ط«ظٹظ†',
      'source': 'ط±ظˆط§ظ‡ ظ…ط³ظ„ظ…',
      'type': 'hasana',
      'icon': 'ًں“؟',
      'target': 1,
      'hasanaValue': 50,
      'color': 0xFF3F51B5,
    },
    {
      'title': 'ظ„ظژط§ ط¥ظگظ„ظژظ‡ظژ ط¥ظگظ„ظژظ‘ط§ ط§ظ„ظ„ظژظ‘ظ‡ظڈ',
      'reward': 'ط£ظپط¶ظ„ ظ…ط§ ظ‚ط§ظ„ظ‡ ط§ظ„ظ†ط¨ظٹظˆظ†',
      'hadith':
      'ط£ظپط¶ظ„ ط§ظ„ط°ظƒط± ظ„ط§ ط¥ظ„ظ‡ ط¥ظ„ط§ ط§ظ„ظ„ظ‡طŒ ظˆط£ظپط¶ظ„ ط§ظ„ط¯ط¹ط§ط، ط§ظ„ط­ظ…ط¯ ظ„ظ„ظ‡',
      'source': 'ط±ظˆط§ظ‡ ط§ظ„طھط±ظ…ط°ظٹ ظˆط§ط¨ظ† ظ…ط§ط¬ظ‡',
      'type': 'light',
      'icon': 'ًںŒں',
      'target': 1,
      'color': 0xFFFF5722,
    },
    {
      'title': 'ط§ظ„ط­ظژظ…ظ’ط¯ظڈ ظ„ظگظ„ظژظ‘ظ‡ظگ',
      'reward': 'طھظ…ظ„ط£ ط§ظ„ظ…ظٹط²ط§ظ†',
      'hadith':
      'ط§ظ„ط·ظ‡ظˆط± ط´ط·ط± ط§ظ„ط¥ظٹظ…ط§ظ†طŒ ظˆط§ظ„ط­ظ…ط¯ ظ„ظ„ظ‡ طھظ…ظ„ط£ ط§ظ„ظ…ظٹط²ط§ظ†',
      'source': 'ط±ظˆط§ظ‡ ظ…ط³ظ„ظ…',
      'type': 'scale',
      'icon': 'âڑ–ï¸ڈ',
      'target': 1,
      'color': 0xFF607D8B,
    },
    {
      'title':
      'ط¨ظگط³ظ’ظ…ظگ ط§ظ„ظ„ظژظ‘ظ‡ظگ ط§ظ„ظژظ‘ط°ظگظٹ ظ„ظژط§ ظٹظژط¶ظڈط±ظڈظ‘ ظ…ظژط¹ظژ ط§ط³ظ’ظ…ظگظ‡ظگ ط´ظژظٹظ’ط،ظŒ ظپظگظٹ ط§ظ„ط£ظژط±ظ’ط¶ظگ ظˆظژظ„ظژط§ ظپظگظٹ ط§ظ„ط³ظژظ‘ظ…ظژط§ط،ظگ ظˆظژظ‡ظڈظˆظژ ط§ظ„ط³ظژظ‘ظ…ظگظٹط¹ظڈ ط§ظ„ط¹ظژظ„ظگظٹظ…ظڈ (3 ظ…ط±ط§طھ)',
      'reward': 'ط­ظپط¸ ظ…ظ† ظƒظ„ ط´ط±',
      'hadith':
      'ظ…ظ† ظ‚ط§ظ„ظ‡ط§ ط«ظ„ط§ط« ظ…ط±ط§طھ ط­ظٹظ† ظٹظڈطµط¨ط­ ظˆط«ظ„ط§ط« ظ…ط±ط§طھ ط­ظٹظ† ظٹظڈظ…ط³ظٹ ظ„ظ… ظٹط¶ط±ظ‡ ط´ظٹط،',
      'source': 'ط±ظˆط§ظ‡ ط£ط¨ظˆ ط¯ط§ظˆط¯ ظˆط§ظ„طھط±ظ…ط°ظٹ',
      'type': 'shield',
      'icon': 'ًں›،ï¸ڈ',
      'target': 3,
      'color': 0xFF00695C,
    },
    {
      'title': 'ط£ظژط¹ظڈظˆط°ظڈ ط¨ظگظƒظژظ„ظگظ…ظژط§طھظگ ط§ظ„ظ„ظژظ‘ظ‡ظگ ط§ظ„طھظژظ‘ط§ظ…ظژظ‘ط§طھظگ ظ…ظگظ†ظ’ ط´ظژط±ظگظ‘ ظ…ظژط§ ط®ظژظ„ظژظ‚ظژ (3 ظ…ط±ط§طھ)',
      'reward': 'ط­ظپط¸ ظ…ظ† ظƒظ„ ط£ط°ظ‰',
      'hadith':
      'ظ…ظ† ظ‚ط§ظ„ظ‡ط§ ط­ظٹظ† ظٹظڈظ…ط³ظٹ ط«ظ„ط§ط« ظ…ط±ط§طھ ظ„ظ… طھط¶ط±ظ‡ ط­ظڈظ…ط© طھظ„ظƒ ط§ظ„ظ„ظٹظ„ط©',
      'source': 'ط±ظˆط§ظ‡ ظ…ط³ظ„ظ…',
      'type': 'shield',
      'icon': 'ًں›،ï¸ڈ',
      'target': 3,
      'color': 0xFF37474F,
    },
  ];

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
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
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
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
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

  void _addDeed(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastTappedIndex = index;
      final type = deeds[index]['type'] as String;
      final target = deeds[index]['target'] as int;

      if (type == 'hasana') {
        final val = deeds[index]['hasanaValue'] as int? ?? 10;

        if (target > 1) {
          progressCounters[type] = (progressCounters[type] ?? 0) + 1;
          hasanat += val;

          if (progressCounters[type]! >= target) {
            progressCounters[type] = 0;
            _showCompletionSnackbar(deeds[index]['reward'] as String);
          }
        } else {
          hasanat += val;
          _showCompletionSnackbar(deeds[index]['reward'] as String);
        }
      } else if (target > 1) {
        progressCounters[type] = (progressCounters[type] ?? 0) + 1;

        if (progressCounters[type]! >= target) {
          progressCounters[type] = 0;
          _incrementType(type);
          _showCompletionSnackbar(deeds[index]['reward'] as String);
        }
      } else {
        _incrementType(type);
        _showCompletionSnackbar(deeds[index]['reward'] as String);
      }
    });

    _bounceController.forward().then((_) => _bounceController.reverse());
    _saveData();
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
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _gold.withValues(alpha: 0.3)),
          ),
          title: Text(
            'ط¥ط¹ط§ط¯ط© طھط¹ظٹظٹظ†',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'ظ‡ظ„ طھط±ظٹط¯ طھطµظپظٹط± ط¬ظ…ظٹط¹ ط§ظ„ط¹ط¯ط§ط¯ط§طھطں',
            style: GoogleFonts.cairo(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'ط¥ظ„ط؛ط§ط،',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
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
                _saveData();
                Navigator.pop(ctx);
              },
              child: Text(
                'طھطµظپظٹط±',
                style: GoogleFonts.cairo(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  String _getTypeFromTitle(String title) {
    if (title.contains('ظ†ط®ظ„')) return 'palm';
    if (title.contains('ظ‚طµظˆط±')) return 'palace';
    if (title.contains('ظƒظ†ظˆط²')) return 'jewel';
    if (title.contains('ط£ظ†ظˆط§ط±')) return 'light';
    if (title.contains('ط£ط¨ظˆط§ط¨')) return 'door';
    if (title.contains('ط¯ط±ظˆط¹')) return 'shield';
    if (title.contains('ظ…ظˆط§ط²ظٹظ†')) return 'scale';
    return 'hasana';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Directionality(
      textDirection: TextDirection.rtl,
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
              'ط­طµط§ط¯ ط§ظ„ط­ط³ظ†ط§طھ',
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
                tooltip: 'طھطµظپظٹط±',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildStatsSection(isDark, textColor, isSmall),
              ),
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
                          'ط§ظ„ط£ط¹ظ…ط§ظ„ ظˆط§ظ„ط£ط¬ظˆط±',
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
                          '${deeds.length} ط°ظƒط±',
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDeedCard(
                      index,
                      isDark,
                      textColor,
                      subColor,
                      isSmall,
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

  Widget _buildStatsSection(bool isDark, Color textColor, bool isSmall) {
    final stats = [
      {'title': 'ظ†ط®ظ„ط§طھ', 'count': palmTrees, 'icon': 'ًںŒ´', 'color': Colors.green},
      {'title': 'ظ‚طµظˆط±', 'count': palaces, 'icon': 'ًںڈ°', 'color': _gold},
      {'title': 'ظƒظ†ظˆط²', 'count': jewels, 'icon': 'ًں’ژ', 'color': Colors.blue},
      {'title': 'ط£ظ†ظˆط§ط±', 'count': lights, 'icon': 'âœ¨', 'color': Colors.orange},
      {'title': 'ط£ط¨ظˆط§ط¨', 'count': doors, 'icon': 'ًںڑھ', 'color': Colors.brown},
      {'title': 'ط¯ط±ظˆط¹', 'count': shields, 'icon': 'ًں›،ï¸ڈ', 'color': Colors.teal},
      {'title': 'ظ…ظˆط§ط²ظٹظ†', 'count': scales, 'icon': 'âڑ–ï¸ڈ', 'color': Colors.purple},
      {'title': 'ط­ط³ظ†ط§طھ', 'count': hasanat, 'icon': 'ًں“؟', 'color': Colors.cyan},
    ];

    final cardBg = isDark ? _bgCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.08) : _gold.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth < 280 ? 3 : 4;
          final spacing = isSmall ? 8.0 : 10.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (crossCount - 1)) / crossCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: stats.map((stat) {
              final type = _getTypeFromTitle(stat['title'] as String);
              final isAnimating = _lastTappedIndex != -1 &&
                  _lastTappedIndex < deeds.length &&
                  deeds[_lastTappedIndex]['type'] == type;

              return AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.scale(
                  scale: isAnimating ? _bounceAnim.value : 1.0,
                  child: child,
                ),
                child: SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: isSmall ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                      (stat['color'] as Color).withValues(alpha: isDark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (stat['color'] as Color).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stat['icon'] as String,
                            style: TextStyle(fontSize: isSmall ? 18 : 22),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${stat['count']}',
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: stat['color'] as Color,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stat['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDeedCard(
      int index,
      bool isDark,
      Color textColor,
      Color subColor,
      bool isSmall,
      ) {
    final deed = deeds[index];
    final type = deed['type'] as String;
    final target = deed['target'] as int;
    final currentProgress = progressCounters[type] ?? 0;
    final progressValue = target > 1 ? (currentProgress / target) : 0.0;
    final accentColor = Color(deed['color'] as int);

    final cardBg = isDark ? _bgCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.08) : accentColor.withValues(alpha: 0.15);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ط§ظ„ط¬ط§ط¦ط²ط©
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: isSmall ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  FittedBox(
                    child: Text(
                      deed['icon'] as String,
                      style: TextStyle(fontSize: isSmall ? 18 : 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      deed['reward'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: isSmall ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ط§ظ„ظ…ط­طھظˆظ‰
            Padding(
              padding: EdgeInsets.all(isSmall ? 14 : 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ط§ظ„ط°ظƒط±
                  Text(
                    deed['title'] as String,
                    style: GoogleFonts.amiri(
                      fontSize: isSmall ? 18 : 22,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // ط§ظ„ط­ط¯ظٹط«
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : accentColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : accentColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          deed['hadith'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: isSmall ? 11 : 12,
                            color: subColor,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 12,
                              color: accentColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                deed['source'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 11,
                                  color: accentColor.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ط§ظ„طھظ‚ط¯ظ… ظˆط§ظ„ط²ط±
                  Row(
                    children: [
                      if (target > 1) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ط§ظ„طھظ‚ط¯ظ…:',
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 11,
                                  color: subColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 7,
                                  backgroundColor: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                  valueColor:
                                  AlwaysStoppedAnimation(accentColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$currentProgress / $target',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      GestureDetector(
                        onTap: () => _addDeed(index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: target > 1 ? 16 : 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                              if (target <= 1) ...[
                                const SizedBox(width: 6),
                                FittedBox(
                                  child: Text(
                                    'ط¥ط¶ط§ظپط©',
                                    style: GoogleFonts.cairo(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmall ? 12 : 13,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
}