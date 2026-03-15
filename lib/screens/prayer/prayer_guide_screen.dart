// screens/prayer_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prayer_guide_repo.dart';

class PrayerGuideScreen extends StatefulWidget {
  final Color primaryColor;
  const PrayerGuideScreen({super.key, required this.primaryColor});

  @override
  State<PrayerGuideScreen> createState() => _PrayerGuideScreenState();
}

class _PrayerGuideScreenState extends State<PrayerGuideScreen> {
  bool _loading = true;
  bool _error = false;
  String _query = '';

  Map<String, dynamic>? _data;
  int _selectedCategoryIndex = 0;

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  @override
  void initState() {
    super.initState();
    _loadSmart();
  }

  Future<void> _loadSmart() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final data = await PrayerGuideRepo.fetchSmart();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _refreshOnline() async {
    try {
      final data = await PrayerGuideRepo.fetchOnlineAndCache();
      setState(() => _data = data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'دليل الصلاة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: _gold),
              onPressed: _loadSmart,
            ),
          ),
        ],
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:  IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: (() => Navigator.pop(context)),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _gold))
          : _error || _data == null
          ? _buildError()
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'ابحث في الدليل...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.4)),
                    icon: Icon(Icons.search, color: _gold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // التصنيفات
            _buildCategories(),
            const SizedBox(height: 20),
            // المحتوى
            Expanded(
              child: RefreshIndicator(
                color: _gold,
                backgroundColor: _bgCard,
                onRefresh: _refreshOnline,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 70, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'لا يمكن تحميل المحتوى',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من الاتصال بالإنترنت',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loadSmart,
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = (_data!['categories'] as List).cast<Map<String, dynamic>>();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isSel = i == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSel
                      ? [_gold.withOpacity(0.3), _gold.withOpacity(0.1)]
                      : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSel ? _gold.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  categories[i]['title'].toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSel ? _gold : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final categories = (_data!['categories'] as List).cast<Map<String, dynamic>>();
    final selected = categories[_selectedCategoryIndex];
    final items = (selected['items'] as List).cast<Map<String, dynamic>>();

    final q = _query.trim();
    final filteredItems = q.isEmpty
        ? items
        : items.where((it) {
      final text = '${it['title']} ${it['content']} ${it['bullets']}';
      return text.contains(q);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final it = filteredItems[index];
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Expanded(
                      child: Text(
                        it['title'] ?? '',
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (it['content'] != null && it['content'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    it['content'],
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      height: 1.8,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
                if (it['bullets'] != null) ...[
                  const SizedBox(height: 12),
                  ...(it['bullets'] as List).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: _gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b.toString(),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}