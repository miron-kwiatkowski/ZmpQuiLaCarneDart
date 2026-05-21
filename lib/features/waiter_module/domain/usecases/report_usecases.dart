import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/guest_report_entity.dart';
import '../../domain/repositories/waiter_repository.dart';

/// Use Case do tworzenia zgłoszenia gościa (działa offline)
class CreateGuestReportUseCase {
  final WaiterRepository repository;

  CreateGuestReportUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String clientToken,
    required String reason,
  }) async {
    return await repository.createGuestReport(
      clientToken: clientToken,
      reason: reason,
    );
  }
}

/// Use Case do pobierania listy zgłoszeń
class GetGuestReportsUseCase {
  final WaiterRepository repository;

  GetGuestReportsUseCase(this.repository);

  Future<Either<Failure, List<GuestReportEntity>>> call() async {
    return await repository.getGuestReports();
  }
}
