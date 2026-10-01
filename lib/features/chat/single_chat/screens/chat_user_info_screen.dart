import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/protected_chats_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_to_groups_screen.dart';
import 'package:qik_talk/features/chat/general/screens/chat_media_tab_screen.dart';
import 'package:qik_talk/features/chat/general/screens/profile_picture_viewer.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_tone_selection_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/protected_chat_screen.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/user_profile_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/single_chat_dialogs.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/chat_lock_auth_helper.dart';
import 'package:qik_talk/utilities/helpers/mute_chat_dialog.dart';
import 'package:qik_talk/utilities/helpers/wallpaper_picker_dialog.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/user_profile_cache_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/model/user_profile_model.dart';

class ChatUserInfoScreen extends StatefulWidget {
  final String userId;
  final String? username;
  final String? phone;
  final String? profilePicture;
  final String? about;
  final bool? isOnline;
  final int mediaCount;

  // ── chatId is needed so wallpaper key matches MessageScreen ──────────────
  // MessageScreen saves wallpaper as chatWallpaper(chatId).
  // If chatId is not provided we fall back to userId (single-chat chatId
  // often equals userId in many backends, but pass it explicitly to be safe).
  final String? chatId;

  const ChatUserInfoScreen({
    Key? key,
    required this.userId,
    this.username,
    this.phone,
    this.profilePicture,
    this.about,
    this.isOnline,
    this.mediaCount = 0,
    this.chatId, // ✅ optional — falls back to userId
  }) : super(key: key);

  @override
  State<ChatUserInfoScreen> createState() => _ChatUserInfoScreenState();
}

class _ChatUserInfoScreenState extends State<ChatUserInfoScreen> {
  final UserProfileService _profileService = UserProfileService();
  final ChatSettingsPersistenceService _settingsSvc =
      ChatSettingsPersistenceService();

  // ── The key used for wallpaper + other settings must match MessageScreen ──
  // MessageScreen calls: AppPreferenceHelper.chatWallpaper(widget.chatId)
  // So we must use chatId here, not userId.
  String get _settingsKey => widget.chatId ?? widget.userId;

  bool isLoading = false; // never block — render instantly
  UserProfile? userProfile;
  String? errorMessage;

  // ── Cached fallback fields — loaded from SharedPreferences instantly ──────
  String _cachedUsername = '';
  String _cachedPhone = '';
  String _cachedAbout = '';
  String _cachedProfilePicture = '';

  // ── Persisted toggle states ───────────────────────────────────────────────
  bool muteNotification = false;
  bool protectedChat = false;
  bool hideChat = false;
  bool hideChatHistory = false;
  Color customChatColor = const Color(0xFF4A90E2);
  bool _isUserBlocked = false; // ✅ Track block state on info screen

  @override
  void initState() {
    super.initState();
    // ── Step 1: Load cache instantly (works offline) ──────────────────────
    _loadCachedProfile();
    // ── Step 2: Load settings (local only, no network) ───────────────────
    _loadMuteStatus();
    _loadPersistedSettings();
    _loadBlockedStateForInfoScreen();
    // ── Step 3: Refresh from network silently in background ───────────────
    _loadUserProfile();
  }

  /// Load cached profile immediately — no network needed.
  Future<void> _loadCachedProfile() async {
    // First try widget props (passed from chat screen — always fresh)
    if (widget.username?.isNotEmpty == true ||
        widget.profilePicture?.isNotEmpty == true) {
      if (mounted) {
        setState(() {
          _cachedUsername = widget.username ?? '';
          _cachedPhone = widget.phone ?? '';
          _cachedAbout = widget.about ?? '';
          _cachedProfilePicture = widget.profilePicture ?? '';
        });
      }
    }

    // Then check SharedPreferences for richer cached data
    final cached = await UserProfileCacheService.load(widget.userId);
    if (cached != null && mounted) {
      setState(() {
        if ((cached['username'] as String? ?? '').isNotEmpty) {
          _cachedUsername = cached['username'] as String;
        }
        if ((cached['phone'] as String? ?? '').isNotEmpty) {
          _cachedPhone = cached['phone'] as String;
        }
        if ((cached['about'] as String? ?? '').isNotEmpty) {
          _cachedAbout = cached['about'] as String;
        }
        if ((cached['profilePicture'] as String? ?? '').isNotEmpty) {
          _cachedProfilePicture = cached['profilePicture'] as String;
        }
      });
    }
  }

  Future<void> _loadBlockedStateForInfoScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('blocked_user_ids') ?? [];
    final chatBox = await Hive.openBox<ChatListItemHive>('chats');
    final chatItem = chatBox.get(widget.chatId ?? widget.userId);
    if (mounted) {
      setState(() {
        _isUserBlocked =
            blocked.contains(widget.userId) || chatItem?.isBlocked == true;
      });
    }
  }

  // ── Load persisted settings ───────────────────────────────────────────────
  Future<void> _loadPersistedSettings() async {
    final s = await _settingsSvc.loadAll(_settingsKey);
    if (!mounted) return;
    setState(() {
      protectedChat = s.protected;
      hideChat = s.hideChat;
      hideChatHistory = s.hideChatHistory;
      if (s.customColor != null) customChatColor = Color(s.customColor!);
    });
  }

  // ── Mute: read from Hive (same system as chat list) ──────────────────────
  Future<void> _loadMuteStatus() async {
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      // Try chatId first, fall back to userId
      final chatItem = chatBox.get(_settingsKey) ?? chatBox.get(widget.userId);
      if (chatItem != null && mounted) {
        setState(() => muteNotification = chatItem.isCurrentlyMuted);
      }
    } catch (e) {
      debugPrint('❌ Error loading mute status: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    // Silent background fetch — screen already shows cached data
    try {
      final profile = await _profileService.fetchUserProfile(widget.userId);
      if (profile != null && mounted) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
        // ── Save fresh data to cache for next offline session ─────────────
        await UserProfileCacheService.save(
          userId: widget.userId,
          data: {
            'username': profile.username,
            'phone': profile.phone,
            'about': profile.about,
            'profilePicture': profile.profilePicture,
            'isOnline': profile.isOnline,
            'lastActive': profile.lastActive?.toIso8601String() ?? '',
          },
        );
        // Also update cached fields so UI reflects fresh data immediately
        if (mounted) {
          setState(() {
            if (profile.username.isNotEmpty) _cachedUsername = profile.username;
            if (profile.phone.isNotEmpty) _cachedPhone = profile.phone;
            if (profile.about.isNotEmpty) _cachedAbout = profile.about;
            if (profile.profilePicture.isNotEmpty) {
              _cachedProfilePicture = profile.profilePicture;
            }
          });
        }
      } else if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('⚠️ Could not load profile (offline?): $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── Privacy helpers ───────────────────────────────────────────────────────
  // ── Display getters: API data → cached data → widget props ───────────────
  // This 3-tier fallback ensures the screen always shows something meaningful
  // even when offline or before the API responds.

  String get displayUsername {
    // Tier 1: live API data
    if (userProfile?.username?.isNotEmpty == true) return userProfile!.username;
    // Tier 2: cached data from SharedPreferences
    if (_cachedUsername.isNotEmpty) return _cachedUsername;
    // Tier 3: widget props passed from chat screen
    if (widget.username?.isNotEmpty == true) return widget.username!;
    return 'Loading...';
  }

  String get displayPhone {
    // Show cached/widget phone even when API privacy says hidden
    // (the person already knows their own contact's number)
    if (userProfile != null && userProfile!.privacy.showPhone) {
      return userProfile!.phone.isNotEmpty ? userProfile!.phone : _cachedPhone;
    }
    // Offline: show cached phone
    if (_cachedPhone.isNotEmpty) return _cachedPhone;
    if (widget.phone?.isNotEmpty == true) return widget.phone!;
    return ''; // empty = don't show the pill at all
  }

  String get displayAbout {
    if (userProfile != null && userProfile!.privacy.showAbout) {
      return userProfile!.about.isEmpty ? 'No bio' : userProfile!.about;
    }
    if (_cachedAbout.isNotEmpty) return _cachedAbout;
    if (widget.about?.isNotEmpty == true) return widget.about!;
    return '';
  }

  String get displayProfilePicture {
    if (userProfile != null &&
        userProfile!.privacy.showProfilePicture &&
        userProfile!.profilePicture.isNotEmpty) {
      return userProfile!.profilePicture;
    }
    if (_cachedProfilePicture.isNotEmpty) return _cachedProfilePicture;
    return widget.profilePicture ?? '';
  }

  bool get displayIsOnline => (userProfile?.privacy.showOnlineStatus ?? false)
      ? (userProfile?.isOnline ?? false)
      : false;

  String get displayLastSeen => (userProfile?.privacy.showLastSeen ?? false)
      ? userProfile!.getLastSeenText()
      : 'Not available';

  List<String> get profilePictures {
    if (userProfile != null &&
        userProfile!.privacy.showProfilePicture &&
        userProfile!.profilePictures != null &&
        userProfile!.profilePictures!.isNotEmpty) {
      return userProfile!.profilePictures!;
    }
    if (displayProfilePicture.isNotEmpty) return [displayProfilePicture];
    return [];
  }

  // ── Toggle handlers (all persisted) ──────────────────────────────────────

  /// Locks or unlocks the chat with biometric authentication.
  /// On lock   → adds chatId to ProtectedChatsService + persists setting.
  /// On unlock → removes chatId from ProtectedChatsService + persists setting.
  Future<void> _toggleProtected(bool v) async {
    final reason = v
        ? 'Authenticate to protect this chat'
        : 'Authenticate to unprotect this chat';
    final ok = await ChatLockAuthHelper.authenticate(context, reason: reason);
    if (!ok || !mounted) return;

    setState(() => protectedChat = v);
    await _settingsSvc.setProtected(_settingsKey, v);

    final svc = ProtectedChatsService();
    if (v) {
      await svc.addProtectedChat(_settingsKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat moved to Locked Chats'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await svc.removeProtectedChat(_settingsKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat returned to main list'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    svc.invalidateCache();
  }

  Future<void> _openProtectedChatScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProtectedChatScreen(
          username: displayUsername,
          initialProtectedChatValue: protectedChat,
        ),
      ),
    );
    if (result != null && mounted) {
      // Sync the toggle result from the sub-screen back
      if (result != protectedChat) {
        await _toggleProtected(result);
      }
    }
  }

  Future<void> _toggleHideChat(bool v) async {
    setState(() => hideChat = v);
    await _settingsSvc.setHideChat(_settingsKey, v);
  }

  Future<void> _toggleHideChatHistory(bool v) async {
    setState(() => hideChatHistory = v);
    await _settingsSvc.setHideChatHistory(_settingsKey, v);
  }

  // ── Mute: write to Hive + sync persistence service ───────────────────────
  Future<void> _muteChat(DateTime? muteUntil) async {
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      final chatItem = chatBox.get(_settingsKey) ?? chatBox.get(widget.userId);

      if (chatItem != null) {
        final updated = chatItem.copyWith(isMuted: true, muteUntil: muteUntil);
        await chatBox.put(chatItem.id, updated);
      }

      // Also sync to ChatSettingsPersistenceService (muted_chats list)
      await _settingsSvc.setMuted(_settingsKey, true);

      setState(() => muteNotification = true);

      if (mounted) {
        final muteText = muteUntil == null
            ? 'Chat muted forever'
            : 'Chat muted until ${DateFormat('MMM d, h:mm a').format(muteUntil)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(muteText),
            backgroundColor: HexColor('#1A7F4B'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error muting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mute chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unmuteChat() async {
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      final chatItem = chatBox.get(_settingsKey) ?? chatBox.get(widget.userId);

      if (chatItem != null) {
        final updated = chatItem.copyWith(isMuted: false, muteUntil: null);
        await chatBox.put(chatItem.id, updated);
      }

      // Also sync to ChatSettingsPersistenceService
      await _settingsSvc.setMuted(_settingsKey, false);

      setState(() => muteNotification = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat unmuted'),
            backgroundColor: HexColor('#1A7F4B'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error unmuting chat: $e');
    }
  }

  // ── Wallpaper: key MUST match MessageScreen (chatId, not userId) ──────────
  Future<void> _showWallpaperPicker() async {
    try {
      // ✅ Use _settingsKey (chatId) so MessageScreen reads the same value
      final currentWallpaper = await SaveValues().getString(
        AppPreferenceHelper.chatWallpaper(_settingsKey),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => WallpaperPickerDialog(
          currentWallpaper: currentWallpaper,
          onWallpaperSelected: _setWallpaper,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing wallpaper picker: $e');
    }
  }

  Future<void> _setWallpaper(String wallpaperPath) async {
    try {
      // ✅ Save with chatId key so MessageScreen loads it correctly
      await SaveValues().saveString(
        AppPreferenceHelper.chatWallpaper(_settingsKey),
        wallpaperPath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wallpaper updated'),
            backgroundColor: HexColor('#1A7F4B'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error setting wallpaper: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update wallpaper'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Color picker ──────────────────────────────────────────────────────────
  void _showColorPicker(
    BuildContext context,
    Color current,
    Function(Color) onSelected,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBgAlt(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Pick a Color',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 18,
          ),
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // ── Colour swatches ──────────────────────────────────────────
            ...[
              const Color(0xFF4A90E2),
              const Color(0xFFFF3B30),
              const Color(0xFF34C759),
              const Color(0xFFAF52DE),
              const Color(0xFFFF9500),
              const Color(0xFFFF2D55),
              const Color(0xFF5AC8FA),
              const Color(0xFFFFCC00),
              const Color(0xFF00C7BE),
              Colors.white,
            ].map(
              (color) => GestureDetector(
                onTap: () {
                  onSelected(color);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: current == color
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Default (clears custom color) ────────────────────────────
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                // null = no custom color = MessageScreen uses its built-in default
                await _settingsSvc.setCustomColor(_settingsKey, null);
                if (mounted)
                  setState(() => customChatColor = const Color(0xFF4A90E2));
              },
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardBgAlt(isDark),
                  border: Border.all(
                    color: isDark ? Colors.white38 : Colors.black26,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Default',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    // ✅ Only show full-screen loader if we have NO fallback data at all
    // Never block — always render with available data
    // isLoading is used only for silent background refresh

    // ✅ Never show error screen — always fall back to widget props
    // errorMessage is now only logged, never shown as a blocking screen
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // ── AppBar ────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgAlt(isDark),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppTheme.iconColor(isDark),
                      size: 22,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _initiateCallFromInfo(isVideo: true),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgAlt(isDark),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.videocam_outlined,
                          color: AppTheme.iconColor(isDark),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _initiateCallFromInfo(isVideo: false),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgAlt(isDark),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.call_outlined,
                          color: AppTheme.iconColor(isDark),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── Profile picture ───────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      if (profilePictures.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilePictureViewer(
                              imageUrls: profilePictures,
                              username: displayUsername,
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'profile_picture_${widget.userId}',
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardBgAlt(isDark),
                        ),
                        child: displayProfilePicture.isNotEmpty
                            ? CachedProfilePicture(
                                imageUrl: displayProfilePicture,
                                size: 140,
                                showBorder: false,
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Username ──────────────────────────────────────────────
                  GestureDetector(
                    onTap: _showUserDetailsBottomSheet,
                    child: Text(
                      displayUsername,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Phone — only show when we actually have data ───────────
                  if (displayPhone.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgAlt(isDark),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayPhone,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
                              fontSize: 14,
                            ),
                          ),
                          if (userProfile?.privacy.showPhone ?? false) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: displayPhone),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Phone number copied'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: HexColor('#FF6B00'),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.copy,
                                color: AppTheme.iconColorSubtle(isDark),
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // ── Menu items ────────────────────────────────────────────
                  _buildMenuItem(
                    icon: Icons.insert_photo_outlined,
                    title: 'Media, Links & Documents',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.mediaCount.toString(),
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right,
                          color: AppTheme.iconColorSubtle(isDark),
                          size: 22,
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatMediaTabScreen(
                          // ✅ ISSUE 4 FIX: Use chatId (Hive key) not userId
                          userId: widget.chatId ?? widget.userId,
                          username: displayUsername,
                          isOnline: displayIsOnline,
                          initialTabIndex: 0,
                          chatId: widget.chatId ?? widget.userId,
                        ),
                      ),
                    ),
                  ),

                  // ── Mute (Hive-backed, real duration picker) ──────────────
                  _buildToggleMenuItem(
                    icon: Icons.notifications_off_outlined,
                    title: 'Mute Notification',
                    value: muteNotification,
                    onChanged: (value) async {
                      if (value) {
                        showDialog(
                          context: context,
                          builder: (_) => MuteChatDialog(
                            chatTitle: displayUsername,
                            onMute: (muteUntil) async =>
                                await _muteChat(muteUntil),
                          ),
                        );
                      } else {
                        await _unmuteChat();
                      }
                    },
                  ),

                  // ── Custom Notification ───────────────────────────────────────────────
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Custom Notification',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatToneSelectionScreen(
                          chatId: _settingsKey,
                          chatName: displayUsername,
                        ),
                      ),
                    ),
                  ),

                  // ── Protected Chat (persisted + sub-screen sync) ──────────
                  _buildToggleMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Protected Chat',
                    value: protectedChat,
                    hasSubMenu: true,
                    onChanged: _toggleProtected,
                    onTap: _openProtectedChatScreen,
                  ),

                  // ── Hide Chat (persisted) ─────────────────────────────────
                  _buildToggleMenuItem(
                    icon: Icons.visibility_off_outlined,
                    title: 'Hide Chat',
                    value: hideChat,
                    hasSubMenu: true,
                    onChanged: _toggleHideChat,
                  ),

                  // ── Hide Chat History (persisted) ─────────────────────────
                  _buildToggleMenuItem(
                    icon: Icons.visibility_off_outlined,
                    title: 'Hide Chat History',
                    value: hideChatHistory,
                    hasSubMenu: true,
                    onChanged: _toggleHideChatHistory,
                  ),

                  // ── Add To Group ──────────────────────────────────────────
                  _buildMenuItem(
                    icon: Icons.group_add_outlined,
                    title: 'Add To Group',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddToGroupsScreen(
                          username: displayUsername,
                          userId: widget.userId,
                        ),
                      ),
                    ),
                  ),

                  // ── Custom Color (persisted) ──────────────────────────────
                  _buildColorPickerMenuItem(
                    icon: Icons.palette_outlined,
                    title: 'Custom Color Chat',
                    color: customChatColor,
                    onTap: () => _showColorPicker(context, customChatColor, (
                      picked,
                    ) async {
                      setState(() => customChatColor = picked);
                      await _settingsSvc.setCustomColor(
                        _settingsKey,
                        picked.value,
                      );
                    }),
                  ),

                  // ── Chat Wallpaper (saved with chatId key) ─────────────────
                  _buildMenuItem(
                    icon: Icons.wallpaper_outlined,
                    title: 'Chat Wallpaper',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: _showWallpaperPicker,
                  ),

                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.error_outline,
                    title: 'Report',
                    textColor: const Color(0xFFFF3B30),
                    iconColor: const Color(0xFFFF3B30),
                    onTap: _showReportDialog,
                  ),

                  _buildMenuItem(
                    icon: _isUserBlocked
                        ? Icons.lock_open_outlined
                        : Icons.block_outlined,
                    title: _isUserBlocked ? 'Unblock' : 'Block',
                    textColor: const Color(0xFFFF3B30),
                    iconColor: const Color(0xFFFF3B30),
                    onTap: _isUserBlocked
                        ? _showUnblockDialog
                        : _showBlockDialog,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        displayUsername.isNotEmpty ? displayUsername[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary(isDark),
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Bottom sheet: user details ────────────────────────────────────────────
  void _showUserDetailsBottomSheet() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.cardBgAlt(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (profilePictures.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePictureViewer(
                        imageUrls: profilePictures,
                        username: displayUsername,
                      ),
                    ),
                  );
                }
              },
              child: displayProfilePicture.isNotEmpty
                  ? CachedProfilePicture(
                      imageUrl: displayProfilePicture,
                      size: 100,
                      showBorder: false,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cardBg(isDark),
                      ),
                      child: Center(
                        child: Text(
                          displayUsername[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              displayUsername,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (displayIsOnline)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  displayLastSeen,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildDetailRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: displayPhone,
                    canCopy: userProfile?.privacy.showPhone ?? false,
                    isDark: isDark,
                  ),
                  Divider(
                    color: isDark ? Colors.white12 : Colors.black12,
                    height: 32,
                  ),
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: 'About',
                    value: displayAbout,
                    canCopy: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReportDialog();
                      },
                      icon: const Icon(Icons.flag, size: 20),
                      label: const Text('Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardBg(isDark),
                        foregroundColor: AppTheme.textPrimary(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog();
                      },
                      icon: const Icon(Icons.block, size: 20),
                      label: const Text('Block'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool canCopy,
    bool isDark = true,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.iconColorSubtle(isDark), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Copied to clipboard'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: HexColor('#FF6B00'),
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              color: AppTheme.iconColorSubtle(isDark),
              size: 20,
            ),
          ),
      ],
    );
  }

  // ── Reusable row widgets ──────────────────────────────────────────────────

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.iconColor(isDark),
              size: 24,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textColor ?? AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    bool hasSubMenu = false,
    VoidCallback? onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: hasSubMenu ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.iconColor(isDark), size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF34C759),
                activeTrackColor: const Color(0xFF34C759).withOpacity(0.5),
                inactiveThumbColor: const Color(0xFF787880),
                inactiveTrackColor: AppTheme.switchInactiveTrack(isDark),
              ),
            ),
            if (hasSubMenu) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppTheme.iconColorSubtle(isDark),
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.iconColor(isDark), size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (_) => SingleChatReportDialog(
        username: displayUsername,
        userId: widget.userId,
        onReport: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$displayUsername reported',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFFF3B30),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showUnblockDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Unblock $displayUsername?',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 16,
            ),
          ),
          content: Text(
            '$displayUsername will be able to call you and send you messages.',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(isDark),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final prefs = await SharedPreferences.getInstance();
                final blocked = prefs.getStringList('blocked_user_ids') ?? [];
                blocked.remove(widget.userId);
                await prefs.setStringList('blocked_user_ids', blocked);
                final chatListBox = await Hive.openBox<ChatListItemHive>(
                  'chats',
                );
                final chatItem = chatListBox.get(
                  widget.chatId ?? widget.userId,
                );
                if (chatItem != null) {
                  await chatListBox.put(
                    chatItem.id,
                    chatItem.copyWith(isBlocked: false),
                  );
                }
                await ChatActionsService().unblockUser(widget.userId);
                if (mounted) {
                  setState(() => _isUserBlocked = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$displayUsername unblocked'),
                      backgroundColor: const Color(0xFF1A7F4B),
                    ),
                  );
                }
              },
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (_) => SingleChatBlockDialog(
        username: displayUsername,
        userId: widget.userId,
        onBlock: () {
          Navigator.pop(context);
          if (mounted) setState(() => _isUserBlocked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$displayUsername has been blocked',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFFF3B30),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  // ✅ ISSUE 3 FIX: Real call initiation from chat info screen
  Future<void> _initiateCallFromInfo({required bool isVideo}) async {
    try {
      // Navigate to message screen first to reuse its full call setup
      final chatId = widget.chatId ?? widget.userId;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatId,
            userId: widget.userId,
            username: displayUsername,
            lastSeenActive: displayLastSeen,
            profilePicture: displayProfilePicture,
            about: displayAbout,
            isGroupChat: false,
            isContact: true,
          ),
        ),
      );
      // Small delay so MessageScreen socket connects before call starts
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      debugPrint('❌ _initiateCallFromInfo error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
