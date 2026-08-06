import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: apiClient, storageService: storage);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    state = AuthState(isLoading: true);
    try {
      final user = await repository.getCurrentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (_) {
      state = AuthState(isLoading: false);
    }
  }

  Future<String> requestOtp({required String identifier, required String method}) async {
    state = AuthState(user: state.user, isLoading: true);
    try {
      final msg = await repository.requestOtp(identifier: identifier, method: method);
      state = AuthState(user: state.user, isLoading: false);
      return msg;
    } catch (e) {
      state = AuthState(user: state.user, isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp({required String identifier, required String code}) async {
    state = AuthState(user: state.user, isLoading: true);
    try {
      final user = await repository.verifyOtp(identifier: identifier, code: code);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(user: null, isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = AuthState(user: null);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = AuthState(user: state.user, isLoading: true);
    try {
      final updatedUser = await repository.updateProfile(data);
      state = AuthState(user: updatedUser, isLoading: false);
    } catch (e) {
      state = AuthState(user: state.user, isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
