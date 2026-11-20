import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
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
  NopDetailModel? _nopDetail;
  bool _loadingNop = false;
  Map<String, dynamic>? _populatedForm;

  @override
  void initState() {
    super.initState();
    _selectedNop = widget.initialData?['nop']?.toString();
    _populatedForm = widget.initialData;
    if (_selectedNop != null && _selectedNop!.isNotEmpty) {
      _loadNopDetail(_selectedNop!);
    }
  }

  Future<void> _loadNopDetail(String nop) async {
    setState(() => _loadingNop = true);
    final res = await ref.read(nopRepositoryProvider).getNopDetail(nop);
    if (!mounted) return;
    setState(() {
      _loadingNop = false;
      if (res.success && res.data != null) {
        _nopDetail = res.data;
        if (widget.initialData == null) {
          _populatedForm = {
            'nop': nop,
            'op_nama_jalan': _nopDetail!.opNamaJalan,
            'op_blok_no': _nopDetail!.opBlokNo,
            'op_kecamatan_id': _nopDetail!.opKecamatanId,
            'op_kelurahan_id': _nopDetail!.opKelurahanId,
            'op_rt': _nopDetail!.opRt,
            'op_rw': _nopDetail!.opRw,
            'luas_tanah': _nopDetail!.luasTanah.toStringAsFixed(0),
            'jenis_tanah': _nopDetail!.jenisTanah,
            'no_sertifikat': _nopDetail!.noSertifikat,
            'jumlah_bangunan': _nopDetail!.jumlahBangunan.toString(),
          };
        }
      }
    });
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
      initialData: _populatedForm,
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
                            if (val != null) {
                              setState(() => _selectedNop = val);
                              _loadNopDetail(val);
                            }
                          },
                  ),
                  if (_loadingNop)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (_nopDetail != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Data Lama Objek & Subjek (Referensi Read-Only)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            _detailRow('Alamat Objek', '${_nopDetail!.opNamaJalan} (RT ${_nopDetail!.opRt}/RW ${_nopDetail!.opRw})'),
                            _detailRow('Wilayah', 'Kel. ${_nopDetail!.opKelurahanNama}, Kec. ${_nopDetail!.opKecamatanNama}'),
                            _detailRow('Luas Tanah / Bangunan', '${_nopDetail!.luasTanah.toStringAsFixed(0)} m² / ${_nopDetail!.luasBangunan.toStringAsFixed(0)} m²'),
                            _detailRow('Jenis Tanah / ZNT', '${_nopDetail!.jenisTanah} (ZNT: ${_nopDetail!.kodeZnt})'),
                            _detailRow('Jml Bangunan / Sertifikat', '${_nopDetail!.jumlahBangunan} bgn / ${_nopDetail!.noSertifikat}'),
                            const SizedBox(height: 6),
                            const Text(
                              'Wajib Pajak Lama:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            _detailRow('Nama / NIK', '${_nopDetail!.namaSubjek} (${AppValidators.maskNik(_nopDetail!.nik)})'),
                            _detailRow('Alamat WP', _nopDetail!.alamatSubjek),
                            _detailRow('NPWP / Pekerjaan', '${_nopDetail!.npwp} / ${_nopDetail!.pekerjaan}'),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
