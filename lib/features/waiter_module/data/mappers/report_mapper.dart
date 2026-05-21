import '../../domain/entities/guest_report_entity.dart';
import '../dto/report_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla zgłoszeń
class ReportMapper {
  static GuestReportEntity toEntity(ReportDto dto) {
    return GuestReportEntity(
      token: dto.token,
      clientToken: dto.clientToken,
      reporterToken: dto.reporterToken,
      reason: dto.reason,
      statusToken: dto.statusToken,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<GuestReportEntity> toEntityList(List<ReportDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static ReportDto toDto(GuestReportEntity entity) {
    return ReportDto(
      token: entity.token,
      clientToken: entity.clientToken,
      reporterToken: entity.reporterToken,
      reason: entity.reason,
      statusToken: entity.statusToken,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
