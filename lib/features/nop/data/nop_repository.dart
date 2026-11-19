import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
