import 'package:json_annotation/json_annotation.dart';

part 'dish_dto.g.dart';

/// DTO dla dania - warstwa Data
/// Używane do serializacji/deserializacji JSON z API
@JsonSerializable()
class DishDto {
  final String token;
  final String name;
  final String? description;
  final double price;
  final String categoryToken;
  final List<String> ingredientTokens;
  final List<String> allergenTokens;
  final bool isAvailable;
  final String? unavailableReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DishDto({
    required this.token,
    required this.name,
    this.description,
    required this.price,
    required this.categoryToken,
    required this.ingredientTokens,
    required this.allergenTokens,
    required this.isAvailable,
    this.unavailableReason,
    this.createdAt,
    this.updatedAt,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) => _$DishDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DishDtoToJson(this);
}

/// DTO dla składnika
@JsonSerializable()
class IngredientDto {
  final String token;
  final String name;
  final String? description;
  final List<String> allergenTokens;

  IngredientDto({
    required this.token,
    required this.name,
    this.description,
    required this.allergenTokens,
  });

  factory IngredientDto.fromJson(Map<String, dynamic> json) => 
      _$IngredientDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$IngredientDtoToJson(this);
}

/// DTO dla alergenu
@JsonSerializable()
class AllergenDto {
  final String token;
  final String name;
  final String? shortName;
  final String colorCode;

  AllergenDto({
    required this.token,
    required this.name,
    this.shortName,
    required this.colorCode,
  });

  factory AllergenDto.fromJson(Map<String, dynamic> json) => 
      _$AllergenDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$AllergenDtoToJson(this);
}

/// DTO dla kategorii dań
@JsonSerializable()
class DishCategoryDto {
  final String token;
  final String name;
  final int? sortOrder;

  DishCategoryDto({
    required this.token,
    required this.name,
    this.sortOrder,
  });

  factory DishCategoryDto.fromJson(Map<String, dynamic> json) => 
      _$DishCategoryDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DishCategoryDtoToJson(this);
}
