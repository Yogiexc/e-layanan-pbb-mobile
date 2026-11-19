import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../nop/data/nop_repository.dart';
import '../../nop/presentation/status_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final nopAsync = ref.watch(nopListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalNop = nopAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final pendingCount = nopAsync.maybeWhen(
      data: (list) => list.where((e) => e.status == 'menunggu').length,
      orElse: () => 0,
    );
    final rejectedCount = nopAsync.maybeWhen(
      data: (list) => list.where((e) => e.status == 'ditolak').length,
      orElse: () => 0,
    );
    final recentItems = nopAsync.maybeWhen(
      data: (list) => list.take(2).toList(),
      orElse: () => [],
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nopListProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 18,
                  20,
                  26,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang,',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name
                                    : 'Wajib Pajak',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Kota Solo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDeep,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _HeaderStat(
                              label: 'Total Objek',
                              value: '$totalNop',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          Expanded(
                            child: _HeaderStat(
                              label: 'Menunggu',
                              value: '$pendingCount',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          Expanded(
                            child: _HeaderStat(
                              label: 'Perlu Revisi',
                              value: '$rejectedCount',
                              highlight: rejectedCount > 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Layanan Utama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BankingServiceCard(
                          title: 'Objek Baru',
                          subtitle: 'Daftar SPOP objek pajak baru',
                          icon: Icons.add_home_work_rounded,
                          accentColor: AppTheme.primary,
                          onTap: () => context.push('/pengajuan/objek-baru'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _BankingServiceCard(
                          title: 'Mutasi PBB',
                          subtitle: 'Penuh, pemecahan, & gabung',
                          icon: Icons.swap_horiz_rounded,
                          accentColor: AppTheme.accentGold,
                          onTap: () => context.push('/pengajuan/pilih-mutasi'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aktivitas Objek Pajak',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/nop'),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recentItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: const Text(
                        'Belum ada objek pajak terdaftar pada akun ini.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...recentItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            boxShadow: AppTheme.softShadow(context),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                context.push('/nop/detail', extra: item),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : AppTheme.primarySoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.home_work_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nop ?? 'NOP belum terbit',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.alamat,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: item.status),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceDark
                          : AppTheme.primarySoft.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.primary.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wilayah Layanan PBB P2 Kota Surakarta',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mencakup Kec. Laweyan, Serengan, Pasar Kliwon, Jebres, dan Banjarsari.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _HeaderStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFFBBF24) : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BankingServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _BankingServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
