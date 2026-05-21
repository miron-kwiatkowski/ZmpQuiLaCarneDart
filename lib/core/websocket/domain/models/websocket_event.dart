import 'package:equatable/equatable.dart';

/// Base envelope for all WebSocket events
/// Format zgodny z dokumentacją API:
/// {
///   "eventType": "CREATED | UPDATED | DELETED",
///   "entityType": "STRING",
///   "token": "STRING",
///   "payload": {},
///   "timestamp": "2026-05-13T12:34:56Z"
/// }
class WebSocketEvent<T> extends Equatable {
  final String eventType;
  final String entityType;
  final String token;
  final T? payload;
  final DateTime timestamp;

  const WebSocketEvent({
    required this.eventType,
    required this.entityType,
    required this.token,
    this.payload,
    required this.timestamp,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json, T? payload) {
    return WebSocketEvent(
      eventType: json['eventType'] as String,
      entityType: json['entityType'] as String,
      token: json['token'] as String,
      payload: payload,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'entityType': entityType,
      'token': token,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [eventType, entityType, token, payload, timestamp];

  @override
  String toString() {
    return 'WebSocketEvent(eventType: $eventType, entityType: $entityType, token: $token, timestamp: $timestamp)';
  }
}

/// Event types as defined in API documentation
enum WSEventType {
  created('CREATED'),
  updated('UPDATED'),
  deleted('DELETED');

  final String value;
  const WSEventType(this.value);

  static WSEventType fromString(String value) {
    return WSEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown event type: $value'),
    );
  }
}

/// Entity types supported by WebSocket
enum WSEntityType {
  report('REPORT'),
  allergen('ALLERGEN'),
  table('TABLE'),
  tableStatus('TABLE_STATUS'),
  ingredient('INGREDIENT'),
  dishCategory('DISH_CATEGORY'),
  dish('DISH'),
  order('ORDER'),
  orderItem('ORDER_ITEM'),
  orderStatus('ORDER_STATUS'),
  orderItemStatus('ORDER_ITEM_STATUS'),
  reservation('RESERVATION'),
  employee('EMPLOYEE'),
  ban('BAN');

  final String value;
  const WSEntityType(this.value);

  static WSEntityType fromString(String value) {
    return WSEntityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown entity type: $value'),
    );
  }
}

/// WebSocket connection states
enum WSConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}
