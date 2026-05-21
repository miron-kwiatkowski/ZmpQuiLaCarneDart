part of 'reports_cubit_export.dart';

// Importy dla Failure
import '../../../../core/error/failure.dart';

/// Stany dla ReportsCubit
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

/// Stan przesyłania zgłoszenia
class ReportsSubmitting extends ReportsState {
  const ReportsSubmitting();
}

/// Stan sukcesu - zgłoszenie utworzone
class ReportCreated extends ReportsState {
  const ReportCreated();
}

/// Stan błędu
class ReportsError extends ReportsState {
  final Failure failure;

  const ReportsError(this.failure);

  @override
  List<Object?> get props => [failure];
}
