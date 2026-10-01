import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qik_talk/features/ai/screens/ai_chat_screen.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/model/get_chat_model.dart';
import 'package:qik_talk/features/chat/general/model/get_chat_model.dart'
    as model;
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/group_composite_avatar.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/features/status/components/emoji_gif_picker.dart';
import 'package:qik_talk/features/status/components/status_reply_bubble.dart';
import 'package:qik_talk/features/status/model/my_status_model.dart';
import 'package:qik_talk/features/status/screens/status_swiper_screen.dart';
import 'package:qik_talk/features/status/services/status_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/chat_list_time_formatter.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/chat/general/services/chat_cache_sync_service.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/chat_pin_service.dart';
import 'package:qik_talk/features/chat/general/services/protected_chats_service.dart';
import 'package:qik_talk/features/chat/general/screens/protected_chats_list_screen.dart';
import 'package:qik_talk/utilities/helpers/chat_lock_auth_helper.dart';

class ChatComponent extends StatefulWidget {
  final String searchQuery;

  /// Reactive total unread count for private chats.
  /// Listen to this in chat_screen.dart for an always-accurate tab badge.
  static final ValueNotifier<int> totalUnread = ValueNotifier<int>(0);

  const ChatComponent({super.key, this.searchQuery = ''});

  @override
  State<ChatComponent> createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent>
    with
        AutomaticKeepAliveClientMixin,
        // ROBOT DISABLED: SingleTickerProviderStateMixin,
        WidgetsBindingObserver {
  SaveValues mySaveValues = SaveValues();
  Timer? _autoRefreshTimer;
  String _myUserId = '';
  bool _isFetchingChats = false;

  List<ChatListItemHive> chats = [];
  bool isLoading = false;
  late Box<ChatListItemHive> chatBox;
  late Box<List> _messageBox;

  Map<String, int> _unreadCounts = {};
  int _lastLoggedUnreadTotal = -1; // ✅ track to suppress duplicate log dumps
  Map<String, int> _serverUnreadCounts = {};
  final Set<String> _activeChatIds = {};
  // ROBOT DISABLED:
  // late AnimationController _robotAnimationController;
  // late Animation<double> _robotAnimation;

  List<String> _archivedChatIds = [];
  Set<String> _blockedUserIds = {};
  AppLifecycleState? _lastLifecycleState;

  // ── Protected chats ──────────────────────────────────────────────────────
  List<String> _protectedChatIds = [];

  // ✅ Starts true so the list renders instantly from Hive.
  // _preloadProtectedChatIdsSync() populates the IDs before the first build
  // so no protected chat ever flashes in the main list.
  bool _protectedChatsLoaded = true;

  /// True when the user has already authenticated this foreground session.
  bool _unlockedThisSession = false;

  Map<String, bool> _statusRings = {};
  final Set<String> _recentlyPinnedChatIds = {};
  List<MyStatusModel> _cachedStatuses = [];
  static const String _deletedChatTombstonesKey = 'deleted_chat_tombstones';

  Future<Map<String, dynamic>> _loadDeletedChatTombstones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_deletedChatTombstonesKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _saveDeletedChatTombstones(
    Map<String, dynamic> tombstones,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deletedChatTombstonesKey, jsonEncode(tombstones));
  }

  Future<void> _markChatDeletedTombstone(ChatListItemHive chat) async {
    final tombstones = await _loadDeletedChatTombstones();
    tombstones[chat.id] = {
      'lastMessageId': chat.lastMessage?.id,
      'updatedAt': chat.updatedAt.toIso8601String(),
    };
    await _saveDeletedChatTombstones(tombstones);
  }

  StreamSubscription<void>? _chatUpdateSubscription;

  // Live typing/recording per chatId — key=chatId, value='typing'|'recording'
  final Map<String, String> _liveActivity = {};

  void _subscribeToChatListUpdates() {
    _chatUpdateSubscription?.cancel();
    _chatUpdateSubscription = GlobalSocketService().chatListUpdates.listen((_) {
      _refreshUnreadCountsFromCache();
    });
  }

  Future<void> _loadStatusRings() async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final myId = await SaveValues().getString(AppPreferenceHelper.ID);
      if (token == null) return;
      final statuses = await StatusService.fetchStatuses(token);
      final prefs = await SharedPreferences.getInstance();
      final viewed = prefs.getStringList('viewed_status_ids') ?? [];
      final Map<String, bool> rings = {};
      for (final s in statuses) {
        if (s.user.id == myId) continue;
        final hasUnviewed = s.updates.any((u) => !viewed.contains(u.id));
        rings[s.user.id] = hasUnviewed;
      }
      if (mounted) {
        setState(() {
          _statusRings = rings;
          _cachedStatuses = statuses;
        });
      }
    } catch (e) {
      debugPrint('Status rings error: $e');
    }
  }

  void _onTypingEvent(data) {
    final chatId = data['chatId']?.toString() ?? data['room']?.toString();
    final userId = data['userId']?.toString();
    if (chatId == null || userId == null || userId == _myUserId) return;
    debugPrint('🟡 CHAT LIST typing: $chatId');
    if (mounted) setState(() => _liveActivity[chatId] = 'typing');
  }

  void _onStopTypingEvent(data) {
    final chatId = data['chatId']?.toString() ?? data['room']?.toString();
    if (chatId == null) return;
    debugPrint('🔴 CHAT LIST stop typing: $chatId');
    if (mounted) setState(() => _liveActivity.remove(chatId));
  }

  void _onRecordingEvent(data) {
    final chatId = data['chatId']?.toString() ?? data['room']?.toString();
    final userId = data['userId']?.toString();
    if (chatId == null || userId == null || userId == _myUserId) return;
    if (mounted) setState(() => _liveActivity[chatId] = 'recording');
  }

  void _onStopRecordingEvent(data) {
    final chatId = data['chatId']?.toString() ?? data['room']?.toString();
    if (chatId == null) return;
    if (mounted) setState(() => _liveActivity.remove(chatId));
  }

  void _onMessagesReadEvent(data) {
    final chatId = data['chatId']?.toString();
    if (chatId == null) return;
    _refreshUnreadCountsFromCache();
    // ✅ TICK SYNC FIX: update the stored tick to blue immediately
    _applyTickStatusToHive(chatId, 'read');
    debugPrint('✅ [CHAT LIST] Read sync updated for chat $chatId');
  }

  // Backend emits "messages delivered" (plural) with { chatId, messageIds[] }.
  void _onMessageDeliveredEvent(data) {
    final chatId = data['chatId']?.toString();
    if (chatId == null) return;
    // ✅ TICK SYNC FIX: update the stored tick to grey double immediately
    _applyTickStatusToHive(chatId, 'delivered');
    debugPrint('📦 [CHAT LIST] Delivery sync updated for chat $chatId');
  }

  /// Updates the lastMessageJson status in the chats Hive box.
  /// Called from socket events in ChatComponent so the tile rebuilds immediately
  /// without waiting for the 10-second API poll.
  Future<void> _applyTickStatusToHive(String chatId, String status) async {
    try {
      final box = Hive.box<ChatListItemHive>('chats');
      final item = box.get(chatId);
      if (item == null || item.lastMessageJson.isEmpty) return;

      final decoded = jsonDecode(item.lastMessageJson) as Map<String, dynamic>;

      // Only update ticks for messages I sent
      final senderId = decoded['senderId']?.toString() ?? '';
      if (senderId != _myUserId) return;

      // Never downgrade
      const rank = {'sent': 1, 'delivered': 2, 'read': 3};
      final currentRank = rank[decoded['status']?.toString() ?? ''] ?? 0;
      final newRank = rank[status] ?? 0;
      if (newRank <= currentRank) return;

      decoded['status'] = status;
      if (status == 'read') decoded['isRead'] = true;

      await box.put(
        chatId,
        item.copyWith(lastMessageJson: jsonEncode(decoded)),
      );
      debugPrint('✅ [CHAT LIST TICK] $chatId → $status');
    } catch (e) {
      debugPrint('❌ _applyTickStatusToHive error: $e');
    }
  }

  // ✅ _onNewMessageEvent removed — GlobalSocketService writes to Hive which
  // triggers the AnimatedBuilder on chatBox.listenable() automatically.
  // No manual handler needed here; it was causing double badge refreshes.

  void _subscribeToSocketActivity() {
    try {
      final socket = GlobalSocketService().socket;
      if (socket == null) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _subscribeToSocketActivity();
        });
        return;
      }

      // ✅ Only attach chat-list-specific listeners here.
      // message received / newMessage are handled by GlobalSocketService
      // which writes to Hive and triggers the Hive listenable on chatBox —
      // ChatComponent picks up the change via AnimatedBuilder automatically.
      socket.off('typing', _onTypingEvent);
      socket.off('stop typing', _onStopTypingEvent);
      socket.off('recording audio', _onRecordingEvent);
      socket.off('stop recording audio', _onStopRecordingEvent);
      socket.off('messages read', _onMessagesReadEvent);
      socket.off('messages delivered', _onMessageDeliveredEvent);

      socket.on('typing', _onTypingEvent);
      socket.on('stop typing', _onStopTypingEvent);
      socket.on('recording audio', _onRecordingEvent);
      socket.on('stop recording audio', _onStopRecordingEvent);
      socket.on('messages read', _onMessagesReadEvent);
      socket.on('messages delivered', _onMessageDeliveredEvent);

      debugPrint('✅ Chat list socket activity listeners attached');
    } catch (e) {
      debugPrint('Socket activity subscribe error: $e');
    }
  }

  String formatFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final timeFormatted = DateFormat('hh:mm a').format(localTime);
    if (localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day) {
      return "Today at $timeFormatted";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (localTime.year == yesterday.year &&
        localTime.month == yesterday.month &&
        localTime.day == yesterday.day) {
      return "Yesterday at $timeFormatted";
    }
    final dateFormatted = DateFormat('dd MMM').format(localTime);
    return "$dateFormatted at $timeFormatted";
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SaveValues().getString(AppPreferenceHelper.ID).then((id) {
      if (mounted) setState(() => _myUserId = id ?? '');
    });
    chatBox = Hive.box<ChatListItemHive>('chats');
    _messageBox = Hive.box<List>('chat_messages');
    _messageBox.listenable().addListener(_refreshUnreadCountsFromCache);
    _restorePinnedChats();
    _startAutoRefresh();
    _loadStatusRings();
    // ✅ WHATSAPP-STYLE: Pre-load protected IDs from local cache synchronously
    // so the filter is active before the first build, then boot the chat list.
    _preloadProtectedChatIdsSync().then((_) {
      if (mounted) _initChatListInstant();
    });
    // Delay socket subscription to ensure socket is connected
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _subscribeToSocketActivity();
    });
    _subscribeToChatListUpdates();
    // ROBOT DISABLED:
    // _robotAnimationController = AnimationController(
    //   duration: const Duration(milliseconds: 1500),
    //   vsync: this,
    // );
    // _robotAnimation = Tween<double>(begin: 0, end: 15).animate(
    //   CurvedAnimation(
    //     parent: _robotAnimationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );
    // _robotAnimationController.repeat(reverse: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Reset session unlock so auth is required again after backgrounding
      _unlockedThisSession = false;
    }
    if (_lastLifecycleState == AppLifecycleState.paused &&
        state == AppLifecycleState.resumed) {
      fetchChatsFromApi();
      fetchUnreadCounts();
      _loadProtectedChats();
    }
    _lastLifecycleState = state;
  }

  Future<void> _restorePinnedChats() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = prefs.getStringList('pinned_chat_ids') ?? [];
    for (final chatId in pinnedIds) {
      final existing = chatBox.get(chatId);
      if (existing != null && !existing.isPinned) {
        await chatBox.put(
          chatId,
          existing.copyWith(
            isPinned: true,
            pinnedAt: existing.pinnedAt ?? DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> _loadArchivedChats() async {
    final archived = await mySaveValues.getStringList(
      AppPreferenceHelper.archivedChats(),
    );
    if (mounted) {
      setState(() => _archivedChatIds = archived);
      _refreshUnreadCountsFromCache();
    }
  }

  // ✅ Reads last-known protected IDs from the local prefs cache before any
  // build runs, so the filter is active from frame zero — no flash.
  Future<void> _preloadProtectedChatIdsSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList('protected_chat_ids_cache') ?? [];
      if (cached.isNotEmpty && mounted) {
        _protectedChatIds = cached;
      }
    } catch (_) {}
  }

  Future<void> _loadProtectedChats() async {
    final ids = await ProtectedChatsService().getProtectedChatIds();
    if (mounted) {
      setState(() {
        _protectedChatIds = ids;
        _protectedChatsLoaded = true;
      });
      // ✅ Write fresh IDs to local cache so next cold start is pre-populated
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('protected_chat_ids_cache', ids);
      } catch (_) {}
      _refreshUnreadCountsFromCache();
    }
  }

  // ✅ WHATSAPP-STYLE: render Hive cache immediately, sync API in background
  void _initChatListInstant() {
    loadLocalChats();
    fetchChatsFromApi().catchError((_) {});
    fetchUnreadCounts().catchError((_) {});
    _loadArchivedChats();
    _loadBlockedUsers();
    _loadProtectedChats();
  }

  Future<void> _loadBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('blocked_user_ids') ?? [];
    if (mounted) setState(() => _blockedUserIds = Set.from(blocked));
  }

  void loadLocalChats() {
    if (!mounted) return;
    final freshList = chatBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    // ✅ Never replace a populated list with an empty one during a refresh
    if (freshList.isEmpty && chats.isNotEmpty) return;
    setState(() => chats = freshList);
  }

  void clearAllUnreadCounts() {
    if (mounted) setState(() => _unreadCounts.clear());
    _serverUnreadCounts.clear();
    ChatComponent.totalUnread.value = 0;
  }

  Iterable<String> _trackedChatIds() =>
      chatBox.values.map((chat) => chat.id).toSet();

  Iterable<String> _visibleChatIds() => chatBox.values
      .where(
        (chat) =>
            !chat.isGroupChat && // ✅ PRIVATE chats only
            !chat.isBroadcast &&
            !chat.isCommunity &&
            !_archivedChatIds.contains(chat.id) &&
            !_protectedChatIds.contains(chat.id) &&
            // ✅ Only include private chats with valid userId
            chat.userId.trim().isNotEmpty,
      )
      .map((chat) => chat.id)
      .toSet();

  int _calculateVisibleUnreadTotal(Map<String, int> counts) {
    var total = 0;
    for (final chatId in _visibleChatIds()) {
      total += counts[chatId] ?? 0;
    }
    return total;
  }

  void _debugDumpVisibleUnreadChats(Map<String, int> counts) {
    final total = _calculateVisibleUnreadTotal(counts);

    // ✅ Only log when the total actually changes — no spam during steady state
    if (total == _lastLoggedUnreadTotal) return;
    _lastLoggedUnreadTotal = total;

    final visibleUnread = chatBox.values
        .where(
          (chat) =>
              !chat.isGroupChat &&
              !chat.isBroadcast &&
              !chat.isCommunity &&
              !_archivedChatIds.contains(chat.id) &&
              !_protectedChatIds.contains(chat.id) &&
              chat.userId.trim().isNotEmpty &&
              (counts[chat.id] ?? 0) > 0,
        )
        .map(
          (chat) =>
              '{id:${chat.id}, title:${chat.title}, userId:${chat.userId}, unread:${counts[chat.id] ?? 0}}',
        )
        .toList();

    debugPrint(
      '[UnreadSync][Chats][VisibleDump] total=$total chats=$visibleUnread',
    );
  }

  void _logUnreadSyncChanges(
    Map<String, int> previousCounts,
    Map<String, int> nextCounts,
  ) {
    final visibleChatIds = _visibleChatIds().toSet();
    final totalTabUnread = _calculateVisibleUnreadTotal(nextCounts);
    final changedChatIds =
        {...previousCounts.keys, ...nextCounts.keys}
            .where(
              (chatId) =>
                  visibleChatIds.contains(chatId) &&
                  (previousCounts[chatId] ?? 0) != (nextCounts[chatId] ?? 0),
            )
            .toList()
          ..sort();

    for (final chatId in changedChatIds) {
      debugPrint(
        '[UnreadSync][Chats] chatId: $chatId previous: ${previousCounts[chatId] ?? 0} new: ${nextCounts[chatId] ?? 0} totalTabUnread: $totalTabUnread',
      );
    }
  }

  void _refreshUnreadCountsFromCache() {
    // Local Hive is the source of truth when a message cache exists.
    final localCounts = ChatCacheSyncService.computeUnreadCountsSync(
      chatIds: _trackedChatIds(),
    );

    final merged = <String, int>{};
    for (final chatId in _trackedChatIds()) {
      final local = localCounts[chatId] ?? 0;
      final server = _serverUnreadCounts[chatId] ?? 0;
      if (ChatCacheSyncService.hasLocalCache(chatId)) {
        merged[chatId] = local;
      } else {
        // Bootstrap from server when we have no local message history yet.
        merged[chatId] = server;
      }
    }

    // Chats currently open: force zero regardless of cache
    for (final chatId in _activeChatIds) {
      merged[chatId] = 0;
    }

    final previousCounts = Map<String, int>.from(_unreadCounts);
    _logUnreadSyncChanges(previousCounts, merged);

    if (!mounted) {
      _unreadCounts = merged;
      _updateChatUnreadBadge();
      return;
    }

    setState(() => _unreadCounts = merged);
    _updateChatUnreadBadge();
  }

  /// Chat tab badge = private chats only (excludes groups, communities, broadcasts).
  void _updateChatUnreadBadge() {
    final total = _calculateVisibleUnreadTotal(_unreadCounts);
    ChatComponent.totalUnread.value = total;
    _debugDumpVisibleUnreadChats(_unreadCounts);
  }

  Future<void> fetchChatsFromApi() async {
    if (_isFetchingChats) return;
    _isFetchingChats = true;
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.get(
        Uri.parse(ApiStrings.getAllChat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (!mounted) {
        _isFetchingChats = false;
        return;
      }
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as List;
        final fetchedChats = decoded
            .map((e) => ChatListItem.fromJson(e))
            .toList();
        // ✅ Sync to Hive first — never wipes the existing list from memory
        await syncChatsToHive(fetchedChats);
        // ✅ Only refresh UI after Hive is updated — avoids flicker
        if (mounted) loadLocalChats();
      }
    } catch (e) {
      // ✅ Silently ignore network errors — cached list stays visible
      debugPrint("Error fetching chats (cached list remains): $e");
    } finally {
      _isFetchingChats = false;
    }
  }

  Future<void> markAllChatsAsRead() async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      debugPrint('markAllChatsAsRead error: $e');
    }
  }

  Future<void> fetchUnreadCounts({bool forceRefresh = false}) async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.get(
        Uri.parse(ApiStrings.getUnreadChatCountPerChat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List data = decoded['data'] ?? [];
        final Map<String, int> counts = {};
        for (final item in data) {
          if (item['isBroadcast'] == true || item['isCommunity'] == true) {
            continue;
          }
          final chatId = item['_id'];
          final unreadCount = item['unreadCount'] ?? 0;
          if (unreadCount > 0) counts[chatId] = unreadCount;
        }
        if (mounted) {
          _serverUnreadCounts = counts;
          _refreshUnreadCountsFromCache();
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread counts: $e');
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // ✅ Only refresh if we have a real connection — avoids log spam offline
      fetchChatsFromApi().catchError((_) {});
      fetchUnreadCounts().catchError((_) {});
      _loadArchivedChats();
      _loadBlockedUsers();
      _loadProtectedChats();
    });
    Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _loadStatusRings();
    });
  }

  Future<void> syncChatsToHive(List<ChatListItem> chats) async {
    final box = Hive.box<ChatListItemHive>('chats');
    final myId = await SaveValues().getString(AppPreferenceHelper.ID) ?? '';

    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = prefs.getStringList('pinned_chat_ids') ?? [];
    final deletedTombstones = await _loadDeletedChatTombstones();

    for (final chat in chats) {
      if (chat.isBroadcast || chat.isCommunity) continue;
      final tombstone = deletedTombstones[chat.id];
      if (tombstone is Map<String, dynamic>) {
        final previousUpdatedAt = DateTime.tryParse(
          (tombstone['updatedAt'] ?? '').toString(),
        );
        final previousLastMessageId = (tombstone['lastMessageId'] ?? '')
            .toString()
            .trim();
        final latestMessageId = chat.latestMessage?.id.toString().trim() ?? '';
        final hasNewMessage =
            latestMessageId.isNotEmpty &&
            latestMessageId != previousLastMessageId;
        final hasAdvancedTime =
            previousUpdatedAt != null &&
            chat.updatedAt.isAfter(previousUpdatedAt);
        if (!hasNewMessage && !hasAdvancedTime) {
          continue;
        }
        deletedTombstones.remove(chat.id);
      }

      final displayUser = chat.isGroupChat ? null : chat.otherUser;
      if (!chat.isGroupChat && displayUser == null) {
        debugPrint('Skipping chat ${chat.id} - invalid user data');
        continue;
      }

      final title = chat.isGroupChat
          ? chat.chatName
          : displayUser?.username ?? 'Unknown';
      final profilePicture = chat.isGroupChat
          ? chat.groupImage
          : (displayUser?.profilePicture ?? '');
      final about = displayUser?.about ?? '';

      // ✅ TICK SYNC FIX: Compute the best tick status — never downgrade.
      // The API returns stale status; socket events write the real status to Hive.
      // We keep whichever is highest: read > delivered > sent.
      String _bestStatus(String apiStatus, String? hiveStatus) {
        const rank = {'sending': 0, 'sent': 1, 'delivered': 2, 'read': 3};
        return (rank[hiveStatus ?? ''] ?? 0) > (rank[apiStatus] ?? 0)
            ? hiveStatus!
            : apiStatus;
      }

      bool _bestIsRead(bool apiIsRead, bool? hiveIsRead) {
        return apiIsRead || (hiveIsRead ?? false);
      }

      final existing = box.get(chat.id);
      // ✅ Read the existing status directly from the raw JSON — more reliable
      // than parsing through LatestMessage which may lose the status field.
      String? _existingRawStatus;
      bool? _existingRawIsRead;
      String? _existingLastMsgId;
      if (existing != null && existing.lastMessageJson.isNotEmpty) {
        try {
          final _existingDecoded =
              jsonDecode(existing.lastMessageJson) as Map<String, dynamic>;
          _existingRawStatus = _existingDecoded['status']?.toString();
          _existingRawIsRead = _existingDecoded['isRead'] as bool?;
          _existingLastMsgId =
              (_existingDecoded['_id'] ?? _existingDecoded['id'] ?? '')
                  .toString();
        } catch (_) {}
      }

      final _apiStatus = chat.latestMessage?.status ?? 'sent';
      final _apiIsRead = chat.latestMessage?.isRead ?? false;
      final _latestSenderId = chat.latestMessage?.senderId ?? '';
      final _latestIsIncoming =
          _latestSenderId.isNotEmpty && _latestSenderId != myId;
      final _sameMessage =
          _existingLastMsgId != null &&
          _existingLastMsgId!.isNotEmpty &&
          _existingLastMsgId == chat.latestMessage?.id;
      final _mergedStatus = _sameMessage
          ? _bestStatus(_apiStatus, _existingRawStatus)
          : _apiStatus;
      // Incoming previews stay unread until the user opens the chat.
      final _mergedIsRead = _latestIsIncoming
          ? false
          : (_sameMessage
                ? _bestIsRead(_apiIsRead, _existingRawIsRead)
                : _apiIsRead);

      final lastMessageJson = chat.latestMessage != null
          ? json.encode({
              '_id': chat.latestMessage!.id,
              'content': chat.latestMessage!.content,
              'senderId': chat.latestMessage!.senderId,
              'isRead': _mergedIsRead,
              'status': _mergedStatus,
              'isImage': chat.latestMessage!.isImage,
              'isVoiceNote': chat.latestMessage!.isVoiceNote,
              'isAudio': chat.latestMessage!.isAudio,
              'isVideo': chat.latestMessage!.isVideo,
              'isDocument': chat.latestMessage!.isDocument,
              'isContact': chat.latestMessage!.isContact,
              // ✅ Persist media names so preview never reverts to "attachment"
              'documentName':
                  chat.latestMessage!.content.isNotEmpty &&
                      chat.latestMessage!.isDocument
                  ? chat.latestMessage!.content
                  : null,
              'audioName':
                  chat.latestMessage!.content.isNotEmpty &&
                      (chat.latestMessage!.isAudio ||
                          chat.latestMessage!.isVoiceNote)
                  ? chat.latestMessage!.content
                  : null,
              'createdAt': chat.latestMessage!.createdAt.toIso8601String(),
            })
          : '';

      final userId = chat.isGroupChat ? '' : (displayUser?.id ?? '');
      if (!chat.isGroupChat && userId.isEmpty) {
        debugPrint('Skipping chat ${chat.id} - empty userId');
        continue;
      }

      final existingChat = box.get(chat.id);

      // Never overwrite a blocked entry — API has no blocked flag
      if (existingChat?.isBlocked == true) continue;

      final bool isPinned = pinnedIds.contains(chat.id);
      final DateTime? pinnedAt = isPinned
          ? (existingChat?.pinnedAt ?? DateTime.now())
          : null;

      final List<String> membersAvatarUrls = chat.isGroupChat
          ? chat.members
                .take(3)
                .map((m) => m.profilePicture)
                .where((url) => url.isNotEmpty)
                .toList()
          : [];

      final List<String> memberUserIds = chat.isGroupChat
          ? chat.members
                .take(3)
                .map((m) => m.id)
                .where((id) => id.isNotEmpty)
                .toList()
          : [];

      box.put(
        chat.id,
        ChatListItemHive(
          id: chat.id,
          isGroupChat: chat.isGroupChat,
          title: title,
          lastMessageJson: lastMessageJson,
          updatedAt: chat.updatedAt,
          profilePicture: profilePicture,
          about: about,
          userId: userId,
          memberCount: chat.isGroupChat ? chat.memberCount : 0,
          isBroadcast: chat.isBroadcast,
          isCommunity: chat.isCommunity,
          isArchived: existing?.isArchived ?? false,
          isMuted: existing?.isMuted ?? false,
          muteUntil: existing?.muteUntil,
          wallpaperPath: existing?.wallpaperPath,
          isPinned: isPinned,
          pinnedAt: pinnedAt,
          membersAvatarUrls: membersAvatarUrls,
          memberUserIds: memberUserIds,
        ),
      );
    }
    await _saveDeletedChatTombstones(deletedTombstones);
  }

  Future<void> clearAllCache() async {
    try {
      setState(() => isLoading = true);
      await chatBox.clear();
      await fetchChatsFromApi();
      if (!mounted) return;
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cache cleared and refreshed'),
            backgroundColor: HexColor("#1A7F4B"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _archiveChat(String chatId) async {
    try {
      final archived = await mySaveValues.getStringList(
        AppPreferenceHelper.archivedChats(),
      );
      if (!archived.contains(chatId)) {
        archived.add(chatId);
        await mySaveValues.saveStringList(
          AppPreferenceHelper.archivedChats(),
          archived,
        );
        await _loadArchivedChats();
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Chat archived'),
              backgroundColor: HexColor("#1A7F4B"),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () => _unarchiveChat(chatId),
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) messenger.hideCurrentSnackBar();
          });
        }
      }
    } catch (e) {
      debugPrint('Error archiving chat: $e');
    }
  }

  Future<void> _unarchiveChat(String chatId) async {
    try {
      final archived = await mySaveValues.getStringList(
        AppPreferenceHelper.archivedChats(),
      );
      archived.remove(chatId);
      await mySaveValues.saveStringList(
        AppPreferenceHelper.archivedChats(),
        archived,
      );
      await _loadArchivedChats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat unarchived'),
            backgroundColor: HexColor("#1A7F4B"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error unarchiving chat: $e');
    }
  }

  Future<void> _pinChat(ChatListItemHive chat) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = prefs.getStringList('pinned_chat_ids') ?? [];

    if (pinnedIds.length >= 3 && !pinnedIds.contains(chat.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only pin up to 3 chats.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final pinnedNow = DateTime.now();

    await chatBox.put(
      chat.id,
      chat.copyWith(isPinned: true, pinnedAt: pinnedNow),
    );

    if (!pinnedIds.contains(chat.id)) {
      pinnedIds.add(chat.id);
      await prefs.setStringList('pinned_chat_ids', pinnedIds);
    }

    final ok = await ChatPinService().pinChat(chatId: chat.id);

    if (!ok) {
      await chatBox.put(
        chat.id,
        chat.copyWith(isPinned: false, pinnedAt: null),
      );
      pinnedIds.remove(chat.id);
      await prefs.setStringList('pinned_chat_ids', pinnedIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pin chat. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chat pinned'),
          backgroundColor: HexColor("#1A7F4B"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _unpinChat(ChatListItemHive chat) async {
    await chatBox.put(chat.id, chat.copyWith(isPinned: false, pinnedAt: null));

    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = prefs.getStringList('pinned_chat_ids') ?? [];
    pinnedIds.remove(chat.id);
    await prefs.setStringList('pinned_chat_ids', pinnedIds);

    final ok = await ChatPinService().unpinChat(chatId: chat.id);

    if (!ok) {
      await chatBox.put(
        chat.id,
        chat.copyWith(isPinned: true, pinnedAt: chat.pinnedAt),
      );
      pinnedIds.add(chat.id);
      await prefs.setStringList('pinned_chat_ids', pinnedIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unpin chat. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chat unpinned'),
          backgroundColor: HexColor("#1A7F4B"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showChatOptions(ChatListItemHive chat) {
    final isArchived = _archivedChatIds.contains(chat.id);
    final isPinned = chat.isPinned;
    showModalBottomSheet(
      context: context,
      backgroundColor: HexColor("#1E1E1E"),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionTile(
                icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                title: isPinned ? 'Unpin chat' : 'Pin chat',
                onTap: () {
                  Navigator.pop(context);
                  isPinned ? _unpinChat(chat) : _pinChat(chat);
                },
              ),
              _buildActionTile(
                icon: isArchived ? Icons.unarchive : Icons.archive,
                title: isArchived ? "Unarchive" : "Archive",
                onTap: () {
                  Navigator.pop(context);
                  isArchived ? _unarchiveChat(chat.id) : _archiveChat(chat.id);
                },
              ),
              _buildActionTile(
                icon: Icons.delete_outline,
                title: "Delete chat",
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteChatDialog(chat);
                },
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.white, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textColor ?? Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChatDialog(ChatListItemHive chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("#2E2E2E"),
        title: Text(
          'Delete Chat',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this chat? This cannot be undone.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chat.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      final existing = chatBox.get(chatId);
      if (existing != null) {
        await _markChatDeletedTombstone(existing);
      }
      await chatBox.delete(chatId);
      final archived = await mySaveValues.getStringList(
        AppPreferenceHelper.archivedChats(),
      );
      if (archived.contains(chatId)) {
        archived.remove(chatId);
        await mySaveValues.saveStringList(
          AppPreferenceHelper.archivedChats(),
          archived,
        );
      }
      if (!mounted) return;
      loadLocalChats();
      await _loadArchivedChats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat deleted'),
            backgroundColor: HexColor("#FF6B00"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting chat: $e');
    }
  }

  @override
  void dispose() {
    _chatUpdateSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    _messageBox.listenable().removeListener(_refreshUnreadCountsFromCache);
    // ROBOT DISABLED: _robotAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    try {
      final socket = GlobalSocketService().socket;
      if (socket != null) {
        socket.off('typing', _onTypingEvent);
        socket.off('stop typing', _onStopTypingEvent);
        socket.off('recording audio', _onRecordingEvent);
        socket.off('stop recording audio', _onStopRecordingEvent);
        socket.off('messages read', _onMessagesReadEvent);
        socket.off('messages delivered', _onMessageDeliveredEvent);
        // ✅ newMessage / message received NOT removed here — never registered
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: chatBox.listenable(),
      builder: (context, _) {
        final box = chatBox;
        var chatList = box.values
            .where(
              (chat) =>
                  !_archivedChatIds.contains(chat.id) &&
                  !_protectedChatIds.contains(chat.id) &&
                  !(chat.isBroadcast) &&
                  !(chat.isCommunity) &&
                  // ✅ WhatsApp-style: show both private AND group chats
                  // Private chats require a valid userId; group chats have empty userId
                  (chat.isGroupChat || chat.userId.trim().isNotEmpty),
            )
            .toList();

        chatList.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          if (a.isPinned && b.isPinned) {
            final aPinnedAt = a.pinnedAt ?? DateTime(0);
            final bPinnedAt = b.pinnedAt ?? DateTime(0);
            return bPinnedAt.compareTo(aPinnedAt);
          }
          return b.updatedAt.compareTo(a.updatedAt);
        });

        if (widget.searchQuery.isNotEmpty) {
          chatList = chatList.where((chat) {
            final titleMatch = chat.title.toLowerCase().contains(
              widget.searchQuery,
            );
            final messageMatch =
                chat.lastMessage?.content.toLowerCase().contains(
                  widget.searchQuery,
                ) ??
                false;
            return titleMatch || messageMatch;
          }).toList();
        }

        final hasAnyChats = box.values.isNotEmpty;
        final showProtectedTile =
            _protectedChatIds.isNotEmpty && widget.searchQuery.isEmpty;

        if (chatList.isEmpty && !showProtectedTile) {
          if (widget.searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                "No chats found",
                style: GoogleFonts.poppins(
                  color: HexColor("#7A7A7A"),
                  fontSize: 14.0,
                ),
              ),
            );
          }
          if (!hasAnyChats) return buildWelcomeScreen(context);
          return Center(
            child: Text(
              "No chats found",
              style: GoogleFonts.poppins(
                color: HexColor("#7A7A7A"),
                fontSize: 14.0,
              ),
            ),
          );
        }

        final int tileOffset = showProtectedTile ? 1 : 0;

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          itemCount: chatList.length + tileOffset,
          itemBuilder: (context, index) {
            // First item = Protected Chats tile
            if (showProtectedTile && index == 0) {
              return _buildProtectedChatsTile();
            }
            return buildChatTile(chatList[index - tileOffset]);
          },
        );
      },
    );
  }

  // ── 🔒 Protected Chats tile ───────────────────────────────────────────────

  Widget _buildProtectedChatsTile() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final count = _protectedChatIds.length;

    return InkWell(
      onTap: () async {
        // If already unlocked this foreground session, go straight in
        if (_unlockedThisSession) {
          _openProtectedChatsScreen();
          return;
        }
        // Keep app in foreground during biometric auth
        bool ok = false;
        try {
          ok = await ChatLockAuthHelper.authenticate(
            context,
            reason: 'Authenticate to view your locked chats',
          );
        } catch (e) {
          debugPrint('❌ Auth error: $e');
        }

        if (!mounted) return;

        // ✅ FIX: Navigate immediately after successful auth — don't wait for lifecycle
        // Waiting for app to resume from background causes it to background unnecessarily
        if (ok) {
          setState(() => _unlockedThisSession = true);
          _openProtectedChatsScreen();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Green lock circle
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [HexColor('#1A7F4B'), HexColor('#0D5C36')],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: HexColor('#1A7F4B').withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Locked Chats ($count)',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.iconColorSubtle(isDark),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _openProtectedChatsScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProtectedChatsListScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      // Reload in case chats were unprotected from inside the list screen
      _loadProtectedChats();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // FIX 1-6: Rebuilt chat tile to match Figma exactly
  // ─────────────────────────────────────────────────────────────
  Widget buildChatTile(ChatListItemHive chat) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Adaptive colors ──────────────────────────────────────────
    final Color nameColor = isDark
        ? HexColor("#C8C9CA")
        : const Color(0xFF303030);
    final Color timeReadColor = isDark
        ? HexColor("#5F5F5F")
        : const Color(0xFF7A6A5A);
    final Color timeUnreadColor = isDark
        ? HexColor("#65D2E9")
        : const Color(0xFF1A7F4B);
    final Color subtitleReadColor = isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF5A4A3A);
    final Color subtitleUnreadColor = isDark
        ? const Color(0xFFFF6900)
        : const Color(0xFFCC5500);
    final Color scaffoldBg = isDark
        ? const Color(0xFF141414)
        : const Color(0xFFFAF5F0);
    // ─────────────────────────────────────────────────────────────

    final title = chat.title;
    final capitalisedTitle = capitalize(title);
    final lastMessage = chat.lastMessage;
    final profilePicture = chat.profilePicture;
    final about = chat.about;

    // Time shown in the list (compact format e.g. "14:33" / "Yesterday")
    final lastMessageTime = chat.lastMessage != null
        ? ChatListTimeFormatter.formatChatListTime(chat.lastMessage!.createdAt)
        : '';

    // Longer time shown when navigating into the chat
    final formattedTime = chat.lastMessage != null
        ? formatFriendlyTime(chat.lastMessage!.createdAt)
        : '';

    final userId = chat.userId;
    final unreadCount = _unreadCounts[chat.id] ?? 0;
    final isPinned = chat.isPinned;

    // Show the tile badge whenever this conversation still has unread
    // messages so the tile sum always matches the tab badge total.
    final bool hasUnread = unreadCount > 0;

    final String? activity = _liveActivity[chat.id];
    final bool isTyping = activity == 'typing';
    final bool isRecording = activity == 'recording';

    return Dismissible(
      key: ValueKey('${chat.id}_$isPinned'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        if (isPinned) {
          _unpinChat(chat);
        } else {
          _pinChat(chat);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: isPinned ? Colors.orange.shade700 : HexColor("#1A7F4B"),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              isPinned ? 'Unpin' : 'Pin',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () {
          if (userId.isEmpty && !chat.isGroupChat) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Cannot open chat - user data missing. Try refreshing.',
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Refresh',
                  textColor: Colors.white,
                  onPressed: clearAllCache,
                ),
              ),
            );
            return;
          }
          if (chat.isGroupChat) {
            // ✅ FIX: Only register as active — do NOT zero the badge before the
            // user actually sees the messages. The badge is cleared in .then()
            // after message_screen / group_screen marks messages as read.
            _activeChatIds.add(chat.id);
            final displayTitle = title
                .split(' ')
                .map(
                  (w) => w.isNotEmpty
                      ? '${w[0].toUpperCase()}${w.substring(1)}'
                      : '',
                )
                .join(' ');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupChatScreen(
                  groupId: chat.id,
                  groupName: displayTitle,
                  communityName: displayTitle,
                  memberCount: chat.memberCount,
                  groupImage: chat.profilePicture,
                ),
              ),
            ).then((_) {
              _loadProtectedChats();
              _activeChatIds.remove(chat.id);
              // Re-read Hive now that group_chat_screen has marked msgs read.
              _refreshUnreadCountsFromCache();
              fetchUnreadCounts();
            });
          } else {
            // ✅ FIX: Only register as active — do NOT zero the badge before the
            // user actually sees the messages. Badge clears in .then() after
            // message_screen.dart calls markChatAsRead() and we re-read Hive.
            _activeChatIds.add(chat.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MessageScreen(
                  chatId: chat.id,
                  username: capitalisedTitle,
                  lastSeenActive: formattedTime,
                  profilePicture: profilePicture,
                  about: about,
                  userId: userId,
                  isGroupChat: false,
                ),
              ),
            ).then((_) {
              _subscribeToSocketActivity();
              _loadProtectedChats();
              _activeChatIds.remove(chat.id);
              // Re-read Hive now that message_screen has marked msgs as read.
              _refreshUnreadCountsFromCache();
              fetchUnreadCounts();
            });
          }
        },
        onLongPress: () => _showChatOptions(chat),
        child: Column(
          children: [
            Padding(
              // FIX: consistent vertical padding so rows don't crowd
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── Avatar ──────────────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      chat.isGroupChat
                          ? GroupCompositeAvatar(
                              imageUrls: chat.membersAvatarUrls,
                              totalMemberCount: chat.memberCount,
                              size: 55,
                              userIds: chat.memberUserIds,
                              statusRings: _statusRings,
                            )
                          : _buildChatAvatar(
                              userId: userId,
                              profilePicture: profilePicture,
                              title: title,
                            ),
                      // FIX 5: pin indicator badge on avatar
                      if (isPinned)
                        Positioned(
                          bottom: 0,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: scaffoldBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.push_pin,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // ── Content column (name + message) ─────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // FIX 3: Name and time on the SAME row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // FIX 2: Name is bold
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        capitalisedTitle,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: nameColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (chat.isCurrentlyMuted) ...[
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.volume_off,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // FIX 3: Time aligned to the right of the name row
                              Text(
                                lastMessageTime,
                                style: GoogleFonts.poppins(
                                  color: hasUnread
                                      ? timeUnreadColor
                                      : timeReadColor,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 3),

                          // FIX 4 & 5: Message preview + unread badge on SAME row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) => SizedBox(
                                    width: constraints.maxWidth,
                                    child: (isTyping || isRecording)
                                        ? _buildActivityIndicator(
                                            isRecording: isRecording,
                                          )
                                        : buildSubtitle(
                                            lastMessage,
                                            isUnread: hasUnread,
                                            readColor: subtitleReadColor,
                                            unreadColor: subtitleUnreadColor,
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              if (hasUnread && !isTyping && !isRecording)
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    // FIX 5: correct unread badge color
                                    color: HexColor("#FF6900"),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
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

  Widget _buildActivityIndicator({required bool isRecording}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRecording ? Icons.mic : Icons.edit,
          size: 14,
          color: const Color(0xFFFF6900),
        ),
        const SizedBox(width: 4),
        Text(
          isRecording ? 'recording audio...' : 'typing...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF6900),
            fontSize: 13.5,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FIX 6: Status ring uses #65D2E9
  // ─────────────────────────────────────────────────────────────
  Widget _buildChatAvatar({
    required String userId,
    required String profilePicture,
    required String title,
  }) {
    final hasStatus = _statusRings.containsKey(userId);
    final hasUnviewed = _statusRings[userId] ?? false;

    final avatar = CachedProfileAvatar(
      imageUrl: profilePicture.isNotEmpty ? profilePicture : null,
      displayName: title,
      radius: 27,
      backgroundColor: HexColor("#FB8830"),
    );

    if (!hasStatus) return avatar;

    return GestureDetector(
      onTap: () async {
        final match = _cachedStatuses
            .where((s) => s.user.id == userId)
            .toList();
        if (match.isEmpty || !mounted) return;
        final allOthers = _cachedStatuses
            .where((s) => s.user.id != _myUserId)
            .toList();
        final idx = allOthers.indexWhere((s) => s.user.id == userId);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusSwiperScreen(
              allStatuses: allOthers,
              initialIndex: idx < 0 ? 0 : idx,
              isMyStatus: false,
            ),
          ),
        );
        _loadStatusRings();
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasUnviewed
              ? const LinearGradient(
                  colors: [Color(0xFF65D2E9), Color(0xFF00A8CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasUnviewed ? null : Colors.grey.shade600,
          boxShadow: hasUnviewed
              ? [
                  BoxShadow(
                    color: const Color(0xFF65D2E9).withOpacity(0.65),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF141414)
                : const Color(0xFFFAF5F0),
          ),
          child: avatar,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FIX 4: Subtitle — single line, ellipsis
  // Read  → #FFFFFF normal weight
  // Unread → #FFFFFF bold (w600)
  // ─────────────────────────────────────────────────────────────
  Widget buildSubtitle(
    LatestMessage? message, {
    bool isUnread = false,
    Color readColor = const Color(0xFF9E9E9E),
    Color unreadColor = const Color(0xFFFF6900),
  }) {
    final TextStyle baseStyle = TextStyle(
      color: isUnread ? unreadColor : readColor,
      fontSize: 13.5,
      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
    );

    if (message == null) {
      return Text(
        'No messages yet',
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final bool isSentByMe =
        _myUserId.isNotEmpty && message.senderId == _myUserId;

    String previewText;
    if (message.isImage) {
      previewText = '📷 Photo';
    } else if (message.isVoiceNote) {
      previewText = '🎙️ Voice message';
    } else if (message.isAudio) {
      previewText = '🎵 Audio';
    } else if (message.isVideo) {
      previewText = '🎥 Video';
    } else if (message.isDocument) {
      previewText = '📄 Document';
    } else if (message.isContact) {
      previewText = '👤 Contact';
    } else if (message.content.startsWith('__TRANSACTION__:')) {
      // Parse amount from the transaction string for a nicer preview
      final parts = message.content.split(':');
      final amount = parts.length >= 2 ? double.tryParse(parts[1]) : null;
      final formatted = amount != null
          ? NumberFormat('#,##0').format(amount)
          : '';
      previewText = formatted.isNotEmpty
          ? '💸 Transfer · ₦$formatted'
          : '💸 Transfer receipt';
    } else if (message.content.startsWith('__CONTACT_SHARE__:')) {
      final parts = message.content.split(':');
      final contactName = parts.length > 1 ? parts[1] : 'Contact';
      previewText = '👤 $contactName';
    } else if (message.content.startsWith('__MONEY-REQUEST__:')) {
      final parts = message.content.split(':');
      final amount = parts.length > 1 ? double.tryParse(parts[1]) : null;
      previewText = amount != null
          ? '🙏 Requested ₦${NumberFormat('#,##0').format(amount)}'
          : '🙏 Money request';
    } else {
      // For normal text messages we want a short, word-based preview.
      const int maxPreviewWords = 5;
      const int maxPreviewCharsFallback = 40;

      final raw = message.content.replaceAll('\n', ' ').trim();
      final words = raw.isEmpty
          ? <String>[]
          : raw.split(RegExp(r'\s+')).where((w) {
              final t = w.trim();
              return t.isNotEmpty;
            }).toList();

      if (words.length > maxPreviewWords) {
        previewText = '${words.take(maxPreviewWords).join(' ')}...';
      } else if (raw.length > maxPreviewCharsFallback) {
        previewText = '${raw.substring(0, maxPreviewCharsFallback)}...';
      } else {
        previewText = raw;
      }
    }

    if (isSentByMe) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildListTick(message),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              previewText,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: baseStyle,
            ),
          ),
        ],
      );
    }

    return Text(
      previewText,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: baseStyle,
    );
  }

  Widget _mediaRow(IconData icon, String label, {bool isUnread = false}) {
    // Always #FFFFFF — only weight differs between read and unread
    final color = isUnread ? const Color(0xFFFFFFFF) : const Color(0xFF9E9E9E);
    return Row(
      // mainAxisSize.max so the row fills the Expanded parent in buildChatTile
      // and the Flexible Text inside can apply ellipsis correctly
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 13.5,
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTick(LatestMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color greyColor = isDark ? Colors.white54 : const Color(0xFF8A7060);

    // ✅ TICK SYNC FIX: Read status from both sources, prefer the higher state
    // The socket writes to Hive immediately; API may be stale.
    // Status rank: read (3) > delivered (2) > sent (1) > sending (0)

    String effectiveStatus = message.status ?? 'sent';
    bool effectiveIsRead = message.isRead;

    // 1. Blue double tick = read by recipient
    if (effectiveIsRead || effectiveStatus == 'read') {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }

    // 2. Grey double tick = delivered to device but not read
    if (effectiveStatus == 'delivered') {
      return _doubleTick(color: greyColor);
    }

    // 3. Single grey tick = sent to server, not yet delivered
    return _singleTick(color: greyColor);
  }

  Widget _doubleTick({required Color color}) {
    return SizedBox(
      width: 18,
      height: 13,
      child: Stack(
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
        ],
      ),
    );
  }

  Widget _singleTick({required Color color}) {
    return SizedBox(
      width: 13,
      height: 13,
      child: Icon(Icons.check, size: 13, color: color),
    );
  }

  Widget buildWelcomeScreen(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/code_dot.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Welcome to Qiktalk Chat App",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            "Start Connecting...",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              // ROBOT DISABLED: Robot image and "Say hello to Qik AI" section hidden
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: AnimatedBuilder(
              //     animation: _robotAnimation,
              //     builder: (context, child) => Transform.translate(
              //       offset: Offset(0, _robotAnimation.value),
              //       child: child,
              //     ),
              //     child: GestureDetector(
              //       onTap: () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => AIChatScreen(initialMessage: ""),
              //         ),
              //       ),
              //       child: Image.asset(
              //         "images/robot.png",
              //         width: 175,
              //         height: 175,
              //       ),
              //     ),
              //   ),
              // ),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: Container(
              //     margin: const EdgeInsets.only(top: 70, right: 15),
              //     child: Column(
              //       children: [
              //         Text(
              //           "Say hello to Qik AI",
              //           style: GoogleFonts.poppins(
              //             color: Colors.white,
              //             fontSize: 18,
              //           ),
              //         ),
              //         GestureDetector(
              //           onTap: () => Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (_) => AIChatScreen(initialMessage: ""),
              //             ),
              //           ),
              //           child: Container(
              //             width: 170,
              //             height: 35,
              //             margin: const EdgeInsets.only(top: 10),
              //             decoration: BoxDecoration(
              //               gradient: LinearGradient(
              //                 colors: [
              //                   HexColor("#FF00A8"),
              //                   HexColor("#00D1FF"),
              //                 ],
              //               ),
              //               borderRadius: BorderRadius.circular(15),
              //             ),
              //             child: const Center(
              //               child: Text(
              //                 "Say Hello!",
              //                 style: TextStyle(
              //                   fontSize: 14,
              //                   color: Colors.white,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
