import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showDivider;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = destructive
        ? Colors.red.shade400
        : (isDark ? Colors.white : Colors.black87);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: (destructive ? Colors.red : color)
                          .withOpacity(0.1),
                    ),
                    child: Icon(
                      icon,
                      color: destructive ? Colors.red.shade400 : color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  trailing ??
                      (onTap != null
                          ? Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.shade400,
                      )
                          : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 14,
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.grey.shade100,
          ),
      ],
    );
  }
}