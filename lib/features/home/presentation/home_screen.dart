import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../nop/data/nop_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final nopAsync = ref.watch(nopListProvider);
    final cs = Theme.of(context).colorScheme;

    final pendingCount = nopAsync.maybeWhen(
      data: (list) => list.where((e) => e.status == 'menunggu').length,
      orElse: () => 0,
    );
    final rejectedCount = nopAsync.maybeWhen(
      data: (list) => list.where((e) => e.status == 'ditolak').length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Layanan PBB Kota Solo'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nopListProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wajib Pajak Kota Surakarta',
                    style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'Wajib Pajak',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _SummaryMetric(
                        label: 'Menunggu',
                        value: '$pendingCount',
                        color: cs.onPrimary,
                      ),
                      const SizedBox(width: 24),
                      _SummaryMetric(
                        label: 'Perlu Revisi',
                        value: '$rejectedCount',
                        color: cs.onPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ajukan Layanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    title: 'Objek Baru',
                    subtitle: 'Formulir SPOP pendaftaran baru',
                    icon: Icons.add_home_work_outlined,
                    onTap: () => context.push('/pengajuan/objek-baru'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    title: 'Mutasi PBB',
                    subtitle: 'Penuh, pemecahan, atau gabung',
                    icon: Icons.sync_alt,
                    onTap: () => context.push('/pengajuan/pilih-mutasi'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_city_outlined,
                        size: 20, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cakupan Wilayah Layanan',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Khusus objek pajak di Kota Surakarta: Kec. Laweyan, Serengan, Pasar Kliwon, Jebres, dan Banjarsari.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cs.primary, size: 28),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
