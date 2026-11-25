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
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: cs.primary.withValues(alpha: 0.08),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cs.primary, size: 24),
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
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
