import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/waiter_repository.dart';

/// Use Case do pobierania listy stolików
class GetTablesUseCase {
  final WaiterRepository repository;

  GetTablesUseCase(this.repository);

  Future<Either<Failure, List<TableEntity>>> call({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    return await repository.getTables(
      startTime: startTime,
      endTime: endTime,
    );
  }
}

/// Use Case do zmiany statusu stolika
class ChangeTableStatusUseCase {
  final WaiterRepository repository;

  ChangeTableStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String tableToken,
    required String newStatus,
  }) async {
    return await repository.changeTableStatus(
      tableToken: tableToken,
      newStatus: newStatus,
    );
  }
}

/// Use Case do przypisania kelnera do rezerwacji
class AssignWaiterUseCase {
  final WaiterRepository repository;

  AssignWaiterUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String reservationToken,
  }) async {
    return await repository.assignWaiter(reservationToken: reservationToken);
  }
}

/// Use Case do oznaczenia rezerwacji jako nieobecny (no-show)
class MarkAbsentUseCase {
  final WaiterRepository repository;

  MarkAbsentUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String reservationToken,
  }) async {
    return await repository.markAbsent(reservationToken: reservationToken);
  }
}
