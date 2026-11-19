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
