import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../languages/app_localizations.dart';
import '../services/auth_service.dart';
import 'auth_text_field.dart';
import 'auth_button.dart';
import 'password_strength_bar.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final tr = context.tr; // ← الترجمة

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SignupError(error: _error),

          // ═══ الاسم ═══
          AuthTextField(
            controller: _name,
            label: tr.fullName,
            hint: tr.enterYourName,
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => (v == null || v.trim().length < 2)
                ? tr.nameRequired
                : null,
          ),

          const SizedBox(height: 14),

          // ═══ البريد ═══
          AuthTextField(
            controller: _email,
            label: tr.email,
            hint: tr.emailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return tr.emailRequired;
              if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$')
                  .hasMatch(v.trim())) return tr.emailInvalid;
              return null;
            },
          ),

          const SizedBox(height: 14),

          // ═══ كلمة المرور ═══
          AuthTextField(
            controller: _pass,
            label: tr.password,
            hint: tr.passwordMinLength,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (v) {
              if (v == null || v.isEmpty) return tr.passwordRequired;
              if (v.length < 6) return tr.passwordMinLength;
              return null;
            },
          ),

          const SizedBox(height: 4),
          PasswordStrengthBar(controller: _pass),
          const SizedBox(height: 14),

          // ═══ تأكيد كلمة المرور ═══
          AuthTextField(
            controller: _confirm,
            label: tr.confirmPassword,
            hint: tr.confirmPasswordHint,
            prefixIcon: Icons.lock_reset_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return tr.confirmRequired;
              if (v != _pass.text) return tr.passwordsNotMatch;
              return null;
            },
          ),

          const SizedBox(height: 26),

          // ═══ زر إنشاء الحساب ═══
          AuthButton(
            text: tr.createAccount, // ← مترجم
            isLoading: auth.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_key.currentState!.validate()) return;
    final r = await context.read<AuthService>().register(
      name: _name.text,
      email: _email.text,
      password: _pass.text,
    );
    if (!r.success && mounted) setState(() => _error = r.error);
  }
}

class _SignupError extends StatelessWidget {
  final String? error;
  const _SignupError({this.error});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: error != null
          ? Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(0.25)),
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