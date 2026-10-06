import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/calls/models/call_log_model.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/services/local_storage_service.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/offline_message_queue.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(CallLogAdapter());
    registerAdapter(CallTypeAdapter());
    registerAdapter(CallStatusAdapter());
    registerAdapter(MessageModelAdapter());
    registerAdapter(MediaModelAdapter());
    registerAdapter(DocumentModelAdapter());
    registerAdapter(NetworkStatsModelAdapter());
    registerAdapter(ChatListItemHiveAdapter());
    registerAdapter(ChatMessageHiveAdapter());
    registerAdapter(MediaCacheEntryAdapter());
    registerAdapter(QueuedMessageAdapter());
  }
}
