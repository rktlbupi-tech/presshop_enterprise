import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MapSocketClient {
  static const String _heatmapUrl =
      'https://dev-api.presshop.news:3005/enterprise-live';

  static io.Socket? _heatmapSocket;
  static io.Socket? get heatmapSocket => _heatmapSocket;

  static io.Socket connectHeatmap(String token) {
    if (_heatmapSocket != null && _heatmapSocket!.connected) {
      return _heatmapSocket!;
    }

    _heatmapSocket = io.io(
      _heatmapUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(-1)
          .setReconnectionDelay(1000)
          .build(),
    );

    _heatmapSocket?.onConnect((_) {
      if (kDebugMode) debugPrint('[MapSocket] Connected [${_heatmapSocket?.id}]');
    });
    _heatmapSocket?.onDisconnect((reason) {
      if (kDebugMode) debugPrint('[MapSocket] Disconnected [$reason]');
    });
    _heatmapSocket?.onConnectError((error) {
      if (kDebugMode) debugPrint('[MapSocket] Error [$error]');
    });

    _heatmapSocket?.connect();
    return _heatmapSocket!;
  }

  static void disconnect() {
    _heatmapSocket?.disconnect();
    _heatmapSocket?.dispose();
    _heatmapSocket = null;
  }
}
