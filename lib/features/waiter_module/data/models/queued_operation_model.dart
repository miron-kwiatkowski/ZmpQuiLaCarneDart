import 'package:equatable/equatable.dart';

/// Typ operacji w kolejce offline
enum QueuedOperationType {
  /// Dodawanie pozycji do rezerwacji (POST /api/reservations/item/add)
  addItemsToReservation,
  
  /// Usuwanie pozycji z rezerwacji
  removeItemFromReservation,
  
  /// Zmiana statusu stolika na CLEANING
  markTableCleaning,
  
  /// Zmiana statusu stolika na OUT_OF_SERVICE
  markTableOutOfService,
  
  /// Zmiana statusu stolika na AVAILABLE
  markTableAvailable,
  
  /// Przypisanie kelnera do rezerwacji
  assignWaiterToReservation,
  
  /// Oznaczenie rezerwacji jako no-show
  markReservationAbsent,
  
  /// Utworzenie zgłoszenia gościa
  createGuestReport,
}

/// Status operacji w kolejce
enum QueuedOperationStatus {
  /// Operacja oczekuje na wysyłkę
  pending,
  
  /// Operacja jest obecnie wysyłana
  sending,
  
  /// Operacja została wysłana pomyślnie
  completed,
  
  /// Operacja nie powiodła się (wymaga retry lub manualnej interwencji)
  failed,
}

/// Model operacji w kolejce offline (Data Layer)
/// 
/// Reprezentuje pojedynczą operację która musi zostać zsynchronizowana z serwerem.
class QueuedOperation extends Equatable {
  /// Unikalny ID operacji (generowany lokalnie)
  final String id;
  
  /// Typ operacji
  final QueuedOperationType type;
  
  /// Dane operacji (specyficzne dla typu)
  final Map<String, dynamic> payload;
  
  /// Data utworzenia operacji
  final DateTime createdAt;
  
  /// Data ostatniej próby wysyłki
  final DateTime? lastAttemptAt;
  
  /// Liczba prób wysyłki
  final int retryCount;
  
  /// Status operacji
  final QueuedOperationStatus status;
  
  /// Komunikat błędu (jeśli wystąpił)
  final String? errorMessage;
  
  /// Token rezerwacji (dla operacji związanych z rezerwacjami)
  final String? reservationToken;
  
  /// Token stolika (dla operacji związanych ze stolikami)
  final String? tableToken;
  
  const QueuedOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.status = QueuedOperationStatus.pending,
    this.errorMessage,
    this.reservationToken,
    this.tableToken,
  });
  
  @override
  List<Object?> get props => [
        id,
        type,
        payload,
        createdAt,
        lastAttemptAt,
        retryCount,
        status,
        errorMessage,
        reservationToken,
        tableToken,
      ];
  
  /// Tworzy kopię z incremented retry count
  QueuedOperation copyWithRetry() {
    return QueuedOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      lastAttemptAt: DateTime.now(),
      retryCount: retryCount + 1,
      status: QueuedOperationStatus.pending,
      errorMessage: null,
      reservationToken: reservationToken,
      tableToken: tableToken,
    );
  }
  
  /// Tworzy kopię ze statusem completed
  QueuedOperation copyWithCompleted() {
    return QueuedOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      lastAttemptAt: DateTime.now(),
      retryCount: retryCount,
      status: QueuedOperationStatus.completed,
      errorMessage: null,
      reservationToken: reservationToken,
      tableToken: tableToken,
    );
  }
  
  /// Tworzy kopię ze statusem failed
  QueuedOperation copyWithFailed(String error) {
    return QueuedOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      lastAttemptAt: DateTime.now(),
      retryCount: retryCount,
      status: QueuedOperationStatus.failed,
      errorMessage: error,
      reservationToken: reservationToken,
      tableToken: tableToken,
    );
  }
  
  /// Konwertuje do mapy JSON (do serializacji)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
      'reservationToken': reservationToken,
      'tableToken': tableToken,
    };
  }
  
  /// Tworzy z mapy JSON (deserializacja)
  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: QueuedOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QueuedOperationType.addItemsToReservation,
      ),
      payload: Map<String, dynamic>.from(json['payload']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      status: QueuedOperationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueuedOperationStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      reservationToken: json['reservationToken'] as String?,
      tableToken: json['tableToken'] as String?,
    );
  }
}

/// Model operacji w kolejce offline - wersja uproszczona dla Isar
/// 
/// Używany przez WaiterLocalDataSource i OfflineQueueManager
class QueuedOperationModel extends Equatable {
  final String id;
  final String type; // String dla łatwej serializacji
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? errorMessage;
  
  const QueuedOperationModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
    this.status = 'pending',
    this.errorMessage,
  });
  
  @override
  List<Object?> get props => [
        id,
        type,
        payload,
        timestamp,
        retryCount,
        status,
        errorMessage,
      ];
  
  /// Konwersja z QueuedOperation
  factory QueuedOperationModel.fromDomain(QueuedOperation operation) {
    return QueuedOperationModel(
      id: operation.id,
      type: operation.type.name,
      payload: operation.payload,
      timestamp: operation.createdAt,
      retryCount: operation.retryCount,
      status: operation.status.name,
      errorMessage: operation.errorMessage,
    );
  }
  
  /// Konwersja na QueuedOperation
  QueuedOperation toDomain() {
    return QueuedOperation(
      id: id,
      type: QueuedOperationType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => QueuedOperationType.addItemsToReservation,
      ),
      payload: payload,
      createdAt: timestamp,
      retryCount: retryCount,
      status: QueuedOperationStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => QueuedOperationStatus.pending,
      ),
      errorMessage: errorMessage,
    );
  }
  
  /// Kopiuje z nowym retry count
  QueuedOperationModel copyWithRetry() {
    return QueuedOperationModel(
      id: id,
      type: type,
      payload: payload,
      timestamp: timestamp,
      retryCount: retryCount + 1,
      status: status,
      errorMessage: errorMessage,
    );
  }
  
  /// Konwertuje do JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'status': status,
      'errorMessage': errorMessage,
    };
  }
  
  /// Tworzy z JSON
  factory QueuedOperationModel.fromJson(Map<String, dynamic> json) {
    return QueuedOperationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
