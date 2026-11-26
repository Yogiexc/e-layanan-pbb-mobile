import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_layout.dart';
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
    final secondaryColor =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    final allItems = nopAsync.maybeWhen(data: (l) => l, orElse: () => []);
    final totalNop = allItems.length;
    final pendingCount = allItems.where((e) => e.status == 'menunggu').length;
    final rejectedCount = allItems.where((e) => e.status == 'ditolak').length;
    final recentItems = allItems.take(3).toList();

    final initials = (user?.name.isNotEmpty == true ? user!.name : 'WP')
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = ResponsiveLayout.isCompact(width);
            final hPad = ResponsiveLayout.horizontalPadding(width);
            final maxW = ResponsiveLayout.maxContentWidth(width);

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(nopListProvider),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isCompact ? 19 : 22,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.name.split(' ').first ?? "Wajib Pajak"}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isCompact ? 16 : 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'PBB P2 Kota Surakarta',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Pengaturan Akun',
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: () => context.go('/akun'),
                            icon: const Icon(Icons.settings_outlined, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Summary Card (Premium Banking Glass Card)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryDeep.withValues(alpha: 0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8B121A),
                                  Color(0xFF6B0E14),
                                  Color(0xFF4A080C),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Subtle Geometric Card Pattern
                                Positioned(
                                  right: -40,
                                  top: -40,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.accentGold.withValues(alpha: 0.12),
                                        width: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  bottom: -50,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.03),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isCompact ? 20 : 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.account_balance_rounded,
                                                  size: 14,
                                                  color: AppTheme.accentGold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'E-LAYANAN PBB SURAKARTA',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.85),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.9,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.15),
                                              ),
                                            ),
                                            child: const Text(
                                              'Bapenda Solo',
                                              style: TextStyle(
                                                color: AppTheme.accentGold,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '$totalNop',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isCompact ? 38 : 44,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -1.2,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Objek Pajak (NOP)',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Kelola status pendaftaran, ketetapan, & berkas mutasi',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryDeep
                                            .withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () => context.go('/nop'),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.schedule_rounded,
                                                      size: 16,
                                                      color: Color(0xFFFBBF24),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$pendingCount Menunggu',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.chevron_right_rounded,
                                                      size: 14,
                                                      color: Colors.white70,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () => context.go('/nop'),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline_rounded,
                                                      size: 16,
                                                      color: rejectedCount > 0
                                                          ? const Color(0xFFFCA5A5)
                                                          : Colors.white
                                                              .withValues(alpha: 0.6),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$rejectedCount Perlu Revisi',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (rejectedCount > 0) ...[
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                        Icons.chevron_right_rounded,
                                                        size: 14,
                                                        color: Color(0xFFFCA5A5),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                      const SizedBox(height: 24),

                      // Services: reflows cleanly on very narrow vs medium/wide
                      const Text(
                        'Layanan Pengajuan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (width < 340)
                        Column(
                          children: [
                            _QuickServiceTile(
                              icon: Icons.add_home_work_rounded,
                              title: 'Objek Baru',
                              subtitle: 'Formulir SPOP pendaftaran baru',
                              onTap: () =>
                                  context.push('/pengajuan/objek-baru'),
                            ),
                            const SizedBox(height: 10),
                            _QuickServiceTile(
                              icon: Icons.swap_horiz_rounded,
                              title: 'Mutasi PBB',
                              subtitle: 'Penuh, pemecahan, atau gabung',
                              onTap: () =>
                                  context.push('/pengajuan/pilih-mutasi'),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _QuickServiceTile(
                                icon: Icons.add_home_work_rounded,
                                title: 'Objek Baru',
                                subtitle: 'Formulir SPOP',
                                onTap: () =>
                                    context.push('/pengajuan/objek-baru'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickServiceTile(
                                icon: Icons.swap_horiz_rounded,
                                title: 'Mutasi PBB',
                                subtitle: 'Penuh / Pecah / Gabung',
                                onTap: () =>
                                    context.push('/pengajuan/pilih-mutasi'),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 26),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Objek Pajak Terbaru',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/nop'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 44),
                            ),
                            child: const Text(
                              'Lihat semua',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: recentItems.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Belum ada objek pajak terdaftar.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children:
                                    recentItems.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  final isLast = idx == recentItems.length - 1;
                                  return Column(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.vertical(
                                          top: idx == 0
                                              ? const Radius.circular(16)
                                              : Radius.zero,
                                          bottom: isLast
                                              ? const Radius.circular(16)
                                              : Radius.zero,
                                        ),
                                        onTap: () => context.push(
                                          '/nop/detail',
                                          extra: item,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.nop ??
                                                          'NOP belum terbit',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${item.alamat} · ${item.luasTanah.toStringAsFixed(0)} m²',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: secondaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              StatusBadge(status: item.status),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                          indent: 16,
                                          endIndent: 16,
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppTheme.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: secondaryColor.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                    height: 1.3,
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
