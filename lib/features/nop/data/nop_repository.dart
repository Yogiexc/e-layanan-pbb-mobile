import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../data/nop_model.dart';

final nopRepositoryProvider = Provider<NopRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NopRepository(dio);
});

class NopRepository {
  final Dio _dio;

  NopRepository(this._dio);

  static final List<NopItemModel> _mockItems = [
    NopItemModel(
      nop: '33.72.010.001.005-0123.0',
      alamat: 'Jl. Slamet Riyadi No. 10, Laweyan',
      luasTanah: 120.0,
      status: 'terdaftar',
      pengajuanTerakhir: null,
    ),
    NopItemModel(
      nop: null,
      alamat: 'Jl. Veteran No. 5, Serengan',
      luasTanah: 90.0,
      status: 'menunggu',
      pengajuanTerakhir: PengajuanTerakhirModel(
        id: 31,
        nomor: 'ELY-2026-00031',
        jenis: 'objek_baru',
      ),
    ),
    NopItemModel(
      nop: '33.72.030.002.012-0045.0',
      alamat: 'Jl. Kapten Mulyadi No. 22, Pasar Kliwon',
      luasTanah: 150.0,
      status: 'ditolak',
      pengajuanTerakhir: PengajuanTerakhirModel(
        id: 28,
        nomor: 'ELY-2026-00028',
        jenis: 'mutasi_penuh',
      ),
    ),
    NopItemModel(
      nop: '33.72.040.005.008-0099.0',
      alamat: 'Jl. Ir. Sutami No. 88, Jebres',
      luasTanah: 200.0,
      status: 'disetujui',
      pengajuanTerakhir: PengajuanTerakhirModel(
        id: 19,
        nomor: 'ELY-2026-00019',
        jenis: 'mutasi_sebagian',
      ),
    ),
  ];

  static final Map<int, Map<String, dynamic>> _mockDetails = {};
  static int _nextId = 150;

  void addMockSubmission({
    String? nop,
    required String alamat,
    required double luasTanah,
    required String jenis,
    required Map<String, dynamic> formData,
    required Map<String, String> berkasUrls,
  }) {
    _nextId++;
    final nomor = 'ELY-2026-${_nextId.toString().padLeft(5, '0')}';
    _mockItems.insert(
      0,
      NopItemModel(
        nop: nop,
        alamat: alamat,
        luasTanah: luasTanah,
        status: 'menunggu',
        pengajuanTerakhir: PengajuanTerakhirModel(
          id: _nextId,
          nomor: nomor,
          jenis: jenis,
        ),
      ),
    );

    _mockDetails[_nextId] = {
      'id': _nextId,
      'nomor': nomor,
      'jenis': jenis,
      'status': 'menunggu',
      'catatan_penolakan': null,
      'form': formData,
      'berkas': berkasUrls,
    };
  }

  void updateMockRevision({
    required int pengajuanId,
    required Map<String, dynamic> formData,
    required Map<String, String> berkasUrls,
  }) {
    final idx = _mockItems.indexWhere((e) => e.pengajuanTerakhir?.id == pengajuanId);
    if (idx != -1) {
      final old = _mockItems[idx];
      _mockItems[idx] = NopItemModel(
        nop: old.nop,
        alamat: formData['op_nama_jalan']?.toString() ?? old.alamat,
        luasTanah: double.tryParse(formData['luas_tanah']?.toString() ?? '') ?? old.luasTanah,
        status: 'menunggu',
        pengajuanTerakhir: old.pengajuanTerakhir,
      );
    }

    if (_mockDetails.containsKey(pengajuanId)) {
      _mockDetails[pengajuanId]!['status'] = 'menunggu';
      _mockDetails[pengajuanId]!['catatan_penolakan'] = null;
      _mockDetails[pengajuanId]!['form'] = formData;
      _mockDetails[pengajuanId]!['berkas'] = berkasUrls;
    }
  }

  Map<String, dynamic>? getMockPengajuanDetail(int id) {
    return _mockDetails[id];
  }

  Future<ApiResponse<List<NopItemModel>>> getNopList({int page = 1}) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<NopItemModel>>(
        success: true,
        message: 'OK',
        data: List.from(_mockItems),
      );
    }

    try {
      final response = await _dio.get(
        '/nop',
        queryParameters: {'page': page},
      );

      return ApiResponse<List<NopItemModel>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data
                .map((e) => NopItemModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<List<NopItemModel>>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<List<NopItemModel>>(
        success: false,
        message: 'Gagal memuat daftar NOP. Periksa koneksi internet Anda.',
      );
    } catch (_) {
      return ApiResponse<List<NopItemModel>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat daftar NOP.',
      );
    }
  }

  Future<ApiResponse<NopDetailModel>> getNopDetail(String nop) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<NopDetailModel>(
        success: true,
        message: 'OK',
        data: NopDetailModel(
          nop: nop,
          opNamaJalan: 'Jl. Slamet Riyadi No. 10',
          opBlokNo: 'Blok A / 10',
          opKecamatanId: '3372010',
          opKecamatanNama: 'Laweyan',
          opKelurahanId: '3372010001',
          opKelurahanNama: 'Pajang',
          opRt: '003',
          opRw: '002',
          luasTanah: 120.0,
          luasBangunan: 95.0,
          jenisTanah: 'tanah_bangunan',
          kodeZnt: 'AA',
          jumlahBangunan: 1,
          noSertifikat: 'SHM-88219/Solo',
          nik: '3372010101900001',
          namaSubjek: 'Budi Santoso',
          alamatSubjek: 'Jl. Slamet Riyadi No. 10, RT 003 / RW 002, Pajang, Laweyan, Solo',
          npwp: '12.345.678.9-526.000',
          pekerjaan: 'pns',
          statusSubjek: 'pemilik',
        ),
      );
    }

    try {
      final response = await _dio.get('/nop/$nop');
      return ApiResponse<NopDetailModel>.fromJson(
        response.data,
        (data) => NopDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiResponse<NopDetailModel>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<NopDetailModel>(
        success: false,
        message: 'Gagal memuat detail objek pajak.',
      );
    } catch (_) {
      return ApiResponse<NopDetailModel>(
        success: false,
        message: 'Terjadi kesalahan sistem saat memuat NOP.',
      );
    }
  }
}

final nopListProvider = FutureProvider.autoDispose<List<NopItemModel>>((ref) async {
  final repo = ref.watch(nopRepositoryProvider);
  final res = await repo.getNopList();
  if (res.success && res.data != null) {
    return res.data!;
  }
  throw Exception(res.message ?? 'Gagal memuat NOP');
});
