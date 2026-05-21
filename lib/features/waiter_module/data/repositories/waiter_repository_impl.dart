import 'package:dartz/dartz.dart';

/// Implementacja repozytorium kelnera (Data Layer)
/// 
/// Łączy zdalne źródło danych (API) z lokalnym cache i kolejką offline.
/// Realizuje strategię Offline-First z automatyczną synchronizacją.
class WaiterRepositoryImpl implements WaiterRepository {
  final WaiterRemoteDataSource _remoteDataSource;
  // final WaiterLocalDataSource _localDataSource;
  final OfflineQueueManager _queueManager;
  final NetworkInfo _networkInfo;
  
  WaiterRepositoryImpl({
    required WaiterRemoteDataSource remoteDataSource,
    // required WaiterLocalDataSource localDataSource,
    required OfflineQueueManager queueManager,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        // _localDataSource = localDataSource,
        _queueManager = queueManager,
        _networkInfo = networkInfo;
  
  @override
  Future<List<TableEntity>> getTables() async {
    try {
      // Strategia: najpierw spróbuj z API, fallback do cache
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        // Pobierz z API i zapisz w cache
        final tableModels = await _remoteDataSource.getTables();
        final tables = tableModels.map((m) => m.toEntity()).toList();
        
        // TODO: Save to local cache
        // await _localDataSource.cacheTables(tables);
        
        return tables;
      } else {
        // Brak internetu - zwróć z cache
        // return await _localDataSource.getCachedTables();
        throw const ConnectionFailure(message: 'Brak połączenia z internetem');
      }
    } on ServerException catch (e) {
      // Spróbuj z cache jeśli API zawiedzie
      // final cachedTables = await _localDataSource.getCachedTables();
      // if (cachedTables.isNotEmpty) {
      //   return cachedTables;
      // }
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<TableEntity?> getTableByToken(String token) async {
    // TODO: Implement get table by token
    throw UnimplementedError();
  }
  
  @override
  Future<void> markTableForCleaning(String tableToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        // Online - wyślij od razu do API
        await _remoteDataSource.markTableCleaning(tableToken);
      } else {
        // Offline - dodaj do kolejki
        final operation = QueueOperationFactory.createMarkTableCleaning(
          tableToken: tableToken,
        );
        await _queueManager.enqueue(operation);
      }
    } on ServerException catch (e) {
      // Błąd API - dodaj do kolejki mimo wszystko
      final operation = QueueOperationFactory.createMarkTableCleaning(
        tableToken: tableToken,
      );
      await _queueManager.enqueue(operation);
    }
  }
  
  @override
  Future<void> markTableOutOfService(String tableToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.markTableOutOfService(tableToken);
      } else {
        // TODO: Add to queue when factory method is available
        throw const ConnectionFailure(message: 'Offline operation not implemented yet');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<void> markTableAvailable(String tableToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.markTableAvailable(tableToken);
      } else {
        // TODO: Add to queue
        throw const ConnectionFailure(message: 'Offline operation not implemented yet');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<void> assignWaiterToReservation(String reservationToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.assignWaiterToReservation(reservationToken);
      } else {
        // TODO: Add to queue
        throw const ConnectionFailure(message: 'Offline operation not implemented yet');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<void> markReservationAsAbsent(String reservationToken) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.markReservationAbsent(reservationToken);
      } else {
        // TODO: Add to queue
        throw const ConnectionFailure(message: 'Offline operation not implemented yet');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<List<DishEntity>> getDishes({List<String>? excludedAllergens}) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        final dishModels = await _remoteDataSource.getDishes(
          excludedAllergens: excludedAllergens,
        );
        final dishes = dishModels.map((m) => m.toEntity()).toList();
        
        // TODO: Cache dishes
        // await _localDataSource.cacheDishes(dishes);
        
        return dishes;
      } else {
        // Return from cache
        // return await _localDataSource.getCachedDishes(excludedAllergens: excludedAllergens);
        throw const ConnectionFailure(message: 'Brak połączenia z internetem');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<DishEntity?> getDishByToken(String token) async {
    // TODO: Implement get dish by token
    throw UnimplementedError();
  }
  
  @override
  Future<void> createOrUpdateOrder(OrderEntity order) async {
    // Ta metoda jest używana dla lokalnych operacji na zamówieniu
    // W przypadku offline, zamówienie jest zapisywane lokalnie
    
    // TODO: Save order to local database
    // await _localDataSource.saveOrder(order);
    
    // Jeśli mamy połączenie i zamówienie ma rezerwację, wyślij do API
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline && order.reservationToken != null) {
      // Konwertuj pozycje zamówienia do formatu API
      final items = order.items.map((item) => {
        'dishToken': item.dishToken,
        'quantity': item.quantity,
        'note': item.note,
      }).toList();
      
      try {
        await _remoteDataSource.addItemsToReservation(
          reservationToken: order.reservationToken!,
          items: items,
        );
      } on ServerException catch (e) {
        // Błąd API - dodaj do kolejki
        final operation = QueueOperationFactory.createAddItemsToReservation(
          reservationToken: order.reservationToken!,
          items: items,
        );
        await _queueManager.enqueue(operation);
      }
    } else if (!isOnline && order.reservationToken != null) {
      // Offline - dodaj do kolejki
      final items = order.items.map((item) => {
        'dishToken': item.dishToken,
        'quantity': item.quantity,
        'note': item.note,
      }).toList();
      
      final operation = QueueOperationFactory.createAddItemsToReservation(
        reservationToken: order.reservationToken!,
        items: items,
      );
      await _queueManager.enqueue(operation);
    }
    
    // W obu przypadkach zamówienie jest zapisane lokalnie
  }
  
  @override
  Future<void> addItemsToReservation({
    required String reservationToken,
    required List<OrderItemInput> items,
  }) async {
    final apiItems = items.map((item) => {
      'dishToken': item.dishToken,
      'quantity': item.quantity,
      'note': item.note,
    }).toList();
    
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.addItemsToReservation(
          reservationToken: reservationToken,
          items: apiItems,
        );
      } else {
        // Offline - dodaj do kolejki
        final operation = QueueOperationFactory.createAddItemsToReservation(
          reservationToken: reservationToken,
          items: apiItems,
        );
        await _queueManager.enqueue(operation);
      }
    } on ServerException catch (e) {
      // Błąd API - dodaj do kolejki
      final operation = QueueOperationFactory.createAddItemsToReservation(
        reservationToken: reservationToken,
        items: apiItems,
      );
      await _queueManager.enqueue(operation);
    }
  }
  
  @override
  Future<void> removeItemFromReservation({
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
      } else {
        // Offline - dodaj do kolejki
        final operation = QueueOperationFactory.createRemoveItemFromReservation(
          reservationToken: reservationToken,
          dishToken: dishToken,
          quantity: quantity,
          note: note,
        );
        await _queueManager.enqueue(operation);
      }
    } on ServerException catch (e) {
      // Błąd API - dodaj do kolejki
      final operation = QueueOperationFactory.createRemoveItemFromReservation(
        reservationToken: reservationToken,
        dishToken: dishToken,
        quantity: quantity,
        note: note,
      );
      await _queueManager.enqueue(operation);
    }
  }
  
  @override
  Future<ReservationEntity?> getReservationByToken(String token) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        final model = await _remoteDataSource.getReservationByToken(token);
        return model.toEntity();
      } else {
        // TODO: Get from cache
        // return await _localDataSource.getCachedReservation(token);
        throw const ConnectionFailure(message: 'Brak połączenia z internetem');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
  
  @override
  Future<List<ReservationEntity>> getReservationsHistory({
    DateTime? fromDate,
    DateTime? toDate,
    String? statusToken,
    int page = 1,
    int size = 10,
  }) async {
    // TODO: Implement reservations history
    throw UnimplementedError();
  }
  
  @override
  Future<void> submitGuestReport(GuestReportEntity report) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        await _remoteDataSource.createGuestReport(
          clientToken: report.clientToken,
          reason: report.reason,
        );
      } else {
        // Offline - dodaj do kolejki
        final operation = QueueOperationFactory.createGuestReport(
          clientToken: report.clientToken,
          reason: report.reason,
        );
        await _queueManager.enqueue(operation);
      }
    } on ServerException catch (e) {
      // Błąd API - dodaj do kolejki
      final operation = QueueOperationFactory.createGuestReport(
        clientToken: report.clientToken,
        reason: report.reason,
      );
      await _queueManager.enqueue(operation);
    }
  }
  
  @override
  Future<List<GuestReportEntity>> getGuestReports({int page = 1}) async {
    // TODO: Implement get guest reports
    throw UnimplementedError();
  }
}

// Extension methods for converting models to entities
// These would normally be in separate model files
extension TableModelX on TableModel {
  TableEntity toEntity() {
    // TODO: Implement actual conversion
    return const TableEntity(
      token: '',
      statusToken: '',
      tableNumber: '',
    );
  }
}

extension DishModelX on DishModel {
  DishEntity toEntity() {
    // TODO: Implement actual conversion
    return const DishEntity(
      token: '',
      name: '',
      description: '',
      priceInCents: 0,
      categoryToken: '',
      ingredientTokens: [],
      allergenTokens: [],
      isAvailable: true,
    );
  }
}

extension ReservationModelX on ReservationModel {
  ReservationEntity toEntity() {
    // TODO: Implement actual conversion
    return const ReservationEntity(
      token: '',
      tableToken: '',
      statusToken: '',
      reservationTime: DateTime.now(),
    );
  }
}
