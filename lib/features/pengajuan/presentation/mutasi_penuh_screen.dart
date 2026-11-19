import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../nop/data/nop_model.dart';
import '../../nop/data/nop_repository.dart';
import 'widgets/spop_form_scaffold.dart';

class MutasiPenuhScreen extends ConsumerStatefulWidget {
  final int? revisiId;
  final Map<String, dynamic>? initialData;
  final Map<String, String> existingBerkas;

  const MutasiPenuhScreen({
    super.key,
    this.revisiId,
    this.initialData,
    this.existingBerkas = const {},
  });

  @override
  ConsumerState<MutasiPenuhScreen> createState() => _MutasiPenuhScreenState();
}

class _MutasiPenuhScreenState extends ConsumerState<MutasiPenuhScreen> {
  String? _selectedNop;
  NopItemModel? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedNop = widget.initialData?['nop']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final nopAsync = ref.watch(nopListProvider);
    final isRevisi = widget.revisiId != null;

    return SpopFormScaffold(
      title: isRevisi ? 'Revisi Mutasi Penuh' : 'Mutasi Penuh',
      jenisTransaksiLabel: 'Mutasi / Perubahan Subjek dan Objek Pajak PBB P2',
      jenisSlug: 'mutasi_penuh',
      submitEndpoint:
          isRevisi ? '/pengajuan/${widget.revisiId}/revisi' : '/pengajuan/mutasi-penuh',
      initialData: widget.initialData,
      existingBerkas: widget.existingBerkas,
      extraValidation: () {
        if (_selectedNop == null || _selectedNop!.isEmpty) {
          return 'Pilih NOP yang akan dimutasi terlebih dahulu.';
        }
        return null;
      },
      extraFields: () => {'nop': _selectedNop},
      topSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pilih NOP yang Diubah',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          nopAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Gagal memuat daftar NOP.'),
            data: (items) {
              final validItems =
                  items.where((e) => e.nop != null && e.nop!.isNotEmpty).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: validItems.any((e) => e.nop == _selectedNop)
                        ? _selectedNop
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'NOP Milik Akun *',
                    ),
                    items: validItems
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.nop,
                            child: Text(e.nop!),
                          ),
                        )
                        .toList(),
                    onChanged: isRevisi
                        ? null
                        : (val) {
                            setState(() {
                              _selectedNop = val;
                              _selectedItem = validItems
                                  .where((e) => e.nop == val)
                                  .firstOrNull;
                            });
                          },
                  ),
                  if (_selectedItem != null) ...[
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Lama (Referensi)',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text('Alamat: ${_selectedItem!.alamat}'),
                            Text(
                              'Luas Tanah: ${_selectedItem!.luasTanah.toStringAsFixed(0)} m²',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
