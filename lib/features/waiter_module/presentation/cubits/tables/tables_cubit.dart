part of 'tables_cubit_export.dart';

/// Cubit do zarządzania stanem stolików
/// 
/// Wzorzec: Cubit Pattern (flutter_bloc)
/// Dlaczego: Lżejsza alternatywa dla BLoC, idealna gdy nie potrzebujemy
/// streamów zdarzeń. Zapewnia czytelne przejścia między stanami.
class TablesCubit extends Cubit<TablesState> {
  final GetTablesUseCase getTablesUseCase;
  final ChangeTableStatusUseCase changeTableStatusUseCase;

  TablesCubit({
    required this.getTablesUseCase,
    required this.changeTableStatusUseCase,
  }) : super(const TablesInitial());

  /// Ładuje listę stolików z repozytorium
  Future<void> loadTables({String? filter}) async {
    emit(const TablesLoading());

    final result = await getTablesUseCase(filter: filter);

    result.fold(
      (failure) => emit(TablesError(failure: failure)),
      (tables) => emit(TablesLoaded(tables: tables, filter: filter)),
    );
  }

  /// Zmienia status stolika
  /// 
  /// Obsługuje zarówno tryb online jak i offline
  /// dzięki WaiterRepository i OfflineQueueManager
  Future<void> changeTableStatus({
    required String tableToken,
    required String newStatus,
  }) async {
    // Emituj stan aktualizacji
    emit(TableStatusUpdating(tableToken));

    final result = await changeTableStatusUseCase(
      tableToken: tableToken,
      newStatus: newStatus,
    );

    result.fold(
      (failure) => emit(TablesError(failure: failure)),
      (_) {
        // Po sukcesie odśwież listę stolików
        final currentState = state;
        if (currentState is TablesLoaded) {
          // Zaktualizuj lokalnie listę bez ponownego pobierania
          final updatedTables = currentState.tables.map((table) {
            if (table.token == tableToken) {
              return table.copyWith(statusToken: newStatus);
            }
            return table;
          }).toList();

          emit(TablesLoaded(
            tables: updatedTables,
            filter: currentState.filter,
          ));
        }
        
        // Emituj też stan sukcesu dla ewentualnych powiadomień UI
        emit(TableStatusUpdated(
          tableToken: tableToken,
          newStatus: newStatus,
        ));
      },
    );
  }

  /// Filtruje załadowaną listę stolików
  void filterTables(String? filter) {
    final currentState = state;
    if (currentState is TablesLoaded) {
      emit(currentState.copyWithFilter(filter));
    }
  }

  /// Odświeża dane z serwerach/bazy lokalnej
  Future<void> refresh() async {
    final currentState = state;
    final currentFilter = currentState is TablesLoaded ? currentState.filter : null;
    await loadTables(filter: currentFilter);
  }
}
