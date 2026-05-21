// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DishDto _$DishDtoFromJson(Map<String, dynamic> json) => DishDto(
      token: json['token'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      categoryToken: json['categoryToken'] as String,
      ingredientTokens: (json['ingredientTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergenTokens: (json['allergenTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isAvailable: json['isAvailable'] as bool,
      unavailableReason: json['unavailableReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DishDtoToJson(DishDto instance) => <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'categoryToken': instance.categoryToken,
      'ingredientTokens': instance.ingredientTokens,
      'allergenTokens': instance.allergenTokens,
      'isAvailable': instance.isAvailable,
      'unavailableReason': instance.unavailableReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

IngredientDto _$IngredientDtoFromJson(Map<String, dynamic> json) =>
    IngredientDto(
      token: json['token'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      allergenTokens: (json['allergenTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$IngredientDtoToJson(IngredientDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'description': instance.description,
      'allergenTokens': instance.allergenTokens,
    };

AllergenDto _$AllergenDtoFromJson(Map<String, dynamic> json) => AllergenDto(
      token: json['token'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      colorCode: json['colorCode'] as String,
    );

Map<String, dynamic> _$AllergenDtoToJson(AllergenDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'shortName': instance.shortName,
      'colorCode': instance.colorCode,
    };

DishCategoryDto _$DishCategoryDtoFromJson(Map<String, dynamic> json) =>
    DishCategoryDto(
      token: json['token'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DishCategoryDtoToJson(DishCategoryDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
    };
