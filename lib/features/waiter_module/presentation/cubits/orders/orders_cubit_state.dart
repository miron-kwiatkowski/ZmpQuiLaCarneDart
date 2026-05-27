part of 'orders_cubit_export.dart';

/// Stany dla OrdersCubit
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Stan ładowania
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Stan z załadowanym zamówieniem
class OrdersLoaded extends OrdersState {
  final ReservationEntity reservation;

  const OrdersLoaded({required this.reservation});

  @override
  List<Object?> get props => [reservation];
}

/// Stan przesyłania danych (dodawanie/usuwanie pozycji)
class OrdersSubmitting extends OrdersState {
  const OrdersSubmitting();
}

/// Stan błędu
class OrdersError extends OrdersState {
  final Failure failure;

  const OrdersError(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Sukces dodania pozycji
class OrderItemsAdded extends OrdersState {
  const OrderItemsAdded();
}

/// Sukces usunięcia pozycji
class OrderItemRemoved extends OrdersState {
  const OrderItemRemoved();
}
