import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class GreatPersonDetailScreen extends StatefulWidget {
  final Map<String, String> person;
  final List<Map<String, String>> allPersons;
  final Color primaryColor;
  final String heroTag;

  const GreatPersonDetailScreen({
    super.key,
    required this.person,
    this.allPersons = const [],
    required this.primaryColor,
    required this.heroTag,
  });

  @override
  State<GreatPersonDetailScreen> createState() => _GreatPersonDetailScreenState();
}

class _GreatPersonDetailScreenState extends State<GreatPersonDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade1;
  late Animation<double> _fade2;
  late Animation<double> _fade3;
  late Animation<Offset> _slide1;
  late Animation<Offset> _slide2;
  late Animation<Offset> _slide3;
  Map<String, String>? _anotherPerson;

  @override
  void initState() {
    super.initState();

    _anotherPerson = _pickRandomAnotherPerson();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.45, curve: Curves.easeOut),
    );

    _fade2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.70, curve: Curves.easeOut),
    );

    _fade3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _slide1 = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _slide2 = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _slide3 = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  Map<String, String>? _pickRandomAnotherPerson() {
    if (widget.allPersons.isEmpty) return null;

    final others = widget.allPersons
        .where((p) => p['name'] != widget.person['name'])
        .toList();

    if (others.isEmpty) return null;

    final random = Random();
    return others[random.nextInt(others.length)];
  }

  void _sharePerson() {
    final text = '''
${widget.person['name']}
${widget.person['title']}

${widget.person['details'] ?? widget.person['desc'] ?? ''}

${(widget.person['quote'] ?? '').isNotEmpty ? 'قال أو نُقل عنه: "${widget.person['quote']}"' : ''}
''';

    Share.share(text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1714) : const Color(0xFFF7F3EA);
    const gold = Color(0xFFC8A44D);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sharePerson,
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.share_rounded),
        label: Text(
          'مشاركة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: widget.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.person['image'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.primaryColor,
                                  widget.primaryColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.35),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'عظيم من عظماء الإسلام',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 26,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.person['name'] ?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.person['title'] ?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFF4E7B2),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fade1,
                    child: SlideTransition(
                      position: _slide1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13211D) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.16 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.menu_book_rounded, color: widget.primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'نبذة عنه',
                                  style: GoogleFonts.cairo(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: widget.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.person['details'] ?? widget.person['desc'] ?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                height: 1.9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if ((widget.person['achievements'] ?? '').isNotEmpty)
                    FadeTransition(
                      opacity: _fade2,
                      child: SlideTransition(
                        position: _slide2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF13211D) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.primaryColor.withOpacity(0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.14 : 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, color: gold, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'أبرز الإنجازات',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                widget.person['achievements']!,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.cairo(
                                  fontSize: 14.5,
                                  height: 1.9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if ((widget.person['quote'] ?? '').isNotEmpty)
                    FadeTransition(
                      opacity: _fade3,
                      child: SlideTransition(
                        position: _slide3,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.primaryColor.withOpacity(0.10),
                                gold.withOpacity(0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: gold.withOpacity(0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.format_quote_rounded, color: gold, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'أثر أو مقولة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '“${widget.person['quote']}”',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: 24,
                                  height: 1.8,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E2415),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (_anotherPerson != null)
                    GestureDetector(
                      onTap: () {
                        final nextHeroTag = 'great_person_${_anotherPerson!['name']}';

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            reverseTransitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (_, animation, secondaryAnimation) {
                              return GreatPersonDetailScreen(
                                person: _anotherPerson!,
                                allPersons: widget.allPersons,
                                primaryColor: widget.primaryColor,
                                heroTag: nextHeroTag,
                              );
                            },
                            transitionsBuilder: (_, animation, secondaryAnimation, child) {
                              final curved = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );

                              return FadeTransition(
                                opacity: curved,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.04),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13211D) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: widget.primaryColor.withOpacity(0.10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.14 : 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                _anotherPerson!['image'] ?? '',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color: widget.primaryColor.withOpacity(0.12),
                                    child: Icon(Icons.person, color: widget.primaryColor),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'شخصية أخرى',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _anotherPerson!['name'] ?? '',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _anotherPerson!['title'] ?? '',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: widget.primaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}