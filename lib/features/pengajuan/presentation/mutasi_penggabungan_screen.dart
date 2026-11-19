import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pengajuan_models.dart';
import '../data/pengajuan_repository.dart';
import 'widgets/spop_form_scaffold.dart';

class MutasiPenggabunganScreen extends ConsumerStatefulWidget {
  const MutasiPenggabunganScreen({super.key});

  @override
  ConsumerState<MutasiPenggabunganScreen> createState() =>
      _MutasiPenggabunganScreenState();
}

class _MutasiPenggabunganScreenState
    extends ConsumerState<MutasiPenggabunganScreen> {
  final _nopInputController = TextEditingController();
  final List<NopCekResult> _nopList = [];
  bool _isChecking = false;
  bool _deklarasiBersebelahan = false;

  @override
  void dispose() {
    _nopInputController.dispose();
    super.dispose();
  }

  Future<void> _addNop() async {
    final nop = _nopInputController.text.trim();
    if (nop.isEmpty) return;

    if (_nopList.any((e) => e.nop == nop)) {
      _showMsg('NOP sudah ada di dalam daftar.');
      return;
    }

    setState(() => _isChecking = true);
    final res = await ref.read(pengajuanRepositoryProvider).cekNop(nop);
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (!res.success || res.data == null || !res.data!.exists) {
      _showMsg(res.message ?? 'NOP tidak ditemukan di basis data.');
      return;
    }

    final checked = res.data!;
    if (_nopList.isNotEmpty) {
      final first = _nopList.first;
      if (first.kecamatan != checked.kecamatan ||
          first.kelurahan != checked.kelurahan ||
          first.blok != checked.blok) {
        _showMsg(
          'NOP harus berada pada kecamatan, kelurahan, dan blok yang sama dengan NOP pertama.',
        );
        return;
      }
    }

    setState(() {
      _nopList.add(checked);
      _nopInputController.clear();
    });
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFB91C1C)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SpopFormScaffold(
      title: 'Mutasi Penggabungan Objek',
      jenisTransaksiLabel: 'Mutasi Penggabungan Objek Pajak PBB P2',
      jenisSlug: 'mutasi_penggabungan',
      submitEndpoint: '/pengajuan/mutasi-penggabungan',
      showInfoTambahan: true,
      showKodeZnt: true,
      extraValidation: () {
        if (_nopList.length < 2) {
          return 'Tambahkan minimal 2 NOP yang akan digabungkan.';
        }
        if (!_deklarasiBersebelahan) {
          return 'Centang deklarasi bahwa lokasi objek saling bersebelahan.';
        }
        return null;
      },
      extraFields: () => {
        'nop_list[]': _nopList.map((e) => e.nop).toList(),
        'deklarasi_bersebelahan': _deklarasiBersebelahan,
      },
      topSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syarat Penggabungan Objek:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1. NOP yang digabung harus lebih dari 1.\n'
                  '2. Lokasi harus pada kecamatan, kelurahan, dan blok yang sama.\n'
                  '3. Lokasi objek harus saling bersebelahan.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nopInputController,
                  decoration: const InputDecoration(
                    labelText: 'Masukkan NOP',
                    hintText: 'Contoh: 33.72.010.001.005-0123.0',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 48),
                  ),
                  onPressed: _isChecking ? null : _addNop,
                  child: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tambah'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_nopList.isNotEmpty)
            Card(
              child: Column(
                children: _nopList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.nop,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Kec. ${item.kecamatan} · Kel. ${item.kelurahan} · Blok ${item.blok}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Hapus NOP',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() => _nopList.removeAt(idx));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: CheckboxListTile(
              value: _deklarasiBersebelahan,
              onChanged: (v) =>
                  setState(() => _deklarasiBersebelahan = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Saya menyatakan bahwa seluruh objek pajak pada daftar NOP di atas lokasinya saling bersebelahan.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
