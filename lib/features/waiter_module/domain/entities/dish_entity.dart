import 'package:equatable/equatable.dart';

/// Encja domenowa dania (Domain Layer)
/// 
/// Reprezentuje pozycję w menu restauracji.
/// Zawiera informacje o składnikach i alergenach.
class DishEntity extends Equatable {
  /// Unikalny token dania (identyfikator biznesowy)
  final String token;
  
  /// Nazwa dania (w języku użytkownika)
  final String name;
  
  /// Opis dania
  final String description;
  
  /// Cena dania w groszach
  final int priceInCents;
  
  /// Token kategorii dania
  final String categoryToken;
  
  /// Lista tokenów składników
  final List<String> ingredientTokens;
  
  /// Lista tokenów alergenów
  final List<String> allergenTokens;
  
  /// Czy danie jest obecnie dostępne
  final bool isAvailable;
  
  /// Powód niedostępności (jeśli dotyczy)
  final String? unavailabilityReason;
  
  /// URL do zdjęcia dania (opcjonalnie)
  final String? imageUrl;
  
  const DishEntity({
    required this.token,
    required this.name,
    required this.description,
    required this.priceInCents,
    required this.categoryToken,
    required this.ingredientTokens,
    required this.allergenTokens,
    required this.isAvailable,
    this.unavailabilityReason,
    this.imageUrl,
  });
  
  /// Cena jako double (złotówki)
  double get price => priceInCents / 100.0;
  
  /// Czy danie zawiera alergeny
  bool get hasAllergens => allergenTokens.isNotEmpty;
  
  @override
  List<Object?> get props => [
        token,
        name,
        description,
        priceInCents,
        categoryToken,
        ingredientTokens,
        allergenTokens,
        isAvailable,
        unavailabilityReason,
        imageUrl,
      ];
  
  /// Tworzy kopię encji z zmienioną dostępnością
  DishEntity copyWith({bool? isAvailable, String? unavailabilityReason}) {
    return DishEntity(
      token: token,
      name: name,
      description: description,
      priceInCents: priceInCents,
      categoryToken: categoryToken,
      ingredientTokens: ingredientTokens,
      allergenTokens: allergenTokens,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailabilityReason: unavailabilityReason ?? this.unavailabilityReason,
      imageUrl: imageUrl,
    );
  }
}
