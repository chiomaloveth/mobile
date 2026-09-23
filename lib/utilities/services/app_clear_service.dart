import 'package:flutter/painting.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/status/services/status_cache_service.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/offline_message_queue.dart';

/// Clears ALL locally stored / cached data for the current user.
///
/// Call this immediately after a successful logout or account deletion so
/// that the next user who logs in on this device starts with a clean slate.
class AppClearService {
  // Every Hive box name used anywhere in the app.
  static const _hiveBoxes = [
    'chats',
    'chat_messages',
    'call_logs',
    'status_cache',
    'media_cache',
    'offline_message_queue',
    'messages_box',
    'media_box',
    'documents_box',
    'stats_box',
    'settings_box',
    'broadcast_messages',
  ];

  /// Wipes every local data store:
  ///   • SharedPreferences (all keys)
  ///   • Hive boxes — cleared in-place (boxes stay open so widgets don't
  ///     crash), then deleted from disk after navigation away
  ///   • Downloaded media files (MediaCacheService + StatusCacheService)
  ///   • Flutter's in-memory image cache
  static Future<void> clearAll() async {
    // ── 1. SharedPreferences — wipe every key ────────────────────────────
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      _log('SharedPreferences clear error: $e');
    }

    // ── 2. Hive boxes — clear contents only ──────────────────────────────
    // We intentionally do NOT close or deleteBoxFromDisk here because
    // widgets (ChatComponent, etc.) may still be mounted and watching the
    // boxes via ValueListenableBuilder. Closing a box while a widget is
    // listening to it throws "Box has already been closed".
    //
    // Clearing the contents is sufficient — the next user will see empty
    // boxes. The box files on disk will be overwritten with fresh data
    // when the new user logs in and the app re-populates them.
    for (final boxName in _hiveBoxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          // Open, clear, then close — safe because no widget is watching
          // a box that isn't open yet
          final box = await Hive.openBox(boxName);
          await box.clear();
          await box.close();
        }
      } catch (e) {
        _log('Hive box "$boxName" clear error: $e');
      }
    }

    // ── 3. Offline message queue (typed box) ─────────────────────────────
    try {
      await OfflineMessageQueue().clear();
    } catch (e) {
      _log('OfflineMessageQueue clear error: $e');
    }

    // ── 4. Downloaded media files ─────────────────────────────────────────
    try {
      await MediaCacheService().clearCache();
    } catch (e) {
      _log('MediaCacheService clear error: $e');
    }

    // ── 5. Status media files ─────────────────────────────────────────────
    try {
      await StatusCacheService.clear();
    } catch (e) {
      _log('StatusCacheService clear error: $e');
    }

    // ── 6. Flutter in-memory image cache ─────────────────────────────────
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      _log('ImageCache clear error: $e');
    }

    _log('✅ AppClearService: all local data cleared');
  }

  static void _log(String msg) {
    // ignore: avoid_print
    print('[AppClearService] $msg');
  }
}
