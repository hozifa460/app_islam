import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/dua_model.dart';
import 'widgets/dua_animations.dart';
import 'widgets/dua_styled_widgets.dart';

class DuaCategoryScreen extends StatelessWidget {
  final DuaCategory category;
  final Color catColor;
  final IconData catIcon;

  const DuaCategoryScreen({
    super.key,
    required this.category,
    required this.catColor,
    required this.catIcon,
  });

  void _copyDua(BuildContext context, Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n📖 ${dua.source}'
        '${dua.reward.isNotEmpty ? '\n\n⭐ ${dua.reward}' : ''}';

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الدعاء', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareDua(Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n📖 ${dua.source}'
        '${dua.reward.isNotEmpty ? '\n\n⭐ ${dua.reward}' : ''}'
        '\n\n— تطبيق طريق الإسلام';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DuaTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, theme),
            _buildDuasList(theme, isSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, DuaTheme theme) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: catColor,
      leading: DuaBackButton(
        isDark: theme.isDark,
        color: catColor,
        primary: theme.primary,
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              category.name,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                catColor,
                catColor.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: 0.15,
              child: Icon(catIcon, size: 90, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuasList(DuaTheme theme, bool isSmall) {
    return SliverPadding(
      padding: const EdgeInsets.all(14),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final dua = category.duas[index];

            return AnimatedListItem(
              index: index,
              child: _DuaItemCard(
                dua: dua,
                index: index,
                catColor: catColor,
                theme: theme,
                isSmall: isSmall,
                onCopy: () => _copyDua(context, dua),
                onShare: () => _shareDua(dua),
              ),
            );
          },
          childCount: category.duas.length,
        ),
      ),
    );
  }
}

/// كارد عنصر الدعاء
class _DuaItemCard extends StatelessWidget {
  final Dua dua;
  final int index;
  final Color catColor;
  final DuaTheme theme;
  final bool isSmall;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _DuaItemCard({
    required this.dua,
    required this.index,
    required this.catColor,
    required this.theme,
    required this.isSmall,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.isDark
              ? Colors.white.withOpacity(0.08)
              : catColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          childrenPadding: EdgeInsets.zero,
          iconColor: catColor,
          collapsedIconColor: catColor.withOpacity(0.6),
          leading: DuaNumberBox(number: index + 1, color: catColor),
          title: Text(
            dua.title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 16,
              color: theme.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              dua.source,
              style: GoogleFonts.cairo(
                fontSize: isSmall ? 10 : 11,
                color: catColor.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          children: [
            _buildDivider(),
            _buildDuaText(),
            if (dua.source.isNotEmpty) _buildSourceBox(),
            if (dua.reward.isNotEmpty) _buildRewardBox(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Divider(
        color: theme.isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.grey.withOpacity(0.15),
        height: 1,
      ),
    );
  }

  Widget _buildDuaText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: DuaTextWidget(
        text: dua.text,
        isDark: theme.isDark,
        fontSize: isSmall ? 18.0 : 22.0,
      ),
    );
  }

  Widget _buildSourceBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DuaInfoBox(
        text: dua.source,
        icon: Icons.menu_book_rounded,
        color: catColor,
        isSmall: isSmall,
      ),
    );
  }

  Widget _buildRewardBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DuaRewardBox(
        text: dua.reward,
        isDark: theme.isDark,
        isSmall: isSmall,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: DuaActionButtons(
        color: catColor,
        onCopy: onCopy,
        onShare: onShare,
      ),
    );
  }
}