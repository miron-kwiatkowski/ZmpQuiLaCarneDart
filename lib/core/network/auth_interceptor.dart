import 'dart:async';
import 'package:dio/dio.dart';
import 'auth_token_provider.dart';

/// Interceptor dla Dio obsługujący automatyczne odświeżanie tokenów
/// 
/// Wzorzec: Interceptor Pattern + Token Refresh Pattern
/// Dlaczego: Centralizacja logiki autoryzacji, automatyczne refresh tokenów
/// przy otrzymaniu 401, bez potrzeby powtarzania kodu w każdym repozytorium
class AuthInterceptor extends Interceptor {
  final AuthTokenProvider _tokenProvider;
  final Dio _dio;
  
  bool _isRefreshing = false;
  final List<Function(String)> _requestQueue = [];

  AuthInterceptor(this._dio, this._tokenProvider);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Dodaj token do każdego żądania
    final accessToken = await _tokenProvider.getAccessToken();
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    // Dodaj nagłówek języka
    options.headers['Accept-Language'] = 'pl';
    
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        final newAccessToken = await _refreshToken();
        
        if (newAccessToken != null) {
          // Ponów oryginalne żądanie z nowym tokenem
          final opts = Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $newAccessToken',
            },
          );
          
          final response = await _dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: opts,
          );
          
          return handler.resolve(response);
        }
      } catch (e) {
        // Nie udało się odświeżyć tokena - wyloguj użytkownika
        await _tokenProvider.clearTokens();
        return handler.next(err);
      }
    }
    
    handler.next(err);
  }

  /// Odświeża token dostępu używając refresh tokena
  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // Jeśli już trwa refresh, poczekaj i wykonaj żądanie później
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenProvider.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;

        // Zapisz nowe tokeny
        await _tokenProvider.saveTokens(
          accessToken: newAccessToken, 
          refreshToken: newRefreshToken ?? refreshToken,
        );

        // Wykonaj wszystkie oczekujące żądania
        for (final callback in _requestQueue) {
          callback(newAccessToken);
        }
        _requestQueue.clear();

        return newAccessToken;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      rethrow;
    } finally {
      _isRefreshing = false;
    }

    return null;
  }

  /// Czeka na zakończenie procesu refresh tokena
  Future<String?> _waitForRefresh() async {
    final completer = Completer<String?>();
    _requestQueue.add((token) => completer.complete(token));
    
    // Timeout aby uniknąć wiszących żądań
    return await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => null,
    );
  }
}

