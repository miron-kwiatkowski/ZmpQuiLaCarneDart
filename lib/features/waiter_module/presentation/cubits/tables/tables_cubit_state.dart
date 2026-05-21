part of 'tables_cubit_export.dart';

/// Stany dla TablesCubit
/// 
/// Wzorzec: State Pattern z flutter_bloc
/// Dlaczego: Immutable stany zapewniają przewidywalność
/// i ułatwiają debugowanie zmian stanu w aplikacji
abstract class TablesState extends Equatable {
  const TablesState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy - ładowanie danych
class TablesLoading extends TablesState {
  const TablesLoading();
}

/// Stan z załadowaną listą stolików
class TablesLoaded extends TablesState {
  final List<TableEntity> tables;
  final String? filter;

  const TablesLoaded({required this.tables, this.filter});

  @override
  List<Object?> get props => [tables, filter];

  /// Filtruje stoliki po statusie
  TablesLoaded copyWithFilter(String? newFilter) {
    if (newFilter == null) {
      return TablesLoaded(tables: tables);
    }
    
    final filteredTables = tables.where((table) {
      switch (newFilter) {
        case 'available':
          return table.isAvailable;
        case 'occupied':
          return table.isOccupied;
        case 'reserved':
          return table.isReserved;
        case 'cleaning':
          return table.requiresCleaning;
        case 'out_of_service':
          return table.isOutOfService;
        default:
          return true;
      }
    }).toList();

    return TablesLoaded(tables: filteredTables, filter: newFilter);
  }
}

/// Stan błędu
class TablesError extends TablesState {
  final Failure failure;

  const TablesError(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Stan aktualizacji statusu stolika (w trakcie)
class TableStatusUpdating extends TablesState {
  final String tableToken;

  const TableStatusUpdating(this.tableToken);

  @override
  List<Object?> get props => [tableToken];
}

/// Stan sukcesu aktualizacji statusu
class TableStatusUpdated extends TablesState {
  final String tableToken;
  final String newStatus;

  const TableStatusUpdated({
    required this.tableToken,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [tableToken, newStatus];
}
