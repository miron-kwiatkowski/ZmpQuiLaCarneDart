import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/reservation_entity.dart';
import '../repositories/waiter_repository.dart';

/// Use Case do dodawania pozycji do zamówienia (działa offline)
/// 
/// QlC10: Kelner może domówić produkty
/// QlC13: Kelner może edytować zamówienie
class AddItemsToReservationUseCase {
  final WaiterRepository repository;

  AddItemsToReservationUseCase(this.repository);

  /// Dodaje pozycje do zamówienia
  /// 
  /// [reservationToken] - token rezerwacji
  /// [items] - lista pozycji do dodania (DTO domenowe)
  Future<Either<Failure, bool>> call({
    required String reservationToken,
    required List<OrderItemToAdd> items,
  }) async {
    return await repository.addItemsToReservation(
      reservationToken: reservationToken,
      items: items,
    );
  }
}

/// Use Case do usuwania pozycji z zamówienia (działa offline)
/// 
/// QlC13: Kelner może edytować zamówienie (zmniejszyć ilość lub usunąć)
class RemoveItemFromReservationUseCase {
  final WaiterRepository repository;

  RemoveItemFromReservationUseCase(this.repository);

  /// Usuwa lub zmniejsza ilość pozycji w zamówieniu
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
/// 
/// Zwraca pełną encję rezerwacji wraz z jej aktualnym zamówieniem.
class GetReservationDetailsUseCase {
  final WaiterRepository repository;

  GetReservationDetailsUseCase(this.repository);

  /// Pobiera szczegóły rezerwacji po jej tokenie
  Future<Either<Failure, ReservationEntity>> call({
    required String reservationToken,
  }) async {
    return await repository.getReservationDetails(reservationToken: reservationToken);
  }
}
