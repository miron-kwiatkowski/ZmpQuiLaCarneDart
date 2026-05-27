import 'package:quilacarne_waiter/features/waiter_module/domain/entities/order_entity.dart';
import 'package:quilacarne_waiter/features/waiter_module/data/models/dto/reservation_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla zamówień
class OrderMapper {
  static OrderItemEntity itemToEntity(OrderItemDto dto) {
    return OrderItemEntity(
      token: dto.token,
      dishToken: dto.dishToken,
      dishName: dto.dishName,
      quantity: dto.quantity,
      unitPriceInCents: (dto.unitPrice * 100).toInt(),
      note: dto.note,
      statusToken: dto.statusToken,
    );
  }

  static OrderEntity toEntity(OrderDto dto) {
    return OrderEntity(
      token: dto.token,
      reservationToken: dto.reservationToken,
      tableToken: dto.tableToken,
      statusToken: dto.statusToken,
      waiterToken: dto.waiterToken,
      totalAmountInCents: (dto.totalPrice * 100).toInt(),
      items: dto.items.map((item) => itemToEntity(item)).toList(),
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt,
      isOfflineCreated: false,
    );
  }

  static List<OrderEntity> toEntityList(List<OrderDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static OrderItemDto itemToDto(OrderItemEntity entity, String orderToken) {
    return OrderItemDto(
      token: entity.token ?? '',
      orderToken: orderToken,
      dishToken: entity.dishToken,
      dishName: entity.dishName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      note: entity.note,
      statusToken: entity.statusToken,
    );
  }

  static OrderDto toDto(OrderEntity entity) {
    final orderToken = entity.token ?? '';
    return OrderDto(
      token: orderToken,
      reservationToken: entity.reservationToken ?? '',
      tableToken: entity.tableToken,
      statusToken: entity.statusToken,
      waiterToken: entity.waiterToken,
      totalPrice: entity.totalAmount,
      items: entity.items.map((item) => itemToDto(item, orderToken)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
