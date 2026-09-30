import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-chat toggle settings locally using SharedPreferences.
///
/// Key alignment with AppPreferenceHelper:
///   - Mute      → "muted_chats_<chatId>"   (matches mutedChats() pattern)
///   - Wallpaper → "wallpaper_<chatId>"      (matches chatWallpaper(chatId))
///   - Others    → "qiktalk_<setting>_<chatId>"
class ChatSettingsPersistenceService {
  // ── Keys — aligned with AppPreferenceHelper where applicable ──────────────

  /// Matches AppPreferenceHelper.mutedChats() pattern → "muted_chats_<chatId>"
  static String _muteKey(String chatId) => 'muted_chats_$chatId';

  /// Matches AppPreferenceHelper.chatWallpaper(chatId) → "wallpaper_<chatId>"
  /// We use this for the background color value (int) stored alongside wallpaper.
  static String _customBgColorKey(String chatId) => 'wallpaper_color_$chatId';

  // Standard per-chat keys
  static String _protectedKey(String chatId) => 'qiktalk_protected_$chatId';
  static String _hideChatKey(String chatId) => 'qiktalk_hide_$chatId';
  static String _hideChatHistoryKey(String chatId) =>
      'qiktalk_hide_history_$chatId';
  static String _customColorKey(String chatId) => 'qiktalk_color_$chatId';

  // ── Mute Notification ─────────────────────────────────────────────────────
  Future<bool> getMuted(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final perChat = prefs.getBool(_muteKey(chatId));
    if (perChat != null) return perChat;
    final raw = prefs.getString('muted_chats') ?? '';
    if (raw.isNotEmpty) {
      final ids = raw.split(',').map((e) => e.trim()).toList();
      return ids.contains(chatId);
    }
    return false;
  }

  Future<void> setMuted(String chatId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey(chatId), value);
    final raw = prefs.getString('muted_chats') ?? '';
    final ids = raw.isNotEmpty
        ? raw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    if (value && !ids.contains(chatId)) {
      ids.add(chatId);
    } else if (!value) {
      ids.remove(chatId);
    }
    await prefs.setString('muted_chats', ids.join(','));
  }

  // ── Protected Chat ────────────────────────────────────────────────────────
  Future<bool> getProtected(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_protectedKey(chatId)) ?? false;
  }

  Future<void> setProtected(String chatId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_protectedKey(chatId), value);
  }

  // ── Hide Chat ─────────────────────────────────────────────────────────────
  Future<bool> getHideChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideChatKey(chatId)) ?? false;
  }

  Future<void> setHideChat(String chatId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideChatKey(chatId), value);
  }

  // ── Hide Chat History ─────────────────────────────────────────────────────
  Future<bool> getHideChatHistory(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideChatHistoryKey(chatId)) ?? false;
  }

  Future<void> setHideChatHistory(String chatId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideChatHistoryKey(chatId), value);
  }

  // ── Custom Chat Color ─────────────────────────────────────────────────────

  Future<int?> getCustomColor(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      _customColorKey(chatId),
    ); // ✅ always 'qiktalk_color_<chatId>'
  }

  /// Pass null to clear the custom color (user chose "Default").
  Future<void> setCustomColor(String chatId, int? colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    if (colorValue == null) {
      // ✅ Remove using the SAME key so getCustomColor returns null
      await prefs.remove(_customColorKey(chatId));
    } else {
      await prefs.setInt(_customColorKey(chatId), colorValue);
    }
  }

  /// Convenience alias — same as setCustomColor(chatId, null).
  Future<void> removeCustomColor(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customColorKey(chatId));
  }

  // ── Custom Background Color ───────────────────────────────────────────────
  Future<int?> getCustomBgColor(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_customBgColorKey(chatId));
  }

  Future<void> setCustomBgColor(String chatId, int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customBgColorKey(chatId), colorValue);
  }

  // ── Load all settings at once ─────────────────────────────────────────────
  Future<ChatLocalSettings> loadAll(String chatId) async {
    final prefs = await SharedPreferences.getInstance();

    bool muted = prefs.getBool(_muteKey(chatId)) ?? false;
    if (!muted) {
      final raw = prefs.getString('muted_chats') ?? '';
      if (raw.isNotEmpty) {
        muted = raw.split(',').map((e) => e.trim()).contains(chatId);
      }
    }

    return ChatLocalSettings(
      muted: muted,
      protected: prefs.getBool(_protectedKey(chatId)) ?? false,
      hideChat: prefs.getBool(_hideChatKey(chatId)) ?? false,
      hideChatHistory: prefs.getBool(_hideChatHistoryKey(chatId)) ?? false,
      customColor: prefs.getInt(_customColorKey(chatId)), // ✅ consistent key
      customBgColor: prefs.getInt(_customBgColorKey(chatId)),
    );
  }
}

/// Value object holding all local settings for a single chat.
class ChatLocalSettings {
  final bool muted;
  final bool protected;
  final bool hideChat;
  final bool hideChatHistory;
  final int? customColor;
  final int? customBgColor;

  const ChatLocalSettings({
    required this.muted,
    required this.protected,
    required this.hideChat,
    required this.hideChatHistory,
    this.customColor,
    this.customBgColor,
  });
}
