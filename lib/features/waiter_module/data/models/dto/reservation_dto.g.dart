// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationDto _$ReservationDtoFromJson(Map<String, dynamic> json) =>
    ReservationDto(
      token: json['token'] as String,
      userToken: json['userToken'] as String,
      tableToken: json['tableToken'] as String,
      statusToken: json['statusToken'] as String,
      reservationDate: DateTime.parse(json['reservationDate'] as String),
      guestCount: (json['guestCount'] as num).toInt(),
      notes: json['notes'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      waiterToken: json['waiterToken'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReservationDtoToJson(ReservationDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'userToken': instance.userToken,
      'tableToken': instance.tableToken,
      'statusToken': instance.statusToken,
      'reservationDate': instance.reservationDate.toIso8601String(),
      'guestCount': instance.guestCount,
      'notes': instance.notes,
      'totalPrice': instance.totalPrice,
      'waiterToken': instance.waiterToken,
      'items': instance.items,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ReservationStatusDto _$ReservationStatusDtoFromJson(
        Map<String, dynamic> json) =>
    ReservationStatusDto(
      token: json['token'] as String,
      name: json['name'] as String,
      colorCode: json['colorCode'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$ReservationStatusDtoToJson(
        ReservationStatusDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'colorCode': instance.colorCode,
      'sortOrder': instance.sortOrder,
    };

OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) => OrderItemDto(
      token: json['token'] as String,
      orderToken: json['orderToken'] as String,
      dishToken: json['dishToken'] as String,
      dishName: json['dishName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      note: json['note'] as String?,
      statusToken: json['statusToken'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderItemDtoToJson(OrderItemDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'orderToken': instance.orderToken,
      'dishToken': instance.dishToken,
      'dishName': instance.dishName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'note': instance.note,
      'statusToken': instance.statusToken,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => OrderDto(
      token: json['token'] as String,
      reservationToken: json['reservationToken'] as String,
      tableToken: json['tableToken'] as String,
      statusToken: json['statusToken'] as String,
      waiterToken: json['waiterToken'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderDtoToJson(OrderDto instance) => <String, dynamic>{
      'token': instance.token,
      'reservationToken': instance.reservationToken,
      'tableToken': instance.tableToken,
      'statusToken': instance.statusToken,
      'waiterToken': instance.waiterToken,
      'totalPrice': instance.totalPrice,
      'items': instance.items,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
