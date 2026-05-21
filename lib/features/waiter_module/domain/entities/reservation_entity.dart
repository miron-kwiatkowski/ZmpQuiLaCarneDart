import 'package:equatable/equatable.dart';

/// Encja domenowa rezerwacji (Domain Layer)
class ReservationEntity extends Equatable {
  final String token;
  final String tableToken;
  final String userToken;
  final String statusToken;
  final String? waiterToken;
  final DateTime reservationDate;
  final DateTime startTime;
  final DateTime endTime;
  final int guestCount;
  final double totalPrice;
  final String? notes;
  final List<OrderItemEntity> orderItems;

  const ReservationEntity({
    required this.token,
    required this.tableToken,
    required this.userToken,
    required this.statusToken,
    this.waiterToken,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    required this.totalPrice,
    this.notes,
    required this.orderItems,
  });

  bool get isActive => statusToken == 'ACTIVE';
  bool get isCompleted => statusToken == 'COMPLETED';
  bool get isCancelled => statusToken == 'CANCELLED';
  bool get isNoShow => statusToken == 'NO_SHOW';

  @override
  List<Object?> get props => [
    token,
    tableToken,
    userToken,
    statusToken,
    waiterToken,
    reservationDate,
    startTime,
    endTime,
    guestCount,
    totalPrice,
    notes,
    orderItems,
  ];
}
