import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

/// DTO dla odpowiedzi logowania - warstwa Data
@JsonSerializable()
class AuthResponseDto {
  final String? accessToken;
  final String? refreshToken;
  final bool? requires2fa;
  final String? message;
  final int statusCode;
  final List<String>? errorMessages;
  final bool success;

  AuthResponseDto({
    this.accessToken,
    this.refreshToken,
    this.requires2fa,
    this.message,
    required this.statusCode,
    this.errorMessages,
    required this.success,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);
}

/// DTO dla requestu logowania
@JsonSerializable()
class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({
    required this.username,
    required this.password,
  });

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

/// DTO dla requestu odświeżenia tokena
@JsonSerializable()
class RefreshTokenRequestDto {
  final String refreshToken;

  RefreshTokenRequestDto({
    required this.refreshToken,
  });

  factory RefreshTokenRequestDto.fromJson(Map<String, dynamic> json) => 
      _$RefreshTokenRequestDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$RefreshTokenRequestDtoToJson(this);
}
