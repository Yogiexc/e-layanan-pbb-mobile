import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PilihMutasiScreen extends StatelessWidget {
  const PilihMutasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jenis Mutasi PBB'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMutasiCard(
            context,
            title: 'Mutasi Penuh',
            description:
                'Perubahan seluruh data subjek dan/atau objek pajak untuk satu NOP secara utuh.',
            icon: Icons.sync,
            onTap: () => context.push('/pengajuan/mutasi-penuh'),
          ),
          const SizedBox(height: 12),
          _buildMutasiCard(
            context,
            title: 'Mutasi Sebagian / Pemecahan',
            description:
                'Pemecahan satu bidang tanah/objek pajak menjadi dua atau lebih bidang baru.',
            icon: Icons.call_split,
            onTap: () => context.push('/pengajuan/mutasi-sebagian'),
          ),
          const SizedBox(height: 12),
          _buildMutasiCard(
            context,
            title: 'Mutasi Penggabungan Objek',
            description:
                'Penggabungan dua atau lebih objek pajak yang lokasinya bersebelahan menjadi satu.',
            icon: Icons.merge_type,
            onTap: () => context.push('/pengajuan/mutasi-penggabungan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMutasiCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF006C4C).withOpacity(0.12),
          child: Icon(icon, color: const Color(0xFF006C4C)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class ObjekBaruScreen extends StatelessWidget {
  const ObjekBaruScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulir Objek Baru (SPOP)')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Formulir SPOP Objek Baru sedang dirangkai sesuai spesifikasi PRD Bab 6.1...',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MutasiPenuhScreen extends StatelessWidget {
  const MutasiPenuhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mutasi Penuh')),
      body: const Center(
        child: Text('Formulir Mutasi Penuh (PRD Bab 6.2)'),
      ),
    );
  }
}

class MutasiSebagianScreen extends StatelessWidget {
  const MutasiSebagianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mutasi Sebagian')),
      body: const Center(
        child: Text('Formulir Mutasi Sebagian (PRD Bab 6.3)'),
      ),
    );
  }
}

class MutasiPenggabunganScreen extends StatelessWidget {
  const MutasiPenggabunganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mutasi Penggabungan Objek')),
      body: const Center(
        child: Text('Formulir Mutasi Penggabungan (PRD Bab 6.4)'),
      ),
    );
  }
}

class SketLokasiScreen extends StatelessWidget {
  final String? initialGeoJson;
  final void Function(String geoJson)? onSave;

  const SketLokasiScreen({super.key, this.initialGeoJson, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sket / Denah Lokasi Peta')),
      body: const Center(
        child: Text('Peta OpenStreetMap dengan flutter_map (PRD Bab 8)'),
      ),
    );
  }
}
