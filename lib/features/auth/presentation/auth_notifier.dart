import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, List<String>>? validationErrors;

  AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.validationErrors,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
    bool clearErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      validationErrors:
          clearErrors ? null : (validationErrors ?? this.validationErrors),
    );
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;
  late VoidCallback _unauthorizedListener;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    final tokenStorage = ref.watch(tokenStorageProvider);

    _unauthorizedListener = () {
      state = AuthState(status: AuthStatus.unauthenticated);
    };
    tokenStorage.unauthorizedSignal.addListener(_unauthorizedListener);
    ref.onDispose(() {
      tokenStorage.unauthorizedSignal.removeListener(_unauthorizedListener);
    });

    // Jalankan pengecekan auth awal secara asynchronous
    Future.microtask(() => checkAuth());
    return AuthState(status: AuthStatus.initial);
  }

  void updateUsernameLocal(String newUsername) {
    if (state.user != null) {
      final updated = UserModel(
        id: state.user!.id,
        name: state.user!.name,
        username: newUsername,
        nik: state.user!.nik,
        npwp: state.user!.npwp,
      );
      state = state.copyWith(user: updated);
    }
  }

  Future<void> checkAuth() async {
    final hasToken = await _repository.hasValidToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final profileRes = await _repository.getProfile();
    if (profileRes.success && profileRes.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: profileRes.data,
      );
    } else {
      await _repository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    final response = await _repository.login(
      username: username,
      password: password,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data!.user,
        isLoading: false,
        clearErrors: true,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: response.message ?? 'Login gagal.',
        validationErrors: response.errors,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
