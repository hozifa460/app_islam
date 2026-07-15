import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:convert';

// â”€â”€ ظ†ظ…ظˆط°ط¬ ط§ظ„ط³ظ†ط© â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SunnahItem {
  final int id;
  final String name;
  final String description;
  final String hadith;
  final String icon;
  final String type;
  final String importance;
  final String timeCategory;
  final int rakaat;
  final String color;

  const _SunnahItem({
    required this.id,
    required this.name,
    required this.description,
    required this.hadith,
    required this.icon,
    required this.type,
    required this.importance,
    required this.timeCategory,
    required this.rakaat,
    required this.color,
  });

  factory _SunnahItem.fromJson(Map<String, dynamic> j) => _SunnahItem(
    id: j['id'] as int,
    name: j['name'] as String,
    description: j['description'] as String,
    hadith: j['hadith'] as String,
    icon: j['icon'] as String,
    type: j['type'] as String,
    importance: j['importance'] as String,
    timeCategory: j['time_category'] as String,
    rakaat: j['rakaat'] as int,
    color: j['color'] as String,
  );
}

// â”€â”€ ظپط¦ط© ط§ظ„ط³ظ†ظ† ط§ظ„ظ…ظڈط¬ظ…ظژظ‘ط¹ط© â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SunnahGroup {
  final String groupKey;   // 'current' | 'always' | 'weekly' | 'monthly' | 'yearly'
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<_SunnahItem> items;

  const _SunnahGroup({
    required this.groupKey,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.items,
  });
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class CurrentSunnahCard extends StatefulWidget {
  final Color deepGreen;
  final Color gold;
  final bool isDark;
  final VoidCallback? onNavigateToTracker;

  const CurrentSunnahCard({
    super.key,
    required this.deepGreen,
    required this.gold,
    required this.isDark,
    this.onNavigateToTracker,
  });

  @override
  State<CurrentSunnahCard> createState() => _CurrentSunnahCardState();
}

class _CurrentSunnahCardState extends State<CurrentSunnahCard>
    with TickerProviderStateMixin {
  // â”€â”€ ط¨ظٹط§ظ†ط§طھ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<_SunnahItem> _all = [];
  List<_SunnahGroup> _groups = [];
  bool _isLoading = true;

  // â”€â”€ ط­ط§ظ„ط© ط§ظ„طھط¨ظˆظٹط¨ط§طھ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _activeGroupIndex = 0;
  int _itemIndex = 0;

  // â”€â”€ ط£ظ†ظٹظ…ظٹط´ظ† â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // â”€â”€ ط«ظˆط§ط¨طھ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Map<String, String> _catIcons = {
    'fajr': '🌙',       'morning_adhkar': '🌅', 'duha': '☀️',
    'dhuhr': '🌞',      'asr': '🌤️',            'evening_adhkar': '🌆',
    'maghrib': '🌇',    'isha': '🌃',            'witr': '⭐',
    'tahajjud': '🌟',   'sleep': '😴',           'always': '♾️',
    'weekly_fast': '📅','monthly_fast': '🌕',    'friday': '🕌',
    'yearly_fast': '🗓️','yearly_prayer': '🎊',
  };

  static const Map<String, String> _catLabels = {
    'fajr': 'الفجر',             'morning_adhkar': 'أذكار الصباح',
    'duha': 'الضحى',             'dhuhr': 'الظهر',
    'asr': 'العصر',              'evening_adhkar': 'أذكار المساء',
    'maghrib': 'المغرب',         'isha': 'العشاء',
    'witr': 'الوتر',             'tahajjud': 'قيام الليل',
    'sleep': 'النوم',            'always': 'دائمة',
    'weekly_fast': 'أسبوعية',    'monthly_fast': 'شهرية',
    'friday': 'الجمعة',          'yearly_fast': 'سنوية',
    'yearly_prayer': 'سنوية',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ طھط­ظ…ظٹظ„ JSON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadData() async {
    try {
      final raw = await DefaultAssetBundle.of(context)
          .loadString('assets/json/sunnan.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      final list = (data['sunnahs'] as List)
          .map((e) => _SunnahItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _all = list;
        _groups = _buildGroups(list);
        _isLoading = false;
      });
      _playEntrance();
    } catch (e) {
      debugPrint('CurrentSunnahCard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _playEntrance() {
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
  }

  void _switchContent(VoidCallback action) {
    HapticFeedback.selectionClick();
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(action);
      _fadeCtrl.forward();
      _slideCtrl.forward(from: 0);
    });
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // â”€â”€ ط¨ظ†ط§ط، ط§ظ„ظ…ط¬ظ…ظˆط¹ط§طھ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  List<_SunnahGroup> _buildGroups(List<_SunnahItem> all) {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final groups = <_SunnahGroup>[];

    // â‘  ط³ظ†ظ† ط§ظ„ظˆظ‚طھ ط§ظ„ط­ط§ظ„ظٹ
    final current = all.where((s) => _isCurrentTime(s, now, hijri)).toList();
    if (current.isNotEmpty) {
      groups.add(_SunnahGroup(
        groupKey: 'current',
        title: 'سنن ${_getPeriodLabel(now)}',
        subtitle: 'وقتك الآن',
        emoji: _getPeriodEmoji(now),
        color: widget.deepGreen,
        items: current,
      ));
    }

    // â‘، ط§ظ„ط³ظ†ظ† ط§ظ„ط¯ط§ط¦ظ…ط©
    final always = all.where((s) => s.timeCategory == 'always').toList();
    if (always.isNotEmpty) {
      groups.add(_SunnahGroup(
        groupKey: 'always',
        title: 'السنن الدائمة',
        subtitle: 'في كل وقت',
        emoji: '♾️',
        color: const Color(0xFF0277BD),
        items: always,
      ));
    }

    // â‘¢ ط³ظ†ظ† ظٹظˆظ… ط§ظ„ط¬ظ…ط¹ط©
    if (now.weekday == DateTime.friday) {
      final friday = all.where((s) => s.timeCategory == 'friday').toList();
      if (friday.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'friday',
          title: 'سنن الجمعة',
          subtitle: 'يوم الجمعة المبارك',
          emoji: '🕌',
          color: const Color(0xFF2E7D32),
          items: friday,
        ));
      }
    }

    // â‘£ طµظٹط§ظ… ط§ظ„ط§ط«ظ†ظٹظ† ظˆط§ظ„ط®ظ…ظٹط³
    if (now.weekday == DateTime.monday || now.weekday == DateTime.thursday) {
      final weeklyFast = all.where((s) => s.timeCategory == 'weekly_fast').toList();
      if (weeklyFast.isNotEmpty) {
        final dayName = now.weekday == DateTime.monday ? 'الاثنين' : 'الخميس';
        groups.add(_SunnahGroup(
          groupKey: 'weekly',
          title: 'صيام يوم $dayName',
          subtitle: 'سنة أسبوعية',
          emoji: '📅',
          color: const Color(0xFF00695C),
          items: weeklyFast,
        ));
      }
    }

    // â‘¤ ط£ظٹط§ظ… ط§ظ„ط¨ظٹط¶ ط§ظ„ظ‡ط¬ط±ظٹط© (13طŒ 14طŒ 15)
    final hDay = hijri.hDay;
    if (hDay == 13 || hDay == 14 || hDay == 15) {
      final monthlyFast = all.where((s) => s.timeCategory == 'monthly_fast').toList();
      if (monthlyFast.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'monthly',
          title: 'أيام البيض',
          subtitle: 'اليوم ${_arabicDay(hDay)} من الشهر',
          emoji: '🌕',
          color: const Color(0xFF004D40),
          items: monthlyFast,
        ));
      }
    }

    // â‘¥ ط§ظ„ط³ظ†ظ† ط§ظ„ط³ظ†ظˆظٹط© - ط¹ط§ط´ظˆط±ط§ط، (10 ظ…ط­ط±ظ…)
    if (hijri.hMonth == 1 && (hijri.hDay == 9 || hijri.hDay == 10 || hijri.hDay == 11)) {
      final ashura = all.where((s) =>
      s.timeCategory == 'yearly_fast' &&
          s.name.contains('عاشوراء')).toList();
      if (ashura.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'yearly_ashura',
          title: 'صيام عاشوراء',
          subtitle: '${hDay == 10 ? "اليوم العاشر" : "قريباً"} من محرم',
          emoji: '🌙',
          color: const Color(0xFF37474F),
          items: ashura,
        ));
      }
    }

    // â‘¦ ط¹ط´ط± ط°ظٹ ط§ظ„ط­ط¬ط© (1-9)
    if (hijri.hMonth == 12 && hijri.hDay >= 1 && hijri.hDay <= 9) {
      final dhulHijja = all.where((s) =>
      s.timeCategory == 'yearly_fast' &&
          s.name.contains('الحجة')).toList();
      if (dhulHijja.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'yearly_dhulhijja',
          title: 'عشر ذي الحجة',
          subtitle: 'اليوم $hDay من ذي الحجة',
          emoji: '✨',
          color: const Color(0xFF6D4C41),
          items: dhulHijja,
        ));
      }
    }

    // â‘§ ظٹظˆظ… ط¹ط±ظپط© (9 ط°ظٹ ط§ظ„ط­ط¬ط©)
    if (hijri.hMonth == 12 && hijri.hDay == 9) {
      final arafa = all.where((s) =>
      s.timeCategory == 'yearly_fast' &&
          s.name.contains('عرفة')).toList();
      if (arafa.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'yearly_arafa',
          title: 'يوم عرفة',
          subtitle: '٩ ذو الحجة',
          emoji: '🏔️',
          color: const Color(0xFF4E342E),
          items: arafa,
        ));
      }
    }

    // â‘¨ ط´ظˆط§ظ„ - ط³طھط© ط£ظٹط§ظ… (1-26 ط´ظˆط§ظ„)
    if (hijri.hMonth == 10 && hijri.hDay >= 2 && hijri.hDay <= 26) {
      final shawwal = all.where((s) =>
      s.timeCategory == 'yearly_fast' &&
          s.name.contains('شوال')).toList();
      if (shawwal.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'yearly_shawwal',
          title: 'ست من شوال',
          subtitle: 'شهر شوال المبارك',
          emoji: '🌙',
          color: const Color(0xFF5D4037),
          items: shawwal,
        ));
      }
    }

    // â‘© ط£ظٹط§ظ… ط§ظ„ط¹ظٹط¯ظٹظ† (1 ط´ظˆط§ظ„ / 10 ط°ظٹ ط§ظ„ط­ط¬ط©)
    final isEid = (hijri.hMonth == 10 && hijri.hDay == 1) ||
        (hijri.hMonth == 12 && hijri.hDay == 10);
    if (isEid) {
      final eid = all.where((s) => s.timeCategory == 'yearly_prayer').toList();
      if (eid.isNotEmpty) {
        groups.add(_SunnahGroup(
          groupKey: 'yearly_eid',
          title: 'سنن العيد',
          subtitle: hijri.hMonth == 10 ? 'عيد الفطر' : 'عيد الأضحى',
          emoji: '🎉',
          color: const Color(0xFFE65100),
          items: eid,
        ));
      }
    }

    return groups;
  }

  // â”€â”€ ظ‡ظ„ ط§ظ„ط³ظ†ط© طھظ†ط·ط¨ظ‚ ط¹ظ„ظ‰ ط§ظ„ظˆظ‚طھ ط§ظ„ط­ط§ظ„ظٹطں â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _isCurrentTime(_SunnahItem s, DateTime now, HijriCalendar hijri) {
    final h = now.hour;
    switch (s.timeCategory) {
      case 'fajr':          return h >= 4 && h < 6;
      case 'morning_adhkar':return h >= 5 && h < 8;
      case 'duha':          return h >= 8 && h < 12;
      case 'dhuhr':         return h >= 11 && h < 14;
      case 'asr':           return h >= 14 && h < 17;
      case 'evening_adhkar':return h >= 15 && h < 18;
      case 'maghrib':       return h >= 17 && h < 20;
      case 'isha':          return h >= 19 && h < 23;
      case 'witr':          return h >= 20 && h < 24;
      case 'tahajjud':      return h >= 1 && h < 5;
      case 'sleep':         return h >= 21 || h < 2;
      default:              return false;
    }
  }

  // â”€â”€ ط§ظ„ظˆظ‚طھ ط§ظ„ط­ط§ظ„ظٹ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _getPeriodLabel(DateTime now) {
    final h = now.hour;
    if (h >= 4 && h < 6)  return 'الفجر';
    if (h >= 6 && h < 8)  return 'الصباح';
    if (h >= 8 && h < 12) return 'الضحى';
    if (h >= 12 && h < 14)return 'الظهر';
    if (h >= 14 && h < 17)return 'العصر';
    if (h >= 17 && h < 20)return 'المغرب';
    if (h >= 20 && h < 23)return 'العشاء';
    return 'الليل';
  }

  String _getPeriodEmoji(DateTime now) {
    final h = now.hour;
    if (h >= 4 && h < 6)  return '🌙';
    if (h >= 6 && h < 8)  return '🌅';
    if (h >= 8 && h < 12) return '☀️';
    if (h >= 12 && h < 14)return '🌞';
    if (h >= 14 && h < 17)return '🌤️';
    if (h >= 17 && h < 20)return '🌇';
    if (h >= 20 && h < 23)return '🌃';
    return '🌟';
  }

  String _arabicDay(int d) {
    const map = {
      13: 'الثالث عشر', 14: 'الرابع عشر', 15: 'الخامس عشر',
    };
    return map[d] ?? '$d';
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    if (_isLoading) return _skeleton(w);
    if (_groups.isEmpty) return _emptyState(w);

    final group = _groups[_activeGroupIndex];
    final item = group.items.isNotEmpty ? group.items[_itemIndex] : null;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF13211D) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: group.color.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: group.color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: widget.isDark ? Color(0xFF063B30).withValues(alpha: 0.9) : Colors.grey.withValues(alpha: 0.8),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // â‘  Header
          _buildHeader(group, w),

          // â‘، Group Tabs
          if (_groups.length > 1) _buildGroupTabs(w),

          // â‘¢ Content
          if (item != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                w * 0.038, 0, w * 0.038, w * 0.038,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildItemContent(item, group, w),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHeader(_SunnahGroup group, double w) {
    final small = w < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: w * 0.03,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [group.color, group.color.withValues(alpha: 0.75)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(22),
          topLeft: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          // Counter pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.025,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_itemIndex + 1} / ${group.items.length}',
              style: GoogleFonts.cairo(
                fontSize: small ? 10 : 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Nav arrows
          _headerNavBtn(Icons.chevron_left_rounded, _nextItem, w),
          const SizedBox(width: 4),
          _headerNavBtn(Icons.chevron_right_rounded, _prevItem, w),

          const Spacer(),

          // Title
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    group.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      fontSize: small ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(group.emoji, style: TextStyle(fontSize: small ? 15 : 17)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerNavBtn(IconData icon, VoidCallback onTap, double w) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.07,
        height: w * 0.07,
        constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: w * 0.045),
      ),
    );
  }

  // â”€â”€ Group Tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildGroupTabs(double w) {
    final small = w < 360;

    return Container(
      width: double.infinity,
      color: widget.isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.black.withValues(alpha: 0.02),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.03,
          vertical: w * 0.022,
        ),
        child: Row(
          children: List.generate(_groups.length, (i) {
            final g = _groups[i];
            final active = i == _activeGroupIndex;
            return GestureDetector(
              onTap: () => _switchContent(() {
                _activeGroupIndex = i;
                _itemIndex = 0;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: active
                      ? LinearGradient(
                    colors: [g.color, g.color.withValues(alpha: 0.75)],
                  )
                      : null,
                  color: active
                      ? null
                      : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08)),
                    width: 1,
                  ),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: g.color.withValues(alpha: 0.3),
                      blurRadius: 6,
                    )
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      g.emoji,
                      style: TextStyle(fontSize: small ? 12 : 13),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      g.subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: small ? 10 : 11,
                        fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                        color: active
                            ? Colors.white
                            : (widget.isDark
                            ? Colors.white54
                            : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // â”€â”€ Item Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildItemContent(
      _SunnahItem item, _SunnahGroup group, double w) {
    final small = w < 360;
    final cardColor = _hexColor(item.color);

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -150) _nextItem();
        if ((d.primaryVelocity ?? 0) > 150) _prevItem();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: w * 0.03),

          // â”€â”€ Name Row â”€â”€
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              _itemIconBox(item, cardColor, w, small),
              SizedBox(width: w * 0.03),
              // Name + importance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.name,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: _nameSize(w, item.name),
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A2E28),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _chip(
                          item.importance,
                          item.importance == 'مؤكدة'
                              ? group.color
                              : widget.gold,
                          small,
                          bold: true,
                          icon: item.importance == 'مؤكدة'
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                        ),
                        if (item.rakaat > 0) ...[
                          const SizedBox(width: 5),
                          _chip(
                            '${item.rakaat} ركعات',
                            const Color(0xFF1565C0),
                            small,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.025),

          // â”€â”€ Description â”€â”€
          _descBox(item.description, group.color, w, small),

          SizedBox(height: w * 0.025),

          // â”€â”€ Hadith â”€â”€
          _hadithBox(item.hadith, w, small),

          SizedBox(height: w * 0.025),

          // â”€â”€ Footer â”€â”€
          _buildFooter(item, group, w, small),

          SizedBox(height: w * 0.02),

          // â”€â”€ Dots â”€â”€
          if (group.items.length > 1) _buildDots(group, w),
        ],
      ),
    );
  }

  // â”€â”€ Icon Box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _itemIconBox(
      _SunnahItem item, Color cardColor, double w, bool small) {
    final boxSize = (w * 0.14).clamp(48.0, 64.0);
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: widget.isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(boxSize * 0.3),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.65),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          item.icon,
          style: TextStyle(fontSize: boxSize * 0.46),
        ),
      ),
    );
  }

  // â”€â”€ Description Box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _descBox(String text, Color color, double w, bool small) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.032),
      decoration: BoxDecoration(
        color: color.withValues(alpha: widget.isDark ? 0.07 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: small ? 11.5 : 12.5,
                color: widget.isDark ? Colors.white70 : Colors.black45,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.info_outline_rounded, color: color, size: 16),
        ],
      ),
    );
  }

  // â”€â”€ Hadith Box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _hadithBox(String text, double w, bool small) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.032),
      decoration: BoxDecoration(
        color: widget.gold.withValues(alpha: widget.isDark ? 0.07 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.gold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.amiri(
                fontSize: small ? 12.5 : 14,
                color: widget.isDark
                    ? const Color(0xFFD4A853)
                    : const Color(0xFF7B5800),
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('📖', style: TextStyle(fontSize: small ? 14 : 16)),
        ],
      ),
    );
  }

  // â”€â”€ Footer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildFooter(
      _SunnahItem item, _SunnahGroup group, double w, bool small) {
    return Row(
      children: [
        // ط²ط± ط¹ط±ط¶ ط§ظ„ظƒظ„
        _actionBtn(
          label: 'عرض الكل',
          icon: Icons.arrow_back_ios_rounded,
          color: group.color,
          w: w,
          small: small,
          onTap: widget.onNavigateToTracker ?? () {},
        ),
        const Spacer(),
        // ط§ظ„طھطµظ†ظٹظپ
        _chip(
          _catLabels[item.timeCategory] ?? item.type,
          group.color.withValues(alpha: 0.85),
          small,
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required double w,
    required bool small,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.035,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: small ? 11 : 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: Colors.white, size: small ? 11 : 12),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Dots â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDots(_SunnahGroup group, double w) {
    final count = group.items.length;
    final visible = count.clamp(0, 7);
    final start = (_itemIndex - 3).clamp(0, count - visible);
    final end = (start + visible).clamp(0, count);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (start > 0)
            Text('…',
                style: TextStyle(
                    color: group.color.withValues(alpha: 0.35), fontSize: 10)),
          ...List.generate(end - start, (i) {
            final ri = start + i;
            final active = ri == _itemIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? group.color
                    : group.color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
          if (end < count)
            Text('…',
                style: TextStyle(
                    color: group.color.withValues(alpha: 0.35), fontSize: 10)),
        ],
      ),
    );
  }

  // â”€â”€ Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _chip(String text, Color color, bool small,
      {bool bold = false, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: widget.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: small ? 9 : 10),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: small ? 9 : 10,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _nextItem() {
    final group = _groups[_activeGroupIndex];
    if (group.items.length <= 1) return;
    _switchContent(() {
      _itemIndex = (_itemIndex + 1) % group.items.length;
    });
  }

  void _prevItem() {
    final group = _groups[_activeGroupIndex];
    if (group.items.length <= 1) return;
    _switchContent(() {
      _itemIndex =
          (_itemIndex - 1 + group.items.length) % group.items.length;
    });
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Color _hexColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  double _nameSize(double w, String name) {
    final len = name.length;
    if (len <= 12) return w * 0.048;
    if (len <= 20) return w * 0.042;
    if (len <= 30) return w * 0.038;
    return w * 0.034;
  }

  // â”€â”€ Skeleton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _skeleton(double w) {
    return Container(
      height: w * 0.5,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF13211D) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.deepGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            height: w * 0.12,
            decoration: BoxDecoration(
              color: widget.deepGreen.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(22),
                topLeft: Radius.circular(22),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: widget.gold,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _skeletonLine(w * 0.55, w * 0.045),
                  SizedBox(height: w * 0.02),
                  _skeletonLine(double.infinity, w * 0.035),
                  SizedBox(height: w * 0.015),
                  _skeletonLine(w * 0.7, w * 0.035),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonLine(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: widget.deepGreen.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // â”€â”€ Empty â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _emptyState(double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF13211D) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.deepGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌙', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'لا توجد سنن خاصة بهذا الوقت',
              maxLines: 2,
              style: GoogleFonts.cairo(
                color: widget.isDark ? Colors.white54 : Colors.black45,
                fontSize: w * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}