import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:qik_talk/features/calls/call_permission_handler.dart';
import 'package:qik_talk/features/calls/group_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/chat/general/previews/audio_preview_screen.dart';
import 'package:qik_talk/features/chat/single_chat/components/contact_picker_sheet.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/features/settings/theme/models/wallpaper_item.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/forward_message_screen.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_mapper.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/screens/chat_media_tab_screen.dart';
import 'package:qik_talk/features/chat/general/services/chat_cache_sync_service.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_invite_service.dart';
import 'package:qik_talk/features/chat/general/services/pinned_messages/pinned_message_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_members_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_menu_features.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/composite_group_avatar.dart';
import 'package:qik_talk/features/status/components/emoji_gif_picker.dart';
import 'package:qik_talk/utilities/services/image_compression_service.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/media_placeholder_widgets.dart';
import 'package:qik_talk/utilities/services/message_sound_service.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import 'package:qik_talk/utilities/services/upload_queue_service.dart';
import 'package:qik_talk/utilities/widgets/pinned_messages_widget.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qik_talk/features/chat/general/components/chat_bubbles/audio_file_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/chat_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/document_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/image_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/multiple_image_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/video_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/voice_note_bubble.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/general/previews/document_preview_screen.dart';
import 'package:qik_talk/features/chat/general/previews/image_preview_screen.dart';
import 'package:qik_talk/features/chat/general/previews/video_preview_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_info_screen.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/notifications/services/permission_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/date_separator_widget.dart';
import 'package:qik_talk/utilities/helpers/video_validator.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/audio_recorder_service.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/services/video_trimming_service.dart';
import 'package:qik_talk/utilities/services/video_compression_service.dart';
import 'package:qik_talk/features/chat/single_chat/components/recorder_ui.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String communityName;
  final int memberCount;
  final String groupImage;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.communityName,
    required this.memberCount,
    required this.groupImage,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen>
    with WidgetsBindingObserver {
  // ── Core ──
  IO.Socket? _socket;
  late Box<List> _chatBox;
  final SaveValues _saveValues = SaveValues();
  final PermissionService _permissionService = PermissionService();

  // ── State ──
  List<ChatMessage> _messages = [];
  Map<String, String> _typingUsers = {};
  String _myUserId = '';
  bool _isLoading = false;
  bool _showScrollToBottom = false;
  bool _showEmojiPicker = false;
  bool _showGifPicker = false;
  double _keyboardHeight = 300;
  final GlobalKey<PinnedMessageBannerState> _pinnedBannerKey =
      GlobalKey<PinnedMessageBannerState>();
  bool _isUserTyping = false;
  Set<String> _savedMessageIds = {};

  // ✅ Upload progress tracking (mirrors message_screen pattern)
  double _uploadProgress = 0;
  String? _uploadingTempId; // which message is currently uploading

  // ✅ FIX: Mutable name fields so the appbar updates after rename
  late String _currentGroupName;
  late String _currentCommunityName;
  List<GroupMember> _groupMembers = [];

  // ✅ Wallpaper + bubble color — loaded once, refreshed on back from info screen
  String? _wallpaperPath;
  Color? _customBubbleColor; // sender bubble color (per-chat or global theme)
  Color? _receiverBubbleColor; // receiver bubble color (global theme only)
  Color? _senderGlowColor; // vivid glow for sender bubble
  Color? _receiverGlowColor; // vivid glow for receiver bubble

  // ── Edit ──
  bool _isEditing = false;
  String? _editingMessageId;

  // ── Mentions ──
  bool _showMentionList = false;
  String _mentionQuery = '';
  List<GroupMember> _filteredMembers = [];

  // ── Search ──
  bool _showSearchBar = false;
  String _searchQuery = '';
  final TextEditingController _searchBarController = TextEditingController();

  // ── Reply ──
  bool _isReplying = false;
  String? _replyToId;
  String? _replyToText;
  bool? _replyToIsMe;
  String? _replyToSenderName;
  String? _replyToMediaType;
  String? _replyToThumbnailUrl;

  // ── Recording ──
  late final AudioRecorderService _audioRecorder;
  bool _isRecording = false;
  bool _isPreviewing = false;
  String? _recordingPath;
  int _recordingDuration = 0;
  Timer? _recordTimer;
  bool get _showRecorder => _isRecording || _isPreviewing;

  // ── Controllers ──
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  Timer? _typingTimer;
  IO.Socket? _listeningSocket;
  bool _socketListenersAttached = false;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ✅ Initialise mutable name copies
    _currentGroupName = widget.groupName;
    _currentCommunityName = widget.communityName;

    _chatBox = Hive.box<List>('chat_messages');
    _audioRecorder = AudioRecorderService();
    NotificationService().clearChatNotifications(widget.groupId);

    // Listen for Hive updates written by group_component socket handlers
    _chatBox
        .listenable(keys: [widget.groupId])
        .addListener(_onGroupHiveCacheUpdated);

    _loadMessagesFromHive(); // Show cached messages instantly
    // Only show the loading spinner if Hive has no data for this chat
    final cached = _chatBox.get(widget.groupId);
    if (cached == null || (cached as List).isEmpty) {
      // No local data — show spinner while fetching
    } else {
      // We have local data — don't show spinner, load history silently
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isLoading = false);
      });
    }
    _initGroupChat();
    _loadWallpaperAndColor(); // ✅ load wallpaper + color on open

    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
    // Open at the latest message without an animated jump/flicker.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _jumpToBottom();
    });
  }

  /// Fire-and-forget: marks remaining unread messages as read when the user
  /// closes the group chat screen, ensuring the badge clears correctly even if
  /// the inline _markGroupAsRead() was missed (e.g. fast navigation).
  void _markGroupReadOnDispose() {
    final unreadIds = _messages
        .where((m) => !m.isMe && !m.isRead)
        .map((m) => m.id)
        .toList();
    if (unreadIds.isEmpty) return;

    // Emit socket event while socket is still connected.
    try {
      if (_socket?.connected == true) {
        // Backend: "chat opened" marks all as read and emits "messages read"
        _socket!.emit('chat opened', {'chatId': widget.groupId});
      }
    } catch (_) {}

    // Fire-and-forget HTTP call.
    _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN).then((token) {
      http
          .put(
            Uri.parse('${AppConfig.apiUrl}message/read'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'chatId': widget.groupId,
              'messageIds': unreadIds,
            }),
          )
          .catchError(
            (e) => debugPrint('Mark group read on dispose failed: $e'),
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatBox
        .listenable(keys: [widget.groupId])
        .removeListener(_onGroupHiveCacheUpdated);
    _typingTimer?.cancel();
    _recordTimer?.cancel();
    _scrollController.removeListener(_onScroll);

    // Mark unread messages as read on exit (fire-and-forget safety net).
    _markGroupReadOnDispose();

    if (_socket?.connected == true) {
      _socket!.emit('leave chat', widget.groupId);
    }

    // ✅ Remove per-screen listeners to prevent stacking on re-open.
    if (_socket != null) {
      for (final event in [
        'message received',
        'typing',
        'stop typing',
        'message deleted',
        'message edited',
        'messages delivered',
        'messages read',
        'group updated',
      ]) {
        _socket!.off(event);
      }
      debugPrint('🧹 GroupChatScreen: socket listeners removed');
    }

    // ✅ Remove per-screen listeners to prevent stacking on re-open.
    if (_socket != null) {
      for (final event in [
        'message received',
        'typing',
        'stop typing',
        'message deleted',
        'message edited',
        'messages delivered',
        'messages read',
        'group updated',
      ]) {
        _socket!.off(event);
      }
      debugPrint('🧹 GroupChatScreen: socket listeners removed');
    }

    _socketListenersAttached = false;
    _listeningSocket = null;

    _audioRecorder.dispose();
    _messageController.dispose();
    _searchBarController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Reload wallpaper whenever the app resumes — picks up any global
  /// wallpaper applied from Chat Themes while this screen was in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadWallpaperAndColor();
    }
  }

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  void _onGroupHiveCacheUpdated() {
    if (!mounted) return;
    _loadMessagesFromHive();
  }

  Future<void> _initGroupChat() async {
    _myUserId = await _saveValues.getString(AppPreferenceHelper.ID) ?? '';
    // ✅ Load starred messages and connect socket in parallel — faster open
    await Future.wait([_loadStarredMessages(), _connectSocket()]);
    // Zero badge immediately on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markGroupAsRead();
    });
    final results = await Future.wait([
      _loadGroupHistory(),
      GroupApiService().getGroupProfile(groupId: widget.groupId),
    ]);
    final group = results[1] as GroupModel?;
    if (group != null && mounted) {
      setState(() => _groupMembers = group.users);
    }
  }

  Future<void> _loadWallpaperAndColor() async {
    final svc = ChatSettingsPersistenceService();
    final results = await Future.wait([
      _saveValues.getString(AppPreferenceHelper.chatWallpaper(widget.groupId)),
      svc.getCustomColor(widget.groupId),
    ]);
    if (!mounted) return;
    // Per-chat wallpaper takes priority; fall back to global wallpaper
    String? perChat = results[0] as String?;
    if (perChat == null || perChat.isEmpty) {
      perChat = await _saveValues.getString(
        AppPreferenceHelper.GLOBAL_WALLPAPER,
      );
    }

    // ── Resolve bubble colors: per-chat custom → global theme ──────────────
    final perChatColorVal = results[1] as int?;
    Color? senderColor;
    Color? receiverColor;
    Color? senderGlowColor;
    Color? receiverGlowColor;

    if (perChatColorVal != null) {
      senderColor = Color(perChatColorVal);
    } else {
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

  Future<void> _loadStarredMessages() async {
    final ids = await _saveValues.getStringList(
      AppPreferenceHelper.STARRED_MESSAGES,
    );
    if (mounted) setState(() => _savedMessageIds = Set.from(ids));
  }

  void _loadMessagesFromHive() {
    final cached = _chatBox.get(widget.groupId);
    if (cached == null) return;
    try {
      final deduped = _dedupeMessages(
        (cached as List<dynamic>)
            .map((e) => (e as ChatMessageHive).toChat())
            .toList(),
      );
      setState(() {
        _messages = deduped;
      });
      _preloadChatMedia(deduped);
      _jumpToBottom();
    } catch (e) {
      debugPrint('❌ Hive load error: $e');
    }
  }

  bool _isNearBottom([double threshold = 160]) {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= threshold;
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

  ChatMessage _mergeMessage(ChatMessage existing, ChatMessage incoming) {
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

  bool _looksLikeSamePendingMedia(ChatMessage pending, ChatMessage incoming) {
    if (!pending.isMe || pending.status != MessageStatus.sending) return false;
    if (pending.text.trim() != incoming.text.trim()) return false;
    final timeDiff =
        DateTime.tryParse(pending.timestamp)
            ?.difference(
              DateTime.tryParse(incoming.timestamp) ?? DateTime.now(),
            )
            .abs() ??
        const Duration(days: 1);
    if (timeDiff > const Duration(minutes: 5)) return false;
    return (pending.isVoiceNote && incoming.isVoiceNote) ||
        (pending.isAudioFile && incoming.isAudioFile) ||
        (pending.isDocument && incoming.isDocument) ||
        (pending.isVideo && incoming.isVideo) ||
        (pending.isImage && incoming.isImage) ||
        (!pending.isImage &&
            !pending.isVideo &&
            !pending.isDocument &&
            !pending.isVoiceNote &&
            !pending.isAudioFile &&
            pending.text == incoming.text);
  }

  List<ChatMessage> _dedupeMessages(List<ChatMessage> source) {
    final result = <ChatMessage>[];
    for (final msg in source) {
      final byId = result.indexWhere((m) => m.id == msg.id);
      if (byId != -1) {
        result[byId] = _mergeMessage(result[byId], msg);
        continue;
      }
      final pendingIndex = result.indexWhere(
        (m) => _looksLikeSamePendingMedia(m, msg),
      );
      if (pendingIndex != -1) {
        result[pendingIndex] = _mergeMessage(result[pendingIndex], msg);
        continue;
      }
      result.add(msg);
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

  void _preloadChatMedia(List<ChatMessage> msgs) {
    final cache = MediaCacheService();

    for (final msg in msgs) {
      if (msg.isImage && msg.imageUrls != null) {
        for (final url in msg.imageUrls!) {
          if (url.startsWith('http')) {
            cache
                .cacheMedia(url: url, mediaType: 'image')
                .catchError((_) => null);
          }
        }
      }

      if (EmojiGifPicker.isGifUrl(msg.text)) {
        final gifUrl = msg.text.trim();
        if (gifUrl.startsWith('http')) {
          cache
              .cacheMedia(url: gifUrl, mediaType: 'image')
              .catchError((_) => null);
        }
      }

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

      if ((msg.isVoiceNote || msg.isAudioFile) && msg.audioUrl != null) {
        final audioUrl = msg.audioUrl!;
        if (audioUrl.startsWith('http')) {
          cache
              .cacheMedia(url: audioUrl, mediaType: 'audio')
              .catchError((_) => null);
        }
      }

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

  Future<void> _replaceTempMessage(
    String tempId,
    ChatMessage serverMessage,
  ) async {
    final idx = _messages.indexWhere(
      (m) => m.id == tempId || m.id == serverMessage.id,
    );
    if (idx != -1) {
      setState(() {
        _messages[idx] = _mergeMessage(
          _messages[idx],
          serverMessage.copyWith(status: MessageStatus.sent),
        );
        _messages = _dedupeMessages(_messages);
      });
    } else {
      setState(
        () => _messages = _dedupeMessages([..._messages, serverMessage]),
      );
    }
    await _saveToHive();
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // ─────────────────────────────────────────────
  // SOCKET
  // ─────────────────────────────────────────────

  Future<void> _connectSocket() async {
    final gs = GlobalSocketService();
    if (gs.socket == null || !gs.isConnected) {
      await gs.connect();
      int attempts = 0;
      while (!gs.isConnected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
    }
    _socket = gs.socket;
    if (_socket == null) return;

    if (_socket!.connected) {
      _socket!.emit('join chat', widget.groupId);
      _setupSocketListeners();
    } else {
      _socket!.onConnect((_) {
        _socket?.emit('join chat', widget.groupId);
        _setupSocketListeners();
      });
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;
    if (_socketListenersAttached && _listeningSocket == _socket) return;

    // ✅ Remove stale listeners before re-adding to prevent stacking.
    for (final event in [
      'message received',
      'typing',
      'stop typing',
      'message deleted',
      'message edited',
      'messages delivered',
      'messages read',
      'group updated',
    ]) {
      _socket!.off(event);
    }

    _socketListenersAttached = true;
    _listeningSocket = _socket;

    _socket!.on('message received', (data) async {
      if (!mounted) return;
      if (data['_id'] == null || data['content'] == null) return;

      ChatMessage incoming;
      try {
        incoming = ChatMessage.fromJson(data, _myUserId);
      } catch (e) {
        debugPrint('❌ Parse error: $e');
        return;
      }

      final serverChatId =
          (data['chat']?['_id'] ?? data['chatId'] ?? incoming.chatId)
              .toString();
      if (serverChatId != widget.groupId) return;

      final tempId = data['tempId']?.toString();
      int existingIndex = _messages.indexWhere((m) => m.id == incoming.id);
      if (existingIndex == -1 && tempId != null) {
        existingIndex = _messages.indexWhere((m) => m.id == tempId);
      }

      setState(() {
        if (existingIndex != -1) {
          _messages[existingIndex] = _mergeMessage(
            _messages[existingIndex],
            incoming,
          );
        } else {
          if (incoming.isMe) {
            final dup = _messages.any((m) => m.id == incoming.id);
            if (dup) return;
            final tempIdx = _messages.indexWhere(
              (m) => _looksLikeSamePendingMedia(m, incoming),
            );
            if (tempIdx != -1) {
              _messages[tempIdx] = _mergeMessage(
                _messages[tempIdx],
                incoming.copyWith(status: MessageStatus.sent),
              );
              return;
            }
          }
          if (!_messages.any((m) => m.id == incoming.id)) {
            if (!incoming.isMe) MessageSoundService().playReceiveSound();
            _messages.add(incoming);
          }
        }
      });

      setState(() => _messages = _dedupeMessages(_messages));
      _preloadChatMedia([incoming]);
      if (_isNearBottom()) _scrollToBottom();
      await _saveToHive();

      if (!incoming.isMe) {
        _markGroupAsRead();
      }
    });

    _socket!.on('typing', (data) {
      if (!mounted) return;
      final uid = data['userId']?.toString();
      final cid = data['chatId']?.toString();
      final name = data['username']?.toString() ?? data['name']?.toString();
      if (uid == null || cid != widget.groupId || uid == _myUserId) return;
      if (mounted) setState(() => _typingUsers[uid] = name ?? uid);
    });

    _socket!.on('stop typing', (data) {
      if (!mounted) return;
      final uid = data['userId']?.toString();
      final cid = data['chatId']?.toString();
      if (uid == null || cid != widget.groupId) return;
      if (mounted) setState(() => _typingUsers.remove(uid));
    });

    _socket!.on('message deleted', (data) async {
      if (!mounted) return;
      if (data['chatId'] != widget.groupId) return;
      setState(() => _messages.removeWhere((m) => m.id == data['messageId']));
      await _saveToHive();
    });

    _socket!.on('message edited', (data) {
      if (!mounted) return;
      if (data['chatId'] != widget.groupId) return;
      setState(() {
        _messages = _messages.map((m) {
          if (m.id == data['messageId']) {
            return m.copyWith(
              text: data['newContent'] ?? m.text,
              isEdited: true,
            );
          }
          return m;
        }).toList();
      });
    });

    // Backend emits "messages delivered" (plural) with messageIds array.
    _socket!.on('messages delivered', (data) {
      final chatId = data['chatId']?.toString();
      final messageIds = (data['messageIds'] as List?)
          ?.map((e) => e.toString())
          .toList();
      if (chatId != widget.groupId || !mounted) return;
      var changed = false;
      setState(() {
        for (var msg in _messages) {
          final matches = messageIds == null || messageIds.contains(msg.id);
          if (msg.isMe &&
              matches &&
              msg.status != MessageStatus.read &&
              msg.status != MessageStatus.delivered) {
            msg.status = MessageStatus.delivered;
            changed = true;
          }
        }
      });
      if (changed) {
        _saveToHive();
        // ✅ SYNC FIX: _updateCachedLastMessageStatus already writes to chats box
        _updateCachedLastMessageStatus('delivered', messageIds: messageIds);
        debugPrint('✅ [GROUP SYNC] Chat list tick → delivered');
      }
    });

    _socket!.on('messages read', (data) {
      final chatId = data['chatId']?.toString();
      final messageIds = (data['messageIds'] as List?)
          ?.map((e) => e.toString())
          .toList();
      if (chatId != widget.groupId || !mounted) return;

      final matchesAllMessages = messageIds == null || messageIds.isEmpty;
      var changed = false;

      setState(() {
        for (var msg in _messages) {
          if (!msg.isMe) continue;
          final shouldMark =
              matchesAllMessages || messageIds.contains(msg.id);
          if (shouldMark && msg.status != MessageStatus.read) {
            msg.isRead = true;
            msg.status = MessageStatus.read;
            changed = true;
          }
        }
      });

      if (changed) {
        _saveToHive();
        _updateCachedLastMessageStatus('read', messageIds: messageIds);
      }
    });

    // ✅ Listen for group rename via socket so appbar updates in real time
    _socket!.on('group updated', (data) {
      if (data['groupId'] != widget.groupId) return;
      if (data['action'] == 'rename' && data['newName'] != null && mounted) {
        setState(() {
          _currentGroupName = data['newName'] as String;
          _currentCommunityName = data['newName'] as String;
        });
      }
    });
  }

  // ─────────────────────────────────────────────
  // HISTORY
  // ─────────────────────────────────────────────

  Future<void> _loadGroupHistory() async {
    // Step 1: Show Hive data immediately — user sees messages instantly even offline
    _loadMessagesFromHive();

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http
          .get(
            Uri.parse(ApiStrings.getChatHistory + widget.groupId),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final parsed = ChatHistoryResponse.fromJson(
          jsonDecode(response.body),
          _myUserId,
        );

        // Load deleted IDs so we don't re-show deleted messages
        final deletedIds =
            await _saveValues.getStringList(
              'deleted_messages_${widget.groupId}',
            ) ??
            [];

        // Build map of existing Hive messages to preserve local media URLs
        final Map<String, ChatMessage> hiveMap = {
          for (final m in _messages) m.id: m,
        };

        final merged = parsed.messages
            .map((apiMsg) {
              final hive = hiveMap[apiMsg.id];
              if (hive == null) return apiMsg;

              return _mergeMessage(hive, apiMsg);
            })
            .where((m) => !deletedIds.contains(m.id))
            .toList();

        final shouldStickToBottom = _isNearBottom() || _messages.isEmpty;
        final deduped = _dedupeMessages(merged);
        setState(() {
          _messages = deduped;
          _isLoading = false;
        });
        _preloadChatMedia(deduped);
        await _saveToHive();
        if (shouldStickToBottom) _scrollToBottom();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _markGroupAsRead();
        });
      } else {
        // API failed — Hive data is already showing, just hide the spinner
        if (mounted) setState(() => _isLoading = false);
      }
    } on Exception catch (e) {
      // Offline or timeout — Hive data stays on screen, no empty state shown
      debugPrint('⚠️ Group history offline/failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ─────────────────────────────────────────────
  // SEND TEXT
  // ─────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    MessageSoundService().playSendSound();

    _typingTimer?.cancel();
    _socket?.emit('stop typing', {
      'room': widget.groupId,
      'chatId': widget.groupId,
    });

    final capturedReplyId = _replyToId;
    final capturedReplyText = _replyToText;
    final capturedReplyIsMe = _replyToIsMe;
    final capturedReplySenderName = _replyToSenderName;
    final capturedReplyMediaType = _replyToMediaType;
    final capturedReplyThumbnailUrl = _replyToThumbnailUrl;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final temp = ChatMessage(
      id: tempId,
      chatId: widget.groupId,
      text: text,
      isMe: true,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      replyToMessageId: capturedReplyId,
      replyToText: capturedReplyText,
      replyToIsMe: capturedReplyIsMe,
      replyToSenderName: capturedReplySenderName,
      replyToMediaType: capturedReplyMediaType,
      replyToThumbnailUrl: capturedReplyThumbnailUrl,
    );

    setState(() {
      _messages.add(temp);
      _isUserTyping = false;
      _isReplying = false;
      _replyToId = null;
      _replyToText = null;
      _replyToIsMe = null;
      _replyToSenderName = null;
      _replyToMediaType = null;
      _replyToThumbnailUrl = null;
    });
    _messageController.clear();
    _scrollToBottom();
    await _saveToHive();

    if (_socket?.connected == true) {
      _socket!.emit('new message', {
        'chat': {'_id': widget.groupId},
        'sender': {'_id': _myUserId},
        'text': text,
        'tempId': tempId,
        if (capturedReplyId != null) 'replyTo': capturedReplyId,
      });
    }

    // Extract mentioned user IDs from text
    final mentionRegex = RegExp(r'@(\S+)');
    final mentionedIds = mentionRegex
        .allMatches(text)
        .map((m) => m.group(1)?.toLowerCase() ?? '')
        .expand(
          (username) => _groupMembers
              .where((member) => member.username.toLowerCase() == username)
              .map((member) => member.id),
        )
        .toSet()
        .toList();

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.post(
        Uri.parse('${ApiStrings.baseUri}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': widget.groupId,
          'content': text,
          if (capturedReplyId != null) 'replyTo': capturedReplyId,
          if (mentionedIds.isNotEmpty) 'mentions': mentionedIds,
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final serverId = jsonDecode(res.body)['_id'];
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          setState(() {
            _messages[idx] = _messages[idx].copyWith(
              id: serverId,
              status: MessageStatus.sent,
            );
          });
          await _saveToHive();
          // ✅ Update group list tile immediately
          await _updateChatListPreview(text: text, messageId: serverId);
        }
      } else {
        _markFailed(tempId);
      }
    } catch (e) {
      _markFailed(tempId);
    }
  }

  void _markFailed(String id) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    setState(
      () => _messages[idx] = _messages[idx].copyWith(
        status: MessageStatus.failed,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TYPING
  // ─────────────────────────────────────────────

  void _onTextChanged() {
    final typing = _messageController.text.trim().isNotEmpty;
    if (typing != _isUserTyping) setState(() => _isUserTyping = typing);
    // If user types with hardware keyboard while picker is open, close picker
    if (_showEmojiPicker || _showGifPicker) {
      final kh = MediaQuery.of(context).viewInsets.bottom;
      if (kh > 100)
        setState(() {
          _showEmojiPicker = false;
          _showGifPicker = false;
        });
    }

    // ── Mention detection ──
    final text = _messageController.text;
    final cursor = _messageController.selection.baseOffset;
    final beforeCursor = cursor > 0 ? text.substring(0, cursor) : '';
    final atIndex = beforeCursor.lastIndexOf('@');
    if (atIndex != -1) {
      final query = beforeCursor.substring(atIndex + 1);
      // Only show if no space in query (i.e. still typing the mention)
      if (!query.contains(' ')) {
        final filtered = _groupMembers.where((m) {
          return m.id != _myUserId &&
              m.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
        setState(() {
          _showMentionList = true;
          _mentionQuery = query;
          _filteredMembers = filtered;
        });
        return;
      }
    }
    setState(() => _showMentionList = false);

    if (typing) {
      if (_socket?.connected == true) {
        _socket!.emit('typing', {
          'room': widget.groupId,
          'chatId': widget.groupId,
          'userId': _myUserId,
        });
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _socket?.emit('stop typing', {
          'room': widget.groupId,
          'chatId': widget.groupId,
        });
      });
    } else {
      _typingTimer?.cancel();
      _socket?.emit('stop typing', {
        'room': widget.groupId,
        'chatId': widget.groupId,
      });
    }
  }

  void _insertMention(GroupMember member) {
    final text = _messageController.text;
    final cursor = _messageController.selection.baseOffset;
    final beforeCursor = cursor > 0 ? text.substring(0, cursor) : '';
    final atIndex = beforeCursor.lastIndexOf('@');
    if (atIndex == -1) return;
    final afterCursor = text.substring(cursor);
    final newText =
        '${text.substring(0, atIndex)}@${member.username} $afterCursor';
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: atIndex + member.username.length + 2, // +2 for @ and space
      ),
    );
    setState(() {
      _showMentionList = false;
      _mentionQuery = '';
      _filteredMembers = [];
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MEDIA SENDERS

  Future<void> _sendMultipleImages(List<File> images, String caption) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final temp = ChatMessage(
      id: tempId,
      chatId: widget.groupId,
      isImage: true,
      imageUrls: images.map((e) => e.path).toList(),
      text: caption,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
    );
    setState(() => _messages = _dedupeMessages([..._messages, temp]));
    _scrollToBottom();
    await _saveToHive();

    try {
      // ✅ Compress images before upload
      final compressedImages = await ImageCompressionService.compressAll(
        inputs: images,
        quality: 72,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      final List<String> publicUrls = [];
      for (final img in compressedImages) {
        final mimeType = lookupMimeType(img.path) ?? 'image/jpeg';

        final completer = Completer<String?>();
        UploadQueueService().enqueue(
          file: img,
          mimeType: mimeType,
          onProgress: (p) {
            if (mounted) {
              setState(() {
                _uploadProgress =
                    (publicUrls.length / compressedImages.length) +
                    (p / compressedImages.length);
                _uploadingTempId = tempId;
              });
            }
          },
          onSuccess: (url) => completer.complete(url),
          onError: (_) => completer.complete(null),
        );
        final publicUrl = await completer.future;
        if (publicUrl == null) {
          _markFailed(tempId);
          await _saveToHive();
          return;
        }
        publicUrls.add(publicUrl);
      }

      if (mounted)
        setState(() {
          _uploadProgress = 0;
          _uploadingTempId = null;
        });

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.post(
        Uri.parse('${ApiStrings.baseUri}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': widget.groupId,
          'content': caption.isNotEmpty ? caption : ' ',
          'contentType': 'image',
          'attachmentUrls': publicUrls,
          'tempId': tempId,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final id = jsonDecode(res.body)['_id'];
        await _replaceTempMessage(
          tempId,
          temp.copyWith(id: id, status: MessageStatus.sent),
        );
        await _updateChatListPreview(
          text: caption,
          isImage: true,
          messageId: id,
        );
      } else {
        _markFailed(tempId);
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _uploadProgress = 0;
          _uploadingTempId = null;
        });
      _markFailed(tempId);
    }
    await _saveToHive();
  }

  Future<void> _sendVideo(File file, {String content = ''}) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final temp = ChatMessage(
      id: tempId,
      chatId: widget.groupId,
      isVideo: true,
      videoUrl: file.path,
      text: content,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
    );
    setState(() => _messages = _dedupeMessages([..._messages, temp]));
    _scrollToBottom();
    await _saveToHive();

    try {
      final compressed = await VideoCompressionService.compressToMaxSize(
        input: file,
        maxSizeMb: 15,
      );
      final mimeType = lookupMimeType(compressed.path) ?? 'video/mp4';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: compressed,
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        _markFailed(tempId);
        await _saveToHive();
        return;
      }

      await MediaCacheService().registerCachedMedia(
        url: publicUrl,
        localPath: compressed.path,
        mediaType: 'video',
      );

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.post(
        Uri.parse('${ApiStrings.baseUri}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': widget.groupId,
          'content': content,
          'contentType': 'video',
          'attachmentUrls': [publicUrl],
          'tempId': tempId,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final id = jsonDecode(res.body)['_id'];
        await _replaceTempMessage(
          tempId,
          temp.copyWith(id: id, status: MessageStatus.sent),
        );
        await _updateChatListPreview(
          text: content,
          isVideo: true,
          messageId: id,
        );
      } else {
        _markFailed(tempId);
      }
    } catch (_) {
      _markFailed(tempId);
    }
    await _saveToHive();
  }

  Future<void> _sendDocument(File file, {String content = ''}) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final temp = ChatMessage(
      id: tempId,
      chatId: widget.groupId,
      isDocument: true,
      documentUrl: file.path,
      documentName: p.basename(file.path),
      text: content,
      isMe: true,
      isRead: false,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
    );
    setState(() => _messages = _dedupeMessages([..._messages, temp]));
    _scrollToBottom();
    await _saveToHive();

    try {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        _markFailed(tempId);
        await _saveToHive();
        return;
      }

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.post(
        Uri.parse('${ApiStrings.baseUri}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': widget.groupId,
          'content': content,
          'contentType': 'document',
          'attachmentUrls': [publicUrl],
          'tempId': tempId,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final id = jsonDecode(res.body)['_id'];
        await _replaceTempMessage(
          tempId,
          temp.copyWith(id: id, status: MessageStatus.sent),
        );
        await _updateChatListPreview(
          text: p.basename(file.path),
          isDocument: true,
          messageId: id,
        );
      } else {
        _markFailed(tempId);
      }
    } catch (_) {
      _markFailed(tempId);
    }
    await _saveToHive();
  }

  // ─────────────────────────────────────────────
  // RECORDING
  // ─────────────────────────────────────────────

  Future<void> _startRecording() async {
    final result = await _permissionService.requestMicrophone(context);
    if (result != PermissionResult.granted) return;
    setState(() {
      _isRecording = true;
      _isPreviewing = false;
      _recordingDuration = 0;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingDuration++);
    });
    await _audioRecorder.startRecording();
  }

  Future<void> _stopRecordingPreview() async {
    _recordTimer?.cancel();
    final path = await _audioRecorder.stopRecording();
    if (path == null || _recordingDuration == 0) {
      _resetRecording();
      return;
    }
    setState(() {
      _recordingPath = path;
      _isRecording = false;
      _isPreviewing = true;
    });
  }

  Future<void> _sendRecording() async {
    if (_recordingPath == null && _isRecording) await _stopRecordingPreview();
    if (_recordingPath == null) return;

    final path = _recordingPath!;
    setState(() {
      _isRecording = false;
      _isPreviewing = false;
    });

    final player = AudioPlayer();
    await player.setFilePath(path);
    final duration = player.duration?.inSeconds ?? 0;
    await player.dispose();
    if (duration == 0) {
      _resetRecording();
      return;
    }

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final temp = ChatMessage(
      id: tempId,
      chatId: widget.groupId,
      isVoiceNote: true,
      audioUrl: path,
      isMe: true,
      status: MessageStatus.sending,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      text: '',
    );
    setState(() => _messages = _dedupeMessages([..._messages, temp]));
    _scrollToBottom();
    await _saveToHive();

    try {
      final mimeType = lookupMimeType(path) ?? 'audio/aac';
      final publicUrl = await PresignedUploadService.uploadFile(
        file: File(path),
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        _markFailed(tempId);
        _resetRecording();
        await _saveToHive();
        return;
      }

      await MediaCacheService().registerCachedMedia(
        url: publicUrl,
        localPath: path,
        mediaType: 'audio',
      );

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.post(
        Uri.parse('${ApiStrings.baseUri}message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': widget.groupId,
          'content': ' ',
          'contentType': 'audio',
          'isVoiceNote': true,
          'attachmentUrls': [publicUrl],
          'tempId': tempId,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final id = jsonDecode(res.body)['_id'];
        await _replaceTempMessage(
          tempId,
          temp.copyWith(id: id, status: MessageStatus.sent),
        );
        await _updateChatListPreview(
          text: ' ',
          isVoiceNote: true,
          messageId: id,
        );
      } else {
        _markFailed(tempId);
      }
    } catch (_) {
      _markFailed(tempId);
    }
    _resetRecording();
    await _saveToHive();
  }

  void _deleteRecording() async {
    _recordTimer?.cancel();
    await _audioRecorder.stopRecording();
    _resetRecording();
  }

  void _resetRecording() {
    setState(() {
      _isRecording = false;
      _isPreviewing = false;
      _recordingPath = null;
      _recordingDuration = 0;
    });
  }

  // ─────────────────────────────────────────────
  // PICKERS
  // ─────────────────────────────────────────────

  Future<void> _pickImages() async {
    final result = await _permissionService.requestStorage(context);
    if (result != PermissionResult.granted) return;
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final images = await _picker.pickMultiImage(imageQuality: 70);
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (images.isEmpty) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedImagePreviewScreen(
          images: images.map((e) => File(e.path)).toList(),
          onSend: (imgs, caption) => _sendMultipleImages(imgs, caption),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final result = await _permissionService.requestStorage(context);
    if (result != PermissionResult.granted) return;
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final picked = await FilePicker.platform.pickFiles(type: FileType.video);
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (picked == null || picked.files.single.path == null) return;
    final file = File(picked.files.single.path!);
    if (!mounted) return;
    VideoTrimmingService.showValidatingDialog(context);
    final validation = await VideoTrimmingService.validateVideo(file);
    if (mounted) Navigator.pop(context);
    if (!validation.isValid) {
      if (mounted)
        await VideoTrimmingService.showVideoTooLongDialog(
          context,
          validation.duration,
        );
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedVideoPreviewScreen(
          videoFile: file,
          onSend: (v, caption) => _sendVideo(v, content: caption),
        ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    final result = await _permissionService.requestStorage(context);
    if (result != PermissionResult.granted) return;
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final picked = await FilePicker.platform.pickFiles();
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (picked == null || picked.files.single.path == null) return;
    final file = File(picked.files.single.path!);
    if (!mounted) return;
    final caption = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => DocumentPreviewScreen(file: file)),
    );
    if (caption != null) _sendDocument(file, content: caption);
  }

  Future<void> _openCamera() async {
    final result = await _permissionService.requestCamera(context);
    if (result != PermissionResult.granted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (_) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDark),
          title: Text(
            'Capture',
            style: TextStyle(color: AppTheme.textPrimary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'photo'),
              child: Text(
                'Photo',
                style: TextStyle(color: AppTheme.textPrimary(isDark)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: Text(
                'Video',
                style: TextStyle(color: AppTheme.textPrimary(isDark)),
              ),
            ),
          ],
        );
      },
    );
    if (choice == 'photo') {
      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final img = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (img != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnhancedImagePreviewScreen(
              images: [File(img.path)],
              onSend: (imgs, caption) => _sendMultipleImages(imgs, caption),
            ),
          ),
        );
      }
    } else if (choice == 'video') {
      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final vid = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (vid != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnhancedVideoPreviewScreen(
              videoFile: File(vid.path),
              onSend: (v, caption) => _sendVideo(v, content: caption),
            ),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // MESSAGE OPTIONS
  // ─────────────────────────────────────────────

  void _showMessageOptions(ChatMessage msg) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── REPLY ──
            _actionTile(Icons.reply, 'Reply', () {
              Navigator.pop(context);
              _startReply(msg);
            }),

            // ── COPY (text only) ──
            if (!msg.isImage &&
                !msg.isVideo &&
                !msg.isDocument &&
                !msg.isAudioFile &&
                !msg.isVoiceNote &&
                msg.text.isNotEmpty &&
                !msg.text.startsWith('__TRANSACTION__') &&
                !msg.text.startsWith('__SCHEDULED__'))
              _actionTile(Icons.copy, 'Copy', () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message copied'),
                    backgroundColor: HexColor('#1A7F4B'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }),

            // ── FORWARD ──
            _actionTile(Icons.forward, 'Forward', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForwardMessageScreen(
                    message: msg,
                    currentChatId: widget.groupId,
                  ),
                ),
              );
            }),

            // ── PIN ──
            _actionTile(Icons.push_pin_outlined, 'Pin message', () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final ok = await PinnedMessageService().pinMessage(
                chatId: widget.groupId,
                messageId: msg.id,
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
            }),

            // ── UNPIN ──
            _actionTile(Icons.push_pin, 'Unpin message', () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final ok = await PinnedMessageService().unpinMessage(
                chatId: widget.groupId,
                messageId: msg.id,
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
            }),

            // ── SAVE/UNSAVE ──
            _actionTile(
              _savedMessageIds.contains(msg.id)
                  ? Icons.star
                  : Icons.star_border,
              _savedMessageIds.contains(msg.id) ? 'Unsave' : 'Save',
              () async {
                Navigator.pop(context);
                await _toggleSave(msg);
              },
            ),

            // ── EDIT (own last text message within 30s) ──
            if (msg.isMe &&
                _canEditMessage(msg) &&
                !msg.isImage &&
                !msg.isVideo &&
                !msg.isDocument &&
                !msg.isAudioFile &&
                !msg.isVoiceNote)
              _actionTile(Icons.edit, 'Edit', () {
                Navigator.pop(context);
                _startEditing(msg);
              }),

            // ── DELETE ──
            if (msg.isMe)
              _actionTile(Icons.delete_outline, 'Delete for me', () {
                Navigator.pop(context);
                _deleteMessage(msg);
              }, color: Colors.red),

            if (msg.isMe && _canDeleteForEveryone(msg))
              _actionTile(Icons.delete_forever, 'Delete for everyone', () {
                Navigator.pop(context);
                _deleteForEveryone(msg);
              }, color: Colors.red),
          ],
        ),
      ),
    );
  }

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
    final wallpaperFile = File(wallpaperPath);
    if (!wallpaperFile.existsSync()) {
      return const BoxDecoration(color: Color(0xFF141414));
    }
    return BoxDecoration(
      image: DecorationImage(
        image: FileImage(wallpaperFile),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  void _startReply(ChatMessage msg) {
    String preview = msg.text;
    if (msg.isVoiceNote)
      preview = '🎤 Voice message';
    else if (msg.isAudioFile)
      preview = '🎵 Audio';
    else if (msg.isImage)
      preview = '🖼️ Photo';
    else if (msg.isVideo)
      preview = '🎥 Video';
    else if (msg.isDocument)
      preview = '📄 ${msg.documentName ?? "Document"}';

    setState(() {
      _isReplying = true;
      _replyToId = msg.id;
      _replyToText = preview;
      _replyToIsMe = msg.isMe;
      _replyToSenderName = msg.isMe ? 'You' : (msg.senderName ?? 'Someone');
      _replyToMediaType = msg.isImage
          ? 'image'
          : msg.isVideo
          ? 'video'
          : msg.isVoiceNote
          ? 'voice_note'
          : msg.isAudioFile
          ? 'audio'
          : msg.isDocument
          ? 'document'
          : null;
      _replyToThumbnailUrl = msg.isImage && (msg.imageUrls?.isNotEmpty ?? false)
          ? msg.imageUrls!.first
          : msg.isVideo
          ? msg.videoThumbnail ?? msg.videoUrl
          : null;
    });
  }

  Future<void> _toggleSave(ChatMessage msg) async {
    final ids = await _saveValues.getStringList(
      AppPreferenceHelper.STARRED_MESSAGES,
    );
    if (ids.contains(msg.id)) {
      ids.remove(msg.id);
      setState(() => _savedMessageIds.remove(msg.id));
    } else {
      ids.add(msg.id);
      setState(() => _savedMessageIds.add(msg.id));
    }
    await _saveValues.saveStringList(AppPreferenceHelper.STARRED_MESSAGES, ids);
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    setState(() => _messages.removeWhere((m) => m.id == msg.id));
    await _saveToHive();
    final ids =
        await _saveValues.getStringList('deleted_messages_${widget.groupId}') ??
        [];
    ids.add(msg.id);
    await _saveValues.saveStringList('deleted_messages_${widget.groupId}', ids);
  }

  bool _canEditMessage(ChatMessage msg) {
    if (!msg.isMe) return false;
    if (_messages.isEmpty || _messages.last.id != msg.id) return false;
    final diff = DateTime.now().difference(DateTime.parse(msg.timestamp));
    return diff.inSeconds <= 30;
  }

  void _startEditing(ChatMessage msg) {
    setState(() {
      _isEditing = true;
      _editingMessageId = msg.id;
      _messageController.text = msg.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingMessageId = null;
    });
    _messageController.clear();
  }

  Future<void> _editMessage() async {
    if (_editingMessageId == null) return;
    final messageId = _editingMessageId!;
    final newText = _messageController.text.trim();
    if (newText.isEmpty) return;

    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    setState(() {
      _messages[idx] = _messages[idx].copyWith(text: newText, isEdited: true);
      _isEditing = false;
      _editingMessageId = null;
    });
    _messageController.clear();

    if (_socket?.connected == true) {
      _socket!.emit('edit message', {
        'chatId': widget.groupId,
        'messageId': messageId,
        'newContent': newText,
      });
    }

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      await http.put(
        Uri.parse('${ApiStrings.baseUri}message/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': newText}),
      );
    } catch (e) {
      debugPrint('❌ Edit failed: $e');
    }
    await _saveToHive();
  }

  bool _canDeleteForEveryone(ChatMessage msg) {
    final diff = DateTime.now().difference(DateTime.parse(msg.timestamp));
    return diff.inHours < 1;
  }

  Future<void> _deleteForEveryone(ChatMessage msg) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
        ),
      );

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.delete(
        Uri.parse('${ApiStrings.baseUri}message/${msg.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'deleteForEveryone': true}),
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() => _messages.removeWhere((m) => m.id == msg.id));
        await _saveToHive();

        if (_socket?.connected == true) {
          _socket!.emit('delete message', {
            'chatId': widget.groupId,
            'messageId': msg.id,
            'deleteForEveryone': true,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Message deleted for everyone'),
              backgroundColor: HexColor('#1A7F4B'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _actionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color defaultColor = AppTheme.textPrimary(isDark);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? defaultColor, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: color ?? defaultColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Future<void> _markGroupAsRead() async {
    if (!mounted) return;
    final unreadIds = _messages
        .where((m) => !m.isMe && !m.isRead)
        .map((m) => m.id)
        .toList();

    if (mounted) {
      setState(() {
        for (var msg in _messages) {
          if (!msg.isMe) {
            msg.isRead = true;
            msg.status = MessageStatus.read;
          }
        }
      });
    }
    await _saveToHive();
    await ChatCacheSyncService.markIncomingMessagesRead(widget.groupId);

    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    try {
      await http.put(
        Uri.parse('${AppConfig.apiUrl}message/read'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": widget.groupId,
          if (unreadIds.isNotEmpty) "messageIds": unreadIds,
        }),
      );

      // ✅ Only emit "chat opened" — GlobalSocketService handles delivery acks.
      if (_socket?.connected == true) {
        _socket!.emit("chat opened", {"chatId": widget.groupId});
      }
    } catch (e) {
      debugPrint('❌ Mark group read failed: $e');
    }
  }

  Future<void> _saveToHive() async {
    _messages = _dedupeMessages(_messages);
    await _chatBox.put(
      widget.groupId,
      _messages.map((e) => e.toHive()).toList(),
    );
  }

  Future<void> _updateCachedLastMessageStatus(
    String status, {
    String? messageId,
    List<String>? messageIds,
  }) async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.groupId);
      if (chatItem == null || chatItem.lastMessageJson.isEmpty) return;
      final decoded =
          jsonDecode(chatItem.lastMessageJson) as Map<String, dynamic>;
      final id = (decoded['_id'] ?? decoded['id'] ?? '').toString();
      final senderId = decoded['senderId']?.toString() ?? '';
      final matches = messageIds != null
          ? messageIds.contains(id)
          : (messageId == null || messageId.isEmpty || id == messageId);
      if (!matches || senderId != _myUserId) return;

      const rank = {'sending': 0, 'sent': 1, 'delivered': 2, 'read': 3};
      final currentRank = rank[decoded['status']?.toString() ?? ''] ?? 0;
      final nextRank = rank[status] ?? 0;
      if (nextRank <= currentRank) return;

      decoded['status'] = status;
      if (status == 'read') decoded['isRead'] = true;
      await chatListBox.put(
        widget.groupId,
        chatItem.copyWith(lastMessageJson: jsonEncode(decoded)),
      );
    } catch (e) {
      debugPrint('❌ Group last-message status cache update failed: $e');
    }
  }

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
      final chatItem = chatListBox.get(widget.groupId);
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
        'senderId': _myUserId,
        'isRead': false,
        'status': 'sent',
        'isImage': isImage,
        'isVoiceNote': isVoiceNote,
        'isAudio': isAudio,
        'isVideo': isVideo,
        'isDocument': isDocument,
        'isContact': false,
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

      await chatListBox.put(widget.groupId, updated);
    } catch (e) {
      debugPrint('❌ Group _updateChatListPreview error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final dist =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (dist > 200 != _showScrollToBottom)
      setState(() => _showScrollToBottom = dist > 200);
  }

  double _safePickerHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final kbH = mq.viewInsets.bottom;
    final navH = mq.padding.bottom;
    if (kbH > 100) {
      _keyboardHeight = kbH + navH;
    }
    if (kbH <= 100) return 320 + navH;
    return _keyboardHeight;
  }

  String _formatTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return DateFormat('hh:mm a').format(d);
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return trimmed;
    if (trimmed.startsWith('http')) return ''; // malformed — drop it
    if (trimmed.startsWith('/') || trimmed.contains('.')) {
      return ApiStrings.baseUriImage + trimmed;
    }
    return '';
  }

  // ─────────────────────────────────────────────
  // GROUP INFO NAVIGATION — awaits result for rename
  // ─────────────────────────────────────────────

  /// ✅ FIX: Push GroupInfoScreen and await the result.
  /// GroupInfoScreen.pop(context, newName) sends back the updated name.
  /// We update _currentGroupName and _currentCommunityName so the appbar refreshes.
  // ─────────────────────────────────────────────────────────────────────────
  // GROUP CALL (Video + Voice) — WhatsApp-style
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initiateGroupCall({required bool isVideo}) async {
    final hasPermission = isVideo
        ? await CallPermissionHandler.requestVideoPermissions(context)
        : await CallPermissionHandler.requestAudioPermissions(context);
    if (!hasPermission) return;

    if (_socket == null || !_socket!.connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not connected. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final myUserId = _myUserId;
    final myUsername =
        await _saveValues.getString(AppPreferenceHelper.USER_NAME) ?? '';
    final authToken =
        await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';

    final callNotifier = ref.read(callStateProvider.notifier);
    callNotifier.initializeWithSocket(
      _socket!,
      myUserId: myUserId,
      myUsername: myUsername,
      authToken: authToken,
    );

    // Prepare UI immediately — screen opens instantly
    callNotifier.prepareOutgoingCall(
      userId: widget.groupId, // group ID acts as the "user" for group calls
      userName: _currentGroupName,
      userPhoto: widget.groupImage,
      isVideo: isVideo,
    );

    if (!mounted) return;

    // Navigate to group call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupCallScreen(
          groupId: widget.groupId,
          groupName: _currentGroupName,
          groupImage: widget.groupImage,
          members: _groupMembers,
          isVideo: isVideo,
          socket: _socket,
          myUserId: _myUserId,
        ),
      ),
    );

    // Start the actual call in background
    callNotifier
        .startCall(
          userId: widget.groupId,
          userName: _currentGroupName,
          userPhoto: widget.groupImage,
          isVideo: isVideo,
        )
        .catchError((e) {
          debugPrint('❌ Group startCall error: $e');
        });
  }

  Future<void> _openGroupInfo() async {
    final updatedName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => GroupInfoScreen(
          groupId: widget.groupId,
          groupName: _currentGroupName,
          groupImage: _getFullImageUrl(widget.groupImage),
        ),
      ),
    );
    // ✅ Reload wallpaper/color the moment user presses back — no need to leave screen
    if (mounted) _loadWallpaperAndColor();
    // ✅ If GroupInfoScreen passed back a new name, apply it
    if (updatedName != null && updatedName.isNotEmpty && mounted) {
      setState(() {
        _currentGroupName = updatedName;
        _currentCommunityName = updatedName;
      });
    }
    _refreshGroupName();
  }

  Future<void> _refreshGroupName() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/group/${widget.groupId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Unwrap data envelope if present
        final groupData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final name =
            groupData['chatName'] as String? ??
            groupData['name'] as String? ??
            '';
        if (name.isNotEmpty && name != 'Unnamed Group' && mounted) {
          setState(() {
            _currentGroupName = name;
            _currentCommunityName = name;
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ _refreshGroupName: $e');
    }
  }

  bool get _isMuted {
    final chatBox = Hive.box<ChatListItemHive>('chats');
    return chatBox.get(widget.groupId)?.isCurrentlyMuted ?? false;
  }

  String _buildTypingText() {
    final names = _typingUsers.values.toList();
    if (names.length == 1) return '${names[0]} is typing...';
    if (names.length == 2) return '${names[0]}, ${names[1]} are typing...';
    return '${names[0]}, ${names[1]} and ${names.length - 2} more are typing...';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: HexColor('#1A7F4B'),
                onPressed: _scrollToBottom,
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          : null,
      body: Container(
        decoration: _wallpaperPath != null
            ? _getWallpaperDecoration(_wallpaperPath!)
            : BoxDecoration(color: AppTheme.scaffoldBg(isDark)),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: (_showEmojiPicker || _showGifPicker)
                ? 0
                : MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              _buildAppBar(),
              PinnedMessageBanner(
                key: _pinnedBannerKey,
                chatId: widget.groupId,
                currentUserId: _myUserId,
                isAdmin: false,
                onChanged: () => _pinnedBannerKey.currentState?.reload(),
              ),
              if (_showSearchBar)
                Container(
                  color: isDark
                      ? const Color(0xFF1A1A1A)
                      : AppTheme.scaffoldBg(isDark),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : AppTheme.inputFill(isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchBarController,
                            autofocus: true,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary(isDark),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search in chat...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : AppTheme.textHint(isDark),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDark
                                    ? Colors.white38
                                    : AppTheme.iconColorSubtle(isDark),
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _showSearchBar = false;
                          _searchQuery = '';
                          _searchBarController.clear();
                        }),
                        child: Icon(
                          Icons.close,
                          color: isDark
                              ? Colors.white54
                              : AppTheme.iconColorSubtle(isDark),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _messages.isEmpty && _isLoading
                    ? const SizedBox.shrink()
                    : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/message_group.png',
                              width: 80,
                              height: 80,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation',
                              style: GoogleFonts.poppins(
                                color: isDark
                                    ? Colors.white54
                                    : AppTheme.textSecondary(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _searchQuery.isEmpty
                            ? _messages.length
                            : _messages
                                  .where(
                                    (m) => m.text.toLowerCase().contains(
                                      _searchQuery.toLowerCase(),
                                    ),
                                  )
                                  .length,
                        itemBuilder: (context, i) {
                          final displayed = _searchQuery.isEmpty
                              ? _messages
                              : _messages
                                    .where(
                                      (m) => m.text.toLowerCase().contains(
                                        _searchQuery.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                          final msg = displayed[i];
                          return Column(
                            key: ValueKey(msg.id),
                            children: [
                              if (shouldShowDateSeparator(displayed, i))
                                DateSeparator(
                                  date: DateTime.parse(msg.timestamp),
                                ),
                              _buildMessageItem(msg),
                            ],
                          );
                        },
                      ),
              ),
              if (_typingUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _buildTypingText(),
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white70
                                : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showMentionList && _filteredMembers.isNotEmpty)
                _buildMentionList(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showRecorder ? _buildRecorder() : _buildInputField(),
              ),

              if (_showEmojiPicker || _showGifPicker)
                Container(
                  height: _safePickerHeight(context),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.vertical(
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
                        final cur = _messageController.text;
                        final sel = _messageController.selection;
                        final start = sel.start < 0 ? cur.length : sel.start;
                        final end = sel.end < 0 ? cur.length : sel.end;
                        final newText = cur.replaceRange(start, end, emoji);
                        _messageController.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                            offset: start + emoji.length,
                          ),
                        );
                        // ✅ Manually update _isUserTyping since programmatic
                        // changes don't trigger onChanged
                        setState(
                          () => _isUserTyping = newText.trim().isNotEmpty,
                        );
                      },
                      onGifSelected: (url) async {
                        setState(() {
                          _showEmojiPicker = false;
                          _showGifPicker = false;
                        });
                        final tempId = DateTime.now().millisecondsSinceEpoch
                            .toString();
                        final gifMsg = ChatMessage(
                          id: tempId,
                          chatId: widget.groupId,
                          isImage: true,
                          imageUrls: [url],
                          text: '',
                          isMe: true,
                          isRead: false,
                          status: MessageStatus.sending,
                          timestamp: DateTime.now().toIso8601String(),
                        );
                        setState(() => _messages.add(gifMsg));
                        _scrollToBottom();
                        try {
                          final token = await _saveValues.getString(
                            AppPreferenceHelper.AUTH_TOKEN,
                          );
                          final res = await http.post(
                            Uri.parse('${ApiStrings.baseUri}message'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode({
                              'chatId': widget.groupId,
                              'content': url,
                            }),
                          );
                          if (!mounted) return;
                          if (res.statusCode == 200 || res.statusCode == 201) {
                            final id = jsonDecode(res.body)['_id'];
                            final idx = _messages.indexWhere(
                              (m) => m.id == tempId,
                            );
                            if (idx != -1) {
                              setState(
                                () => _messages[idx] = _messages[idx].copyWith(
                                  id: id,
                                  status: MessageStatus.sent,
                                ),
                              );
                            }
                          } else {
                            _markFailed(tempId);
                          }
                        } catch (_) {
                          _markFailed(tempId);
                        }
                        await _saveToHive();
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/app_bar_gredient.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: _openGroupInfo,
                  child: Row(
                    children: [
                      // Composite avatar when members are loaded, single avatar fallback otherwise
                      if (_groupMembers.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 70,
                            maxHeight: 36,
                          ),
                          child: CompositeGroupAvatar(
                            members: _groupMembers,
                            avatarRadius: 14,
                            overlap: 10,
                          ),
                        )
                      else
                        CachedProfileAvatar(
                          imageUrl: widget.groupImage.isNotEmpty
                              ? (_getFullImageUrl(widget.groupImage).isNotEmpty
                                    ? _getFullImageUrl(widget.groupImage)
                                    : null)
                              : null,
                          displayName: _currentGroupName.isNotEmpty
                              ? _currentGroupName
                              : 'Group',
                          radius: 18,
                          backgroundColor: HexColor('#FB8830'),
                        ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentCommunityName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${widget.memberCount} members',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: Colors.white),
                onPressed: () => _initiateGroupCall(isVideo: true),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white, size: 20),
                onPressed: () => _initiateGroupCall(isVideo: false),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: _showGroupMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGroupMenu() {
    final scaffoldCtx = context;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 220,
        MediaQuery.of(context).padding.top + kToolbarHeight - 10,
        12,
        0,
      ),
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _menuItem(Icons.info_outline, 'Group info', 'info'),
        _menuItem(Icons.photo_library_outlined, 'Media, links & docs', 'media'),
        _menuItem(Icons.search, 'Search', 'search'),
        _menuItem(
          _isMuted
              ? Icons.notifications_outlined
              : Icons.notifications_off_outlined,
          _isMuted ? 'Unmute notifications' : 'Mute notifications',
          'mute',
        ),
        _menuItem(Icons.person_add_outlined, 'Add members', 'add_members'),
        _menuItem(Icons.share_outlined, 'Share', 'share'),
        _menuItem(Icons.settings_outlined, 'Group settings', 'settings'),
        _menuItem(Icons.archive_outlined, 'Archive group', 'archive'),
        _menuItem(
          Icons.logout,
          'Exit group',
          'exit',
          color: const Color(0xFFFF3B30),
        ),
        _menuItem(
          Icons.delete_outline,
          'Delete group',
          'delete',
          color: const Color(0xFFFF3B30),
        ),
      ],
    ).then((value) {
      if (value == null || !mounted) return;
      switch (value) {
        case 'info':
          _openGroupInfo();
          break;

        case 'media':
          Navigator.push(
            scaffoldCtx,
            MaterialPageRoute(
              builder: (_) => ChatMediaTabScreen(
                userId: widget.groupId,
                username: _currentGroupName,
                isOnline: false,
                initialTabIndex: 0,
                chatId: widget.groupId,
              ),
            ),
          );
          break;

        case 'search':
          setState(() {
            _showSearchBar = !_showSearchBar;
            if (!_showSearchBar) {
              _searchQuery = '';
              _searchBarController.clear();
            }
          });
          break;

        case 'mute':
          _handleMuteToggle(scaffoldCtx);
          break;

        case 'add_members':
          Navigator.push(
            scaffoldCtx,
            MaterialPageRoute(
              builder: (_) => AddMembersScreen(
                groupId: widget.groupId,
                groupName: _currentGroupName,
              ),
            ),
          );
          break;

        case 'share':
          GroupInviteService.generateAndShare(
            scaffoldCtx,
            groupId: widget.groupId,
            groupName: _currentGroupName,
          );
          break;

        case 'settings':
          Navigator.push(
            scaffoldCtx,
            MaterialPageRoute(
              builder: (_) => GroupSettingsFullScreen(
                groupId: widget.groupId,
                groupName: _currentGroupName,
                groupImage: _getFullImageUrl(widget.groupImage),
                isAdmin: true,
                members: _groupMembers,
                admins: const [],
                onChanged: () {
                  _loadWallpaperAndColor();
                  _refreshGroupName();
                },
              ),
            ),
          ).then((newName) {
            if (newName is String && newName.isNotEmpty && mounted) {
              setState(() {
                _currentGroupName = newName;
                _currentCommunityName = newName;
              });
            }
          });
          break;

        case 'archive':
          _handleArchive(scaffoldCtx);
          break;

        case 'exit':
          showDialog(
            context: scaffoldCtx,
            builder: (_) => ExitGroupDialog(
              groupName: _currentGroupName,
              isAdmin: true,
              onExit: () async {
                final ok = await GroupApiService().leaveGroup(
                  groupId: widget.groupId,
                );
                if (ok && mounted) {
                  Navigator.pop(scaffoldCtx);
                  ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                    SnackBar(
                      content: Text('Left $_currentGroupName'),
                      backgroundColor: const Color(0xFFFF3B30),
                    ),
                  );
                }
              },
            ),
          );
          break;

        case 'delete':
          showDialog(
            context: scaffoldCtx,
            builder: (_) => DeleteGroupDialog(
              groupName: _currentGroupName,
              onDelete: () async {
                try {
                  final token = await _saveValues.getString(
                    AppPreferenceHelper.AUTH_TOKEN,
                  );
                  await http.delete(
                    Uri.parse(
                      '${ApiStrings.baseUri}chat/group/${widget.groupId}',
                    ),
                    headers: {'Authorization': 'Bearer $token'},
                  );
                } catch (_) {}
                if (mounted) {
                  Navigator.pop(scaffoldCtx);
                  Navigator.pop(scaffoldCtx);
                }
              },
            ),
          );
          break;
      }
    });
  }

  // ── Popup menu item builder ────────────────────────────────────────────────
  PopupMenuItem<String> _menuItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white70, size: 20),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color ?? Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mute helper — called after menu closes ────────────────────────────────
  Future<void> _handleMuteToggle(BuildContext ctx) async {
    // Check current mute state from Hive
    final chatBox = Hive.box<ChatListItemHive>('chats');
    final chatItem = chatBox.get(widget.groupId);
    final bool isCurrentlyMuted = chatItem?.isCurrentlyMuted ?? false;

    if (isCurrentlyMuted) {
      // Already muted — unmute immediately
      if (chatItem != null) {
        await chatBox.put(
          widget.groupId,
          chatItem.copyWith(isMuted: false, muteUntil: null),
        );
      }
      await ChatActionsService().unmuteChat(widget.groupId);
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              'Notifications unmuted',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: HexColor('#1A7F4B'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      // Not muted — show duration picker
      final result = await showDialog<int>(
        context: ctx,
        builder: (_) => MuteNotificationsDialog(chatId: widget.groupId),
      );
      if (result != null && mounted) {
        const durations = ['1 Hour', '8 Hours', '1 Week', 'Always'];
        final muteUntil = result == 3
            ? null // Always = no end date
            : DateTime.now().add(
                [
                  const Duration(hours: 1),
                  const Duration(hours: 8),
                  const Duration(days: 7),
                ][result],
              );

        // Save to Hive so group list shows mute icon immediately
        if (chatItem != null) {
          await chatBox.put(
            widget.groupId,
            chatItem.copyWith(isMuted: true, muteUntil: muteUntil),
          );
        }
        await ChatActionsService().muteChat(widget.groupId);

        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                'Notifications muted for ${durations[result]}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: HexColor('#1A7F4B'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  // ── Archive helper — saves ID to archived list & pops back ────────────────
  Future<void> _handleArchive(BuildContext ctx) async {
    // Read the existing archived list and add this group
    final archivedIds = await _saveValues.getStringList(
      AppPreferenceHelper.archivedChats(),
    );
    if (!archivedIds.contains(widget.groupId)) {
      archivedIds.add(widget.groupId);
      await _saveValues.saveStringList(
        AppPreferenceHelper.archivedChats(),
        archivedIds,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          'Group archived',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: HexColor('#1A7F4B'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    // Pop back to the group list so the group disappears immediately
    Navigator.pop(ctx);
  }

  Widget _buildMessageItem(ChatMessage msg) {
    void handleReply() => _startReply(msg);
    final senderName = msg.isMe ? null : (msg.senderName ?? 'Unknown');

    // ── Contact share bubble ───────────────────────────────────────────────
    if (msg.text.startsWith('__CONTACT_SHARE__:')) {
      final parts = msg.text.split(':');
      final cName = parts.length > 1 ? parts[1] : 'Contact';
      final cPhone = parts.length > 2 ? parts[2] : '';
      final cPic = parts.length > 3 ? parts[3] : '';
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return _wrapWithAvatar(
        msg,
        GestureDetector(
          onLongPress: () => _showMessageOptions(msg),
          child: Align(
            alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
        ),
      );
    }

    if (msg.isVoiceNote) {
      return _wrapWithAvatar(
        msg,
        VoiceNoteBubble(
          audioUrl: msg.audioUrl!,
          isMe: msg.isMe,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
          status: msg.status,
          isSaved: _savedMessageIds.contains(msg.id),
          replyToText: msg.replyToText,
          replyToIsMe: msg.replyToIsMe,
          replyToSenderName: msg.replyToSenderName,
          replyToMediaType: msg.replyToMediaType,
          replyToThumbnailUrl: msg.replyToThumbnailUrl,
          isForwarded: msg.isForwarded,
          onLongPress: () => _showMessageOptions(msg),
          onSwipe: (_) => handleReply(),
        ),
      );
    }
    if (msg.isAudioFile) {
      return _wrapWithAvatar(
        msg,
        AudioFileBubble(
          audioUrl: msg.audioUrl!,
          fileName: msg.audioName ?? 'audio',
          isMe: msg.isMe,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
          status: msg.status,
          isSaved: _savedMessageIds.contains(msg.id),
          replyToText: msg.replyToText,
          replyToIsMe: msg.replyToIsMe,
          onLongPress: () => _showMessageOptions(msg),
          onSwipe: (_) => handleReply(),
          senderName: senderName,
        ),
      );
    }
    if (msg.isDocument) {
      return _wrapWithAvatar(
        msg,
        DocumentBubble(
          name: msg.documentName ?? 'document',
          text: msg.text,
          isMe: msg.isMe,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
          documentUrl: msg.documentUrl,
          status: msg.status,
        ),
      );
    }
    if (msg.isVideo) {
      return _wrapWithAvatar(
        msg,
        VideoBubble(
          videoUrl: msg.videoUrl!,
          thumbnail: msg.videoThumbnail,
          text: msg.text,
          isMe: msg.isMe,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
          isSaved: _savedMessageIds.contains(msg.id),
          replyToText: msg.replyToText,
          replyToIsMe: msg.replyToIsMe,
          replyToSenderName: msg.replyToSenderName,
          replyToMediaType: msg.replyToMediaType,
          replyToThumbnailUrl: msg.replyToThumbnailUrl,
          isForwarded: msg.isForwarded,
          status: msg.status,
          isRecipientOnline: true,
          onLongPress: () => _showMessageOptions(msg),
          onSwipe: (_) => handleReply(),
        ),
      );
    }
    if (msg.isImage) {
      if (msg.imageUrls != null && msg.imageUrls!.isNotEmpty) {
        final bool isUploading =
            msg.status == MessageStatus.sending &&
            msg.isMe &&
            _uploadingTempId == msg.id;
        return _wrapWithAvatar(
          msg,
          MultiImageBubble(
            images: msg.imageUrls!,
            text: msg.text,
            isMe: msg.isMe,
            isRead: msg.isRead,
            timestamp: msg.timestamp,
            status: msg.status,
            isSaved: _savedMessageIds.contains(msg.id),
            replyToText: msg.replyToText,
            replyToIsMe: msg.replyToIsMe,
            replyToSenderName: msg.replyToSenderName,
            replyToMediaType: msg.replyToMediaType,
            replyToThumbnailUrl: msg.replyToThumbnailUrl,
            isForwarded: msg.isForwarded,
            onLongPress: () => _showMessageOptions(msg),
            onSwipe: (_) => handleReply(),
            senderName: senderName,
            uploadProgress: isUploading ? _uploadProgress : null,
          ),
        );
      }
    }

    return _wrapWithAvatar(
      msg,
      ChatMessageBubble(
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        isEdited: msg.isEdited,
        timestamp: msg.timestamp,
        isSaved: _savedMessageIds.contains(msg.id),
        replyToText: msg.replyToText,
        replyToIsMe: msg.replyToIsMe,
        replyToSenderName: msg.replyToSenderName,
        replyToMediaType: msg.replyToMediaType,
        replyToThumbnailUrl: msg.replyToThumbnailUrl,
        replyToMessageId: msg.replyToMessageId,
        status: msg.status,
        isRecipientOnline: true,
        bubbleColor: _customBubbleColor,
        receiverBubbleColor: _receiverBubbleColor,
        senderGlowColor: _senderGlowColor,
        receiverGlowColor: _receiverGlowColor,
        isForwarded: msg.isForwarded,
        onLongPress: () => _showMessageOptions(msg),
        onSwipe: (_) => handleReply(),
        senderName: senderName,
        mentionedUserIds: msg.mentionedUserIds,
        myUserId: _myUserId,
      ),
    );
  }

  Widget _wrapWithAvatar(ChatMessage msg, Widget bubble) {
    if (msg.isMe) return bubble;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CachedProfileAvatar(
            imageUrl: msg.senderAvatar != null && msg.senderAvatar!.isNotEmpty
                ? _getFullImageUrl(msg.senderAvatar)
                : null,
            displayName: msg.senderName ?? '',
            radius: 14,
            backgroundColor: HexColor('#3A3A3A'),
          ),
          const SizedBox(width: 6),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget _buildMentionList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _filteredMembers.length,
        itemBuilder: (context, i) {
          final member = _filteredMembers[i];
          return InkWell(
            onTap: () => _insertMention(member),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CachedProfileAvatar(
                    imageUrl: member.profilePicture?.isNotEmpty == true
                        ? _getFullImageUrl(member.profilePicture)
                        : null,
                    displayName: member.username,
                    radius: 16,
                    backgroundColor: HexColor('#3A3A3A'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '@${member.username}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecorder() {
    return RecorderUI(
      onDelete: _deleteRecording,
      onSend: _sendRecording,
      recorderController: _audioRecorder.recorderController,
      recordingDuration: _recordingDuration,
    );
  }

  Widget _buildInputField() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: keyboardOpen
                  ? AppTheme.cardBg(isDark)
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
                if (_isReplying && _replyToText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
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
                        Icon(Icons.reply, color: HexColor('#1A7F4B'), size: 18),
                        const SizedBox(width: 8),
                        if (_replyToMediaType == 'image' &&
                            _replyToThumbnailUrl != null &&
                            _replyToThumbnailUrl!.isNotEmpty)
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.black26,
                            ),
                            child: _replyToThumbnailUrl!.startsWith('http')
                                ? Image.network(
                                    _replyToThumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  )
                                : Image.file(
                                    File(_replyToThumbnailUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                          )
                        else if (_replyToMediaType != null)
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
                                _replyToMediaType == 'video'
                                    ? Icons.videocam_outlined
                                    : _replyToMediaType == 'voice_note' ||
                                          _replyToMediaType == 'voice'
                                    ? Icons.graphic_eq
                                    : _replyToMediaType == 'audio'
                                    ? Icons.audiotrack
                                    : _replyToMediaType == 'document'
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
                                _replyToSenderName ?? '',
                                style: TextStyle(
                                  color: HexColor('#1A7F4B'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _replyToText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textSecondary(isDark),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isReplying = false;
                            _replyToId = null;
                            _replyToText = null;
                            _replyToIsMe = null;
                            _replyToSenderName = null;
                            _replyToMediaType = null;
                            _replyToThumbnailUrl = null;
                          }),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isEditing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
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
                        const Icon(Icons.edit, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Editing message',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.textSecondary(isDark),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _cancelEditing,
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: isDark
                              ? const DecorationImage(
                                  image: AssetImage(
                                    'images/app_bar_gredient.png',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: isDark ? null : const Color(0xFFFAF5F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.15)
                                : AppTheme.border(isDark),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 15,
                          ),
                          cursorColor: isDark
                              ? Colors.white
                              : AppTheme.textPrimary(isDark),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.textHint(isDark),
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                                  Future.delayed(
                                    const Duration(milliseconds: 50),
                                    () {
                                      if (mounted)
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(_messageFocusNode);
                                    },
                                  );
                                } else {
                                  final kh = MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom;
                                  if (kh > 100)
                                    setState(() => _keyboardHeight = kh);
                                  FocusScope.of(context).unfocus();
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
                                        ? const SizedBox(key: ValueKey('empty'))
                                        : GestureDetector(
                                            key: const ValueKey('cam'),
                                            onTap: _openCamera,
                                            child: Image(
                                              image: const AssetImage(
                                                'images/cam.png',
                                              ),
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
                                    onTap: _showAttachmentMenu,
                                    child: Image(
                                      image: const AssetImage(
                                        'images/button_add.png',
                                      ),
                                      width: 30,
                                      height: 30,
                                      color: isDark
                                          ? null
                                          : AppTheme.iconColor(isDark),
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
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isEditing
                          ? _editMessage
                          : (_isUserTyping ? _sendMessage : _startRecording),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: HexColor('#1A7F4B'),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Contact picker for group chat ───────────────────────────────────────
  void _openGroupContactPicker() {
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
            chatId: widget.groupId,
            text: contactText,
            isMe: true,
            isRead: false,
            status: MessageStatus.sending,
            timestamp: DateTime.now().toIso8601String(),
          );
          setState(() => _messages.add(tempMsg));
          _scrollToBottom();
          await _saveToHive();
          try {
            final token = await _saveValues.getString(
              AppPreferenceHelper.AUTH_TOKEN,
            );
            final res = await http.post(
              Uri.parse('${ApiStrings.baseUri}message'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'chatId': widget.groupId,
                'content': contactText,
              }),
            );
            if (!mounted) return;
            if (res.statusCode == 200 || res.statusCode == 201) {
              final serverId = jsonDecode(res.body)['_id'];
              final idx = _messages.indexWhere((m) => m.id == tempId);
              if (idx != -1) {
                setState(
                  () => _messages[idx] = _messages[idx].copyWith(
                    id: serverId,
                    status: MessageStatus.sent,
                  ),
                );
                await _updateChatListPreview(
                  text: '👤 $name',
                  messageId: serverId,
                );
              }
            } else {
              _markFailed(tempId);
            }
          } catch (_) {
            _markFailed(tempId);
          }
          await _saveToHive();
        },
      ),
    );
  }

  // ─── Audio picker for group chat ─────────────────────────────────────────
  Future<void> _pickGroupAudioFile() async {
    try {
      final storageResult = await _permissionService.requestStorage(context);
      if (storageResult != PermissionResult.granted) return;

      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;

      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
      } catch (_) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
      }

      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();

      if (result == null || result.files.single.path == null) return;
      final path = result.files.single.path!;
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
          path.toLowerCase().endsWith('.wma');

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

      // Show preview before sending
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AudioPreviewScreen(
            audioFile: file,
            onSend: (audioFile) async {
              final fileName = audioFile.path.split('/').last;
              final tempId = DateTime.now().millisecondsSinceEpoch.toString();

              final tempMsg = ChatMessage(
                id: tempId,
                chatId: widget.groupId,
                isVoiceNote: false,
                isAudioFile: true,
                audioUrl: path,
                audioName: fileName,
                isMe: true,
                isRead: false,
                status: MessageStatus.sending,
                timestamp: DateTime.now().toIso8601String(),
                text: '',
              );
              setState(
                () => _messages = _dedupeMessages([..._messages, tempMsg]),
              );
              _scrollToBottom();
              await _saveToHive();

              try {
                final mime = lookupMimeType(path) ?? 'audio/mpeg';
                final publicUrl = await PresignedUploadService.uploadFile(
                  file: file,
                  mimeType: mime,
                );
                if (publicUrl == null) {
                  _markFailed(tempId);
                  return;
                }
                final token = await _saveValues.getString(
                  AppPreferenceHelper.AUTH_TOKEN,
                );
                final res = await http.post(
                  Uri.parse('${ApiStrings.baseUri}message'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    'chatId': widget.groupId,
                    'content': ' ',
                    'contentType': 'audio',
                    'attachmentUrls': [publicUrl],
                    'tempId': tempId,
                  }),
                );
                if (!mounted) return;
                if (res.statusCode == 200 || res.statusCode == 201) {
                  final id = jsonDecode(res.body)['_id'];
                  await _replaceTempMessage(
                    tempId,
                    tempMsg.copyWith(id: id, status: MessageStatus.sent),
                  );
                  await _updateChatListPreview(
                    text: ' ',
                    isAudio: true,
                    messageId: id,
                  );
                } else {
                  _markFailed(tempId);
                }
              } catch (_) {
                _markFailed(tempId);
              }
              await _saveToHive();
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Group audio pick error: $e');
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 320.0,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // ── Row 1: Camera | Audio | Contact ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachItem(
                    Icons.camera_alt,
                    'Camera',
                    HexColor('#F6695E'),
                    () {
                      ProviderScope.containerOf(context)
                              .read(biometricAuthProvider.notifier)
                              .isPickerActive =
                          true;
                      Navigator.pop(ctx);
                      _openCamera();
                    },
                  ),
                  _attachItem(
                    Icons.headphones,
                    'Audio',
                    HexColor('#66D0FF'),
                    () {
                      ProviderScope.containerOf(context)
                              .read(biometricAuthProvider.notifier)
                              .isPickerActive =
                          true;
                      Navigator.pop(ctx);
                      _pickGroupAudioFile();
                    },
                  ),
                  _attachItem(Icons.person, 'Contact', HexColor('#4484CD'), () {
                    Navigator.pop(ctx);
                    _openGroupContactPicker();
                  }),
                ],
              ),
              const SizedBox(height: 50),
              // ── Row 2: Gallery | Video | Document ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachItem(
                    Icons.photo_library,
                    'Gallery',
                    HexColor('#FFD233'),
                    () {
                      ProviderScope.containerOf(context)
                              .read(biometricAuthProvider.notifier)
                              .isPickerActive =
                          true;
                      Navigator.pop(ctx);
                      _pickImages();
                    },
                  ),
                  _attachItem(Icons.videocam, 'Video', HexColor('#40C4FF'), () {
                    ProviderScope.containerOf(
                          context,
                        ).read(biometricAuthProvider.notifier).isPickerActive =
                        true;
                    Navigator.pop(ctx);
                    _pickVideo();
                  }),
                  _attachItem(
                    Icons.insert_drive_file,
                    'Document',
                    HexColor('#33D375'),
                    () {
                      ProviderScope.containerOf(context)
                              .read(biometricAuthProvider.notifier)
                              .isPickerActive =
                          true;
                      Navigator.pop(ctx);
                      _pickDocument();
                    },
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

  Widget _attachItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
