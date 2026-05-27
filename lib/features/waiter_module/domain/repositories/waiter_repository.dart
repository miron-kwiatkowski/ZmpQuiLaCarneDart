import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/table_entity.dart';
import '../entities/dish_entity.dart';
import '../entities/reservation_entity.dart';

import '../entities/guest_report_entity.dart';

/// Abstrakcyjne repozytorium dla operacji kelnera (Domain Layer)
/// 
/// Definiuje kontrakt dla wszystkich operacji związanych z obsługą kelnerską.
/// Implementacja znajduje się w warstwie Data i decyduje o źródłach danych.
abstract class WaiterRepository {
  /// Pobiera listę stolików
  Future<Either<Failure, List<TableEntity>>> getTables({String? filter});
  
  /// Zmienia status stolika
  Future<Either<Failure, bool>> changeTableStatus({
    required String tableToken,
    required String newStatus,
  });
  
  /// Dodaje pozycje do rezerwacji
  Future<Either<Failure, bool>> addItemsToReservation({
    required String reservationToken,
    required List<OrderItemToAdd> items,
  });
  
  /// Usuwa pozycję z rezerwacji
  Future<Either<Failure, bool>> removeItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  });
  
  /// Przypisuje kelnera do rezerwacji
  Future<Either<Failure, bool>> assignWaiter({required String reservationToken});
  
  /// Oznacza rezerwację jako nieobecność (no-show)
  Future<Either<Failure, bool>> markAbsent({required String reservationToken});
  
  /// Tworzy zgłoszenie gościa
  Future<Either<Failure, bool>> createGuestReport({
    required String clientToken,
    required String reason,
  });
  
  /// Pobiera listę dań
  Future<Either<Failure, List<DishEntity>>> getDishes({List<String>? excludedAllergens});
  
  /// Pobiera szczegóły rezerwacji
  Future<Either<Failure, ReservationEntity>> getReservationDetails({
    required String reservationToken,
  });

  /// Pobiera listę zgłoszeń gości
  Future<Either<Failure, List<GuestReportEntity>>> getGuestReports();

  /// Oznacza rezerwację jako nieobecność (no-show)
  Future<Either<Failure, bool>> markReservationAbsent(String reservationToken);
}

/// Pomocnicza klasa dla pozycji dodawanych do zamówienia
class OrderItemToAdd {
  final String dishToken;
  final int quantity;
  final String? note;

  OrderItemToAdd({
    required this.dishToken,
    required this.quantity,
    this.note,
  });
}
