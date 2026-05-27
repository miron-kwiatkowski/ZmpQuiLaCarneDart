import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quilacarne_waiter/features/auth_module/domain/entities/auth_entity.dart';
import 'package:quilacarne_waiter/features/auth_module/domain/usecases/auth_usecases.dart';

/// Stany dla AuthCubit
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class AuthInitial extends AuthState {}

/// Stan ładowania
class AuthLoading extends AuthState {}

/// Stan zalogowania
class AuthAuthenticated extends AuthState {
  final AuthEntity auth;

  const AuthAuthenticated(this.auth);

  @override
  List<Object?> get props => [auth];
}

/// Stan niezalogowania
class AuthUnauthenticated extends AuthState {}

/// Stan błędu
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cubit do zarządzania autoryzacją
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final LogoutUseCase logoutUseCase;

  String? _currentRefreshToken;

  AuthCubit({
    required this.loginUseCase,
    required this.refreshTokenUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial());

  /// Logowanie użytkownika
  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      username: username,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (auth) {
        _currentRefreshToken = auth.refreshToken;
        emit(AuthAuthenticated(auth));
      },
    );
  }

  /// Odświeżanie tokena
  Future<void> refreshAuthToken() async {
    if (_currentRefreshToken == null) {
      emit(const AuthError('No refresh token available'));
      return;
    }

    emit(AuthLoading());

    final result = await refreshTokenUseCase(
      refreshToken: _currentRefreshToken!,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (auth) {
        _currentRefreshToken = auth.refreshToken;
        emit(AuthAuthenticated(auth));
      },
    );
  }

  /// Wylogowanie
  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        _currentRefreshToken = null;
        emit(AuthUnauthenticated());
      },
    );
  }

  /// Ustawia token odświeżania (np. po wczytaniu z secure storage)
  void setRefreshToken(String token) {
    _currentRefreshToken = token;
  }
}
