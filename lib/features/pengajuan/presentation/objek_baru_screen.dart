import 'package:flutter/material.dart';
import 'widgets/spop_form_scaffold.dart';

class ObjekBaruScreen extends StatelessWidget {
  final int? revisiId;
  final Map<String, dynamic>? initialData;
  final Map<String, String> existingBerkas;

  const ObjekBaruScreen({
    super.key,
    this.revisiId,
    this.initialData,
    this.existingBerkas = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isRevisi = revisiId != null;
    return SpopFormScaffold(
      title: isRevisi ? 'Revisi Objek Baru' : 'Pengajuan Objek Baru',
      jenisTransaksiLabel: 'Permohonan Objek Baru PBB P2',
      jenisSlug: 'objek_baru',
      submitEndpoint:
          isRevisi ? '/pengajuan/$revisiId/revisi' : '/pengajuan/objek-baru',
      showInfoTambahan: true,
      initialData: initialData,
      existingBerkas: existingBerkas,
    );
  }
}
