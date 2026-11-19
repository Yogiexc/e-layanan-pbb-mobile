import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/pengajuan_models.dart';
import '../../data/pengajuan_repository.dart';
import 'berkas_upload_section.dart';

class SpopFormControllers {
  final nopBersama = TextEditingController();
  final noSpptLama = TextEditingController();
  final opNamaJalan = TextEditingController();
  final opBlokNo = TextEditingController();
  final opRt = TextEditingController();
  final opRw = TextEditingController();

  final nik = TextEditingController();
  final namaSubjek = TextEditingController();
  final noTelp = TextEditingController();
  final npwp = TextEditingController();
  final wpNamaJalan = TextEditingController();
  final wpBlokNo = TextEditingController();
  final wpKelurahan = TextEditingController();
  final wpRt = TextEditingController();
  final wpRw = TextEditingController();
  final wpKecamatan = TextEditingController();
  final wpKabupatenKota = TextEditingController();
  final wpKodePos = TextEditingController();

  final kodeZnt = TextEditingController();
  final luasTanah = TextEditingController();
  final noSertifikat = TextEditingController();
  final jumlahBangunan = TextEditingController(text: '0');

  void populateFromMap(Map<String, dynamic> data) {
    nopBersama.text = data['nop_bersama']?.toString() ?? '';
    noSpptLama.text = data['no_sppt_lama']?.toString() ?? '';
    opNamaJalan.text = data['op_nama_jalan']?.toString() ?? '';
    opBlokNo.text = data['op_blok_no']?.toString() ?? '';
    opRt.text = data['op_rt']?.toString() ?? '';
    opRw.text = data['op_rw']?.toString() ?? '';

    nik.text = data['nik']?.toString() ?? '';
    namaSubjek.text = data['nama_subjek']?.toString() ?? '';
    noTelp.text = data['no_telp']?.toString() ?? '';
    npwp.text = data['npwp']?.toString() ?? '';
    wpNamaJalan.text = data['wp_nama_jalan']?.toString() ?? '';
    wpBlokNo.text = data['wp_blok_no']?.toString() ?? '';
    wpKelurahan.text = data['wp_kelurahan']?.toString() ?? '';
    wpRt.text = data['wp_rt']?.toString() ?? '';
    wpRw.text = data['wp_rw']?.toString() ?? '';
    wpKecamatan.text = data['wp_kecamatan']?.toString() ?? '';
    wpKabupatenKota.text = data['wp_kabupaten_kota']?.toString() ?? '';
    wpKodePos.text = data['wp_kode_pos']?.toString() ?? '';

    kodeZnt.text = data['kode_znt']?.toString() ?? '';
    luasTanah.text = data['luas_tanah']?.toString() ?? '';
    noSertifikat.text = data['no_sertifikat']?.toString() ?? '';
    jumlahBangunan.text = data['jumlah_bangunan']?.toString() ?? '0';
  }

  void dispose() {
    nopBersama.dispose();
    noSpptLama.dispose();
    opNamaJalan.dispose();
    opBlokNo.dispose();
    opRt.dispose();
    opRw.dispose();
    nik.dispose();
    namaSubjek.dispose();
    noTelp.dispose();
    npwp.dispose();
    wpNamaJalan.dispose();
    wpBlokNo.dispose();
    wpKelurahan.dispose();
    wpRt.dispose();
    wpRw.dispose();
    wpKecamatan.dispose();
    wpKabupatenKota.dispose();
    wpKodePos.dispose();
    kodeZnt.dispose();
    luasTanah.dispose();
    noSertifikat.dispose();
    jumlahBangunan.dispose();
  }
}

class SpopFormScaffold extends ConsumerStatefulWidget {
  final String title;
  final String jenisTransaksiLabel;
  final String jenisSlug;
  final String submitEndpoint;
  final bool showInfoTambahan;
  final bool showKodeZnt;
  final Widget? topSection;
  final Map<String, dynamic>? initialData;
  final Map<String, String> existingBerkas;
  final String? Function()? extraValidation;
  final Map<String, dynamic> Function()? extraFields;

  const SpopFormScaffold({
    super.key,
    required this.title,
    required this.jenisTransaksiLabel,
    required this.jenisSlug,
    required this.submitEndpoint,
    this.showInfoTambahan = false,
    this.showKodeZnt = false,
    this.topSection,
    this.initialData,
    this.existingBerkas = const {},
    this.extraValidation,
    this.extraFields,
  });

  @override
  ConsumerState<SpopFormScaffold> createState() => _SpopFormScaffoldState();
}

class _SpopFormScaffoldState extends ConsumerState<SpopFormScaffold> {
  final _formKey = GlobalKey<FormState>();
  final _c = SpopFormControllers();

  List<WilayahItem> _kecamatanList = PengajuanReferensi.kecamatanSolo;
  List<WilayahItem> _kelurahanList = [];

  String? _selectedKecamatanId;
  String? _selectedKelurahanId;
  String _selectedStatusSubjek = 'pemilik';
  String _selectedPekerjaan = 'lainnya';
  String _selectedJenisTanah = 'tanah_bangunan';
  bool _pernyataanChecked = false;
  String? _geometryGeoJson;

  final Map<String, UploadedBerkas> _uploadedBerkas = {};
  Map<String, List<String>>? _serverErrors;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final repo = ref.read(pengajuanRepositoryProvider);
    final kec = await repo.getKecamatan();
    if (!mounted) return;
    setState(() => _kecamatanList = kec);

    if (widget.initialData != null) {
      final d = widget.initialData!;
      _c.populateFromMap(d);
      _selectedStatusSubjek =
          d['status_subjek']?.toString() ?? _selectedStatusSubjek;
      _selectedPekerjaan = d['pekerjaan']?.toString() ?? _selectedPekerjaan;
      _selectedJenisTanah =
          d['jenis_tanah']?.toString() ?? _selectedJenisTanah;
      _geometryGeoJson = d['geometry']?.toString();

      final kecId = d['op_kecamatan_id']?.toString();
      if (kecId != null && kecId.isNotEmpty) {
        _selectedKecamatanId = kecId;
        final kel = await repo.getKelurahan(kecId);
        if (mounted) {
          setState(() {
            _kelurahanList = kel;
            _selectedKelurahanId = d['op_kelurahan_id']?.toString();
          });
        }
      }
    }
  }

  Future<void> _onKecamatanChanged(String? val) async {
    setState(() {
      _selectedKecamatanId = val;
      _selectedKelurahanId = null;
      _kelurahanList = [];
    });
    if (val != null) {
      final kel = await ref.read(pengajuanRepositoryProvider).getKelurahan(val);
      if (mounted) {
        setState(() => _kelurahanList = kel);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    final res = await context.push<String>(
      '/pengajuan/sket-lokasi',
      extra: {'geometry': _geometryGeoJson},
    );
    if (res != null && mounted) {
      setState(() => _geometryGeoJson = res);
    }
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = null);

    if (widget.extraValidation != null) {
      final extraErr = widget.extraValidation!();
      if (extraErr != null) {
        _showError(extraErr);
        return;
      }
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showError('Periksa kembali isian formulir yang bertanda merah.');
      return;
    }

    if (_selectedKecamatanId == null || _selectedKelurahanId == null) {
      _showError('Pilih Kecamatan dan Kelurahan letak objek pajak.');
      return;
    }

    if (_geometryGeoJson == null || _geometryGeoJson!.isEmpty) {
      _showError('Sket / Denah Lokasi pada peta wajib diisi.');
      return;
    }

    if (!_pernyataanChecked) {
      _showError('Pernyataan Subjek Pajak wajib dicentang.');
      return;
    }

    final reqs = PengajuanReferensi.berkasForJenis(widget.jenisSlug);
    for (final req in reqs) {
      final hasNew = _uploadedBerkas.containsKey(req.key);
      final hasExisting = widget.existingBerkas.containsKey(req.key);
      if (req.wajib && !hasNew && !hasExisting) {
        _showError('Berkas wajib "${req.label}" belum diunggah.');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final fields = <String, dynamic>{
      if (widget.showInfoTambahan) ...{
        'nop_bersama': _c.nopBersama.text.trim(),
        'no_sppt_lama': _c.noSpptLama.text.trim(),
      },
      'op_nama_jalan': _c.opNamaJalan.text.trim(),
      'op_blok_no': _c.opBlokNo.text.trim(),
      'op_kecamatan_id': _selectedKecamatanId,
      'op_kelurahan_id': _selectedKelurahanId,
      'op_rt': _c.opRt.text.trim(),
      'op_rw': _c.opRw.text.trim(),
      'nik': _c.nik.text.trim(),
      'status_subjek': _selectedStatusSubjek,
      'pekerjaan': _selectedPekerjaan,
      'nama_subjek': _c.namaSubjek.text.trim(),
      'no_telp': _c.noTelp.text.trim(),
      'npwp': _c.npwp.text.replaceAll(RegExp(r'[\.\-]'), '').trim(),
      'wp_nama_jalan': _c.wpNamaJalan.text.trim(),
      'wp_blok_no': _c.wpBlokNo.text.trim(),
      'wp_kelurahan': _c.wpKelurahan.text.trim(),
      'wp_rt': _c.wpRt.text.trim(),
      'wp_rw': _c.wpRw.text.trim(),
      'wp_kecamatan': _c.wpKecamatan.text.trim(),
      'wp_kabupaten_kota': _c.wpKabupatenKota.text.trim(),
      'wp_kode_pos': _c.wpKodePos.text.trim(),
      if (widget.showKodeZnt) 'kode_znt': _c.kodeZnt.text.trim(),
      'luas_tanah': _c.luasTanah.text.trim().replaceAll(',', '.'),
      'jenis_tanah': _selectedJenisTanah,
      'no_sertifikat': _c.noSertifikat.text.trim(),
      'jumlah_bangunan': int.tryParse(_c.jumlahBangunan.text.trim()) ?? 0,
      'pernyataan': true,
      'geometry': _geometryGeoJson,
      if (widget.extraFields != null) ...widget.extraFields!(),
    };

    final res = await ref.read(pengajuanRepositoryProvider).submitMultipart(
          endpoint: widget.submitEndpoint,
          fields: fields,
          berkas: _uploadedBerkas,
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
      setState(() => _serverErrors = res.errors);
      _showError(res.message ?? 'Pengajuan gagal dikirim.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFB91C1C),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqs = PengajuanReferensi.berkasForJenis(widget.jenisSlug);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Transaksi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.jenisTransaksiLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (widget.topSection != null) ...[
              const SizedBox(height: 16),
              widget.topSection!,
            ],

            if (widget.showInfoTambahan) ...[
              _sectionHeader('1. Informasi Tambahan (Opsional)'),
              TextFormField(
                controller: _c.nopBersama,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'NOP Bersama',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _c.noSpptLama,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'No. SPPT Lama',
                  counterText: '',
                ),
              ),
            ],

            _sectionHeader('Data Letak Objek Pajak (Kota Solo)'),
            TextFormField(
              controller: _c.opNamaJalan,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Nama Jalan (Objek) *',
                counterText: '',
                errorText: _serverErrors?['op_nama_jalan']?.first,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama jalan wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.opBlokNo,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Blok & No. Rumah (Opsional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedKecamatanId,
              decoration: InputDecoration(
                labelText: 'Kecamatan (Kota Solo) *',
                errorText: _serverErrors?['op_kecamatan_id']?.first,
              ),
              items: _kecamatanList
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nama)))
                  .toList(),
              onChanged: _onKecamatanChanged,
              validator: (v) => v == null ? 'Pilih kecamatan' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedKelurahanId,
              decoration: InputDecoration(
                labelText: 'Kelurahan *',
                errorText: _serverErrors?['op_kelurahan_id']?.first,
              ),
              items: _kelurahanList
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nama)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedKelurahanId = v),
              validator: (v) => v == null ? 'Pilih kelurahan' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _c.opRt,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: 'RT *',
                      counterText: '',
                      errorText: _serverErrors?['op_rt']?.first,
                    ),
                    validator: (v) => AppValidators.validateRtRw(v, 'RT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _c.opRw,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: 'RW *',
                      counterText: '',
                      errorText: _serverErrors?['op_rw']?.first,
                    ),
                    validator: (v) => AppValidators.validateRtRw(v, 'RW'),
                  ),
                ),
              ],
            ),

            _sectionHeader('Data Subjek Pajak'),
            TextFormField(
              controller: _c.nik,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: InputDecoration(
                labelText: 'Nomor KTP / NIK (16 digit) *',
                errorText: _serverErrors?['nik']?.first,
              ),
              validator: AppValidators.validateNik,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatusSubjek,
              decoration: const InputDecoration(labelText: 'Status Subjek *'),
              items: PengajuanReferensi.statusSubjek.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatusSubjek = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPekerjaan,
              decoration: const InputDecoration(labelText: 'Pekerjaan *'),
              items: PengajuanReferensi.pekerjaan.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPekerjaan = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.namaSubjek,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Nama Subjek Pajak *',
                counterText: '',
                errorText: _serverErrors?['nama_subjek']?.first,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama subjek wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.noTelp,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No. Telp / No. HP *',
                errorText: _serverErrors?['no_telp']?.first,
              ),
              validator: AppValidators.validatePhone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.npwp,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'NPWP (Opsional, 15 atau 16 digit)',
                errorText: _serverErrors?['npwp']?.first,
              ),
              validator: AppValidators.validateNpwp,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpNamaJalan,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Nama Jalan (Subjek) *',
                counterText: '',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpBlokNo,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Blok & No. Rumah Subjek (Opsional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpKelurahan,
              decoration: const InputDecoration(labelText: 'Kelurahan / Desa *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _c.wpRt,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: const InputDecoration(
                      labelText: 'RT Subjek *',
                      counterText: '',
                    ),
                    validator: (v) => AppValidators.validateRtRw(v, 'RT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _c.wpRw,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: const InputDecoration(
                      labelText: 'RW Subjek *',
                      counterText: '',
                    ),
                    validator: (v) => AppValidators.validateRtRw(v, 'RW'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpKecamatan,
              decoration: const InputDecoration(labelText: 'Kecamatan Subjek *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpKabupatenKota,
              decoration: const InputDecoration(labelText: 'Kabupaten / Kota *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.wpKodePos,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: const InputDecoration(
                labelText: 'Kode Pos (5 digit) *',
                counterText: '',
              ),
              validator: AppValidators.validatePostalCode,
            ),

            _sectionHeader('Data Tanah, Bangunan, dan Sket Lokasi'),
            if (widget.showKodeZnt) ...[
              TextFormField(
                controller: _c.kodeZnt,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Kode ZNT (Opsional)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _c.luasTanah,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Luas Tanah (m²) *',
                errorText: _serverErrors?['luas_tanah']?.first,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Luas tanah wajib diisi';
                final numVal = double.tryParse(v.trim().replaceAll(',', '.'));
                if (numVal == null || numVal <= 0) {
                  return 'Luas tanah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedJenisTanah,
              decoration: const InputDecoration(labelText: 'Jenis Tanah *'),
              items: PengajuanReferensi.jenisTanah.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedJenisTanah = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.noSertifikat,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Nomor Sertifikat (Opsional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c.jumlahBangunan,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Bangunan *',
              ),
              validator: (v) {
                final parsed = int.tryParse(v?.trim() ?? '');
                if (parsed == null || parsed < 0) {
                  return 'Isi bilangan bulat 0 atau lebih';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: Icon(
                  _geometryGeoJson != null
                      ? Icons.check_circle
                      : Icons.map_outlined,
                  color: _geometryGeoJson != null
                      ? const Color(0xFF15803D)
                      : Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Sket / Denah Lokasi (Peta) *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  _geometryGeoJson != null
                      ? 'Koordinat lokasi sudah tersimpan'
                      : 'Ketuk untuk menandai titik atau bidang pada peta Solo',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openMap,
              ),
            ),

            _sectionHeader('Lampiran Berkas'),
            BerkasUploadSection(
              requirements: reqs,
              uploadedFiles: _uploadedBerkas,
              existingFiles: widget.existingBerkas,
              serverErrors: _serverErrors,
              onFilePicked: (key, file) {
                setState(() => _uploadedBerkas[key] = file);
              },
              onFileRemoved: (key) {
                setState(() => _uploadedBerkas.remove(key));
              },
            ),

            _sectionHeader('Pernyataan Subjek Pajak'),
            Card(
              child: CheckboxListTile(
                value: _pernyataanChecked,
                onChanged: (v) =>
                    setState(() => _pernyataanChecked = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  PengajuanReferensi.teksPernyataanSpop,
                  style: TextStyle(fontSize: 13, height: 1.45),
                ),
              ),
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
