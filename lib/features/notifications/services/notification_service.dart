import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/general/services/chat_cache_sync_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/features/notifications/services/notification_settings_services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND HANDLER  (must be top-level)
// ─────────────────────────────────────────────────────────────────────────────

AudioPlayer? _callAudioPlayer;

class _PreparedQuickReply {
  final String chatId;
  final String replyText;
  final Map<String, dynamic> payloadData;
  final String authToken;
  final String myUserId;
  final String senderId;
  final String tempId;
  final ChatMessage tempMessage;

  const _PreparedQuickReply({
    required this.chatId,
    required this.replyText,
    required this.payloadData,
    required this.authToken,
    required this.myUserId,
    required this.senderId,
    required this.tempId,
    required this.tempMessage,
  });
}

Future<void> _ensureNotificationActionIsolateInitialized() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ChatListItemHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ChatMessageHiveAdapter());
  }

  if (!Hive.isBoxOpen('chats')) {
    await Hive.openBox<ChatListItemHive>('chats');
  }
  if (!Hive.isBoxOpen('chat_messages')) {
    await Hive.openBox<List>('chat_messages');
  }
}

Map<String, dynamic> _decodeNotificationPayload(String? payload) {
  if (payload == null || payload.isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {}
  return <String, dynamic>{};
}

String? _extractMessageIdFromResponseBody(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final directId = decoded['_id']?.toString();
      if (directId != null && directId.isNotEmpty) return directId;

      final message = decoded['message'];
      if (message is Map<String, dynamic>) {
        final nestedId = message['_id']?.toString();
        if (nestedId != null && nestedId.isNotEmpty) return nestedId;
      }
    }
  } catch (_) {}
  return null;
}

String _friendlyQuickReplyError({int? statusCode, Object? error}) {
  if (error is TimeoutException) {
    return 'Reply timed out. Check your connection and retry.';
  }
  if (error is SocketException) {
    return 'No internet connection. Reply not sent.';
  }
  if (statusCode == 401 || statusCode == 403) {
    return 'Your session expired. Open QikTalk and sign in again.';
  }
  if (statusCode != null && statusCode >= 500) {
    return 'QikTalk is having trouble right now. Please retry.';
  }
  return 'Reply not sent. Please try again.';
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NOTIF_TRACK] Background message received: ${message.messageId}');

  final type = message.data['type'] ?? '';

  // ── Incoming call ──────────────────────────────────────────────────────────
  if (type == 'INCOMING_CALL') {
    debugPrint(
      '[NOTIF_TRACK] 📞 FCM Background INCOMING_CALL — triggering CallKit',
    );

    // Check if calls are enabled in settings
    final settingsService = NotificationSettingsServices();
    final cachedSettings = await settingsService.getCachedSettings();
    final bool callsEnabled = cachedSettings?['calls'] ?? true;

    if (!callsEnabled) {
      debugPrint('[NOTIF_TRACK] Calls disabled in settings - skipping CallKit');
      return;
    }

    final saveValues = SaveValues();
    final callToneTitle =
        await saveValues.getString("call_ringtone") ?? "Default";
    String ringtoneUri = "system_ringtone_default";

    if (callToneTitle != "Default") {
      final customUri = await saveValues.getString("tone_uri_$callToneTitle");
      if (customUri != null && customUri.isNotEmpty) {
        ringtoneUri = customUri;
      } else {
        try {
          final ringtones =
              await FlutterSystemRingtones.getNotificationSounds();
          for (final r in ringtones) {
            if (r.title == callToneTitle) {
              ringtoneUri = r.uri;
              break;
            }
          }
        } catch (e) {
          debugPrint("[NOTIF_TRACK] Error finding call ringtone: $e");
        }
      }
    }

    final callId =
        message.data['callId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final callerName =
        message.data['callerName'] ?? message.data['name'] ?? 'Incoming Call';
    final callerPhoto =
        message.data['callerPhoto'] ?? message.data['profilePicture'] ?? '';
    final isVideo =
        message.data['callType'] == 'video' ||
        (message.data['isVideo'] == 'true');

    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'QikTalk',
      avatar: callerPhoto,
      handle: callerName,
      type: isVideo ? 1 : 0,
      duration: 30000,
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'silent_ringtone',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);

    debugPrint(
      '[NOTIF_TRACK] CallKit shown. CallTone: $callToneTitle, ResolvedURI: $ringtoneUri',
    );

    if (ringtoneUri != 'system_ringtone_default') {
      try {
        debugPrint(
          '[NOTIF_TRACK] Starting manual AudioPlayer for custom ringtone: $ringtoneUri',
        );
        // Cleanup any existing player before creating a new one
        if (_callAudioPlayer != null) {
          debugPrint('[NOTIF_TRACK] Cleaning up old player');
          await _callAudioPlayer!.stop();
          await _callAudioPlayer!.dispose();
        }

        final player = AudioPlayer();
        _callAudioPlayer = player;

        await player.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType
                  .notificationRingtone, // Correct member for calls in audioplayers 6.x
              audioFocus: AndroidAudioFocus.gainTransient,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {
                AVAudioSessionOptions.defaultToSpeaker,
                AVAudioSessionOptions.allowBluetooth,
              },
            ),
          ),
        );

        await player.setReleaseMode(ReleaseMode.loop);

        if (ringtoneUri.startsWith('content://')) {
          debugPrint('[NOTIF_TRACK] Playing from content URI');
          await player.play(UrlSource(ringtoneUri));
        } else if (ringtoneUri.startsWith('/')) {
          debugPrint('[NOTIF_TRACK] Playing from device file');
          await player.play(DeviceFileSource(ringtoneUri));
        } else if (ringtoneUri.startsWith('asset:')) {
          final assetPath = ringtoneUri.replaceFirst('asset:', '');
          debugPrint('[NOTIF_TRACK] Playing from asset: $assetPath');
          await player.play(AssetSource(assetPath));
        } else {
          debugPrint('[NOTIF_TRACK] Playing from URL or other');
          await player.play(UrlSource(ringtoneUri));
        }
        debugPrint('[NOTIF_TRACK] Manual ringtone playing successfully');
      } catch (e) {
        debugPrint('[NOTIF_TRACK] ❌ Error playing manual ringtone: $e');
        FlutterRingtonePlayer().playRingtone();
      }
    } else {
      debugPrint('[NOTIF_TRACK] Using system default ringtone (fallback)');
      FlutterRingtonePlayer().playRingtone();
    }

    // Listen for CallKit events to stop the audio
    StreamSubscription? callSubscription;
    callSubscription = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event?.event == Event.actionCallAccept ||
          event?.event == Event.actionCallDecline ||
          event?.event == Event.actionCallEnded ||
          event?.event == Event.actionCallTimeout) {
        debugPrint('[NOTIF_TRACK] Call event ${event?.event} - stopping audio');
        _callAudioPlayer?.stop();
        FlutterRingtonePlayer().stop();
        callSubscription?.cancel();
      }
    });

    return;
  }

  // Ensure the service is initialized for the background isolate
  final service = NotificationService();
  await service.initializeBackground();
  await service.showNotification(message);
}

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND NOTIFICATION RESPONSE HANDLER  (must be a top-level function)
// ─────────────────────────────────────────────────────────────────────────────

/// Handles notification action-button taps when the app is **background or
/// terminated**. Must be a top-level function (not a static method) so that
/// [flutter_local_notifications] can reach it from a background isolate via
/// `@pragma('vm:entry-point')`.
///
/// Uses [SharedPreferences] directly — it works in any isolate with zero
/// extra setup, unlike Hive which requires `initFlutter()` + adapters.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(
  NotificationResponse response,
) async {
  debugPrint(
    '[NOTIF_BG] notificationBackgroundHandler — actionId: ${response.actionId}',
  );

  await _ensureNotificationActionIsolateInitialized();

  // Parse the payload that was embedded when the notification was shown.
  final data = _decodeNotificationPayload(response.payload);
  final chatId = data['chatId'] as String? ?? '';

  // ── ① Inline Reply ────────────────────────────────────────────────────────
  if (response.actionId == _ActionId.reply) {
    final replyText = response.input?.trim() ?? '';
    if (replyText.isEmpty || chatId.isEmpty) {
      debugPrint('[NOTIF_BG] ⚠️ Empty reply or chatId — aborting');
      return;
    }

    debugPrint('[NOTIF_BG] 💬 Sending "$replyText" to chat $chatId');

    final service = NotificationService();
    await service.initializeBackground();
    final prepared = await service._prepareQuickReplyAction(
      chatId: chatId,
      replyText: replyText,
      payloadData: data,
      notificationId: response.id,
      emitSocketEvent: false,
    );
    if (prepared != null) {
      debugPrint(
        '[NOTIF_BG] 🚀 Quick reply prepared — returning action immediately',
      );
      unawaited(service._finishQuickReplySend(prepared));
    }
    return;
  }

  // ── ② Mark as Read ────────────────────────────────────────────────────────
  if (response.actionId == _ActionId.markRead) {
    if (chatId.isEmpty) return;
    debugPrint('[NOTIF_BG] 📖 Mark as read for chat $chatId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (authToken != null && authToken.isNotEmpty) {
        await http
            .put(
              Uri.parse('${ApiStrings.baseUri}chat/mark-read'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode({'chatId': chatId}),
            )
            .timeout(const Duration(seconds: 10));
        debugPrint('[NOTIF_BG] ✅ Marked as read on backend');
      }
    } catch (e) {
      debugPrint('[NOTIF_BG] ❌ Mark as read error: $e');
    }
    // Notification is auto-dismissed via cancelNotification: true on the action.
    return;
  }

  debugPrint('[NOTIF_BG] ℹ️ Unhandled background action: ${response.actionId}');
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION ACTION IDs
// ─────────────────────────────────────────────────────────────────────────────

/// Android notification action IDs — keep these in sync with
/// the AndroidNotificationAction declarations below.
class _ActionId {
  static const String reply = 'REPLY_ACTION';
  static const String markRead = 'MARK_READ_ACTION';
  static const String mute = 'MUTE_ACTION';
  static const String yesItWasMe = 'YES_IT_WAS_ME';
  static const String secureAccount = 'SECURE_ACCOUNT';
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SaveValues _saveValues = SaveValues();

  /// Called by QuickTalkApp when the user taps a notification.
  Function(Map<String, dynamic> data)? onNotificationTap;

  /// Called by QuickTalkApp when the user sends a quick-reply from the shade.
  Function(String chatId, String replyText)? onQuickReply;

  /// Called by QuickTalkApp when the user taps Mute from the shade.
  Function(String chatId)? onMuteChat;

  Future<void> _dismissQuickReplyNotification(
    String chatId, {
    int? notificationId,
  }) async {
    if (notificationId != null) {
      await _localNotifications.cancel(id: notificationId);
    }
    await clearChatNotifications(chatId);
  }

  void _emitQuickReplySocketEvent({
    required String chatId,
    required String myUserId,
    required String text,
    required String tempId,
  }) {
    final socketService = GlobalSocketService();
    if (!socketService.isConnected) return;

    socketService.emit('new message', {
      'chat': {'_id': chatId},
      'sender': {'_id': myUserId},
      'text': text,
      'tempId': tempId,
    });
  }

  Future<_PreparedQuickReply?> _prepareQuickReplyAction({
    required String chatId,
    required String replyText,
    required Map<String, dynamic> payloadData,
    int? notificationId,
    bool emitSocketEvent = true,
  }) async {
    final normalizedText = replyText.trim();
    if (normalizedText.isEmpty || chatId.isEmpty) {
      debugPrint('[NOTIF_REPLY] prepare aborted — empty reply or chatId');
      return null;
    }

    debugPrint('[NOTIF_REPLY] prepare start — chatId=$chatId');
    await _dismissQuickReplyNotification(
      chatId,
      notificationId: notificationId,
    );

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';
    final myUserId = prefs.getString(AppPreferenceHelper.ID) ?? '';
    final senderId = myUserId.isNotEmpty ? myUserId : '__me__';
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: chatId,
      text: normalizedText,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
    );

    await ChatCacheSyncService.upsertLocalMessage(
      message: tempMessage,
      senderId: senderId,
    );
    GlobalSocketService().notifyChatListUpdated();
    debugPrint('[NOTIF_REPLY] local sending message inserted — tempId=$tempId');

    if (emitSocketEvent && myUserId.isNotEmpty) {
      final socketService = GlobalSocketService();
      if (socketService.isConnected) {
        _emitQuickReplySocketEvent(
          chatId: chatId,
          myUserId: myUserId,
          text: normalizedText,
          tempId: tempId,
        );
        debugPrint('[NOTIF_REPLY] optimistic socket event emitted');
      } else {
        debugPrint(
          '[NOTIF_REPLY] socket dead — skipping emit, HTTP will handle it',
        );
      }
    }

    return _PreparedQuickReply(
      chatId: chatId,
      replyText: normalizedText,
      payloadData: payloadData,
      authToken: authToken,
      myUserId: myUserId,
      senderId: senderId,
      tempId: tempId,
      tempMessage: tempMessage,
    );
  }

  Future<bool> _finishQuickReplySend(_PreparedQuickReply prepared) async {
    debugPrint(
      '[NOTIF_REPLY] finish start — chatId=${prepared.chatId}, tempId=${prepared.tempId}',
    );

    if (prepared.authToken.isEmpty) {
      final failedMessage = prepared.tempMessage.copyWith(
        status: MessageStatus.failed,
      );
      await ChatCacheSyncService.upsertLocalMessage(
        message: failedMessage,
        senderId: prepared.senderId,
        tempId: prepared.tempId,
      );
      await _showReplyErrorNotification(
        prepared.chatId,
        replyText: prepared.replyText,
        errorMessage: _friendlyQuickReplyError(statusCode: 401),
        payloadData: prepared.payloadData,
      );
      GlobalSocketService().notifyChatListUpdated();
      debugPrint('[NOTIF_REPLY] finish failed — missing auth token');
      return false;
    }

    // Retry once on server errors or timeouts (handles Render.com cold starts)
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        debugPrint('[NOTIF_REPLY] HTTP send attempt $attempt');
        final httpResponse = await http
            .post(
              Uri.parse('${ApiStrings.baseUri}message'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${prepared.authToken}',
              },
              body: jsonEncode({
                'chatId': prepared.chatId,
                'content': prepared.replyText,
                'tempId': prepared.tempId,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
          final serverMessageId =
              _extractMessageIdFromResponseBody(httpResponse.body) ??
              prepared.tempId;
          final sentMessage = prepared.tempMessage.copyWith(
            id: serverMessageId,
            status: MessageStatus.sent,
          );

          await ChatCacheSyncService.upsertLocalMessage(
            message: sentMessage,
            senderId: prepared.senderId,
            tempId: prepared.tempId,
          );
          GlobalSocketService().notifyChatListUpdated();
          debugPrint(
            '[NOTIF_REPLY] finish success — serverId=$serverMessageId',
          );
          return true;
        }

        // Retry on server errors (5xx) — server may be cold-starting
        if (httpResponse.statusCode >= 500 && attempt < 2) {
          debugPrint(
            '[NOTIF_REPLY] Server error ${httpResponse.statusCode} — retrying in 5s',
          );
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }

        final failedMessage = prepared.tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        await ChatCacheSyncService.upsertLocalMessage(
          message: failedMessage,
          senderId: prepared.senderId,
          tempId: prepared.tempId,
        );
        await _showReplyErrorNotification(
          prepared.chatId,
          replyText: prepared.replyText,
          errorMessage: _friendlyQuickReplyError(
            statusCode: httpResponse.statusCode,
          ),
          payloadData: prepared.payloadData,
        );
        GlobalSocketService().notifyChatListUpdated();
        debugPrint(
          '[NOTIF_REPLY] finish failed — HTTP ${httpResponse.statusCode}: ${httpResponse.body}',
        );
        return false;
      } on TimeoutException catch (e) {
        if (attempt < 2) {
          debugPrint('[NOTIF_REPLY] Timeout — retrying in 5s');
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        final failedMessage = prepared.tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        await ChatCacheSyncService.upsertLocalMessage(
          message: failedMessage,
          senderId: prepared.senderId,
          tempId: prepared.tempId,
        );
        await _showReplyErrorNotification(
          prepared.chatId,
          replyText: prepared.replyText,
          errorMessage: _friendlyQuickReplyError(error: e),
          payloadData: prepared.payloadData,
        );
        GlobalSocketService().notifyChatListUpdated();
        debugPrint('[NOTIF_REPLY] finish timeout: $e');
        return false;
      } on SocketException catch (e) {
        if (attempt < 2) {
          debugPrint('[NOTIF_REPLY] Socket error — retrying in 5s');
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        final failedMessage = prepared.tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        await ChatCacheSyncService.upsertLocalMessage(
          message: failedMessage,
          senderId: prepared.senderId,
          tempId: prepared.tempId,
        );
        await _showReplyErrorNotification(
          prepared.chatId,
          replyText: prepared.replyText,
          errorMessage: _friendlyQuickReplyError(error: e),
          payloadData: prepared.payloadData,
        );
        GlobalSocketService().notifyChatListUpdated();
        debugPrint('[NOTIF_REPLY] finish socket error: $e');
        return false;
      } catch (e) {
        if (attempt < 2) {
          debugPrint('[NOTIF_REPLY] Error — retrying in 5s: $e');
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        final failedMessage = prepared.tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        await ChatCacheSyncService.upsertLocalMessage(
          message: failedMessage,
          senderId: prepared.senderId,
          tempId: prepared.tempId,
        );
        await _showReplyErrorNotification(
          prepared.chatId,
          replyText: prepared.replyText,
          errorMessage: _friendlyQuickReplyError(error: e),
          payloadData: prepared.payloadData,
        );
        GlobalSocketService().notifyChatListUpdated();
        debugPrint('[NOTIF_REPLY] finish unexpected error: $e');
        return false;
      }
    }
    return false;
  }

  // ── initialize ─────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    debugPrint('🔔 Initializing Notification Service…');
    await _requestPermissions();
    await _initializeLocalNotifications();
    await _configureFCM();
    await _getFCMToken();
    debugPrint('✅ Notification Service initialized');
  }

  /// Specialized initialization for background isolates that avoids setting up FCM listeners
  Future<void> initializeBackground() async {
    debugPrint('[NOTIF_TRACK] Initializing Notification Service (Background)…');
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
    debugPrint('[NOTIF_TRACK] ✅ Notification Service initialized (Background)');
  }

  // ── permissions ────────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
      );
      debugPrint('📱 iOS permission: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('📱 Android permission: $granted');
    }
  }

  // ── local notification init ────────────────────────────────────────────────
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // ── Channels ──────────────────────────────────────────────────────────────

    // Delete and recreate the chat channel to force action buttons to register
    await androidPlugin?.deleteNotificationChannel(
      channelId: 'qiktalk_channel',
    );

    // Main chat channel (high importance → heads-up banner)
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'qiktalk_ch_incoming_message',
        'QikTalk Messages',
        description: 'Notifications for new messages',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('incoming_message'),
        showBadge: true,
      ),
    );

    // Silent channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'qiktalk_msg_silent',
        'Silent Notifications',
        description: 'Muted notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: false,
        showBadge: true,
      ),
    );

    // Security / login-detected channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'qiktalk_security',
        'QikTalk Security',
        description: 'Login and security alerts',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
    );

    // Status reshare channel
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        'qiktalk_status_reshare',
        'Status Reshares',
        description: 'Alerts when someone reshares your status',
        importance: Importance.high,
        enableVibration: false,
        playSound: false,
        vibrationPattern: Int64List.fromList([0, 250, 100, 250]),
      ),
    );

    // Online presence channel
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        'qiktalk_online_presence',
        'Online Presence',
        description: 'Notifies when a friend comes online',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: false,
        vibrationPattern: Int64List.fromList([0, 120]),
      ),
    );
  }

  // ── FCM config ─────────────────────────────────────────────────────────────
  Future<void> _configureFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message: ${message.notification?.title}');
      final type = message.data['type'] ?? '';
      if (type == 'INCOMING_CALL') {
        GlobalSocketService().notifyIncomingCall({
          'callId': message.data['callId'] ?? '',
          'from': message.data['callerId'] ?? message.data['from'] ?? '',
          'name':
              message.data['callerName'] ?? message.data['name'] ?? 'Unknown',
          'profilePicture':
              message.data['callerPhoto'] ??
              message.data['profilePicture'] ??
              '',
          'callType': message.data['callType'] ?? 'audio',
          'isVideo': message.data['callType'] == 'video',
        });
        return;
      }
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped (background)');
      Future.delayed(
        const Duration(milliseconds: 300),
        () => _handleTap(message.data),
      );
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔔 Notification tapped (terminated)');
      Future.delayed(
        const Duration(seconds: 2),
        () => _handleTap(initialMessage.data),
      );
    }

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── FCM token ──────────────────────────────────────────────────────────────
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('📱 FCM TOKEN obtained');
        await _saveValues.saveString(AppPreferenceHelper.FCM_TOKEN, token);
      }
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveValues.saveString(AppPreferenceHelper.FCM_TOKEN, newToken);
        uploadTokenToBackend(newToken);
      });
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  // ── upload token ───────────────────────────────────────────────────────────
  Future<bool> uploadTokenToBackend([String? token]) async {
    try {
      final authToken = await _saveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      if (authToken == null || authToken.isEmpty) return false;

      String? fcmToken = token;
      fcmToken ??= await _saveValues.getString(AppPreferenceHelper.FCM_TOKEN);
      fcmToken ??= await _firebaseMessaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return false;

      if (token != null) {
        await _saveValues.saveString(AppPreferenceHelper.FCM_TOKEN, fcmToken);
      }

      final url = Uri.parse('${ApiStrings.baseUri}user/fcm-token');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error uploading FCM token: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHOW NOTIFICATION  ←  the main entry-point
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final String type = data['type'] ?? 'CHAT_MESSAGE';
    final String chatId = data['chatId'] ?? '';
    final String messageId = data['messageId'] ?? '';

    // ── Backend-fixed payload fields (commit 47358e1) ──────────────────────
    // type, chatId, senderId, senderName, senderAvatar, message, messageId
    final String title =
        data['senderName'] ?? notification?.title ?? data['name'] ?? 'QikTalk';
    final String body =
        data['message'] ?? notification?.body ?? data['body'] ?? '';
    final String senderAvatar =
        data['senderAvatar'] ?? data['profilePicture'] ?? '';

    debugPrint(
      '[NOTIF_TRACK] showNotification — type: $type, sender: $title, avatar: "$senderAvatar"',
    );

    // Check for duplicate notification
    if (await _isDuplicateNotification(chatId, messageId, type)) {
      debugPrint('[NOTIF_TRACK] Duplicate notification detected - skipping');
      return;
    }

    // ── Apply Privacy Settings ───────────────────────────────────────────────
    final settingsService = NotificationSettingsServices();
    final cachedSettings = await settingsService.getCachedSettings();
    final bool messagesEnabled = cachedSettings?['messages'] ?? true;
    final bool groupsEnabled = cachedSettings?['groups'] ?? true;
    final bool soundEnabled = cachedSettings?['sound'] ?? true;
    final bool vibrateEnabled = cachedSettings?['vibrate'] ?? true;
    final bool isGroup = data['isGroup'] == 'true' || data['isGroup'] == true;

    // Resolve which channel to use:
    // - sound disabled → silent channel
    // - group message → active_group_channel_id (or default)
    // - direct message → active_msg_channel_id (or default)
    String resolvedChannelId;
    if (!soundEnabled) {
      resolvedChannelId = 'qiktalk_msg_silent';
      debugPrint('[NOTIF_TRACK] 🔇 Sound disabled - using silent channel');
    } else {
      final channelKeyStr = isGroup ? 'group' : 'msg';
      final channelIdPref = 'active_${channelKeyStr}_channel_id';
      final String? existingChannelId = await _saveValues.getString(
        channelIdPref,
      );

      if (existingChannelId == null) {
        // If the channel mapping is missing, try to resolve from the saved title
        final toneTitlePref = isGroup
            ? 'group_tone_title'
            : 'message_tone_title';
        final toneTitle =
            await _saveValues.getString(toneTitlePref) ?? 'Incoming Message';
        final toneUri =
            await _saveValues.getString('tone_uri_$toneTitle') ?? '';

        debugPrint(
          '[NOTIF_TRACK] ℹ️ Channel mapping missing for $toneTitle - auto-registering...',
        );
        await registerToneChannel(
          channelKey: channelKeyStr,
          toneTitle: toneTitle,
          toneUri: toneUri,
        );
        resolvedChannelId =
            await _saveValues.getString(channelIdPref) ??
            'qiktalk_ch_incoming_message';
      } else {
        resolvedChannelId = existingChannelId;
      }
      debugPrint(
        '[NOTIF_TRACK] 🔊 Sound enabled - using channel: $resolvedChannelId',
      );
    }

    // Respect mute
    if (chatId.isNotEmpty && await _isChatMuted(chatId)) {
      debugPrint('[NOTIF_TRACK] Chat $chatId is muted - skipping');
      return;
    }

    // Respect global messages toggle
    if (!messagesEnabled) {
      debugPrint(
        '[NOTIF_TRACK] Global messages disabled - skipping notification',
      );
      return;
    }

    // Respect groups toggle
    if (isGroup && !groupsEnabled) {
      debugPrint(
        '[NOTIF_TRACK] Group messages disabled - skipping notification',
      );
      return;
    }

    // Vibration (sound is handled by the notification channel itself)
    if (vibrateEnabled) {
      Vibration.vibrate();
    }

    debugPrint('[NOTIF_TRACK] Final resolvedChannelId: $resolvedChannelId');

    // Route to the correct builder
    switch (type) {
      case 'CHAT_MESSAGE':
      case 'IMAGE':
      case 'VIDEO':
      case 'AUDIO':
      case 'VOICE_NOTE':
      case 'DOCUMENT':
        await _showChatNotification(
          title: title,
          body: body,
          type: type,
          data: data,
          chatId: chatId,
          messageId: messageId,
          senderAvatarUrl: senderAvatar,
          channelId: resolvedChannelId,
        );
        break;

      case 'NEW_LOGIN':
      case 'LOGIN_DETECTED':
      case 'SECURITY_ALERT':
        await _showSecurityNotification(
          title: title.isNotEmpty ? title : 'New Login Detected',
          body: body.isNotEmpty
              ? body
              : 'Your Qiktalk account was accessed on a web device. '
                    'If this was you, you\'re good to go. If not, please '
                    'review your account activity.',
          data: data,
          messageId: messageId,
          channelId: resolvedChannelId,
        );
        break;

      default:
        await _showGenericNotification(
          title: title,
          body: body,
          type: type,
          data: data,
          chatId: chatId,
          messageId: messageId,
          channelId: resolvedChannelId,
        );
    }
  }

  static Future<void> registerToneChannel({
    required String channelKey,
    required String toneTitle,
    required String toneUri,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (plugin == null) return;

    debugPrint(
      '[NOTIF_TRACK] registerToneChannel: key=$channelKey, title=$toneTitle, uri=$toneUri',
    );

    // Derive a unique channel ID from the tone to force Android 8+ to pick up sound changes
    AndroidNotificationSound? sound;
    String channelId;
    bool shouldPlaySound = true;

    if (toneTitle == 'None (Silent)') {
      channelId = 'qiktalk_${channelKey}_silent';
      sound = null;
      shouldPlaySound = false;
    } else if (toneTitle == 'Incoming Message' ||
        toneUri == 'asset:images/incoming_message.mp3') {
      channelId = 'qiktalk_ch_incoming_message';
      sound = const RawResourceAndroidNotificationSound('incoming_message');
    } else if (toneTitle == 'Outgoing Message' ||
        toneUri == 'asset:images/outgoing_message.mp3') {
      channelId = 'qiktalk_ch_outgoing_message';
      sound = const RawResourceAndroidNotificationSound('outgoing_message');
    } else if (toneUri.startsWith('content://') ||
        toneUri.startsWith('/') ||
        toneUri.contains('ringtone')) {
      // Use both title and URI hash to ensure a unique channel ID for sound changes
      final int hash = (toneTitle + toneUri).hashCode.abs();
      channelId = 'qiktalk_${channelKey}_$hash';
      sound = UriAndroidNotificationSound(toneUri);
    } else if (toneUri.startsWith('asset:')) {
      // Handle asset URIs by falling back to corresponding raw resource if possible
      final String assetName = toneUri.split('/').last.split('.').first;
      channelId = 'qiktalk_${channelKey}_asset_$assetName';
      sound = RawResourceAndroidNotificationSound(assetName);
    } else {
      // Default / fallback
      channelId = 'qiktalk_ch_incoming_message';
      sound = const RawResourceAndroidNotificationSound('incoming_message');
    }

    debugPrint(
      '[NOTIF_TRACK] Registering Channel — ID: $channelId, Sound: $sound, PlaySound: $shouldPlaySound',
    );

    try {
      await plugin.createNotificationChannel(
        AndroidNotificationChannel(
          channelId,
          'QikTalk – $toneTitle',
          description: 'Notifications with $toneTitle tone',
          importance: Importance.max,
          enableVibration: true,
          playSound: shouldPlaySound,
          sound: sound,
          showBadge: true,
          enableLights: true,
          ledColor: const Color(0xFFFF6B00),
        ),
      );
      debugPrint(
        '[NOTIF_TRACK] ✅ Channel $channelId created/updated successfully',
      );
    } catch (e) {
      debugPrint('[NOTIF_TRACK] ❌ Failed to create channel $channelId: $e');
    }

    final saveValues = SaveValues();
    await saveValues.saveString('active_${channelKey}_channel_id', channelId);
    debugPrint(
      '[NOTIF_TRACK] ✅ Registered tone channel $channelId for $toneTitle',
    );
  }

  Future<void> _showChatNotification({
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
    required String chatId,
    required String messageId,
    required String channelId,
    String senderAvatarUrl = '',
  }) async {
    // ── Resolve sender avatar - use consistent approach to prevent duplicates
    // Priority: FCM payload senderAvatar -> Hive cache -> nothing
    String? avatarUrl = senderAvatarUrl.isNotEmpty
        ? senderAvatarUrl
        : await _lookupAvatarFromHive(chatId);

    Uint8List? avatarBytes;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      debugPrint(' Downloading avatar from: $avatarUrl');
      avatarBytes = await _downloadImageBytes(avatarUrl);
      debugPrint(
        ' Avatar download result: ${avatarBytes != null ? "${avatarBytes.length} bytes" : "FAILED"}',
      );
    } else {
      debugPrint(' No avatar URL available for chat: $chatId');
    }

    // ── MessagingStyle person objects ──────────────────────────────────────
    // "sender" = the person who sent the message
    final Person sender = Person(
      name: title,
      icon: avatarBytes != null
          ? ByteArrayAndroidIcon(await _resizeImageTo96px(avatarBytes))
          : null,
      important: true,
    );

    // "me" = the device owner (used for the reply bubble placeholder)
    const Person me = Person(name: 'You');

    // Build the MessagingStyle — this creates the WhatsApp-style bubble layout
    // with the sender name on the first line and the message body below it.
    // groupConversation: false keeps it as a 1-on-1 conversation style.
    final MessagingStyleInformation messagingStyle = MessagingStyleInformation(
      me,
      conversationTitle: title,
      groupConversation: false,
      messages: [Message(_bodyForType(body, type), DateTime.now(), sender)],
    );

    // ── Android notification details ───────────────────────────────────────
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          'QikTalk Messages',
          channelDescription: 'Notifications for new messages',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
          largeIcon: avatarBytes != null
              ? ByteArrayAndroidBitmap(avatarBytes)
              : null,
          color: const Color(0xFFFF6B00),
          enableVibration: true,
          playSound: true,
          number: 1,
          styleInformation: messagingStyle,
          // ── Action buttons (shown below message body in shade) ──────────
          actions: [
            // ① Reply — inline text input matching "Reply" in the Figma footer
            AndroidNotificationAction(
              _ActionId.reply,
              'Reply',
              inputs: [
                AndroidNotificationActionInput(
                  label: 'Write a reply…',
                  allowedMimeTypes: {'text/plain'},
                ),
              ],
              showsUserInterface: false,
              cancelNotification: true,
            ),
            // ② Mark as read — matches "Mark as read" in the Figma footer
            AndroidNotificationAction(
              _ActionId.markRead,
              'Mark as read',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            // ③ Mute — matches "Mute" in the Figma footer
            AndroidNotificationAction(
              _ActionId.mute,
              'Mute',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    // Use a stable ID per chatId so multiple messages from the same chat
    // update the same notification instead of stacking separate ones.
    final int notifId = chatId.isNotEmpty
        ? chatId.hashCode.abs() % 2147483647
        : messageId.hashCode.abs() % 2147483647;

    debugPrint(
      '[NOTIF_TRACK] _showChatNotification — ID: $notifId, Channel: $channelId',
    );

    try {
      await _localNotifications.show(
        id: notifId,
        title: title,
        body: _bodyForType(body, type),
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: jsonEncode({...data, 'type': 'CHAT_MESSAGE'}),
      );
      debugPrint('[NOTIF_TRACK] ✅ Notification .show() completed');
    } catch (e) {
      debugPrint('[NOTIF_TRACK] ❌ Notification .show() FAILED: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECURITY / LOGIN-DETECTED NOTIFICATION  — matches Figma exactly:
  //
  //  ┌──────────────────────────────────────────────────────────┐
  //  │  [Q]  Qiktalk • 15 messages from 6 chats • 33m          │
  //  │  ╔══════════════════════════════════════════════════╗    │
  //  │  ║  [Avatar]  New Login Detected          22m  ˄   ║    │
  //  │  ║  Your Qiktalk account was accessed on a web     ║    │
  //  │  ║  device. If this was you, you're good to go.    ║    │
  //  │  ║  If not, please review your account activity.   ║    │
  //  │  ║  ┌─────────────┐  ┌──────────────────────────┐  ║    │
  //  │  ║  │ Yes, it was │  │  No, secure account  (🔴)│  ║    │
  //  │  ║  │     me      │  └──────────────────────────┘  ║    │
  //  │  ║  └─────────────┘                                ║    │
  //  │  ╚══════════════════════════════════════════════════╝    │
  //  └──────────────────────────────────────────────────────────┘
  //
  //  • BigTextStyle  →  full expanded body text visible without expanding
  //  • "Yes, it was me"   — outlined  (showsUserInterface: false, dismisses)
  //  • "No, secure account" — filled red (showsUserInterface: true, opens app)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showSecurityNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String messageId,
    required String channelId,
  }) async {
    // BigTextStyle expands the body automatically so all lines are visible
    // without the user having to swipe down — matches the Figma expanded state.
    final BigTextStyleInformation bigText = BigTextStyleInformation(
      body,
      htmlFormatBigText: false,
      contentTitle: title,
      htmlFormatContentTitle: false,
      summaryText: 'Tap to review your account',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          'QikTalk Security',
          channelDescription: 'Login and security alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          // Red accent to match the "No, secure account" filled button in Figma
          color: const Color(0xFFE8453C),
          enableVibration: true,
          playSound: true,
          styleInformation: bigText,
          actions: [
            // ① "Yes, it was me" — outlined button (dismiss, no app open)
            AndroidNotificationAction(
              _ActionId.yesItWasMe,
              'Yes, it was me',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            // ② "No, secure account" — filled red button (opens app)
            AndroidNotificationAction(
              _ActionId.secureAccount,
              'No, secure account',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final int notifId = messageId.isNotEmpty
        ? messageId.hashCode.abs() % 2147483647
        : DateTime.now().millisecondsSinceEpoch % 2147483647;

    await _localNotifications.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode({...data, 'type': 'NEW_LOGIN'}),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC NOTIFICATION  (posts, followers, status reshares, etc.)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showGenericNotification({
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
    required String chatId,
    required String messageId,
    required String channelId,
  }) async {
    final String resolvedChannelId = type == 'STATUS_RESHARED'
        ? 'qiktalk_status_reshare'
        : channelId;
    final String channelName = type == 'STATUS_RESHARED'
        ? 'Status Reshares'
        : 'QikTalk Messages';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          resolvedChannelId,
          channelName,
          channelDescription: 'QikTalk notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFFFF6B00),
          enableVibration: true,
          playSound: true,
          styleInformation: _getNotificationStyle(body, type),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final int notifId = messageId.isNotEmpty
        ? messageId.hashCode.abs() % 2147483647
        : DateTime.now().millisecondsSinceEpoch % 2147483647;

    await _localNotifications.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode({...data, 'type': type}),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRANSFER SUCCESS (in-app local)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> showTransferSuccessNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'qiktalk_channel',
          'QikTalk Messages',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFFFF6B00),
          enableVibration: false,
          playSound: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Transfer Successful ✅',
      body: 'Shipped to recipient successfully.',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode({'type': 'TRANSFER_SUCCESS'}),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESPONSE HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  void _onNotificationResponse(NotificationResponse response) async {
    debugPrint(
      '🔔 Notification response — action: ${response.actionId}, payload: ${response.payload}',
    );

    final data = _decodeNotificationPayload(response.payload);

    final actionId = response.actionId;

    // ── ① Inline reply ─────────────────────────────────────────────────────
    if (actionId == _ActionId.reply) {
      final replyText = response.input?.trim() ?? '';
      final chatId = data['chatId'] as String? ?? '';
      final notifId = response.id;
      if (replyText.isNotEmpty && chatId.isNotEmpty) {
        debugPrint('💬 Quick reply "$replyText" for chat $chatId');

        final prepared = await _prepareQuickReplyAction(
          chatId: chatId,
          replyText: replyText,
          payloadData: data,
          notificationId: notifId,
        );

        if (prepared != null) {
          debugPrint('💬 Quick reply prepared — returning action immediately');
          unawaited(
            _finishQuickReplySend(prepared).then((success) {
              if (success) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  onQuickReply?.call(chatId, replyText);
                  GlobalSocketService().notifyChatListUpdated();
                });
              }
            }),
          );
        }
      }
      return;
    }

    // ── ② Mark as read ─────────────────────────────────────────────────────
    if (actionId == _ActionId.markRead) {
      final chatId = data['chatId'] as String? ?? '';
      final messageId = data['messageId'] as String? ?? '';
      debugPrint(' Mark as read for chat $chatId');
      try {
        final authToken = await _saveValues.getString(
          AppPreferenceHelper.AUTH_TOKEN,
        );
        if (authToken != null && authToken.isNotEmpty && chatId.isNotEmpty) {
          // Use the correct endpoint for marking messages as read
          final response = await http
              .put(
                Uri.parse('${ApiStrings.baseUri}chat/mark-read'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authToken',
                },
                body: jsonEncode({
                  'chatId': chatId,
                  // If specific messageId provided, mark only that, otherwise mark all as read
                  'messageId': messageId.isNotEmpty ? messageId : null,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            debugPrint(' Messages marked as read for chat $chatId');
            // Also clear any existing notifications for this chat
            await clearChatNotifications(chatId);
          } else {
            debugPrint(
              ' Mark as read failed: ${response.statusCode} - ${response.body}',
            );
          }
        }
      } catch (e) {
        debugPrint(' Mark as read error: $e');
      }
      // Notification already cancelled via cancelNotification: true
      return;
    }

    // ── ③ Mute ─────────────────────────────────────────────────────────────
    if (actionId == _ActionId.mute) {
      final chatId = data['chatId'] as String? ?? '';
      debugPrint(' Muting chat $chatId from notification shade');
      if (chatId.isNotEmpty) {
        try {
          // First sync with backend
          final authToken = await _saveValues.getString(
            AppPreferenceHelper.AUTH_TOKEN,
          );
          if (authToken != null && authToken.isNotEmpty) {
            final response = await http
                .put(
                  Uri.parse('${ApiStrings.baseUri}chat/mute'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $authToken',
                  },
                  body: jsonEncode({'chatId': chatId, 'muted': true}),
                )
                .timeout(const Duration(seconds: 10));

            if (response.statusCode == 200) {
              debugPrint(' Chat $chatId muted on backend');

              // Then persist mute state in Hive so _isChatMuted() returns true
              final box = Hive.isBoxOpen('chats')
                  ? Hive.box<ChatListItemHive>('chats')
                  : await Hive.openBox<ChatListItemHive>('chats');
              final chatItem = box.get(chatId);
              if (chatItem != null) {
                final muted = chatItem.copyWith(
                  isMuted: true,
                  muteUntil: DateTime.now().add(
                    const Duration(days: 365),
                  ), // Long mute
                );
                await box.put(chatId, muted);
                debugPrint(' Chat $chatId muted in Hive');
              }

              // Clear existing notifications for this chat
              await clearChatNotifications(chatId);
            } else {
              debugPrint(
                ' Backend mute failed: ${response.statusCode} - ${response.body}',
              );
            }
          }
        } catch (e) {
          debugPrint(' Mute error: $e');
        }
        // Also notify the app if it's open
        Future.delayed(const Duration(milliseconds: 100), () {
          onMuteChat?.call(chatId);
        });
      }
      return;
    }

    // ── ④ Security: Yes it was me ──────────────────────────────────────────
    if (actionId == _ActionId.yesItWasMe) {
      debugPrint('✅ User confirmed login — dismissing');
      return;
    }

    // ── ⑤ Security: No, secure account ────────────────────────────────────
    if (actionId == _ActionId.secureAccount) {
      debugPrint('🔒 User wants to secure account');
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleTap({...data, 'type': 'SECURE_ACCOUNT'});
      });
      return;
    }

    // ── ⑥ Regular tap on notification body ────────────────────────────────
    Future.delayed(const Duration(milliseconds: 300), () {
      _handleTap(data);
    });
  }

  // [notificationBackgroundHandler] (top-level) handles background action
  // button taps — see the function defined above the NotificationService class.

  void _handleTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    debugPrint('🔔 Handling tap — type: $type');
    if (type == null || type.isEmpty) return;
    onNotificationTap?.call(data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AVATAR HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Download image bytes from a URL. Returns null on failure.
  Future<Uint8List?> _downloadImageBytes(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (e) {
      debugPrint('⚠️ Avatar download failed: $e');
    }
    return null;
  }

  /// Resize avatar bytes to 96×96 px so Android renders it correctly
  /// as a circle icon in MessagingStyle notifications.
  Future<Uint8List> _resizeImageTo96px(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(
        bytes,
        targetWidth: 96,
        targetHeight: 96,
      );
      final frame = await codec.getNextFrame();
      final resized = await frame.image.toByteData(format: ImageByteFormat.png);
      return resized?.buffer.asUint8List() ?? bytes;
    } catch (e) {
      debugPrint('⚠️ Avatar resize failed: $e');
      return bytes;
    }
  }

  /// Try to find an avatar URL from the Hive chat box.
  Future<String?> _lookupAvatarFromHive(String chatId) async {
    if (chatId.isEmpty) return null;
    try {
      final box = Hive.isBoxOpen('chats')
          ? Hive.box<ChatListItemHive>('chats')
          : await Hive.openBox<ChatListItemHive>('chats');
      return box.get(chatId)?.profilePicture;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STYLE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _bodyForType(String body, String type) {
    switch (type) {
      case 'IMAGE':
        return body.isNotEmpty ? body : '📷 Photo';
      case 'VIDEO':
        return body.isNotEmpty ? body : '🎥 Video';
      case 'AUDIO':
      case 'VOICE_NOTE':
        return body.isNotEmpty ? body : '🎵 Voice message';
      case 'DOCUMENT':
        return body.isNotEmpty ? body : '📄 Document';
      default:
        return body;
    }
  }

  StyleInformation _getNotificationStyle(String body, String type) {
    switch (type) {
      case 'CHAT_MESSAGE':
        return BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          htmlFormatContentTitle: true,
        );
      case 'IMAGE':
        return BigTextStyleInformation(
          body.isEmpty ? 'Sent a photo' : body,
          contentTitle: '📷 Photo',
          summaryText: 'Tap to view',
        );
      case 'VIDEO':
        return BigTextStyleInformation(
          body.isEmpty ? 'Sent a video' : body,
          contentTitle: '🎥 Video',
          summaryText: 'Tap to view',
        );
      case 'AUDIO':
      case 'VOICE_NOTE':
        return BigTextStyleInformation(
          body.isEmpty ? 'Sent a voice message' : body,
          contentTitle: '🎵 Voice Message',
          summaryText: 'Tap to listen',
        );
      case 'DOCUMENT':
        return BigTextStyleInformation(
          body.isEmpty ? 'Sent a document' : body,
          contentTitle: '📄 Document',
          summaryText: 'Tap to view',
        );
      case 'POST_LIKED':
        return BigTextStyleInformation(
          body.isEmpty ? 'Someone liked your post' : body,
          contentTitle: '❤️ Post Liked',
          summaryText: 'Tap to view',
        );
      case 'POST_COMMENTED':
        return BigTextStyleInformation(
          body.isEmpty ? 'Someone commented on your post' : body,
          contentTitle: '💬 New Comment',
          summaryText: 'Tap to view',
        );
      case 'USER_FOLLOWED':
        return BigTextStyleInformation(
          body.isEmpty ? 'Someone started following you' : body,
          contentTitle: '👤 New Follower',
          summaryText: 'Tap to view',
        );
      case 'POST_BOOKMARKED':
        return BigTextStyleInformation(
          body.isEmpty ? 'Someone bookmarked your post' : body,
          contentTitle: '🔖 Post Bookmarked',
          summaryText: 'Tap to view',
        );
      case 'STATUS_RESHARED':
        return BigTextStyleInformation(
          body.isEmpty ? 'Someone reshared your status' : body,
          contentTitle: '🔁 Status Reshared',
          summaryText: 'Tap to view your status',
        );
      default:
        return BigTextStyleInformation(body);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILITIES
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> clearAllNotifications() async => _localNotifications.cancelAll();

  Future<void> clearChatNotifications(String chatId) async {
    final int notifId = chatId.hashCode.abs() % 2147483647;
    await _localNotifications.cancel(id: notifId);
    debugPrint('🧹 Cleared notification for chat: $chatId');
  }

  Future<String?> getToken() async => _firebaseMessaging.getToken();

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _saveValues.clearPrefValue(AppPreferenceHelper.FCM_TOKEN);
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async =>
      _firebaseMessaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) async =>
      _firebaseMessaging.unsubscribeFromTopic(topic);

  Future<bool> _isChatMuted(String chatId) async {
    if (chatId.isEmpty) return false;
    try {
      final box = Hive.isBoxOpen('chats')
          ? Hive.box<ChatListItemHive>('chats')
          : await Hive.openBox<ChatListItemHive>('chats');
      return box.get(chatId)?.isCurrentlyMuted ?? false;
    } catch (e) {
      debugPrint('❌ Error checking mute: $e');
      return false;
    }
  }

  /// Check if notification is a duplicate to prevent showing the same notification twice
  Future<bool> _isDuplicateNotification(
    String chatId,
    String messageId,
    String type,
  ) async {
    if (chatId.isEmpty && messageId.isEmpty) return false;

    try {
      // Use a more sophisticated key-based deduplication that accounts for avatar processing
      // This prevents the issue where one notification shows without avatar and another with avatar
      final key = chatId.isNotEmpty ? 'chat_$chatId' : 'msg_$messageId';
      final lastShownKey = 'last_notif_$key';

      final lastShownTime = await _saveValues.getString(lastShownKey);
      if (lastShownTime != null) {
        final lastTime = DateTime.parse(lastShownTime);
        final now = DateTime.now();
        // If same notification was shown in the last 3 seconds, consider it duplicate
        // This is tighter to prevent the avatar processing delay from causing duplicates
        if (now.difference(lastTime).inSeconds < 3) {
          debugPrint(
            ' Duplicate notification blocked: $key (time difference: ${now.difference(lastTime).inSeconds}s)',
          );
          return true;
        }
      }

      // Save current notification time immediately to block any rapid subsequent notifications
      await _saveValues.saveString(
        lastShownKey,
        DateTime.now().toIso8601String(),
      );
      return false;
    } catch (e) {
      debugPrint(' Error checking duplicate notification: $e');
      return false;
    }
  }

  /// Show error notification when quick reply fails
  Future<void> _showReplyErrorNotification(
    String chatId, {
    required String replyText,
    required String errorMessage,
    required Map<String, dynamic> payloadData,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'qiktalk_ch_incoming_message',
          'QikTalk Messages',
          channelDescription: 'Notifications for new messages',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFFE8453C),
          playSound: false,
          enableVibration: false,
          autoCancel: true,
          actions: [
            AndroidNotificationAction(
              _ActionId.reply,
              'Retry',
              inputs: [
                AndroidNotificationActionInput(
                  label: 'Retry your reply…',
                  allowedMimeTypes: {'text/plain'},
                ),
              ],
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final int notifId =
        'reply_error_${chatId.hashCode}'.hashCode.abs() % 2147483647;
    final trimmedReply = replyText.trim();
    final preview = trimmedReply.length > 48
        ? '${trimmedReply.substring(0, 48)}…'
        : trimmedReply;

    await _localNotifications.show(
      id: notifId,
      title: 'Reply failed',
      body: '$errorMessage${preview.isEmpty ? '' : ' • "$preview"'}',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode({
        ...payloadData,
        'chatId': chatId,
        'type': 'CHAT_MESSAGE',
      }),
    );
  }
}
