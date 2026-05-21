import 'package:dio/dio.dart';

/// Zdalne źródło danych dla modułu kelnera (Data Layer)
/// 
/// Odpowiada za komunikację z API REST.
/// Nie zawiera żadnej logiki biznesowej - tylko HTTP calls.
abstract class WaiterRemoteDataSource {
  /// Pobiera listę stolików z API
  Future<List<TableModel>> getTables();
  
  /// Pobiera listę dań z API
  Future<List<DishModel>> getDishes({List<String>? excludedAllergens});
  
  /// Dodaje pozycje do rezerwacji
  Future<void> addItemsToReservation({
    required String reservationToken,
    required List<Map<String, dynamic>> items,
  });
  
  /// Usuwa pozycję z rezerwacji
  Future<void> removeItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  });
  
  /// Zmienia status stolika na CLEANING
  Future<void> markTableCleaning(String tableToken);
  
  /// Zmienia status stolika na OUT_OF_SERVICE
  Future<void> markTableOutOfService(String tableToken);
  
  /// Zmienia status stolika na AVAILABLE
  Future<void> markTableAvailable(String tableToken);
  
  /// Przypisuje kelnera do rezerwacji
  Future<void> assignWaiterToReservation(String reservationToken);
  
  /// Oznacza rezerwację jako no-show
  Future<void> markReservationAbsent(String reservationToken);
  
  /// Tworzy zgłoszenie gościa
  Future<void> createGuestReport({
    required String clientToken,
    required String reason,
  });
  
  /// Pobiera szczegóły rezerwacji
  Future<ReservationModel> getReservationByToken(String token);
}

/// Implementacja zdalnego źródła danych
class WaiterRemoteDataSourceImpl implements WaiterRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;
  
  WaiterRemoteDataSourceImpl({
    required Dio dio,
    String baseUrl = 'https://api.quilacarne.com',
  })  : _dio = dio,
        _baseUrl = baseUrl;
  
  @override
  Future<List<TableModel>> getTables() async {
    final response = await _dio.get('/api/tables');
    
    // TODO: Handle error responses properly
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => TableModel.fromJson(item)).toList();
    }
    
    throw ServerException('Failed to fetch tables');
  }
  
  @override
  Future<List<DishModel>> getDishes({List<String>? excludedAllergens}) async {
    final response = await _dio.get(
      '/api/dishes',
      queryParameters: excludedAllergens != null
          ? {'excludedAllergens': excludedAllergens}
          : null,
    );
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => DishModel.fromJson(item)).toList();
    }
    
    throw ServerException('Failed to fetch dishes');
  }
  
  @override
  Future<void> addItemsToReservation({
    required String reservationToken,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _dio.post(
      '/api/reservations/item/add',
      queryParameters: {'reservationToken': reservationToken},
      data: items,
    );
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to add items to reservation');
    }
  }
  
  @override
  Future<void> removeItemFromReservation({
    required String reservationToken,
    required String dishToken,
    required int quantity,
    String? note,
  }) async {
    // API endpoint: DELETE /api/reservations/item/remove
    // Request body: { dishToken, quantity, note }
    // Query param: reservationToken
    final response = await _dio.delete(
      '/api/reservations/item/remove',
      queryParameters: {'reservationToken': reservationToken},
      data: {
        'dishToken': dishToken,
        'quantity': quantity,
        if (note != null) 'note': note,
      },
    );
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      final errorMessages = (response.data['errorMessages'] as List?)?.join(', ') ?? 'Unknown error';
      throw ServerException('Failed to remove item from reservation: $errorMessages');
    }
  }
  
  @override
  Future<void> markTableCleaning(String tableToken) async {
    final response = await _dio.patch('/api/tables/$tableToken/clear');
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to mark table for cleaning');
    }
  }
  
  @override
  Future<void> markTableOutOfService(String tableToken) async {
    final response = await _dio.patch('/api/tables/$tableToken/out-of-services');
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to mark table as out of service');
    }
  }
  
  @override
  Future<void> markTableAvailable(String tableToken) async {
    final response = await _dio.patch('/api/tables/$tableToken/avalaible');
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to mark table as available');
    }
  }
  
  @override
  Future<void> assignWaiterToReservation(String reservationToken) async {
    final response = await _dio.patch('/api/reservations/$reservationToken/assign-waiter');
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to assign waiter to reservation');
    }
  }
  
  @override
  Future<void> markReservationAbsent(String reservationToken) async {
    final response = await _dio.patch('/api/reservations/$reservationToken/absent');
    
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException('Failed to mark reservation as absent');
    }
  }
  
  @override
  Future<void> createGuestReport({
    required String clientToken,
    required String reason,
  }) async {
    final response = await _dio.post(
      '/api/report',
      data: {
        'clientToken': clientToken,
        'reason': reason,
      },
    );
    
    if (response.statusCode != 201 || response.data['success'] != true) {
      throw ServerException('Failed to create guest report');
    }
  }
  
  @override
  Future<ReservationModel> getReservationByToken(String token) async {
    final response = await _dio.get('/api/reservations/$token');
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ReservationModel.fromJson(data);
    }
    
    throw ServerException('Failed to fetch reservation details');
  }
}

/// Wyjątek dla błędów serwera
class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

// Forward declarations for models (to be implemented in separate files)
// These are placeholders to make the code compile
class TableModel {
  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel();
}

class DishModel {
  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel();
}

class ReservationModel {
  factory ReservationModel.fromJson(Map<String, dynamic> json) => ReservationModel();
}
