import 'package:json_annotation/json_annotation.dart';

part 'report_dto.g.dart';

/// DTO dla zgłoszenia gościa - warstwa Data
@JsonSerializable()
class ReportDto {
  final String token;
  final String clientToken;
  final String reporterToken;
  final String reason;
  final String statusToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReportDto({
    required this.token,
    required this.clientToken,
    required this.reporterToken,
    required this.reason,
    required this.statusToken,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) => 
      _$ReportDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReportDtoToJson(this);
}

/// DTO dla statusu zgłoszenia
@JsonSerializable()
class ReportStatusDto {
  final String token;
  final String name;
  final String colorCode;
  final int sortOrder;

  ReportStatusDto({
    required this.token,
    required this.name,
    required this.colorCode,
    required this.sortOrder,
  });

  factory ReportStatusDto.fromJson(Map<String, dynamic> json) => 
      _$ReportStatusDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReportStatusDtoToJson(this);
}
