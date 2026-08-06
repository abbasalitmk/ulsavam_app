import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storageService;

  ApiClient({required this.storageService}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt silent token refresh
            final refreshToken = await storageService.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshResponse = await Dio().post(
                  '${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
                  data: {'refresh': refreshToken},
                );

                if (refreshResponse.statusCode == 200) {
                  final newAccess = refreshResponse.data['access'];
                  final newRefresh = refreshResponse.data['refresh'] ?? refreshToken;
                  await storageService.saveTokens(access: newAccess, refresh: newRefresh);

                  // Retry original request
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final retriedResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(retriedResponse);
                }
              } catch (_) {
                await storageService.clearTokens();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
