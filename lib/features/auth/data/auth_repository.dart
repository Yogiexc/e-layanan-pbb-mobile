import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import '../data/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(dio, tokenStorage);
});

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository(this._dio, this._tokenStorage);

  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockUser = UserModel(
        id: 7,
        name: 'Budi Santoso',
        username: username.isNotEmpty ? username : 'budi01',
        nik: '3372010101900001',
        npwp: '12.345.678.9-526.000',
      );
      const mockToken = 'mock_token_demo_pbb_solo';
      await _tokenStorage.saveToken(mockToken);
      return ApiResponse<LoginResponse>(
        success: true,
        message: 'Login berhasil (Mode Mockup)',
        data: LoginResponse(token: mockToken, user: mockUser),
      );
    }

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await _tokenStorage.saveToken(apiResponse.data!.token);
      }

      return apiResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return ApiResponse<LoginResponse>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Koneksi gagal atau server tidak dapat dijangkau.',
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Terjadi kesalahan tidak terduga.',
      );
    }
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResponse<UserModel>(
        success: true,
        message: 'OK',
        data: UserModel(
          id: 7,
          name: 'Budi Santoso',
          username: 'budi01',
          nik: '3372010101900001',
          npwp: '12.345.678.9-526.000',
        ),
      );
    }

    try {
      final response = await _dio.get('/me');
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return ApiResponse<UserModel>.fromJson(
          e.response!.data as Map<String, dynamic>,
          null,
        );
      }
      return ApiResponse<UserModel>(
        success: false,
        message: 'Gagal mengambil profil.',
      );
    }
  }

  Future<void> logout() async {
    if (AppConfig.useMockData) {
      await _tokenStorage.clearToken();
      return;
    }

    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Abaikan error saat memanggil API logout di backend
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
