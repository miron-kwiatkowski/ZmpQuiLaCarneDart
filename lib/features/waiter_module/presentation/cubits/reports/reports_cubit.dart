part of 'reports_cubit_export.dart';

/// Cubit do zarządzania zgłoszeniami gości
///
/// Wzorzec: Cubit Pattern (flutter_bloc)
/// Dlaczego: Zarządzanie stanem zgłoszeń z obsługą offline
class ReportsCubit extends Cubit<ReportsState> {
  final CreateGuestReportUseCase createReportUseCase;

  ReportsCubit({required this.createReportUseCase}) : super(const ReportsInitial());

  /// Tworzy zgłoszenie gościa (działa offline!)
  Future<void> createReport({
    required String clientToken,
    required String reason,
  }) async {
    emit(const ReportsSubmitting());

    // Walidacja długości powodu (10-500 znaków zgodnie z API)
    if (reason.length < 10 || reason.length > 500) {
      emit(const ReportsError(
        ValidationFailure(
          message: 'Powód musi mieć od 10 do 500 znaków',
        ),
      ));
      return;
    }

    final result = await createReportUseCase(
      clientToken: clientToken,
      reason: reason,
    );

    result.fold(
      (failure) => emit(ReportsError(failure)),
      (_) {
        emit(const ReportCreated());
      },
    );
  }

  /// Resetuje stan cubita
  void reset() {
    emit(const ReportsInitial());
  }
}
