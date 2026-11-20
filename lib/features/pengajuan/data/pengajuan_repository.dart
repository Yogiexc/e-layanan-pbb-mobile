import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../nop/data/nop_repository.dart';
import 'pengajuan_models.dart';

final pengajuanRepositoryProvider = Provider<PengajuanRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final nopRepo = ref.watch(nopRepositoryProvider);
  return PengajuanRepository(dio, nopRepo);
});

class PengajuanRepository {
  final Dio _dio;
  final NopRepository _nopRepository;

  PengajuanRepository(this._dio, this._nopRepository);

  Future<List<WilayahItem>> getKecamatan() async {
    if (AppConfig.useMockData) {
      return PengajuanReferensi.kecamatanSolo;
    }
    try {
      final res = await _dio.get('/wilayah/kecamatan');
      final apiRes = ApiResponse<List<WilayahItem>>.fromJson(
        res.data,
        (data) => (data as List)
            .map((e) => WilayahItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiRes.data ?? PengajuanReferensi.kecamatanSolo;
    } catch (_) {
      return PengajuanReferensi.kecamatanSolo;
    }
  }

  Future<List<WilayahItem>> getKelurahan(String kecamatanId) async {
    if (AppConfig.useMockData) {
      return PengajuanReferensi.kelurahanByKecamatan[kecamatanId] ?? [];
    }
    try {
      final res = await _dio.get('/wilayah/kecamatan/$kecamatanId/kelurahan');
      final apiRes = ApiResponse<List<WilayahItem>>.fromJson(
        res.data,
        (data) => (data as List)
            .map((e) => WilayahItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiRes.data ??
          PengajuanReferensi.kelurahanByKecamatan[kecamatanId] ??
          [];
    } catch (_) {
      return PengajuanReferensi.kelurahanByKecamatan[kecamatanId] ?? [];
    }
  }

  Future<ApiResponse<NopCekResult>> cekNop(String nop) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 350));
      final clean = nop.trim();
      if (clean.length < 10) {
        return ApiResponse<NopCekResult>(
          success: false,
          message: 'NOP tidak ditemukan di basis data Oracle.',
        );
      }
      final parts = clean.split('.');
      final kec = parts.length > 2 ? parts[2] : '010';
      final kel = parts.length > 3 ? parts[3] : '001';
      final blok = parts.length > 4 ? parts[4].split('-').first : '005';
      return ApiResponse<NopCekResult>(
        success: true,
        message: 'NOP ditemukan',
        data: NopCekResult(
          exists: true,
          nop: clean,
          kecamatan: kec,
          kelurahan: kel,
          blok: blok,
        ),
      );
    }

    try {
      final res = await _dio.get('/nop/$nop/cek');
      return ApiResponse<NopCekResult>.fromJson(
        res.data,
        (data) => NopCekResult.fromJson(nop, data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<NopCekResult>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<NopCekResult>(
        success: false,
        message: 'Gagal memeriksa NOP ke server.',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> submitMultipart({
    required String endpoint,
    required Map<String, dynamic> fields,
    required Map<String, UploadedBerkas> berkas,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));

      final berkasMap = <String, String>{};
      berkas.forEach((k, v) => berkasMap[k] = v.fileName);

      if (endpoint.contains('/revisi')) {
        final uriParts = endpoint.split('/');
        final idIdx = uriParts.indexOf('pengajuan') + 1;
        final revId = int.tryParse(uriParts[idIdx]) ?? 28;
        _nopRepository.updateMockRevision(
          pengajuanId: revId,
          formData: fields,
          berkasUrls: berkasMap,
        );
      } else {
        String jenis = 'objek_baru';
        if (endpoint.contains('mutasi-penuh')) {
          jenis = 'mutasi_penuh';
        } else if (endpoint.contains('mutasi-penggabungan')) {
          jenis = 'mutasi_penggabungan';
        }
        _nopRepository.addMockSubmission(
          nop: fields['nop']?.toString(),
          alamat: fields['op_nama_jalan']?.toString() ?? 'Surakarta',
          luasTanah: double.tryParse(fields['luas_tanah']?.toString() ?? '') ?? 100.0,
          jenis: jenis,
          formData: fields,
          berkasUrls: berkasMap,
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Pengajuan berhasil dikirim (Mode Mockup).',
        data: {'id': 99, 'nomor': 'ELY-2026-00099'},
      );
    }

    try {
      final formMap = <String, dynamic>{...fields};
      for (final entry in berkas.entries) {
        formMap[entry.key] = await MultipartFile.fromFile(
          entry.value.path,
          filename: entry.value.fileName,
        );
      }
      final formData = FormData.fromMap(formMap);
      final res = await _dio.post(endpoint, data: formData);
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data,
        (data) => data is Map<String, dynamic> ? data : {},
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Gagal mengirim pengajuan. Periksa koneksi Anda.',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> submitMutasiSebagian({
    required String nop,
    required int jumlahBidang,
    required String keterangan,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      _nopRepository.addMockSubmission(
        nop: nop,
        alamat: 'Pemecahan $jumlahBidang bidang dari NOP $nop',
        luasTanah: 200.0,
        jenis: 'mutasi_sebagian',
        formData: {
          'nop': nop,
          'jumlah_bidang': jumlahBidang,
          'keterangan': keterangan,
        },
        berkasUrls: {},
      );
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Pengajuan Mutasi Sebagian berhasil dikirim (Mode Mockup).',
        data: {'id': 101, 'nomor': 'ELY-2026-00101'},
      );
    }

    try {
      final res = await _dio.post(
        '/pengajuan/mutasi-sebagian',
        data: {
          'nop': nop,
          'jumlah_bidang': jumlahBidang,
          'keterangan': keterangan,
        },
      );
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data,
        (data) => data is Map<String, dynamic> ? data : {},
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Gagal mengirim Mutasi Sebagian.',
      );
    }
  }

  Future<ApiResponse<PengajuanDetailModel>> getPengajuanDetail(int id) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 350));
      final dynamicDetail = _nopRepository.getMockPengajuanDetail(id);
      if (dynamicDetail != null) {
        return ApiResponse<PengajuanDetailModel>(
          success: true,
          message: 'OK',
          data: PengajuanDetailModel.fromJson(dynamicDetail),
        );
      }

      final isDitolak = id == 28;
      return ApiResponse<PengajuanDetailModel>(
        success: true,
        message: 'OK',
        data: PengajuanDetailModel(
          id: id,
          nomor: isDitolak ? 'ELY-2026-00028' : 'ELY-2026-00031',
          jenis: isDitolak ? 'mutasi_penuh' : 'objek_baru',
          status: isDitolak ? 'ditolak' : 'menunggu',
          catatanPenolakan: isDitolak
              ? 'Foto lampiran KTP buram dan luas tanah pada sertifikat belum sesuai. Mohon unggah ulang KTP yang terbaca jelas.'
              : null,
          formData: {
            'nop': isDitolak ? '33.72.030.002.012-0045.0' : null,
            'op_nama_jalan': isDitolak
                ? 'Jl. Kapten Mulyadi No. 22'
                : 'Jl. Veteran No. 5',
            'op_blok_no': isDitolak ? 'Blok B / 22' : 'No. 5',
            'op_kecamatan_id': isDitolak ? '3372030' : '3372020',
            'op_kelurahan_id': isDitolak ? '3372030003' : '3372020003',
            'op_rt': '002',
            'op_rw': '005',
            'nik': '3372010101900001',
            'status_subjek': 'pemilik',
            'pekerjaan': 'lainnya',
            'nama_subjek': 'Budi Santoso',
            'no_telp': '081234567890',
            'npwp': '123456789526000',
            'wp_nama_jalan': 'Jl. Slamet Riyadi No. 10',
            'wp_kelurahan': 'Laweyan',
            'wp_rt': '001',
            'wp_rw': '004',
            'wp_kecamatan': 'Laweyan',
            'wp_kabupaten_kota': 'Kota Surakarta',
            'wp_kode_pos': '57148',
            'luas_tanah': isDitolak ? '150' : '90',
            'jenis_tanah': 'tanah_bangunan',
            'no_sertifikat': 'SHM-019283',
            'jumlah_bangunan': '1',
            'geometry':
                '{"type":"Point","coordinates":[110.83167,-7.55611]}',
          },
          berkasUrls: const {
            'ktp': 'ktp_budi_santoso.jpg',
            'sertifikat': 'shm_tanah.pdf',
            'sppt_tetangga': 'sppt_tetangga.jpg',
          },
        ),
      );
    }

    try {
      final res = await _dio.get('/pengajuan/$id');
      return ApiResponse<PengajuanDetailModel>.fromJson(
        res.data,
        (data) => PengajuanDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<PengajuanDetailModel>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<PengajuanDetailModel>(
        success: false,
        message: 'Gagal memuat detail pengajuan.',
      );
    }
  }
}
