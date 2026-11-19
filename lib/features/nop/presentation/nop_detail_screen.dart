import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../pengajuan/data/pengajuan_models.dart';
import '../../pengajuan/data/pengajuan_repository.dart';
import '../data/nop_model.dart';
import 'status_badge.dart';

class NopDetailScreen extends ConsumerStatefulWidget {
  final NopItemModel item;

  const NopDetailScreen({super.key, required this.item});

  @override
  ConsumerState<NopDetailScreen> createState() => _NopDetailScreenState();
}

class _NopDetailScreenState extends ConsumerState<NopDetailScreen> {
  PengajuanDetailModel? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.item.pengajuanTerakhir != null) {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref
        .read(pengajuanRepositoryProvider)
        .getPengajuanDetail(widget.item.pengajuanTerakhir!.id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success && res.data != null) {
        _detail = res.data;
      } else {
        _error = res.message ?? 'Gagal memuat detail pengajuan.';
      }
    });
  }

  void _openRevisi() {
    if (_detail == null) return;
    final jenis = _detail!.jenis;
    final extra = {
      'revisiId': _detail!.id,
      'initialData': _detail!.formData,
      'existingBerkas': _detail!.berkasUrls,
    };

    if (jenis == 'mutasi_penuh') {
      context.push('/pengajuan/mutasi-penuh', extra: extra);
    } else {
      context.push('/pengajuan/objek-baru', extra: extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDitolak = item.status.toLowerCase() == 'ditolak';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Objek & Pengajuan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchDetail,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (isDitolak && _detail?.catatanPenolakan != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFB91C1C)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFB91C1C), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Catatan Penolakan Admin',
                                  style: TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _detail!.catatanPenolakan!,
                              style: const TextStyle(
                                color: Color(0xFF7F1D1D),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _openRevisi,
                              icon: const Icon(Icons.edit_note),
                              label: const Text('Perbaiki dan Kirim Ulang'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.nop ?? 'NOP belum terbit',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: item.status),
                              ],
                            ),
                            const Divider(height: 24),
                            _InfoRow('Alamat Objek', item.alamat),
                            _InfoRow(
                              'Luas Tanah',
                              '${item.luasTanah.toStringAsFixed(0)} m²',
                            ),
                            if (item.pengajuanTerakhir != null) ...[
                              _InfoRow(
                                'No. Pendaftaran',
                                item.pengajuanTerakhir!.nomor,
                              ),
                              _InfoRow(
                                'Jenis Layanan',
                                item.pengajuanTerakhir!.jenis.replaceAll('_', ' '),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_detail != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Wajib Pajak',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const Divider(height: 20),
                              _InfoRow(
                                'Nama Subjek',
                                _detail!.formData['nama_subjek']?.toString() ??
                                    '-',
                              ),
                              _InfoRow(
                                'NIK',
                                AppValidators.maskNik(
                                  _detail!.formData['nik']?.toString(),
                                ),
                              ),
                              _InfoRow(
                                'No. Telepon',
                                _detail!.formData['no_telp']?.toString() ?? '-',
                              ),
                              _InfoRow(
                                'No. Sertifikat',
                                _detail!.formData['no_sertifikat']?.toString() ??
                                    '-',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_detail!.berkasUrls.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Berkas Terlampir',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const Divider(height: 20),
                                ..._detail!.berkasUrls.entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${e.key.toUpperCase()}: ${e.value}',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
