import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

/// Abstrakcyjny repository dla autoryzacji
abstract class AuthRepository {
  /// Logowanie użytkownika
  Future<Either<Failure, AuthEntity>> login({
    required String username,
    required String password,
  });

  /// Odświeżanie tokena dostępu
  Future<Either<Failure, AuthEntity>> refreshToken({
    required String refreshToken,
  });

  /// Wylogowanie użytkownika
  Future<Either<Failure, bool>> logout();
}
