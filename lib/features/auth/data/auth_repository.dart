import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storageService;

  AuthRepository({required this.apiClient, required this.storageService});

  /// [fields] should contain `name`, `password`, `date_of_birth`, `gender`,
  /// `district`, and at least one of `email` / `phone_number`, matching the
  /// multipart `/auth/register/` contract. Returns tokens + the new user
  /// immediately (registering logs the user in, no separate OTP step).
  Future<UserModel> register(Map<String, dynamic> fields) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.register,
      data: FormData.fromMap(fields),
    );

    final access = response.data['access'];
    final refresh = response.data['refresh'];
    await storageService.saveTokens(access: access, refresh: refresh);

    return UserModel.fromJson(response.data['user']);
  }

  /// [username] accepts either an email or a phone number.
  Future<UserModel> login(
      {required String username, required String password}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );

    final access = response.data['access'];
    final refresh = response.data['refresh'];
    await storageService.saveTokens(access: access, refresh: refresh);

    return UserModel.fromJson(response.data['user']);
  }

  Future<String> requestOtp(
      {required String identifier, required String method}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.requestOtp,
      data: {'identifier': identifier, 'method': method},
    );
    return response.data['message'] ?? 'OTP sent successfully.';
  }

  Future<UserModel> verifyOtp(
      {required String identifier, required String code}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {'identifier': identifier, 'code': code},
    );

    final access = response.data['access'];
    final refresh = response.data['refresh'];
    await storageService.saveTokens(access: access, refresh: refresh);

    return UserModel.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    final refresh = await storageService.getRefreshToken();
    if (refresh != null) {
      try {
        await apiClient.dio.post(
          ApiEndpoints.logout,
          data: {'refresh': refresh},
        );
      } catch (_) {}
    }
    await storageService.clearTokens();
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await storageService.getAccessToken();
    if (token == null) return null;

    try {
      final response = await apiClient.dio.get(ApiEndpoints.userMe);
      return UserModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.dio.patch(
      ApiEndpoints.userMe,
      data: data,
    );
    return UserModel.fromJson(response.data);
  }
}
