// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableDto _$TableDtoFromJson(Map<String, dynamic> json) => TableDto(
      token: json['token'] as String,
      name: json['name'] as String,
      tableNumber: (json['tableNumber'] as num?)?.toInt(),
      statusToken: json['statusToken'] as String,
      capacity: (json['capacity'] as num?)?.toInt(),
      location: json['location'] as String?,
      isAvailable: json['isAvailable'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TableDtoToJson(TableDto instance) => <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'tableNumber': instance.tableNumber,
      'statusToken': instance.statusToken,
      'capacity': instance.capacity,
      'location': instance.location,
      'isAvailable': instance.isAvailable,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

TableStatusDto _$TableStatusDtoFromJson(Map<String, dynamic> json) =>
    TableStatusDto(
      token: json['token'] as String,
      name: json['name'] as String,
      colorCode: json['colorCode'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$TableStatusDtoToJson(TableStatusDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'colorCode': instance.colorCode,
      'sortOrder': instance.sortOrder,
    };
