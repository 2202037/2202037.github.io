import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Service providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthService(api, storage);
});

// Auth state
class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isInitialized,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthNotifier(this._authService, this._storageService)
      : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await _storageService.getToken();
    final user = await _storageService.getUser();

    if (token != null && user != null) {
      state = state.copyWith(
        token: token,
        user: user,
        isAuthenticated: true,
        isInitialized: true,
      );
    } else {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authService.login(email, password);
      state = state.copyWith(
        user: result['user'] as UserModel,
        token: result['token'] as String,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'patient',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      state = state.copyWith(
        user: result['user'] as UserModel,
        token: result['token'] as String,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = const AuthState(isInitialized: true);
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authService, storageService);
});
