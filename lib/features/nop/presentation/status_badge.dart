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

    Color border;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ditolak':
        bg = AppTheme.statusRejectedBg;
        text = AppTheme.statusRejectedText;
        border = AppTheme.statusRejectedBorder;
        icon = Icons.cancel_rounded;
        label = 'Perlu Revisi';
        break;
      case 'disetujui':
      case 'terdaftar':
        bg = AppTheme.statusApprovedBg;
        text = AppTheme.statusApprovedText;
        border = AppTheme.statusApprovedBorder;
        icon = Icons.check_circle_rounded;
        label = status.toLowerCase() == 'disetujui' ? 'Disetujui' : 'Terdaftar';
        break;
      case 'menunggu':
      default:
        bg = AppTheme.statusPendingBg;
        text = AppTheme.statusPendingText;
        border = AppTheme.statusPendingBorder;
        icon = Icons.hourglass_top_rounded;
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
