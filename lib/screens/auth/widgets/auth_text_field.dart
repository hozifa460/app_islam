import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  static const _gold = Color(0xFFD4AF37);
  bool _obscure = true;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool get _focused => _focus.hasFocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused
              ? _gold
              : isDark
              ? Colors.white.withOpacity(0.10)
              : Colors.grey.shade300,
          width: _focused ? 2.0 : 1.4,
        ),
        color: isDark
            ? Colors.white.withOpacity(_focused ? 0.07 : 0.04)
            : Colors.white.withOpacity(_focused ? 0.95 : 0.75),
        boxShadow: _focused
            ? [
          BoxShadow(
            color: _gold.withOpacity(0.15),
            blurRadius: 14,
          ),
        ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.isPassword && _obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textDirection:
        widget.keyboardType == TextInputType.emailAddress
            ? TextDirection.ltr
            : TextDirection.rtl,
        style: GoogleFonts.cairo(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: GoogleFonts.cairo(
            color: _focused
                ? _gold
                : isDark
                ? Colors.white54
                : Colors.grey.shade600,
            fontSize: 14,
            fontWeight:
            _focused ? FontWeight.w600 : FontWeight.w400,
          ),
          hintStyle: GoogleFonts.cairo(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 14, end: 8),
            child: Icon(
              widget.prefixIcon,
              color: _focused
                  ? _gold
                  : isDark
                  ? Colors.white38
                  : Colors.grey,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: widget.isPassword
              ? Padding(
            padding:
            const EdgeInsetsDirectional.only(end: 6),
            child: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color:
                isDark ? Colors.white38 : Colors.grey,
                size: 21,
              ),
              onPressed: () =>
                  setState(() => _obscure = !_obscure),
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          errorStyle: GoogleFonts.cairo(
            color: Colors.red.shade300,
            fontSize: 11.5,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}