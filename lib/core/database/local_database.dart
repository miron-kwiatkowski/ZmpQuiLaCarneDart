import 'package:isar/isar.dart';
import '../../features/waiter_module/data/models/isar_models.dart';

part 'local_database.g.dart';

/// Główna klasa bazy danych Isar
///
/// Wzorzec: Database Singleton Pattern
/// Dlaczego: Isar wymaga inicjalizacji przy starcie aplikacji,
/// singleton zapewnia dostęp do tej samej instancji w całym app
class LocalDatabase {
  static late Isar _isar;
  static const String _dbName = 'quilacarne_db';

  /// Inicjalizacja bazy danych
  static Future<void> initialize() async {
    if (Isar.instanceNames.isEmpty) {
      _isar = await Isar.open([
        // Waiter Module Models
        IsarTableSchema,
        IsarDishSchema,
        IsarOrderSchema,
        IsarOrderItemSchema,
        IsarReservationSchema,
        IsarGuestReportSchema,
        IsarQueuedOperationSchema,
        // Sync & Dictionary Models
        SyncMetadataSchema,
        UserEntitySchema,
        IngredientEntitySchema,
        AllergenEntitySchema,
        DictionaryEntrySchema,
      ], name: _dbName);
    }
  }

  /// Pobierz instancję Isar
  static Isar get instance => _isar;

  /// Wyczyść całą bazę danych (np. przy wylogowaniu)
  static Future<void> clear() async {
    await _isar.writeTxn(() async {
      // Waiter module data
      await _isar.isarTables.clear();
      await _isar.isarDishes.clear();
      await _isar.isarOrders.clear();
      await _isar.isarReservations.clear();
      await _isar.isarGuestReports.clear();
      // Queue operations (zachowujemy do synchronizacji po ponownym logowaniu)
      // await _isar.isarQueuedOperations.clear();
      // Sync & dictionary data
      await _isar.syncMetadata.clear();
      await _isar.userEntities.clear();
      await _isar.ingredientEntities.clear();
      await _isar.allergenEntities.clear();
      await _isar.dictionaryEntries.clear();
    });
  }

  /// Zamknij bazę danych
  static Future<void> close() async {
    await _isar.close();
  }

  /// Sprawdź czy baza jest zainicjalizowana
  static bool get isInitialized => _isar.isOpen;
}

/// Metadane synchronizacji - przechowuje informacje o ostatniej synchronizacji
@collection
class SyncMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String moduleName; // np. 'tables', 'dishes', 'orders'

  late int lastSyncPage;
  late DateTime lastSyncTime;
  late int totalRecords;
  late int totalPages;
  late bool isComplete; // Czy wszystkie strony zostały pobrane
}

/// Użytkownik systemu
@collection
class UserEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token; // Unikalny identyfikator użytkownika

  late String username;
  late String? email;
  late String? firstName;
  late String? lastName;
  late String roleToken;
  late bool isStaff;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
}

/// Rezerwacja stolika (dodatkowa encja dla sync)
@collection
class ReservationEntity {
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
  late double totalPrice;

  late String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Relacje
  @Backlink(to: 'reservation')
  final orderItems = IsarLinks<OrderItemEntity>();
}

/// Składnik dania
@collection
class IngredientEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String namePl;
  late String nameEn;
  late String? description;
}

/// Alergen
@collection
class AllergenEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String namePl;
  late String nameEn;
  late String? symbol; // np. "A", "B" dla oznaczeń na menu
}

/// Wpis słownika (statusy, kategorie, itp.)
@collection
class DictionaryEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String key; // np. 'table_status:AVAILABLE'

  late String type; // np. 'tableStatus', 'orderStatus'
  late String token;
  late String namePl;
  late String nameEn;
  late String? color; // Kolor hex dla UI
  late String? icon; // Ikona dla UI
}
