import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/dish_entity.dart';
import '../repositories/waiter_repository.dart';

/// Implementacja Use Case dla pobierania listy dań
/// Use Case Pattern - izolacja logiki biznesowej
class GetDishesUseCase {
  final WaiterRepository repository;

  GetDishesUseCase(this.repository);

  /// Pobiera listę dań z cache lokalnego lub API przez repository
  Future<Either<Failure, List<DishEntity>>> call({
    List<String>? excludedAllergens,
  }) async {
    return await repository.getDishes(excludedAllergens: excludedAllergens);
  }
}
