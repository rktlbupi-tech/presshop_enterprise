class SocketEvents {
  SocketEvents._();

  // ── Chat namespace (/chat-v2) ────────────────────────────
  static const String sendMessage = 'send-message';
  static const String receiveMessage = 'receive-message';
  static const String messageRead = 'message-read';
  static const String userTyping = 'user-typing';
  static const String userStoppedTyping = 'user-stopped-typing';
  static const String userOnline = 'user-online';
  static const String userOffline = 'user-offline';
  static const String joinRoom = 'join-room';
  static const String leaveRoom = 'leave-room';
  static const String messageDeleted = 'message-deleted';
  static const String messageEdited = 'message-edited';

  // ── Live / Enterprise namespace (/enterprise-live) ───────
  static const String locationUpdate = 'location-update';
  static const String heatmapUpdate = 'heatmap-update';
  static const String sosAlert = 'sos-alert';
  static const String sosStopped = 'sos-stopped';
  static const String emergencyBroadcast = 'emergency-broadcast';
  static const String workerStatus = 'worker-status';
  static const String workerJoined = 'worker-joined';
  static const String workerLeft = 'worker-left';

  // ── System (both namespaces) ─────────────────────────────
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connect_error';
  static const String reconnect = 'reconnect';
  static const String reconnecting = 'reconnecting';
  static const String reconnectFailed = 'reconnect_failed';
}
