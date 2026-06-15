import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth_text_field.dart';
import 'auth_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const _gold = Color(0xFFD4AF37);

  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ErrorMsg(error: _error),
          AuthTextField(
            controller: _email,
            label: 'ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ',
            hint: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _vEmail,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _pass,
            label: 'ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±',
            hint: 'ط£ط¯ط®ظ„ ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: _vPass,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: _forgot,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'ظ†ط³ظٹطھ ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±طں',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: _gold.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„',
            isLoading: auth.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  String? _vEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'ط§ظ„ط¨ط±ظٹط¯ ظ…ط·ظ„ظˆط¨';
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(v.trim())) return 'ط¨ط±ظٹط¯ ط؛ظٹط± طµط­ظٹط­';
    return null;
  }

  String? _vPass(String? v) {
    if (v == null || v.isEmpty) return 'ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط± ظ…ط·ظ„ظˆط¨ط©';
    if (v.length < 6) return '6 ط£ط­ط±ظپ ط¹ظ„ظ‰ ط§ظ„ط£ظ‚ظ„';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_key.currentState!.validate()) return;
    final r = await context
        .read<AuthService>()
        .login(email: _email.text, password: _pass.text);
    if (!r.success && mounted) setState(() => _error = r.error);
  }

  void _forgot() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'ط¥ط¹ط§ط¯ط© طھط¹ظٹظٹظ† ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±',
          style:
          GoogleFonts.cairo(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ط£ط¯ط®ظ„ ط¨ط±ظٹط¯ظƒ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ظˆط³ظ†ط±ط³ظ„ ظ„ظƒ ط±ط§ط¨ط· ط¥ط¹ط§ط¯ط© ط§ظ„طھط¹ظٹظٹظ†',
              style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.cairo(),
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: _gold, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ط¥ظ„ط؛ط§ط،',
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;
              final r = await context
                  .read<AuthService>()
                  .resetPassword(emailCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      r.success
                          ? 'âœ“ طھظ… ط¥ط±ط³ط§ظ„ ط±ط§ط¨ط· ط¥ط¹ط§ط¯ط© ط§ظ„طھط¹ظٹظٹظ†'
                          : r.error ?? 'ط®ط·ط£',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: r.success
                        ? Colors.green.shade600
                        : Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(
              'ط¥ط±ط³ط§ظ„',
              style: GoogleFonts.cairo(
                  color: _gold, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMsg extends StatelessWidget {
  final String? error;
  const _ErrorMsg({this.error});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: error != null
          ? Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade300, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error!,
                style: GoogleFonts.cairo(
                  color: Colors.red.shade300,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}