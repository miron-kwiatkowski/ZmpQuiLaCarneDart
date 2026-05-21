import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/repositories/waiter_repository.dart';
import '../datasources/waiter_remote_datasource.dart';
import '../datasources/waiter_local_datasource.dart';
import '../mappers/dish_mapper.dart';

/// Implementacja Use Case dla pobierania listy dań
/// Use Case Pattern - izolacja logiki biznesowej
class GetDishesUseCase {
  final WaiterRepository repository;

  GetDishesUseCase(this.repository);

  /// Pobiera listę dań z cache lokalnego lub API
  /// Jeśli offline, zwraca dane z bazy lokalnej
  Future<Either<Failure, List<DishEntity>>> call({
    List<String>? excludedAllergens,
  }) async {
    try {
      // Najpierw próbuj pobrać z API (jeśli online)
      final remoteResult = await repository.getDishes(
        excludedAllergens: excludedAllergens,
      );

      return remoteResult.fold(
        (failure) async {
          // Jeśli błąd sieci, zwróć dane z cache
          if (failure is NetworkFailure) {
            return await repository.getCachedDishes();
          }
          return Left<Failure, List<DishEntity>>(failure);
        },
        (dishes) async {
          // Sukces - zapisz w cache i zwróć
          await repository.cacheDishes(dishes);
          return Right<Failure, List<DishEntity>>(dishes);
        },
      );
    } catch (e) {
      // Fallback do cache w przypadku każdego błędu
      return await repository.getCachedDishes();
    }
  }
}
