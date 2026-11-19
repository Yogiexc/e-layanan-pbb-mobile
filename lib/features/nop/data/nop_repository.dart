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

  Future<ApiResponse<List<NopItemModel>>> getNopList({int page = 1}) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse<List<NopItemModel>>(
        success: true,
        message: 'OK',
        data: [
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
        ],
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
    } catch (e) {
      return ApiResponse<List<NopItemModel>>(
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
