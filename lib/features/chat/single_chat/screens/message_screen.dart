import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as path;
import 'package:qik_talk/features/calls/widgets/ongoing_call_banner.dart';
import 'package:qik_talk/features/chat/general/model/user_profile_model.dart';
import 'package:qik_talk/features/chat/general/previews/audio_preview_screen.dart';
import 'package:qik_talk/features/chat/single_chat/components/contact_picker_sheet.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/provider/privacy_settings_provider.dart';
import 'package:qik_talk/features/settings/theme/models/wallpaper_item.dart';
import 'package:qik_talk/features/calls/call_permission_handler.dart';
import 'package:qik_talk/features/calls/ongoing_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/calls/screens/call_event_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/audio_file_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/chat_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/document_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/forward_message_screen.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/image_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/multiple_image_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/video_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/voice_note_bubble.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/general/model/transaction_model.dart';
import 'package:qik_talk/features/chat/general/model/user_online_model.dart';
import 'package:qik_talk/features/chat/general/previews/document_preview_screen.dart';
import 'package:qik_talk/features/chat/general/previews/image_preview_screen.dart';
import 'package:qik_talk/features/chat/general/previews/video_preview_screen.dart';
import 'package:qik_talk/features/chat/general/screens/chat_media_tab_screen.dart';
import 'package:qik_talk/features/chat/general/services/chat_cache_sync_service.dart';
import 'package:qik_talk/features/chat/general/screens/profile_picture_viewer.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/pinned_messages/pinned_message_service.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/user_online_service.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/user_profile_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_to_groups_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_info_screen.dart';
import 'package:qik_talk/features/chat/single_chat/components/recorder_ui.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_user_info_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/single_chat_dialogs.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/features/notifications/services/permission_service.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/blocked_contacts_screen.dart';
import 'package:qik_talk/features/status/components/emoji_gif_picker.dart';
import 'package:qik_talk/features/status/components/status_reply_bubble.dart';
import 'package:qik_talk/features/wallet/components/in_chat_send_money/send_money_sheet.dart';
import 'package:qik_talk/features/wallet/components/transaction_bubble.dart';
import 'package:qik_talk/features/wallet/components/transaction_history_screen.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/date_separator_widget.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/audio_recorder_service.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/services/image_compression_service.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/media_placeholder_widgets.dart';
import 'package:qik_talk/utilities/services/message_sound_service.dart';
import 'package:qik_talk/features/chat/general/services/typing_indicator_manager.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import 'package:qik_talk/utilities/services/upload_queue_service.dart';
import 'package:qik_talk/utilities/services/video_compression_service.dart';
import 'package:qik_talk/utilities/services/video_trimming_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:qik_talk/utilities/widgets/pinned_messages_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mime/mime.dart';

import '../../../wallet/components/in_chat_send_money/sample.dart';
import '../../general/components/chat_bubbles/request_money_bubble.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String userId;
  final String username;
  final String lastSeenActive;
  final String profilePicture;
  final String about;
  final bool isGroupChat; // ✅ ADD THIS
  final bool isContact; // controls call icon visibility
  final String? highlightMessageId;

  MessageScreen({
    required this.chatId,
    required this.userId,
    required this.username,
    required this.lastSeenActive,
    required this.profilePicture,
    required this.about,
    this.isGroupChat = false,
    this.isContact = true,
    this.highlightMessageId,
    super.key,
  });

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen>
    with WidgetsBindingObserver {
  static const String _deletedChatTombstonesKey = 'deleted_chat_tombstones';
  IO.Socket? socket; // ✅ Changed from 'late' to nullable
  late Box<List> _chatBox;
  SaveValues mySaveValues = SaveValues();
  final PermissionService _permissionService = PermissionService();
  bool isTyping = false;
  bool _isUserTyping = false; // ✅ ADD THIS LINE
  Map<String, bool> typingUsers = {}; // ✅ ADD THIS LINE
  String myUserId = "";
  String message = "";
  List<ChatMessage> messages = [];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  Future<ChatHistoryResponse>? futureMessages;
  UserOnlineData? userStatus;
  UserProfile? _otherUserProfile;

  Timer? _typingTimer;
  bool _hasEmittedTyping = false;

  // Typing indicator manager for persistent state
  late TypingIndicatorManager _typingManager;

  String lastMessageId = "";
  bool _isChatVisible = false;

  /// Get WhatsApp-like typing display text
  String _getTypingDisplayText() {
    final Map<String, String> userNames = {widget.userId: widget.username};
    final typingText = _typingManager.getTypingText(widget.chatId, userNames);
    return typingText.isNotEmpty
        ? typingText
        : "${widget.username} is typing...";
  }

  String? editingMessageId;
  bool isEditing = false;

  // ✅ NEW REPLY STATE
  String? replyingToMessageId;
  String? replyingToText;
  bool? replyingToIsMe;
  String? replyingToSenderName;
  bool isReplying = false;

  Set<String> savedMessageIds = {};

  bool isSearchActive = false;
  TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  List<ChatMessage> _filteredMessages = [];

  // ✅ WALLPAPER FIELD
  String? _wallpaperPath;
  Color? _customBubbleColor; // sender bubble color (per-chat or global theme)
  Color? _receiverBubbleColor; // receiver bubble color (global theme only)
  Color? _senderGlowColor; // vivid glow for sender bubble
  Color? _receiverGlowColor; // vivid glow for receiver bubble

  bool isMuted = false;
  bool _isBlocked = false; // ✅ WhatsApp-style: blocked state tracked in screen

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return ApiStrings.baseUriImage + imageUrl;
  }

  ///privacy aware helpers

  /// Returns profile picture URL only if the other user allows it,
  /// otherwise returns empty string (triggers avatar fallback)
  String get _displayProfilePicture {
    if (_otherUserProfile == null) return widget.profilePicture;
    if (!_otherUserProfile!.privacy.showProfilePicture) return '';
    return _otherUserProfile!.profilePicture.isNotEmpty
        ? _otherUserProfile!.profilePicture
        : widget.profilePicture;
  }

  /// Returns true only if the other user allows online status visibility
  bool get _displayIsOnline {
    if (_otherUserProfile == null) return userStatus?.isOnline ?? false;
    if (!_otherUserProfile!.privacy.showOnlineStatus) return false;
    return userStatus?.isOnline ?? false;
  }

  /// Returns last seen text only if the other user allows it
  String get _displayLastSeen {
    if (_otherUserProfile == null) {
      return _formatLastActive(userStatus?.lastActive);
    }
    if (!_otherUserProfile!.privacy.showLastSeen) return '';
    return _formatLastActive(userStatus?.lastActive);
  }

  bool isRecording = false;
  bool isPreviewing = false;

  late final AudioRecorderService _audioRecorder;
  String? recordingPath;
  int recordingDuration = 0;
  Timer? _recordTimer;

  late final PlayerController _playerController;
  bool isPlaying = false;

  bool get showRecorder => isRecording || isPreviewing;
  bool isUploading = false;
  bool _showScrollToBottom = false;
  int _newMessageCount = 0; // ✅ Track unread messages when scrolled up
  bool _showEmojiPicker = false;
  bool _showGifPicker = false;
  double _keyboardHeight = 300;
  final GlobalKey<PinnedMessageBannerState> _pinnedBannerKey =
      GlobalKey<PinnedMessageBannerState>();
  double uploadProgress = 0;
  final Map<String, double> _messageUploadProgress = {};
  String? replyingToMediaType;
  String? replyingToThumbnailUrl;

  List<TransactionRecord> _localTransactions = [];
  double? _swipeStartY;
  List<_ScheduledMessage> _scheduledMessages = [];
  String? _highlightedMessageId; // for search jump highlight
  IO.Socket? _listeningSocket;
  bool _socketListenersAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _typingManager = TypingIndicatorManager();
    _loadStatus();
    _loadOtherUserProfile();
    _loadMuteState();
    _loadBlockedState(); // ✅ Load block state on screen open
    _loadStarredMessages();

    _isChatVisible = true;
    NotificationService().clearChatNotifications(widget.chatId);

    // Mark as read after first frame — user has opened the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) markChatAsRead();
      // Open at latest message without animation to avoid first-frame flicker.
      if (mounted) _jumpToBottom();
      // If opened from search, jump to the target message
      if (widget.highlightMessageId != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _scrollToMessageAndHighlight(widget.highlightMessageId!);
        });
      }
    });

    _audioRecorder = AudioRecorderService();
    _playerController = PlayerController();

    _chatBox = Hive.box<List>('chat_messages');
    _loadMessagesFromHive();

    _initChat();
    _monitorConnection(); // ✅ ADD THIS LINE
    // ✅ ADD THIS SCROLL LISTENER
    scrollController.addListener(_onScroll);

    // ✅ ADD SEARCH LISTENER
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.toLowerCase();
        if (_searchQuery.isEmpty) {
          _filteredMessages = [];
        } else {
          _filteredMessages = messages.where((msg) {
            return msg.text.toLowerCase().contains(_searchQuery);
          }).toList();
        }
      });
    });

    // ✅ LOAD WALLPAPER + COLOR in one parallel call
    _loadWallpaperAndColor();
    _reloadTransactionsFromStorage(); // ✅ FIX 3: restore transactions on screen open
    _loadPersistedSchedules(); // ✅ Reload scheduled messages on app open
  }

  void _updateKeyboardHeight() {
    final mq = MediaQuery.of(context);
    final h = mq.viewInsets.bottom + mq.padding.bottom;
    if (h > 100 && h != _keyboardHeight) {
      setState(() => _keyboardHeight = h);
    }
  }

  double _safePickerHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final kbH = mq.viewInsets.bottom;
    final navH = mq.padding.bottom;
    if (kbH > 100) {
      _keyboardHeight = kbH + navH;
    }
    // When keyboard is closed, use a stable picker height (WhatsApp-like)
    // so it doesn't feel "floating" or mis-positioned.
    if (kbH <= 100) {
      return 320 + navH;
    }
    return _keyboardHeight;
  }

  Widget _buildOngoingCallReturnButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OngoingCallScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: HexColor('#FB8830'),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PulsingIcon(),
            const SizedBox(width: 8),
            Text(
              'Ongoing',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedBanner() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: 14 + bottomPadding,
      ),
      color: const Color(0xFF1C1C1E),
      child: Row(
        children: [
          const Icon(Icons.block, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You blocked this contact',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: _quickUnblock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1A7F4B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderOrInput() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: showRecorder ? _buildRecordingContainer() : _buildInputField(),
    );
  }

  bool _isNearBottom([double threshold = 160]) {
    if (!scrollController.hasClients) return true;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return maxScroll - currentScroll <= threshold;
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      final distanceFromBottom = maxScroll - currentScroll;

      // Show button if user scrolled up more than 200 pixels from bottom
      if (distanceFromBottom > 200 && !_showScrollToBottom) {
        setState(() => _showScrollToBottom = true);
      } else if (distanceFromBottom <= 200 && _showScrollToBottom) {
        // ✅ Reset new message count when user scrolls back to bottom
        setState(() {
          _showScrollToBottom = false;
          _newMessageCount = 0;
        });
      }
    }
  }

  // ✅ Single parallel loader — one setState, no double rebuild
  Future<void> _loadWallpaperAndColor() async {
    final svc = ChatSettingsPersistenceService();
    final results = await Future.wait([
      mySaveValues.getString(AppPreferenceHelper.chatWallpaper(widget.chatId)),
      svc.getCustomColor(widget.chatId),
    ]);
    if (!mounted) return;
    // Per-chat wallpaper takes priority; fall back to global wallpaper
    String? perChat = results[0] as String?;
    if (perChat == null || perChat.isEmpty) {
      perChat = await mySaveValues.getString(
        AppPreferenceHelper.GLOBAL_WALLPAPER,
      );
    }

    // ── Resolve bubble colors: per-chat custom color → global theme color ──
    final perChatColorVal = results[1] as int?;
    Color? senderColor;
    Color? receiverColor;
    Color? senderGlowColor;
    Color? receiverGlowColor;

    if (perChatColorVal != null) {
      // Per-chat custom color overrides everything — apply to sender only
      senderColor = Color(perChatColorVal);
      // No theme glow when using a per-chat custom color — derive from the color itself
    } else {
      // Fall back to global theme colors written by chat_themes_screen
      final prefs = await SharedPreferences.getInstance();
      final globalSender = prefs.getInt('global_bubble_color');
      final globalReceiver = prefs.getInt('global_receiver_color');
      final globalSenderGlow = prefs.getInt('global_sender_glow');
      final globalReceiverGlow = prefs.getInt('global_receiver_glow');
      if (globalSender != null) senderColor = Color(globalSender);
      if (globalReceiver != null) receiverColor = Color(globalReceiver);
      if (globalSenderGlow != null) senderGlowColor = Color(globalSenderGlow);
      if (globalReceiverGlow != null)
        receiverGlowColor = Color(globalReceiverGlow);
    }

    if (!mounted) return;
    setState(() {
      _wallpaperPath = (perChat != null && perChat!.isNotEmpty)
          ? perChat
          : null;
      _customBubbleColor = senderColor;
      _receiverBubbleColor = receiverColor;
      _senderGlowColor = senderGlowColor;
      _receiverGlowColor = receiverGlowColor;
    });
  }

  // Keep alias so existing call sites work — logic moved to _loadWallpaperAndColor
  // Future<void> _loadWallpaper() => _loadWallpaperAndColor();

  BoxDecoration _getWallpaperDecoration(String wallpaperPath) {
    // ── Legacy gradient presets ────────────────────────────────────────────
    if (wallpaperPath.startsWith('default_')) {
      switch (wallpaperPath) {
        case 'default_dark':
          return const BoxDecoration(color: Color(0xFF141414));
        case 'default_blue':
          return const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );
        case 'default_green':
          return const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF065F46), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );
        case 'default_purple':
          return const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B21A8), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );
        case 'default_orange':
          return const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );
        case 'default_light':
          return const BoxDecoration(color: Color(0xFFFAF5F0));
        default:
          return const BoxDecoration(color: Color(0xFF141414));
      }
    }
    // ── Solid color wallpapers ─────────────────────────────────────────────
    if (wallpaperPath.startsWith('solid_')) {
      switch (wallpaperPath) {
        case 'solid_black':
          return const BoxDecoration(color: Color(0xFF000000));
        case 'solid_dark':
          return const BoxDecoration(color: Color(0xFF141414));
        case 'solid_white':
          return const BoxDecoration(color: Color(0xFFFFFFFF));
        case 'solid_lightgrey':
          return const BoxDecoration(color: Color(0xFFE0E0E0));
        case 'solid_cream':
          return const BoxDecoration(color: Color(0xFFFAF5F0));
        default:
          return const BoxDecoration(color: Color(0xFF141414));
      }
    }
    // ── Asset wallpapers (PNG files in images/) ────────────────────────────
    if (wallpaperPath.startsWith('wp_')) {
      final item = BuiltInWallpapers.assetWallpapers
          .where((w) => w.key == wallpaperPath)
          .firstOrNull;
      if (item?.assetPath != null) {
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage(item!.assetPath!),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        );
      }
      if (item != null) {
        return BoxDecoration(gradient: item.fallbackGradient);
      }
    }
    // ── Gallery / file path ────────────────────────────────────────────────
    return BoxDecoration(
      image: DecorationImage(
        image: FileImage(File(wallpaperPath)),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  // ✅ ADD THIS METHOD
  Future<void> _quickUnblock() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Unblock ${widget.username}?',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 16,
            ),
          ),
          content: Text(
            '${widget.username} will be able to call you and send you messages.',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(isDark),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    // Optimistic UI update — restore input immediately
    setState(() {
      _isBlocked = false;
      _isUserTyping = false;
    });

    // Re-join the chat room so socket events flow again
    if (socket?.connected == true) {
      socket!.emit('join chat', widget.chatId);
    }

    // Re-focus input after a short delay so keyboard can appear
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) FocusScope.of(context).requestFocus(_messageFocusNode);
    });

    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final blocked = prefs.getStringList('blocked_user_ids') ?? [];
      blocked.remove(widget.userId);
      await prefs.setStringList('blocked_user_ids', blocked);

      // Clear Hive flag
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);
      if (chatItem != null) {
        await chatListBox.put(
          widget.chatId,
          chatItem.copyWith(isBlocked: false),
        );
      }

      // Call backend unblock
      await ChatActionsService().unblockUser(widget.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.username} unblocked',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A7F4B),
          ),
        );

        // Re-setup socket listeners in case they need refreshing
        _setupSocketListeners();

        // Reload chat history so any messages sent while blocked appear
        await loadChatHistory();
      }
    } catch (e) {
      // Revert on failure
      if (mounted) setState(() => _isBlocked = true);
      debugPrint('❌ Quick unblock failed: $e');
    }
  }

  Future<void> _loadStarredMessages() async {
    final starredIds = await mySaveValues.getStringList(
      AppPreferenceHelper.STARRED_MESSAGES,
    );

    if (mounted) {
      setState(() {
        savedMessageIds = Set.from(starredIds);
      });
    }
  }

  Future<void> _loadBlockedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedIds = prefs.getStringList('blocked_user_ids') ?? [];
      final chatBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatBox.get(widget.chatId);
      final blockedInHive = chatItem?.isBlocked == true;
      final blockedInPrefs = blockedIds.contains(widget.userId);
      if (mounted) {
        setState(() => _isBlocked = blockedInHive || blockedInPrefs);
      }
    } catch (e) {
      debugPrint('❌ [BLOCKED STATE] Error: $e');
    }
  }

  Future<void> _loadMuteState() async {
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      final chatItem = chatBox.get(widget.chatId);
      if (chatItem != null && mounted) {
        setState(() => isMuted = chatItem.isCurrentlyMuted);
        debugPrint(
          '🔇 [MUTE STATE] Loaded: isMuted=$isMuted for chat ${widget.chatId}',
        );
      }
    } catch (e) {
      debugPrint('❌ [MUTE STATE] Error loading: $e');
    }
  }

  Future<void> _initChat() async {
    try {
      await _loadUserId();
      print("After loading userId: $myUserId");

      if (!mounted) return;

      // Stop all typing indicators when entering chat (WhatsApp-like behavior)
      _typingManager.stopAllTypingInChat(widget.chatId);

      await _connectSocket();

      if (!mounted) return;

      // ✅ Hive is already loaded in initState via _loadMessagesFromHive()
      // loadChatHistory will refresh from API and merge
      await loadChatHistory();

      if (!mounted) return; // ✅ ADD THIS

      messageController.addListener(() {
        if (!mounted) return;
        // Typing socket is handled by onChanged in the input field
        // This listener only keeps _isUserTyping in sync
      });
    } catch (e) {
      print('❌ Error in _initChat: $e');
    }
  }

  Future<void> _loadStatus() async {
    // Skip fetch if userId is empty (group chats, etc.)
    if (widget.userId.isEmpty) {
      debugPrint('⚠️ Skipping status fetch - userId is empty');
      return;
    }

    try {
      // One-time initial fetch — all updates after this come from socket events
      final status = await fetchUserStatus(widget.userId);
      debugPrint(
        '🟡 Initial status: isOnline=${status?.isOnline}, lastActive=${status?.lastActive}',
      );

      if (mounted) {
        setState(() {
          userStatus = status;
          if (status?.isOnline == true) {
            for (var msg in messages) {
              if (msg.isMe && msg.status == MessageStatus.sent) {
                msg.status = MessageStatus.delivered;
              }
            }
          }
        });
        if (status?.isOnline == true) {
          await _saveMessagesToHive();
        }
      }
      // ✅ No polling timer — socket 'user online' / 'user offline' handle updates
    } catch (e) {
      debugPrint('⚠️ Failed to fetch initial status: $e');
      // Set a default offline status so we still show the user as offline
      if (mounted) {
        setState(() {
          userStatus = UserOnlineData(
            id: widget.userId,
            isOnline: false,
            lastActive: DateTime.now(),
          );
        });
      }
    }
  }

  Future<void> _loadOtherUserProfile() async {
    if (widget.userId.isEmpty || widget.isGroupChat) return;
    try {
      final profile = await UserProfileService().fetchUserProfile(
        widget.userId,
      );
      if (profile != null && mounted) {
        setState(() => _otherUserProfile = profile);
      }
    } catch (e) {
      debugPrint('❌ Failed to load other user profile: $e');
    }
  }

  Future<void> _loadUserId() async {
    final storedUserId = await mySaveValues.getString(AppPreferenceHelper.ID);
    myUserId = storedUserId ?? "";
    print("Loaded userId: $myUserId");
  }

  Future<void> loadChatHistory() async {
    // ✅ STEP 1: Show Hive data immediately — user sees messages instantly offline
    _loadMessagesFromHive();

    try {
      final chatHistory = await fetchMessages(widget.chatId);
      if (!mounted) return;

      // ✅ STEP 2: If offline/failed, keep Hive data — don't wipe the screen
      if (chatHistory == null) {
        print("⚠️ loadChatHistory: offline — showing cached messages");
        return;
      }

      // ✅ Load deleted message IDs
      final deletedIds =
          await mySaveValues.getStringList(
            'deleted_messages_${widget.chatId}',
          ) ??
          [];
      if (!mounted) return; // ✅ ADD THIS

      // Create a map of existing messages from Hive by ID for quick lookup
      final Map<String, ChatMessage> hiveMessagesMap = {
        for (var msg in messages) msg.id: msg,
      };

      // Merge API messages with Hive messages, preserving:
      // 1. Reply data from Hive if API doesn't have it
      // 2. Local media URLs (documentUrl, videoUrl, audioUrl, imageUrls) from Hive
      //    when the API version has lost them — this prevents media bubbles from
      //    disappearing when you leave and re-enter the chat before the server
      //    has fully processed the upload.
      final mergedMessages = chatHistory.messages.map((apiMsg) {
        final hiveMsg = hiveMessagesMap[apiMsg.id];
        if (hiveMsg == null) return apiMsg;

        // Build a merged message starting from the API version
        ChatMessage merged = apiMsg;

        // ── Preserve reply data ──────────────────────────────────────────────
        if ((hiveMsg.replyToMessageId != null || hiveMsg.replyToText != null) &&
            (apiMsg.replyToMessageId == null && apiMsg.replyToText == null)) {
          print("💾 Preserving reply data from Hive for message ${apiMsg.id}");
          merged = merged.copyWith(
            replyToMessageId: hiveMsg.replyToMessageId,
            replyToText: hiveMsg.replyToText,
            replyToIsMe: hiveMsg.replyToIsMe,
          );
        }

        // ── Preserve local document URL ──────────────────────────────────────
        // API may return documentUrl as null or empty if server hasn't processed
        // the upload yet. Keep the local path so DocumentBubble stays visible.
        if (hiveMsg.isDocument &&
            (apiMsg.documentUrl == null || apiMsg.documentUrl!.isEmpty) &&
            hiveMsg.documentUrl != null) {
          merged = merged.copyWith(
            isDocument: true,
            documentUrl: hiveMsg.documentUrl,
            documentName: hiveMsg.documentName ?? apiMsg.documentName,
          );
        }

        // ── Preserve local video URL ─────────────────────────────────────────
        if (hiveMsg.isVideo &&
            (apiMsg.videoUrl == null || apiMsg.videoUrl!.isEmpty) &&
            hiveMsg.videoUrl != null) {
          merged = merged.copyWith(
            isVideo: true,
            videoUrl: hiveMsg.videoUrl,
            videoThumbnail: hiveMsg.videoThumbnail ?? apiMsg.videoThumbnail,
          );
        }

        // ── Preserve local audio URL ─────────────────────────────────────────
        if ((hiveMsg.isVoiceNote || hiveMsg.isAudioFile) &&
            (apiMsg.audioUrl == null || apiMsg.audioUrl!.isEmpty) &&
            hiveMsg.audioUrl != null) {
          merged = merged.copyWith(
            isVoiceNote: hiveMsg.isVoiceNote,
            isAudioFile: hiveMsg.isAudioFile,
            audioUrl: hiveMsg.audioUrl,
            audioName: hiveMsg.audioName ?? apiMsg.audioName,
          );
        }

        // ── Preserve local image URLs ──────────────────────────────────────
        if (hiveMsg.isImage &&
            hiveMsg.imageUrls != null &&
            hiveMsg.imageUrls!.isNotEmpty) {
          final hivePaths = hiveMsg.imageUrls!;
          final apiPaths = apiMsg.imageUrls ?? [];

          // ✅ If API has remote URLs, use those (best for offline caching).
          // If API returned nothing OR fewer than Hive has, keep Hive paths
          // so the sender's locally sent images never disappear.
          List<String> bestUrls;
          if (apiPaths.length >= hivePaths.length && apiPaths.isNotEmpty) {
            bestUrls = apiPaths;
          } else if (apiPaths.isNotEmpty) {
            // API has some but fewer — merge: prefer API where available
            bestUrls = List.generate(
              hivePaths.length,
              (i) => i < apiPaths.length ? apiPaths[i] : hivePaths[i],
            );
          } else {
            // API returned nothing — keep all local paths
            bestUrls = hivePaths;
          }

          merged = merged.copyWith(isImage: true, imageUrls: bestUrls);
        }

        if (apiMsg.replyToMessageId != null) {
          print("✅ API message ${apiMsg.id} has reply data");
        }
        return merged;
      }).toList();

      // ✅ Filter out locally deleted messages
      // ✅ Filter out locally deleted messages
      final filteredMessages = mergedMessages
          .where((msg) => !deletedIds.contains(msg.id))
          .toList();

      // ✅ Re-inject any persisted scheduled cards so they survive re-entry
      final prefs = await SharedPreferences.getInstance();
      final schedKey = _schedulePrefsKey(widget.chatId);
      final schedRaw = prefs.getStringList(schedKey) ?? [];
      final List<ChatMessage> scheduledCards = [];

      for (final entry in schedRaw) {
        try {
          final map = jsonDecode(entry) as Map<String, dynamic>;
          final tempId = map['tempId'] as String;
          final text = map['text'] as String;
          final scheduledAt = DateTime.parse(map['scheduledAt'] as String);
          if (scheduledAt.isAfter(DateTime.now())) {
            scheduledCards.add(
              ChatMessage(
                id: tempId,
                chatId: widget.chatId,
                text: '__SCHEDULED__:${scheduledAt.toIso8601String()}:$text',
                isMe: true,
                isRead: false,
                status: MessageStatus.sending,
                timestamp: DateTime.now().toIso8601String(),
              ),
            );
          }
        } catch (_) {}
      }

      final combined = _dedupeLocalMessages([
        ...filteredMessages,
        ...scheduledCards,
      ]);

      // ✅ Only auto-scroll if: initial load (empty) or user is at bottom
      final isInitialLoad = messages.isEmpty;
      final shouldStickToBottom = isInitialLoad || _isNearBottom();

      // ✅ CRITICAL FIX: Save scroll position BEFORE setState to prevent auto-scroll
      double savedScrollPosition = 0;
      if (!shouldStickToBottom && scrollController.hasClients) {
        savedScrollPosition = scrollController.position.pixels;
      }

      setState(() {
        messages = combined;
      });

      // ✅ CRITICAL FIX: Restore scroll position if user was scrolled up
      if (!shouldStickToBottom && savedScrollPosition > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients &&
              scrollController.position.pixels != savedScrollPosition) {
            print(
              '📍 Restoring scroll position in loadChatHistory from ${scrollController.position.pixels} to $savedScrollPosition',
            );
            scrollController.jumpTo(savedScrollPosition);
          }
        });
      } else if (shouldStickToBottom) {
        _scrollToBottom();
      }

      // ✅ Background preload all media for offline access
      _preloadChatMedia(combined);

      await _saveMessagesToHive(
        filteredMessages, // ✅ Only real messages saved to Hive
      );
      // Mark as read now that messages are loaded from the server.
      // The addPostFrameCallback call in initState fires before messages
      // arrive, so this second call is the one that actually marks the server.
      if (mounted) markChatAsRead();
    } catch (e) {
      print("Failed to load messages: $e");
    }
  }

  void _preloadChatMedia(List<ChatMessage> msgs) {
    final cache = MediaCacheService();

    // Warm the offline cache so messages/media are available without network.
    // We don't await these downloads; they run in the background.
    for (final msg in msgs) {
      // Images (single + multi)
      if (msg.isImage && msg.imageUrls != null) {
        for (final url in msg.imageUrls!) {
          if (url.startsWith('http')) {
            cache
                .cacheMedia(url: url, mediaType: 'image')
                .catchError((_) => null);
          }
        }
      }

      // GIF: stored as msg.text URL
      if (EmojiGifPicker.isGifUrl(msg.text)) {
        final gifUrl = msg.text.trim();
        if (gifUrl.startsWith('http')) {
          cache
              .cacheMedia(url: gifUrl, mediaType: 'image')
              .catchError((_) => null);
        }
      }

      // Videos
      if (msg.isVideo) {
        final videoUrl = msg.videoUrl;
        final thumbUrl = msg.videoThumbnail;

        if (videoUrl != null && videoUrl.startsWith('http')) {
          cache
              .cacheMedia(
                url: videoUrl,
                mediaType: 'video',
                thumbnailUrl: thumbUrl,
              )
              .catchError((_) => null);
        } else if (thumbUrl != null && thumbUrl.startsWith('http')) {
          cache
              .cacheMedia(url: thumbUrl, mediaType: 'image')
              .catchError((_) => null);
        }
      }

      // Audio (voice note + audio file)
      if ((msg.isVoiceNote || msg.isAudioFile) && msg.audioUrl != null) {
        final audioUrl = msg.audioUrl!;
        if (audioUrl.startsWith('http')) {
          cache
              .cacheMedia(url: audioUrl, mediaType: 'audio')
              .catchError((_) => null);
        }
      }

      // Documents
      if (msg.isDocument && msg.documentUrl != null) {
        final docUrl = msg.documentUrl!;
        if (docUrl.startsWith('http')) {
          cache
              .cacheMedia(url: docUrl, mediaType: 'document')
              .catchError((_) => null);
        }
      }
    }
  }

  // ============================================================================
  // ✅ WEBRTC CALL METHODS - ADD THESE
  // ============================================================================

  // ✅ Step 2: Update _initiateCall to use EXISTING socket
  Future<void> _initiateCall({required bool isVideo}) async {
    try {
      debugPrint('📞 Initiating ${isVideo ? 'video' : 'audio'} call');

      final hasPermission = isVideo
          ? await CallPermissionHandler.requestVideoPermissions(context)
          : await CallPermissionHandler.requestAudioPermissions(context);

      if (!hasPermission) {
        debugPrint('❌ Permissions not granted');
        return;
      }

      if (socket == null || !socket!.connected) {
        debugPrint('❌ Socket not connected — cannot start call');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not connected. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final callNotifier = ref.read(callStateProvider.notifier);

      callNotifier.initializeWithSocket(
        socket!,
        myUserId: myUserId,
        myUsername:
            await mySaveValues.getString(AppPreferenceHelper.USER_NAME) ?? '',
        authToken:
            await mySaveValues.getString(AppPreferenceHelper.AUTH_TOKEN) ?? '',
      );

      // ✅ FIX: Set UI state immediately — screen opens instantly
      callNotifier.prepareOutgoingCall(
        userId: widget.userId,
        userName: widget.username,
        userPhoto: widget.profilePicture,
        isVideo: isVideo,
      );

      // ✅ FIX: Navigate right away without waiting for network
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OngoingCallScreen()),
        );
      }

      // ✅ FIX: Connect to backend + LiveKit in background
      callNotifier
          .startCall(
            userId: widget.userId,
            userName: widget.username,
            userPhoto: widget.profilePicture,
            isVideo: isVideo,
          )
          .catchError((e) {
            debugPrint('❌ startCall failed: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to start call: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } catch (e) {
      debugPrint('❌ Error initiating call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectSocket() async {
    try {
      print("🔌 ========== CONNECTING TO CHAT ==========");
      print("🔌 Chat ID: ${widget.chatId}");

      final globalSocket = GlobalSocketService();

      // Check if global socket is connected
      if (globalSocket.socket == null || !globalSocket.isConnected) {
        print("🔌 Global socket not connected, connecting...");
        await globalSocket.connect();

        // ✅ Wait for connection via stream instead of polling loop
        try {
          await globalSocket.connectionStatus
              .firstWhere((s) => s == ConnectionStatus.connected)
              .timeout(const Duration(seconds: 15));
        } on TimeoutException {
          print("❌ Socket connection timeout after 15 seconds");
          // Don't return here, assign the socket anyway so it can connect in background
        }

        if (!globalSocket.isConnected) {
          print("⚠️ Socket not connected after wait, but will keep trying in background");
        }
      }

      // ✅ Assign socket (now nullable)
      socket = globalSocket.socket;

      if (socket == null) {
        print("❌ Socket is null after connection");
        return;
      }

      print("✅ Got socket from GlobalSocketService");
      print("✅ Socket connected: ${socket!.connected}");

      if (socket!.connected) {
        socket!.emit('join chat', widget.chatId);
        print("✅ Joined chat room: ${widget.chatId}");

        _setupSocketListeners();
        print("✅ Socket listeners setup complete");
      } else {
        print("⚠️ Socket not connected, waiting...");

        socket!.onConnect((_) {
          print("✅ Socket connected (delayed)");
          socket?.emit('join chat', widget.chatId);
          _setupSocketListeners();
        });
      }

      print("🔌 =========================================\n");
    } catch (e) {
      print("❌ Error in _connectSocket: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _monitorConnection() {
    final globalSocket = GlobalSocketService();

    globalSocket.connectionStatus.listen((status) {
      print("📡 Connection status changed: $status");

      // ✅ CHECK mounted before updating UI
      if (!mounted) return;

      if (status == ConnectionStatus.connected) {
        print("🔄 Reconnected - rejoining chat room");

        // ✅ Reassign socket reference
        socket = globalSocket.socket;

        // ✅ Rejoin chat and reload
        if (socket?.connected == true) {
          socket!.emit('join chat', widget.chatId);
          loadChatHistory();
        }
      } else if (status == ConnectionStatus.disconnected) {
        print("❌ Connection lost");
      }
    });

    // Monitor Hive box for changes made by other screens (e.g. ChatComponent socket updates)
    _chatBox.listenable(keys: [widget.chatId]).addListener(_onHiveCacheUpdated);
  }

  void _onHiveCacheUpdated() {
    if (!mounted) return;
    // ✅ TICK SYNC FIX: Only update from Hive if the chat_messages box changed,
    // not the chats box. Merging prevents Hive's stale 'sent' status from
    // overwriting the live 'delivered'/'read' status held in memory.
    _loadMessagesFromHiveMerged();
  }

  void _loadMessagesFromHiveMerged() {
    final cached = _chatBox.get(widget.chatId);
    if (cached == null) return;
    try {
      final hiveMessages = (cached as List<dynamic>)
          .whereType<ChatMessageHive>()
          .toList();
      if (hiveMessages.isEmpty) return;

      final hiveList = hiveMessages.map((e) => e.toChat()).toList();

      // ✅ Merge: keep whichever status is higher (never downgrade live status)
      final Map<String, ChatMessage> hiveMap = {
        for (final m in hiveList) m.id: m,
      };

      final merged = messages.map((liveMsg) {
        final hiveMsg = hiveMap[liveMsg.id];
        if (hiveMsg == null) return liveMsg;
        // Preserve the higher tick status
        return _mergeLocalMessage(hiveMsg, liveMsg); // live wins on status
      }).toList();

      // Add any new messages from Hive not yet in memory
      for (final hiveMsg in hiveList) {
        if (!merged.any((m) => m.id == hiveMsg.id)) {
          merged.add(hiveMsg);
        }
      }

      if (mounted) {
        setState(() => messages = _dedupeLocalMessages(merged));
      }
    } catch (e) {
      debugPrint('❌ Hive merged load error: $e');
    }
  }

  void _setupSocketListeners() {
    if (socket == null) {
      print("❌ Cannot setup listeners - socket is null");
      return;
    }
    if (_socketListenersAttached && _listeningSocket == socket) {
      return;
    }

    // ✅ Remove any stale listeners before re-adding to prevent stacking.
    for (final event in [
      'message received',
      'typing',
      'stop typing',
      'message edited',
      'message deleted',
      'reaction added',
      'messages delivered',
      'messages read',
      'user online',
      'user offline',
      'user status changed',
    ]) {
      socket!.off(event);
    }

    _socketListenersAttached = true;
    _listeningSocket = socket;
    // ✅ Re-load userId in case it wasn't ready when initState ran
    SaveValues().getString(AppPreferenceHelper.ID).then((id) {
      if (id != null && id.isNotEmpty && myUserId.isEmpty) {
        myUserId = id;
      }
    });
    socket!.on('message received', (data) async {
      if (!mounted) return;
      print("📨 MESSAGE RECEIVED EVENT IN CHAT SCREEN");
      print("📦 Full data received: $data");

      // ✅ Skip messages sent in socket-only format (no _id = not yet saved to DB)
      // These will arrive again via API format with full data
      final hasId = data['_id'] != null;
      final hasContent = data['content'] != null;

      if (!hasId || !hasContent) {
        print(
          "⚠️ Skipping incomplete socket message (no _id or content) - waiting for API version",
        );
        return;
      }

      ChatMessage incomingMessage;
      try {
        incomingMessage = ChatMessage.fromJson(data, myUserId);
      } catch (e) {
        print("❌ Error parsing message: $e");
        print("📦 Problematic data: $data");
        return;
      }

      // ✅ TRY MULTIPLE WAYS TO GET CHAT ID
      final chatIdFromServer =
          (data['chat']?['_id'] ??
                  data['chatId'] ??
                  data['chat'] ??
                  incomingMessage.chatId)
              .toString();

      print(
        "📬 Chat ID from server: $chatIdFromServer, My chat ID: ${widget.chatId}",
      );

      // ✅ MORE FLEXIBLE COMPARISON
      if (chatIdFromServer != widget.chatId.toString() &&
          chatIdFromServer != widget.chatId) {
        print("⚠️ Message not for this chat, ignoring");
        return;
      }

      print("✅ Message is for this chat, processing..."); // ✅ ADD THIS

      // ✅ FIX: Update existing message instead of skipping it
      // This ensures reply data from server is properly merged
      final incomingId = incomingMessage.id;
      final tempId = data['tempId']?.toString();

      // Try to find existing message by server ID or tempId
      int existingIndex = messages.indexWhere((m) => m.id == incomingId);

      // If not found by ID, try to find by tempId (in case socket arrives before API response)
      if (existingIndex == -1 && tempId != null) {
        existingIndex = messages.indexWhere((m) => m.id == tempId);
      }

      if (existingIndex != -1) {
        print(
          "🔄 Updating message ${incomingMessage.id} with reply data: ${incomingMessage.replyToMessageId != null ? 'YES' : 'NO'}",
        );
        // ✅ FIX: Preserve local media data from the existing message when the
        // incoming socket message is missing it. The socket version of our own
        // sent message often has fewer imageUrls, no documentUrl, etc.
        final existing = messages[existingIndex];
        final merged = _mergeLocalMessage(existing, incomingMessage);
        setState(() {
          messages[existingIndex] = merged;
          messages = _dedupeLocalMessages(messages);
        });
      } else {
        // ✅ If it's our own message arriving via socket, update the temp message status
        if (incomingMessage.isMe) {
          print(
            "🔄 Own message confirmed by server via socket - updating status",
          );
          final tempIndex = messages.indexWhere(
            (m) => _looksLikeSamePendingMessage(m, incomingMessage),
          );
          if (tempIndex != -1) {
            setState(() {
              messages[tempIndex] = _mergeLocalMessage(
                messages[tempIndex],
                incomingMessage.copyWith(status: MessageStatus.sent),
              );
              messages = _dedupeLocalMessages(messages);
            });
            await _saveMessagesToHive();
          } else {
            // Server confirmed a message we don't have a local temp for — add it
            final alreadyExists = messages.any(
              (m) => m.id == incomingMessage.id,
            );
            if (!alreadyExists) {
              setState(() {
                messages = _dedupeLocalMessages([
                  ...messages,
                  incomingMessage.copyWith(status: MessageStatus.sent),
                ]);
              });
              await _saveMessagesToHive();
            }
          }
          return;
        }

        // ✅ Deduplication check
        final alreadyExists = messages.any((m) => m.id == incomingMessage.id);
        if (alreadyExists) {
          print(
            "⚠️ Message ${incomingMessage.id} already exists, skipping duplicate",
          );
          return;
        }

        print(
          "➕ Adding new message ${incomingMessage.id} with reply data: ${incomingMessage.replyToMessageId != null ? 'YES' : 'NO'}",
        );
        if (!incomingMessage.isMe) MessageSoundService().playReceiveSound();
        final shouldStickToBottom = _isNearBottom();

        // ✅ CRITICAL FIX: Save scroll position BEFORE setState to prevent auto-scroll
        double savedScrollPosition = 0;
        if (!shouldStickToBottom && scrollController.hasClients) {
          savedScrollPosition = scrollController.position.pixels;
        }

        setState(() {
          messages = _dedupeLocalMessages([...messages, incomingMessage]);
          // ✅ Track new messages when scrolled up for "New Messages" indicator
          if (!shouldStickToBottom && !incomingMessage.isMe) {
            _newMessageCount++;
          }
        });

        // ✅ CRITICAL FIX: Restore scroll position if user was scrolled up
        if (!shouldStickToBottom && savedScrollPosition > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients &&
                scrollController.position.pixels != savedScrollPosition) {
              print(
                '📍 Restoring scroll position from ${scrollController.position.pixels} to $savedScrollPosition',
              );
              scrollController.jumpTo(savedScrollPosition);
            }
          });
        } else if (shouldStickToBottom) {
          _scrollToBottom();
        }
      }

      // ✅ Always save to Hive immediately so ChatComponent and other listeners see it
      await _saveMessagesToHive();

      if (_isChatVisible && !incomingMessage.isMe) {
        markChatAsRead();
      }
      // Always acknowledge delivery so the sender gets grey double ticks.
      if (socket?.connected == true && !incomingMessage.isMe) {
        socket!.emit("message delivered", {"chatId": widget.chatId});
      }
    });

    // ✅ TYPING EVENT LISTENERS - REPLACE ENTIRE BLOCK
    socket!.on('typing', (data) {
      if (!mounted) return;
      print("✏️ ========== TYPING EVENT ==========");
      print("✏️ Full data: $data");

      final typingUserId = data['userId']?.toString();
      final chatId = data['chatId']?.toString() ?? data['room']?.toString();

      print("✏️ typingUserId: $typingUserId");
      print("✏️ chatId: $chatId");
      print("✏️ myUserId: $myUserId");
      print("✏️ widget.chatId: ${widget.chatId}");

      // Use TypingIndicatorManager for persistent state
      if (typingUserId != null &&
          (chatId == widget.chatId || chatId == null) &&
          typingUserId != myUserId) {
        print("SHOWING typing indicator");
        _typingManager.startTyping(
          widget.chatId,
          typingUserId,
          userName: data['userName']?.toString(),
        );

        if (mounted) {
          setState(() {
            typingUsers[typingUserId] = true;
            isTyping = true; // For backward compatibility
          });
        }
      } else {
        print(" Ignoring typing event");
        if (typingUserId == myUserId) {
          print("   (This shouldn't happen - backend should filter it)");
        }
      }
      print("✏️ ===================================\n");
    });

    socket!.on('stop typing', (data) {
      if (!mounted) return;
      print("🛑 ========== STOP TYPING EVENT ==========");
      print("🛑 Full data: $data");

      final typingUserId = data['userId']?.toString();
      final chatId = data['chatId']?.toString() ?? data['room']?.toString();

      print("🛑 typingUserId: $typingUserId");

      // Use TypingIndicatorManager for persistent state
      if (typingUserId != null &&
          (chatId == widget.chatId || chatId == null) &&
          typingUserId != myUserId) {
        print(" HIDING typing indicator");
        _typingManager.stopTyping(widget.chatId, typingUserId);

        if (mounted) {
          setState(() {
            typingUsers.remove(typingUserId);
            // Only hide indicator if nobody else is typing
            isTyping = typingUsers.isNotEmpty;
          });

          // Safety fallback: if typingUsers is empty, force hide after short delay
          if (typingUsers.isEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  isTyping = false;
                });
              }
            });
          }
        }
      }
      print("🛑 =========================================\n");
    });

    socket!.on('message edited', (data) {
      if (!mounted) return;
      if (data['chatId'] != widget.chatId) return;

      setState(() {
        messages = messages.map((m) {
          if (m.id == data['messageId']) {
            final reactions = (data['reactions'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList();

            return m.copyWith(
              text: data['newContent'] ?? m.text,
              isEdited: true,
              reactions: reactions ?? m.reactions,
            );
          }
          return m;
        }).toList();
      });
    });

    socket!.on('message deleted', (data) async {
      if (!mounted) return;
      if (data['chatId'] != widget.chatId) return;

      // Find the deleted message before removing
      final deletedMessage = messages.firstWhere(
        (m) => m.id == data['messageId'],
        orElse: () => ChatMessage(
          id: data['messageId'],
          chatId: widget.chatId,
          text: '',
          isMe: false,
          isRead: false,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );

      setState(() {
        messages.removeWhere((m) => m.id == data['messageId']);
      });

      await _saveMessagesToHive();

      // ✅ Update chat list if needed
      await _updateChatListAfterDelete(deletedMessage);
    });

    socket!.on('reaction added', (data) {
      if (!mounted) return;
      if (data['chatId'] != widget.chatId) return;

      setState(() {
        messages = messages.map((m) {
          if (m.id == data['messageId']) {
            final reactions = [...(m.reactions ?? <Map<String, dynamic>>[])];

            if (!reactions.any(
              (r) =>
                  r['userId'] == data['userId'] && r['emoji'] == data['emoji'],
            )) {
              reactions.add({'userId': data['userId'], 'emoji': data['emoji']});
            }

            return m.copyWith(reactions: reactions);
          }
          return m;
        }).toList();
      });
    });

    // Backend emits "messages delivered" (plural) with { chatId, messageIds[] }.
    socket!.on('messages delivered', (data) {
      final chatId = data['chatId']?.toString();
      final messageIds = (data['messageIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      debugPrint('📦 [DELIVERY] messageIds: $messageIds, chatId: $chatId');

      if (chatId == widget.chatId && mounted) {
        bool changed = false;
        for (var msg in messages) {
          if (!msg.isMe) continue;
          final matches = messageIds == null || messageIds.contains(msg.id);
          if (matches &&
              msg.status != MessageStatus.read &&
              msg.status != MessageStatus.delivered) {
            msg.status = MessageStatus.delivered;
            changed = true;
            debugPrint('✅ [DELIVERY] Updated ${msg.id} → DELIVERED');
          }
        }
        if (changed && mounted) {
          setState(() {});
          _saveMessagesToHive();
          // ✅ SYNC FIX: also update the chat list preview box
          _syncLastMessageStatusToChatList('delivered', messageIds: messageIds);
        }
      }
    });

    socket!.on('messages read', (data) {
      final chatId = data['chatId']?.toString();
      // Backend may send messageIds array OR just chatId (bulk read)
      final messageIds = (data['messageIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      debugPrint(
        '✅ [READ] messageIds: $messageIds, chatId: $chatId, currentChat: ${widget.chatId}',
      );

      if (chatId == widget.chatId && mounted) {
        final readReceiptsOn = ref.read(privacySettingsProvider).readReceipts;
        if (!readReceiptsOn) return;
        setState(() {
          for (var msg in messages) {
            if (!msg.isMe) continue;
            // If messageIds provided match them; if null mark all sent messages read
            final shouldMark =
                messageIds == null || messageIds.contains(msg.id);
            if (shouldMark && msg.status != MessageStatus.read) {
              msg.isRead = true;
              msg.status = MessageStatus.read;
              debugPrint('✅ [READ] Updated message ${msg.id} to READ');
            }
          }
        });
        _saveMessagesToHive();
        // ✅ SYNC FIX: also update the chat list preview box
        _syncLastMessageStatusToChatList('read', messageIds: messageIds);
      }
    });

    socket!.on('user online', (userId) {
      debugPrint(
        '🟢 user online received: $userId, widget.userId: ${widget.userId}',
      );
      final userIdStr = userId.toString().trim();
      final widgetUserIdStr = widget.userId.toString().trim();

      if (userIdStr == widgetUserIdStr && mounted) {
        setState(() {
          userStatus = UserOnlineData(
            id: widget.userId,
            isOnline: true,
            lastActive: DateTime.now(),
          );
          // ✅ Upgrade all sent (1 tick) messages to delivered (2 grey ticks)
          // because the recipient is now online and will receive them
          for (var msg in messages) {
            if (msg.isMe && msg.status == MessageStatus.sent) {
              msg.status = MessageStatus.delivered;
            }
          }
        });
        _saveMessagesToHive();
        debugPrint('✅ Set user ONLINE + upgraded sent messages to DELIVERED');
      }
    });

    socket!.on('user offline', (userId) {
      debugPrint(
        '🔴 user offline received: $userId, widget.userId: ${widget.userId}',
      );
      final userIdStr = userId.toString().trim();
      final widgetUserIdStr = widget.userId.toString().trim();

      if (userIdStr == widgetUserIdStr && mounted) {
        setState(() {
          userStatus = UserOnlineData(
            id: widget.userId,
            isOnline: false,
            lastActive: DateTime.now(),
          );
          // ✅ DO NOT downgrade tick status — delivered stays delivered
        });
        debugPrint('✅ Set user OFFLINE (ticks unchanged)');
      }
    });

    // ✅ ADD THIS NEW SOCKET LISTENER
    // ✅ ENHANCED: Update status AND refresh messages to update ticks
    socket!.on('user status changed', (data) {
      if (data['userId'] == widget.userId) {
        if (mounted) {
          setState(() {
            userStatus = UserOnlineData(
              id: data['userId'] ?? widget.userId,
              isOnline: data['isOnline'] ?? false,
              lastActive: data['lastActive'] != null
                  ? DateTime.parse(data['lastActive'])
                  : DateTime.now(),
            );
          });
        }

        // Force UI rebuild to update ticks immediately
        Future.microtask(() {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _startTyping() {
    if (!_hasEmittedTyping) {
      _hasEmittedTyping = true;
      if (socket?.connected == true) {
        socket?.emit('typing', {
          'room': widget.chatId,
          'chatId': widget.chatId,
        });
        debugPrint("🔵 Typing event emitted");
      }
    }
    // ✅ Reset timer on every keystroke — only stop after 3s of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    _hasEmittedTyping = false;
    _typingTimer?.cancel();
    if (socket?.connected == true) {
      socket?.emit('stop typing', {
        'room': widget.chatId,
        'chatId': widget.chatId,
      });
      debugPrint("🔴 Stop typing event emitted");
    }
  }

  // ✅ Called on dispose to ensure messages marked as read when user leaves
  void _markAllVisibleAsRead() {
    final hasUnread = messages.any((m) => !m.isMe && !m.isRead);
    if (!hasUnread) return;

    final unreadIds = messages
        .where((m) => !m.isMe && !m.isRead)
        .map((m) => m.id)
        .toList();

    // Emit socket event while socket is still connected (synchronous, safe on dispose).
    try {
      if (socket?.connected == true) {
        // Backend: "chat opened" marks all unread msgs as read and emits "messages read"
        socket!.emit('chat opened', {'chatId': widget.chatId});
      }
    } catch (_) {}

    // Fire and forget HTTP — don't await in dispose
    SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN).then((token) {
      http
          .put(
            Uri.parse('${AppConfig.apiUrl}message/read'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"chatId": widget.chatId}),
          )
          .catchError((e) => debugPrint('Mark read on dispose failed: $e'));
    });
  }

  void markChatAsRead() async {
    if (!_isChatVisible) return;

    if (mounted) {
      setState(() {
        for (var msg in messages) {
          if (!msg.isMe) {
            msg.isRead = true;
            msg.status = MessageStatus.read;
          }
        }
      });
    }
    await _saveMessagesToHive();
    await ChatCacheSyncService.markIncomingMessagesRead(widget.chatId);

    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

    try {
      await http.put(
        Uri.parse('${AppConfig.apiUrl}message/read'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"chatId": widget.chatId}),
      );

      // ✅ Only emit "chat opened" — GlobalSocketService handles delivery acks.
      final readReceiptsOn = ref.read(privacySettingsProvider).readReceipts;
      if (socket?.connected == true && readReceiptsOn) {
        socket!.emit("chat opened", {"chatId": widget.chatId});
      }
    } catch (e) {
      print("Mark read failed: $e");
    }
  }

  Future<ChatHistoryResponse?> fetchMessages(String chatId) async {
    try {
      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      final response = await http
          .get(
            Uri.parse(ApiStrings.getChatHistory + chatId),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      return ChatHistoryResponse.fromJson(jsonDecode(response.body), myUserId);
    } catch (e) {
      // ✅ Offline or timeout — return null, Hive data stays on screen
      print("⚠️ fetchMessages offline/failed: $e");
      return null;
    }
  }

  void handleSend() {
    if (isEditing) {
      _editMessage();
    } else {
      sendMessage();
    }
  }

  /// MongoDB ObjectIds are exactly 24 hex characters.
  /// TempIds are timestamp numbers like "1775823858836" — reject those.
  bool _isValidObjectId(String id) {
    return RegExp(r'^[a-f\d]{24}$', caseSensitive: false).hasMatch(id);
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    MessageSoundService().playSendSound();

    // ✅ ADD THESE LINES AT THE TOP
    _typingTimer?.cancel();
    socket?.emit('stop typing', {
      'room': widget.chatId,
      'chatId': widget.chatId,
    });
    setState(() {
      _isUserTyping = false;
    });

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ Capture reply data BEFORE clearing state
    final capturedReplyToId = replyingToMessageId;
    final capturedReplyText = replyingToText;
    final capturedReplyIsMe = replyingToIsMe;

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      text: text,
      isMe: true,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      replyToMessageId: capturedReplyToId, // ✅ Use captured
      replyToText: capturedReplyText,
      replyToIsMe: capturedReplyIsMe,
      replyToSenderName: replyingToSenderName,
      replyToMediaType: replyingToMediaType,
      replyToThumbnailUrl: replyingToThumbnailUrl,
    );

    await _addMessage(tempMessage);
    messageController.clear();

    // ✅ Clear reply state AFTER creating message
    if (isReplying) {
      _clearReplyState();
    }

    _scrollToBottom();

    // ✅ Only emit if socket exists and is connected
    if (socket?.connected == true) {
      socket?.emit('new message', {
        "chat": {
          "_id": widget.chatId,
          "users": [
            {"_id": myUserId},
            {"_id": widget.userId},
          ],
        },
        "sender": {"_id": myUserId},
        "text": text,
        "tempId": tempId,
        if (capturedReplyToId != null && _isValidObjectId(capturedReplyToId))
          "replyTo": capturedReplyToId,
      });
    } else {
      print("⚠️ Socket not connected - message will send via API only");
    }
    try {
      final serverMessageId = await sendMessageToApi(
        chatId: widget.chatId,
        content: text,
        replyToId: capturedReplyToId, // ✅ ADD THIS
      );

      if (!mounted) return; // ✅ ADD THIS

      if (serverMessageId != null) {
        // Start as SENT unless the recipient is already online, in which case
        // mirror WhatsApp-style delivered state immediately. A later
        // 'messages read' event still owns the blue tick/read transition.
        final initialStatus = userStatus?.isOnline == true
            ? MessageStatus.delivered
            : MessageStatus.sent;

        final updatedMessage = tempMessage.copyWith(
          id: serverMessageId,
          status: initialStatus,
        );

        await _updateMessage(updatedMessage);

        // ✅ Update chat list tile immediately with correct initial status
        await _updateChatListPreview(text: text, messageId: serverMessageId);

        // ✅ SYNC FIX: ensure the chat list tile tick matches the initial status
        if (initialStatus == MessageStatus.delivered) {
          await _syncLastMessageStatusToChatList(
            'delivered',
            messageIds: [serverMessageId],
          );
        }

        if (editingMessageId == tempId) {
          editingMessageId = lastMessageId;
        }
      }
    } catch (e) {
      _markFailed(tempId);
    }
  }

  Future<void> _editMessage() async {
    if (editingMessageId == null) return;

    final messageId = editingMessageId!;
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = messages[index];

    final newText = messageController.text.trim();
    if (newText.isEmpty) return;

    setState(() {
      messages[index] = msg.copyWith(
        text: newText,
        isEdited: true,
        status: MessageStatus.sent,
      );
    });

    _cancelEditing();

    // ✅ Only emit if socket exists and is connected
    if (socket?.connected == true) {
      socket?.emit('edit message', {
        "chatId": widget.chatId,
        "messageId": messageId,
        "newContent": newText,
      });
    }

    try {
      await editMessageApi(messageId: messageId, newContent: newText);
    } catch (e) {
      debugPrint("❌ EDIT FAILED: $e");
    }

    if (!mounted) return; // ✅ ADD THIS

    await _saveMessagesToHive();
  }

  Future<void> _addMessage(ChatMessage msg) async {
    setState(() {
      messages = _dedupeLocalMessages([...messages, msg]);
    });

    _scrollToBottom();

    await _saveMessagesToHive();
  }

  Future<void> _updateMessage(ChatMessage updated) async {
    var index = messages.indexWhere((m) => m.id == updated.id);

    // Server confirmations arrive with a new id. Replace the local temp message
    // instead of adding/keeping a duplicate or leaving it stuck as sending.
    if (index == -1 && updated.isMe) {
      index = messages.indexWhere((m) {
        if (!m.isMe || m.status != MessageStatus.sending) return false;
        final sameText = m.text.trim() == updated.text.trim();
        final sameMedia =
            (m.isImage && updated.isImage) ||
            (m.isVideo && updated.isVideo) ||
            (m.isDocument && updated.isDocument) ||
            (m.isVoiceNote && updated.isVoiceNote) ||
            (m.isAudioFile && updated.isAudioFile);
        return sameText &&
            (sameMedia ||
                (!m.isImage &&
                    !m.isVideo &&
                    !m.isDocument &&
                    !m.isVoiceNote &&
                    !m.isAudioFile));
      });
    }

    if (index == -1) return;

    setState(() {
      messages[index] = _mergeLocalMessage(messages[index], updated);
      messages = _dedupeLocalMessages(messages);
    });

    await _saveMessagesToHive();
  }

  bool _isLocalPath(String? value) {
    if (value == null || value.isEmpty) return false;
    return !value.startsWith('http') && File(value).existsSync();
  }

  List<String>? _preferLocalImageUrls(
    ChatMessage existing,
    ChatMessage incoming,
  ) {
    final existingUrls = existing.imageUrls ?? const <String>[];
    final incomingUrls = incoming.imageUrls ?? const <String>[];
    if (existing.isMe && existingUrls.any(_isLocalPath)) return existingUrls;
    if (incomingUrls.isNotEmpty) return incomingUrls;
    return existingUrls.isNotEmpty ? existingUrls : null;
  }

  ChatMessage _mergeLocalMessage(ChatMessage existing, ChatMessage incoming) {
    final preserveExistingStatus =
        existing.status == MessageStatus.read ||
        (existing.status == MessageStatus.delivered &&
            incoming.status != MessageStatus.read);

    return incoming.copyWith(
      imageUrls: _preferLocalImageUrls(existing, incoming),
      isImage: existing.isImage || incoming.isImage,
      documentUrl: existing.isMe && _isLocalPath(existing.documentUrl)
          ? existing.documentUrl
          : (incoming.documentUrl?.isNotEmpty == true
                ? incoming.documentUrl
                : existing.documentUrl),
      documentName: incoming.documentName?.isNotEmpty == true
          ? incoming.documentName
          : existing.documentName,
      isDocument: existing.isDocument || incoming.isDocument,
      videoUrl: existing.isMe && _isLocalPath(existing.videoUrl)
          ? existing.videoUrl
          : (incoming.videoUrl?.isNotEmpty == true
                ? incoming.videoUrl
                : existing.videoUrl),
      videoThumbnail: existing.videoThumbnail ?? incoming.videoThumbnail,
      isVideo: existing.isVideo || incoming.isVideo,
      audioUrl: existing.isMe && _isLocalPath(existing.audioUrl)
          ? existing.audioUrl
          : (incoming.audioUrl?.isNotEmpty == true
                ? incoming.audioUrl
                : existing.audioUrl),
      audioName: incoming.audioName ?? existing.audioName,
      isVoiceNote: existing.isVoiceNote || incoming.isVoiceNote,
      isAudioFile: existing.isAudioFile || incoming.isAudioFile,
      replyToMessageId: incoming.replyToMessageId ?? existing.replyToMessageId,
      replyToText: incoming.replyToText ?? existing.replyToText,
      replyToIsMe: incoming.replyToIsMe ?? existing.replyToIsMe,
      replyToSenderName:
          incoming.replyToSenderName ?? existing.replyToSenderName,
      replyToMediaType: incoming.replyToMediaType ?? existing.replyToMediaType,
      replyToThumbnailUrl:
          incoming.replyToThumbnailUrl ?? existing.replyToThumbnailUrl,
      status: preserveExistingStatus ? existing.status : incoming.status,
      // For incoming messages, trust the latest server/local merged read flag.
      // For outgoing messages, preserve the highest read state.
      isRead: incoming.isMe
          ? (existing.isRead || incoming.isRead)
          : incoming.isRead,
    );
  }

  bool _looksLikeSamePendingMessage(ChatMessage pending, ChatMessage incoming) {
    if (!pending.isMe || pending.status != MessageStatus.sending) return false;
    if (pending.text.trim() != incoming.text.trim()) return false;
    return (pending.isImage && incoming.isImage) ||
        (pending.isVideo && incoming.isVideo) ||
        (pending.isDocument && incoming.isDocument) ||
        (pending.isVoiceNote && incoming.isVoiceNote) ||
        (pending.isAudioFile && incoming.isAudioFile) ||
        (!pending.isImage &&
            !pending.isVideo &&
            !pending.isDocument &&
            !pending.isVoiceNote &&
            !pending.isAudioFile);
  }

  List<ChatMessage> _dedupeLocalMessages(List<ChatMessage> source) {
    final result = <ChatMessage>[];
    for (final msg in source) {
      final existingIndex = result.indexWhere((m) => m.id == msg.id);
      if (existingIndex != -1) {
        result[existingIndex] = _mergeLocalMessage(result[existingIndex], msg);
        continue;
      }
      final pendingIndex = result.indexWhere(
        (m) => _looksLikeSamePendingMessage(m, msg),
      );
      if (pendingIndex != -1) {
        result[pendingIndex] = _mergeLocalMessage(result[pendingIndex], msg);
      } else {
        result.add(msg);
      }
    }
    result.sort((a, b) {
      final at =
          DateTime.tryParse(a.timestamp) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bt =
          DateTime.tryParse(b.timestamp) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return at.compareTo(bt);
    });
    return result;
  }

  Future<void> _saveMessagesToHive([List<ChatMessage>? source]) async {
    final saveList = _dedupeLocalMessages(source ?? messages);
    if (source == null) messages = saveList;
    await _chatBox.put(widget.chatId, saveList.map((e) => e.toHive()).toList());
  }

  Future<String?> sendMessageToApi({
    required String chatId,
    required String content,
    String? replyToId,
  }) async {
    // Retry once on server errors or timeouts (handles server cold starts)
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final token = await SaveValues().getString(
          AppPreferenceHelper.AUTH_TOKEN,
        );

        final response = await http.post(
          Uri.parse('${AppConfig.apiUrl}message'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "chatId": chatId,
            "content": content,
            if (replyToId != null && _isValidObjectId(replyToId))
              "replyTo": replyToId,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          lastMessageId = data['_id'];
          return data['_id'];
        }

        // Retry on server errors (5xx) — server may be cold-starting
        if (response.statusCode >= 500 && attempt < 2) {
          debugPrint(
            "⚠️ SEND STATUS: ${response.statusCode} — retrying in 2s (attempt $attempt)",
          );
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        debugPrint("❌ SEND STATUS: ${response.statusCode}");
        debugPrint("📨 SEND BODY: ${response.body}");

        if (response.statusCode == 400) {
          try {
            final errBody = jsonDecode(response.body);
            final errMsg = (errBody['message'] ?? '').toString().toLowerCase();
            if (errMsg.contains('blocked')) {
              // Clear stale local block flags — user may have unblocked
              // from Settings but the backend still rejected this send.
              final prefs = await SharedPreferences.getInstance();
              final blockedList = prefs.getStringList('blocked_user_ids') ?? [];
              blockedList.remove(widget.userId);
              await prefs.setStringList('blocked_user_ids', blockedList);

              final chatListBox = Hive.box<ChatListItemHive>('chats');
              final chatItem = chatListBox.get(widget.chatId);
              if (chatItem != null && chatItem.isBlocked == true) {
                await chatListBox.put(
                  widget.chatId,
                  chatItem.copyWith(isBlocked: false),
                );
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Message blocked — go to Settings → Privacy → Blocked Contacts and unblock this user first.',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            }
          } catch (_) {}
        }
        return null;
      } catch (e) {
        if (attempt < 2) {
          debugPrint("⚠️ SEND ERROR (retrying in 2s): $e");
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        debugPrint("❌ SEND ERROR: $e");
        return null;
      }
    }
    return null;
  }


  bool canEditMessage(ChatMessage msg) {
    if (!msg.isMe) return false;

    if (messages.isEmpty || messages.last.id != msg.id) {
      return false;
    }

    final sentTime = DateTime.parse(msg.timestamp);
    final diff = DateTime.now().difference(sentTime);

    return diff.inSeconds <= 30;
  }

  void _startEditing(ChatMessage msg) {
    if (!canEditMessage(msg)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You can only edit your last message within 30 seconds",
          ),
        ),
      );
      return;
    }

    setState(() {
      isEditing = true;
      editingMessageId = msg.id;
      messageController.text = msg.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      editingMessageId = null;
    });
    messageController.clear();
  }

  Future<void> editMessageApi({
    required String messageId,
    required String newContent,
  }) async {
    final token = await mySaveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

    final response = await http.put(
      Uri.parse('${AppConfig.apiUrl}message/$lastMessageId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"content": newContent}),
    );

    debugPrint("✏️ EDIT STATUS: ${response.statusCode}");
    debugPrint("✏️ EDIT BODY: ${response.body}");
  }

  Future<void> _sendMultipleImages(List<File> images, String caption) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('🖼️ _sendMultipleImages called');
    debugPrint('🖼️ Number of images: ${images.length}');
    debugPrint('🖼️ Caption: $caption');

    // ✅ Compress images before upload — WhatsApp-style quality reduction
    final compressedImages = await ImageCompressionService.compressAll(
      inputs: images,
      quality: 72,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    final capturedReplyToId = replyingToMessageId;
    final capturedReplyText = replyingToText;
    final capturedReplyIsMe = replyingToIsMe;

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      isImage: true,
      imageUrls: compressedImages.map((e) => e.path).toList(),
      text: caption,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      replyToMessageId: capturedReplyToId,
      replyToText: capturedReplyText,
      replyToIsMe: capturedReplyIsMe,
      replyToSenderName: replyingToSenderName,
      replyToMediaType: replyingToMediaType,
      replyToThumbnailUrl: replyingToThumbnailUrl,
    );

    await _addMessage(tempMessage);
    if (isReplying) _clearReplyState();
    _scrollToBottom();

    try {
      debugPrint('📤 Calling sendMultipleImagesApi...');
      final serverMessageId = await sendMultipleImagesApi(
        tempMessageId: tempId,
        images: compressedImages,
        caption: caption,
        replyToId: capturedReplyToId,
      );

      if (!mounted) return; // ✅ ADD THIS

      if (serverMessageId != null) {
        debugPrint('✅ Images sent successfully, ID: $serverMessageId');
        await _updateMessage(
          tempMessage.copyWith(
            id: serverMessageId,
            status: MessageStatus.sent,
            imageUrls: tempMessage.imageUrls,
            isImage: true,
          ),
        );
        // ✅ Update chat list tile immediately — shows "📷 Photo"
        await _updateChatListPreview(
          text: caption.isNotEmpty ? caption : ' ',
          isImage: true,
          messageId: serverMessageId,
        );
        // ✅ Also remove the old tempId entry from Hive to avoid duplicates
        final tempIndex = messages.indexWhere((m) => m.id == tempMessage.id);
        if (tempIndex == -1) {
          // tempMessage was already replaced by _updateMessage — save once more
          await _saveMessagesToHive();
        }
      } else {
        debugPrint('❌ sendMultipleImagesApi returned null');
        await _markFailed(tempId);
      }
    } catch (e) {
      debugPrint('❌ Error in _sendMultipleImages: $e');
      await _markFailed(tempId);
    } finally {
      if (mounted) {
        setState(() => _messageUploadProgress.remove(tempId));
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatBox
        .listenable(keys: [widget.chatId])
        .removeListener(_onHiveCacheUpdated);
    // ✅ Cancel timers FIRST
    _typingTimer?.cancel();
    for (final s in _scheduledMessages) {
      s.timer?.cancel();
    }
    _markAllVisibleAsRead();
    scrollController.removeListener(_onScroll); // ✅ ADD THIS

    // ✅ Leave chat room only — never emit user offline here.
    // GlobalSocketService owns the online/offline lifecycle.
    if (socket?.connected == true) {
      socket!.emit('leave chat', widget.chatId);
      debugPrint('📤 left chat room: ${widget.chatId}');
    }

    _audioRecorder.dispose();
    _playerController.dispose();
    messageController.dispose();
    scrollController.dispose();
    searchController.dispose();
    _messageFocusNode.dispose();

    _typingManager.stopAllTypingInChat(widget.chatId);

    // ✅ Remove per-screen listeners so they don't stack on re-open.
    if (socket != null) {
      for (final event in [
        'message received',
        'typing',
        'stop typing',
        'message edited',
        'message deleted',
        'reaction added',
        'messages delivered',
        'messages read',
        'user online',
        'user offline',
        'user status changed',
      ]) {
        socket!.off(event);
      }
      debugPrint('🧹 MessageScreen: socket listeners removed');
    }

    _socketListenersAttached = false;
    _listeningSocket = null;
    _isChatVisible = false;

    super.dispose();
  }

  /// Reload wallpaper whenever the app resumes — picks up any global
  /// wallpaper applied from Chat Themes while this screen was in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadWallpaperAndColor();
      // ✅ Mark user as online when app comes back to foreground
      _isChatVisible = true;
      debugPrint('📱 App resumed — marking user online and chat as visible');
      if (socket?.connected == true &&
          myUserId.isNotEmpty &&
          widget.userId.isNotEmpty) {
        socket?.emit('user online', myUserId);
      }
    } else if (state == AppLifecycleState.paused && mounted) {
      // ✅ Mark chat as not visible when app goes to background
      _isChatVisible = false;
      debugPrint('📱 App paused — marking chat as not visible');
    } else if (state == AppLifecycleState.detached && mounted) {
      // ✅ App is being terminated - mark user as offline
      _isChatVisible = false;
      debugPrint('📱 App detached — cleaning up');
    }
  }

  Future<String?> sendMultipleImagesApi({
    required String tempMessageId,
    required List<File> images,
    required String caption,
    String? replyToId,
  }) async {
    try {
      debugPrint(
        '🖼️ Uploading ${images.length} image(s) via presigned URL...',
      );

      // Upload each image to MinIO and collect public URLs
      final List<String> publicUrls = [];
      for (int i = 0; i < images.length; i++) {
        if (mounted) {
          setState(
            () => _messageUploadProgress[tempMessageId] =
                (i / images.length) * 0.8,
          );
        }
        final mimeType = lookupMimeType(images[i].path) ?? 'image/jpeg';

        // ✅ Use a Completer so we can await the queue-based upload
        final completer = Completer<String?>();
        UploadQueueService().enqueue(
          file: images[i],
          mimeType: mimeType,
          onProgress: (p) {
            if (mounted) {
              setState(
                () => _messageUploadProgress[tempMessageId] =
                    (i / images.length) + (p / images.length) * 0.8,
              );
            }
          },
          onSuccess: (url) => completer.complete(url),
          onError: (err) {
            debugPrint('❌ Image upload error: $err');
            completer.complete(null);
          },
        );
        final publicUrl = await completer.future;
        if (publicUrl == null) {
          debugPrint('❌ Failed to upload image $i');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image ${i + 1}')),
            );
          }
          return null;
        }
        publicUrls.add(publicUrl);
        debugPrint('✅ Image $i uploaded: $publicUrl');
      }

      // Tell backend about the message with all image URLs
      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.chatId,
          "content": caption.isNotEmpty ? caption : " ",
          "contentType": "image",
          "attachmentUrls": publicUrls,
          if (replyToId != null && _isValidObjectId(replyToId))
            "replyTo": replyToId,
        }),
      );

      if (mounted) {
        setState(() => _messageUploadProgress[tempMessageId] = 1.0);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final messageId = data["_id"] ?? data["message"]?["_id"];
        debugPrint('✅ Image message saved, ID: $messageId');

        final idx = messages.indexWhere(
          (m) => m.id == messageId || m.id == tempMessageId,
        );
        if (idx != -1 && mounted) {
          final updated = messages[idx].copyWith(
            id: messageId,
            status: MessageStatus.sent,
          );
          setState(
            () => messages[idx] = _mergeLocalMessage(messages[idx], updated),
          );
          await _saveMessagesToHive();
        }

        return messageId;
      } else {
        debugPrint(
          '❌ Save message failed: ${response.statusCode} ${response.body}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: ${response.statusCode}'),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('❌ sendMultipleImagesApi error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload error: $e')));
      }
      return null;
    }
  }

  Future<void> _sendPickedAudio(File audioFile, int duration) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ Extract file name from path
    final fileName = audioFile.path.split('/').last;

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      isVoiceNote: false,
      isAudioFile: true,
      audioUrl: audioFile.path,
      audioName: fileName,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      text: '',
      replyToMessageId: replyingToMessageId,
      replyToText: replyingToText,
      replyToIsMe: replyingToIsMe,
      replyToSenderName: replyingToSenderName,
      replyToMediaType: replyingToMediaType,
      replyToThumbnailUrl: replyingToThumbnailUrl,
    );

    await _addMessage(tempMessage);
    _scrollToBottom();

    try {
      final serverMessageId = await sendAudioApi(audioPath: audioFile.path);
      if (!mounted) return; // ✅ ADD THIS

      if (serverMessageId != null) {
        // ✅ FIX: Match by tempId explicitly, not by serverMessageId
        final idx = messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          setState(() {
            messages[idx] = _mergeLocalMessage(
              messages[idx],
              tempMessage.copyWith(
                id: serverMessageId,
                status: MessageStatus.sent,
              ),
            );
          });
          await _saveMessagesToHive();
        } else {
          // ✅ FIX Bug1: Guard against duplicate — a concurrent loadChatHistory may
          // have already added the server version to the list; only add if absent.
          if (!messages.any((m) => m.id == serverMessageId)) {
            final confirmed = tempMessage.copyWith(
              id: serverMessageId,
              status: MessageStatus.sent,
            );
            setState(
              () => messages = _dedupeLocalMessages([...messages, confirmed]),
            );
            await _saveMessagesToHive();
          }
        }
        await _updateChatListPreview(
          text: ' ',
          isAudio: true,
          messageId: serverMessageId,
        );
      } else {
        await _markFailed(tempId);
      }
    } catch (_) {
      await _markFailed(tempId);
    }
  }

  Future<String?> sendAudioApi({required String audioPath}) async {
    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0;
      });

      final mimeType = lookupMimeType(audioPath) ?? 'audio/mpeg';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: File(audioPath),
        mimeType: mimeType,
        onProgress: (p) {
          if (mounted) setState(() => uploadProgress = p);
        },
      );

      if (publicUrl == null) {
        setState(() => isUploading = false);
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Audio upload failed')));
        return null;
      }

      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.chatId,
          "content": " ",
          "contentType": "audio",
          "attachmentUrls": [publicUrl],
        }),
      );

      setState(() {
        isUploading = false;
        uploadProgress = 0;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["_id"] ?? data["message"]?["_id"];
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Audio upload failed: ${response.statusCode}"),
            ),
          );
        return null;
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Audio upload error: $e")));
      return null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  // ── Scroll to a message (from reply tap) ──────────────────────
  void _scrollToMessageAndHighlight(String messageId) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    // Approximate position — each message ~80px
    final position = (index * 80.0).clamp(
      0.0,
      scrollController.hasClients
          ? scrollController.position.maxScrollExtent
          : 0.0,
    );

    if (scrollController.hasClients) {
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }

    // Flash highlight
    setState(() => _highlightedMessageId = messageId);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
  }

  // ✅ ADD THIS ENTIRE METHOD
  void _scrollToMessage(String messageId) {
    final index = messages.indexWhere((m) => m.id == messageId);

    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Original message not found"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Calculate approximate position
    // Each message is roughly 80 pixels (adjust if needed)
    final position = index * 80.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Optional: Highlight the message briefly
        setState(() {
          // You could add a highlightedMessageId state variable
        });
      }
    });
  }

  Future<void> startRecording() async {
    try {
      // ✅ Request microphone permission
      final micResult = await _permissionService.requestMicrophone(context);

      debugPrint('🎤 Microphone permission result: $micResult');

      if (micResult != PermissionResult.granted) {
        debugPrint('❌ Microphone permission not granted');
        return;
      }

      debugPrint('✅ Microphone permission granted - starting recording');

      // Start recording
      setState(() {
        isRecording = true;
        isPreviewing = false;
      });

      recordingDuration = 0;
      _recordTimer?.cancel();

      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => recordingDuration++);
      });

      await _audioRecorder.startRecording();
      // Notify chat list that user is recording
      if (socket?.connected == true) {
        socket?.emit('recording audio', {
          'chatId': widget.chatId,
          'userId': myUserId,
        });
      }
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error recording audio: $e')));
    }
  }

  Future<void> stopRecordingPreview() async {
    if (!isRecording) return;

    _recordTimer?.cancel();

    final path = await _audioRecorder.stopRecording();

    if (path == null || recordingDuration == 0) {
      _resetRecordingState();
      return;
    }

    setState(() {
      recordingPath = path;
      isRecording = false;
      isPreviewing = true;
    });
  }

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void _deleteRecording() async {
    _recordTimer?.cancel();
    await _audioRecorder.stopRecording();

    if (socket?.connected == true) {
      socket?.emit('stop recording audio', {
        'chatId': widget.chatId,
        'userId': myUserId,
      });
    }
    setState(() {
      isRecording = false;
      isPreviewing = false;
      recordingPath = null;
      recordingDuration = 0;
    });
  }

  Future<void> sendRecording() async {
    if (recordingPath == null && isRecording) {
      await stopRecordingPreview();
    }

    if (recordingPath == null) return;

    final path = recordingPath!;

    setState(() {
      isRecording = false;
      isPreviewing = false;
    });
    if (socket?.connected == true) {
      socket?.emit('stop recording audio', {
        'chatId': widget.chatId,
        'userId': myUserId,
      });
    }

    final duration = await getRealAudioDuration(path);
    if (duration == 0) {
      _resetRecordingState();
      return;
    }

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      isVoiceNote: true,
      audioUrl: path,
      isMe: true,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      text: '',
    );

    await _addMessage(tempMessage);
    _scrollToBottom();

    try {
      final serverMessageId = await sendRecordApi(
        audioPath: path,
        duration: duration,
      );
      if (!mounted) return; // ✅ ADD THIS

      if (serverMessageId != null) {
        // ✅ FIX Bug3: _updateMessage searched by serverMessageId but the temp
        // message still has tempId — it was a silent no-op causing voice notes
        // to disappear on navigation. Use explicit tempId lookup instead.
        final idx = messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          setState(() {
            messages[idx] = _mergeLocalMessage(
              messages[idx],
              tempMessage.copyWith(
                id: serverMessageId,
                status: MessageStatus.sent,
              ),
            );
          });
          await _saveMessagesToHive();
        } else if (!messages.any((m) => m.id == serverMessageId)) {
          // tempId already replaced by a concurrent loadChatHistory reload —
          // only add if server version not already present (dedup guard)
          final confirmed = tempMessage.copyWith(
            id: serverMessageId,
            status: MessageStatus.sent,
          );
          setState(
            () => messages = _dedupeLocalMessages([...messages, confirmed]),
          );
          await _saveMessagesToHive();
        }
        // ✅ Update chat list tile immediately — shows "🎤 Voice message"
        await _updateChatListPreview(
          text: ' ',
          isVoiceNote: true,
          messageId: serverMessageId,
        );
      } else {
        _markFailed(tempId);
      }
    } catch (_) {
      _markFailed(tempId);
    }

    _resetRecordingState();
  }

  void _resetRecordingState() {
    setState(() {
      recordingPath = null;
      recordingDuration = 0;
      isRecording = false;
      isPreviewing = false;
    });
  }

  Future<void> _markFailed(String messageId) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final failedMessage = messages[index].copyWith(
      status: MessageStatus.failed,
    );

    await _updateMessage(failedMessage);
  }

  Future<String?> sendRecordApi({
    required String audioPath,
    required int duration,
  }) async {
    debugPrint("📡 sendRecordApi() duration: $duration seconds");
    try {
      final mimeType = lookupMimeType(audioPath) ?? 'audio/aac';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: File(audioPath),
        mimeType: mimeType,
      );

      if (publicUrl == null) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Voice note upload failed")),
          );
        return null;
      }

      await MediaCacheService().registerCachedMedia(
        url: publicUrl,
        localPath: audioPath,
        mediaType: 'audio',
      );

      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.chatId,
          "content": " ",
          "contentType": "audio",
          "isVoiceNote": true,
          "attachmentUrls": [publicUrl],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["_id"] ?? data["message"]?["_id"];
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Voice note upload failed: ${response.body}"),
            ),
          );
        return null;
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Voice note upload error: $e")));
      return null;
    }
  }

  Future<int> getRealAudioDuration(String path) async {
    final player = AudioPlayer();
    await player.setFilePath(path);
    final duration = player.duration?.inSeconds ?? 0;
    await player.dispose();
    return duration;
  }

  String _extractFileName(String path) {
    return path.split('/').last;
  }

  String _getReplyPreviewText(ChatMessage message) {
    if (message.isVoiceNote) return "Voice note";
    if (message.isAudioFile) return "Audio";
    if (message.isImage) return "Photo";
    if (message.isVideo) return "Video";
    if (message.isDocument) return message.documentName ?? "Document";
    return message.text;
  }

  String? _getReplyMediaType(ChatMessage message) {
    if (message.isImage) return 'image';
    if (message.isVideo) return 'video';
    if (message.isVoiceNote)
      return 'voice_note'; // ✅ BUG1 FIX: was 'voice', must match icon-chooser
    if (message.isAudioFile) return 'audio';
    if (message.isDocument) return 'document';
    return null;
  }

  String? _getReplyThumbnail(ChatMessage message) {
    if (message.isImage && (message.imageUrls?.isNotEmpty ?? false)) {
      return message.imageUrls!.first;
    }
    if (message.isVideo) return message.videoThumbnail ?? message.videoUrl;
    return null;
  }

  void _startReplyToMessage(ChatMessage message) {
    setState(() {
      isReplying = true;
      replyingToMessageId = message.id;
      replyingToText = _getReplyPreviewText(message);
      replyingToIsMe = message.isMe;
      replyingToSenderName = message.isMe
          ? 'You'
          : (message.senderName?.isNotEmpty == true
                ? message.senderName
                : widget.username);
      replyingToMediaType = _getReplyMediaType(message);
      replyingToThumbnailUrl = _getReplyThumbnail(message);
    });
  }

  void _clearReplyState() {
    setState(() {
      isReplying = false;
      replyingToMessageId = null;
      replyingToText = null;
      replyingToIsMe = null;
      replyingToSenderName = null;
      replyingToMediaType = null;
      replyingToThumbnailUrl = null;
    });
  }

  Future<void> _sendDocument(File file, {String content = ""}) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final capturedReplyToId = replyingToMessageId;
    final capturedReplyText = replyingToText;
    final capturedReplyIsMe = replyingToIsMe;

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      isDocument: true,
      documentUrl: file.path,
      documentName: _extractFileName(file.path),
      text: content,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      replyToMessageId: capturedReplyToId,
      replyToText: capturedReplyText,
      replyToIsMe: capturedReplyIsMe,
      replyToSenderName: replyingToSenderName,
      replyToMediaType: replyingToMediaType,
      replyToThumbnailUrl: replyingToThumbnailUrl,
    );

    await _addMessage(tempMessage);
    if (isReplying) _clearReplyState();
    _scrollToBottom();

    try {
      final serverId = await sendDocumentApi(
        file: file,
        content: content,
        replyToId: capturedReplyToId,
      );
      if (!mounted) return; // ✅ ADD THIS

      if (serverId != null) {
        // ✅ FIX: Find by tempId first, then update with real serverId + real URL
        final idx = messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          // Preserve the documentUrl from temp message (local path) until we
          // have a confirmed remote URL. The local path still works for display.
          setState(() {
            messages[idx] = _mergeLocalMessage(
              messages[idx],
              tempMessage.copyWith(id: serverId, status: MessageStatus.sent),
            );
          });
          await _saveMessagesToHive();
        } else {
          // ✅ FIX Bug1: Guard against duplicate — a concurrent loadChatHistory may
          // have already added the server version to the list; only add if absent.
          if (!messages.any((m) => m.id == serverId)) {
            final confirmed = tempMessage.copyWith(
              id: serverId,
              status: MessageStatus.sent,
            );
            setState(
              () => messages = _dedupeLocalMessages([...messages, confirmed]),
            );
            await _saveMessagesToHive();
          }
        }
        await _updateChatListPreview(
          text: content.isNotEmpty ? content : ' ',
          isDocument: true,
          messageId: serverId,
        );
      } else {
        await _markFailed(tempId);
      }
    } catch (_) {
      await _markFailed(tempId);
    }
  }

  Future<String?> sendDocumentApi({
    required File file,
    String content = "",
    String? replyToId,
  }) async {
    try {
      debugPrint('📄 Uploading document via presigned URL...');
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
      );

      if (publicUrl == null) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Document upload failed")),
          );
        return null;
      }

      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.chatId,
          "content": content.isNotEmpty ? content : " ",
          "contentType": "document",
          "attachmentUrls": [publicUrl],
          if (replyToId != null && _isValidObjectId(replyToId))
            "replyTo": replyToId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["_id"] ?? data["message"]?["_id"];
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Document upload failed: ${response.body}")),
          );
        return null;
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Document upload error: $e")));
      return null;
    }
  }

  Future<void> _sendVideo(File file, {String content = ""}) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final capturedReplyToId = replyingToMessageId;
    final capturedReplyText = replyingToText;
    final capturedReplyIsMe = replyingToIsMe;

    debugPrint('📹 _sendVideo called');
    debugPrint('📹 File path: ${file.path}');
    debugPrint('📹 Caption: $content');

    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      isVideo: true,
      videoUrl: file.path,
      text: content,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      replyToMessageId: capturedReplyToId,
      replyToText: capturedReplyText,
      replyToIsMe: capturedReplyIsMe,
      replyToSenderName: replyingToSenderName,
      replyToMediaType: replyingToMediaType,
      replyToThumbnailUrl: replyingToThumbnailUrl,
    );

    await _addMessage(tempMessage);
    if (isReplying) _clearReplyState();
    _scrollToBottom();

    try {
      debugPrint('📤 Calling sendVideoApi...');
      final compressed = await VideoCompressionService.compressToMaxSize(
        input: file,
        maxSizeMb: 15,
      );
      final serverId = await sendVideoApi(
        tempMessageId: tempId,
        file: compressed,
        content: content,
        replyToId: capturedReplyToId,
      );
      if (!mounted) return; // ✅ ADD THIS

      if (serverId != null) {
        debugPrint('✅ Video sent successfully, ID: $serverId');
        await _updateMessage(
          tempMessage.copyWith(id: serverId, status: MessageStatus.sent),
        );
        // ✅ Update chat list tile immediately — shows "🎥 Video"
        await _updateChatListPreview(
          text: content.isNotEmpty ? content : ' ',
          isVideo: true,
          messageId: serverId,
        );
      } else {
        debugPrint('❌ sendVideoApi returned null');
        await _markFailed(tempId);
      }
    } catch (e) {
      debugPrint('❌ Error in _sendVideo: $e');
      await _markFailed(tempId);
    } finally {
      if (mounted) {
        setState(() => _messageUploadProgress.remove(tempId));
      }
    }
  }

  Future<String?> sendVideoApi({
    required String tempMessageId,
    required File file,
    String content = "",
    String? replyToId,
  }) async {
    try {
      debugPrint('📹 Uploading video via presigned URL...');
      final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
        onProgress: (p) {
          if (mounted)
            setState(() => _messageUploadProgress[tempMessageId] = p);
        },
      );

      if (mounted) setState(() => _messageUploadProgress[tempMessageId] = 1.0);

      if (publicUrl == null) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        return null;
      }

      await MediaCacheService().registerCachedMedia(
        url: publicUrl,
        localPath: file.path,
        mediaType: 'video',
      );

      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}message'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.chatId,
          "content": content.isNotEmpty ? content : " ",
          "contentType": "video",
          "attachmentUrls": [publicUrl],
          if (replyToId != null && _isValidObjectId(replyToId))
            "replyTo": replyToId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final msgId = data["_id"] ?? data["message"]?["_id"];

        // ✅ FIX: Save public video URL to Hive so video persists on re-entry
        if (publicUrl != null && msgId != null && mounted) {
          final idx = messages.indexWhere(
            (m) => m.id == msgId || m.id == tempMessageId,
          );
          if (idx != -1) {
            final updated = messages[idx].copyWith(
              id: msgId,
              status: MessageStatus.sent,
            );
            setState(
              () => messages[idx] = _mergeLocalMessage(messages[idx], updated),
            );
            await _saveMessagesToHive();
          }
        }
        return msgId;
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video upload failed: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        return null;
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video upload error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      return null;
    }
  }

  void _loadMessagesFromHive() {
    final cached = _chatBox.get(widget.chatId);

    if (cached != null) {
      try {
        final hiveMessages = (cached as List<dynamic>)
            .whereType<ChatMessageHive>() // ✅ Skip any corrupted entries
            .toList();

        if (hiveMessages.isNotEmpty) {
          // ✅ CRITICAL FIX: Only jump to bottom if messages list is currently empty
          // If user scrolled up while viewing, don't auto-scroll
          final shouldJump = messages.isEmpty;

          setState(() {
            messages = _dedupeLocalMessages(
              hiveMessages.map((e) => e.toChat()).toList(),
            );
          });

          // ✅ Only jump to bottom on initial load
          if (shouldJump) {
            _jumpToBottom();
          }

          debugPrint('✅ Loaded ${hiveMessages.length} messages from Hive');
        }
      } catch (e) {
        debugPrint('❌ Failed to load Hive messages: $e');
        // ✅ Don't wipe the box on parse error — just show empty
      }
    }
  }

  void _showThreeDotMenu() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ctx = context;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 220,
        MediaQuery.of(context).padding.top + kToolbarHeight - 10,
        12,
        0,
      ),
      color: AppTheme.popupBg(isDark),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _menuEntry(Icons.info_outline, 'Contact info', 'contact_info'),
        _menuEntry(
          Icons.photo_library_outlined,
          'Media, links & docs',
          'media',
        ),
        _menuEntry(Icons.search, 'Search', 'search'),
        _menuEntry(
          isMuted
              ? Icons.notifications_outlined
              : Icons.notifications_off_outlined,
          isMuted ? 'Unmute notifications' : 'Mute notifications',
          'mute',
        ),
        _menuEntry(Icons.share_outlined, 'Share contact', 'share'),
        _menuEntry(
          Icons.person_off_outlined,
          'Block contact',
          'block',
          color: const Color(0xFFFF3B30),
        ),
        _menuEntry(
          Icons.flag_outlined,
          'Report contact',
          'report',
          color: const Color(0xFFFF3B30),
        ),
        _menuEntry(Icons.delete_sweep_outlined, 'Clear chat', 'clear'),
        _menuEntry(Icons.upload_outlined, 'Export chat', 'export'),
        _menuEntry(
          Icons.delete_outline,
          'Delete chat',
          'delete',
          color: const Color(0xFFFF3B30),
        ),
      ],
    ).then((value) async {
      if (value == null || !mounted) return;
      switch (value) {
        case 'contact_info':
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ChatUserInfoScreen(
                userId: widget.userId,
                mediaCount: _getMediaCount(),
                chatId: widget.chatId,
              ),
            ),
          ).then((_) => _loadWallpaperAndColor());
          break;

        case 'media':
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ChatMediaTabScreen(
                userId: widget.userId,
                username: widget.username,
                isOnline: userStatus?.isOnline ?? false,
                initialTabIndex: 0,
                chatId: widget
                    .chatId, // ✅ FIX: pass chatId so tabs filter correctly
              ),
            ),
          );
          break;

        case 'search':
          setState(() => isSearchActive = true);
          break;

        case 'mute':
          if (isMuted) {
            // Already muted → unmute
            final result = await ChatActionsService().unmuteChat(widget.chatId);
            if (mounted) {
              setState(() => isMuted = false);
              // ✅ Update Hive so chat list icon disappears immediately
              await _updateMuteInHive(false);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.username} unmuted',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  backgroundColor: HexColor('#1A7F4B'),
                ),
              );
            }
          } else {
            showDialog(
              context: ctx,
              builder: (_) => SingleChatMuteDialog(
                username: widget.username,
                chatId: widget.chatId,
                onMuted: () async {
                  if (mounted) {
                    setState(() => isMuted = true);
                    // ✅ Update Hive so mute icon appears in chat list immediately
                    await _updateMuteInHive(true);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.username} muted',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: HexColor('#1A7F4B'),
                      ),
                    );
                  }
                },
              ),
            );
          }
          break;

        case 'share':
          _openContactPickerForSharing();
          break;

        case 'block':
          showDialog(
            context: ctx,
            builder: (_) => SingleChatBlockDialog(
              username: widget.username,
              userId: widget.userId,
              onBlock: () async {
                // Persist block so chat list survives API refresh
                final prefs = await SharedPreferences.getInstance();
                final blocked = prefs.getStringList('blocked_user_ids') ?? [];
                if (!blocked.contains(widget.userId)) {
                  blocked.add(widget.userId);
                  await prefs.setStringList('blocked_user_ids', blocked);
                }
                // Also mark in Hive immediately
                final chatListBox = Hive.box<ChatListItemHive>('chats');
                final chatItem = chatListBox.get(widget.chatId);
                if (chatItem != null) {
                  await chatListBox.put(
                    widget.chatId,
                    chatItem.copyWith(isBlocked: true),
                  );
                }
                // ✅ Update local screen state immediately — shows banner without restart
                if (mounted) setState(() => _isBlocked = true);
                ref.invalidate(blockedContactsProvider);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.username} blocked',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                );
                Navigator.pop(ctx);
              },
            ),
          );
          break;

        case 'report':
          showDialog(
            context: ctx,
            builder: (_) => SingleChatReportDialog(
              username: widget.username,
              userId: widget.userId,
              onReport: () {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.username} reported',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                );
              },
            ),
          );
          break;

        case 'clear':
          showDialog(
            context: ctx,
            builder: (_) => SingleChatClearDialog(
              username: widget.username,
              chatId: widget.chatId,
              onClear: () async {
                // 1. Wipe messages from screen
                setState(() => messages.clear());
                // 2. Wipe from Hive message box
                await _chatBox.delete(widget.chatId);
                // 3. Wipe last-message preview from chat list
                await _wipeChatListPreview();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat cleared',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: HexColor('#1A7F4B'),
                  ),
                );
              },
            ),
          );
          break;

        case 'export':
          showDialog(
            context: ctx,
            builder: (_) => SingleChatExportDialog(
              chatId: widget.chatId,
              username: widget.username,
              onWithoutMedia: () {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat exported',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: HexColor('#1A7F4B'),
                  ),
                );
              },
              onIncludeMedia: () {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat exported with media',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: HexColor('#1A7F4B'),
                  ),
                );
              },
            ),
          );
          break;

        case 'delete':
          showDialog(
            context: ctx,
            builder: (_) => SingleChatDeleteDialog(
              username: widget.username,
              chatId: widget.chatId,
              onDelete: () async {
                // 1. Wipe messages from screen
                setState(() => messages.clear());
                await _markDeletedChatTombstone();
                // 2. Wipe from Hive message box
                await _chatBox.delete(widget.chatId);
                // 3. Wipe last-message preview from chat list
                await _wipeChatListPreview();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat deleted',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                );
                Navigator.pop(ctx);
              },
            ),
          );
          break;
      }
    });
  }

  PopupMenuItem<String> _menuEntry(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppTheme.iconColorSubtle(isDark),
            size: 20,
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color ?? AppTheme.popupText(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Menu option
  PopupMenuItem _buildPopupMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      height: 48,
      child: Row(
        children: [
          Icon(icon, color: textColor ?? Colors.white, size: 22),
          SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor ?? Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Show message options bottom sheet
  void _showMessageOptions(ChatMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ REPLY
                  _buildActionTile(
                    icon: Icons.reply,
                    title: "Reply",
                    onTap: () {
                      Navigator.pop(context);
                      _startReplyToMessage(message);
                    },
                  ),

                  _buildActionTile(
                    icon: Icons.push_pin_outlined,
                    title: 'Pin message',
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final ok = await PinnedMessageService().pinMessage(
                        chatId: widget.chatId,
                        messageId: message.id,
                      );
                      if (ok) {
                        _pinnedBannerKey.currentState?.reload();
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Message pinned'),
                            backgroundColor: HexColor('#1A7F4B'),
                          ),
                        );
                      }
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.push_pin,
                    title: 'Unpin message',
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final ok = await PinnedMessageService().unpinMessage(
                        chatId: widget.chatId,
                        messageId: message.id,
                      );
                      if (ok) {
                        _pinnedBannerKey.currentState?.reload();
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Message unpinned'),
                            backgroundColor: HexColor('#1A7F4B'),
                          ),
                        );
                      }
                    },
                  ),
                  // ✅ SAVE/UNSAVE
                  _buildActionTile(
                    icon: savedMessageIds.contains(message.id)
                        ? Icons.star
                        : Icons.star_border,
                    title: savedMessageIds.contains(message.id)
                        ? "Unsave"
                        : "Save",
                    // Inside the "Save/Unsave" action tile onTap
                    onTap: () async {
                      Navigator.pop(context);

                      // Get current starred list
                      final starredIds = await mySaveValues.getStringList(
                        AppPreferenceHelper.STARRED_MESSAGES,
                      );

                      if (starredIds.contains(message.id)) {
                        // Remove from starred
                        starredIds.remove(message.id);
                        await mySaveValues.saveStringList(
                          AppPreferenceHelper.STARRED_MESSAGES,
                          starredIds,
                        );
                        setState(() {
                          savedMessageIds.remove(message.id);
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Message removed from starred'),
                              backgroundColor: HexColor("#FF6B00"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      } else {
                        // Add to starred
                        starredIds.add(message.id);
                        await mySaveValues.saveStringList(
                          AppPreferenceHelper.STARRED_MESSAGES,
                          starredIds,
                        );
                        setState(() {
                          savedMessageIds.add(message.id);
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Message starred'),
                              backgroundColor: HexColor("#1A7F4B"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  // ✅ FORWARD
                  _buildActionTile(
                    icon: Icons.forward,
                    title: "Forward",
                    onTap: () {
                      Navigator.pop(context);
                      _showForwardDialog(message);
                    },
                  ),

                  // ✅ COPY (text messages only)
                  if (!message.isImage &&
                      !message.isVideo &&
                      !message.isDocument &&
                      !message.isAudioFile &&
                      !message.isVoiceNote &&
                      message.text.isNotEmpty &&
                      !message.text.startsWith('__TRANSACTION__') &&
                      !message.text.startsWith('__SCHEDULED__'))
                    _buildActionTile(
                      icon: Icons.copy,
                      title: "Copy",
                      onTap: () {
                        Navigator.pop(context);
                        Clipboard.setData(ClipboardData(text: message.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message copied'),
                            backgroundColor: HexColor("#1A7F4B"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                  // ✅ EDIT (only for own messages and text-only)
                  if (message.isMe &&
                      canEditMessage(message) &&
                      !message.isImage &&
                      !message.isVideo &&
                      !message.isDocument &&
                      !message.isAudioFile &&
                      !message.isVoiceNote)
                    _buildActionTile(
                      icon: Icons.edit,
                      title: "Edit",
                      onTap: () {
                        Navigator.pop(context);
                        _startEditing(message);
                      },
                    ),

                  // ✅ DELETE (only for own messages)
                  if (message.isMe)
                    _buildActionTile(
                      icon: Icons.delete,
                      title: "Delete",
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteOptions(message);
                      },
                      textColor: Colors.red,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? AppTheme.iconColor(isDark),
              size: 22,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textColor ?? AppTheme.popupText(isDark),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForwardDialog(ChatMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForwardMessageScreen(
          message: message,
          currentChatId: widget.chatId,
        ),
      ),
    );
  }

  // ✅ NEW: Show delete options
  void _showDeleteOptions(ChatMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Delete message",
                    style: GoogleFonts.poppins(
                      color: AppTheme.popupText(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Delete for me
                _buildActionTile(
                  icon: Icons.delete_outline,
                  title: "Delete for me",
                  onTap: () {
                    Navigator.pop(context);
                    _deleteForMe(message);
                  },
                ),

                // Delete for everyone (only if within 1 hour)
                if (_canDeleteForEveryone(message))
                  _buildActionTile(
                    icon: Icons.delete_forever,
                    title: "Delete for everyone",
                    onTap: () {
                      Navigator.pop(context);
                      _deleteForEveryone(message);
                    },
                    textColor: Colors.red,
                  ),

                // Cancel
                _buildActionTile(
                  icon: Icons.close,
                  title: "Cancel",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Check if can delete for everyone (within 1 hour)
  bool _canDeleteForEveryone(ChatMessage message) {
    final sentTime = DateTime.parse(message.timestamp);
    final difference = DateTime.now().difference(sentTime);
    return difference.inHours < 1;
  }

  // ✅ Delete for me only
  Future<void> _deleteForMe(ChatMessage message) async {
    // ✅ Remove from UI
    setState(() {
      messages.removeWhere((m) => m.id == message.id);
    });

    // ✅ Save to Hive immediately
    await _saveMessagesToHive();

    // ✅ Also mark as deleted locally in a persistent way
    final deletedIds =
        await mySaveValues.getStringList('deleted_messages_${widget.chatId}') ??
        [];
    deletedIds.add(message.id);
    await mySaveValues.saveStringList(
      'deleted_messages_${widget.chatId}',
      deletedIds,
    );

    // ✅ NEW: Update chat list if this was the last message
    await _updateChatListAfterDelete(message);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Message deleted"),
          backgroundColor: HexColor("#1A7F4B"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ ADD THIS NEW METHOD
  // ✅ Update chat list after deleting a message
  Future<void> _updateChatListAfterDelete(ChatMessage deletedMessage) async {
    try {
      // Get chat list box
      final chatListBox = await Hive.openBox<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);

      if (chatItem == null) return;

      // Parse the last message
      final lastMessage = chatItem.lastMessage;

      // Check if the deleted message was the last message in chat list
      if (lastMessage?.id == deletedMessage.id) {
        // Find the new last message (the one before the deleted one)
        final newLastMessage = messages.isNotEmpty ? messages.last : null;

        if (newLastMessage != null) {
          // Update chat list with new last message
          final updatedLastMessageJson = json.encode({
            '_id': newLastMessage.id,
            'content': newLastMessage.text,
            'isImage': newLastMessage.isImage,
            'isVoiceNote': newLastMessage.isVoiceNote,
            'isAudio': newLastMessage.isAudioFile,
            'isVideo': newLastMessage.isVideo,
            'isDocument': newLastMessage.isDocument,
            'isContact': false,
            'createdAt': newLastMessage.timestamp,
          });

          final updatedChatItem = ChatListItemHive(
            id: chatItem.id,
            isGroupChat: chatItem.isGroupChat,
            title: chatItem.title,
            lastMessageJson: updatedLastMessageJson,
            updatedAt: DateTime.parse(newLastMessage.timestamp),
            profilePicture: chatItem.profilePicture,
            about: chatItem.about,
            userId: chatItem.userId,
            isArchived: chatItem.isArchived,
            isMuted: chatItem.isMuted,
          );

          await chatListBox.put(widget.chatId, updatedChatItem);
          print('✅ Updated chat list with new last message');
        } else {
          // No messages left - update with empty message
          final updatedChatItem = ChatListItemHive(
            id: chatItem.id,
            isGroupChat: chatItem.isGroupChat,
            title: chatItem.title,
            lastMessageJson: '', // Empty - no messages
            updatedAt: DateTime.now(),
            profilePicture: chatItem.profilePicture,
            about: chatItem.about,
            userId: chatItem.userId,
            isArchived: chatItem.isArchived,
            isMuted: chatItem.isMuted,
          );

          await chatListBox.put(widget.chatId, updatedChatItem);
          print('✅ Updated chat list - no messages left');
        }
      }
    } catch (e) {
      print('❌ Error updating chat list after delete: $e');
    }
  }

  // ✅ Delete for everyone
  Future<void> _deleteForEveryone(ChatMessage message) async {
    try {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: HexColor("#1A7F4B")),
        ),
      );

      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      final response = await http.delete(
        Uri.parse('${AppConfig.apiUrl}message/${message.id}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"deleteForEveryone": true}),
      );

      // ✅ Close ONLY the loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print("🗑️ Delete response: ${response.statusCode}");
      print("🗑️ Delete body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        // ✅ SUCCESS - Remove from UI
        if (mounted) {
          setState(() {
            messages.removeWhere((m) => m.id == message.id);
          });
        }

        await _saveMessagesToHive();

        // ✅ Only emit if socket exists and is connected
        if (socket?.connected == true) {
          socket?.emit('delete message', {
            "chatId": widget.chatId,
            "messageId": message.id,
            "deleteForEveryone": true,
          });
        }
        await _updateChatListAfterDelete(message);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Message deleted for everyone"),
              backgroundColor: HexColor("#1A7F4B"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception("Delete failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ Error deleting: $e');

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete message"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Sync mute state to the chat list Hive box ─────────────────────────────
  // Called after mute/unmute so the 🔇 icon in the chat list updates instantly.
  Future<void> _updateMuteInHive(bool muted) async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);
      if (chatItem == null) return;
      final updated = chatItem.copyWith(isMuted: muted);
      await chatListBox.put(widget.chatId, updated);
      debugPrint('🔇 [HIVE] isMuted=$muted saved for ${widget.chatId}');
    } catch (e) {
      debugPrint('❌ _updateMuteInHive error: $e');
    }
  }

  // ── Wipe the last-message preview from the chat list Hive box ─────────────
  // Called after Clear or Delete so the chat list shows no preview at all.
  /// ✅ SYNC FIX: Keeps the chat list tile tick in sync with the message screen.
  /// Called whenever a delivery or read receipt arrives so both boxes update atomically.
  Future<void> _syncLastMessageStatusToChatList(
    String status, {
    List<String>? messageIds,
  }) async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);
      if (chatItem == null || chatItem.lastMessageJson.isEmpty) return;

      final decoded =
          jsonDecode(chatItem.lastMessageJson) as Map<String, dynamic>;

      // Only update if the last message was sent by me
      final senderId = decoded['senderId']?.toString() ?? '';
      if (senderId != myUserId) return;

      // Never downgrade: read > delivered > sent
      final currentStatus = decoded['status']?.toString() ?? '';
      if (currentStatus == 'read') return; // already at highest state
      if (status == 'delivered' && currentStatus == 'read') return;

      final lastMsgId = (decoded['_id'] ?? decoded['id'] ?? '').toString();
      final matches =
          messageIds == null ||
          messageIds.isEmpty ||
          messageIds.contains(lastMsgId);
      if (!matches) return;

      decoded['status'] = status;
      if (status == 'read') {
        decoded['isRead'] = true;
      }

      await chatListBox.put(
        widget.chatId,
        chatItem.copyWith(lastMessageJson: jsonEncode(decoded)),
      );
      debugPrint(
        '✅ [SYNC] Chat list tick updated → $status for ${widget.chatId}',
      );
    } catch (e) {
      debugPrint('❌ _syncLastMessageStatusToChatList error: $e');
    }
  }

  Future<void> _wipeChatListPreview() async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);
      if (chatItem == null) return;

      final wiped = ChatListItemHive(
        id: chatItem.id,
        isGroupChat: chatItem.isGroupChat,
        title: chatItem.title,
        lastMessageJson: '', // ← empty string = no preview shown
        updatedAt: DateTime.now(),
        profilePicture: chatItem.profilePicture,
        about: chatItem.about,
        userId: chatItem.userId,
        isArchived: chatItem.isArchived,
        isMuted: chatItem.isMuted,
      );

      await chatListBox.put(widget.chatId, wiped);
      debugPrint('✅ Chat list preview wiped for ${widget.chatId}');
    } catch (e) {
      debugPrint('❌ _wipeChatListPreview error: $e');
    }
  }

  /// Updates the chat list Hive box with the latest sent message so the
  /// preview tile refreshes immediately — no need to wait for the 10s poll.
  Future<void> _updateChatListPreview({
    required String text,
    bool isImage = false,
    bool isVoiceNote = false,
    bool isAudio = false,
    bool isVideo = false,
    bool isDocument = false,
    String? messageId,
  }) async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.chatId);
      if (chatItem == null) return;

      final now = DateTime.now();
      String _ct = 'text';
      if (isImage)
        _ct = 'image';
      else if (isVideo)
        _ct = 'video';
      else if (isVoiceNote || isAudio)
        _ct = 'audio';
      else if (isDocument)
        _ct = 'document';

      final newLastMessageJson = json.encode({
        '_id': messageId ?? now.millisecondsSinceEpoch.toString(),
        'content': text,
        'senderId': myUserId,
        'isRead': false,
        'status': userStatus?.isOnline == true ? 'delivered' : 'sent',
        'isImage': isImage,
        'isVoiceNote': isVoiceNote,
        'isAudio': isAudio,
        'isVideo': isVideo,
        'isDocument': isDocument,
        'isContact': false,
        // ✅ These two fields prevent syncChatsToHive from overwriting the media flag
        'contentType': _ct,
        'attachments':
            (isImage || isVideo || isAudio || isVoiceNote || isDocument)
            ? [
                {'fileType': _ct, 'url': ''},
              ]
            : [],
        'createdAt': now.toIso8601String(),
      });

      final updated = ChatListItemHive(
        id: chatItem.id,
        isGroupChat: chatItem.isGroupChat,
        title: chatItem.title,
        lastMessageJson: newLastMessageJson,
        updatedAt: now,
        profilePicture: chatItem.profilePicture,
        about: chatItem.about,
        userId: chatItem.userId,
        isArchived: chatItem.isArchived,
        isMuted: chatItem.isMuted,
        isPinned: chatItem.isPinned,
        pinnedAt: chatItem.pinnedAt,
        memberCount: chatItem.memberCount,
        membersAvatarUrls: chatItem.membersAvatarUrls,
        memberUserIds: chatItem.memberUserIds,
      );

      await chatListBox.put(widget.chatId, updated);
      debugPrint(
        '✅ Chat list preview updated: ${isImage
            ? "📷 Photo"
            : isVideo
            ? "🎥 Video"
            : isVoiceNote
            ? "🎤 Voice"
            : isDocument
            ? "📄 Doc"
            : text}',
      );
    } catch (e) {
      debugPrint('❌ _updateChatListPreview error: $e');
    }
  }

  Future<void> _markDeletedChatTombstone() async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chat = chatListBox.get(widget.chatId);
      if (chat == null) return;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_deletedChatTombstonesKey);
      Map<String, dynamic> tombstones = <String, dynamic>{};
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) tombstones = decoded;
      }
      tombstones[widget.chatId] = {
        'lastMessageId': chat.lastMessage?.id,
        'updatedAt': chat.updatedAt.toIso8601String(),
      };
      await prefs.setString(_deletedChatTombstonesKey, jsonEncode(tombstones));
    } catch (e) {
      debugPrint('❌ _markDeletedChatTombstone error: $e');
    }
  }

  // ✅ NEW: Clear messages dialog
  // ===============================================================================
  // UPDATED CLEAR MESSAGES DIALOG
  // ===============================================================================

  // ✅ REPLACE THE _showClearMessagesDialog METHOD WITH THIS:

  void _showClearMessagesDialog() {
    // ✅ Save context immediately
    final savedContext = context;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: savedContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardBgAlt(isDark),
        title: Text(
          "Clear Messages",
          style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
        ),
        content: Text(
          "Are you sure you want to clear all messages in this chat? This action cannot be undone.",
          style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog
              Navigator.of(dialogContext).pop();

              // ✅ CHECK if still mounted before showing loading
              if (!mounted) return;

              // Show loading
              showDialog(
                context: savedContext,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) => WillPopScope(
                  onWillPop: () async => false,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgAlt(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: HexColor("#1A7F4B")),
                          SizedBox(height: 16),
                          Text(
                            "Clearing messages...",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                await Future.delayed(Duration(milliseconds: 200));

                if (mounted) {
                  setState(() => messages.clear());
                }

                await _chatBox.delete(widget.chatId);
                // ✅ Also wipe the chat list preview
                await _wipeChatListPreview();

                await Future.delayed(Duration(milliseconds: 200));

                if (mounted && Navigator.canPop(savedContext)) {
                  Navigator.of(savedContext).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(savedContext).showSnackBar(
                    SnackBar(
                      content: Text("Messages cleared successfully"),
                      backgroundColor: HexColor("#1A7F4B"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error clearing messages: $e');

                if (mounted && Navigator.canPop(savedContext)) {
                  Navigator.of(savedContext).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(savedContext).showSnackBar(
                    SnackBar(
                      content: Text("Failed to clear messages"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 10;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateKeyboardHeight();
    });
    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ CHANGED from HexColor("#141414")
      resizeToAvoidBottomInset: true,

      // ✅ REMOVED appBar parameter - it's now inside body
      body: Container(
        // ✅ NEW: Wrap entire body in Container
        // ✅ NEW: Add wallpaper decoration
        decoration: _wallpaperPath != null
            ? _getWallpaperDecoration(_wallpaperPath!)
            : BoxDecoration(color: AppTheme.scaffoldBg(isDark)),

        child: Column(
          // ✅ Column is now child of Container
          children: [
            // ✅ NEW: AppBar moved here as first child of Column
            PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: HexColor("#3A1D07"),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/app_bar_gredient.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomBottomNav(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 22.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () async {
                                final profile = await UserProfileService()
                                    .fetchUserProfile(widget.userId);

                                if (profile != null) {
                                  final pictures =
                                      profile.profilePictures ??
                                      (profile.profilePicture.isNotEmpty
                                          ? [profile.profilePicture]
                                          : []);

                                  if (pictures.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfilePictureViewer(
                                          imageUrls: pictures,
                                          username: widget.username,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No profile picture available',
                                        ),
                                        backgroundColor: HexColor("#FF6B00"),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not load user profile',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Hero(
                                  tag: 'profile_picture_${widget.userId}',
                                  child: CachedProfileAvatar(
                                    imageUrl: _displayProfilePicture.isNotEmpty
                                        ? _getFullImageUrl(
                                            _displayProfilePicture,
                                          )
                                        : null,
                                    displayName: widget.username,
                                    radius: 17,
                                    backgroundColor: HexColor("#FB8830"),
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                if (widget.isGroupChat ||
                                    widget.userId.isEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GroupInfoScreen(
                                        groupId: widget.chatId,
                                        groupName: widget.username,
                                        groupImage: widget.profilePicture,
                                      ),
                                    ),
                                  ).then((_) => _loadWallpaperAndColor());
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatUserInfoScreen(
                                        userId: widget.userId,
                                        username: widget.username,
                                        profilePicture: widget.profilePicture,
                                        about: widget.about,
                                        mediaCount: _getMediaCount(),
                                        chatId: widget.chatId,
                                      ),
                                    ),
                                  ).then((_) => _loadWallpaperAndColor());
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100.0,
                                      child: Text(
                                        widget.username,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                    ),
                                    buildOnlineStatus(userStatus),
                                  ],
                                ),
                              ),
                            ),

                            const Expanded(child: SizedBox()),

                            if (ref.watch(callStateProvider) != null &&
                                ref.watch(callStateProvider)!.userId ==
                                    widget.userId &&
                                ref.watch(callStateProvider)!.state !=
                                    CallState.ended)
                              _buildOngoingCallReturnButton()
                            else if (widget.isContact && !_isBlocked) ...[
                              InkWell(
                                onTap: () => _initiateCall(isVideo: true),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 0.0),
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: Colors.white,
                                    size: 27.0,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _initiateCall(isVideo: false),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 15.0,
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.white,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            ],

                            Builder(
                              builder: (BuildContext context) {
                                return InkWell(
                                  onTap: () => _showThreeDotMenu(),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 25.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ NEW: Search bar (shows when search is active)
            if (isSearchActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.cardBg(isDark),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        style: TextStyle(color: AppTheme.textPrimary(isDark)),
                        decoration: InputDecoration(
                          hintText: "Search messages...",
                          hintStyle: TextStyle(
                            color: AppTheme.textHint(isDark),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.iconColorSubtle(isDark),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.inputFill(isDark),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.iconColor(isDark),
                      ),
                      onPressed: () {
                        setState(() {
                          isSearchActive = false;
                          searchController.clear();
                          _searchQuery = '';
                          _filteredMessages = [];
                        });
                      },
                    ),
                  ],
                ),
              ),

            // ✅ ISSUE 2 FIX: Show ongoing call banner on all message screens
            OngoingCallBanner(),
            PinnedMessageBanner(
              key: _pinnedBannerKey,
              chatId: widget.chatId,
              currentUserId: myUserId,
              isAdmin: false,
              onChanged: () => _pinnedBannerKey.currentState?.reload(),
            ),

            // ✅ TYPING INDICATOR
            Expanded(
              child: Stack(
                children: [
                  _buildMessageList(),
                  // ✅ "NEW MESSAGES" INDICATOR - shows when scrolled up and new messages arrive
                  if (_newMessageCount > 0 && _showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _newMessageCount = 0);
                            _jumpToBottom();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: HexColor("#1A7F4B"),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _newMessageCount == 1
                                      ? '1 new message'
                                      : '${_newMessageCount} new messages',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ✅ TYPING INDICATOR - Now above input box
            if (isTyping)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Text(
                      _getTypingDisplayText(),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            if (_isBlocked) _buildBlockedBanner() else _buildRecorderOrInput(),

            // ── Emoji / GIF picker ──
            if (_showEmojiPicker || _showGifPicker)
              Container(
                height: _safePickerHeight(context),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(isDark),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: EmojiGifPicker(
                    showGif: _showGifPicker,
                    onTabChanged: (isGif) =>
                        setState(() => _showGifPicker = isGif),
                    onEmojiSelected: (emoji) {
                      final cur = messageController.text;
                      final sel = messageController.selection;
                      final start = sel.start < 0 ? cur.length : sel.start;
                      final end = sel.end < 0 ? cur.length : sel.end;
                      final newText = cur.replaceRange(start, end, emoji);
                      messageController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                          offset: start + emoji.length,
                        ),
                      );
                      // ✅ Manually update _isUserTyping since programmatic
                      // changes don't trigger onChanged
                      setState(() => _isUserTyping = newText.trim().isNotEmpty);
                    },
                    onGifSelected: (url) async {
                      setState(() {
                        _showEmojiPicker = false;
                        _showGifPicker = false;
                      });
                      // Send GIF as image message
                      final tempId = DateTime.now().millisecondsSinceEpoch
                          .toString();
                      final gifMsg = ChatMessage(
                        id: tempId,
                        chatId: widget.chatId,
                        isImage: true,
                        imageUrls: [url],
                        text: '',
                        isMe: true,
                        isRead: false,
                        status: MessageStatus.sending,
                        timestamp: DateTime.now().toIso8601String(),
                      );
                      await _addMessage(gifMsg);
                      _scrollToBottom();
                      final serverId = await sendMessageToApi(
                        chatId: widget.chatId,
                        content: url,
                      );
                      if (serverId != null) {
                        await _updateMessage(
                          gifMsg.copyWith(
                            id: serverId,
                            status: MessageStatus.sent,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      // ✅ SCROLL TO BOTTOM BUTTON - positioned above input
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: EdgeInsets.only(
                bottom: showRecorder ? 80.0 : 80.0, // Above input/recorder
              ),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: HexColor("#1A7F4B"),
                onPressed: () {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildOnlineStatus(UserOnlineData? userStatus) {
    // ✅ Use privacy-aware getters instead of raw userStatus
    final isOnline = _displayIsOnline;
    final lastSeen = _displayLastSeen;

    if (isOnline) {
      return Text(
        "Online",
        style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12),
      );
    }

    // ✅ If last seen is hidden by privacy setting, show nothing
    if (lastSeen.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 130,
      height: 16,
      child: Marquee(
        text: "Last seen $lastSeen",
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 30.0,
        velocity: 20.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(milliseconds: 800),
        accelerationCurve: Curves.easeOut,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeIn,
      ),
    );
  }

  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return "";

    final difference = DateTime.now().difference(lastActive);

    if (difference.inMinutes < 1) return "just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
  }

  Widget _buildMessageList() {
    final displayMessages = _searchQuery.isEmpty ? messages : _filteredMessages;

    if (displayMessages.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? "" : "No messages found",
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return Listener(
      // ✅ FIX 2: Listener fires on raw pointer events — never competes with scroll
      onPointerDown: (event) {
        _swipeStartY = event.position.dy;
      },
      onPointerUp: (event) {
        if (_swipeStartY == null) return;
        final deltaY = event.position.dy - _swipeStartY!;
        _swipeStartY = null;

        // deltaY negative = finger moved upward
        // Require at least 80px upward swipe
        if (deltaY < -80) {
          bool isAtBottom = false;
          if (scrollController.hasClients) {
            final distanceFromBottom =
                scrollController.position.maxScrollExtent -
                scrollController.position.pixels;
            isAtBottom = distanceFromBottom < 80;
          }
          if (isAtBottom) {
            _openSendMoneySheet();
          }
        }
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: displayMessages.length,
        itemBuilder: (context, index) {
          final msg = displayMessages[index];
          return Column(
            key: ValueKey(msg.id),
            children: [
              if (shouldShowDateSeparator(displayMessages, index))
                DateSeparator(date: DateTime.parse(msg.timestamp)),
              _buildMessageItem(msg),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSendMoneySheet() async {
    FocusScope.of(context).unfocus();
    final senderName =
        await mySaveValues.getString(AppPreferenceHelper.USER_NAME) ?? 'You';

    // Builds the __TRANSACTION__ message string carrying ALL receipt fields.
    String _txText(TransactionRecord r) =>
        '__TRANSACTION__'
        ':${r.amount}'
        ':${r.receiverName}'
        ':${r.receiverBank}'
        ':${r.receiverAccountNumber}'
        ':${r.senderName}'
        ':${r.timestamp.toIso8601String()}';

    // Track whether the user tapped "Share Receipt" so we don't double-post.
    bool _receiptShared = false;

    // onShareReceipt: fired ONLY when user taps "Share Receipt".
    // This is the single place that posts to server + local list.
    void postReceiptMessage(TransactionRecord record) async {
      if (!mounted) return;
      _receiptShared = true;
      await _reloadTransactionsFromStorage();
      final txText = _txText(record);
      // Send to server first — server broadcasts to recipient via socket.
      await sendMessageToApi(chatId: widget.chatId, content: txText);
      // Add locally so sender sees it instantly without waiting for socket echo.
      final txMessage = ChatMessage(
        id: '${record.id}_receipt',
        chatId: widget.chatId,
        text: txText,
        isMe: true,
        isRead: false,
        status: MessageStatus.sent,
        timestamp: record.timestamp.toIso8601String(),
      );
      await _addMessage(txMessage);
      _scrollToBottom();
    }

    final result = await SendMoneySheet.show(
      context,
      recipientName: widget.username,
      recipientAccountNumber: widget.userId,
      recipientBank: 'Qiktag Bank',
      senderName: senderName,
      chatId: widget.chatId,
      profilePicture: widget.profilePicture,
      onShareReceipt: postReceiptMessage,
    );

    if (result != null && mounted && !_receiptShared) {
      await _reloadTransactionsFromStorage();
      final txText = _txText(result);
      await sendMessageToApi(chatId: widget.chatId, content: txText);
      final txMessage = ChatMessage(
        id: result.id,
        chatId: widget.chatId,
        text: txText,
        isMe: true,
        isRead: false,
        status: MessageStatus.sent,
        timestamp: result.timestamp.toIso8601String(),
      );
      await _addMessage(txMessage);
      _scrollToBottom();
    }
  }

  Future<void> sendMoneyRequest({
    required double amount,
    required String requesterName,
    required String accountNo,
    required String bankName,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    // 1. Format the magic string for the request
    // Format: __MONEY-REQUEST__:amount:receiverName:receiverBank:receiverAcct:senderName:timestamp
    final requestText =
        '__MONEY-REQUEST__:$amount:$requesterName:$bankName:$accountNo:$requesterName:$timestamp';

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // 2. Create a local temporary message (Optimistic UI so it shows instantly)
    final tempMessage = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      text: requestText,
      isMe: true,
      status: MessageStatus.sending,
      timestamp: timestamp,
      isRead: false,
    );

    await _addMessage(tempMessage);
    _scrollToBottom();

    // 3. Send to API just like a normal text message!
    final serverId = await sendMessageToApi(
      chatId: widget.chatId,
      content: requestText,
    );

    if (serverId != null) {
      await _updateMessage(
        tempMessage.copyWith(id: serverId, status: MessageStatus.sent),
      );
      await _updateChatListPreview(
        text: "Requested ₦$amount",
        messageId: serverId,
      );
    } else {
      _markFailed(tempId);
    }
  }

  Future<void> _reloadTransactionsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'transactions_${widget.chatId}';
      final raw = prefs.getStringList(key) ?? [];
      final loaded = raw
          .map((e) => TransactionRecord.fromJson(jsonDecode(e)))
          .toList();
      if (mounted) {
        setState(() {
          _localTransactions = loaded;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to reload transactions: $e');
    }
  }

  Widget _buildRecordingContainer() {
    return RecorderUI(
      onDelete: _deleteRecording,
      onSend: () async {
        await sendRecording();
      },
      recorderController: _audioRecorder.recorderController,
      recordingDuration: recordingDuration,
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final bool isHighlighted = _highlightedMessageId == msg.id;

    // ✅ Common reply handler for all message types
    void _handleReply() {
      _startReplyToMessage(msg);
    }

    // ── Contact share bubble ─────────────────────────────────────────────────
    if (msg.text.startsWith('__CONTACT_SHARE__:')) {
      final rawContact = msg.text.substring('__CONTACT_SHARE__:'.length);
      final firstColon = rawContact.indexOf(':');
      final secondColon = firstColon != -1
          ? rawContact.indexOf(':', firstColon + 1)
          : -1;
      final cName = firstColon != -1
          ? rawContact.substring(0, firstColon)
          : rawContact;
      final cPhone = (firstColon != -1 && secondColon != -1)
          ? rawContact.substring(firstColon + 1, secondColon)
          : (firstColon != -1 ? rawContact.substring(firstColon + 1) : '');
      final cPic = secondColon != -1
          ? rawContact.substring(secondColon + 1)
          : '';
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () => _showMessageOptions(msg),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? (msg.isMe ? HexColor('#1B1B1B') : HexColor('#232323'))
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isMe ? 16 : 0),
                bottomRight: Radius.circular(msg.isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: HexColor('#1A7F4B').withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: HexColor('#FB8830'),
                      backgroundImage:
                          (cPic.isNotEmpty && cPic.startsWith('http'))
                          ? NetworkImage(cPic)
                          : null,
                      child: (cPic.isEmpty || !cPic.startsWith('http'))
                          ? Text(
                              cName.isNotEmpty ? cName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cName,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1008),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            cPhone,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF8A7060),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withOpacity(0.08),
                ),
                const SizedBox(height: 8),
                Text(
                  '👤 Contact',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF8A7060),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── GIF bubble — must check BEFORE isImage ──
    if (EmojiGifPicker.isGifUrl(msg.text)) {
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OfflineCachedImage(
              imageUrl: msg.text.trim(),
              width: MediaQuery.of(context).size.width * 0.65,
              height: 120,
              fit: BoxFit.cover,
              placeholder: Container(
                height: 120,
                color: const Color(0xFF2A2A2A),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A7F4B),
                  ),
                ),
              ),
              errorWidget: Container(
                height: 80,
                color: const Color(0xFF2A2A2A),
                child: const Center(
                  child: Icon(Icons.gif, color: Colors.white38, size: 40),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Status reply bubble ──
    if (StatusReplyBubble.isStatusReply(msg.text)) {
      return StatusReplyBubble(
        rawContent: msg.text,
        isMe: msg.isMe,
        timestamp: msg.timestamp,
        isRead: msg.isRead,
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (direction) => _handleReply(),
      );
    }

    // Scheduled message card
    if (msg.text.startsWith('__SCHEDULED__:')) {
      final raw = msg.text.substring('__SCHEDULED__:'.length);
      final colonIdx = raw.indexOf(':');
      final isoStr = colonIdx != -1 ? raw.substring(0, colonIdx) : raw;
      final msgText = colonIdx != -1 ? raw.substring(colonIdx + 1) : '';
      final scheduledAt = DateTime.tryParse(isoStr) ?? DateTime.now();
      return _buildScheduledCard(msg.id, msgText, scheduledAt);
    }

    // Transaction bubble
    if (msg.text.startsWith('__TRANSACTION__:')) {
      final parts = msg.text.split(':');

      if (parts.length >= 5) {
        // ISO timestamp may itself contain colons — rejoin from index 6 onward
        String parsedTimestamp = msg.timestamp;
        if (parts.length >= 7) {
          parsedTimestamp = parts.sublist(6).join(':');
        }
        final record = TransactionRecord(
          id: msg.id,
          chatId: msg.chatId,
          senderName: parts.length >= 6
              ? parts[5]
              : (msg.isMe ? 'You' : 'Sender'),
          receiverName: parts[2],
          receiverAccountNumber: parts[4],
          receiverBank: parts[3],
          amount: double.tryParse(parts[1]) ?? 0,
          timestamp:
              DateTime.tryParse(parsedTimestamp) ??
              DateTime.parse(msg.timestamp),
          isMe: msg.isMe,
        );
        return TransactionBubble(transaction: record);
      }
    }

    if (msg.text.startsWith('__MONEY-REQUEST__:')) {
      final parts = msg.text.split(':');
      if (parts.length >= 5) {
        String parsedTimestamp = msg.timestamp;
        if (parts.length >= 7) {
          parsedTimestamp = parts.sublist(6).join(':');
        }
        final record = TransactionRecord(
          id: msg.id,
          chatId: msg.chatId,
          senderName: parts.length >= 6
              ? parts[5]
              : (msg.isMe ? 'You' : 'Sender'),
          receiverName: parts[2],
          receiverAccountNumber: parts[4],
          receiverBank: parts[3],
          amount: double.tryParse(parts[1]) ?? 0,
          timestamp:
              DateTime.tryParse(parsedTimestamp) ??
              DateTime.parse(msg.timestamp),
          isMe: msg.isMe,
        );

        return RequestMoneyBubble();
      }
    }

    // ✅ Call event bubble
    if (msg.isCallEvent) {
      return CallEventBubble(
        callType: msg.callType ?? 'audio',
        callStatus: msg.callStatus ?? 'missed',
        isOutgoing: msg.isMe,
        duration: msg.callDuration ?? 0,
        timestamp: msg.timestamp,
        onTap: () => _initiateCall(isVideo: msg.callType == 'video'),
        onSwipe: (_) => _handleReply(),
      );
    }

    // Catch plain-text call messages (e.g. "Cancelled Voice call", "Incoming Video call - 2m 3s")
    // saved before contentType:'call' was used
    final plainCallBubble = CallEventBubble.fromPlainText(
      text: msg.text,
      timestamp: msg.timestamp,
      isMe: msg.isMe,
      onTap: () =>
          _initiateCall(isVideo: msg.text.toLowerCase().contains('video')),
      onSwipe: (_) => _handleReply(),
    );
    if (plainCallBubble != null) return plainCallBubble;

    if (msg.isVoiceNote) {
      return VoiceNoteBubble(
        audioUrl: msg.audioUrl!,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        status: msg.status,
        isSaved: savedMessageIds.contains(msg.id),
        replyToText: msg.replyToText,
        replyToIsMe: msg.replyToIsMe,
        replyToSenderName: msg.replyToSenderName,
        replyToMediaType: msg.replyToMediaType,
        replyToThumbnailUrl: msg.replyToThumbnailUrl,
        isForwarded: msg.isForwarded,
        onReplyTap: msg.replyToMessageId != null
            ? () => _scrollToMessage(msg.replyToMessageId!)
            : null,
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (direction) => _handleReply(),
      );
    }

    if (msg.isAudioFile) {
      return AudioFileBubble(
        audioUrl: msg.audioUrl!,
        fileName:
            (msg.audioName != null &&
                msg.audioName!.isNotEmpty &&
                msg.audioName!.toLowerCase() != 'attachment')
            ? msg.audioName!
            : (() {
                try {
                  final uri = Uri.parse(msg.audioUrl!);
                  final seg = uri.pathSegments;
                  return seg.isNotEmpty ? seg.last : 'audio_file';
                } catch (_) {
                  return 'audio_file';
                }
              })(),
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        status: msg.status,
        isSaved: savedMessageIds.contains(msg.id),
        replyToText: msg.replyToText,
        replyToIsMe: msg.replyToIsMe,
        replyToSenderName: msg.replyToSenderName, // ✅ BUG1 FIX
        replyToMediaType: msg.replyToMediaType, // ✅ BUG1 FIX
        replyToThumbnailUrl: msg.replyToThumbnailUrl, // ✅ BUG1 FIX
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (direction) => _handleReply(),
      );
    }

    if (msg.isDocument) {
      return DocumentBubble(
        name: msg.documentName ?? "document.pdf",
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        documentUrl: msg.documentUrl,
        status: msg.status,
      );
    }

    if (msg.isVideo) {
      return VideoBubble(
        videoUrl: msg.videoUrl!,
        thumbnail: msg.videoThumbnail,
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        isSaved: savedMessageIds.contains(msg.id),
        replyToText: msg.replyToText,
        replyToIsMe: msg.replyToIsMe,
        replyToSenderName: msg.replyToSenderName,
        replyToMediaType: msg.replyToMediaType,
        replyToThumbnailUrl: msg.replyToThumbnailUrl,
        isForwarded: msg.isForwarded,
        onReplyTap: msg.replyToMessageId != null
            ? () => _scrollToMessage(msg.replyToMessageId!)
            : null,
        status: msg.status,
        isRecipientOnline: userStatus?.isOnline ?? false,
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (direction) => _handleReply(),
      );
    }

    if (msg.isImage && msg.imageUrls != null && msg.imageUrls!.isNotEmpty) {
      final isUploading = msg.status == MessageStatus.sending && msg.isMe;
      final progress = _messageUploadProgress[msg.id] ?? uploadProgress;
      return MultiImageBubble(
        images: msg.imageUrls!,
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        status: msg.status,
        isSaved: savedMessageIds.contains(msg.id),
        replyToText: msg.replyToText,
        replyToIsMe: msg.replyToIsMe,
        replyToSenderName: msg.replyToSenderName,
        replyToMediaType: msg.replyToMediaType,
        replyToThumbnailUrl: msg.replyToThumbnailUrl,
        isForwarded: msg.isForwarded,
        onReplyTap: msg.replyToMessageId != null
            ? () => _scrollToMessage(msg.replyToMessageId!)
            : null,
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (direction) => _handleReply(),
        uploadProgress: isUploading ? progress : null,
      );
    }

    final bubble = ChatMessageBubble(
      text: msg.text,
      isMe: msg.isMe,
      isRead: msg.isRead,
      isEdited: msg.isEdited,
      timestamp: msg.timestamp,
      isSaved: savedMessageIds.contains(msg.id),
      replyToText: msg.replyToText,
      replyToIsMe: msg.replyToIsMe,
      replyToSenderName: msg.replyToSenderName,
      replyToMediaType: msg.replyToMediaType,
      replyToThumbnailUrl: msg.replyToThumbnailUrl,
      replyToMessageId: msg.replyToMessageId,
      status: msg.status,
      isRecipientOnline: userStatus?.isOnline ?? false,
      bubbleColor: _customBubbleColor,
      receiverBubbleColor: _receiverBubbleColor,
      senderGlowColor: _senderGlowColor,
      receiverGlowColor: _receiverGlowColor,
      isForwarded: msg.isForwarded,
      onLongPress: () => _showMessageOptions(msg),
      onSwipe: (direction) => _handleReply(),
      onReplyTap: msg.replyToMessageId != null
          ? () => _scrollToMessage(msg.replyToMessageId!)
          : null,
      readReceiptsEnabled: ref.read(privacySettingsProvider).readReceipts,
    );

    if (!isHighlighted) return bubble;

    // Flashing highlight container for search-jumped messages
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6900).withOpacity(isHighlighted ? 0.15 : 0.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: bubble,
    );
  }

  Widget _buildInputField() {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: keyboardOpen
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: keyboardOpen
              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
              : ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              // Keyboard OPEN: fully solid dark — no messages bleed through
              // Keyboard CLOSED: very low opacity white = frosted glass look
              color: keyboardOpen
                  ? AppTheme.cardBg(
                      Theme.of(context).brightness == Brightness.dark,
                    )
                  : Colors.white.withOpacity(0.04),
              border: keyboardOpen
                  ? null
                  : Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 0.8,
                      ),
                    ),
              boxShadow: keyboardOpen
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: -6,
                        offset: const Offset(0, -8),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                // ✅ REPLY PREVIEW BAR
                if (isReplying && replyingToText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.reply, color: HexColor("#1A7F4B"), size: 18),
                        const SizedBox(width: 8),
                        if (replyingToMediaType == 'image' &&
                            replyingToThumbnailUrl != null &&
                            replyingToThumbnailUrl!.isNotEmpty)
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.black26,
                            ),
                            child: replyingToThumbnailUrl!.startsWith('http')
                                ? Image.network(
                                    replyingToThumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  )
                                : Image.file(
                                    File(replyingToThumbnailUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                          )
                        else if (replyingToMediaType != null)
                          Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: HexColor('#1A7F4B').withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Icon(
                                replyingToMediaType == 'video'
                                    ? Icons.videocam_outlined
                                    : replyingToMediaType == 'voice' ||
                                          replyingToMediaType == 'voice_note'
                                    ? Icons.graphic_eq
                                    : replyingToMediaType == 'audio'
                                    ? Icons.audiotrack
                                    : replyingToMediaType == 'document'
                                    ? Icons.description_outlined
                                    : Icons.insert_drive_file_outlined,
                                color: HexColor('#1A7F4B'),
                                size: 20,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                replyingToIsMe == true
                                    ? "Replying to yourself"
                                    : "Replying to ${widget.username}",
                                style: TextStyle(
                                  color: HexColor("#1A7F4B"),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                replyingToMediaType == null
                                    ? replyingToText!
                                    : '${replyingToMediaType![0].toUpperCase()}${replyingToMediaType!.substring(1)} • ${replyingToText!}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _clearReplyState();
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ✅ EDIT PREVIEW BAR
                if (isEditing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Editing message",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        GestureDetector(
                          onTap: _cancelEditing,
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _buildMessageInput(keyboardOpen: keyboardOpen),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput({bool keyboardOpen = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: isDark
                  ? const DecorationImage(
                      image: AssetImage("images/app_bar_gredient.png"),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: isDark ? null : const Color(0xFFFAF5F0),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : AppTheme.border(isDark),
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: messageController,
              focusNode: _messageFocusNode,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
              minLines: 1,
              onChanged: (value) {
                final typingNow = value.trim().isNotEmpty;
                setState(() {
                  _isUserTyping = typingNow;
                  if (typingNow && _showEmojiPicker) _showEmojiPicker = false;
                });
                if (typingNow) {
                  _startTyping();
                } else {
                  _stopTyping();
                }
              },
              style: TextStyle(
                fontSize: 15.0,
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              ),
              cursorColor: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white : AppTheme.textHint(isDark),
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    _showEmojiPicker || _showGifPicker
                        ? Icons.keyboard_outlined
                        : Icons.emoji_emotions_outlined,
                    color: _showEmojiPicker || _showGifPicker
                        ? const Color(0xFF1A7F4B)
                        : (isDark
                              ? Colors.white54
                              : AppTheme.iconColorSubtle(isDark)),
                    size: 22,
                  ),
                  onPressed: () {
                    if (_showEmojiPicker || _showGifPicker) {
                      setState(() {
                        _showEmojiPicker = false;
                        _showGifPicker = false;
                      });
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_messageFocusNode);
                        }
                      });
                    } else {
                      final kh = MediaQuery.of(context).viewInsets.bottom;
                      if (kh > 100) setState(() => _keyboardHeight = kh);
                      _messageFocusNode.unfocus();
                      setState(() {
                        _showEmojiPicker = true;
                        _showGifPicker = false;
                      });
                    }
                  },
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _isUserTyping
                            ? GestureDetector(
                                key: const ValueKey('calendar'),
                                onTap: _openSchedulePicker,
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.iconColor(isDark),
                                  size: 24,
                                ),
                              )
                            : GestureDetector(
                                key: const ValueKey('camera'),
                                onTap: _openCamera,
                                child: Image(
                                  image: const AssetImage("images/cam.png"),
                                  width: 24,
                                  height: 24,
                                  color: isDark
                                      ? null
                                      : AppTheme.iconColor(isDark),
                                ),
                              ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: _showCustomDialog,
                        child: Image(
                          image: const AssetImage("images/button_add.png"),
                          width: 30,
                          height: 30,
                          color: isDark ? null : AppTheme.iconColor(isDark),
                        ),
                      ),
                      const SizedBox(width: 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 10.0),

        InkWell(
          onTap: _isUserTyping ? handleSend : startRecording,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: HexColor("#1A7F4B"),
              child: Image.asset(
                _isUserTyping
                    ? 'images/send_chat.png'
                    : 'images/record_chat.png',
                key: ValueKey(_isUserTyping),
                height: 24,
                width: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 320.0,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(biometricAuthProvider.notifier).isPickerActive =
                          true;
                      Navigator.pop(context);
                      _openCamera();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#F6695E"),
                          child: Icon(
                            Icons.camera_alt,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "Camera",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      ref.read(biometricAuthProvider.notifier).isPickerActive =
                          true;
                      Navigator.pop(context);
                      _pickAudioFile();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#66D0FF"),
                          child: Image(
                            image: AssetImage("images/record_chat.png"),
                            width: 24,
                            height: 24,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "Audio",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _openContactPickerForSharing();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#4484CD"),
                          child: Icon(
                            Icons.person,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "Contact",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(biometricAuthProvider.notifier).isPickerActive =
                          true;
                      Navigator.pop(context);
                      _pickImages();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#FFD233"),
                          child: Image(
                            image: AssetImage("images/gallery.png"),
                            width: 24,
                            height: 24,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "Gallery",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      ref.read(biometricAuthProvider.notifier).isPickerActive =
                          true;
                      Navigator.pop(context);
                      _pickVideo();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#40C4FF"),
                          child: Image(
                            image: AssetImage("images/gallery.png"),
                            width: 24,
                            height: 24,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "Video",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      ref.read(biometricAuthProvider.notifier).isPickerActive =
                          true;
                      Navigator.pop(context);
                      _pickDocument();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: HexColor("#33D375"),
                          child: Image(
                            image: AssetImage("images/document.png"),
                            width: 24,
                            height: 24,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 0.0,
                          ),
                          child: Text(
                            "document",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ✅ SEND MONEY SHEET TRIGGER (also callable from attachment dialog)
  void _showSendMoneyOption() {
    Navigator.pop(context);
    _openSendMoneySheet();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      // ✅ Request storage permission
      final storageResult = await _permissionService.requestStorage(context);

      debugPrint('📸 Storage permission result: $storageResult');

      // If denied, just return (don't show error - permission service handles it)
      if (storageResult != PermissionResult.granted) {
        debugPrint('❌ Storage permission not granted');
        return;
      }

      debugPrint('✅ Storage permission granted - opening picker');

      // Permission granted - pick images
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (images.isEmpty) return;

      if (images.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 10 images")),
        );
        return;
      }

      _openImagePreview(images.map((e) => File(e.path)).toList());
    } catch (e) {
      debugPrint('❌ Error picking images: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting images: $e')));
    }
  }

  final ImagePicker _cameraPicker = ImagePicker();

  Future<void> _openCamera() async {
    // ✅ Check camera permission
    final cameraResult = await _permissionService.requestCamera(context);

    if (cameraResult == PermissionResult.permanentlyDenied) {
      await _permissionService.showSettingsDialog(
        context,
        title: 'Camera Permission Required',
        message:
            'Please enable camera access in your device settings to capture media.',
      );
      return;
    }

    if (cameraResult == PermissionResult.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission is required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Show choice dialog: Photo or Video
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("#2E2E2E"),
        title: Text('Capture', style: TextStyle(color: Colors.white)),
        content: Text(
          'What would you like to capture?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'photo'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: HexColor("#1A7F4B")),
                SizedBox(width: 8),
                Text('Photo', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'video'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: HexColor("#1A7F4B")),
                SizedBox(width: 8),
                Text('Video', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == 'photo') {
      // Take photo
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final XFile? image = await _cameraPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (image != null) {
        print("📸 Photo taken: ${image.path}");
        _openImagePreview([File(image.path)]);
      }
    } else if (choice == 'video') {
      // Record video
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final XFile? video = await _cameraPicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (video != null) {
        print("📹 Video recorded: ${video.path}");
        final file = File(video.path);

        // Show video preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnhancedVideoPreviewScreen(
              videoFile: file,
              onSend: (video, caption) {
                _sendVideo(video, content: caption);
              },
            ),
          ),
        );
      }
    }
  }

  void _openImagePreview(List<File> files) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedImagePreviewScreen(
          images: files,
          onSend: (editedImages, caption) {
            _sendMultipleImages(editedImages, caption);
          },
        ),
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      final storageResult = await _permissionService.requestStorage(context);
      if (storageResult != PermissionResult.granted) {
        debugPrint('❌ Storage permission not granted for audio');
        return;
      }

      ref.read(biometricAuthProvider.notifier).isPickerActive = true;

      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
      } catch (pickerError) {
        // FilePicker can throw on some Android versions with audio type.
        // Fall back to any file type and filter client-side.
        debugPrint('⚠️ Audio picker failed, falling back to any: $pickerError');
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
        } catch (e2) {
          debugPrint('❌ Fallback picker also failed: $e2');
        }
      }

      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (result == null) return;
      final platformFile = result.files.single;
      final path = platformFile.path;

      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access the selected file')),
          );
        }
        return;
      }

      // Validate it is actually an audio file
      final mimeType = lookupMimeType(path) ?? '';
      final isAudio =
          mimeType.startsWith('audio/') ||
          path.toLowerCase().endsWith('.mp3') ||
          path.toLowerCase().endsWith('.m4a') ||
          path.toLowerCase().endsWith('.aac') ||
          path.toLowerCase().endsWith('.ogg') ||
          path.toLowerCase().endsWith('.wav') ||
          path.toLowerCase().endsWith('.flac') ||
          path.toLowerCase().endsWith('.opus') ||
          path.toLowerCase().endsWith('.wma') ||
          path.toLowerCase().endsWith('.3gp');

      if (!isAudio) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a valid audio file'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio file not found on device'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get duration — use 1 as fallback so valid-but-unreadable files still send
      int duration = 0;
      try {
        duration = await getRealAudioDuration(path);
      } catch (e) {
        debugPrint('⚠️ Could not read audio duration: $e');
        duration = 1;
      }

      if (duration == 0) {
        // Try to send anyway — some formats just report 0
        duration = 1;
      }

      // Show preview screen before sending
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AudioPreviewScreen(
            audioFile: file,
            onSend: (audioFile) => _sendPickedAudio(audioFile, duration),
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error picking audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      // ✅ Request storage permission
      final storageResult = await _permissionService.requestStorage(context);

      debugPrint('📄 Storage permission result: $storageResult');

      if (storageResult != PermissionResult.granted) {
        debugPrint('❌ Storage permission not granted for document');
        return;
      }

      debugPrint('✅ Storage permission granted - opening document picker');

      // Pick document
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final result = await FilePicker.platform.pickFiles();
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);

      final caption = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => DocumentPreviewScreen(file: file)),
      );

      if (caption != null) {
        _sendDocument(file, content: caption);
      }
    } catch (e) {
      debugPrint('❌ Error picking document: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting document: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      // ✅ Request storage permission
      final storageResult = await _permissionService.requestStorage(context);

      debugPrint('🎥 Storage permission result: $storageResult');

      // If denied, just return (permission service handles showing dialogs)
      if (storageResult != PermissionResult.granted) {
        debugPrint('❌ Storage permission not granted for video');
        return;
      }

      debugPrint('✅ Storage permission granted - opening video picker');

      // Pick video file
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();

      if (result == null || result.files.single.path == null) {
        debugPrint('❌ No video selected');
        return;
      }

      final file = File(result.files.single.path!);
      debugPrint('✅ Video selected: ${file.path}');

      // Validate video duration
      VideoTrimmingService.showValidatingDialog(context);

      final validation = await VideoTrimmingService.validateVideo(file);

      if (mounted) {
        Navigator.pop(context); // Close validating dialog
      }

      if (!validation.isValid) {
        debugPrint('❌ Video validation failed: ${validation.error}');
        if (mounted) {
          await VideoTrimmingService.showVideoTooLongDialog(
            context,
            validation.duration,
          );
        }
        return;
      }

      debugPrint('✅ Video validated - showing preview');

      // Show enhanced video preview
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnhancedVideoPreviewScreen(
              videoFile: file,
              onSend: (video, caption) {
                debugPrint('📤 Sending video with caption: $caption');
                _sendVideo(video, content: caption);
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking video: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting video: $e')));
    }
  }

  // ══════════════════════════════════════════════════════════
  // SCHEDULED MESSAGING — COMPLETE IMPLEMENTATION
  // ══════════════════════════════════════════════════════════
  Future<void> _openSchedulePicker() async {
    final text = messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Type a message first before scheduling'),
          backgroundColor: HexColor("#FF6B00"),
        ),
      );
      return;
    }
    final now = DateTime.now();

    // ✅ WHITE calendar — matches Figma Image 1 exactly
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A7F4B),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A7F4B),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    // ✅ WHITE time picker — matches Figma
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5))),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A7F4B),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A7F4B),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null || !mounted) return;

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a future time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await _showScheduleConfirmSheet(text, scheduledAt);
    if (confirmed != true || !mounted) return;

    _scheduleMessage(text, scheduledAt);
    messageController.clear();
    setState(() => _isUserTyping = false);
    _stopTyping();
  }

  // ✅ Figma Image 2 — confirmation bottom sheet
  Future<bool?> _showScheduleConfirmSheet(String text, DateTime scheduledAt) {
    final dateStr = DateFormat('d MMM, yyyy').format(scheduledAt);
    final timeStr = DateFormat('hh:mma').format(scheduledAt).toLowerCase();
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // [X]  ................  Schedule
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Schedule',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF6B00),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF555555),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Summary',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.username,
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          timeStr,
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '2',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX DOUBLE-SEND: Sends directly via API, no messageController, no socket loop
  Future<void> _sendScheduledMessageNow(String text) async {
    try {
      debugPrint('📅 Sending scheduled message: $text');
      final serverMessageId = await sendMessageToApi(
        chatId: widget.chatId,
        content: text,
      );

      if (!mounted) return;

      // Socket emit removed — backend already broadcasts after API call

      final sentMsg = ChatMessage(
        id: serverMessageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: widget.chatId,
        text: text,
        isMe: true,
        isRead: false,
        status: MessageStatus.sent,
        timestamp: DateTime.now().toIso8601String(),
      );

      await _addMessage(sentMsg);
      _scrollToBottom();
      debugPrint('✅ Scheduled message sent');
    } catch (e) {
      debugPrint('❌ Failed to send scheduled message: $e');
    }
  }

  // ✅ FIX CARD DISAPPEARS: Card saved to Hive immediately on schedule
  void _scheduleMessage(String text, DateTime scheduledAt) {
    final tempId = 'scheduled${DateTime.now().millisecondsSinceEpoch}';
    final delay = scheduledAt.difference(DateTime.now());
    final scheduledCard = ChatMessage(
      id: tempId,
      chatId: widget.chatId,
      text: '__SCHEDULED__:${scheduledAt.toIso8601String()}:$text',
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(
      () => messages = _dedupeLocalMessages([...messages, scheduledCard]),
    );
    // ✅ Save to Hive immediately so card survives leaving the screen
    _saveMessagesToHive();
    _scrollToBottom();

    // ✅ Save to SharedPreferences so card survives full app close
    _saveScheduleToPrefs(tempId, text, scheduledAt);

    final entry = _ScheduledMessage(
      tempId: tempId,
      text: text,
      scheduledAt: scheduledAt,
    );

    entry.timer = Timer(delay, () async {
      if (!mounted) return;
      // Remove card from UI and Hive
      setState(() => messages.removeWhere((m) => m.id == tempId));
      _saveMessagesToHive();
      // Clean up
      _removeScheduleFromPrefs(tempId);
      _scheduledMessages.removeWhere((s) => s.tempId == tempId);
      // Send once directly
      await _sendScheduledMessageNow(text);
    });

    setState(() => _scheduledMessages.add(entry));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Message scheduled for ${DateFormat('hh:mma, d MMM').format(scheduledAt)}',
        ),
        backgroundColor: const Color(0xFF1A7F4B),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancelScheduledMessage(String tempId) {
    final idx = _scheduledMessages.indexWhere((s) => s.tempId == tempId);
    if (idx != -1) {
      _scheduledMessages[idx].timer?.cancel();
      _scheduledMessages.removeAt(idx);
    }
    setState(() => messages.removeWhere((m) => m.id == tempId));
    _saveMessagesToHive();
    _removeScheduleFromPrefs(tempId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scheduled message cancelled'),
        backgroundColor: Color(0xFFFF6B00),
      ),
    );
  }

  // ── SharedPreferences persistence ────────────────────────────
  String _schedulePrefsKey(String chatId) => 'scheduled_msgs$chatId';
  Future<void> _saveScheduleToPrefs(
    String tempId,
    String text,
    DateTime scheduledAt,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _schedulePrefsKey(widget.chatId);
      final raw = prefs.getStringList(key) ?? [];
      raw.removeWhere((e) {
        try {
          return jsonDecode(e)['tempId'] == tempId;
        } catch (e) {
          return false;
        }
      });
      raw.add(
        jsonEncode({
          'tempId': tempId,
          'text': text,
          'scheduledAt': scheduledAt.toIso8601String(),
        }),
      );
      await prefs.setStringList(key, raw);
    } catch (e) {
      debugPrint('❌ Failed to save schedule: $e');
    }
  }

  Future<void> _removeScheduleFromPrefs(String tempId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _schedulePrefsKey(widget.chatId);
      final raw = prefs.getStringList(key) ?? [];
      raw.removeWhere((entry) {
        try {
          return jsonDecode(entry)['tempId'] == tempId;
        } catch (e) {
          return false;
        }
      });
      await prefs.setStringList(key, raw);
    } catch (e) {
      debugPrint('❌ Failed to remove schedule: $e');
    }
  }

  Future<void> _loadPersistedSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _schedulePrefsKey(widget.chatId);
      final raw = prefs.getStringList(key) ?? [];
      if (raw.isEmpty) return;
      debugPrint('🔄 Reloading ${raw.length} persisted schedule(s)');

      final now = DateTime.now();
      final List<String> expiredIds = [];

      for (final entry in raw) {
        try {
          final map = jsonDecode(entry) as Map<String, dynamic>;
          final tempId = map['tempId'] as String;
          final text = map['text'] as String;
          final scheduledAt = DateTime.parse(map['scheduledAt'] as String);

          // Skip if timer already registered
          if (_scheduledMessages.any((s) => s.tempId == tempId)) continue;

          if (scheduledAt.isBefore(now)) {
            // Overdue — send after screen loads
            expiredIds.add(tempId);
            Future.delayed(const Duration(seconds: 2), () async {
              if (!mounted) return;
              setState(() => messages.removeWhere((m) => m.id == tempId));
              _saveMessagesToHive();
              await _sendScheduledMessageNow(text);
            });
            continue;
          }

          // Card already in Hive — just re-register the timer
          final delay = scheduledAt.difference(now);
          final scheduleEntry = _ScheduledMessage(
            tempId: tempId,
            text: text,
            scheduledAt: scheduledAt,
          );

          scheduleEntry.timer = Timer(delay, () async {
            if (!mounted) return;
            setState(() => messages.removeWhere((m) => m.id == tempId));
            _saveMessagesToHive();
            _removeScheduleFromPrefs(tempId);
            _scheduledMessages.removeWhere((s) => s.tempId == tempId);
            await _sendScheduledMessageNow(text);
          });

          setState(() => _scheduledMessages.add(scheduleEntry));
          debugPrint(
            '⏰ Timer re-registered: $tempId fires in ${delay.inSeconds}s',
          );
        } catch (e) {
          debugPrint('❌ Error restoring schedule: $e');
        }
      }

      for (final id in expiredIds) {
        await _removeScheduleFromPrefs(id);
      }
    } catch (e) {
      debugPrint('❌ Failed to load persisted schedules: $e');
    }
  }

  // ── Card UI — matches Figma Images 3 and 4 exactly ──────────
  Widget _buildScheduledCard(String tempId, String text, DateTime scheduledAt) {
    final dateStr = DateFormat('d MMM, yyyy').format(scheduledAt);
    final timeStr = DateFormat('hh:mma').format(scheduledAt).toLowerCase();
    return Dismissible(
      key: Key(tempId),
      direction: DismissDirection.startToEnd,
      // ✅ Figma Image 4: red panel left side, white trash icon
      background: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFFCC2222),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
      ),
      onDismissed: (_) => _cancelScheduledMessage(tempId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Orange "Post Scheduled" CENTERED + calendar icon right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Post Scheduled',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF6B00),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF3D3D3D)),
            // ── [Summary] pill + message text
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Summary',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Person | Time | Date | Count
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    widget.username,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.access_time,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    timeStr,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '2',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
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

  void _shareContact() {
    // Legacy stub — replaced by _openContactPickerForSharing
    _openContactPickerForSharing();
  }

  void _openContactPickerForSharing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContactPickerSheet(
        onContactSelected: (name, phone, profilePicture) async {
          Navigator.pop(ctx);
          final contactText =
              '__CONTACT_SHARE__:$name:$phone:${profilePicture ?? ''}';
          final tempId = DateTime.now().millisecondsSinceEpoch.toString();
          final tempMsg = ChatMessage(
            id: tempId,
            chatId: widget.chatId,
            text: contactText,
            isMe: true,
            isRead: false,
            status: MessageStatus.sending,
            timestamp: DateTime.now().toIso8601String(),
          );
          await _addMessage(tempMsg);
          _scrollToBottom();
          final serverId = await sendMessageToApi(
            chatId: widget.chatId,
            content: contactText,
          );
          if (serverId != null) {
            await _updateMessage(
              tempMsg.copyWith(id: serverId, status: MessageStatus.sent),
            );
            // ✅ Show contact name in preview instead of raw string
            await _updateChatListPreview(text: '👤 $name', messageId: serverId);
          } else {
            await _markFailed(tempId);
          }
        },
      ),
    );
  }

  int _getMediaCount() {
    int count = 0;
    for (var message in messages) {
      if (message.isImage ||
          message.isVideo ||
          message.isDocument ||
          message.isAudioFile) {
        count++;
      }
    }
    return count;
  }
}

class _ScheduledMessage {
  final String tempId;
  final String text;
  final DateTime scheduledAt;
  Timer? timer;
  _ScheduledMessage({
    required this.tempId,
    required this.text,
    required this.scheduledAt,
    this.timer,
  });
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Icon(Icons.call, color: Colors.white, size: 14),
    );
  }
}
