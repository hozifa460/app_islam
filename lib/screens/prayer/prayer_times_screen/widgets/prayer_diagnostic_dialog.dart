import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';

class PrayerDiagnosticDialog extends StatelessWidget {
  final bool hasNotification;
  final bool hasExactAlarm;
  final bool ignoresBattery;
  final Color gold;
  final VoidCallback onFixNotification;
  final VoidCallback onFixExactAlarm;
  final VoidCallback onFixBattery;

  const PrayerDiagnosticDialog({
    super.key,
    required this.hasNotification,
    required this.hasExactAlarm,
    required this.ignoresBattery,
    required this.gold,
    required this.onFixNotification,
    required this.onFixExactAlarm,
    required this.onFixBattery,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF151B26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        context.tr.adhanDiagnosticTitle,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(context,context.tr.notificationPermission, hasNotification, onFixNotification),
          _buildItem(context,context.tr.exactAlarmPermission, hasExactAlarm, onFixExactAlarm),
          _buildItem(context,context.tr.batteryExclusion, ignoresBattery, onFixBattery),
          const SizedBox(height: 15),
          Text(context.tr.xiaomiDiagnosticNote,
            style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
              context.tr.closeDialog,
              style: GoogleFonts.cairo(color: gold)
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context,title, bool isOk, VoidCallback fixAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.error,
            color: isOk ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            ),
          ),
          if (!isOk)
            TextButton(
              onPressed: fixAction,
              child: Text(
                context.tr.fixPermission,
                style: GoogleFonts.cairo(color: gold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}