import 'package:flutter/material.dart';

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
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFC62828);
        label = 'Ditolak';
        break;
      case 'disetujui':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        label = 'Disetujui';
        break;
      case 'terdaftar':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        label = 'Terdaftar';
        break;
      case 'menunggu':
      default:
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFE65100);
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
