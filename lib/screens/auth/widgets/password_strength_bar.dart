import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordStrengthBar extends StatefulWidget {
  final TextEditingController controller;
  const PasswordStrengthBar({super.key, required this.controller});

  @override
  State<PasswordStrengthBar> createState() =>
      _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<PasswordStrengthBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pass = widget.controller.text;
    if (pass.isEmpty) return const SizedBox(height: 8);

    final strength = _calc(pass);
    final color = _color(strength);
    final label = _label(strength);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 4,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.end,
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

  double _calc(String p) {
    double s = 0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.2;
    if (RegExp(r'[!@#\$%\^&\*\.\-_]').hasMatch(p)) s += 0.2;
    return s.clamp(0.0, 1.0);
  }

  Color _color(double s) {
    if (s < 0.3) return Colors.red;
    if (s < 0.6) return Colors.orange;
    if (s < 0.85) return Colors.amber;
    return Colors.green;
  }

  String _label(double s) {
    if (s < 0.3) return 'ضعيفة';
    if (s < 0.6) return 'متوسطة';
    if (s < 0.85) return 'جيدة';
    return 'قوية 💪';
  }
}