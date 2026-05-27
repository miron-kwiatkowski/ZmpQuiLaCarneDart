import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/offline_queue_manager.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/guest_report_entity.dart';
import '../../domain/repositories/waiter_repository.dart';
import '../datasources/waiter_remote_datasource.dart';
import '../datasources/waiter_local_datasource.dart';
import '../models/dto/table_dto.dart';
import '../models/dto/dish_dto.dart';
import '../models/dto/reservation_dto.dart';

/// Implementacja repozytorium kelnera (Data Layer)
class WaiterRepositoryImpl implements WaiterRepository {
  final WaiterRemoteDataSource _remoteDataSource;
  final WaiterLocalDataSource _localDataSource;
  final OfflineQueueManager _queueManager;
  final NetworkInfo _networkInfo;

  WaiterRepositoryImpl({
    required WaiterRemoteDataSource remoteDataSource,
    required WaiterLocalDataSource localDataSource,
    required OfflineQueueManager queueManager,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _queueManager = queueManager,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<TableEntity>>> getTables({String? filter}) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final tableDtos = await _remoteDataSource.getTables();
        final entities = tableDtos.map((m) => m.toEntity()).toList();
        await _localDataSource.cacheTables(entities);
        return Right(entities);
      } else {
        final cachedTables = await _localDataSource.getTables();
        return Right(cachedTables);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changeTableStatus({
    required String tableToken,
    required String newStatus,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        if (newStatus == 'CLEANING') {
          await _remoteDataSource.markTableCleaning(tableToken);
        } else if (newStatus == 'OUT_OF_SERVICE') {
          await _remoteDataSource.markTableOutOfService(tableToken);
        } else if (newStatus == 'AVAILABLE') {
          await _remoteDataSource.markTableAvailable(tableToken);
        }
        return const Right(true);
      } else {
        final operation = QueueOperationFactory.createMarkTableCleaning(tableToken: tableToken);
        await _queueManager.enqueue(operation);
        return const Right(true);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addItemsToReservation({
    required String reservationToken,
    required List<OrderItemToAdd> items,
  }) async {
    final apiItems = items.map((i) => {
      'dishToken': i.dishToken,
      'quantity': i.quantity,
      'note': i.note,
    }).toList();

    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.addItemsToReservation(
          reservationToken: reservationToken,
          items: apiItems,
        );
        return const Right(true);
      } else {
        final operation = QueueOperationFactory.createAddItemsToReservation(
          reservationToken: reservationToken,
          items: apiItems,
        );
        await _queueManager.enqueue(operation);
        return const Right(true);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.removeItemFromReservation(
          reservationToken: reservationToken,
          dishToken: dishToken,
          quantity: quantity,
          note: note,
        );
        return const Right(true);
      } else {
        final operation = QueueOperationFactory.createRemoveItemFromReservation(
          reservationToken: reservationToken,
          dishToken: dishToken,
          quantity: quantity,
          note: note,
        );
        await _queueManager.enqueue(operation);
        return const Right(true);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> assignWaiter({required String reservationToken}) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.assignWaiterToReservation(reservationToken);
        return const Right(true);
      } else {
        // TODO: Add to queue
        return const Left(ConnectionFailure(message: 'Offline operation not implemented'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAbsent({required String reservationToken}) async {
    return await markReservationAbsent(reservationToken);
  }

  @override
  Future<Either<Failure, bool>> markReservationAbsent(String reservationToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.markReservationAbsent(reservationToken);
        return const Right(true);
      } else {
        // TODO: Add proper offline operation for markReservationAbsent
        return const Left(ConnectionFailure(message: 'Offline operation not implemented for markReservationAbsent'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GuestReportEntity>>> getGuestReports() async {
    try {
      final entities = await _localDataSource.getGuestReports();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createGuestReport({
    required String clientToken,
    required String reason,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.createGuestReport(
          clientToken: clientToken,
          reason: reason,
        );
        return const Right(true);
      } else {
        final operation = QueueOperationFactory.createGuestReport(
          clientToken: clientToken,
          reason: reason,
        );
        await _queueManager.enqueue(operation);
        return const Right(true);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DishEntity>>> getDishes({List<String>? excludedAllergens}) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final models = await _remoteDataSource.getDishes(excludedAllergens: excludedAllergens);
        final entities = models.map((m) => m.toEntity()).toList();
        await _localDataSource.cacheDishes(entities);
        return Right(entities);
      } else {
        final cached = await _localDataSource.getDishes();
        return Right(cached);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReservationEntity>> getReservationDetails({
    required String reservationToken,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final dto = await _remoteDataSource.getReservationByToken(reservationToken);
        final entity = dto.toEntity();
        await _localDataSource.cacheReservation(entity);
        return Right(entity);
      } else {
        final cached = await _localDataSource.getReservationByToken(reservationToken);
        if (cached != null) {
          return Right(cached);
        }
        return const Left(CacheFailure(message: 'Reservation not found in cache'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// Extension methods to handle conversion from DTOs to Entities
extension TableDtoX on TableDto {
  TableEntity toEntity() => TableEntity(
        token: token,
        statusToken: statusToken,
        seats: capacity,
        tableNumber: tableNumber?.toString() ?? name,
        locationDescription: location,
      );
}

extension DishDtoX on DishDto {
  DishEntity toEntity() => DishEntity(
        token: token,
        name: name,
        description: description ?? '',
        priceInCents: (price * 100).toInt(),
        categoryToken: categoryToken,
        ingredientTokens: ingredientTokens,
        allergenTokens: allergenTokens,
        isAvailable: isAvailable,
        imageUrl: null, 
      );
}

extension ReservationDtoX on ReservationDto {
  ReservationEntity toEntity() => ReservationEntity(
        token: token,
        tableToken: tableToken,
        userToken: userToken,
        statusToken: statusToken,
        waiterToken: waiterToken,
        reservationDate: reservationDate,
        startTime: reservationDate, 
        endTime: reservationDate.add(const Duration(hours: 2)), 
        guestCount: guestCount,
        totalPrice: totalPrice ?? 0,
        notes: notes,
        orderItems: items?.map((i) => i.toEntity()).toList() ?? const [],
      );
}

extension OrderItemDtoX on OrderItemDto {
  OrderItemEntity toEntity() => OrderItemEntity(
        token: token,
        dishToken: dishToken,
        dishName: dishName,
        quantity: quantity,
        note: note,
        unitPriceInCents: (unitPrice * 100).toInt(),
        statusToken: statusToken,
      );
}
