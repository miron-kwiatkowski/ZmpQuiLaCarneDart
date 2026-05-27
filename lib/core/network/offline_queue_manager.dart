import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../features/waiter_module/data/models/queued_operation_model.dart';
import '../../features/waiter_module/data/models/isar_models.dart';

/// Interfejs dla informacji o połączeniu sieciowym
/// 
/// Abstrakcja nad connectivity_plus dla lepszej testowalności.
abstract class NetworkInfo {
  /// Czy urządzenie ma aktywne połączenie z internetem
  Future<bool> get isConnected;
  
  /// Strumień zmian statusu połączenia
  Stream<bool> get onConnectivityChanged;
}

/// Implementacja NetworkInfo używająca connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfoImpl(this._connectivity);
  
  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((status) => 
        status != ConnectivityResult.none && 
        status != ConnectivityResult.bluetooth
      );
    } catch (e) {
      // W przypadku błędu zakładamy brak połączenia
      print('Error checking connectivity: $e');
      return false;
    }
  }
  
  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((results) => results.any((status) => 
          status != ConnectivityResult.none && 
          status != ConnectivityResult.bluetooth
        ));
  }
}

/// Manager kolejki operacji offline
/// 
/// Odpowiada za:
/// 1. Zapisywanie operacji do lokalnej bazy
/// 2. Monitorowanie połączenia sieciowego
/// 3. Automatyczną synchronizację oczekujących operacji
/// 4. Obsługę błędów i retry logic
class OfflineQueueManager {
  final NetworkInfo networkInfo;
  final Isar _database;
  final Dio _dio;
  
  // Lista operacji w pamięci (cache)
  final List<QueuedOperation> _pendingOperations = [];
  
  // Flaga zapobiegająca równoczesnym synchronizacjom
  bool _isSyncing = false;
  
  // Subskrypcja zmian połączenia
  StreamSubscription? _connectivitySubscription;
  
  OfflineQueueManager({
    required this.networkInfo,
    required Isar database,
    required Dio dio,
  })  : _database = database,
        _dio = dio {
    _startListeningToConnectivityChanges();
  }
  
  /// Rozpoczyna nasłuchiwanie zmian połączenia
  void _startListeningToConnectivityChanges() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        // Po odzyskaniu połączenia, spróbuj zsynchronizować
        _trySync();
      }
    });
  }
  
  /// Dodaje operację do kolejki
  /// 
  /// Operacja jest zapisywana lokalnie i natychmiastowo wysyłana
  /// jeśli dostępne jest połączenie.
  Future<void> enqueue(QueuedOperation operation) async {
    // Zapisz do lokalnej bazy danych Isar
    await _database.writeTxn(() async {
      final model = QueuedOperationModel.fromDomain(operation);
      final isarOp = IsarQueuedOperation.fromModel(model);
      await _database.isarQueuedOperations.put(isarOp);
    });
    
    // Dodaj do cache w pamięci
    _pendingOperations.add(operation);
    
    // Spróbuj natychmiastowej synchronizacji
    await _trySync();
  }
  
  /// Próbuje zsynchronizować wszystkie oczekujące operacje
  /// 
  /// Jeśli urządzenie jest online, wysyła operacje po kolei.
  /// W przypadku błędu, operacja pozostaje w kolejce do następnej próby.
  Future<void> _trySync() async {
    // Zapobiegaj równoczesnym synchronizacjom
    if (_isSyncing) {
      return;
    }
    
    // Sprawdź czy mamy połączenie
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return;
    }
    
    _isSyncing = true;
    
    try {
      // Pobierz operacje z bazy danych (nie tylko z cache)
      final pendingOps = await _database.isarQueuedOperations
          .filter()
          .statusEqualTo('pending')
          .findAll();
      
      for (final isarOp in pendingOps) {
        // Konwertuj na domenową operację
        final operation = isarOp.toModel().toDomain();
        await _executeOperation(operation);
      }
    } finally {
      _isSyncing = false;
    }
  }

  
  /// Wykonuje pojedynczą operację
  /// 
  /// Wysyła żądanie HTTP odpowiednie do typu operacji.
  /// W przypadku sukcesu usuwa operację z kolejki.
  /// W przypadku błędu inkrementuje retry count.
  Future<void> _executeOperation(QueuedOperation operation) async {
    try {
      Response? response;
      
      switch (operation.type) {
        case QueuedOperationType.addItemsToReservation:
          response = await _executeAddItemsToReservation(operation);
          break;
          
        case QueuedOperationType.removeItemFromReservation:
          response = await _executeRemoveItemFromReservation(operation);
          break;
          
        case QueuedOperationType.markTableCleaning:
          response = await _executeMarkTableCleaning(operation);
          break;
          
        case QueuedOperationType.markTableOutOfService:
          response = await _executeMarkTableOutOfService(operation);
          break;
          
        case QueuedOperationType.markTableAvailable:
          response = await _executeMarkTableAvailable(operation);
          break;
          
        case QueuedOperationType.assignWaiterToReservation:
          response = await _executeAssignWaiterToReservation(operation);
          break;
          
        case QueuedOperationType.markReservationAbsent:
          response = await _executeMarkReservationAbsent(operation);
          break;
          
        case QueuedOperationType.createGuestReport:
          response = await _executeCreateGuestReport(operation);
          break;
      }
      
      // Sukces - usuń operację z kolejki
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _removeOperation(operation.id);
      } else {
        // Błąd HTTP - retry
        await _handleOperationError(operation, 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Błąd sieciowy lub inny - retry
      await _handleOperationError(operation, e.toString());
    }
  }
  
  /// Wykonuje operację dodania pozycji do rezerwacji
  Future<Response> _executeAddItemsToReservation(QueuedOperation operation) async {
    final reservationToken = operation.payload['reservationToken'] as String;
    final items = operation.payload['items'] as List<Map<String, dynamic>>;
    
    return await _dio.post(
      '/api/reservations/item/add',
      queryParameters: {'reservationToken': reservationToken},
      data: items,
    );
  }
  
  /// Wykonuje operację usunięcia pozycji z rezerwacji
  Future<Response> _executeRemoveItemFromReservation(QueuedOperation operation) async {
    final reservationToken = operation.payload['reservationToken'] as String;
    final dishToken = operation.payload['dishToken'] as String;
    final quantity = operation.payload['quantity'] as int;
    final note = operation.payload['note'] as String?;
    
    return await _dio.post(
      '/api/reservations/item/remove',
      queryParameters: {'reservationToken': reservationToken},
      data: {
        'dishToken': dishToken,
        'quantity': quantity,
        'note': note,
      },
    );
  }
  
  /// Wykonuje operację zmiany statusu stolika na CLEANING
  Future<Response> _executeMarkTableCleaning(QueuedOperation operation) async {
    final tableToken = operation.payload['tableToken'] as String;
    
    return await _dio.patch('/api/tables/$tableToken/clear');
  }
  
  /// Wykonuje operację zmiany statusu stolika na OUT_OF_SERVICE
  Future<Response> _executeMarkTableOutOfService(QueuedOperation operation) async {
    final tableToken = operation.payload['tableToken'] as String;
    
    return await _dio.patch('/api/tables/$tableToken/out-of-services');
  }
  
  /// Wykonuje operację zmiany statusu stolika na AVAILABLE
  Future<Response> _executeMarkTableAvailable(QueuedOperation operation) async {
    final tableToken = operation.payload['tableToken'] as String;
    
    return await _dio.patch('/api/tables/$tableToken/avalaible');
  }
  
  /// Wykonuje operację przypisania kelnera do rezerwacji
  Future<Response> _executeAssignWaiterToReservation(QueuedOperation operation) async {
    final reservationToken = operation.payload['reservationToken'] as String;
    
    return await _dio.patch('/api/reservations/$reservationToken/assign-waiter');
  }
  
  /// Wykonuje operację oznaczenia rezerwacji jako no-show
  Future<Response> _executeMarkReservationAbsent(QueuedOperation operation) async {
    final reservationToken = operation.payload['reservationToken'] as String;
    
    return await _dio.patch('/api/reservations/$reservationToken/absent');
  }
  
  /// Wykonuje operację utworzenia zgłoszenia gościa
  Future<Response> _executeCreateGuestReport(QueuedOperation operation) async {
    final clientToken = operation.payload['clientToken'] as String;
    final reason = operation.payload['reason'] as String;
    
    return await _dio.post(
      '/api/report',
      data: {
        'clientToken': clientToken,
        'reason': reason,
      },
    );
  }
  
  /// Obsługuje błąd operacji
  /// 
  /// Inkrementuje retry count i ustawia limit maksymalnych prób.
  Future<void> _handleOperationError(QueuedOperation operation, String error) async {
    const maxRetries = 5;
    
    if (operation.retryCount >= maxRetries) {
      // Przekroczono limit prób - oznacz jako failed w bazie
      await _database.writeTxn(() async {
        final isarOp = await _database.isarQueuedOperations
            .filter()
            .operationIdEqualTo(operation.id)
            .findFirst();
        if (isarOp != null) {
          isarOp.status = 'failed';
          isarOp.errorMessage = error;
          isarOp.failedAt = DateTime.now();
          await _database.isarQueuedOperations.put(isarOp);
        }
      });
      
      // Usuń z cache w pamięci
      _pendingOperations.removeWhere((op) => op.id == operation.id);
      
      print('Operation ${operation.id} failed after $maxRetries attempts: $error');
    } else {
      // Zwiększ retry count i zapisz w bazie
      await _database.writeTxn(() async {
        final isarOp = await _database.isarQueuedOperations
            .filter()
            .operationIdEqualTo(operation.id)
            .findFirst();
        if (isarOp != null) {
          isarOp.retryCount = isarOp.retryCount + 1;
          isarOp.lastAttemptAt = DateTime.now();
          await _database.isarQueuedOperations.put(isarOp);
        }
      });
      
      // Aktualizuj w cache
      final updatedOperation = operation.copyWithRetry();
      final index = _pendingOperations.indexWhere((op) => op.id == operation.id);
      if (index != -1) {
        _pendingOperations[index] = updatedOperation;
      }
      
      print('Operation ${operation.id} failed (attempt ${operation.retryCount + 1}): $error');
    }
  }
  
  /// Usuwa operację z kolejki po pomyślnej synchronizacji
  Future<void> _removeOperation(String operationId) async {
    // Usuń z bazy danych
    await _database.writeTxn(() async {
      final isarOp = await _database.isarQueuedOperations
          .filter()
          .operationIdEqualTo(operationId)
          .findFirst();
      if (isarOp != null) {
        isarOp.status = 'completed';
        isarOp.completedAt = DateTime.now();
        await _database.isarQueuedOperations.put(isarOp);
      }
    });
    
    // Usuń z cache w pamięci
    _pendingOperations.removeWhere((op) => op.id == operationId);
    print('Operation $operationId completed and removed from queue');
  }

  
  /// Zwraca liczbę oczekujących operacji
  int get pendingOperationsCount => _pendingOperations.length;
  
  /// Czyści wszystkie zakończone operacje
  Future<void> clearCompleted() async {
    // Usuń zakończone operacje z bazy
    await _database.writeTxn(() async {
      final completedOps = await _database.isarQueuedOperations
          .filter()
          .statusEqualTo('completed')
          .findAll();
      
      for (final op in completedOps) {
        await _database.isarQueuedOperations.delete(op.id);
      }
    });
    
    // Wyczyść cache
    _pendingOperations.removeWhere((op) => op.status == QueuedOperationStatus.completed);
  }
  
  /// Dispose - czyszczenie zasobów
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Helper do tworzenia operacji kolejki
class QueueOperationFactory {
  static final _uuid = const Uuid();
  
  /// Tworzy operację dodania pozycji do rezerwacji
  static QueuedOperation createAddItemsToReservation({
    required String reservationToken,
    required List<Map<String, dynamic>> items,
  }) {
    return QueuedOperation(
      id: _uuid.v4(),
      type: QueuedOperationType.addItemsToReservation,
      payload: {
        'reservationToken': reservationToken,
        'items': items,
      },
      createdAt: DateTime.now(),
      reservationToken: reservationToken,
    );
  }
  
  /// Tworzy operację usunięcia pozycji z rezerwacji
  static QueuedOperation createRemoveItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  }) {
    return QueuedOperation(
      id: _uuid.v4(),
      type: QueuedOperationType.removeItemFromReservation,
      payload: {
        'reservationToken': reservationToken,
        'dishToken': dishToken,
        'quantity': quantity,
        'note': note,
      },
      createdAt: DateTime.now(),
      reservationToken: reservationToken,
    );
  }
  
  /// Tworzy operację zmiany statusu stolika
  static QueuedOperation createMarkTableCleaning({required String tableToken}) {
    return QueuedOperation(
      id: _uuid.v4(),
      type: QueuedOperationType.markTableCleaning,
      payload: {'tableToken': tableToken},
      createdAt: DateTime.now(),
      tableToken: tableToken,
    );
  }
  
  /// Tworzy operację zgłoszenia gościa
  static QueuedOperation createGuestReport({
    required String clientToken,
    required String reason,
  }) {
    return QueuedOperation(
      id: _uuid.v4(),
      type: QueuedOperationType.createGuestReport,
      payload: {
        'clientToken': clientToken,
        'reason': reason,
      },
      createdAt: DateTime.now(),
    );
  }
}
