import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/general/services/chat_cache_sync_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'offline_message_queue.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

class GlobalSocketService {
  static final GlobalSocketService _instance = GlobalSocketService._internal();
  factory GlobalSocketService() => _instance;
  GlobalSocketService._internal();

  IO.Socket? _socket;

  final _chatListUpdateController = StreamController<void>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  final _messageReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _incomingCallController =
      StreamController<Map<String, dynamic>>.broadcast();
  // ✅ Broadcasts {userId, username} every time a contact comes online
  final _userOnlineController =
      StreamController<Map<String, dynamic>>.broadcast();

  // ── BROADCAST CONTROLLERS ──────────────────────────────────────────────────
  final broadcastMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final messageDeliveredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final messagesReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final broadcastMembersController =
      StreamController<Map<String, dynamic>>.broadcast();
  final broadcastDeletedController = StreamController<String>.broadcast();
  final broadcastUpdatedController = StreamController<dynamic>.broadcast();
  final broadcastMemberJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final broadcastMemberLeftController =
      StreamController<Map<String, dynamic>>.broadcast();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  Timer? _reconnectTimer;
  bool _isManualDisconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 15;
  bool _isSetupEmitted = false;
  bool _isConnecting = false; // ✅ guard against concurrent connect() calls
  bool _listenersAttached =
      false; // ✅ guard against multiple listener registrations

  // ── Getters ────────────────────────────────────────────────────────────────
  Stream<void> get chatListUpdates => _chatListUpdateController.stream;
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get messageReceived =>
      _messageReceivedController.stream;
  Stream<Map<String, dynamic>> get incomingCallStream =>
      _incomingCallController.stream;

  /// Emits {userId, username} — consumed by OnlinePresenceNotificationService
  Stream<Map<String, dynamic>> get userOnlineStream =>
      _userOnlineController.stream;

  IO.Socket? get socket => _socket;
  ConnectionStatus get status => _status;
  bool get isConnected => _socket?.connected ?? false;

  // ── connect ────────────────────────────────────────────────────────────────
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('✅ Socket already connected');
      return;
    }

    // ✅ Prevent concurrent connect() calls that create duplicate sockets
    if (_isConnecting) {
      debugPrint('⚠️ Socket already connecting — skipping duplicate call');
      return;
    }

    _isManualDisconnect = false;
    _isConnecting = true;
    _updateStatus(ConnectionStatus.connecting);

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final userId = await SaveValues().getString(AppPreferenceHelper.ID);

      if (token == null || token.isEmpty) {
        debugPrint('❌ No auth token — cannot connect socket');
        _updateStatus(ConnectionStatus.disconnected);
        return;
      }

      debugPrint('🔌 Connecting socket... userId: $userId');

      _socket = IO.io(
        AppConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token, 'userId': userId})
            .setExtraHeaders({'Authorization': 'Bearer $token', 'userid': userId ?? ''})
            .setQuery({'token': token, 'userId': userId})
            .enableAutoConnect()
            .disableReconnection() // ✅ manual reconnect only — avoids double loops
            .setTimeout(20000)
            .build(),
      );

      if (!_listenersAttached) {
        _setupSocketListeners();
        _listenersAttached = true;
      }
      _socket?.connect();
    } catch (e) {
      debugPrint('❌ Socket connection error: $e');
      _isConnecting = false;
      _updateStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  // ── listeners ──────────────────────────────────────────────────────────────
  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) async {
      debugPrint('✅ Global socket connected — id: ${_socket!.id}');
      _updateStatus(ConnectionStatus.connected);
      _reconnectTimer?.cancel();
      _reconnectAttempts = 0;
      _isConnecting = false; // ✅ clear connecting guard
      _isSetupEmitted = false; // ✅ always reset on fresh connect

      try {
        final userId = await SaveValues().getString(AppPreferenceHelper.ID);
        if (userId != null && userId.isNotEmpty) {
          _socket?.emit('setup', {'_id': userId});
          _isSetupEmitted = true;
          debugPrint('📤 setup emitted for $userId');
        }
      } catch (e) {
        debugPrint('❌ Error emitting setup: $e');
      }

      processOfflineQueue();
    });

    _socket!.onDisconnect((reason) {
      debugPrint('🔌 Socket disconnected: $reason');
      _isSetupEmitted = false;

      final isServerForced = reason == 'io server disconnect';
      if (_isManualDisconnect) {
        _updateStatus(ConnectionStatus.disconnected);
      } else if (isServerForced) {
        debugPrint('⛔ Server forced disconnect — retrying with backoff');
        _listenersAttached = false; // ✅ reset so reconnect gets fresh listeners
        _isConnecting = false;
        _socket?.dispose();
        _socket = null;
        _updateStatus(ConnectionStatus.disconnected);
        _scheduleReconnect(); // ✅ use exponential backoff + max attempts
      } else {
        _updateStatus(ConnectionStatus.reconnecting);
        _scheduleReconnect();
      }

      // ✅ Only broadcast offline to presence listeners — do NOT emit socket event.
      // The user is still in the app; GlobalSocket owns the online/offline lifecycle.
      SaveValues().getString(AppPreferenceHelper.ID).then((userId) {
        if (userId != null && userId.isNotEmpty) {
          debugPrint('📤 user offline broadcast (local only): $userId');
          _userOnlineController.add({
            'userId': userId,
            'isOnline': false,
            'offline': true,
          });
          _chatListUpdateController.add(null);
        }
      });
    });

    _socket!.onConnectError((error) {
      debugPrint('❌ Connection error: $error');
      final msg = error.toString().toLowerCase();
      if (msg.contains('authentication') ||
          msg.contains('unauthorized') ||
          msg.contains('token')) {
        _updateStatus(ConnectionStatus.disconnected);
        _reconnectTimer?.cancel();
        return;
      }
      _updateStatus(ConnectionStatus.reconnecting);
      _scheduleReconnect();
    });

    _socket!.onError((e) => debugPrint('❌ Socket error: $e'));

    // ── CHAT ─────────────────────────────────────────────────────────────────
    Future<void> handleIncomingMessage(dynamic data) async {
      debugPrint('📨 Global: message received');
      _chatListUpdateController.add(null);

      try {
        if (data is! Map) return;
        final payload = Map<String, dynamic>.from(data as Map);
        final myId = await SaveValues().getString(AppPreferenceHelper.ID);
        final sender = payload['sender'];
        final senderId = sender is Map
            ? (sender['_id'] ?? sender['id'] ?? '').toString()
            : sender?.toString() ?? '';
        final messageId = (payload['_id'] ?? payload['messageId'] ?? '')
            .toString();
        final chatId =
            (payload['chat'] is Map
                    ? payload['chat']['_id']
                    : payload['chat'] ?? payload['chatId'])
                ?.toString();

        if (myId != null && myId.isNotEmpty) {
          await ChatCacheSyncService.upsertSocketMessage(
            rawData: payload,
            myUserId: myId,
          );
        }

        // Acknowledge delivery at the app level even when the chat screen is not
        // open. This is the WhatsApp-like transition from 1 tick (sent to server)
        // to 2 gray ticks (recipient device received it). Read receipts are still
        // emitted only by the message screens after /message/read succeeds.
        if (myId == null ||
            myId.isEmpty ||
            senderId == myId ||
            messageId.isEmpty ||
            chatId == null ||
            chatId.isEmpty) {
          return;
        }
        _socket?.emit('message delivered', {
          'chatId': chatId,
          'messageId': messageId,
          'userId': myId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        debugPrint('📤 Global delivered ack emitted for $messageId');
      } catch (e) {
        debugPrint('❌ Global delivery/cache sync error: $e');
      }
    }

    _socket!.on('message received', handleIncomingMessage);
    _socket!.on('newMessage', handleIncomingMessage);
    _socket!.on('message deleted', (_) => _chatListUpdateController.add(null));
    _socket!.on('message edited', (_) => _chatListUpdateController.add(null));
    void handleDelivered(dynamic data) {
      debugPrint('📦 Global: message delivered');
      if (data is Map) {
        final payload = Map<String, dynamic>.from(data as Map);
        messageDeliveredController.add(payload);
        final chatId = payload['chatId']?.toString();
        final messageIds =
            (payload['messageIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ((payload['messageId'] != null &&
                    payload['messageId'].toString().isNotEmpty)
                ? [payload['messageId'].toString()]
                : null);
        if (chatId != null && chatId.isNotEmpty) {
          ChatCacheSyncService.updateOutgoingMessageStatus(
            chatId,
            MessageStatus.delivered,
            messageIds: messageIds,
          );
        }
      }
      _chatListUpdateController.add(null);
    }

    _socket!.on('message delivered', handleDelivered);
    _socket!.on('messages delivered', handleDelivered);
    _socket!.on('messages read', (data) {
      if (data is Map) {
        final payload = Map<String, dynamic>.from(data as Map);
        messagesReadController.add(payload);
        final chatId = payload['chatId']?.toString();
        final readerUserId =
            (payload['userId'] ?? payload['readerId'] ?? '').toString();
        final messageIds =
            (payload['messageIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ((payload['messageId'] != null &&
                    payload['messageId'].toString().isNotEmpty)
                ? [payload['messageId'].toString()]
                : null);

        debugPrint(
          '👁️ Global: messages read chatId=$chatId reader=$readerUserId messageIds=$messageIds',
        );

        if (chatId != null && chatId.isNotEmpty) {
          // Only message screens may clear incoming unread counts when the user
          // actually opens a conversation. A generic socket read event can also
          // mean "the other user read my outgoing messages", so never clear
          // unread state globally from here.
          ChatCacheSyncService.updateOutgoingMessageStatus(
            chatId,
            MessageStatus.read,
            messageIds: messageIds,
          );
        }
      }
      _chatListUpdateController.add(null);
    });
    _socket!.on(
      'user status changed',
      (_) => _chatListUpdateController.add(null),
    );

    // ── GROUPS ────────────────────────────────────────────────────────────────
    for (final ev in [
      'group created',
      'group updated',
      'member added',
      'member removed',
      'admin added',
      'group deleted',
    ]) {
      _socket!.on(ev, (_) => _chatListUpdateController.add(null));
    }

    // ── BROADCASTS ───────────────────────────────────────────────────────────
    _socket!.on('broadcast created', (data) {
      debugPrint('📢 [Socket] broadcast created: $data');
      try {
        if (data is Map) {
          broadcastUpdatedController.add({
            ...Map<String, dynamic>.from(data as Map),
            '_socketEvent': 'created',
          });
        }
      } catch (e) {
        debugPrint('❌ broadcast created parse error: $e');
      }
      _chatListUpdateController.add(null);
    });

    _socket!.on('broadcast updated', (data) {
      debugPrint('📢 [Socket] broadcast updated: $data');
      try {
        if (data is Map) {
          broadcastUpdatedController.add({
            ...Map<String, dynamic>.from(data as Map),
            '_socketEvent': 'updated',
          });
        }
      } catch (e) {
        debugPrint('❌ broadcast updated parse error: $e');
      }
      _chatListUpdateController.add(null);
    });

    _socket!.on('broadcast deleted', (data) {
      debugPrint('📢 [Socket] broadcast deleted: $data');
      try {
        String id = '';
        if (data is String) {
          id = data.trim();
        } else if (data is Map) {
          id = (data['_id'] ?? data['broadcastId'] ?? data['id'] ?? '')
              .toString()
              .trim();
        }
        if (id.isNotEmpty) broadcastDeletedController.add(id);
      } catch (e) {
        debugPrint('❌ broadcast deleted parse error: $e');
      }
      _chatListUpdateController.add(null);
    });

    _socket!.on('broadcast member joined', (data) {
      debugPrint('📢 [Socket] broadcast member joined: $data');
      try {
        if (data is Map) {
          broadcastMemberJoinedController.add(
            Map<String, dynamic>.from(data as Map),
          );
        }
      } catch (e) {
        debugPrint('❌ broadcast member joined parse error: $e');
      }
    });

    _socket!.on('broadcast member left', (data) {
      debugPrint('📢 [Socket] broadcast member left: $data');
      try {
        if (data is Map) {
          broadcastMemberLeftController.add(
            Map<String, dynamic>.from(data as Map),
          );
        }
      } catch (e) {
        debugPrint('❌ broadcast member left parse error: $e');
      }
    });

    // ── CALLS ─────────────────────────────────────────────────────────────────
    _socket!.on('call user', (data) {
      debugPrint('📞 incoming call received');
      try {
        _incomingCallController.add(Map<String, dynamic>.from(data as Map));
      } catch (e) {
        debugPrint('❌ Failed to parse incoming call: $e');
      }
    });
    _socket!.on('call accepted', (_) {});
    _socket!.on('call rejected', (_) {});
    _socket!.on('call ended', (_) {});
    _socket!.on('call timeout', (_) {});

    // ── ONLINE PRESENCE ───────────────────────────────────────────────────────
    // Backend emits 'user online' with EITHER:
    //   • A plain userId string  →  "63abc..."
    //   • A map                  →  { userId: "63abc...", username: "John" }
    //   • A map with _id         →  { _id: "63abc..." }
    // We normalise all three into {userId, username} and broadcast.
    _socket!.on('user online', (data) async {
      debugPrint(
        '🟢 [GlobalSocket] "user online" event raw: $data  (type: ${data.runtimeType})',
      );

      try {
        String userId = '';
        String username = '';

        if (data == null) return;

        if (data is String) {
          userId = data.trim();
        } else if (data is Map) {
          userId = (data['userId'] ?? data['_id'] ?? data['id'] ?? '')
              .toString()
              .trim();
          username = (data['username'] ?? data['name'] ?? '').toString().trim();
        } else {
          // Fallback — toString in case the library wraps it differently
          userId = data.toString().trim();
        }

        if (userId.isEmpty) {
          debugPrint('⚠️ user online: could not extract userId from $data');
          return;
        }

        // Resolve display name from Hive if the socket didn't include it
        if (username.isEmpty) {
          username = await _resolveUsernameFromHive(userId);
          debugPrint('🔍 Resolved name from Hive: "$username" for $userId');
        }

        debugPrint(
          '🟢 Broadcasting userOnlineStream — id: $userId, name: "$username"',
        );

        // ✅ Broadcast so OnlinePresenceNotificationService fires the notification
        _userOnlineController.add({'userId': userId, 'username': username});

        // Also refresh chat list for green dot indicator
        _chatListUpdateController.add(null);
      } catch (e) {
        debugPrint('❌ user online parse error: $e');
      }
    });

    _socket!.on('user offline', (_) => _chatListUpdateController.add(null));
    _socket!.on(
      'connected',
      (_) => debugPrint('✅ Server confirmed connection'),
    );
  }

  // ── Resolve display name from Hive chat cache ─────────────────────────────
  // Called when the socket event doesn't include a username.
  Future<String> _resolveUsernameFromHive(String userId) async {
    try {
      final Box<ChatListItemHive> box = Hive.isBoxOpen('chats')
          ? Hive.box<ChatListItemHive>('chats')
          : await Hive.openBox<ChatListItemHive>('chats');

      for (final chat in box.values) {
        final storedId = (chat.userId ?? '').toString().trim();
        if (storedId == userId || chat.id == userId) {
          final name = chat.title.trim();
          if (name.isNotEmpty) return name;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Hive username lookup failed: $e');
    }
    // Last resort: first 8 chars so it's at least identifiable
    return userId.length > 8 ? userId.substring(0, 8) : userId;
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  void _updateStatus(ConnectionStatus s) {
    if (_status != s) {
      _status = s;
      _connectionStatusController.add(s);
      debugPrint('🔄 Socket status: $s');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isManualDisconnect) return;
    _reconnectAttempts++;
    if (_reconnectAttempts > _maxReconnectAttempts) {
      debugPrint('❌ Max reconnect attempts reached ($_maxReconnectAttempts)');
      _updateStatus(ConnectionStatus.disconnected);
      return;
    }
    // Exponential backoff capped at 30 seconds to handle server cold starts
    final delaySecs = (2 * _reconnectAttempts).clamp(2, 30);
    final delay = Duration(seconds: delaySecs);
    debugPrint(
      '⏱️ Reconnect in ${delay.inSeconds}s (${_reconnectAttempts}/$_maxReconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, () {
      if (!isConnected && !_isManualDisconnect) connect();
    });
  }

  Future<void> processOfflineQueue() async {
    try {
      final queue = OfflineMessageQueue();
      if (queue.pendingCount > 0) {
        debugPrint('📤 Processing ${queue.pendingCount} queued messages');
        await queue.processQueue(sendFunction: sendMessageViaApi);
      }
    } catch (e) {
      debugPrint('❌ Offline queue error: $e');
    }
  }

  Future<String?> sendMessageViaApi(QueuedMessage msg) async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': msg.chatId,
          'content': msg.content,
          if (msg.replyToId != null) 'replyTo': msg.replyToId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return (jsonDecode(response.body) as Map<String, dynamic>)['_id']
            as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ sendMessageViaApi error: $e');
      return null;
    }
  }

  void disconnect() {
    debugPrint('🔌 Manual disconnect');
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listenersAttached = false; // ✅ allow fresh listener setup on next connect
    _updateStatus(ConnectionStatus.disconnected);
  }

  void dispose() {
    _reconnectTimer?.cancel();
    disconnect();
    _chatListUpdateController.close();
    _connectionStatusController.close();
    _messageReceivedController.close();
    _incomingCallController.close();
    _userOnlineController.close();

    // Close broadcast controllers
    broadcastMessageController.close();
    messageDeliveredController.close();
    messagesReadController.close();
    broadcastMembersController.close();
    broadcastDeletedController.close();
    broadcastUpdatedController.close();
    broadcastMemberJoinedController.close();
    broadcastMemberLeftController.close();
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket?.emit(event, data);
      debugPrint('📤 Emitted: $event');
    } else {
      debugPrint('⚠️ Cannot emit "$event" — not connected');
    }
  }

  void notifyChatListUpdated() {
    _chatListUpdateController.add(null);
  }

  void resetAndRetry() {
    _reconnectAttempts = 0;
    _isManualDisconnect = false;
    connect();
  }

  /// Called by NotificationService when FCM delivers an INCOMING_CALL
  /// and the socket 'call user' event never fires.
  void notifyIncomingCall(Map<String, dynamic> data) {
    debugPrint('📞 [GlobalSocketService] notifyIncomingCall via FCM: $data');
    _incomingCallController.add(data);
  }
}

// ── RIVERPOD PROVIDER ──────────────────────────────────────────────────────
final globalSocketServiceProvider = Provider((ref) {
  return GlobalSocketService();
});
