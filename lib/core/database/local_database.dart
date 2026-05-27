import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/waiter_module/data/models/isar_models.dart';

part 'local_database.g.dart';

/// Główna klasa bazy danych Isar
///
/// Wzorzec: Database Singleton Pattern
/// Dlaczego: Isar wymaga inicjalizacji przy starcie aplikacji,
/// singleton zapewnia dostęp do tej samej instancji w całym app
class LocalDatabase {
  static Isar? _isar;
  static const String _dbName = 'quilacarne_db';

  /// Inicjalizacja bazy danych
  static Future<void> initialize() async {
    if (_isar != null && _isar!.isOpen) return;

    // Pobranie katalogu dla bazy danych (wymagane na platformach mobilnych)
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open([
      // Waiter Module Models (z isar_models.dart)
      IsarTableSchema,
      IsarDishSchema,
      IsarOrderSchema,
      IsarReservationSchema,
      IsarGuestReportSchema,
      IsarQueuedOperationSchema,
      // Sync & Dictionary Models (zdefiniowane poniżej)
      IsarSyncMetadataSchema,
      IsarUserSchema,
      IsarIngredientSchema,
      IsarAllergenSchema,
      IsarDictionaryEntrySchema,
    ], directory: dir.path, name: _dbName);
  }

  /// Pobierz instancję Isar
  static Isar get instance {
    if (_isar == null) {
      throw Exception("LocalDatabase not initialized. Call initialize() first.");
    }
    return _isar!;
  }

  /// Wyczyść całą bazę danych (np. przy wylogowaniu)
  static Future<void> clear() async {
    final isar = instance;
    await isar.writeTxn(() async {
      // Waiter module data
      await isar.isarTables.clear();
      await isar.isarDishs.clear(); // Isar pluralizuje Dish jako Dishs domyślnie
      await isar.isarOrders.clear();
      await isar.isarReservations.clear();
      await isar.isarGuestReports.clear();
      
      // Queue operations (zachowujemy do synchronizacji po ponownym logowaniu)
      // await isar.isarQueuedOperations.clear();
      
      // Sync & dictionary data
      await isar.isarSyncMetadatas.clear();
      await isar.isarUsers.clear();
      await isar.isarIngredients.clear();
      await isar.isarAllergens.clear();
      await isar.isarDictionaryEntrys.clear();
    });
  }

  /// Zamknij bazę danych
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Sprawdź czy baza jest zainicjalizowana
  static bool get isInitialized => _isar?.isOpen ?? false;
}

/// Metadane synchronizacji - przechowuje informacje o ostatniej synchronizacji
@collection
class IsarSyncMetadata {
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
class IsarUser {
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

/// Składnik dania
@collection
class IsarIngredient {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String namePl;
  late String nameEn;
  late String? description;
}

/// Alergen
@collection
class IsarAllergen {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String token;

  late String namePl;
  late String nameEn;
  late String? symbol; // np. "A", "B" dla oznaczeń na menu
}

/// Wpis słownika (statusy, kategorie, itp.)
@collection
class IsarDictionaryEntry {
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
