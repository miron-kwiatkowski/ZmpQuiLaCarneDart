// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDto _$ReportDtoFromJson(Map<String, dynamic> json) => ReportDto(
      token: json['token'] as String,
      clientToken: json['clientToken'] as String,
      reporterToken: json['reporterToken'] as String,
      reason: json['reason'] as String,
      statusToken: json['statusToken'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReportDtoToJson(ReportDto instance) => <String, dynamic>{
      'token': instance.token,
      'clientToken': instance.clientToken,
      'reporterToken': instance.reporterToken,
      'reason': instance.reason,
      'statusToken': instance.statusToken,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ReportStatusDto _$ReportStatusDtoFromJson(Map<String, dynamic> json) =>
    ReportStatusDto(
      token: json['token'] as String,
      name: json['name'] as String,
      colorCode: json['colorCode'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$ReportStatusDtoToJson(ReportStatusDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'colorCode': instance.colorCode,
      'sortOrder': instance.sortOrder,
    };
