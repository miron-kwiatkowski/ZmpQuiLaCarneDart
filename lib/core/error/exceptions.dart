/// Wyjątek serwera (HTTP 5xx, timeout, etc.)
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException([this.message = 'Server Error', this.statusCode]);

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Wyjątek cache (dane nie znalezione)
class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache Error']);
}

/// Wyjątek autoryzacji (HTTP 401)
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException([this.message = 'Authentication Error']);
}

/// Wyjątek braku połączenia
class ConnectionException implements Exception {
  final String message;

  ConnectionException([this.message = 'Connection Error']);
}
