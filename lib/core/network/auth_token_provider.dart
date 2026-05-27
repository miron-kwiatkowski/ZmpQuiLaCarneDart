import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interfejs dla dostawcy tokenów autoryzacyjnych
abstract class AuthTokenProvider {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
  Future<bool> isLoggedIn();
}

/// Implementacja AuthTokenProvider używająca Secure Storage
class AuthTokenProviderImpl implements AuthTokenProvider {
  final FlutterSecureStorage _secureStorage;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthTokenProviderImpl(this._secureStorage);

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}
