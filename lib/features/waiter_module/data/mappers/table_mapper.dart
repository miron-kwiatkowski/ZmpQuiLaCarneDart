import 'package:quilacarne_waiter/features/waiter_module/domain/entities/table_entity.dart';
import 'package:quilacarne_waiter/features/waiter_module/data/models/dto/table_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla stolików
class TableMapper {
  static TableEntity toEntity(TableDto dto) {
    return TableEntity(
      token: dto.token,
      statusToken: dto.statusToken,
      seats: dto.capacity,
      tableNumber: dto.tableNumber?.toString() ?? dto.name,
      locationDescription: dto.location,
    );
  }

  static List<TableEntity> toEntityList(List<TableDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static TableDto toDto(TableEntity entity) {
    return TableDto(
      token: entity.token,
      name: 'Table ${entity.tableNumber}',
      tableNumber: int.tryParse(entity.tableNumber),
      capacity: entity.seats ?? 0,
      location: entity.locationDescription ?? '',
      statusToken: entity.statusToken,
      isAvailable: entity.isAvailable,
    );
  }
}
