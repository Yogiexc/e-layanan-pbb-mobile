import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'ditolak':
        bg = AppTheme.statusRejectedBg;
        text = AppTheme.statusRejectedText;
        label = 'Ditolak';
        break;
      case 'disetujui':
        bg = AppTheme.statusApprovedBg;
        text = AppTheme.statusApprovedText;
        label = 'Disetujui';
        break;
      case 'terdaftar':
        bg = AppTheme.statusApprovedBg;
        text = AppTheme.statusApprovedText;
        label = 'Terdaftar';
        break;
      case 'menunggu':
      default:
        bg = AppTheme.statusPendingBg;
        text = AppTheme.statusPendingText;
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: text.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
