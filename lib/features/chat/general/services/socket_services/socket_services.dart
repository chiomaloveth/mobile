import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

/// Called when a remote user is calling us.
typedef OnIncomingCall =
    void Function(
      String callerId,
      String callerName,
      bool isVideo,
      String callId,
    );

/// Called when the remote party accepted our outgoing call.
typedef OnCallAccepted = void Function();

/// Called when the remote party rejected our call.
typedef OnCallRejected = void Function(String reason);

/// Called when either side ends the call.
typedef OnCallEnded = void Function();

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect({
    required String token,
    required String userId,
    required String chatId,
    required Function onConnected,
    required Function(dynamic data) onMessageReceived,
    required OnIncomingCall onIncomingCall,
    required OnCallAccepted onCallAccepted,
    required OnCallRejected onCallRejected,
    required OnCallEnded onCallEnded,
  }) {
    // ✅ Always reuse GlobalSocketService socket — never open a second connection.
    socket = GlobalSocketService().socket;

    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ GlobalSocket not ready — waiting for connection');
      GlobalSocketService().connectionStatus
          .firstWhere((s) => s == ConnectionStatus.connected)
          .then((_) {
            socket = GlobalSocketService().socket;
            if (chatId.isNotEmpty) {
              socket?.emit('join chat', chatId);
              debugPrint('🚪 Joined chat after wait: $chatId');
            }
            onConnected();
          });
      return;
    }

    debugPrint('✅ SocketService reusing GlobalSocket: ${socket!.id}');
    if (chatId.isNotEmpty) {
      socket!.emit('join chat', chatId);
      debugPrint('🚪 Joined chat: $chatId');
    }
    onConnected();
  }

  bool get isConnected => socket != null && socket!.connected;

  // ── CHAT HELPERS (unchanged) ────────────────────────────────────────────

  void sendTyping(String chatId) {
    if (!isConnected) return;
    socket?.emit('typing', {'room': chatId, 'chatId': chatId});
  }

  void stopTyping(String chatId) {
    if (!isConnected) return;
    socket?.emit('stop typing', {'room': chatId, 'chatId': chatId});
  }

  void leaveChat(String chatId) {
    if (!isConnected) return;
    socket?.emit('leave chat', chatId);
  }

  // ── CALL SIGNALING ──────────────────────────────────────────────────────
  // NOTE: callUser() no longer sends SDP. It only alerts the backend so it
  // can emit 'incoming call' to the receiver. The LiveKit token was already
  // obtained from POST /api/v1/call/start before this is called.

  /// Alert the receiver that we're calling.
  void callUser({
    required String userToCallId,
    required String myUserId,
    required String myName,
    required bool isVideo,
    required String callId,
  }) {
    if (!isConnected) {
      debugPrint('❌ Cannot call user – socket not connected');
      return;
    }
    socket!.emit('call user', {
      'userToCall': userToCallId,
      'from': myUserId,
      'name': myName,
      'type': isVideo ? 'video' : 'audio',
      'callId': callId,
    });
    debugPrint('📤 call user emitted → $userToCallId');
  }

  /// Reject a call.
  void rejectCall({required String toCallerId}) {
    if (!isConnected) return;
    socket!.emit('reject call', {'to': toCallerId});
  }

  /// End a call.
  void endCall({required String toUserId}) {
    if (!isConnected) return;
    socket!.emit('end call', {'to': toUserId});
  }

  /// Notify the other party of a timeout.
  void reportTimeout({required String toUserId}) {
    if (!isConnected) return;
    socket!.emit('call timeout', {'to': toUserId});
  }

  void dispose() {
    // ✅ Do NOT dispose the shared GlobalSocket — just release our reference.
    debugPrint('🧹 SocketService: releasing socket reference (not disposing)');
    socket = null;
  }
}
