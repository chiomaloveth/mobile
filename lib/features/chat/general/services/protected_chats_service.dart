import 'package:shared_preferences/shared_preferences.dart';

/// Manages the list of chat IDs that the user has locked (protected).
///
/// Key: "protected_chat_ids"  →  List<String>
///
/// This is separate from the per-chat setting key
/// (qiktalk_protected_<chatId>) stored in ChatSettingsPersistenceService.
/// The per-chat key tracks whether the user has *enabled* the protected
/// setting; this service tracks which chats are currently *active* in the
/// protected list (i.e. hidden from main lists).
class ProtectedChatsService {
  static const String _kProtectedChatIds = 'protected_chat_ids';

  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ProtectedChatsService _instance =
      ProtectedChatsService._internal();
  factory ProtectedChatsService() => _instance;
  ProtectedChatsService._internal();

  // ── In-memory cache so we avoid repeated SharedPreferences reads ───────────
  List<String>? _cachedIds;

  Future<List<String>> _loadIds() async {
    if (_cachedIds != null) return List.from(_cachedIds!);
    final prefs = await SharedPreferences.getInstance();
    _cachedIds = prefs.getStringList(_kProtectedChatIds) ?? [];
    return List.from(_cachedIds!);
  }

  Future<void> _saveIds(List<String> ids) async {
    _cachedIds = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kProtectedChatIds, ids);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the current list of protected chat IDs.
  Future<List<String>> getProtectedChatIds() => _loadIds();

  /// Returns the number of protected chats.
  Future<int> getProtectedCount() async {
    final ids = await _loadIds();
    return ids.length;
  }

  /// Returns true if [chatId] is currently in the protected list.
  Future<bool> isProtected(String chatId) async {
    final ids = await _loadIds();
    return ids.contains(chatId);
  }

  /// Adds [chatId] to the protected list. No-op if already present.
  Future<void> addProtectedChat(String chatId) async {
    final ids = await _loadIds();
    if (!ids.contains(chatId)) {
      ids.add(chatId);
      await _saveIds(ids);
    }
  }

  /// Removes [chatId] from the protected list. No-op if not present.
  Future<void> removeProtectedChat(String chatId) async {
    final ids = await _loadIds();
    if (ids.remove(chatId)) {
      await _saveIds(ids);
    }
  }

  /// Forces a reload from disk on the next read (call after external changes).
  void invalidateCache() => _cachedIds = null;
}
