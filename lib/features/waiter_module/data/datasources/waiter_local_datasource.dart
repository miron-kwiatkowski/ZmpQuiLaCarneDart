import 'package:isar/isar.dart';
import '../../../../core/database/local_database.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/guest_report_entity.dart';
import '../models/isar_models.dart';
import '../models/queued_operation_model.dart';

/// Abstrakcja dla lokalnego źródła danych (Local DataSource Interface)
/// 
/// WZORZEC: Data Source Pattern
/// - Izoluje dostęp do konkretnej bazy danych (Isar)
/// - Umożliwia łatwe testowanie przez mockowanie
/// - Separuje logikę dostępu do danych od logiki biznesowej
abstract class WaiterLocalDataSource {
  Future<List<TableEntity>> getTables();
  Future<void> cacheTables(List<TableEntity> tables);
  Future<List<DishEntity>> getDishes();
  Future<void> cacheDishes(List<DishEntity> dishes);
  Future<DishEntity?> getDishByToken(String token);
  Future<List<OrderEntity>> getOrdersForReservation(String reservationToken);
  Future<void> cacheOrder(OrderEntity order);
  Future<void> updateOrderStatus(String orderToken, String statusToken);
  Future<List<ReservationEntity>> getReservations();
  Future<void> cacheReservation(ReservationEntity reservation);
  Future<ReservationEntity?> getReservationByToken(String token);
  Future<List<GuestReportEntity>> getGuestReports();
  Future<void> cacheGuestReport(GuestReportEntity report);
  Future<List<QueuedOperationModel>> getPendingOperations();
  Future<void> addOperationToQueue(QueuedOperationModel operation);
  Future<void> removeOperationFromQueue(String operationId);
  Future<void> updateOperationRetryCount(String operationId, int retryCount);
  Future<void> markOperationAsCompleted(String operationId);
  Future<void> markOperationAsFailed(String operationId, String errorMessage);
  Future<void> clearAllData();
  Future<Map<String, int>> getCacheStats();
}

/// Implementacja lokalnego źródła danych przy użyciu Isar
class WaiterLocalDataSourceImpl implements WaiterLocalDataSource {
  final Isar _isar;

  WaiterLocalDataSourceImpl({Isar? isar}) : _isar = isar ?? LocalDatabase.instance;

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      final tables = await _isar.isarTables.where().findAll();
      return tables.map((t) => t.toEntity()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu stolików z cache: $e');
    }
  }

  @override
  Future<void> cacheTables(List<TableEntity> tables) async {
    try {
      await _isar.writeTxn(() async {
        for (final table in tables) {
          final existing = await _isar.isarTables.filter().tokenEqualTo(table.token).findFirst();
          if (existing != null) {
            existing
              ..statusToken = table.statusToken
              ..seats = table.seats
              ..tableNumber = table.tableNumber
              ..locationDescription = table.locationDescription
              ..lastUpdatedAt = DateTime.now();
            await _isar.isarTables.put(existing);
          } else {
            final newTable = IsarTable.fromEntity(table)
              ..createdAt = DateTime.now()
              ..lastUpdatedAt = DateTime.now();
            await _isar.isarTables.put(newTable);
          }
        }
      });
    } catch (e) {
      throw Exception('Błąd zapisu stolików do cache: $e');
    }
  }

  @override
  Future<List<DishEntity>> getDishes() async {
    try {
      final dishes = await _isar.isarDishs.where().findAll();
      return dishes.map((d) => d.toEntity()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu dań z cache: $e');
    }
  }

  @override
  Future<void> cacheDishes(List<DishEntity> dishes) async {
    try {
      await _isar.writeTxn(() async {
        for (final dish in dishes) {
          final existing = await _isar.isarDishs.filter().tokenEqualTo(dish.token).findFirst();
          if (existing != null) {
            existing
              ..name = dish.name
              ..description = dish.description
              ..priceInCents = dish.priceInCents
              ..categoryToken = dish.categoryToken
              ..ingredientTokens = dish.ingredientTokens
              ..allergenTokens = dish.allergenTokens
              ..isAvailable = dish.isAvailable
              ..unavailabilityReason = dish.unavailabilityReason
              ..imageUrl = dish.imageUrl
              ..lastUpdatedAt = DateTime.now();
            await _isar.isarDishs.put(existing);
          } else {
            final newDish = IsarDish.fromEntity(dish)
              ..createdAt = DateTime.now()
              ..lastUpdatedAt = DateTime.now();
            await _isar.isarDishs.put(newDish);
          }
        }
      });
    } catch (e) {
      throw Exception('Błąd zapisu dań do cache: $e');
    }
  }

  @override
  Future<DishEntity?> getDishByToken(String token) async {
    try {
      return await _isar.isarDishs.filter().tokenEqualTo(token).findFirst().then((d) => d?.toEntity());
    } catch (e) {
      throw Exception('Błąd odczytu dania: $e');
    }
  }


  @override
  Future<List<OrderEntity>> getOrdersForReservation(String reservationToken) async {
    try {
      final orders = await _isar.isarOrders
          .filter()
          .reservationTokenEqualTo(reservationToken)
          .findAll();
      return orders.map((o) => o.toEntity()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu zamówień: $e');
    }
  }

  @override
  Future<void> cacheOrder(OrderEntity order) async {
    try {
      await _isar.writeTxn(() async {
        final existing = order.token != null 
            ? await _isar.isarOrders.filter().tokenEqualTo(order.token).findFirst()
            : null;
        if (existing != null) {
          existing
            ..reservationToken = order.reservationToken
            ..tableToken = order.tableToken
            ..waiterToken = order.waiterToken
            ..statusToken = order.statusToken
            ..totalAmountInCents = order.totalAmountInCents
            ..items = order.items.map((i) => IsarOrderItem.fromEntity(i)).toList()
            ..updatedAt = DateTime.now();
          await _isar.isarOrders.put(existing);
        } else {
          final newOrder = IsarOrder.fromEntity(order)
            ..createdAt = order.createdAt;
          await _isar.isarOrders.put(newOrder);
        }
      });
    } catch (e) {
      throw Exception('Błąd zapisu zamówienia: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderToken, String statusToken) async {
    try {
      await _isar.writeTxn(() async {
        final order = await _isar.isarOrders.filter().tokenEqualTo(orderToken).findFirst();
        if (order != null) {
          order.statusToken = statusToken;
          order.updatedAt = DateTime.now();
          await _isar.isarOrders.put(order);
        } else {
          throw Exception('Zamówienie nie znalezione: $orderToken');
        }
      });
    } catch (e) {
      throw Exception('Błąd aktualizacji statusu zamówienia: $e');
    }
  }

  @override
  Future<List<ReservationEntity>> getReservations() async {
    try {
      final reservations = await _isar.isarReservations.where().findAll();
      return reservations.map((r) => r.toEntity()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu rezerwacji: $e');
    }
  }

  @override
  Future<void> cacheReservation(ReservationEntity reservation) async {
    try {
      await _isar.writeTxn(() async {
        final existing = await _isar.isarReservations.filter().tokenEqualTo(reservation.token).findFirst();
        if (existing != null) {
          existing
            ..tableToken = reservation.tableToken
            ..userToken = reservation.userToken
            ..statusToken = reservation.statusToken
            ..waiterToken = reservation.waiterToken
            ..reservationDate = reservation.reservationDate
            ..startTime = reservation.startTime
            ..endTime = reservation.endTime
            ..guestCount = reservation.guestCount
            ..totalPriceInCents = (reservation.totalPrice * 100).toInt()
            ..notes = reservation.notes
            ..updatedAt = DateTime.now();
          await _isar.isarReservations.put(existing);
        } else {
          final newReservation = IsarReservation.fromEntity(reservation)
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await _isar.isarReservations.put(newReservation);
        }
      });
    } catch (e) {
      throw Exception('Błąd zapisu rezerwacji: $e');
    }
  }

  @override
  Future<ReservationEntity?> getReservationByToken(String token) async {
    try {
      final reservation = await _isar.isarReservations.filter().tokenEqualTo(token).findFirst();
      return reservation?.toEntity();
    } catch (e) {
      throw Exception('Błąd odczytu rezerwacji: $e');
    }
  }

  @override
  Future<List<GuestReportEntity>> getGuestReports() async {
    try {
      final reports = await _isar.isarGuestReports.where().findAll();
      return reports.map((r) => r.toEntity()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu zgłoszeń: $e');
    }
  }

  @override
  Future<void> cacheGuestReport(GuestReportEntity report) async {
    try {
      await _isar.writeTxn(() async {
        final existing = report.token != null 
            ? await _isar.isarGuestReports.filter().tokenEqualTo(report.token).findFirst()
            : null;
        if (existing != null) {
          existing
            ..clientToken = report.clientToken
            ..reason = report.reason
            ..statusToken = report.statusToken
            ..reporterToken = report.reporterToken
            ..updatedAt = DateTime.now();
          await _isar.isarGuestReports.put(existing);
        } else {
          final newReport = IsarGuestReport.fromEntity(report)
            ..createdAt = report.createdAt;
          await _isar.isarGuestReports.put(newReport);
        }
      });
    } catch (e) {
      throw Exception('Błąd zapisu zgłoszenia: $e');
    }
  }


  @override
  Future<List<QueuedOperationModel>> getPendingOperations() async {
    try {
      final operations = await _isar.isarQueuedOperations
          .filter()
          .statusEqualTo('pending')
          .sortByTimestamp()
          .findAll();
      return operations.map((o) => o.toModel()).toList();
    } catch (e) {
      throw Exception('Błąd odczytu kolejki operacji: $e');
    }
  }

  @override
  Future<void> addOperationToQueue(QueuedOperationModel operation) async {
    try {
      await _isar.writeTxn(() async {
        final queuedOp = IsarQueuedOperation.fromModel(operation)
          ..createdAt = DateTime.now();
        await _isar.isarQueuedOperations.put(queuedOp);
      });
    } catch (e) {
      throw Exception('Błąd dodania operacji do kolejki: $e');
    }
  }

  @override
  Future<void> removeOperationFromQueue(String operationId) async {
    try {
      await _isar.writeTxn(() async {
        final op = await _isar.isarQueuedOperations.filter().operationIdEqualTo(operationId).findFirst();
        if (op != null) {
          await _isar.isarQueuedOperations.delete(op.id);
        }
      });
    } catch (e) {
      throw Exception('Błąd usuwania operacji z kolejki: $e');
    }
  }

  @override
  Future<void> updateOperationRetryCount(String operationId, int retryCount) async {
    try {
      await _isar.writeTxn(() async {
        final operation = await _isar.isarQueuedOperations.filter().operationIdEqualTo(operationId).findFirst();
        if (operation != null) {
          operation.retryCount = retryCount;
          operation.lastAttemptAt = DateTime.now();
          await _isar.isarQueuedOperations.put(operation);
        }
      });
    } catch (e) {
      throw Exception('Błąd aktualizacji próby operacji: $e');
    }
  }

  @override
  Future<void> markOperationAsCompleted(String operationId) async {
    try {
      await _isar.writeTxn(() async {
        final operation = await _isar.isarQueuedOperations.filter().operationIdEqualTo(operationId).findFirst();
        if (operation != null) {
          operation.status = 'completed';
          operation.completedAt = DateTime.now();
          await _isar.isarQueuedOperations.put(operation);
        }
      });
    } catch (e) {
      throw Exception('Błąd oznaczania operacji jako completed: $e');
    }
  }

  @override
  Future<void> markOperationAsFailed(String operationId, String errorMessage) async {
    try {
      await _isar.writeTxn(() async {
        final operation = await _isar.isarQueuedOperations.filter().operationIdEqualTo(operationId).findFirst();
        if (operation != null) {
          operation.status = 'failed';
          operation.errorMessage = errorMessage;
          operation.failedAt = DateTime.now();
          await _isar.isarQueuedOperations.put(operation);
        }
      });
    } catch (e) {
      throw Exception('Błąd oznaczania operacji jako failed: $e');
    }
  }


  @override
  Future<void> clearAllData() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.isarTables.clear();
        await _isar.isarDishs.clear();
        await _isar.isarOrders.clear();
        await _isar.isarReservations.clear();
        await _isar.isarGuestReports.clear();
      });
    } catch (e) {
      throw Exception('Błąd czyszczenia danych: $e');
    }
  }

  @override
  Future<Map<String, int>> getCacheStats() async {
    try {
      return {
        'tables': await _isar.isarTables.count(),
        'dishes': await _isar.isarDishs.count(),
        'orders': await _isar.isarOrders.count(),
        'reservations': await _isar.isarReservations.count(),
        'guestReports': await _isar.isarGuestReports.count(),
        'queuedOperations': await _isar.isarQueuedOperations.count(),
        'pendingOperations': await _isar.isarQueuedOperations
            .filter()
            .statusEqualTo('pending')
            .count(),
      };
    } catch (e) {
      throw Exception('Błąd pobierania statystyk cache: $e');
    }
  }
}
