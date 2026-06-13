import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'socket_events.dart';

class SocketClient {
  final String url;
  final String name;

  io.Socket? _socket;

  SocketClient({required this.url, required this.name});

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(-1)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.on(SocketEvents.connect, (_) {
      _log('Connected [${_socket?.id}]');
    });

    _socket!.on(SocketEvents.disconnect, (reason) {
      _log('Disconnected [$reason]');
    });

    _socket!.on(SocketEvents.connectError, (error) {
      _log('Connection Error [$error]');
    });

    _socket!.on(SocketEvents.reconnect, (attempt) {
      _log('Reconnected after $attempt attempt(s)');
    });

    _socket!.connect();
  }

  void emit(String event, dynamic data) {
    if (!isConnected) {
      _log('Cannot emit [$event] — not connected');
      return;
    }
    _log('Emit [$event]');
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _log('Disconnected and disposed');
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[$name Socket] $message');
    }
  }
}
