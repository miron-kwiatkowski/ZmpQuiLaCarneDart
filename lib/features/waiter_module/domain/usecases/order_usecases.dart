import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/waiter_repository.dart';

/// Use Case do dodawania pozycji do zamówienia (działa offline)
class AddItemsToReservationUseCase {
  final WaiterRepository repository;

  AddItemsToReservationUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String reservationToken,
    required List<OrderItemEntity> items,
  }) async {
    return await repository.addItemsToReservation(
      reservationToken: reservationToken,
      items: items,
    );
  }
}

/// Use Case do usuwania pozycji z zamówienia (działa offline)
class RemoveItemFromReservationUseCase {
  final WaiterRepository repository;

  RemoveItemFromReservationUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  }) async {
    return await repository.removeItemFromReservation(
      reservationToken: reservationToken,
      dishToken: dishToken,
      quantity: quantity,
      note: note,
    );
  }
}

/// Use Case do pobierania szczegółów rezerwacji
class GetReservationDetailsUseCase {
  final WaiterRepository repository;

  GetReservationDetailsUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required String reservationToken,
  }) async {
    return await repository.getReservationDetails(reservationToken: reservationToken);
  }
}
