import 'package:equatable/equatable.dart';

/// Encja domenowa pozycji zamówienia (Domain Layer)
/// 
/// Reprezentuje pojedynczą pozycję w zamówieniu (danie z ilością i notatką).
class OrderItemEntity extends Equatable {
  /// Unikalny token pozycji zamówienia
  final String? token; // Null dla nowych, jeszcze nie zsynchronizowanych pozycji
  
  /// Token dania
  final String dishToken;
  
  /// Nazwa dania (zdenormalizowana dla wygody wyświetlania)
  final String dishName;
  
  /// Ilość sztuk dania
  final int quantity;
  
  /// Notatka do pozycji (np. "bez cebuli", "sos osobno")
  final String? note;
  
  /// Cena jednostkowa w groszach (zdenormalizowana)
  final int unitPriceInCents;
  
  /// Token statusu pozycji (PENDING, IN_PROGRESS, COMPLETED, CANCELLED)
  final String statusToken;
  
  const OrderItemEntity({
    this.token,
    required this.dishToken,
    required this.dishName,
    required this.quantity,
    this.note,
    required this.unitPriceInCents,
    required this.statusToken,
  });
  
  /// Cena jednostkowa jako double (złotówki)
  double get unitPrice => unitPriceInCents / 100.0;
  
  /// Łączna cena za pozycję (quantity * unitPrice) w groszach
  int get totalPriceInCents => quantity * unitPriceInCents;
  
  /// Łączna cena jako double (złotówki)
  double get totalPrice => totalPriceInCents / 100.0;
  
  @override
  List<Object?> get props => [
        token,
        dishToken,
        dishName,
        quantity,
        note,
        unitPriceInCents,
        statusToken,
      ];
  
  /// Tworzy kopię z zmienioną ilością
  OrderItemEntity copyWith({int? quantity, String? note}) {
    return OrderItemEntity(
      token: token,
      dishToken: dishToken,
      dishName: dishName,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      unitPriceInCents: unitPriceInCents,
      statusToken: statusToken,
    );
  }
}

/// Encja domenowa zamówienia (Domain Layer)
/// 
/// Reprezentuje zamówienie złożone przez kelnera.
/// Może być powiązane z rezerwacją lub stolikiem.
class OrderEntity extends Equatable {
  /// Unikalny token zamówienia
  final String? token; // Null dla nowych, offline zamówień
  
  /// Token rezerwacji (jeśli dotyczy)
  final String? reservationToken;
  
  /// Token stolika
  final String tableToken;
  
  /// Lista pozycji zamówienia
  final List<OrderItemEntity> items;
  
  /// Token statusu zamówienia (PENDING, IN_PROGRESS, COMPLETED, CANCELLED)
  final String statusToken;
  
  /// Token kelnera obsługującego zamówienie
  final String? waiterToken;
  
  /// Data utworzenia zamówienia
  final DateTime createdAt;
  
  /// Data ostatniej modyfikacji
  final DateTime? updatedAt;
  
  /// Całkowita kwota zamówienia w groszach (może być zdenormalizowana)
  final int totalAmountInCents;
  
  /// Czy zamówienie zostało utworzone offline
  final bool isOfflineCreated;
  
  const OrderEntity({
    this.token,
    this.reservationToken,
    required this.tableToken,
    required this.items,
    required this.statusToken,
    this.waiterToken,
    required this.createdAt,
    this.updatedAt,
    required this.totalAmountInCents,
    this.isOfflineCreated = false,
  });
  
  /// Całkowita kwota jako double (złotówki)
  double get totalAmount => totalAmountInCents / 100.0;
  
  /// Liczba pozycji w zamówieniu
  int get itemCount => items.length;
  
  /// Oblicza sumę cen z pozycji (weryfikacja)
  int get calculatedTotalInCents {
    return items.fold(0, (sum, item) => sum + item.totalPriceInCents);
  }
  
  @override
  List<Object?> get props => [
        token,
        reservationToken,
        tableToken,
        items,
        statusToken,
        waiterToken,
        createdAt,
        updatedAt,
        totalAmountInCents,
        isOfflineCreated,
      ];
  
  /// Dodaje nową pozycję do zamówienia
  OrderEntity copyWithAddingItem(OrderItemEntity newItem) {
    final existingItems = List<OrderItemEntity>.from(items);
    
    // Sprawdź czy pozycja o tym samym daniu i notatce już istnieje
    final existingIndex = existingItems.indexWhere((item) =>
        item.dishToken == newItem.dishToken && item.note == newItem.note);
    
    if (existingIndex != -1) {
      // Zwiększ ilość istniejącej pozycji
      final existingItem = existingItems[existingIndex];
      existingItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      // Dodaj nową pozycję
      existingItems.add(newItem);
    }
    
    return copyWith(items: existingItems);
  }
  
  /// Usuwa pozycję z zamówienia
  OrderEntity copyWithRemovingItem(String itemToken) {
    return copyWith(
      items: items.where((item) => item.token != itemToken).toList(),
    );
  }
  
  /// Aktualizuje status zamówienia
  OrderEntity copyWithStatus(String newStatusToken) {
    return copyWith(statusToken: newStatusToken);
  }
  
  /// Tworzy kopię encji z zmienionymi polami
  OrderEntity copyWith({
    String? token,
    String? reservationToken,
    String? tableToken,
    List<OrderItemEntity>? items,
    String? statusToken,
    String? waiterToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalAmountInCents,
    bool? isOfflineCreated,
  }) {
    return OrderEntity(
      token: token ?? this.token,
      reservationToken: reservationToken ?? this.reservationToken,
      tableToken: tableToken ?? this.tableToken,
      items: items ?? this.items,
      statusToken: statusToken ?? this.statusToken,
      waiterToken: waiterToken ?? this.waiterToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalAmountInCents: totalAmountInCents ?? this.totalAmountInCents,
      isOfflineCreated: isOfflineCreated ?? this.isOfflineCreated,
    );
  }
}
