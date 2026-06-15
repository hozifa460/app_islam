import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ثيم الألوان للأدعية
class DuaTheme {
  final bool isDark;
  final Color primary;
  final Color bgColor;
  final Color textColor;
  final Color subColor;
  final Color cardBg;

  DuaTheme({
    required this.isDark,
    required this.primary,
  })  : bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA),
        textColor = isDark ? Colors.white : const Color(0xFF1A1A1A),
        subColor = isDark ? Colors.white60 : Colors.black54,
        cardBg = isDark ? const Color(0xFF151B26) : Colors.white;

  factory DuaTheme.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return DuaTheme(isDark: isDark, primary: primary);
  }
}

/// صندوق الأيقونة المزخرف
class DuaIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const DuaIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 52,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }
}

/// صندوق العدد المزخرف
class DuaCountBox extends StatelessWidget {
  final int count;
  final Color color;

  const DuaCountBox({
    super.key,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count دعاء',
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// كارد الفئة
class DuaCategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int duasCount;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;

  const DuaCategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.duasCount,
    required this.onTap,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ]
                : [
              Colors.white,
              color.withOpacity(0.05),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DuaIconBox(icon: icon, color: color),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                flex: 3,
                child: Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DuaCountBox(count: duasCount, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صندوق رقم الدعاء
class DuaNumberBox extends StatelessWidget {
  final int number;
  final Color color;

  const DuaNumberBox({
    super.key,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              '$number',
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// صندوق معلومات (المصدر / الفضل)
class DuaInfoBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color? textColor;
  final bool isSmall;

  const DuaInfoBox({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.textColor,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: isSmall ? 11 : 12,
                color: textColor ?? color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// صندوق الفضل
class DuaRewardBox extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool isSmall;

  const DuaRewardBox({
    super.key,
    required this.text,
    required this.isDark,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withOpacity(0.08)
            : Colors.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star_rounded,
            color: Colors.amber.shade700,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: isSmall ? 11 : 12,
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// زر العمل (نسخ / مشاركة)
class DuaActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const DuaActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 14,
          color: color,
        ),
        label: FittedBox(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(
            color: color.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// صف أزرار العمل
class DuaActionButtons extends StatelessWidget {
  final Color color;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const DuaActionButtons({
    super.key,
    required this.color,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DuaActionButton(
            label: 'نسخ',
            icon: Icons.copy_rounded,
            color: color,
            onPressed: onCopy,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DuaActionButton(
            label: 'مشاركة',
            icon: Icons.share_rounded,
            color: color,
            onPressed: onShare,
          ),
        ),
      ],
    );
  }
}

/// نص الدعاء الرئيسي
class DuaTextWidget extends StatelessWidget {
  final String text;
  final bool isDark;
  final double fontSize;

  const DuaTextWidget({
    super.key,
    required this.text,
    required this.isDark,
    this.fontSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.amiri(
        fontSize: fontSize,
        height: 2.0,
        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// زر الرجوع المخصص
class DuaBackButton extends StatelessWidget {
  final bool isDark;
  final Color? color;
  final Color primary;

  const DuaBackButton({
    super.key,
    required this.isDark,
    this.color,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isDark ? Colors.white : primary);
    final bgColor = color != null
        ? Colors.white.withOpacity(0.2)
        : isDark
        ? Colors.white.withOpacity(0.1)
        : primary.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: color != null ? Colors.white : buttonColor,
          size: color != null ? 20 : 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}