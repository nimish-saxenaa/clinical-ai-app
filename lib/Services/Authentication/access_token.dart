import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccessTokenService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(
      key: "access_token",
      value: accessToken,
    );
  }
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(
      key: "refresh_token",
      value: refreshToken,
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: "access_token",
    );
  }

  static Future<String?> getRequestToken() async {
    return await _storage.read(
      key: "refresh_token",
    );
  }

  static Future<void> deleteToken() async {
    await _storage.delete(
      key: "access_token",
    );
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

}