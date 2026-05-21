import '../domain/models/websocket_event.dart';
import '../data/services/websocket_service.dart';

/// Handler for table updates
/// Topic: /topic/tables/updates
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncTableResponse or null (for DELETED)
class TableWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onTableUpdate;

  TableWSHandler(this.onTableUpdate);

  @override
  String get topic => '/topic/tables/updates';

  @override
  WSEntityType get entityType => WSEntityType.table;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    // Emit event to global stream for Cubits to consume
    onTableUpdate(event);
    print('📡 [TABLE] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for order updates
/// Topic: /topic/orders/updates
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncOrderResponse or null (for DELETED)
class OrderWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onOrderUpdate;

  OrderWSHandler(this.onOrderUpdate);

  @override
  String get topic => '/topic/orders/updates';

  @override
  WSEntityType get entityType => WSEntityType.order;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onOrderUpdate(event);
    print('📡 [ORDER] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for order item updates
/// Topic: /topic/orders/items
/// Events: CREATED, UPDATED
/// Payload: SyncOrderItemResponse
class OrderItemWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onOrderItemUpdate;

  OrderItemWSHandler(this.onOrderItemUpdate);

  @override
  String get topic => '/topic/orders/items';

  @override
  WSEntityType get entityType => WSEntityType.orderItem;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onOrderItemUpdate(event);
    print('📡 [ORDER ITEM] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for reservation updates
/// Topic: /topic/reservations/updates
/// Events: CREATED, UPDATED
/// Payload: SyncReservationResponse
class ReservationWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onReservationUpdate;

  ReservationWSHandler(this.onReservationUpdate);

  @override
  String get topic => '/topic/reservations/updates';

  @override
  WSEntityType get entityType => WSEntityType.reservation;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onReservationUpdate(event);
    print('📡 [RESERVATION] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for dish/menu updates
/// Topic: /topic/menu/dishes
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncDishResponse or null (for DELETED)
class DishWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onDishUpdate;

  DishWSHandler(this.onDishUpdate);

  @override
  String get topic => '/topic/menu/dishes';

  @override
  WSEntityType get entityType => WSEntityType.dish;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onDishUpdate(event);
    print('📡 [DISH] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for ingredient availability
/// Topic: /topic/menu/availability
/// Events: DELETED (when ingredient removed, affects dish availability)
/// Payload: null
class IngredientAvailabilityWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onIngredientAvailabilityChange;

  IngredientAvailabilityWSHandler(this.onIngredientAvailabilityChange);

  @override
  String get topic => '/topic/menu/availability';

  @override
  WSEntityType get entityType => WSEntityType.ingredient;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onIngredientAvailabilityChange(event);
    print('📡 [INGREDIENT AVAILABILITY] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for ingredient dictionary sync
/// Topic: /topic/dictionary/sync
/// Events: CREATED
/// Payload: SyncIngredientResponse
class IngredientSyncWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onIngredientSync;

  IngredientSyncWSHandler(this.onIngredientSync);

  @override
  String get topic => '/topic/dictionary/sync';

  @override
  WSEntityType get entityType => WSEntityType.ingredient;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onIngredientSync(event);
    print('📡 [INGREDIENT SYNC] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for report updates
/// Topic: /topic/reports/updates
/// Events: CREATED, UPDATED
/// Payload: SyncReportResponse
class ReportWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onReportUpdate;

  ReportWSHandler(this.onReportUpdate);

  @override
  String get topic => '/topic/reports/updates';

  @override
  WSEntityType get entityType => WSEntityType.report;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onReportUpdate(event);
    print('📡 [REPORT] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for employee/personnel updates
/// Topic: /topic/personnel/updates
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncUserResponse or null (for DELETED)
class EmployeeWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onEmployeeUpdate;

  EmployeeWSHandler(this.onEmployeeUpdate);

  @override
  String get topic => '/topic/personnel/updates';

  @override
  WSEntityType get entityType => WSEntityType.employee;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onEmployeeUpdate(event);
    print('📡 [EMPLOYEE] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for ban updates
/// Topic: /topic/security/bans
/// Events: CREATED, UPDATED
/// Payload: SyncBanResponse
class BanWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onBanUpdate;

  BanWSHandler(this.onBanUpdate);

  @override
  String get topic => '/topic/security/bans';

  @override
  WSEntityType get entityType => WSEntityType.ban;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onBanUpdate(event);
    print('📡 [BAN] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for allergen dictionary updates
/// Topic: /topic/dictionary/allergens
/// Events: CREATED, DELETED
/// Payload: SyncDictionaryResponse or null (for DELETED)
class AllergenWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onAllergenUpdate;

  AllergenWSHandler(this.onAllergenUpdate);

  @override
  String get topic => '/topic/dictionary/allergens';

  @override
  WSEntityType get entityType => WSEntityType.allergen;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onAllergenUpdate(event);
    print('📡 [ALLERGEN] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for table status dictionary updates
/// Topic: /topic/dictionary/table-statuses
/// Events: CREATED, DELETED
/// Payload: SyncDictionaryResponse or null (for DELETED)
class TableStatusWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onTableStatusUpdate;

  TableStatusWSHandler(this.onTableStatusUpdate);

  @override
  String get topic => '/topic/dictionary/table-statuses';

  @override
  WSEntityType get entityType => WSEntityType.tableStatus;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onTableStatusUpdate(event);
    print('📡 [TABLE STATUS] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for dish category dictionary updates
/// Topic: /topic/dictionary/dish-categories
/// Events: CREATED, DELETED
/// Payload: SyncDictionaryResponse or null (for DELETED)
class DishCategoryWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onDishCategoryUpdate;

  DishCategoryWSHandler(this.onDishCategoryUpdate);

  @override
  String get topic => '/topic/dictionary/dish-categories';

  @override
  WSEntityType get entityType => WSEntityType.dishCategory;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onDishCategoryUpdate(event);
    print('📡 [DISH CATEGORY] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for order status dictionary updates
/// Topic: /topic/dictionary/order-statuses
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncDictionaryResponse or null (for DELETED)
class OrderStatusWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onOrderStatusUpdate;

  OrderStatusWSHandler(this.onOrderStatusUpdate);

  @override
  String get topic => '/topic/dictionary/order-statuses';

  @override
  WSEntityType get entityType => WSEntityType.orderStatus;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onOrderStatusUpdate(event);
    print('📡 [ORDER STATUS] ${event.eventType} - Token: ${event.token}');
  }
}

/// Handler for order item status dictionary updates
/// Topic: /topic/dictionary/order-item-statuses
/// Events: CREATED, UPDATED, DELETED
/// Payload: SyncDictionaryResponse or null (for DELETED)
class OrderItemStatusWSHandler implements WSEventHandler<dynamic> {
  final Function(WebSocketEvent<dynamic>) onOrderItemStatusUpdate;

  OrderItemStatusWSHandler(this.onOrderItemStatusUpdate);

  @override
  String get topic => '/topic/dictionary/order-item-statuses';

  @override
  WSEntityType get entityType => WSEntityType.orderItemStatus;

  @override
  Future<void> handleEvent(WebSocketEvent<dynamic> event) async {
    onOrderItemStatusUpdate(event);
    print('📡 [ORDER ITEM STATUS] ${event.eventType} - Token: ${event.token}');
  }
}
