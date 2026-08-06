import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keySelectedDistrictSlug = 'selected_district_slug';
  static const _keySelectedDistrictName = 'selected_district_name';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<void> saveSelectedDistrict({required String slug, required String name}) async {
    await _storage.write(key: _keySelectedDistrictSlug, value: slug);
    await _storage.write(key: _keySelectedDistrictName, value: name);
  }

  Future<String?> getSelectedDistrictSlug() async {
    return await _storage.read(key: _keySelectedDistrictSlug);
  }

  Future<String?> getSelectedDistrictName() async {
    return await _storage.read(key: _keySelectedDistrictName);
  }
}
