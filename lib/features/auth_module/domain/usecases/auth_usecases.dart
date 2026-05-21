import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Use Case do logowania użytkownika
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(
      username: username,
      password: password,
    );
  }
}

/// Use Case do odświeżania tokena
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String refreshToken,
  }) async {
    return await repository.refreshToken(refreshToken: refreshToken);
  }
}

/// Use Case do wylogowania
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.logout();
  }
}
