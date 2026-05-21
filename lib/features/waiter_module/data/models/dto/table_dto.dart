import 'package:json_annotation/json_annotation.dart';

part 'table_dto.g.dart';

/// DTO dla stolika - warstwa Data
@JsonSerializable()
class TableDto {
  final String token;
  final String name;
  final int? tableNumber;
  final String statusToken;
  final int? capacity;
  final String? location;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableDto({
    required this.token,
    required this.name,
    this.tableNumber,
    required this.statusToken,
    this.capacity,
    this.location,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory TableDto.fromJson(Map<String, dynamic> json) => _$TableDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$TableDtoToJson(this);
}

/// DTO dla statusu stolika
@JsonSerializable()
class TableStatusDto {
  final String token;
  final String name;
  final String colorCode;
  final int sortOrder;

  TableStatusDto({
    required this.token,
    required this.name,
    required this.colorCode,
    required this.sortOrder,
  });

  factory TableStatusDto.fromJson(Map<String, dynamic> json) => 
      _$TableStatusDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$TableStatusDtoToJson(this);
}
