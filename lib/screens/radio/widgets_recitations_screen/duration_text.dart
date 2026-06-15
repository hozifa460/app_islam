// lib/screens/radio/widgets_recitations_screen/widgets/duration_text.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/duration_cache_service.dart';

class DurationText extends StatefulWidget {
  final String audioUrl;
  final int? fallbackSeconds;
  final double fontSize;
  final Color color;

  const DurationText({
    super.key,
    required this.audioUrl,
    this.fallbackSeconds,
    this.fontSize = 10,
    this.color = Colors.white30,
  });

  @override
  State<DurationText> createState() => _DurationTextState();
}

class _DurationTextState extends State<DurationText> {
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant DurationText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl ||
        oldWidget.fallbackSeconds != widget.fallbackSeconds) {
      _bootstrap();
    }
  }

  void _bootstrap() {
    final cache = DurationCacheService();

    // ✅ أولاً: قيمة fallback إن وجدت
    Duration? initial;
    if (widget.fallbackSeconds != null && widget.fallbackSeconds! > 0) {
      initial = Duration(seconds: widget.fallbackSeconds!);
    }

    // ✅ ثانيًا: لو المدة موجودة في cache الذاكرة
    final cached = widget.audioUrl.isNotEmpty
        ? cache.getCached(widget.audioUrl)
        : null;

    _duration = cached ?? initial;

    if (mounted) {
      setState(() {});
    }

    // ✅ ثالثًا: جلب المدة الحقيقية إن لم تكن موجودة في cache
    if (widget.audioUrl.isNotEmpty && cached == null) {
      _loadRealDuration(widget.audioUrl);
    }
  }

  Future<void> _loadRealDuration(String url) async {
    final realDuration = await DurationCacheService().getDuration(url);
    if (!mounted) return;

    // ✅ تجاهل النتيجة إذا تغير الرابط أثناء الانتظار
    if (widget.audioUrl != url) return;

    if (realDuration != null && realDuration != _duration) {
      setState(() {
        _duration = realDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = DurationCacheService.formatDuration(_duration);
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: widget.fontSize,
        color: widget.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}