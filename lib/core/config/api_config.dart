import 'package:flutter/foundation.dart';

/// Konfiguracja API dla aplikacji QuiLaCarne
/// 
/// Wzorzec: Configuration Object Pattern
/// Dlaczego: Centralizacja wszystkich stałych konfiguracyjnych
/// ułatwia zarządzanie różnymi środowiskami (dev, staging, prod)
class ApiConfig {
  // Środowiska
  static const String _devBaseUrl = 'https://dev-api.quilacarne.com';
  static const String _stagingBaseUrl = 'https://staging-api.quilacarne.com';
  static const String _prodBaseUrl = 'https://api.quilacarne.com';

  /// Bazowy URL API w zależności od środowiska
  static String get baseUrl {
    if (kReleaseMode) {
      return _prodBaseUrl;
    } else if (kDebugMode) {
      return _devBaseUrl;
    }
    return _stagingBaseUrl;
  }

  /// Timeout dla połączeń HTTP (w sekundach)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  /// Endpointy API
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  
  static const String dishes = '/api/dishes';
  static const String dishesDictionary = '/api/dishes/dictionary';
  static const String dishesAllergens = '/api/dishes/allergens/dictionary';
  
  static const String tables = '/api/tables';
  static const String tablesDictionary = '/api/tables/dictionary';
  
  static const String reservations = '/api/reservations';
  static const String reservationsDictionary = '/api/reservations/dictionary';
  
  static const String orders = '/api/sync/orders';
  static const String orderDictionary = '/api/order/dictionary';
  static const String orderItemDictionary = '/api/order/item/dictionary';
  
  static const String ingredients = '/api/sync/ingredients';
  static const String ingredientsDictionary = '/api/ingredients/dictionary';
  
  static const String reports = '/api/report';
  static const String reservationItemAdd = '/api/reservations/item/add';
  static const String reservationItemRemove = '/api/reservations/item/remove';
  static const String reservationAbsent = '/api/reservations/{token}/absent';
  
  static const String syncBootstrap = '/api/sync/bootstrap';
  static const String syncUsers = '/api/sync/users';
  static const String syncTables = '/api/sync/tables';
  static const String syncReservations = '/api/sync/reservations';
  static const String syncOrders = '/api/sync/orders';
  static const String syncOrderItems = '/api/sync/order-items';
  static const String syncDishes = '/api/sync/dishes';
  static const String syncIngredients = '/api/sync/ingredients';
  static const String syncReports = '/api/sync/reports';
  static const String syncRoles = '/api/sync/roles';
  static const String syncDictionaries = '/api/sync/dictionaries';
  static const String syncBans = '/api/sync/bans';

  /// Domyślny język aplikacji
  static const String defaultLanguage = 'pl';
  
  /// Dostępne języki
  static const List<String> supportedLanguages = ['pl', 'en'];

  /// Paginacja - domyślne wartości
  static const int defaultPageSize = 50;
  static const int defaultPageNumber = 1;

  /// Limit retry dla operacji offline
  static const int maxRetryAttempts = 5;
  
  /// Czas oczekiwania między retry (w sekundach)
  static const int retryDelaySeconds = 5;
}
