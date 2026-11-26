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
  NopDetailModel? _nopDetail;
  bool _loadingNopDetail = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _jumlahBidangController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _onNopChanged(String? val) async {
    setState(() {
      _selectedNop = val;
      _nopDetail = null;
    });

    if (val != null && val.isNotEmpty) {
      setState(() => _loadingNopDetail = true);
      final res = await ref.read(nopRepositoryProvider).getNopDetail(val);
      if (!mounted) return;
      setState(() {
        _loadingNopDetail = false;
        _nopDetail = res.data;
      });
    }
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
      ref.invalidate(nopListProvider);
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
                      key: ValueKey(_selectedNop),
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
                      onChanged: _onNopChanged,
                      validator: (v) => v == null ? 'Pilih NOP Induk' : null,
                    ),
                    if (_loadingNopDetail)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_nopDetail != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 18, color: Color(0xFF9E1B22)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Data NOP Induk Terdaftar',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              _buildDetailRow('Wajib Pajak', _nopDetail!.namaSubjek),
                              _buildDetailRow('Alamat Objek', '${_nopDetail!.opNamaJalan}, RT ${_nopDetail!.opRt} / RW ${_nopDetail!.opRw}'),
                              _buildDetailRow('Kelurahan', _nopDetail!.opKelurahanNama),
                              _buildDetailRow('Kecamatan', _nopDetail!.opKecamatanNama),
                              _buildDetailRow('Luas Tanah', '${_nopDetail!.luasTanah.toStringAsFixed(0)} m²'),
                              _buildDetailRow('Luas Bangunan', '${_nopDetail!.luasBangunan.toStringAsFixed(0)} m²'),
                              _buildDetailRow('Jenis Tanah', _nopDetail!.jenisTanah),
                              _buildDetailRow('Kode ZNT', _nopDetail!.kodeZnt),
                              _buildDetailRow('No. Sertifikat', _nopDetail!.noSertifikat.isEmpty ? '-' : _nopDetail!.noSertifikat),
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
                suffixText: 'Bidang',
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final parsed = int.tryParse(v?.trim() ?? '');
                if (parsed == null || parsed < 2) {
                  return 'Jumlah bidang minimal 2';
                }
                return null;
              },
            ),
            if (_nopDetail != null) ...[
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final nBidang = int.tryParse(_jumlahBidangController.text.trim()) ?? 2;
                  final validNBidang = nBidang < 2 ? 2 : (nBidang > 12 ? 12 : nBidang);
                  final avgArea = _nopDetail!.luasTanah / validNBidang;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Simulasi Pembagian Bidang',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9E1B22).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Est. ± ${avgArea.toStringAsFixed(1)} m² / bidang',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFF9E1B22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 12,
                            child: Row(
                              children: List.generate(validNBidang, (index) {
                                final colors = [
                                  const Color(0xFF9E1B22),
                                  const Color(0xFFD49E35),
                                  const Color(0xFF2E7D32),
                                  const Color(0xFF1565C0),
                                  const Color(0xFF6A1B9A),
                                  const Color(0xFFE65100),
                                ];
                                final color = colors[index % colors.length];
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: index == validNBidang - 1 ? 0 : 2),
                                    color: color,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Luas Induk: ${_nopDetail!.luasTanah.toStringAsFixed(0)} m² akan dipecah menjadi $validNBidang bagian baru.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
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
