import '../../domain/entities/table_entity.dart';
import '../dto/table_dto.dart';

/// Mapper konwertujący DTO na Encję Domenową
/// Data Mapper Pattern - separacja warstwy danych od domeny
class TableMapper {
  /// Konwersja DTO → Entity
  static TableEntity toEntity(TableDto dto) {
    return TableEntity(
      token: dto.token,
      name: dto.name,
      tableNumber: dto.tableNumber,
      statusToken: dto.statusToken,
      capacity: dto.capacity,
      location: dto.location,
      isAvailable: dto.isAvailable,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Konwersja listy DTO → lista Entity
  static List<TableEntity> toEntityList(List<TableDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  /// Konwersja Entity → DTO (rzadko używane, głównie do testów)
  static TableDto toDto(TableEntity entity) {
    return TableDto(
      token: entity.token,
      name: entity.name,
      tableNumber: entity.tableNumber,
      statusToken: entity.statusToken,
      capacity: entity.capacity,
      location: entity.location,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
