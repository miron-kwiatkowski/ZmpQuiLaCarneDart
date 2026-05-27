import '../../domain/entities/dish_entity.dart';
import '../models/dto/dish_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla dań
class DishMapper {
  static DishEntity toEntity(DishDto dto) {
    return DishEntity(
      token: dto.token,
      name: dto.name,
      description: dto.description ?? '',
      priceInCents: (dto.price * 100).toInt(),
      categoryToken: dto.categoryToken,
      ingredientTokens: dto.ingredientTokens,
      allergenTokens: dto.allergenTokens,
      isAvailable: dto.isAvailable,
      unavailabilityReason: dto.unavailableReason,
    );
  }

  static List<DishEntity> toEntityList(List<DishDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static DishDto toDto(DishEntity entity) {
    return DishDto(
      token: entity.token,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      categoryToken: entity.categoryToken,
      ingredientTokens: entity.ingredientTokens,
      allergenTokens: entity.allergenTokens,
      isAvailable: entity.isAvailable,
      unavailableReason: entity.unavailabilityReason,
    );
  }
}
