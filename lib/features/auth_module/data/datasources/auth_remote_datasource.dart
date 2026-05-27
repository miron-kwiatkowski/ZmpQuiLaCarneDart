import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dto/auth_dto.dart';

/// Abstrakcyjne źródło danych zdalnych dla autoryzacji
abstract class AuthRemoteDataSource {
  /// Logowanie użytkownika
  /// POST /api/auth/login
  Future<AuthResponseDto> login({
    required String username,
    required String password,
  });

  /// Odświeżanie tokena dostępu
  /// POST /api/auth/refresh
  Future<AuthResponseDto> refreshToken({
    required String refreshToken,
  });

  /// Wylogowanie użytkownika
  /// POST /api/auth/logout
  Future<void> logout();
}

/// Implementacja zdalnego źródła danych dla autoryzacji
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<AuthResponseDto> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.data['success'] != true) {
        final errorMessages = (response.data['errorMessages'] as List?)?.join(', ') ?? 'Unknown error';
        throw ServerException('Login failed: $errorMessages');
      }

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['errorMessages'] != null) {
        final errorMessages = (e.response!.data['errorMessages'] as List).join(', ');
        throw ServerException('Login failed: $errorMessages');
      }
      throw ServerException('Network error: ${e.message}');
    }
  }

  @override
  Future<AuthResponseDto> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.data['success'] != true) {
        final errorMessages = (response.data['errorMessages'] as List?)?.join(', ') ?? 'Unknown error';
        throw ServerException('Token refresh failed: $errorMessages');
      }

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['errorMessages'] != null) {
        final errorMessages = (e.response!.data['errorMessages'] as List).join(', ');
        throw ServerException('Token refresh failed: $errorMessages');
      }
      throw ServerException('Network error: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout');

      if (response.data['success'] != true) {
        final errorMessages = (response.data['errorMessages'] as List?)?.join(', ') ?? 'Unknown error';
        throw ServerException('Logout failed: $errorMessages');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['errorMessages'] != null) {
        final errorMessages = (e.response!.data['errorMessages'] as List).join(', ');
        throw ServerException('Logout failed: $errorMessages');
      }
      throw ServerException('Network error: ${e.message}');
    }
  }
}
