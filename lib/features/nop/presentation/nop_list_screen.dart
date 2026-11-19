import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/nop_repository.dart';
import 'status_badge.dart';

class NopListScreen extends ConsumerWidget {
  const NopListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nopAsync = ref.watch(nopListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Objek Pajak (NOP)'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nopListProvider);
        },
        child: nopAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 54, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada objek pajak terdaftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ajukan Objek Baru atau Mutasi untuk mendaftarkan NOP Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final nopDisplay = item.nop ?? 'NOP belum terbit';

                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                nopDisplay,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: item.nop == null
                                      ? Colors.grey[700]
                                      : const Color(0xFF006C4C),
                                ),
                              ),
                            ),
                            StatusBadge(status: item.status),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.alamat,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.square_foot_outlined,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Luas Tanah: ${item.luasTanah.toStringAsFixed(0)} m²',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        if (item.pengajuanTerakhir != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Pengajuan: ${item.pengajuanTerakhir!.nomor} (${item.pengajuanTerakhir!.jenis})',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ],
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
