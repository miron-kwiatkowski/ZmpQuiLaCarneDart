import 'package:injectable/injectable.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:async';
import 'dart:convert';

import '../../../core/config/api_config.dart';
import '../../../core/network/auth_token_provider.dart';
import '../domain/models/websocket_event.dart';

/// WebSocket service configuration
@lazySingleton
class WebSocketConfig {
  String get wsUrl => ApiConfig.baseUrl.replaceFirst('http', 'ws');
  String get wsEndpoint => '/ws-qlc';
  
  Duration get reconnectDelay => const Duration(seconds: 3);
  Duration get heartbeat => const Duration(seconds: 10);
  int get maxReconnectAttempts => 5;
}

/// Abstract interface for WebSocket event handlers
abstract class WSEventHandler<T> {
  String get topic;
  WSEntityType get entityType;
  Future<void> handleEvent(WebSocketEvent<T> event);
}

/// Main WebSocket service using STOMP protocol
@lazySingleton
class WebSocketService {
  final WebSocketConfig config;
  final AuthTokenProvider authTokenProvider;
  
  StompClient? _client;
  WSConnectionState _connectionState = WSConnectionState.disconnected;
  final Map<String, List<dynamic>> _subscriptions = {};
  final StreamController<WSConnectionState> _connectionStateController = 
      StreamController<WSConnectionState>.broadcast();
  final StreamController<WebSocketEvent> _eventController = 
      StreamController<WebSocketEvent>.broadcast();
  
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  WebSocketService(this.config, this.authTokenProvider);

  /// Current connection state
  WSConnectionState get connectionState => _connectionState;
  
  /// Stream of connection state changes
  Stream<WSConnectionState> get connectionStateStream => 
      _connectionStateController.stream;
  
  /// Stream of all WebSocket events
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  /// Connect to WebSocket server with JWT authentication
  Future<void> connect() async {
    if (_connectionState == WSConnectionState.connected || 
        _connectionState == WSConnectionState.connecting) {
      return;
    }

    _updateConnectionState(WSConnectionState.connecting);

    try {
      final token = await authTokenProvider.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      _client = StompClient(
        config: StompConfig(
          url: '${config.wsUrl}${config.wsEndpoint}',
          onConnect: _onConnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          onDisconnect: _onDisconnect,
          onReconnect: _onReconnect,
          reconnectDelay: config.reconnectDelay,
          heartbeatIncoming: config.heartbeat,
          heartbeatOutgoing: config.heartbeat,
          beforeConnect: () async {
            final newToken = await authTokenProvider.getAccessToken();
            return {'Authorization': 'Bearer $newToken'};
          },
        ),
      );

      _client!.activate();
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket connected');
    _reconnectAttempts = 0;
    _updateConnectionState(WSConnectionState.connected);
    
    // Re-subscribe to all topics after reconnection
    _resubscribeAll();
  }

  void _onStompError(StompFrame frame) {
    print('STOMP error: ${frame.body}');
    _handleConnectionError(frame.body);
  }

  void _onWebSocketError(dynamic error) {
    print('WebSocket error: $error');
    _handleConnectionError(error);
  }

  void _onDisconnect(StompFrame frame) {
    print('WebSocket disconnected');
    _updateConnectionState(WSConnectionState.disconnected);
  }

  void _onReconnect() {
    print('Attempting to reconnect...');
    _updateConnectionState(WSConnectionState.reconnecting);
  }

  void _handleConnectionError(dynamic error) {
    _reconnectAttempts++;
    if (_reconnectAttempts >= config.maxReconnectAttempts) {
      _updateConnectionState(WSConnectionState.error);
      print('Max reconnect attempts reached');
      return;
    }

    _updateConnectionState(WSConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(config.reconnectDelay, () {
      connect();
    });
  }

  /// Subscribe to a topic with a custom handler
  void subscribe<T>(WSEventHandler<T> handler) {
    if (_client == null || !_client!.active) {
      print('Cannot subscribe: not connected');
      return;
    }

    final subscription = _client!.subscribe(
      destination: handler.topic,
      callback: (frame) {
        _handleMessage(frame.body, handler);
      },
    );

    _subscriptions.putIfAbsent(handler.topic, () => []);
    _subscriptions[handler.topic]!.add(handler);
    
    print('Subscribed to ${handler.topic}');
  }

  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    _subscriptions.remove(topic);
    print('Unsubscribed from $topic');
  }

  void _handleMessage<T>(String? body, WSEventHandler<T> handler) {
    if (body == null) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final event = WebSocketEvent.fromJson(json, null);
      
      // Emit to global event stream
      _eventController.add(event);
      
      // Call specific handler
      handler.handleEvent(event);
      
      print('Received event: ${event.eventType} ${event.entityType} (${event.token})');
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _resubscribeAll() {
    // Re-subscription will be handled by individual cubits
    // when they detect connection state change
    print('Ready to resubscribe to ${_subscriptions.keys.length} topics');
  }

  void _updateConnectionState(WSConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _client?.deactivate();
    _client = null;
    _subscriptions.clear();
    _updateConnectionState(WSConnectionState.disconnected);
    print('WebSocket disconnected');
  }

  /// Check if connected
  bool get isConnected => 
      _connectionState == WSConnectionState.connected && 
      _client != null && 
      _client!.active;
}
