import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PilihMutasiScreen extends StatelessWidget {
  const PilihMutasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Jenis Mutasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pilih jenis layanan mutasi PBB sesuai kebutuhan pengajuan Anda.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _MutasiOptionCard(
            title: 'Mutasi Penuh',
            subtitle:
                'Perubahan seluruh data subjek dan/atau objek pajak untuk satu NOP secara utuh.',
            icon: Icons.sync_alt,
            onTap: () => context.push('/pengajuan/mutasi-penuh'),
          ),
          const SizedBox(height: 12),
          _MutasiOptionCard(
            title: 'Mutasi Sebagian / Pemecahan',
            subtitle:
                'Pemecahan satu NOP induk menjadi dua atau lebih bidang baru. Tanpa lampiran berkas.',
            icon: Icons.call_split,
            onTap: () => context.push('/pengajuan/mutasi-sebagian'),
          ),
          const SizedBox(height: 12),
          _MutasiOptionCard(
            title: 'Mutasi Penggabungan Objek',
            subtitle:
                'Penggabungan dua atau lebih NOP pada kecamatan, kelurahan, dan blok yang sama.',
            icon: Icons.merge_type,
            onTap: () => context.push('/pengajuan/mutasi-penggabungan'),
          ),
        ],
      ),
    );
  }
}

class _MutasiOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MutasiOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
