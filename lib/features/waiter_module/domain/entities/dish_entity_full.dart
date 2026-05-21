import 'package:equatable/equatable.dart';

/// Encja domenowa dania (Domain Layer)
/// 
/// Reprezentuje danie w menu restauracji z informacjami
/// o składnikach, alergenach i dostępności.
class DishEntity extends Equatable {
  /// Unikalny token dania (identyfikator biznesowy)
  final String token;
  
  /// Nazwa dania (w języku użytkownika)
  final String name;
  
  /// Opis dania
  final String? description;
  
  /// Cena dania
  final double price;
  
  /// Token kategorii dania
  final String categoryToken;
  
  /// Lista tokenów alergenów
  final List<String> allergenTokens;
  
  /// Lista tokenów składników
  final List<String> ingredientTokens;
  
  /// Czy danie jest obecnie dostępne
  final bool isAvailable;
  
  /// Powód niedostępności (jeśli dotyczy)
  final String? unavailabilityReason;
  
  /// URL do zdjęcia dania
  final String? imageUrl;
  
  /// Czas przygotowania w minutach (opcjonalnie)
  final int? preparationTimeMinutes;
  
  const DishEntity({
    required this.token,
    required this.name,
    this.description,
    required this.price,
    required this.categoryToken,
    required this.allergenTokens,
    required this.ingredientTokens,
    required this.isAvailable,
    this.unavailabilityReason,
    this.imageUrl,
    this.preparationTimeMinutes,
  });
  
  /// Czy danie zawiera określony alergen
  bool hasAllergen(String allergenToken) {
    return allergenTokens.contains(allergenToken);
  }
  
  /// Czy danie zawiera którykolwiek z podanych alergenów
  bool hasAnyOfAllergens(List<String> allergenTokens) {
    return allergenTokens.any((token) => this.allergenTokens.contains(token));
  }
  
  /// Czy danie jest wegetariańskie (uproszczona logika - do rozszerzenia)
  bool get isVegetarian {
    // To powinno być rozszerzone o pełną logikę sprawdzania składników
    return !hasAnyOfAllergens(['MEAT', 'FISH', 'SEAFOOD']);
  }
  
  /// Czy danie jest wegańskie (uproszczona logika - do rozszerzenia)
  bool get isVegan {
    return isVegetarian && !hasAnyOfAllergens(['DAIRY', 'EGGS', 'HONEY']);
  }
  
  @override
  List<Object?> get props => [
    token,
    name,
    description,
    price,
    categoryToken,
    allergenTokens,
    ingredientTokens,
    isAvailable,
    unavailabilityReason,
    imageUrl,
    preparationTimeMinutes,
  ];
  
  /// Tworzy kopię encji ze zmienionymi wartościami
  DishEntity copyWith({
    String? token,
    String? name,
    String? description,
    double? price,
    String? categoryToken,
    List<String>? allergenTokens,
    List<String>? ingredientTokens,
    bool? isAvailable,
    String? unavailabilityReason,
    String? imageUrl,
    int? preparationTimeMinutes,
  }) {
    return DishEntity(
      token: token ?? this.token,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryToken: categoryToken ?? this.categoryToken,
      allergenTokens: allergenTokens ?? this.allergenTokens,
      ingredientTokens: ingredientTokens ?? this.ingredientTokens,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailabilityReason: unavailabilityReason ?? this.unavailabilityReason,
      imageUrl: imageUrl ?? this.imageUrl,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
    );
  }
}
