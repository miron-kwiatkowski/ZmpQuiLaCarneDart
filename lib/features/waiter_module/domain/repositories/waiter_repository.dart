import 'package:equatable/equatable.dart';

/// Abstrakcyjne repozytorium dla operacji kelnera (Domain Layer)
/// 
/// Definiuje kontrakt dla wszystkich operacji związanych z obsługą kelnerską.
/// Implementacja znajduje się w warstwie Data i decyduje o źródłach danych.
abstract class WaiterRepository {
  /// Pobiera listę stolików z sali
  /// 
  /// Strategia: najpierw zwraca dane z cache lokalnego,
  /// następnie synchronizuje z API w tle.
  Future<List<TableEntity>> getTables();
  
  /// Pobiera szczegóły konkretnego stolika
  Future<TableEntity?> getTableByToken(String token);
  
  /// Aktualizuje status stolika na "wymaga sprzątania"
  /// 
  /// Operacja offline-first: jeśli brak internetu, zapisuje lokalnie
  /// i synchronizuje później.
  Future<void> markTableForCleaning(String tableToken);
  
  /// Aktualizuje status stolika na "niedostępny" (uszkodzony)
  Future<void> markTableOutOfService(String tableToken);
  
  /// Aktualizuje status stolika na "wolny"
  Future<void> markTableAvailable(String tableToken);
  
  /// Przypisuje kelnera do rezerwacji
  Future<void> assignWaiterToReservation(String reservationToken);
  
  /// Oznacza rezerwację jako niepokazaną (no-show)
  Future<void> markReservationAsAbsent(String reservationToken);
  
  /// Pobiera listę dań z menu
  /// 
  /// Obsługuje filtrowanie po alergenach.
  Future<List<DishEntity>> getDishes({List<String>? excludedAllergens});
  
  /// Pobiera szczegóły dania
  Future<DishEntity?> getDishByToken(String token);
  
  /// Tworzy nowe zamówienie lub aktualizuje istniejące
  /// 
  /// **OFFLINE-FIRST**: Jeśli brak połączenia, zamówienie jest zapisywane
  /// lokalnie i dodawane do kolejki synchronizacji.
  Future<void> createOrUpdateOrder(OrderEntity order);
  
  /// Dodaje pozycje do istniejącej rezerwacji
  /// 
  /// Odpowiednik API: POST /api/reservations/item/add
  /// 
  /// **OFFLINE-FIRST**: Operacja kolejkowana przy braku sieci.
  Future<void> addItemsToReservation({
    required String reservationToken,
    required List<OrderItemInput> items,
  });
  
  /// Usuwa pozycję z zamówienia/rezerwacji
  /// 
  /// **OFFLINE-FIRST**: Operacja kolejkowana przy braku sieci.
  Future<void> removeItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  });
  
  /// Pobiera szczegóły rezerwacji
  Future<ReservationEntity?> getReservationByToken(String token);
  
  /// Pobiera historię rezerwacji użytkownika
  Future<List<ReservationEntity>> getReservationsHistory({
    DateTime? fromDate,
    DateTime? toDate,
    String? statusToken,
    int page = 1,
    int size = 10,
  });
  
  /// Tworzy zgłoszenie gościa
  /// 
  /// **OFFLINE-FIRST**: Zgłoszenie zapisywane lokalnie i synchronizowane później.
  Future<void> submitGuestReport(GuestReportEntity report);
  
  /// Pobiera listę zgłoszeń
  Future<List<GuestReportEntity>> getGuestReports({int page = 1});
}

/// Obiekt wejściowy dla dodawania pozycji do zamówienia
class OrderItemInput extends Equatable {
  final String dishToken;
  final int quantity;
  final String? note;
  
  const OrderItemInput({
    required this.dishToken,
    required this.quantity,
    this.note,
  });
  
  @override
  List<Object?> get props => [dishToken, quantity, note];
}

/// Encja rezerwacji (uproszczona wersja)
class ReservationEntity extends Equatable {
  final String token;
  final String? userToken;
  final String tableToken;
  final String statusToken;
  final DateTime reservationTime;
  final String? notes;
  final List<OrderItemEntity> preOrderedItems;
  final int? totalPriceInCents;
  
  const ReservationEntity({
    required this.token,
    this.userToken,
    required this.tableToken,
    required this.statusToken,
    required this.reservationTime,
    this.notes,
    this.preOrderedItems = const [],
    this.totalPriceInCents,
  });
  
  @override
  List<Object?> get props => [
        token,
        userToken,
        tableToken,
        statusToken,
        reservationTime,
        notes,
        preOrderedItems,
        totalPriceInCents,
      ];
}
