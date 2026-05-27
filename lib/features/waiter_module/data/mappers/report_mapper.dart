import 'package:quilacarne_waiter/features/waiter_module/domain/entities/guest_report_entity.dart';
import 'package:quilacarne_waiter/features/waiter_module/data/models/dto/report_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla zgłoszeń
class ReportMapper {
  static GuestReportEntity toEntity(ReportDto dto) {
    return GuestReportEntity(
      token: dto.token,
      clientToken: dto.clientToken,
      reason: dto.reason,
      statusToken: dto.statusToken,
      reporterToken: dto.reporterToken,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      isOfflineCreated: false,
    );
  }

  static List<GuestReportEntity> toEntityList(List<ReportDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static ReportDto toDto(GuestReportEntity entity) {
    return ReportDto(
      token: entity.token ?? '',
      clientToken: entity.clientToken,
      reporterToken: entity.reporterToken ?? '',
      reason: entity.reason,
      statusToken: entity.statusToken,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
