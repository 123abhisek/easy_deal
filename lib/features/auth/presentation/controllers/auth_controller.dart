import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/core/network/api_client.dart';
import 'package:easy_deal/core/storage/secure_storage.dart';
import 'package:easy_deal/features/auth/data/auth_repository.dart';
import 'package:easy_deal/features/auth/data/models/user_model.dart';

// Storage Provider
final Provider<StorageService> storageServiceProvider = Provider<StorageService>((Ref ref) {
  return StorageService();
});

// ApiClient Provider
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(
    storage: storage,
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).handleUnauthorized();
    },
  );
});

// AuthRepository Provider
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(client: client, storage: storage);
});

// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  bool get isPremium => user?.isPremium ?? false;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isSeller => user?.isSeller ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
    );
  }
}

// Auth Controller
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final StorageService _storage;

  AuthController({
    required AuthRepository repository,
    required StorageService storage,
  })  : _repository = repository,
        _storage = storage,
        super(const AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      final response = await _repository.getMe();
      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          user: response.data,
          isLoading: false,
          isInitialized: true,
        );
        return;
      }
    }
    state = state.copyWith(
      clearUser: true,
      isLoading: false,
      isInitialized: true,
    );
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.login(
      identifier: identifier,
      password: password,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Login failed',
      );
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.register(data);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Registration failed',
      );
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.updateProfile(data);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Profile update failed',
      );
      return false;
    }
  }

  void setUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> refreshUser() async {
    final response = await _repository.getMe();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(user: response.data);
    }
  }

  void handleUnauthorized() {
    state = state.copyWith(clearUser: true);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState(isInitialized: true);
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthController(repository: repository, storage: storage);
});
