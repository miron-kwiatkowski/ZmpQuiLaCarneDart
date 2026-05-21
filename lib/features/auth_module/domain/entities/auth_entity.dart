/// Encja użytkownika zalogowanego
class UserEntity {
  final String token;
  final String username;
  final String email;
  final List<String> roles;
  final bool isActive;

  UserEntity({
    required this.token,
    required this.username,
    required this.email,
    required this.roles,
    required this.isActive,
  });
}

/// Encja odpowiedzi autoryzacyjnej
class AuthEntity {
  final String? accessToken;
  final String? refreshToken;
  final bool? requires2fa;
  final UserEntity? user;

  AuthEntity({
    this.accessToken,
    this.refreshToken,
    this.requires2fa,
    this.user,
  });
}
