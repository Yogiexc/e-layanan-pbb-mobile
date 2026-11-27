class WilayahItem {
  final String id;
  final String nama;

  const WilayahItem({required this.id, required this.nama});

  factory WilayahItem.fromJson(Map<String, dynamic> json) {
    return WilayahItem(
      id: json['id'].toString(),
      nama: json['nama'] as String? ?? '',
    );
  }
}

class BerkasRequirement {
  final String key;
  final String label;
  final bool wajib;

  const BerkasRequirement({
    required this.key,
    required this.label,
    required this.wajib,
  });
}

class PengajuanReferensi {
  static const Map<String, String> statusSubjek = {
    'pemilik': 'Pemilik',
    'penyewa': 'Penyewa',
    'pengelola': 'Pengelola',
    'pemangkai': 'Pemangkai',
    'sengketa': 'Sengketa',
  };

  static const Map<String, String> pekerjaan = {
    'pns': 'PNS',
    'abri': 'ABRI / TNI / Polri',
    'pensiunan': 'Pensiunan',
    'badan': 'Badan',
    'lainnya': 'Lainnya',
  };

  static const Map<String, String> jenisTanah = {
    'tanah_bangunan': 'Tanah + Bangunan',
    'kavling_siap_bangun': 'Kavling Siap Bangun',
    'tanah_kosong': 'Tanah Kosong',
    'fasilitas_umum': 'Fasilitas Umum',
    'lahan_pertanian': 'Lahan Pertanian',
  };

  static const List<WilayahItem> kecamatanSolo = [
    WilayahItem(id: '3372010', nama: 'Laweyan'),
    WilayahItem(id: '3372020', nama: 'Serengan'),
    WilayahItem(id: '3372030', nama: 'Pasar Kliwon'),
    WilayahItem(id: '3372040', nama: 'Jebres'),
    WilayahItem(id: '3372050', nama: 'Banjarsari'),
  ];

  static const Map<String, List<WilayahItem>> kelurahanByKecamatan = {
    '3372010': [
      WilayahItem(id: '3372010001', nama: 'Pajang'),
      WilayahItem(id: '3372010002', nama: 'Laweyan'),
      WilayahItem(id: '3372010003', nama: 'Bumi'),
      WilayahItem(id: '3372010004', nama: 'Panularan'),
      WilayahItem(id: '3372010005', nama: 'Sriwedari'),
      WilayahItem(id: '3372010006', nama: 'Purwosari'),
    ],
    '3372020': [
      WilayahItem(id: '3372020001', nama: 'Joyotakan'),
      WilayahItem(id: '3372020002', nama: 'Danukusuman'),
      WilayahItem(id: '3372020003', nama: 'Serengan'),
      WilayahItem(id: '3372020004', nama: 'Tipes'),
      WilayahItem(id: '3372020005', nama: 'Kratonan'),
    ],
    '3372030': [
      WilayahItem(id: '3372030001', nama: 'Joyosuran'),
      WilayahItem(id: '3372030002', nama: 'Semanggi'),
      WilayahItem(id: '3372030003', nama: 'Pasar Kliwon'),
      WilayahItem(id: '3372030004', nama: 'Gajahan'),
      WilayahItem(id: '3372030005', nama: 'Kauman'),
    ],
    '3372040': [
      WilayahItem(id: '3372040001', nama: 'Kepatihan Kulon'),
      WilayahItem(id: '3372040002', nama: 'Sudiroprajan'),
      WilayahItem(id: '3372040003', nama: 'Gandekan'),
      WilayahItem(id: '3372040004', nama: 'Jebres'),
      WilayahItem(id: '3372040005', nama: 'Mojosongo'),
    ],
    '3372050': [
      WilayahItem(id: '3372050001', nama: 'Kadipiro'),
      WilayahItem(id: '3372050002', nama: 'Nusukan'),
      WilayahItem(id: '3372050003', nama: 'Manahan'),
      WilayahItem(id: '3372050004', nama: 'Mangkubumen'),
      WilayahItem(id: '3372050005', nama: 'Setabelan'),
    ],
  };

  static const String teksPernyataanSpop =
      'Sesuai Pasal 9 ayat (2) UU No. 12 Tahun 1985 tentang Pajak Bumi dan Bangunan, '
      'saya menyatakan bahwa data yang saya isikan pada formulir ini adalah benar, '
      'jelas, dan lengkap. Apabila di kemudian hari ditemukan ketidakbenaran data, '
      'saya bersedia menerima sanksi sesuai ketentuan peraturan perundang-undangan.';

  static List<BerkasRequirement> berkasForJenis(String jenis) {
    switch (jenis) {
      case 'objek_baru':
        return const [
          BerkasRequirement(key: 'ktp', label: 'Lampiran KTP', wajib: true),
          BerkasRequirement(key: 'kk', label: 'Lampiran KK', wajib: false),
          BerkasRequirement(
            key: 'sertifikat',
            label: 'Sertifikat / Bukti Kepemilikan / Bukti Tanah Lainnya',
            wajib: true,
          ),
          BerkasRequirement(
            key: 'sppt_tetangga',
            label: 'SPPT PBB Tetangga',
            wajib: true,
          ),
          BerkasRequirement(
            key: 'surat_ket_desa',
            label: 'Surat Keterangan Desa / Kelurahan',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'surat_kuasa',
            label: 'Surat Kuasa dari Wajib Pajak (bila dikuasakan)',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'foto_lokasi',
            label: 'Foto Lokasi Objek',
            wajib: false,
          ),
          BerkasRequirement(key: 'imb_pbg', label: 'IMB / PBG', wajib: false),
        ];
      case 'mutasi_penuh':
        return const [
          BerkasRequirement(key: 'ktp', label: 'Lampiran KTP', wajib: true),
          BerkasRequirement(
            key: 'sertifikat',
            label: 'Sertifikat / Bukti Kepemilikan / Bukti Tanah Lainnya',
            wajib: true,
          ),
          BerkasRequirement(
            key: 'sppt_tetangga',
            label: 'SPPT PBB Tetangga',
            wajib: true,
          ),
          BerkasRequirement(
            key: 'surat_ket_pembayaran',
            label: 'Surat Keterangan Pembayaran PBB',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'surat_ket_desa',
            label: 'Surat Keterangan Desa / Kelurahan',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'surat_kuasa',
            label: 'Surat Kuasa dari Wajib Pajak (bila dikuasakan)',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'foto_lokasi',
            label: 'Foto Lokasi Objek',
            wajib: false,
          ),
          BerkasRequirement(key: 'imb_pbg', label: 'IMB / PBG', wajib: false),
        ];
      case 'mutasi_penggabungan':
        return const [
          BerkasRequirement(key: 'ktp', label: 'Lampiran KTP', wajib: true),
          BerkasRequirement(
            key: 'sertifikat',
            label: 'Sertifikat / Bukti Kepemilikan / Bukti Tanah Lainnya',
            wajib: true,
          ),
          BerkasRequirement(key: 'sppt_pbb', label: 'SPPT PBB', wajib: true),
          BerkasRequirement(
            key: 'surat_ket_pembayaran',
            label: 'Surat Keterangan Pembayaran PBB',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'surat_ket_desa',
            label: 'Surat Keterangan Desa / Kelurahan',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'surat_kuasa',
            label: 'Surat Kuasa dari Wajib Pajak (bila dikuasakan)',
            wajib: false,
          ),
          BerkasRequirement(
            key: 'foto_lokasi',
            label: 'Foto Lokasi Objek',
            wajib: false,
          ),
          BerkasRequirement(key: 'imb_pbg', label: 'IMB / PBG', wajib: false),
        ];
      default:
        return const [];
    }
  }
}

class UploadedBerkas {
  final String path;
  final String fileName;
  final bool isPdf;
  final int sizeBytes;

  const UploadedBerkas({
    required this.path,
    required this.fileName,
    required this.isPdf,
    required this.sizeBytes,
  });

  String get sizeLabel {
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(2)} MB';
  }
}

class NopCekResult {
  final bool exists;
  final String nop;
  final String kecamatan;
  final String kelurahan;
  final String blok;
  final String? message;

  const NopCekResult({
    required this.exists,
    required this.nop,
    required this.kecamatan,
    required this.kelurahan,
    required this.blok,
    this.message,
  });

  factory NopCekResult.fromJson(String nop, Map<String, dynamic> json) {
    return NopCekResult(
      exists: json['ada'] == true || json['exists'] == true,
      nop: nop,
      kecamatan: json['kecamatan']?.toString() ?? '',
      kelurahan: json['kelurahan']?.toString() ?? '',
      blok: json['blok']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }
}

class PengajuanDetailModel {
  final int id;
  final String nomor;
  final String jenis;
  final String status;
  final String? catatanPenolakan;
  final Map<String, dynamic> formData;
  final Map<String, String> berkasUrls;

  const PengajuanDetailModel({
    required this.id,
    required this.nomor,
    required this.jenis,
    required this.status,
    this.catatanPenolakan,
    required this.formData,
    required this.berkasUrls,
  });

  factory PengajuanDetailModel.fromJson(Map<String, dynamic> json) {
    final rawBerkas = json['berkas'];
    final parsedBerkas = <String, String>{};
    if (rawBerkas is List) {
      for (final item in rawBerkas) {
        if (item is Map) {
          final key = item['key']?.toString();
          final fileName = item['nama_file']?.toString() ?? item['nama_jenis']?.toString() ?? 'Tersimpan';
          if (key != null && key.isNotEmpty) {
            parsedBerkas[key] = fileName;
          }
        }
      }
    } else if (rawBerkas is Map) {
      rawBerkas.forEach((k, v) {
        if (v != null) parsedBerkas[k.toString()] = v.toString();
      });
    }

    return PengajuanDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomor: json['nomor']?.toString() ?? '-',
      jenis: json['jenis']?.toString() ?? 'objek_baru',
      status: json['status']?.toString() ?? 'menunggu',
      catatanPenolakan: json['catatan_penolakan']?.toString(),
      formData: (json['data_form'] as Map<String, dynamic>?) ??
          (json['form'] as Map<String, dynamic>?) ??
          {},
      berkasUrls: parsedBerkas,
    );
  }
}
