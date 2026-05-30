import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/table_entity.dart';
import '../entities/dish_entity.dart';
import '../entities/reservation_entity.dart';
import '../repositories/waiter_repository.dart';

/// Use Case: Pobieranie listy stolików
/// 
/// Wzorzec: Use Case Pattern (Clean Architecture)
/// Dlaczego: Każda operacja biznesowa jest osobną klasą,
/// co ułatwia testowanie, ponowne użycie i utrzymanie kodu.
class GetTablesUseCase {
  final WaiterRepository repository;

  GetTablesUseCase(this.repository);

  /// Pobiera listę stolików
  /// 
  /// [filter] - opcjonalny filtr po statusie
  Future<Either<Failure, List<TableEntity>>> call({String? filter}) async {
    return await repository.getTables(filter: filter);
  }
}

/// Use Case: Zmiana statusu stolika
class ChangeTableStatusUseCase {
  final WaiterRepository repository;

  ChangeTableStatusUseCase(this.repository);

  /// Zmienia status stolika
  /// 
  /// [tableToken] - token stolika
  /// [newStatus] - nowy status (CLEANING, OUT_OF_SERVICE, AVAILABLE)
  Future<Either<Failure, bool>> call({
    required String tableToken,
    required String newStatus,
  }) async {
    return await repository.changeTableStatus(
      tableToken: tableToken,
      newStatus: newStatus,
    );
  }
}

/// Use Case: Dodawanie pozycji do rezerwacji/zamówienia
class AddItemsToReservationUseCase {
  final WaiterRepository repository;

  AddItemsToReservationUseCase(this.repository);

  /// Dodaje pozycje do rezerwacji/zamówienia
  /// 
  /// [reservationToken] - token rezerwacji
  /// [items] - lista pozycji do dodania
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

/// Use Case: Usuwanie pozycji z rezerwacji/zamówienia
class RemoveItemFromReservationUseCase {
  final WaiterRepository repository;

  RemoveItemFromReservationUseCase(this.repository);

  /// Usuwa pozycję z rezerwacji/zamówienia
  /// 
  /// [reservationToken] - token rezerwacji
  /// [dishToken] - token dania
  /// [quantity] - ilość do usunięcia
  /// [note] - notatka (musi pasować do istniejącej)
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

/// Use Case: Przypisanie kelnera do rezerwacji
class AssignWaiterUseCase {
  final WaiterRepository repository;

  AssignWaiterUseCase(this.repository);

  /// Przypisuje kelnera do rezerwacji
  Future<Either<Failure, bool>> call({required String reservationToken}) async {
    return await repository.assignWaiter(reservationToken: reservationToken);
  }
}

/// Use Case: Oznaczenie rezerwacji jako nieobecność (no-show)
class MarkAbsentUseCase {
  final WaiterRepository repository;

  MarkAbsentUseCase(this.repository);

  /// Oznacza rezerwację jako nieobecność (no-show)
  Future<Either<Failure, bool>> call({required String reservationToken}) async {
    return await repository.markReservationAbsent(reservationToken);
  }
}

/// Use Case: Tworzenie zgłoszenia gościa
class CreateGuestReportUseCase {
  final WaiterRepository repository;

  CreateGuestReportUseCase(this.repository);

  /// Tworzy zgłoszenie gościa
  /// 
  /// [clientToken] - token zgłaszanego klienta
  /// [reason] - powód zgłoszenia (10-500 znaków)
  Future<Either<Failure, bool>> call({
    required String clientToken,
    required String reason,
  }) async {
    return await repository.createGuestReport(
      clientToken: clientToken,
      reason: reason,
    );
  }
}

/// Use Case: Pobieranie listy dań
class GetDishesUseCase {
  final WaiterRepository repository;

  GetDishesUseCase(this.repository);

  /// Pobiera listę dań z opcjonalnym filtrem alergenów
  Future<Either<Failure, List<DishEntity>>> call({
    List<String>? excludedAllergens,
  }) async {
    return await repository.getDishes(excludedAllergens: excludedAllergens);
  }
}

/// Use Case: Pobieranie szczegółów rezerwacji
class GetReservationDetailsUseCase {
  final WaiterRepository repository;

  GetReservationDetailsUseCase(this.repository);

  /// Pobiera szczegóły rezerwacji
  Future<Either<Failure, ReservationEntity>> call({
    required String reservationToken,
  }) async {
    return await repository.getReservationDetails(reservationToken: reservationToken);
  }
}

/// Use Case: Synchronizacja wszystkich danych
class SyncAllDataUseCase {
  final WaiterRepository repository;

  SyncAllDataUseCase(this.repository);

  /// Synchronizuje wszystkie dane z serwerem
  Future<Either<Failure, bool>> call() async {
    return await repository.syncAllData();
  }
}
