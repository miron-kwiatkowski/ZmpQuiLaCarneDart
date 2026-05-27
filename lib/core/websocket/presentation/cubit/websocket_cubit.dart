import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:quilacarne_waiter/core/websocket/domain/models/websocket_event.dart';
import 'package:quilacarne_waiter/core/websocket/data/services/websocket_service.dart';
import 'package:quilacarne_waiter/core/websocket/data/handlers/websocket_handlers.dart';

// States
abstract class WebSocketState extends Equatable {
  const WebSocketState();

  @override
  List<Object?> get props => [];
}

class WebSocketInitial extends WebSocketState {
  const WebSocketInitial();
}

class WebSocketConnecting extends WebSocketState {
  const WebSocketConnecting();
}

class WebSocketConnected extends WebSocketState {
  const WebSocketConnected();
}

class WebSocketDisconnected extends WebSocketState {
  const WebSocketDisconnected();
}

class WebSocketError extends WebSocketState {
  final String message;
  
  const WebSocketError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Events
abstract class WebSocketEventAction extends Equatable {
  const WebSocketEventAction();

  @override
  List<Object?> get props => [];
}

class WebSocketConnect extends WebSocketEventAction {
  const WebSocketConnect();
}

class WebSocketDisconnect extends WebSocketEventAction {
  const WebSocketDisconnect();
}

class WebSocketReconnect extends WebSocketEventAction {
  const WebSocketReconnect();
}

class WebSocketSubscribeToTables extends WebSocketEventAction {
  const WebSocketSubscribeToTables();
}

class WebSocketSubscribeToOrders extends WebSocketEventAction {
  const WebSocketSubscribeToOrders();
}

class WebSocketSubscribeToReservations extends WebSocketEventAction {
  const WebSocketSubscribeToReservations();
}

class WebSocketSubscribeToDishes extends WebSocketEventAction {
  const WebSocketSubscribeToDishes();
}

class WebSocketSubscribeToReports extends WebSocketEventAction {
  const WebSocketSubscribeToReports();
}

// Cubit
@injectable
class WebSocketCubit extends Cubit<WebSocketState> {
  final WebSocketService _webSocketService;
  
  WebSocketCubit(this._webSocketService) : super(const WebSocketInitial());

  /// Initialize WebSocket connection
  Future<void> initialize() async {
    try {
      await _webSocketService.connect();
      
      // Listen to connection state changes
      _webSocketService.connectionStateStream.listen((state) {
        _onConnectionStateChange(state);
      });
    } catch (e) {
      emit(WebSocketError(e.toString()));
    }
  }

  void _onConnectionStateChange(WSConnectionState state) {
    switch (state) {
      case WSConnectionState.connecting:
        emit(const WebSocketConnecting());
        break;
      case WSConnectionState.connected:
        emit(const WebSocketConnected());
        break;
      case WSConnectionState.disconnected:
        emit(const WebSocketDisconnected());
        break;
      case WSConnectionState.reconnecting:
        emit(const WebSocketConnecting());
        break;
      case WSConnectionState.error:
        emit(const WebSocketError('Connection error'));
        break;
    }
  }

  /// Subscribe to all waiter-relevant topics
  void subscribeToAllWaiterTopics() {
    subscribeToTables();
    subscribeToOrders();
    subscribeToReservations();
    subscribeToDishes();
    subscribeToReports();
  }

  /// Subscribe to table updates
  void subscribeToTables() {
    if (_webSocketService.isConnected) {
      _webSocketService.subscribe(TableWSHandler((event) {
        // Handle table update - will be consumed by TablesCubit
        print('Table event received: ${event.eventType} for ${event.token}');
      }));
    }
  }

  /// Subscribe to order updates
  void subscribeToOrders() {
    if (_webSocketService.isConnected) {
      _webSocketService.subscribe(OrderWSHandler((event) {
        // Handle order update - will be consumed by OrdersCubit
        print('Order event received: ${event.eventType} for ${event.token}');
      }));
      
      _webSocketService.subscribe(OrderItemWSHandler((event) {
        // Handle order item update
        print('Order item event received: ${event.eventType} for ${event.token}');
      }));
    }
  }

  /// Subscribe to reservation updates
  void subscribeToReservations() {
    if (_webSocketService.isConnected) {
      _webSocketService.subscribe(ReservationWSHandler((event) {
        // Handle reservation update - will be consumed by ReservationsCubit
        print('Reservation event received: ${event.eventType} for ${event.token}');
      }));
    }
  }

  /// Subscribe to dish/menu updates
  void subscribeToDishes() {
    if (_webSocketService.isConnected) {
      _webSocketService.subscribe(DishWSHandler((event) {
        // Handle dish update - will be consumed by DishesCubit
        print('Dish event received: ${event.eventType} for ${event.token}');
      }));
      
      _webSocketService.subscribe(IngredientAvailabilityWSHandler((event) {
        // Handle ingredient availability change
        print('Ingredient availability event: ${event.eventType}');
      }));
    }
  }

  /// Subscribe to report updates
  void subscribeToReports() {
    if (_webSocketService.isConnected) {
      _webSocketService.subscribe(ReportWSHandler((event) {
        // Handle report update - will be consumed by ReportsCubit
        print('Report event received: ${event.eventType} for ${event.token}');
      }));
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
    emit(const WebSocketDisconnected());
  }

  /// Reconnect to WebSocket
  Future<void> reconnect() async {
    emit(const WebSocketConnecting());
    await _webSocketService.connect();
  }

  /// Check if connected
  bool get isConnected => _webSocketService.isConnected;
  
  /// Get connection state stream
  Stream<WSConnectionState> get connectionStateStream => 
      _webSocketService.connectionStateStream;
  
  /// Get global event stream
  Stream<WebSocketEvent> get eventStream => _webSocketService.eventStream;
}
