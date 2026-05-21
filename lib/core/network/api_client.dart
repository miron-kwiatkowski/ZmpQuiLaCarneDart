import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'offline_queue_manager.dart';

/// Klient HTTP oparty na Dio z obsługą offline
/// 
/// Wzorzec: HTTP Client Wrapper Pattern
/// Dlaczego: Abstrakcja nad Dio, centralizacja konfiguracji,
/// łatwe testowanie przez dependency injection
class ApiClient {
  late final Dio _dio;
  final AuthInterceptor _authInterceptor;
  final OfflineQueueManager _queueManager;
  
  ApiClient({
    required AuthInterceptor authInterceptor,
    required OfflineQueueManager queueManager,
  })  : _authInterceptor = authInterceptor,
        _queueManager = queueManager {
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: ApiConfig.connectionTimeout),
      receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
      sendTimeout: const Duration(seconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'pl', // Default language - API requirement
      },
    ));

    // Dodaj interceptory
    _dio.interceptors.add(_authInterceptor);
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        // W produkcji można wyłączyć lub użyć loggera
        print(obj);
      },
    ));
  }

  /// Sprawdza dostępność połączenia internetowego
  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Stream zmian statusu połączenia
  Stream<bool> get onConnectivityChanged {
    return Connectivity()
        .onConnectivityChanged
        .map((result) => !result.contains(ConnectivityResult.none));
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Pobierz Dio instance (dla zaawansowanych przypadków)
  Dio get dio => _dio;

  /// Zamknij połączenia i wyczyść zasoby
  void dispose() {
    _dio.close();
  }
}
