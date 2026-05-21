import '../../domain/entities/order_entity.dart';
import '../dto/reservation_dto.dart';

/// Data Mapper Pattern - konwersja DTO ↔ Entity dla zamówień
class OrderMapper {
  static OrderEntity toEntity(OrderDto dto) {
    final items = dto.items.map((itemDto) => OrderItemEntity(
      token: itemDto.token,
      orderToken: itemDto.orderToken,
      dishToken: itemDto.dishToken,
      dishName: itemDto.dishName,
      quantity: itemDto.quantity,
      unitPrice: itemDto.unitPrice,
      totalPrice: itemDto.totalPrice,
      note: itemDto.note,
      statusToken: itemDto.statusToken,
      createdAt: itemDto.createdAt,
      updatedAt: itemDto.updatedAt,
    )).toList();

    return OrderEntity(
      token: dto.token,
      reservationToken: dto.reservationToken,
      tableToken: dto.tableToken,
      statusToken: dto.statusToken,
      waiterToken: dto.waiterToken,
      totalPrice: dto.totalPrice,
      items: items,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<OrderEntity> toEntityList(List<OrderDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static OrderDto toDto(OrderEntity entity) {
    final items = entity.items.map((item) => OrderItemDto(
      token: item.token,
      orderToken: item.orderToken,
      dishToken: item.dishToken,
      dishName: item.dishName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
      note: item.note,
      statusToken: item.statusToken,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    )).toList();

    return OrderDto(
      token: entity.token,
      reservationToken: entity.reservationToken,
      tableToken: entity.tableToken,
      statusToken: entity.statusToken,
      waiterToken: entity.waiterToken,
      totalPrice: entity.totalPrice,
      items: items,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
