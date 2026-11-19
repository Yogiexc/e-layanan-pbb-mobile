import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/nop_repository.dart';
import 'status_badge.dart';

class NopListScreen extends ConsumerWidget {
  const NopListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nopAsync = ref.watch(nopListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Objek Pajak (NOP)')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nopListProvider),
        child: nopAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFB91C1C)),
                  const SizedBox(height: 12),
                  Text(
                    error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(nopListProvider),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 56),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada objek pajak terdaftar',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ajukan Objek Baru atau Mutasi melalui tab Beranda.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/nop/detail', extra: item),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.nop ?? 'NOP belum terbit',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              StatusBadge(status: item.status),
                            ],
                          ),
                          const Divider(height: 18),
                          Text(
                            item.alamat,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Luas Tanah: ${item.luasTanah.toStringAsFixed(0)} m²',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (item.pengajuanTerakhir != null)
                                Text(
                                  item.pengajuanTerakhir!.nomor,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
