// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      requires2fa: json['requires2fa'] as bool?,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num).toInt(),
      errorMessages: (json['errorMessages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      success: json['success'] as bool,
    );

Map<String, dynamic> _$AuthResponseDtoToJson(AuthResponseDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'requires2fa': instance.requires2fa,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'errorMessages': instance.errorMessages,
      'success': instance.success,
    };

LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) =>
    LoginRequestDto(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

RefreshTokenRequestDto _$RefreshTokenRequestDtoFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenRequestDto(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestDtoToJson(
        RefreshTokenRequestDto instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };
