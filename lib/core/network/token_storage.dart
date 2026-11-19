import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});
