import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/profile/widgets/profile_avatar.dart';
import '../../auth/models/user_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final GlobalKey<ProfileAvatarWidgetState> avatarKey;
  final ValueChanged<String> onImageChanged;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.avatarKey,
    required this.onImageChanged,
  });

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1A3050), Color(0xFF0D1F35)]
              : const [Color(0xFF1B5E72), Color(0xFF134B5C)],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0xFF1B5E72).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ط²ط®ط±ظپط©
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.mosque_rounded,
                size: w * 0.35,
                color: Colors.white,
              ),
            ),
          ),

          // ظ†ظ‚ظˆط´
          Positioned.fill(
            child: CustomPaint(
              painter: _HeaderPatternPainter(),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatarWidget(
                key: avatarKey,
                photoUrl: user.photoUrl,
                name: user.name,
                loginMethod: user.loginMethod,
                size: (w * 0.24).clamp(85.0, 110.0),
                onImageChanged: onImageChanged,
              ),

              const SizedBox(height: 16),

              // ط§ظ„ط§ط³ظ…
              Text(
                user.name,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (user.email.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          user.email,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: _gold.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ط¹ط¶ظˆ ظ…ظ†ط° ${_fmtDate(user.createdAt)}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: _gold.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      '', 'ظٹظ†ط§ظٹط±', 'ظپط¨ط±ط§ظٹط±', 'ظ…ط§ط±ط³', 'ط£ط¨ط±ظٹظ„', 'ظ…ط§ظٹظˆ',
      'ظٹظˆظ†ظٹظˆ', 'ظٹظˆظ„ظٹظˆ', 'ط£ط؛ط³ط·ط³', 'ط³ط¨طھظ…ط¨ط±', 'ط£ظƒطھظˆط¨ط±',
      'ظ†ظˆظپظ…ط¨ط±', 'ط¯ظٹط³ظ…ط¨ط±',
    ];
    return '${m[d.month]} ${d.year}';
  }
}

class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.2),
        30.0 + i * 22,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}