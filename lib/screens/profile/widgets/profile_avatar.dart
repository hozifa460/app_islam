import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_image_provider.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final String? photoUrl;
  final String name;
  final String loginMethod;
  final double size;
  final bool editable;
  final ValueChanged<String>? onImageChanged;

  const ProfileAvatarWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.loginMethod = 'email',
    this.size = 100,
    this.editable = true,
    this.onImageChanged,
  });

  @override
  State<ProfileAvatarWidget> createState() => ProfileAvatarWidgetState();
}

class ProfileAvatarWidgetState extends State<ProfileAvatarWidget>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFD4AF37);
  static const _goldD = Color(0xFFB8860B);

  late AnimationController _pulseCtrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گ ط§ط®طھظٹط§ط± طµظˆط±ط© â•گâ•گâ•گ
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 70,
      );
      if (picked == null || !mounted) return;

      // â•گâ•گâ•گ ط§ظ…ط³ط­ ظƒط§ط´ ط§ظ„طµظˆط±ط© ط§ظ„ظ‚ط¯ظٹظ…ط© â•گâ•گâ•گ
      final provider = context.read<ProfileImageProvider>();
      if (provider.imagePath != null) {
        await FileImage(File(provider.imagePath!)).evict();
      }

      // â•گâ•گâ•گ ط£ط¸ظ‡ط± ظپظˆط±ط§ظ‹ â•گâ•گâ•گ
      provider.setImageImmediately(picked.path);

      // â•گâ•گâ•گ ط§ط­ظپط¸ ظپظٹ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گâ•گ
      provider.updateImage(picked.path);

      widget.onImageChanged?.call(picked.path);
    } catch (e) {
      debugPrint('❌ خطأ: $e');
    }
  }

  // â•گâ•گâ•گ ط­ط°ظپ ط§ظ„طµظˆط±ط© â•گâ•گâ•گ
  Future<void> _removeImage() async {
    if (!mounted) return;
    final provider = context.read<ProfileImageProvider>();
    await provider.removeImage();
    widget.onImageChanged?.call('');
  }

  // â•گâ•گâ•گ ط¹ط±ط¶ ط®ظٹط§ط±ط§طھ â•گâ•گâ•گ
  void showImagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage =
        context.read<ProfileImageProvider>().hasImage;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 12,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تغيير الصورة الشخصية',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _SheetBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  color: _gold,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(width: 12),
                _SheetBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  color: Colors.blue,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasImage) ...[
                  const SizedBox(width: 12),
                  _SheetBtn(
                    icon: Icons.delete_outline_rounded,
                    label: 'إزالة',
                    color: Colors.red,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.size;



    // â•گâ•گâ•گ ط§ط³طھظ…ط¹ ظ„ظ„طھط؛ظٹظٹط±ط§طھ â•گâ•گâ•گ
    final provider = context.watch<ProfileImageProvider>();
    final imagePath = context.watch<ProfileImageProvider>().imagePath;
    final isUploading = provider.isUploading;

    return GestureDetector(
      onTap: widget.editable ? () => showImagePicker(context) : null,
      child: SizedBox(
        width: s + 20,
        height: s + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ط§ظ„ط­ظ„ظ‚ط© ط§ظ„ظ…طھظˆظ‡ط¬ط©
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                final v = _pulseCtrl.value;
                return Container(
                  width: s + 12 + (v * 4),
                  height: s + 12 + (v * 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        _gold.withValues(alpha: 0.6),
                        _goldD.withValues(alpha: 0.2),
                        _gold.withValues(alpha: 0.8),
                        _goldD.withValues(alpha: 0.2),
                        _gold.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.25 + v * 0.15),
                        blurRadius: 20 + v * 10,
                        spreadRadius: v * 3,
                      ),
                    ],
                  ),
                );
              },
            ),

            // ط§ظ„طµظˆط±ط©
            Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: isUploading
                    ? _buildUploading(s)
                    : _buildImage(s, imagePath),
              ),
            ),

            // ط²ط± ط§ظ„طھط¹ط¯ظٹظ„
            if (widget.editable)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_goldD, _gold],
                    ),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0A0E1A)
                          : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),

            // ط´ط§ط±ط© ط§ظ„ط·ط±ظٹظ‚ط©
            Positioned(
              top: 2,
              right: 2,
              child: _MethodBadge(method: widget.loginMethod),
            ),
          ],
        ),
      ),
    );
  }

// â•گâ•گâ•گ ظ…ط¤ط´ط± ط§ظ„ط±ظپط¹ â•گâ•گâ•گ
  Widget _buildUploading(double s) {
    return Container(
      color: _gold.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: s * 0.35,
              height: s * 0.35,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _gold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'جاري الحفظ',
              style: GoogleFonts.cairo(
                fontSize: s * 0.1,
                color: _gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

// â•گâ•گâ•گ ط¨ظ†ط§ط، ط§ظ„طµظˆط±ط© â•گâ•گâ•گ
  Widget _buildImage(double s, String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      // â•گâ•گâ•گ ط§ظ…ط³ط­ ط§ظ„ظƒط§ط´ ط§ظ„ظ‚ط¯ظٹظ… ظˆط£ط¸ظ‡ط± ط§ظ„ط¬ط¯ظٹط¯ط© â•گâ•گâ•گ
      final file = File(imagePath);
      final image = FileImage(file);
      image.evict(); // â†گ ظٹظ…ط³ط­ ط§ظ„ظƒط§ط´

      return Image(
        image: FileImage(file),
        fit: BoxFit.cover,
        width: s,
        height: s,
        key: UniqueKey(), // â†گ ظٹط¬ط¨ط± Flutter ط¹ظ„ظ‰ ط¥ط¹ط§ط¯ط© ط§ظ„ط¨ظ†ط§ط،
      );
    }
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return Image.network(
        widget.photoUrl!,
        fit: BoxFit.cover,
        width: s,
        height: s,
        errorBuilder: (_, __, ___) => _buildInitials(s),
      );
    }
    return _buildInitials(s);
  }

  Widget _buildInitials(double s) {
    final letters = widget.name.trim().isEmpty
        ? 'طں'
        : widget.name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join();

    return Container(
      color: _gold.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          letters,
          style: GoogleFonts.cairo(
            fontSize: s * 0.34,
            fontWeight: FontWeight.w700,
            color: _gold,
          ),
        ),
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (method) {
      'google' => (Icons.g_mobiledata_rounded, const Color(0xFFDB4437)),
      'apple' => (Icons.apple_rounded, Colors.white),
      _ => (Icons.email_rounded, const Color(0xFFD4AF37)),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}