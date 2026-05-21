import 'package:equatable/equatable.dart';

/// Encja domenowa zgłoszenia gościa (Domain Layer)
/// 
/// Reprezentuje zgłoszenie incydentu dotyczącego gościa.
/// Używane przez kelnerów do raportowania problemów.
class GuestReportEntity extends Equatable {
  /// Unikalny token zgłoszenia
  final String? token; // Null dla nowych, offline zgłoszeń
  
  /// Token zgłaszanego klienta
  final String clientToken;
  
  /// Powód zgłoszenia (opis incydentu)
  final String reason;
  
  /// Token statusu zgłoszenia (IN_PROGRESS, RESOLVED, ESCALATED)
  final String statusToken;
  
  /// Token użytkownika który utworzył zgłoszenie (kelner/manager)
  final String? reporterToken;
  
  /// Data utworzenia zgłoszenia
  final DateTime createdAt;
  
  /// Data ostatniej modyfikacji
  final DateTime? updatedAt;
  
  /// Czy zgłoszenie zostało utworzone offline
  final bool isOfflineCreated;
  
  const GuestReportEntity({
    this.token,
    required this.clientToken,
    required this.reason,
    required this.statusToken,
    this.reporterToken,
    required this.createdAt,
    this.updatedAt,
    this.isOfflineCreated = false,
  });
  
  @override
  List<Object?> get props => [
        token,
        clientToken,
        reason,
        statusToken,
        reporterToken,
        createdAt,
        updatedAt,
        isOfflineCreated,
      ];
  
  /// Tworzy kopię encji z zmienionymi polami
  GuestReportEntity copyWith({
    String? token,
    String? clientToken,
    String? reason,
    String? statusToken,
    String? reporterToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOfflineCreated,
  }) {
    return GuestReportEntity(
      token: token ?? this.token,
      clientToken: clientToken ?? this.clientToken,
      reason: reason ?? this.reason,
      statusToken: statusToken ?? this.statusToken,
      reporterToken: reporterToken ?? this.reporterToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOfflineCreated: isOfflineCreated ?? this.isOfflineCreated,
    );
  }
}
