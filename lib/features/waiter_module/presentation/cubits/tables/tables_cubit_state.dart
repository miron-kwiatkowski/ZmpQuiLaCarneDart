part of 'tables_cubit_export.dart';

/// Stany dla TablesCubit
abstract class TablesState extends Equatable {
  const TablesState();

  @override
  List<Object?> get props => [];
}

class TablesInitial extends TablesState {
  const TablesInitial();
}

class TablesLoading extends TablesState {
  const TablesLoading();
}

class TablesLoaded extends TablesState {
  final List<TableEntity> tables;
  final String? filter;

  const TablesLoaded({required this.tables, this.filter});

  @override
  List<Object?> get props => [tables, filter];
  
  // Pomocnicze gettery dla UI
  List<TableEntity> get availableTables => 
      tables.where((t) => t.isAvailable).toList();
      
  List<TableEntity> get occupiedTables => 
      tables.where((t) => t.isOccupied).toList();
      
  List<TableEntity> get reservedTables => 
      tables.where((t) => t.isReserved).toList();
      
  List<TableEntity> get cleaningTables => 
      tables.where((t) => t.requiresCleaning).toList();
      
  List<TableEntity> get outOfServiceTables => 
      tables.where((t) => t.isOutOfService).toList();

  TablesLoaded copyWith({List<TableEntity>? tables, String? filter}) {
    return TablesLoaded(
      tables: tables ?? this.tables,
      filter: filter ?? this.filter,
    );
  }

  TablesLoaded copyWithFilter(String? filter) {
    return TablesLoaded(
      tables: tables,
      filter: filter,
    );
  }
}

class TableStatusUpdating extends TablesState {
  final String tableToken;
  const TableStatusUpdating(this.tableToken);

  @override
  List<Object?> get props => [tableToken];
}

class TableStatusUpdated extends TablesState {
  final String tableToken;
  final String newStatus;
  const TableStatusUpdated({required this.tableToken, required this.newStatus});

  @override
  List<Object?> get props => [tableToken, newStatus];
}

class TablesError extends TablesState {
  final Failure failure;

  const TablesError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
