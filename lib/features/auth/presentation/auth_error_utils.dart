import 'package:dio/dio.dart';

/// Extracts a human-readable message from a DioException thrown by an auth
/// endpoint. The API returns errors in a few different shapes:
/// `{"error": "msg"}`, `{"error": ["msg"]}`, or field-keyed validation
/// errors like `{"email": ["This email is already registered."]}`.
String authErrorMessage(Object error, {required String fallback}) {
  if (error is! DioException) return fallback;

  final data = error.response?.data;
  if (data is Map) {
    final error0 = data['error'];
    if (error0 is String) return error0;
    if (error0 is List && error0.isNotEmpty) return error0.first.toString();

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String) return value;
    }
  }

  return fallback;
}

/// True when the server responded 404 to an OTP request/verify call,
/// meaning no account exists for that identifier.
bool isAccountNotFound(Object error) =>
    error is DioException && error.response?.statusCode == 404;

/// True when a request failed because it needed an auth token that wasn't
/// present or had expired.
bool isUnauthorized(Object error) =>
    error is DioException && error.response?.statusCode == 401;
