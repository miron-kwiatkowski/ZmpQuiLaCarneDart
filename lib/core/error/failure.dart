import 'package:equatable/equatable.dart';

/// Abstrakcyjna klasa dla błędów (Domain Layer)
/// 
/// Używana do reprezentacji błędów w stylu functional programming.
/// Wszystkie błędy dziedziczą po Failure.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure({required this.message, this.statusCode});
  
  @override
  List<Object?> get props => [message, statusCode];
}

/// Błąd serwera (HTTP 5xx, timeout, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Błąd połączenia (brak internetu)
class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message}) : super(statusCode: 0);
}

/// Błąd walidacji (HTTP 400)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode = 400});
}

/// Błąd autoryzacji (HTTP 401)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.statusCode = 401});
}

/// Błąd dostępu (HTTP 403)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message, super.statusCode = 403});
}

/// Błąd nie znaleziono (HTTP 404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.statusCode = 404});
}

/// Błąd lokalnej bazy danych
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message}) : super(statusCode: 0);
}

/// Błąd operacji offline (np. przekroczono limit retry)
class OfflineOperationFailure extends Failure {
  final String operationId;
  
  const OfflineOperationFailure({
    required super.message,
    required this.operationId,
  }) : super(statusCode: 0);
  
  @override
  List<Object?> get props => [message, statusCode, operationId];
}

/// Błąd cache (dane nie znalezione w cache)
class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(statusCode: 0);
}
