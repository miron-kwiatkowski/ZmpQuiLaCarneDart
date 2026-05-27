import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilacarne_waiter/core/di/injection_container.dart';
import 'package:quilacarne_waiter/features/waiter_module/domain/entities/dish_entity.dart';
import 'package:quilacarne_waiter/features/waiter_module/domain/usecases/waiter_usecases.dart';

/// States dla DishesCubit
abstract class DishesState extends Equatable {
  const DishesState();

  @override
  List<Object?> get props => [];
}

class DishesInitial extends DishesState {
  const DishesInitial();
}

class DishesLoading extends DishesState {
  const DishesLoading();
}

class DishesLoaded extends DishesState {
  final List<DishEntity> dishes;
  final List<String>? excludedAllergens;

  const DishesLoaded({required this.dishes, this.excludedAllergens});

  @override
  List<Object?> get props => [dishes, excludedAllergens];
}

class DishesError extends DishesState {
  final String message;

  const DishesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Cubit do zarządzania stanem listy dań
/// Cubit Pattern - uproszczona wersja BLoC
class DishesCubit extends Cubit<DishesState> {
  final GetDishesUseCase getDishesUseCase;

  DishesCubit(this.getDishesUseCase) : super(const DishesInitial());

  /// Fabryka z dependency injection
  factory DishesCubit.create() {
    return DishesCubit(sl<GetDishesUseCase>());
  }

  /// Pobiera listę dań z API lub cache
  Future<void> loadDishes({List<String>? excludedAllergens}) async {
    emit(const DishesLoading());

    final result = await getDishesUseCase.call(
      excludedAllergens: excludedAllergens,
    );

    result.fold(
      (failure) => emit(DishesError(message: failure.toString())),
      (dishes) => emit(DishesLoaded(
        dishes: dishes,
        excludedAllergens: excludedAllergens,
      )),
    );
  }

  /// Filtruje dania po kategorii
  List<DishEntity> filterByCategory(List<DishEntity> dishes, String categoryToken) {
    return dishes.where((dish) => dish.categoryToken == categoryToken).toList();
  }

  /// Sprawdza czy danie zawiera alergeny
  bool containsAllergens(DishEntity dish, List<String> userAllergens) {
    return dish.allergenTokens.any((allergen) => userAllergens.contains(allergen));
  }
}
