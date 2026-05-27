part of 'orders_cubit_export.dart';

/// Cubit do zarządzania stanem zamówień
///
/// Wzorzec: Cubit Pattern (flutter_bloc)
/// Dlaczego: Zarządzanie stanem zamówień z obsługą operacji offline
class OrdersCubit extends Cubit<OrdersState> {
  final AddItemsToReservationUseCase addItemsUseCase;
  final RemoveItemFromReservationUseCase removeItemUseCase;
  final GetReservationDetailsUseCase getDetailsUseCase;

  OrdersCubit({
    required this.addItemsUseCase,
    required this.removeItemUseCase,
    required this.getDetailsUseCase,
  }) : super(const OrdersInitial());

  /// Ładuje szczegóły rezerwacji/zamówienia
  Future<void> loadReservationDetails(String reservationToken) async {
    emit(const OrdersLoading());

    final result = await getDetailsUseCase(reservationToken: reservationToken);

    result.fold(
      (failure) => emit(OrdersError(failure)),
      (reservation) => emit(OrdersLoaded(reservation: reservation)),
    );
  }

  /// Dodaje pozycje do zamówienia (działa offline!)
  Future<void> addItems({
    required String reservationToken,
    required List<OrderItemToAdd> items,
  }) async {
    emit(const OrdersSubmitting());

    final result = await addItemsUseCase(
      reservationToken: reservationToken,
      items: items,
    );

    result.fold(
      (failure) => emit(OrdersError(failure)),
      (_) {
        emit(const OrderItemsAdded());
        // Odśwież dane po sukcesie
        loadReservationDetails(reservationToken);
      },
    );
  }

  /// Usuwa pozycję z zamówienia (działa offline!)
  Future<void> removeItem({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  }) async {
    emit(const OrdersSubmitting());

    final result = await removeItemUseCase(
      reservationToken: reservationToken,
      dishToken: dishToken,
      quantity: quantity,
      note: note,
    );

    result.fold(
      (failure) => emit(OrdersError(failure)),
      (_) {
        emit(const OrderItemRemoved());
        // Odśwież dane po sukcesie
        loadReservationDetails(reservationToken);
      },
    );
  }

  /// Resetuje stan cubita
  void reset() {
    emit(const OrdersInitial());
  }
}
