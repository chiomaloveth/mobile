import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

/// Listens on [GlobalSocketService.userOnlineStream] and fires:
///   • A local push notification: "[Name] is online, tap to have a conversation"
///   • A floating SnackBar banner when the app is in the foreground
///
/// HOW TO CALL in main.dart (_QuickTalkAppState.initState):
///
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     OnlinePresenceNotificationService().initialize(navigatorKey);
///   });
///
/// IMPORTANT: Call this AFTER NotificationService().initialize() completes.
/// This service does NOT call plugin.initialize() itself — it only creates
/// its own Android channel and shows notifications using the same shared plugin.
class OnlinePresenceNotificationService {
  static final OnlinePresenceNotificationService _instance =
      OnlinePresenceNotificationService._internal();
  factory OnlinePresenceNotificationService() => _instance;
  OnlinePresenceNotificationService._internal();

  // Reuse the same FlutterLocalNotificationsPlugin singleton —
  // Flutter's plugin system ensures it's the same underlying instance.
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Map<String, dynamic>>? _onlineSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Prevent firing more than once per user per 5 minutes
  final Map<String, DateTime> _lastNotified = {};
  static const Duration _coolDown = Duration(minutes: 5);

  static const String _channelId = 'qiktalk_online_presence';
  static const String _channelName = 'Online Presence';

  // ── initialize ─────────────────────────────────────────────────────────────
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    // Create the Android notification channel.
    // Safe to call even if it already exists — Android is idempotent.
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Notifies when a friend comes online',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
      ),
    );

    // Cancel any existing subscription before re-subscribing.
    // This is important when the service is re-initialized after a hot restart.
    _onlineSubscription?.cancel();
    _onlineSubscription = GlobalSocketService().userOnlineStream.listen(
      _handleUserOnline,
      onError: (e) => debugPrint('❌ userOnlineStream error: $e'),
    );

    debugPrint(
      '✅ OnlinePresenceNotificationService initialized — listening for online events',
    );
  }

  // ── Main event handler ─────────────────────────────────────────────────────
  Future<void> _handleUserOnline(Map<String, dynamic> data) async {
    debugPrint('🟢 OnlinePresenceService received: $data');

    final String userId = (data['userId'] ?? '').toString().trim();
    final String username = (data['username'] ?? '').toString().trim();

    if (userId.isEmpty) {
      debugPrint('⚠️ Online event missing userId — skipping');
      return;
    }

    // Skip our own session
    final String? myId = await SaveValues().getString(AppPreferenceHelper.ID);
    if (userId == myId) {
      debugPrint('ℹ️ Own userId — skipping notification');
      return;
    }

    // Cool-down: max one notification per user per 5 minutes
    final DateTime? last = _lastNotified[userId];
    if (last != null && DateTime.now().difference(last) < _coolDown) {
      debugPrint('⏳ Cool-down active for $userId');
      return;
    }
    _lastNotified[userId] = DateTime.now();

    // If GlobalSocketService couldn't resolve the name, try again here
    final String displayName = username.isNotEmpty
        ? username
        : await _resolveUsernameFromHive(userId);

    debugPrint('🟢 Firing notification — "$displayName" ($userId)');

    await _showLocalNotification(userId: userId, username: displayName);
    _showInAppBanner(username: displayName);
  }

  // ── Hive fallback name lookup ──────────────────────────────────────────────
  Future<String> _resolveUsernameFromHive(String userId) async {
    try {
      final Box<ChatListItemHive> box = Hive.isBoxOpen('chats')
          ? Hive.box<ChatListItemHive>('chats')
          : await Hive.openBox<ChatListItemHive>('chats');

      for (final chat in box.values) {
        final storedId = chat.userId.toString().trim();
        if (storedId == userId || chat.id == userId) {
          final name = chat.title.trim();
          if (name.isNotEmpty) {
            debugPrint('✅ Hive resolved "$name" for $userId');
            return name;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Hive lookup failed: $e');
    }
    return userId.length > 8 ? userId.substring(0, 8) : userId;
  }

  // ── Local push notification ────────────────────────────────────────────────
  Future<void> _showLocalNotification({
    required String userId,
    required String username,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Friend online alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFF00C853),
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
          styleInformation: BigTextStyleInformation(
            '$username is online, tap to have a conversation',
            contentTitle: '🟢 $username is online',
            htmlFormatBigText: false,
            htmlFormatContentTitle: false,
          ),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    // Stable ID per user so repeated events replace each other
    final int notifId = userId.hashCode.abs() % 2147483647;

    await _localNotifications.show(
      id: notifId,
      title: '🟢 $username is online',
      body: 'Tap to have a conversation',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: 'online:$userId',
    );
  }

  // ── In-app floating banner (foreground only) ───────────────────────────────
  void _showInAppBanner({required String username}) {
    final BuildContext? context = _navigatorKey?.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1B1B1B),
        elevation: 6,
        content: Row(
          children: [
            // Green online dot
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00C853),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$username is online',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to have a conversation',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── dispose ────────────────────────────────────────────────────────────────
  void dispose() {
    _onlineSubscription?.cancel();
    _onlineSubscription = null;
  }
}
