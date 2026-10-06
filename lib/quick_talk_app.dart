import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:qik_talk/features/feed/domain/services/feed_deep_link_service.dart';
import 'package:qik_talk/utilities/components/app_lock_wrapper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_lifecycle_manager.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/services/offline_message_queue.dart';
import 'package:upgrader/upgrader.dart';

import 'features/calls/global_call_listener.dart';
import 'features/calls/providers/call_state_provider.dart';
import 'utilities/constants/app_theme.dart';
import 'features/chat/general/data/chat_list_item_hive.dart';
import 'features/chat/general/services/deep_link_service.dart';
import 'features/chat/single_chat/screens/message_screen.dart';
import 'features/feed/presentation/screens/feed_profile_screen.dart';
import 'features/feed/presentation/screens/qik_flash_screen.dart';
import 'features/feed/presentation/state/data/get_feed_response_data.dart';
import 'features/feed/presentation/state/provider/feed_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/notifications/services/online_presence_notification_service.dart';
import 'features/settings/theme/provider/theme_provider.dart';
import 'features/wallet/features/account_statement/screens/account_statement_screen.dart';
import 'features/wallet/features/e_bills/cable/screens/cable_tv_screen.dart';
import 'features/wallet/features/e_bills/electricity/screens/electricity_bill_screen.dart';
import 'features/wallet/features/savings/group_savings/screens/group_savings_screen.dart';
import 'features/wallet/features/savings/screens/withdrawal_screen.dart';
import 'features/wallet/features/savings/screens/savings_screen.dart';
import 'features/wallet/features/virtual_card/screens/fund_card_screen.dart';
import 'features/wallet/features/virtual_card/screens/virtual_card_screen.dart';
import 'features/wallet/features/e_bills/mobile_data/mobile_data_screen.dart';
import 'features/wallet/features/wallet_setup/screens/wallet_intro_screen.dart';
import 'features/welcome/splash/screens/splash_screen.dart';
import 'features/welcome/splash/provider/splash_provider.dart';
import 'features/welcome/onboarding/screens/onboarding_screen.dart';
import 'utilities/bottom_nav/screen/custom_bottom_nav.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class QuickTalkApp extends ConsumerStatefulWidget {
  const QuickTalkApp({super.key});

  @override
  ConsumerState<QuickTalkApp> createState() => _QuickTalkAppState();
}

class _QuickTalkAppState extends ConsumerState<QuickTalkApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final SaveValues _saveValues = SaveValues();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ── Step 0: Trigger splash screen login check ─────────────────────────────
    ref.read(splashProvider.notifier).checkLogin();

    // ── Step 1: Connect socket immediately ────────────────────────────────────
    _connectSocket();

    // ── Step 2: Initialize FCM + local notification channels ─────────────────
    _initializeNotifications();

    // ── Step 3: Listen for CallKit events (Background Calls) ──────────────────
    _listenToCallKitEvents();

    // ── Step 4: Post-frame tasks — navigator is ready at this point ───────────
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Deep links
      DeepLinkService.init(navigatorKey);
      PostDeepLinkService.init(navigatorKey);

      // Wait for NotificationService.initialize() to fully complete
      // before OnlinePresenceNotificationService tries to show notifications.
      // The 2-second delay guarantees the Android notification channel
      // created inside NotificationService is registered before we fire any
      // 'user online' notifications through it.
      await Future.delayed(const Duration(seconds: 2));
      await OnlinePresenceNotificationService().initialize(navigatorKey);
      print('✅ OnlinePresenceNotificationService initialized');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkService.dispose();
    PostDeepLinkService.dispose();
    OnlinePresenceNotificationService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('📱 App resumed — reconnecting socket & processing queue');
      _connectSocket();
      _processOfflineQueue();
    } else if (state == AppLifecycleState.paused) {
      print('📱 App paused');
    }
  }

  void _listenToCallKitEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallAccept:
          debugPrint('📞 CallKit: User accepted call in background');
          // Handle navigation after a short delay to ensure app is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            ref.read(callStateProvider.notifier).acceptCall();
            // GlobalCallListener will handle the navigation to OngoingCallScreen
          });
          break;

        case Event.actionCallDecline:
          debugPrint('📞 CallKit: User declined call in background');
          ref.read(callStateProvider.notifier).endCall();
          break;

        case Event.actionCallEnded:
          debugPrint('📞 CallKit: Call ended');
          ref.read(callStateProvider.notifier).endCall();
          break;

        default:
          break;
      }
    });
  }

  // ── Socket ─────────────────────────────────────────────────────────────────
  Future<void> _connectSocket() async {
    final authToken = await _saveValues.getString(
      AppPreferenceHelper.AUTH_TOKEN,
    );
    if (authToken != null && authToken.isNotEmpty) {
      await GlobalSocketService().connect();
    }
  }

  Future<void> _processOfflineQueue() async {
    try {
      final queue = OfflineMessageQueue();
      if (queue.pendingCount > 0) {
        print('📤 Processing ${queue.pendingCount} queued messages...');
        await GlobalSocketService().processOfflineQueue();
      }
    } catch (e) {
      print('❌ Error processing queue in main: $e');
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  Future<void> _initializeNotifications() async {
    final notificationService = NotificationService();

    // ✅ Must be awaited so all channels are created before
    // OnlinePresenceNotificationService tries to use them.
    await notificationService.initialize();

    final authToken = await _saveValues.getString(
      AppPreferenceHelper.AUTH_TOKEN,
    );
    if (authToken != null && authToken.isNotEmpty) {
      print('🔄 User is logged in, uploading FCM token...');
      await notificationService.uploadTokenToBackend();
    }

    notificationService.onQuickReply = (String chatId, String replyText) async {
      // The message was already sent by the notification handler:
      //  • foreground  → _onNotificationResponse (notification_service.dart)
      //  • background/terminated → notificationBackgroundHandler (top-level)
      // This callback only clears any leftover notification badge.
      debugPrint(
        '💬 onQuickReply — clearing notification badge for chat: $chatId',
      );
      await NotificationService().clearChatNotifications(chatId);
    };

    notificationService.onNotificationTap = (Map<String, dynamic> data) {
      final type = data['type'] as String? ?? '';
      print('🔔 Notification tapped — type: $type, data: $data');

      Future.delayed(const Duration(milliseconds: 500), () {
        switch (type) {
          case 'CHAT_MESSAGE':
            // ✅ Never navigate to chat while a call is active
            final callState = ref.read(callStateProvider);
            if (callState != null &&
                callState.state != CallState.ended &&
                callState.state != CallState.failed) {
              debugPrint('📵 Ignoring CHAT_MESSAGE nav — call is active');
              break;
            }
            final chatId = data['chatId'] as String? ?? '';
            final senderId = data['senderId'] as String? ?? '';
            if (chatId.isNotEmpty && senderId.isNotEmpty) {
              _navigateToChat(chatId, senderId);
            }
            break;

          case 'POST_LIKED':
          case 'POST_COMMENTED':
          case 'POST_BOOKMARKED':
            final postId = data['postId'] as String? ?? '';
            if (postId.isNotEmpty) _navigateToPost(postId);
            break;

          case 'USER_FOLLOWED':
            final followerId = data['followerId'] as String? ?? '';
            if (followerId.isNotEmpty) _navigateToProfile(followerId);
            break;

          // ✅ Status reshare — navigates to Status tab via CustomBottomNav
          case 'STATUS_RESHARED':
            print('🔁 STATUS_RESHARED notification tapped');
            // CustomBottomNav handles routing to the Status tab
            break;

          // ✅ Online presence tap — navigate to the chat with that user
          case 'online':
            final onlineCallState = ref.read(callStateProvider);
            if (onlineCallState != null &&
                onlineCallState.state != CallState.ended &&
                onlineCallState.state != CallState.failed) {
              debugPrint('📵 Ignoring online nav — call is active');
              break;
            }
            final payload = data['payload'] as String? ?? '';
            final userId = payload.replaceFirst('online:', '').trim();
            if (userId.isNotEmpty) {
              _navigateToChatByUserId(userId);
            }
            break;

          case 'INCOMING_CALL':
            // Backend sent FCM push when app was in background/killed.
            // GlobalCallListener handles the UI when socket fires 'call user'.
            debugPrint(
              '📲 INCOMING_CALL notification tapped — waiting for socket',
            );
            break;

          default:
            print('⚠️ Unhandled notification type: $type');
        }
      });
    };
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────
  Future<void> _navigateToChat(String chatId, String senderId) async {
    print('🔔 _navigateToChat — chatId: $chatId, senderId: $senderId');

    int attempts = 0;
    while (navigatorKey.currentState == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    if (navigatorKey.currentState == null) {
      print('❌ Navigator not ready');
      return;
    }

    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      final chatItem = chatBox.get(chatId);

      final username = chatItem?.title ?? 'User';
      final profilePicture = chatItem?.profilePicture ?? '';
      final about = chatItem?.about ?? '';

      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatId,
            userId: senderId,
            username: username,
            lastSeenActive: '',
            profilePicture: profilePicture,
            about: about,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to chat: $e');
    }
  }

  /// Called when user taps an "online" notification — finds the chat by userId
  Future<void> _navigateToChatByUserId(String userId) async {
    print('🔔 _navigateToChatByUserId — userId: $userId');

    int attempts = 0;
    while (navigatorKey.currentState == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    if (navigatorKey.currentState == null) return;

    try {
      final chatBox = Hive.isBoxOpen('chats')
          ? Hive.box<ChatListItemHive>('chats')
          : await Hive.openBox<ChatListItemHive>('chats');

      // Find the chat where the other user matches userId
      ChatListItemHive? chatItem;
      for (final chat in chatBox.values) {
        if (chat.userId == userId) {
          chatItem = chat;
          break;
        }
      }

      if (chatItem == null) {
        print('⚠️ No chat found for userId $userId');
        return;
      }

      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatItem!.id,
            userId: userId,
            username: chatItem.title,
            lastSeenActive: '',
            profilePicture: chatItem.profilePicture,
            about: chatItem.about,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to chat by userId: $e');
    }
  }

  Future<void> _navigateToPost(String postId) async {
    print('🔔 _navigateToPost — postId: $postId');

    int attempts = 0;
    while (navigatorKey.currentState == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    if (navigatorKey.currentState == null) return;

    try {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);

      final feedState = ref.read(feedProvider);
      final rawPosts = [
        ...feedState.followingPosts,
        ...feedState.personalizedPosts,
      ];
      final idx = rawPosts.indexWhere((p) => p.id == postId);

      final List<GetFeedResponseData> displayPosts = idx != -1
          ? rawPosts
          : [
              GetFeedResponseData(
                id: postId,
                user: const FeedUser(id: '', username: 'Loading...'),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ];

      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => QikFlashScreen(
            posts: displayPosts,
            initialPostIndex: idx != -1 ? idx : 0,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to post: $e');
    }
  }

  Future<void> _navigateToProfile(String userId) async {
    print('🔔 _navigateToProfile — userId: $userId');

    int attempts = 0;
    while (navigatorKey.currentState == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    if (navigatorKey.currentState == null) return;

    try {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            user: FeedUser(id: userId, username: 'Loading...'),
            isCurrentUser: false,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to profile: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final textSizeIndex = ref.watch(textSizeProvider);
    final scaleFactor = TextSizeNotifier.toScaleFactor(textSizeIndex);
    final splashState = ref.watch(splashProvider);

    // Show splash screen during initial loading
    if (splashState == SplashState.loading) {
      return MaterialApp(
        title: 'QikTalk',
        themeMode: themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    // After splash completes, wrap the main app with AppLockWrapper
    return AppLifecycleManager(
      child: GlobalCallListener(
        navigatorKey: navigatorKey,
        child: AppLockWrapper(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [routeObserver],
            title: 'QikTalk',
            themeMode: themeMode,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scaleFactor)),
                child: child!,
              );
            },
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            debugShowCheckedModeBanner: false,
            home: UpgradeAlert(
              child: splashState == SplashState.loggedIn
                  ? const CustomBottomNav()
                  : const SlidersPage(),
            ),
          ),
        ),
      ),
    );
  }
}
