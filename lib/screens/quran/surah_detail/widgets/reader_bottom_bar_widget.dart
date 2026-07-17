import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class ReaderBottomBarWidget extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final double bottomPadding;
  final String viewMode;
  final bool showAudioPanel;
  final bool isAyahPlaying;
  final bool isTextHidden;
  final int hideLevel;
  final int currentAyah;
  final AudioPlayer audioPlayer;
  final List<Map<String, String>> reciters;
  final String selectedReciterId;
  final String selectedReciterName;
  final VoidCallback onListenTap;
  final VoidCallback onCloseAudioPanel;
  final VoidCallback onViewModeTap;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onHideToggleTap;
  final ValueChanged<int> onHideLevelChanged;
  final void Function(String id, String name) onReciterSelected;

  const ReaderBottomBarWidget({
    super.key,
    required this.primary,
    required this.isDark,
    required this.bottomPadding,
    required this.viewMode,
    required this.showAudioPanel,
    required this.isAyahPlaying,
    required this.isTextHidden,
    required this.hideLevel,
    required this.currentAyah,
    required this.audioPlayer,
    required this.reciters,
    required this.selectedReciterId,
    required this.selectedReciterName,
    required this.onListenTap,
    required this.onCloseAudioPanel,
    required this.onViewModeTap,
    required this.onPlayPauseTap,
    required this.onHideToggleTap,
    required this.onHideLevelChanged,
    required this.onReciterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final maxPanelHeight = MediaQuery.sizeOf(context).height * .50;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding > 0 ? 0 : 7),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxPanelHeight),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewMode == 'memorize') _buildHideControl(),
                if (showAudioPanel) ...[
                  _buildAudioCard(),
                  const SizedBox(height: 7),
                  _buildReciters(),
                  const SizedBox(height: 7),
                ],
                _buildCompactActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioCard() {
    final card = isDark ? const Color(0xFF153653) : const Color(0xFF174B78);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 11),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onCloseAudioPanel,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      selectedReciterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentAyah > 0
                          ? 'الآية $currentAyah'
                          : 'تلاوة الصفحة الحالية',
                      style: GoogleFonts.cairo(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.graphic_eq_rounded,
                color: Color(0xFFE2B95F),
                size: 23,
              ),
            ],
          ),
          StreamBuilder<Duration?>(
            stream: audioPlayer.durationStream,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                initialData: Duration.zero,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final maxMs =
                      duration.inMilliseconds <= 0
                          ? 1.0
                          : duration.inMilliseconds.toDouble();
                  final value =
                      position.inMilliseconds
                          .clamp(0, maxMs.toInt())
                          .toDouble();
                  return Row(
                    children: [
                      Text(_durationLabel(position), style: _timeStyle),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2.5,
                            activeTrackColor: const Color(0xFFE2B95F),
                            inactiveTrackColor: Colors.white30,
                            thumbColor: const Color(0xFFE2B95F),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            min: 0,
                            max: maxMs,
                            value: value,
                            onChanged:
                                duration == Duration.zero
                                    ? null
                                    : (next) => audioPlayer.seek(
                                      Duration(milliseconds: next.round()),
                                    ),
                          ),
                        ),
                      ),
                      Text(_durationLabel(duration), style: _timeStyle),
                    ],
                  );
                },
              );
            },
          ),
          InkWell(
            onTap: onPlayPauseTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD5A84A),
              ),
              child: Icon(
                isAyahPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 31,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _timeStyle =>
      GoogleFonts.cairo(color: Colors.white60, fontSize: 9);

  String _durationLabel(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildReciters() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF222222) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4, bottom: 5),
          child: Text(
            'اختر القارئ',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 62,
          child: ListView.separated(
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: reciters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 7),
            itemBuilder: (_, index) {
              final reciter = reciters[index];
              final id = reciter['id']!;
              final name = reciter['name']!;
              return _ReciterChip(
                name: name,
                selected: id == selectedReciterId,
                primary: primary,
                isDark: isDark,
                onTap: () => onReciterSelected(id, name),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildCompactActions() => Container(
    height: 54,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF222222) : Colors.white,
      borderRadius: BorderRadius.circular(27),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .09),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        _action(
          icon:
              showAudioPanel
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.headphones_rounded,
          label: showAudioPanel ? 'إخفاء الاستماع' : 'الاستماع',
          onTap: showAudioPanel ? onCloseAudioPanel : onListenTap,
          active: showAudioPanel,
        ),
        _action(
          icon:
              viewMode == 'memorize'
                  ? Icons.school_rounded
                  : Icons.menu_book_rounded,
          label: viewMode == 'memorize' ? 'الحفظ' : 'القراءة',
          onTap: onViewModeTap,
          active: viewMode == 'memorize',
        ),
        _action(
          icon:
              isTextHidden
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
          label: isTextHidden ? 'إظهار' : 'إخفاء',
          onTap: onHideToggleTap,
        ),
      ],
    ),
  );

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) => Expanded(
    child: Material(
      color: active ? primary.withValues(alpha: .10) : Colors.transparent,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: active ? primary : null),
                const SizedBox(width: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: active ? primary : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildHideControl() => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF222222) : Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      children: [
        Text('إخفاء للحفظ', style: GoogleFonts.cairo(fontSize: 10)),
        for (var level = 0; level < 4; level++)
          ChoiceChip(
            visualDensity: VisualDensity.compact,
            label: Text('$level'),
            selected: hideLevel == level,
            onSelected: (_) => onHideLevelChanged(level),
          ),
      ],
    ),
  );
}

class _ReciterChip extends StatelessWidget {
  final String name;
  final bool selected;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _ReciterChip({
    required this.name,
    required this.selected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color:
        selected
            ? primary.withValues(alpha: .10)
            : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF7F7F7)),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: selected ? primary : const Color(0xFFE7DDC7),
              child: Icon(
                Icons.record_voice_over_rounded,
                size: 17,
                color: selected ? Colors.white : const Color(0xFF69562E),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
