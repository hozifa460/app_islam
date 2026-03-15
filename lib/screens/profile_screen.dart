import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // الإحصائيات
  int _totalTasbih = 0;
  int _totalQuranPages = 0;
  int _totalAzkar = 0;
  int _streakDays = 0;
  int _totalPoints = 0;
  int _completedChallenges = 0;
  double _khatmaProgress = 0.0;

  // الإنجازات
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'قارئ مبتدئ',
      'description': 'قراءة 10 صفحات من القرآن',
      'icon': '📖',
      'unlocked': true,
      'progress': 1.0,
    },
    {
      'title': 'مسبّح',
      'description': '1000 تسبيحة',
      'icon': '📿',
      'unlocked': true,
      'progress': 1.0,
    },
    {
      'title': 'ذاكر الله',
      'description': '7 أيام متتالية',
      'icon': '🔥',
      'unlocked': true,
      'progress': 1.0,
    },
    {
      'title': 'حافظ الأذكار',
      'description': '30 يوم أذكار الصباح والمساء',
      'icon': '⭐',
      'unlocked': false,
      'progress': 0.6,
    },
    {
      'title': 'ختّام القرآن',
      'description': 'ختم القرآن كاملاً',
      'icon': '🏆',
      'unlocked': false,
      'progress': 0.35,
    },
    {
      'title': 'عابد الليل',
      'description': 'صلاة قيام الليل 10 مرات',
      'icon': '🌙',
      'unlocked': false,
      'progress': 0.3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalTasbih = prefs.getInt('totalTasbih') ?? 1250;
      _totalQuranPages = prefs.getInt('quranPages') ?? 45;
      _totalAzkar = prefs.getInt('azkarCount') ?? 89;
      _streakDays = prefs.getInt('streakDays') ?? 7;
      _totalPoints = prefs.getInt('totalPoints') ?? 2450;
      _completedChallenges = prefs.getInt('completedChallenges') ?? 15;
      _khatmaProgress = prefs.getDouble('khatmaProgress') ?? 0.35;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // الهيدر
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // الصورة الرمزية
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: Text(
                            '🤲',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'مسلم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⭐',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_totalPoints نقطة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // الإحصائيات الرئيسية
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('📖', '$_totalQuranPages', 'صفحة'),
                    _buildDivider(),
                    _buildStatItem('📿', '$_totalTasbih', 'تسبيحة'),
                    _buildDivider(),
                    _buildStatItem('🔥', '$_streakDays', 'يوم'),
                    _buildDivider(),
                    _buildStatItem('🎯', '$_completedChallenges', 'تحدي'),
                  ],
                ),
              ),
            ),
          ),

          // تقدم الختمة
          SliverToBoxAdapter(
            child: _buildKhatmaProgressCard(isDark),
          ),

          // الإنجازات
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإنجازات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${_achievements.where((a) => a['unlocked']).length}/${_achievements.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._achievements.map((achievement) {
                    return _buildAchievementCard(achievement, isDark);
                  }).toList(),
                ],
              ),
            ),
          ),

          // الإعدادات السريعة
          SliverToBoxAdapter(
            child: _buildQuickSettings(isDark),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildKhatmaProgressCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📖 تقدم الختمة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(_khatmaProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _khatmaProgress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'الجزء ${(_khatmaProgress * 30).toInt()} من 30',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, bool isDark) {
    final unlocked = achievement['unlocked'] as bool;
    final progress = achievement['progress'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFFD700).withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: unlocked
            ? [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 10,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFFFFD700).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                achievement['icon'],
                style: TextStyle(
                  fontSize: 24,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: unlocked
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF667eea)),
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            const Icon(
              Icons.check_circle,
              color: Color(0xFFFFD700),
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(bool isDark) {
    final settings = [
      {'icon': Icons.edit, 'title': 'تعديل الملف الشخصي', 'color': Colors.blue},
      {'icon': Icons.notifications, 'title': 'إعدادات الإشعارات', 'color': Colors.orange},
      {'icon': Icons.share, 'title': 'مشاركة التطبيق', 'color': Colors.green},
      {'icon': Icons.help, 'title': 'المساعدة والدعم', 'color': Colors.purple},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...settings.map((setting) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (setting['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    setting['icon'] as IconData,
                    color: setting['color'] as Color,
                    size: 22,
                  ),
                ),
                title: Text(
                  setting['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () {},
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}