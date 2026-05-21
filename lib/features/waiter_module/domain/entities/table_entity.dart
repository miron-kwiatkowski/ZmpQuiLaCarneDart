import 'package:equatable/equatable.dart';

/// Encja domenowa stolika (Domain Layer)
/// 
/// Czysty obiekt biznesowy bez zależności technicznych.
/// Nie zawiera annotacji JSON, ID bazy danych, ani innych
/// zależności od frameworków.
class TableEntity extends Equatable {
  /// Unikalny token stolika (identyfikator biznesowy)
  final String token;
  
  /// Token statusu stolika (AVAILABLE, OCCUPIED, RESERVED, CLEANING, OUT_OF_SERVICE)
  final String statusToken;
  
  /// Liczba miejsc przy stoliku
  final int? seats;
  
  /// Numer stolika do wyświetlania
  final String tableNumber;
  
  /// Opis lokalizacji (opcjonalnie)
  final String? locationDescription;
  
  const TableEntity({
    required this.token,
    required this.statusToken,
    this.seats,
    required this.tableNumber,
    this.locationDescription,
  });
  
  /// Czy stolik jest wolny i dostępny dla gości
  bool get isAvailable => statusToken == 'AVAILABLE';
  
  /// Czy stolik jest zajęty przez gości
  bool get isOccupied => statusToken == 'OCCUPIED';
  
  /// Czy stolik ma rezerwację
  bool get isReserved => statusToken == 'RESERVED';
  
  /// Czy stolik wymaga sprzątania
  bool get requiresCleaning => statusToken == 'CLEANING';
  
  /// Czy stolik jest uszkodzony/niedostępny
  bool get isOutOfService => statusToken == 'OUT_OF_SERVICE';
  
  @override
  List<Object?> get props => [token, statusToken, seats, tableNumber, locationDescription];
  
  /// Tworzy kopię encji z zmienionym statusem
  TableEntity copyWith({String? statusToken}) {
    return TableEntity(
      token: token,
      statusToken: statusToken ?? this.statusToken,
      seats: seats,
      tableNumber: tableNumber,
      locationDescription: locationDescription,
    );
  }
}
