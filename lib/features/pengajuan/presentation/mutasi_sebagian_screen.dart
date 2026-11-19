import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../nop/data/nop_model.dart';
import '../../nop/data/nop_repository.dart';
import '../data/pengajuan_repository.dart';

class MutasiSebagianScreen extends ConsumerStatefulWidget {
  const MutasiSebagianScreen({super.key});

  @override
  ConsumerState<MutasiSebagianScreen> createState() =>
      _MutasiSebagianScreenState();
}

class _MutasiSebagianScreenState extends ConsumerState<MutasiSebagianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahBidangController = TextEditingController(text: '2');
  final _keteranganController = TextEditingController();

  String? _selectedNop;
  NopItemModel? _selectedItem;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _jumlahBidangController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedNop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih NOP Induk terlebih dahulu.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final res = await ref.read(pengajuanRepositoryProvider).submitMutasiSebagian(
          nop: _selectedNop!,
          jumlahBidang: int.parse(_jumlahBidangController.text.trim()),
          keterangan: _keteranganController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Pengajuan berhasil dikirim.'),
          backgroundColor: const Color(0xFF15803D),
        ),
      );
      context.go('/nop');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Gagal mengirim pengajuan.'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nopAsync = ref.watch(nopListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mutasi Sebagian / Pemecahan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Pelayanan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pendaftaran Mutasi Sebagian (Tanpa Lampiran Berkas)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cukup isi jumlah bidang pemecahan dan keterangan. Data tiap bidang akan dilengkapi oleh petugas admin.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            nopAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Gagal memuat daftar NOP.'),
              data: (items) {
                final validItems = items
                    .where((e) => e.nop != null && e.nop!.isNotEmpty)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedNop,
                      decoration: const InputDecoration(labelText: 'NOP Induk *'),
                      items: validItems
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.nop,
                              child: Text(e.nop!),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedNop = val;
                          _selectedItem = validItems
                              .where((e) => e.nop == val)
                              .firstOrNull;
                        });
                      },
                      validator: (v) => v == null ? 'Pilih NOP Induk' : null,
                    ),
                    if (_selectedItem != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data NOP Induk',
                                style: TextStyle(fontWeight: FontWeight.w700),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _jumlahBidangController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Bidang (Minimal 2) *',
              ),
              validator: (v) {
                final parsed = int.tryParse(v?.trim() ?? '');
                if (parsed == null || parsed < 2) {
                  return 'Jumlah bidang minimal 2';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keteranganController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Keterangan Pemecahan *',
                alignLabelWithHint: true,
                hintText:
                    'Jelaskan pembagian bidang dan rencana luas masing-masing...',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Keterangan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }
}
