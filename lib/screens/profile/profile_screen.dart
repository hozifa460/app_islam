import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../languages/app_localizations.dart';
import '../../languages/locale_provider.dart';
import '../../languages/widgets/language_selector.dart';
import '../auth/services/auth_service.dart';
import 'widgets/guest_lock_screen.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_section_card.dart';
import 'widgets/profile_tile.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _gold = Color(0xFFD4AF37);
  final _avatarKey = GlobalKey<ProfileAvatarWidgetState>();
  String? _localImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final p = await SharedPreferences.getInstance();
    final path = p.getString('profile_local_image');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => _localImage = path);
    }
  }

  void _showLanguageSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                tr.selectLanguage,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
             Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: LanguageButton(),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final tr = context.tr; // â†گ ط§ظ„طھط±ط¬ظ…ط©

    if (!auth.isLoggedIn || (auth.user?.isGuest ?? true)) {
      return const GuestLockScreen();
    }

    final user = auth.user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // â•گâ•گâ•گ ظ‚ط³ظ… ط§ظ„ظ„ط؛ط© â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProfileSectionCard(
                title: tr.language,
                children: [
                  ProfileTile(
                    icon: Icons.language_rounded,
                    color: Colors.blue,
                    title: tr.language,
                    subtitle: '${context.watch<LocaleProvider>().currentFlag} '
                        '${context.watch<LocaleProvider>().currentLangName}',
                    showDivider: false,
                    onTap: () => _showLanguageSheet(context),
                  ),
                ],
              ),
            ),
          ),
          // â•گâ•گâ•گ AppBar â•گâ•گâ•گ
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              tr.profile,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: true,
          ),

          // â•گâ•گâ•گ ط§ظ„ظ‡ظٹط¯ط± â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ProfileHeaderCard(
                user: user,
                avatarKey: _avatarKey,
                onImageChanged: (path) {
                  setState(() => _localImage = path);
                },
              ),
            ),
          ),

          // â•گâ•گâ•گ ط§ظ„ط¥ط­طµط§ط¦ظٹط§طھ â•گâ•گâ•گ
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: ProfileStatsRow(),
            ),
          ),

          // â•گâ•گâ•گ ظ‚ط³ظ… ط§ظ„ط­ط³ط§ط¨ â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ProfileSectionCard(
                title: tr.account,
                children: [
                  ProfileTile(
                    icon: Icons.person_outline_rounded,
                    color: _gold,
                    title: tr.editName,
                    subtitle: user.name,
                    onTap: () => _editName(context, user.name),
                  ),
                  ProfileTile(
                    icon: Icons.camera_alt_outlined,
                    color: Colors.purple,
                    title: tr.changePhoto,
                    subtitle: tr.changePhotoSubtitle,
                    onTap: () =>
                        _avatarKey.currentState?.showImagePicker(context),
                  ),
                  if (user.loginMethod == 'email')
                    ProfileTile(
                      icon: Icons.lock_outline_rounded,
                      color: Colors.blue,
                      title: tr.resetPassword,
                      subtitle: tr.resetPasswordSubtitle,
                      onTap: () => _resetPassword(context, user.email),
                    ),
                  ProfileTile(
                    icon: Icons.verified_outlined,
                    color: Colors.green,
                    title: tr.accountStatus,
                    subtitle: _methodLabel(user.loginMethod, tr),
                    showDivider: false,
                    trailing: _StatusChip(method: user.loginMethod),
                  ),
                ],
              ),
            ),
          ),

          // â•گâ•گâ•گ ظ‚ط³ظ… ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProfileSectionCard(
                title: tr.settings,
                children: [
                  ProfileTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: isDark ? Colors.indigo : Colors.amber,
                    title: tr.appearance,
                    subtitle: isDark ? tr.darkMode : tr.lightMode,
                    trailing: Switch(
                      value: isDark,
                      onChanged: widget.onThemeChanged,
                      activeColor: _gold,
                      activeTrackColor: _gold.withValues(alpha: 0.3),
                    ),
                  ),
                  ProfileTile(
                    icon: Icons.notifications_none_rounded,
                    color: Colors.orange,
                    title: tr.notifications,
                    subtitle: tr.manageAlerts,
                    showDivider: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // â•گâ•گâ•گ ظ‚ط³ظ… ط§ظ„طھط·ط¨ظٹظ‚ â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProfileSectionCard(
                title: tr.theApp,
                children: [
                  ProfileTile(
                    icon: Icons.info_outline_rounded,
                    color: Colors.blue,
                    title: tr.aboutApp,
                    subtitle: tr.versionNumber('1.0.0'),
                    onTap: () => _showAbout(context),
                  ),
                  ProfileTile(
                    icon: Icons.star_outline_rounded,
                    color: _gold,
                    title: tr.rateApp,
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.share_outlined,
                    color: Colors.green,
                    title: tr.shareApp,
                    showDivider: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // â•گâ•گâ•گ طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬ â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProfileSectionCard(
                title: '',
                children: [
                  ProfileTile(
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    title: tr.signOut,
                    destructive: true,
                    showDivider: false,
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
          ),

          // â•گâ•گâ•گ ط¢ظٹط© â•گâ•گâ•گ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 24, horizontal: 20),
              child: Text(
                tr.quoteVerse,
                style: GoogleFonts.amiri(
                  fontSize: 15,
                  color: _gold.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 20,
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گ طھط¹ط¯ظٹظ„ ط§ظ„ط§ط³ظ… â•گâ•گâ•گ
  void _editName(BuildContext context, String current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController(text: current);
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          tr.editName,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.cairo(),
          autofocus: true,
          decoration: InputDecoration(
            hintText: tr.enterNewName,
            hintStyle: GoogleFonts.cairo(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold, width: 2),
            ),
            prefixIcon:
            const Icon(Icons.person_outline, color: _gold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.cancel,
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isEmpty || newName.length < 2) return;
              try {
                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(newName);
                await context.read<AuthService>().init();
              } catch (_) {}
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(tr.nameUpdated,
                      style: GoogleFonts.cairo()),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            child: Text(tr.save,
                style: GoogleFonts.cairo(
                    color: _gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گ ط¥ط¹ط§ط¯ط© طھط¹ظٹظٹظ† ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط± â•گâ•گâ•گ
  void _resetPassword(BuildContext context, String email) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          tr.resetPassword,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          tr.resetPasswordEmailMsg(email),
          style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.cancel,
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final r = await context
                  .read<AuthService>()
                  .resetPassword(email);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    r.success
                        ? tr.resetPasswordSent
                        : r.error ?? tr.error,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: r.success
                      ? Colors.green.shade600
                      : Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            child: Text(tr.send,
                style: GoogleFonts.cairo(
                    color: _gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گ ط¹ظ† ط§ظ„طھط·ط¨ظٹظ‚ â•گâ•گâ•گ
  void _showAbout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [_gold.withValues(alpha: 0.8), _gold],
          ).createShader(b),
          child: Text(
            tr.appTitle,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tr.appDescription}\n${tr.versionNumber('1.0.0')}',
              style: GoogleFonts.cairo(
                fontSize: 14,
                height: 1.8,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '﴿ وَاذْكُرُوا اللَّهَ كَثِيرًا ﴾',
              style: GoogleFonts.amiri(
                fontSize: 15,
                color: _gold.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.ok,
                style: GoogleFonts.cairo(
                    color: _gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گ طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬ â•گâ•گâ•گ
  void _signOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          tr.signOut,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          tr.signOutConfirm,
          style: GoogleFonts.cairo(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.cancel,
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst);
              }
            },
            child: Text(
              tr.signOut,
              style: GoogleFonts.cairo(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String m, AppLocalizations tr) => switch (m) {
    'google' => tr.loggedWithGoogle,
    'apple' => tr.loggedWithApple,
    'email' => tr.loggedWithEmail,
    _ => tr.guest,
  };
}

class _StatusChip extends StatelessWidget {
  final String method;
  const _StatusChip({required this.method});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isGuest = method == 'guest';
    final color = isGuest ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isGuest) ...[
            Icon(Icons.verified_rounded, color: color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            isGuest ? tr.guest : tr.verified,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}