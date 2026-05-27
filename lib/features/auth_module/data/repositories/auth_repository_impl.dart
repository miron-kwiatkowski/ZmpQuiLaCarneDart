import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementacja repository autoryzacji
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        username: username,
        password: password,
      );

      // TODO: Map DTO to Entity when user info is available
      final authEntity = AuthEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        requires2fa: response.requires2fa,
      );

      return Right(authEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during login: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      final authEntity = AuthEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return Right(authEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during token refresh: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during logout: $e'));
    }
  }
}
