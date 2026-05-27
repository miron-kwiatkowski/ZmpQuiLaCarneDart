import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/guest_report_entity.dart';
import 'queued_operation_model.dart';

part 'isar_models.g.dart';

/// Modele Isar dla bazy danych lokalnej
/// 
/// WZORZEC: Data Mapper Pattern
/// - Mapuje encje domenowe na obiekty persistencji (Isar)
/// - Izoluje logikę mapowania od reszty aplikacji
/// - Umożliwia zmianę bazy danych bez wpływu na warstwę Domain

// ============================================================================
// TABLE MODEL
// ============================================================================

@collection
class IsarTable {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String statusToken;
  late int? seats;
  late String tableNumber;
  late String? locationDescription;

  DateTime? createdAt;
  DateTime? lastUpdatedAt;

  /// Konwersja na encję domenową
  TableEntity toEntity() {
    return TableEntity(
      token: token,
      statusToken: statusToken,
      seats: seats,
      tableNumber: tableNumber,
      locationDescription: locationDescription,
    );
  }

  /// Tworzenie z encji domenowej
  static IsarTable fromEntity(TableEntity entity) {
    return IsarTable()
      ..token = entity.token
      ..statusToken = entity.statusToken
      ..seats = entity.seats
      ..tableNumber = entity.tableNumber
      ..locationDescription = entity.locationDescription;
  }
}

// ============================================================================
// DISH MODEL
// ============================================================================

@collection
class IsarDish {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String name;
  late String description;
  late int priceInCents;
  late String categoryToken;

  late List<String> ingredientTokens;

  late List<String> allergenTokens;

  late bool isAvailable;
  late String? unavailabilityReason;
  late String? imageUrl;

  DateTime? createdAt;
  DateTime? lastUpdatedAt;

  /// Konwersja na encję domenową
  DishEntity toEntity() {
    return DishEntity(
      token: token,
      name: name,
      description: description,
      priceInCents: priceInCents,
      categoryToken: categoryToken,
      ingredientTokens: ingredientTokens,
      allergenTokens: allergenTokens,
      isAvailable: isAvailable,
      unavailabilityReason: unavailabilityReason,
      imageUrl: imageUrl,
    );
  }

  /// Tworzenie z encji domenowej
  static IsarDish fromEntity(DishEntity entity) {
    return IsarDish()
      ..token = entity.token
      ..name = entity.name
      ..description = entity.description
      ..priceInCents = entity.priceInCents
      ..categoryToken = entity.categoryToken
      ..ingredientTokens = entity.ingredientTokens
      ..allergenTokens = entity.allergenTokens
      ..isAvailable = entity.isAvailable
      ..unavailabilityReason = entity.unavailabilityReason
      ..imageUrl = entity.imageUrl;
  }
}

// ============================================================================
// ORDER ITEM MODEL (Embedded)
// ============================================================================

@embedded
class IsarOrderItem {
  late String? token;
  late String dishToken;
  late String dishName;
  late int quantity;
  late int unitPriceInCents;
  late String? note;
  late String statusToken;

  /// Konwersja na encję domenową
  OrderItemEntity toEntity() {
    return OrderItemEntity(
      token: token,
      dishToken: dishToken,
      dishName: dishName,
      quantity: quantity,
      note: note,
      unitPriceInCents: unitPriceInCents,
      statusToken: statusToken,
    );
  }

  /// Tworzenie z encji domenowej
  static IsarOrderItem fromEntity(OrderItemEntity entity) {
    return IsarOrderItem()
      ..token = entity.token
      ..dishToken = entity.dishToken
      ..dishName = entity.dishName
      ..quantity = entity.quantity
      ..unitPriceInCents = entity.unitPriceInCents
      ..note = entity.note
      ..statusToken = entity.statusToken;
  }
}

// ============================================================================
// ORDER MODEL
// ============================================================================

@collection
class IsarOrder {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String? token;

  late String? reservationToken;
  late String tableToken;
  late String? waiterToken;
  late String statusToken;
  late int totalAmountInCents;
  late bool isOfflineCreated;

  late List<IsarOrderItem> items;

  late DateTime createdAt;
  DateTime? updatedAt;

  /// Konwersja na encję domenową
  OrderEntity toEntity() {
    return OrderEntity(
      token: token,
      reservationToken: reservationToken,
      tableToken: tableToken,
      waiterToken: waiterToken,
      statusToken: statusToken,
      totalAmountInCents: totalAmountInCents,
      items: items.map((i) => i.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOfflineCreated: isOfflineCreated,
    );
  }

  /// Tworzenie z encji domenowej
  static IsarOrder fromEntity(OrderEntity entity) {
    return IsarOrder()
      ..token = entity.token
      ..reservationToken = entity.reservationToken
      ..tableToken = entity.tableToken
      ..waiterToken = entity.waiterToken
      ..statusToken = entity.statusToken
      ..totalAmountInCents = entity.totalAmountInCents
      ..items = entity.items.map((i) => IsarOrderItem.fromEntity(i)).toList()
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isOfflineCreated = entity.isOfflineCreated;
  }
}

// ============================================================================
// RESERVATION MODEL
// ============================================================================

@collection
class IsarReservation {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String tableToken;
  late String userToken;
  late String statusToken;
  late String? waiterToken;

  late DateTime reservationDate;
  late DateTime startTime;
  late DateTime endTime;
  late int guestCount;
  late int totalPriceInCents;

  late String? notes;

  DateTime? createdAt;
  DateTime? updatedAt;

  /// Konwersja na encję domenową
  ReservationEntity toEntity() {
    return ReservationEntity(
      token: token,
      tableToken: tableToken,
      userToken: userToken,
      statusToken: statusToken,
      waiterToken: waiterToken,
      reservationDate: reservationDate,
      startTime: startTime,
      endTime: endTime,
      guestCount: guestCount,
      totalPrice: totalPriceInCents / 100.0,
      notes: notes,
      orderItems: const [], // Order items są ładowane osobno
    );
  }

  /// Tworzenie z encji domenowej
  static IsarReservation fromEntity(ReservationEntity entity) {
    return IsarReservation()
      ..token = entity.token
      ..tableToken = entity.tableToken
      ..userToken = entity.userToken
      ..statusToken = entity.statusToken
      ..waiterToken = entity.waiterToken
      ..reservationDate = entity.reservationDate
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..guestCount = entity.guestCount
      ..totalPriceInCents = (entity.totalPrice * 100).toInt()
      ..notes = entity.notes;
  }
}

// ============================================================================
// GUEST REPORT MODEL
// ============================================================================

@collection
class IsarGuestReport {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String? token;

  late String clientToken;
  late String reason;
  late String statusToken;
  late String? reporterToken;

  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isOfflineCreated;

  /// Konwersja na encję domenową
  GuestReportEntity toEntity() {
    return GuestReportEntity(
      token: token,
      clientToken: clientToken,
      reason: reason,
      statusToken: statusToken,
      reporterToken: reporterToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOfflineCreated: isOfflineCreated,
    );
  }

  /// Tworzenie z encji domenowej
  static IsarGuestReport fromEntity(GuestReportEntity entity) {
    return IsarGuestReport()
      ..token = entity.token
      ..clientToken = entity.clientToken
      ..reason = entity.reason
      ..statusToken = entity.statusToken
      ..reporterToken = entity.reporterToken
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isOfflineCreated = entity.isOfflineCreated;
  }
}

// ============================================================================
// QUEUED OPERATION MODEL
// ============================================================================

@collection
class IsarQueuedOperation {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String operationId;

  late String type; // np. 'addItemsToReservation', 'removeItemFromReservation'
  
  @ignore
  late Map<String, dynamic> payload;

  late String payloadJson;
  
  late DateTime timestamp;

  late int retryCount;
  late String status; // 'pending', 'processing', 'completed', 'failed'
  String? errorMessage;

  DateTime? createdAt;
  DateTime? lastAttemptAt;
  DateTime? completedAt;
  DateTime? failedAt;

  /// Konwersja na model domenowy
  QueuedOperationModel toModel() {
    return QueuedOperationModel(
      id: operationId,
      type: type,
      payload: jsonDecode(payloadJson) as Map<String, dynamic>,
      timestamp: timestamp,
      retryCount: retryCount,
      status: status,
      errorMessage: errorMessage,
    );
  }

  /// Tworzenie z modelu domenowego
  static IsarQueuedOperation fromModel(QueuedOperationModel model) {
    return IsarQueuedOperation()
      ..operationId = model.id
      ..type = model.type
      ..payloadJson = jsonEncode(model.payload)
      ..timestamp = model.timestamp
      ..retryCount = model.retryCount
      ..status = model.status
      ..errorMessage = model.errorMessage;
  }
}
