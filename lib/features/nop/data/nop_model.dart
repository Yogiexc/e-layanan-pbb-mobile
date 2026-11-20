class NopItemModel {
  final String? nop;
  final String alamat;
  final double luasTanah;
  final String status; // 'menunggu', 'ditolak', 'disetujui', 'terdaftar'
  final PengajuanTerakhirModel? pengajuanTerakhir;

  NopItemModel({
    this.nop,
    required this.alamat,
    required this.luasTanah,
    required this.status,
    this.pengajuanTerakhir,
  });

  factory NopItemModel.fromJson(Map<String, dynamic> json) {
    return NopItemModel(
      nop: json['nop'] as String?,
      alamat: json['alamat'] as String? ?? '-',
      luasTanah: (json['luas_tanah'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'menunggu',
      pengajuanTerakhir: json['pengajuan_terakhir'] != null
          ? PengajuanTerakhirModel.fromJson(
              json['pengajuan_terakhir'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PengajuanTerakhirModel {
  final int id;
  final String nomor;
  final String jenis;

  PengajuanTerakhirModel({
    required this.id,
    required this.nomor,
    required this.jenis,
  });

  factory PengajuanTerakhirModel.fromJson(Map<String, dynamic> json) {
    return PengajuanTerakhirModel(
      id: json['id'] as int,
      nomor: json['nomor'] as String? ?? '-',
      jenis: json['jenis'] as String? ?? '-',
    );
  }
}

class NopDetailModel {
  final String nop;
  final String opNamaJalan;
  final String opBlokNo;
  final String opKecamatanId;
  final String opKecamatanNama;
  final String opKelurahanId;
  final String opKelurahanNama;
  final String opRt;
  final String opRw;
  final double luasTanah;
  final double luasBangunan;
  final String jenisTanah;
  final String kodeZnt;
  final int jumlahBangunan;
  final String noSertifikat;
  final String nik;
  final String namaSubjek;
  final String alamatSubjek;
  final String npwp;
  final String pekerjaan;
  final String statusSubjek;

  NopDetailModel({
    required this.nop,
    required this.opNamaJalan,
    required this.opBlokNo,
    required this.opKecamatanId,
    required this.opKecamatanNama,
    required this.opKelurahanId,
    required this.opKelurahanNama,
    required this.opRt,
    required this.opRw,
    required this.luasTanah,
    required this.luasBangunan,
    required this.jenisTanah,
    required this.kodeZnt,
    required this.jumlahBangunan,
    required this.noSertifikat,
    required this.nik,
    required this.namaSubjek,
    required this.alamatSubjek,
    required this.npwp,
    required this.pekerjaan,
    required this.statusSubjek,
  });

  factory NopDetailModel.fromJson(Map<String, dynamic> json) {
    return NopDetailModel(
      nop: json['nop']?.toString() ?? '',
      opNamaJalan: json['op_nama_jalan']?.toString() ?? json['alamat']?.toString() ?? '-',
      opBlokNo: json['op_blok_no']?.toString() ?? '',
      opKecamatanId: json['op_kecamatan_id']?.toString() ?? '3372010',
      opKecamatanNama: json['op_kecamatan_nama']?.toString() ?? 'Laweyan',
      opKelurahanId: json['op_kelurahan_id']?.toString() ?? '3372010001',
      opKelurahanNama: json['op_kelurahan_nama']?.toString() ?? 'Pajang',
      opRt: json['op_rt']?.toString() ?? '001',
      opRw: json['op_rw']?.toString() ?? '001',
      luasTanah: (json['luas_tanah'] as num?)?.toDouble() ?? 0.0,
      luasBangunan: (json['luas_bangunan'] as num?)?.toDouble() ?? 0.0,
      jenisTanah: json['jenis_tanah']?.toString() ?? 'tanah_bangunan',
      kodeZnt: json['kode_znt']?.toString() ?? 'AA',
      jumlahBangunan: (json['jumlah_bangunan'] as num?)?.toInt() ?? 1,
      noSertifikat: json['no_sertifikat']?.toString() ?? '-',
      nik: json['nik']?.toString() ?? '3372010101900001',
      namaSubjek: json['nama_subjek']?.toString() ?? 'Budi Santoso',
      alamatSubjek: json['alamat_subjek']?.toString() ?? 'Jl. Slamet Riyadi No. 10',
      npwp: json['npwp']?.toString() ?? '-',
      pekerjaan: json['pekerjaan']?.toString() ?? 'lainnya',
      statusSubjek: json['status_subjek']?.toString() ?? 'pemilik',
    );
  }
}
