import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/prayer_repository.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/progress_ring.dart';
import 'achievements_screen.dart';
import 'insights_screen.dart';
import 'ai_coach_screen.dart';
import 'journey_screen.dart';
import 'buddy_screen.dart';
import 'leaderboard_screen.dart';

class PrayerOSScreen extends StatefulWidget {
  final Color primary;

  const PrayerOSScreen({super.key, required this.primary});

  @override
  State<PrayerOSScreen> createState() => _PrayerOSScreenState();
}

class _PrayerOSScreenState extends State<PrayerOSScreen>
    with TickerProviderStateMixin {

  final PrayerRepository _repo = PrayerRepository.instance;

  int streak = 0;
  int today = 0;
  double noor = 0;
  String rankEmoji = "🌱";
  String rankName = "الباحث";

  late AnimationController _heroController;
  late Animation<double> _heroScale;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroScale = CurvedAnimation(
      parent: _heroController,
      curve: Curves.elasticOut,
    );

    load();
  }

  Future<void> load() async {
    final profile = await _repo.getProfile();
    setState(() {
      streak = profile.currentStreak;
      today = profile.todayPrayersCount;
      noor = profile.totalNoorPoints;
      rankEmoji = profile.rank.emoji;
      rankName = profile.rank.arabicName;
      _heroController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Prayer OS", style: GoogleFonts.cairo()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [

            /// 🔥 HERO
            ScaleTransition(
              scale: _heroScale,
              child: _heroCard(cardBg, textColor),
            ),

            const SizedBox(height: 24),

            /// ✅ PROGRESS RING
            _progressSection(cardBg, textColor),

            const SizedBox(height: 24),

            /// 📱 QUICK ACTIONS (Glass)
            _glassCard(
              child: Column(
                children: [
                  _actionRow(
                    icon: Icons.route,
                    title: "رحلتك",
                    subtitle: "اليوم 7 من 30",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JourneyScreen(primary: widget.primary),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _actionRow(
                    icon: Icons.group,
                    title: "رفيق الصلاة",
                    subtitle: "أحمد ينتظرك",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuddyScreen(primary: widget.primary),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _actionRow(
                    icon: Icons.leaderboard,
                    title: "الترتيب",
                    subtitle: "أنت #12",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeaderboardScreen(primary: widget.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🗺 HEATMAP
            _sectionHeader("نشاطك الأخير", Icons.grid_view, textColor),
            const SizedBox(height: 12),
            const PrayerHeatmap(),

            const SizedBox(height: 24),

            /// 🤖 AI COACH
            _glassCard(
              child: ListTile(
                leading: const Icon(Icons.psychology, color: Colors.blue),
                title: Text("AI Coach", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text("استعد لنصيحة ذكية", style: GoogleFonts.cairo(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AICoachScreen(primary: widget.primary),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 📊 STATS
            _sectionHeader("إحصائياتك", Icons.analytics, textColor),
            const SizedBox(height: 12),
            _statsGrid(cardBg, textColor),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 🔥 HERO CARD
  Widget _heroCard(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.primary, widget.primary.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: widget.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$rankEmoji $rankName",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "🔥 $streak يوم متواصل",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                today.toString(),
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ PROGRESS RING
  Widget _progressSection(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "تقدم اليوم",
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: today / 5),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(widget.primary),
                    );
                  },
                ),
              ),
              Text(
                "${(today / 5 * 100).toInt()}%",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 STATS GRID
  Widget _statsGrid(Color cardBg, Color textColor) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard("✨", noor.toInt().toString(), "نور", cardBg, textColor),
        _statCard("🕌", "12", "مسجد", cardBg, textColor),
        _statCard("✅", "5", "أيام كاملة", cardBg, textColor),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 11, color: text.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  /// 🔷 GLASS CARD
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  /// 🔷 ACTION ROW
  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }

  /// 🔷 SECTION HEADER
  Widget _sectionHeader(String title, IconData icon, Color text) {
    return Row(
      children: [
        Icon(icon, color: text, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: text,
          ),
        ),
      ],
    );
  }
}