import 'package:json_annotation/json_annotation.dart';

part 'reservation_dto.g.dart';

/// DTO dla rezerwacji - warstwa Data
@JsonSerializable()
class ReservationDto {
  final String token;
  final String userToken;
  final String tableToken;
  final String statusToken;
  final DateTime reservationDate;
  final int guestCount;
  final String? notes;
  final double? totalPrice;
  final String? waiterToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationDto({
    required this.token,
    required this.userToken,
    required this.tableToken,
    required this.statusToken,
    required this.reservationDate,
    required this.guestCount,
    this.notes,
    this.totalPrice,
    this.waiterToken,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationDto.fromJson(Map<String, dynamic> json) => 
      _$ReservationDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReservationDtoToJson(this);
}

/// DTO dla statusu rezerwacji
@JsonSerializable()
class ReservationStatusDto {
  final String token;
  final String name;
  final String colorCode;
  final int sortOrder;

  ReservationStatusDto({
    required this.token,
    required this.name,
    required this.colorCode,
    required this.sortOrder,
  });

  factory ReservationStatusDto.fromJson(Map<String, dynamic> json) => 
      _$ReservationStatusDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReservationStatusDtoToJson(this);
}

/// DTO dla pozycji zamówienia
@JsonSerializable()
class OrderItemDto {
  final String token;
  final String orderToken;
  final String dishToken;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? note;
  final String statusToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItemDto({
    required this.token,
    required this.orderToken,
    required this.dishToken,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.note,
    required this.statusToken,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) => 
      _$OrderItemDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);
}

/// DTO dla zamówienia
@JsonSerializable()
class OrderDto {
  final String token;
  final String reservationToken;
  final String tableToken;
  final String statusToken;
  final String? waiterToken;
  final double totalPrice;
  final List<OrderItemDto> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderDto({
    required this.token,
    required this.reservationToken,
    required this.tableToken,
    required this.statusToken,
    this.waiterToken,
    required this.totalPrice,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => 
      _$OrderDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}
