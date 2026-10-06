import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:qik_talk/features/calls/global_call_listener.dart';
import 'package:qik_talk/features/calls/models/call_log_model.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/chat/general/services/deep_link_service.dart';
import 'package:qik_talk/features/notifications/services/online_presence_notification_service.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/offline_message_queue.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:audio_session/audio_session.dart';

import 'features/chat/general/data/chat_list_item_hive.dart';
import 'features/chat/general/data/chat_message_hive.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/settings/account/screens/data_and_storage/services/local_storage_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized
  }

  await Hive.initFlutter();
  await DBService.init();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ChatListItemHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ChatMessageHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(QueuedMessageAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(MediaCacheEntryAdapter());
  }

  try {
    if (!Hive.isBoxOpen('chats')) {
      await Hive.openBox<ChatListItemHive>('chats');
    }
    if (!Hive.isBoxOpen('chat_messages')) {
      await Hive.openBox<List>('chat_messages');
    }
  } catch (e) {
    print('⚠️ Error opening Hive boxes in background: $e');
  }

  print('📨 Background message: ${message.messageId}');
  await firebaseMessagingBackgroundHandler(message);
}

class MainUtility {
  static Future<void> asyncActions() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ========== FIREBASE ==========
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) print('Firebase already initialized: $e');
    }
    await Hive.initFlutter();
    const bool clearHiveOnDebugStart = false;
    if (kDebugMode && clearHiveOnDebugStart) {
      await Hive.deleteBoxFromDisk('chats');
      await Hive.deleteBoxFromDisk('chat_messages');
    }

    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(ChatListItemHiveAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(ChatMessageHiveAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(QueuedMessageAdapter());
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(MediaCacheEntryAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(CallLogAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(CallTypeAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(CallStatusAdapter());

    try {
      await Hive.openBox<ChatListItemHive>('chats');
    } catch (e) {
      debugPrint('⚠️ Hive chats box corrupt, clearing and reopening: $e');
      try {
        await Hive.deleteBoxFromDisk('chats');
      } catch (deleteError) {
        debugPrint('⚠️ Could not delete chats box: $deleteError');
      }
      await Hive.openBox<ChatListItemHive>('chats');
    }

    try {
      await Hive.openBox<List>('chat_messages');
    } catch (e) {
      debugPrint(
        '⚠️ Hive chat_messages box corrupt, clearing and reopening: $e',
      );
      try {
        await Hive.deleteBoxFromDisk('chat_messages');
      } catch (deleteError) {
        debugPrint('⚠️ Could not delete chat_messages box: $deleteError');
      }
      await Hive.openBox<List>('chat_messages');
    }

    try {
      await Hive.openBox<CallLog>('call_logs');
    } catch (e) {
      debugPrint('⚠️ Hive call_logs box corrupt, clearing and reopening: $e');
      await Hive.deleteBoxFromDisk('call_logs');
      await Hive.openBox<CallLog>('call_logs');
    }

    try {
      await Hive.openBox('status_cache');
    } catch (e) {
      debugPrint(
        '⚠️ Hive status_cache box corrupt, clearing and reopening: $e',
      );
      await Hive.deleteBoxFromDisk('status_cache');
      await Hive.openBox('status_cache');
    }

    print('🚀 Initializing app services...');

    await OfflineMessageQueue().initialize();
    print('✅ Offline queue initialized');

    await MediaCacheService().initialize();
    print('✅ Media cache initialized');

    GlobalSocketService();
    print('✅ Socket service ready');

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          // iOS only — these 4 lines are fine to keep, they're just ignored on Android
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,

          // Android — this is what actually matters on Android
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
        ),
      );
      print('✅ Audio session configured');
    } catch (e) {
      print('⚠️ Audio session configuration failed (non-fatal): $e');
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Color(AppColors.primaryBackgroundColor),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
