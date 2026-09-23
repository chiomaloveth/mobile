class AppPreferenceHelper {
  static final String FIRST_NAME = "FIRST_NAME";
  static final String PROFILE_IMAGE = "PROFILE_IMAGE";
  static final String USER_NAME = "USER_NAME";
  static final String FULL_NAME = "FULL_NAME";
  static final String ABOUT = "ABOUT";
  static final String LAST_NAME = "LAST_NAME";
  static final String EMAIL_ADDRESS = "EMAIL_ADDRESS";
  static final String PASSWORD = "PASSWORD";
  static final String REMEMBER_ME = "REMEMBER_ME";
  static final String ONBOARDING_COMPLETED = "ONBOARDING_COMPLETED";
  static final String ID = "ID";
  static final String HAS_PASSWORD = "HAS_PASSWORD";
  static final String PHONE_NUMBER = "PHONE_NUMBER";
  static final String SELECTED_TOKEN = "SELECTED_TOKEN";
  static final String AUTH_TOKEN = "AUTH_TOKEN";
  static final String REFRESH_TOKEN = "REFRESH_TOKEN";
  static final String FCM_TOKEN = "FCM_TOKEN";
  /// Temporary token returned by login when 2FA is required.
  /// Cleared once 2FA verification succeeds and the real AUTH_TOKEN is stored.
  static const String TEMP_TOKEN = "TEMP_TOKEN";
  static const String AI_ONBOARDING_COMPLETED = "ai_onboarding_completed";
  static const String HAS_SEEN_INTERESTS = "has_seen_interests";

  // ✅ Starred messages
  static const String STARRED_MESSAGES = "starred_messages";

  // ✅ Archive & Mute
  static String archivedChats() => "archived_chats";
  static String mutedChats() => "muted_chats";
  static String deletedMessages(String chatId) => "deleted_messages_$chatId";

  // ✅ NEW: Wallpaper settings
  static const String GLOBAL_WALLPAPER =
      "global_wallpaper"; // String (path or 'default_X')
  static String chatWallpaper(String chatId) =>
      "wallpaper_$chatId"; // Per-chat wallpaper

  // ✅ Archive behavior
  static const String USER_INFO_CACHE = "user_info_cache";
  static const String USER_POSTS_CACHE = "user_posts_cache";
  static const String UNARCHIVE_ON_NEW_MESSAGE = "unarchive_on_new_message";
}
