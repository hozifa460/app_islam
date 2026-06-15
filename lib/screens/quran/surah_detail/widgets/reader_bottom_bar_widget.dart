import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/quran/audio_recitation_service.dart';

class ReaderBottomBarWidget extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final double bottomPadding;
  final String viewMode;
  final bool isAyahPlaying;
  final bool isMicActive;
  final bool isTextHidden;
  final int hideLevel;
  final String recitationSpokenText;
  final RecitationState recitationState;
  final VoidCallback onViewModeTap;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onHideToggleTap;
  final VoidCallback onMicTap;
  final Function(int) onHideLevelChanged;

  const ReaderBottomBarWidget({
    Key? key,
    required this.primary,
    required this.isDark,
    required this.bottomPadding,
    required this.viewMode,
    required this.isAyahPlaying,
    required this.isMicActive,
    required this.isTextHidden,
    required this.hideLevel,
    required this.recitationSpokenText,
    required this.recitationState,
    required this.onViewModeTap,
    required this.onPlayPauseTap,
    required this.onHideToggleTap,
    required this.onMicTap,
    required this.onHideLevelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final barColor = isDark ? const Color(0xFF232323) : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: isSmall ? 8 : 14,
          right: isSmall ? 8 : 14,
          bottom: bottomPadding > 0 ? 0 : 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط الحفظ
            if (viewMode == 'memorize' && !isMicActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildHideControlBar(isSmall),
              ),

            // حالة التسميع
            if (isMicActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildMicStatusBar(),
              ),

            // النص المنطوق
            if (isMicActive && recitationSpokenText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recitationSpokenText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // الشريط الرئيسي + الميكروفون
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // الأزرار
                Expanded(
                  child: Container(
                    height: isSmall ? 46 : 52,
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 3 : 5),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildPill(
                          icon: _getViewModeIcon(),
                          label: _getViewModeLabel(),
                          isSmall: isSmall,
                          highlighted: viewMode != 'image',
                          onTap: onViewModeTap,
                        ),
                        SizedBox(width: isSmall ? 2 : 3),
                        _buildPill(
                          icon: isAyahPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: isAyahPlaying ? 'وقف' : 'شغّل',
                          isSmall: isSmall,
                          highlighted: isAyahPlaying,
                          onTap: onPlayPauseTap,
                        ),
                        SizedBox(width: isSmall ? 2 : 3),
                        _buildPill(
                          icon: isTextHidden ? Icons.visibility : Icons.visibility_off,
                          label: isTextHidden ? 'أظهر' : 'أخفِ',
                          isSmall: isSmall,
                          onTap: onHideToggleTap,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: isSmall ? 8 : 12),

                // زر الميكروفون
                GestureDetector(
                  onTap: onMicTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSmall ? 58 : 68,
                    height: isSmall ? 58 : 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getMicGradientColors(),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getMicShadowColor(),
                          blurRadius: 14,
                          spreadRadius: isMicActive ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: recitationState == RecitationState.processing
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Icon(
                        isMicActive ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: isSmall ? 26 : 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getViewModeIcon() {
    switch (viewMode) {
      case 'text':
        return Icons.text_fields;
      case 'memorize':
        return Icons.school;
      default:
        return Icons.image_rounded;
    }
  }

  String _getViewModeLabel() {
    switch (viewMode) {
      case 'text':
        return 'نص';
      case 'memorize':
        return 'حفظ';
      default:
        return 'صور';
    }
  }

  List<Color> _getMicGradientColors() {
    if (recitationState == RecitationState.processing) {
      return [Colors.orange.shade400, Colors.orange.shade700];
    }
    if (isMicActive) {
      return [Colors.red.shade400, Colors.red.shade700];
    }
    return [const Color(0xFF66BB6A), const Color(0xFF43A047)];
  }

  Color _getMicShadowColor() {
    if (recitationState == RecitationState.processing) {
      return Colors.orange.withOpacity(0.35);
    }
    if (isMicActive) {
      return Colors.red.withOpacity(0.35);
    }
    return Colors.green.withOpacity(0.3);
  }

  Widget _buildHideControlBar(bool isSmall) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232323) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'إخفاء:',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          ...List.generate(4, (i) {
            final labels = ['٠', '١', '٢', '٣'];
            return Padding(
              padding: const EdgeInsets.only(left: 3),
              child: GestureDetector(
                onTap: () => onHideLevelChanged(i),
                child: Container(
                  width: 28,
                  height: 26,
                  decoration: BoxDecoration(
                    color: hideLevel == i ? primary : primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: hideLevel == i ? Colors.white : primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMicStatusBar() {
    final isProcessing = recitationState == RecitationState.processing;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isProcessing
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProcessing
              ? Colors.orange.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isProcessing)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Text(
            isProcessing ? 'جاري التحليل...' : 'جاري التسجيل...',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isProcessing ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required bool isSmall,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final ic = highlighted
        ? const Color(0xFFD6A300)
        : (isDark ? Colors.white70 : Colors.black87);
    final bg = highlighted
        ? const Color(0xFFFFF4D6)
        : isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFF5F5F5);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            height: isSmall ? 32 : 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: isSmall ? 13 : 16, color: ic),
                    SizedBox(width: isSmall ? 2 : 3),
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: isSmall ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: ic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}