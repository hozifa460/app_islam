// widgets/voice_search_button.dart
import 'package:flutter/material.dart';
import '../services/voice_search_service.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String text) onVoiceResult;

  const VoiceSearchButton({super.key, required this.onVoiceResult});

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.stop();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await VoiceSearchService.stopListening();
      if (!mounted) return;
      setState(() => _isListening = false);
      _animController.stop();
      _animController.reset();
      return;
    }

    setState(() => _isListening = true);
    _animController.repeat(reverse: true);

    await VoiceSearchService.startListening(
      onResult: (text) {
        if (!mounted) return;
        widget.onVoiceResult(text);
        setState(() => _isListening = false);
        _animController.stop();
        _animController.reset();
      },
      onListeningStart: () {},
      onListeningStop: () {
        if (!mounted) return;
        setState(() => _isListening = false);
        _animController.stop();
        _animController.reset();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        _animController.stop();
        _animController.reset();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $error')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                boxShadow:
                    _isListening
                        ? [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ]
                        : [],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (VoiceSearchService.isListening) {
      VoiceSearchService.stopListening();
    }
    _animController.dispose();
    super.dispose();
  }
}
