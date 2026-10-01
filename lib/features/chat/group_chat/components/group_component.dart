import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qik_talk/features/status/model/my_status_model.dart';
import 'package:qik_talk/features/status/screens/status_swiper_screen.dart';
import 'package:qik_talk/features/status/services/status_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/group_composite_avatar.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../utilities/services/global_socket_service.dart';
import '../../general/model/get_chat_model.dart';
import '../../general/services/chat_cache_sync_service.dart';
import '../../general/services/protected_chats_service.dart';

// ─── Group type store ─────────────────────────────────────────────────────────
const String _kGroupTypeKey = 'qiktalk_group_type_map';

class GroupTypeStore {
  static Map<String, String> _cache = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kGroupTypeKey);
    if (raw != null) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _cache = decoded.map((k, v) => MapEntry(k, v.toString()));
    }
    _loaded = true;
  }

  static Future<void> setType(String groupId, String type) async {
    _cache[groupId] = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGroupTypeKey, json.encode(_cache));
  }

  /// Returns 'family' by default so existing groups fall into Family & Friends
  static String getType(String groupId) => _cache[groupId] ?? 'family';
}

// ─── Main GroupComponent ──────────────────────────────────────────────────────
class GroupComponent extends StatefulWidget {
  /// Reactive total unread count for group chats.
  /// Listen to this in chat_screen.dart for an always-accurate tab badge.
  static final ValueNotifier<int> totalUnread = ValueNotifier<int>(0);

  const GroupComponent({super.key});

  @override
  State<GroupComponent> createState() => _GroupComponentState();
}

class _GroupComponentState extends State<GroupComponent> {
  final GlobalSocketService _globalSocket = GlobalSocketService();

  List<ChatListItem> _chats = [];
  bool _isLoading = true;
  bool _typeStoreReady = false;
  StreamSubscription? _chatUpdateSubscription;
  Map<String, int> _unreadCounts = {};
  Map<String, int> _serverUnreadCounts = {};
  Map<String, bool> _mutedStates = {};
  static final Map<String, String> _groupNameCache = {};
  final Map<String, String> _typingTexts = {};
  static List<ChatListItem>? _cachedChats;
  Timer? _autoRefreshTimer;
  List<String> _archivedIds = [];
  late Box<ChatListItemHive> _chatBox;
  late Box<List> _messageBox;
  List<ChatListItemHive> _hiveFallbackItems = [];
  String _myUserId = '';

  List<String> _protectedChatIds = [];

  Map<String, bool> _statusRings = {};
  List<MyStatusModel> _cachedStatuses = [];

  /// Finance/category selection is temporarily disabled.
  /// Keep the state for the commented category UI below so it can be restored.
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    _chatBox = Hive.box<ChatListItemHive>('chats');
    _messageBox = Hive.box<List>('chat_messages');
    _messageBox.listenable().addListener(_refreshUnreadCountsFromCache);

    SaveValues().getString(AppPreferenceHelper.ID).then((id) {
      if (mounted) setState(() => _myUserId = id ?? '');
    });

    GroupTypeStore.load().then((_) {
      if (mounted) setState(() => _typeStoreReady = true);
    });

    if (_cachedChats != null) {
      _chats = _cachedChats!;
      _isLoading = false;
      _refresh();
    } else {
      _loadFromHive();
      _refresh();
    }
    _setupSocketListeners();
    _fetchUnreadCounts();
    _loadArchivedIds();
    _loadMutedStates();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _refresh();
        _fetchUnreadCounts();
        _loadProtectedChats();
      }
    });

    Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _loadStatusRings();
    });

    _loadStatusRings();
    _loadProtectedChats();
  }

  void _loadFromHive() {
    final hiveGroups =
        _chatBox.values
            .where(
              (c) =>
                  c.isGroupChat &&
                  !c.isBroadcast &&
                  !c.isCommunity &&
                  !_archivedIds.contains(c.id) &&
                  !_protectedChatIds.contains(c.id), // 🔒 hide protected groups
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (mounted) {
      setState(() {
        _hiveFallbackItems = hiveGroups;
        if (hiveGroups.isNotEmpty) _isLoading = false;
      });
    }
  }

  Iterable<String> _trackedGroupIds() => _chatBox.values
      .where((c) => c.isGroupChat && !c.isBroadcast && !c.isCommunity)
      .map((c) => c.id)
      .toSet();

  Iterable<String> _visibleGroupIds() => _chatBox.values
      .where(
        (chat) =>
            chat.isGroupChat &&
            !chat.isBroadcast &&
            !chat.isCommunity &&
            !_archivedIds.contains(chat.id) &&
            !_protectedChatIds.contains(chat.id),
      )
      .map((chat) => chat.id)
      .toSet();

  int _calculateVisibleUnreadTotal(Map<String, int> counts) {
    var total = 0;
    for (final chatId in _visibleGroupIds()) {
      total += counts[chatId] ?? 0;
    }
    return total;
  }

  void _logUnreadSyncChanges(
    Map<String, int> previousCounts,
    Map<String, int> nextCounts,
  ) {
    final visibleGroupIds = _visibleGroupIds().toSet();
    final totalTabUnread = _calculateVisibleUnreadTotal(nextCounts);
    final changedChatIds = {...previousCounts.keys, ...nextCounts.keys}
        .where(
          (chatId) =>
              visibleGroupIds.contains(chatId) &&
              (previousCounts[chatId] ?? 0) != (nextCounts[chatId] ?? 0),
        )
        .toList()
      ..sort();

    for (final chatId in changedChatIds) {
      debugPrint(
        '[UnreadSync][Groups] chatId: $chatId previous: ${previousCounts[chatId] ?? 0} new: ${nextCounts[chatId] ?? 0} totalTabUnread: $totalTabUnread',
      );
    }
  }

  void _refreshUnreadCountsFromCache() {
    final localCounts = ChatCacheSyncService.computeUnreadCountsSync(
      chatIds: _trackedGroupIds(),
    );

    final merged = <String, int>{};
    for (final chatId in _trackedGroupIds()) {
      final local = localCounts[chatId] ?? 0;
      final server = _serverUnreadCounts[chatId] ?? 0;
      if (ChatCacheSyncService.hasLocalCache(chatId)) {
        merged[chatId] = local;
      } else {
        merged[chatId] = server;
      }
    }

    for (final chatId in _activeGroupIds) {
      merged[chatId] = 0;
    }

    final previousCounts = Map<String, int>.from(_unreadCounts);
    _logUnreadSyncChanges(previousCounts, merged);

    if (!mounted) {
      _unreadCounts = merged;
      _updateGroupUnreadBadge();
      return;
    }

    setState(() => _unreadCounts = merged);
    _updateGroupUnreadBadge();
  }

  void _setupSocketListeners() {
    _chatUpdateSubscription = _globalSocket.chatListUpdates.listen((_) {
      if (mounted) {
        _refreshUnreadCountsFromCache();
        _refresh();
      }
    });

    final socket = _globalSocket.socket;
    if (socket == null) return;

    // ✅ Always remove before re-adding to prevent listener stacking
    socket.off('typing');
    socket.off('stop typing');
    socket.off('group updated');
    socket.off('group created');
    socket.off('chat updated');
    socket.off('messages read');
    socket.off('messages delivered');
    // ✅ newMessage NOT registered here — GlobalSocketService handles Hive writes
    // which trigger AnimatedBuilder/listenable on chatBox automatically.

    socket.on('typing', (data) {
      final chatId = data['chatId']?.toString() ?? data['room']?.toString();
      final userName =
          data['username']?.toString() ??
          data['name']?.toString() ??
          data['userName']?.toString();
      if (chatId == null || !mounted) return;
      setState(() {
        _typingTexts[chatId] = userName != null
            ? '$userName is typing...'
            : 'typing...';
      });
    });

    socket.on('stop typing', (data) {
      final chatId = data['chatId']?.toString() ?? data['room']?.toString();
      if (chatId == null || !mounted) return;
      setState(() => _typingTexts.remove(chatId));
    });

    socket.on('group updated', (data) {
      if (data['action'] == 'rename' &&
          data['newName'] != null &&
          data['groupId'] != null) {
        _groupNameCache[data['groupId'] as String] = data['newName'] as String;
        if (mounted) setState(() {});
      }
    });

    socket.on('group created', (_) {
      if (mounted) _refresh();
    });

    socket.on('chat updated', (_) {
      if (mounted) _refresh();
    });

    socket.on('messages read', (data) {
      final chatId = data['chatId']?.toString();
      if (chatId == null || !mounted) return;
      _refreshUnreadCountsFromCache();
      _updateGroupLastMessageStatus(chatId, 'read');
    });

    socket.on('messages delivered', (data) {
      final chatId = data['chatId']?.toString();
      if (chatId == null || !mounted) return;
      _updateGroupLastMessageStatus(chatId, 'delivered');
    });
  }

  /// Groups tab badge = visible group chats only (excludes private,
  /// communities, broadcasts, archived, and protected groups).
  void _updateGroupUnreadBadge() {
    GroupComponent.totalUnread.value = _calculateVisibleUnreadTotal(
      _unreadCounts,
    );
  }

  /// Updates the cached lastMessageJson status for a group tile tick indicator.
  void _updateGroupLastMessageStatus(String chatId, String status) {
    try {
      final box = Hive.box<ChatListItemHive>('chats');
      final item = box.get(chatId);
      if (item == null || item.lastMessageJson.isEmpty) return;
      final decoded = jsonDecode(item.lastMessageJson) as Map<String, dynamic>;
      final senderId = decoded['senderId']?.toString() ?? '';
      if (senderId != _myUserId) return;

      const rank = {'sending': 0, 'sent': 1, 'delivered': 2, 'read': 3};
      final currentRank = rank[decoded['status']?.toString() ?? ''] ?? 0;
      final nextRank = rank[status] ?? 0;
      if (nextRank <= currentRank) return;

      decoded['status'] = status;
      if (status == 'read') decoded['isRead'] = true;
      box.put(chatId, item.copyWith(lastMessageJson: jsonEncode(decoded)));
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Group list tick update failed: $e');
    }
  }

  Future<void> _loadArchivedIds() async {
    final ids = await SaveValues().getStringList(
      AppPreferenceHelper.archivedChats(),
    );
    if (mounted) {
      setState(() => _archivedIds = ids);
      _refreshUnreadCountsFromCache();
    }
  }

  Future<void> _loadProtectedChats() async {
    final ids = await ProtectedChatsService().getProtectedChatIds();
    if (mounted) {
      setState(() => _protectedChatIds = ids);
      _refreshUnreadCountsFromCache();
    }
  }

  final Set<String> _activeGroupIds = {};

  Future<void> _fetchUnreadCounts() async {
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
          if (item['isGroupChat'] != true) continue;
          final count = item['unreadCount'] ?? 0;
          if (count > 0) counts[item['_id']] = count;
        }
        if (mounted) {
          _serverUnreadCounts = counts;
          _refreshUnreadCountsFromCache();
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching group unread counts: $e');
    }
  }

  Future<void> _loadMutedStates() async {
    final box = Hive.box<ChatListItemHive>('chats');
    final Map<String, bool> states = {};
    for (final chat in box.values) {
      if (chat.isGroupChat) {
        states[chat.id] = chat.isCurrentlyMuted;
      }
    }
    if (mounted) setState(() => _mutedStates = states);
  }

  Future<void> _refresh() async {
    try {
      final chats = await _fetchChats();
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
      // Keep Hive in sync so offline visits show fresh data
      _loadFromHive();
      _fetchUnreadCounts();
    } catch (_) {
      // API failed — load from Hive so groups still show offline
      _loadFromHive();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<ChatListItem>> _fetchChats() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    final response = await http.get(
      Uri.parse(ApiStrings.getAllChat),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      final chats = decoded.map((e) => ChatListItem.fromJson(e)).toList();
      chats.sort((a, b) {
        final aTime = a.latestMessage?.createdAt ?? DateTime(2000);
        final bTime = b.latestMessage?.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      _cachedChats = chats;
      return chats;
    } else {
      throw Exception('Failed to load chats');
    }
  }

  String _formatLastActive(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(local.year, local.month, local.day);
    if (d == today) return DateFormat('h:mm a').format(local);
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MM/dd/yyyy').format(local);
  }

  String _buildPreviewText(String? content) {
    if (content == null || content.isEmpty) return 'No messages yet';
    if (content.startsWith('__TRANSACTION__:')) return '💸 Transfer receipt';
    final raw = content.replaceAll('\n', ' ').trim();
    final words = raw.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length > 5) return '${words.take(5).join(' ')}...';
    if (raw.length > 40) return '${raw.substring(0, 40)}...';
    return raw;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ChatListItem> get _allGroups {
    // If we have live API data, use it
    if (_chats.isNotEmpty) {
      return _chats
          .where(
            (c) =>
                c.isGroupChat &&
                !c.isCommunity &&
                !c.isBroadcast &&
                !_archivedIds.contains(c.id) &&
                !_protectedChatIds.contains(c.id), // 🔒 hide protected groups
          )
          .toList();
    }
    // Offline fallback — build from Hive cache
    return _hiveFallbackItems
        .where(
          (h) =>
              !_archivedIds.contains(h.id) && !_protectedChatIds.contains(h.id),
        )
        .map((h) {
          final dummyUser = UserSummary(
            id: '',
            username: '',
            profilePicture: '',
            isOnline: false,
          );
          return ChatListItem(
            id: h.id,
            chatName: h.title,
            isGroupChat: true,
            isCommunity: false,
            isBroadcast: false,
            currentUser: dummyUser,
            members: [],
            updatedAt: h.updatedAt,
            chatImage: h.profilePicture,
            latestMessage: h.lastMessage,
          );
        })
        .toList();
  }

  List<ChatListItem> _groupsForCategory(String cat) =>
      _allGroups.where((c) => GroupTypeStore.getType(c.id) == cat).toList();

  String _latestTimeForCategory(String cat) {
    final groups = _groupsForCategory(cat);
    DateTime? latest;
    for (final g in groups) {
      final t = g.latestMessage?.createdAt;
      if (t != null && (latest == null || t.isAfter(latest))) latest = t;
    }
    return latest != null ? _formatLastActive(latest) : '';
  }

  int _unreadForCategory(String cat) => _groupsForCategory(
    cat,
  ).fold(0, (sum, g) => sum + (_unreadCounts[g.id] ?? 0));

  Widget _doubleTick({required Color color}) => SizedBox(
    width: 18,
    height: 13,
    child: Stack(
      children: [
        Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
        Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
      ],
    ),
  );

  Widget _singleTick({required Color color}) => SizedBox(
    width: 13,
    height: 13,
    child: Icon(Icons.check, size: 13, color: color),
  );

  Widget _buildListTick(LatestMessage message) {
    if (message.isRead || message.status == 'read') {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    if (message.status == 'delivered') {
      return _doubleTick(color: Colors.white54);
    }
    return _singleTick(color: Colors.white54);
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
      debugPrint('Group status rings error: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _allGroups.isEmpty && !_typeStoreReady) {
      return Center(
        child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
      );
    }

    // Finance/category selection is temporarily disabled.
    // The Group tab now opens directly to the existing Family & Friends-style
    // group list while preserving chat loading, Hive fallback, unread counts,
    // last-message previews, and group-chat navigation.
    return _buildDefaultGroupList();

    /* Finance/category home navigation disabled temporarily.
    return WillPopScope(
      onWillPop: () async {
        if (_activeCategory != null) {
          setState(() => _activeCategory = null);
          return false;
        }
        return true;
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) {
          final isEntering = child.key == ValueKey(_activeCategory);
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: isEntering ? const Offset(1, 0) : const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          );
        },
        child: _activeCategory == null
            ? _buildHome()
            : _buildCategoryDetail(_activeCategory!),
      ),
    );
    */
  }

  Widget _buildDefaultGroupList() {
    final groups = _allGroups;

    if (_isLoading && groups.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
      );
    }

    return groups.isEmpty
        ? _buildEmptyState('family')
        : ListView.builder(
            key: const ValueKey<String>('default-groups'),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: groups.length,
            itemBuilder: (_, i) => _buildSimpleGroupTile(groups[i]),
          );
  }

  Widget _buildSimpleGroupTile(ChatListItem chat) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final rawTitle = chat.chatName.isNotEmpty ? chat.chatName : 'Unnamed Group';
    final titleCased = rawTitle
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
    final displayTitle = _groupNameCache[chat.id] ?? titleCased;

    final hiveItem = _chatBox.get(chat.id);
    final hiveMsg = hiveItem?.lastMessage;
    final apiMsg = chat.latestMessage;
    final bool hiveRicher =
        hiveMsg != null &&
        (hiveMsg.isImage ||
            hiveMsg.isVideo ||
            hiveMsg.isAudio ||
            hiveMsg.isVoiceNote ||
            hiveMsg.isDocument);
    final bool apiNoMedia =
        apiMsg == null ||
        (!apiMsg.isImage &&
            !apiMsg.isVideo &&
            !apiMsg.isAudio &&
            !apiMsg.isVoiceNote &&
            !apiMsg.isDocument);
    final LatestMessage? effectiveMsg = (hiveRicher && apiNoMedia)
        ? hiveMsg
        : (apiMsg ?? hiveMsg);

    final latestContent = effectiveMsg?.content ?? '';
    String subtitle;
    if (effectiveMsg == null) {
      subtitle = 'No messages yet';
    } else if (effectiveMsg.isVoiceNote) {
      subtitle = '🎙️ Voice message';
    } else if (effectiveMsg.isAudio) {
      subtitle = '🎵 Audio';
    } else if (effectiveMsg.isImage ||
        (latestContent.startsWith('http') &&
            (latestContent.contains('.jpg') ||
                latestContent.contains('.png') ||
                latestContent.contains('qiktalk-media')))) {
      subtitle = '📷 Photo';
    } else if (effectiveMsg.isVideo ||
        (latestContent.startsWith('http') && latestContent.contains('.mp4'))) {
      subtitle = '🎥 Video';
    } else if (effectiveMsg.isDocument) {
      subtitle = '📄 Document';
    } else if (latestContent.startsWith('__CONTACT_SHARE__:')) {
      final parts = latestContent.split(':');
      final contactName = parts.length > 1 ? parts[1] : 'Contact';
      subtitle = '👤 $contactName';
    } else if (latestContent.startsWith('__MONEY-REQUEST__:')) {
      final parts = latestContent.split(':');
      final amount = parts.length > 1 ? double.tryParse(parts[1]) : null;
      subtitle = amount != null
          ? '🙏 Requested ₦${amount.toStringAsFixed(0)}'
          : '🙏 Money request';
    } else {
      subtitle = _buildPreviewText(latestContent);
    }

    final lastActiveTime = effectiveMsg?.createdAt != null
        ? _formatLastActive(effectiveMsg!.createdAt!)
        : '';
    final unreadCount = _unreadCounts[chat.id] ?? 0;
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: () {
        // ✅ FIX: Only register as active — do NOT zero the badge before the
        // user actually sees the messages. Badge clears in .then() after
        // group_chat_screen marks messages as read and we re-read Hive.
        _activeGroupIds.add(chat.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatScreen(
              groupId: chat.id,
              groupName: displayTitle,
              communityName: displayTitle,
              memberCount: chat.memberCount,
              groupImage: chat.groupImage,
            ),
          ),
        ).then((result) {
          if (result is String && result.isNotEmpty) {
            _groupNameCache[chat.id] = result;
          }
          _loadArchivedIds();
          _activeGroupIds.remove(chat.id);
          // Re-read Hive now that group_chat_screen has marked msgs as read.
          _refreshUnreadCountsFromCache();
          _refresh();
          _fetchUnreadCounts();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupAvatar(chat),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.textPrimary(isDark),
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_mutedStates[chat.id] == true) ...[
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
                        Text(
                          lastActiveTime,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white38
                                : AppTheme.textHint(isDark),
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (effectiveMsg != null &&
                            effectiveMsg.senderId == _myUserId) ...[
                          _buildListTick(effectiveMsg),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: _typingTexts.containsKey(chat.id)
                              ? Text(
                                  _typingTexts[chat.id]!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF6900),
                                    fontSize: 13.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: hasUnread
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : AppTheme.textSecondary(isDark)),
                                    fontSize: 13.5,
                                    fontWeight: hasUnread
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 6),
                        if (hasUnread)
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: HexColor('#FF6900'),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
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
    );
  }

  // ── HOME: category cards (temporarily disabled) ───────────────────────────

  Widget _buildHome() {
    return SingleChildScrollView(
      key: const ValueKey<String?>('home'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          /* Finance group tab/counters temporarily disabled.
          _CategoryCard(
            iconBgColor: const Color(0xFF5B35C5),
            iconWidget: Image.asset(
              'images/finance_group.png',
              fit: BoxFit.contain,
            ),
            label: 'Finance',
            tagLabel: 'Finance',
            tagBg: const Color(0xFF3D2A0A),
            tagFg: const Color(0xFFE8A838),
            groupCount: _groupsForCategory('finance').length,
            lastTime: _latestTimeForCategory('finance'),
            unreadCount: _unreadForCategory('finance'),
            onTap: () => setState(() => _activeCategory = 'finance'),
          ),
          const SizedBox(height: 14),
          */
          _CategoryCard(
            iconBgColor: const Color(0xFF5B35C5),
            iconWidget: Image.asset(
              'images/family_group.png',
              fit: BoxFit.contain,
            ),
            label: 'Family Group',
            tagLabel: 'Family & Friends',
            tagBg: const Color(0xFF0D3320),
            tagFg: const Color(0xFF2ECC71),
            groupCount: _groupsForCategory('family').length,
            lastTime: _latestTimeForCategory('family'),
            unreadCount: _unreadForCategory('family'),
            onTap: () => setState(() => _activeCategory = 'family'),
          ),
        ],
      ),
    );
  }

  // ── DETAIL VIEW ───────────────────────────────────────────────────────────

  Widget _buildCategoryDetail(String category) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isFinance = category == 'finance';
    final title = isFinance ? 'Finance Groups' : 'Family & Friends';
    final groups = _groupsForCategory(category);

    return Column(
      key: ValueKey<String?>(category),
      children: [
        // Sub-header bar
        Container(
          color: isDark ? HexColor('#1A1A1A') : AppTheme.scaffoldBg(isDark),
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  size: 22,
                ),
                onPressed: () => setState(() => _activeCategory = null),
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_unreadForCategory(category) > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: HexColor('#FF6900'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_unreadForCategory(category)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: groups.isEmpty
              ? _buildEmptyState(category)
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _buildGroupTile(groups[i], category),
                ),
        ),
      ],
    );
  }

  Widget _buildGroupTile(ChatListItem chat, String category) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final rawTitle = chat.chatName.isNotEmpty ? chat.chatName : 'Unnamed Group';
    final titleCased = rawTitle
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
    final displayTitle = _groupNameCache[chat.id] ?? titleCased;

    // ── Message preview (same rich logic from existing code) ────────────────
    final hiveItem = _chatBox.get(chat.id);
    final hiveMsg = hiveItem?.lastMessage;
    final apiMsg = chat.latestMessage;

    final bool hiveRicher =
        hiveMsg != null &&
        (hiveMsg.isImage ||
            hiveMsg.isVideo ||
            hiveMsg.isAudio ||
            hiveMsg.isVoiceNote ||
            hiveMsg.isDocument);
    final bool apiNoMedia =
        apiMsg == null ||
        (!apiMsg.isImage &&
            !apiMsg.isVideo &&
            !apiMsg.isAudio &&
            !apiMsg.isVoiceNote &&
            !apiMsg.isDocument);

    final LatestMessage? effectiveMsg = (hiveRicher && apiNoMedia)
        ? hiveMsg
        : (apiMsg ?? hiveMsg);

    final latestContent = effectiveMsg?.content ?? '';
    String subtitle;
    if (effectiveMsg == null) {
      subtitle = 'No messages yet';
    } else if (effectiveMsg.isVoiceNote) {
      subtitle = '🎙️ Voice message';
    } else if (effectiveMsg.isAudio) {
      subtitle = '🎵 Audio';
    } else if (effectiveMsg.isImage ||
        (latestContent.startsWith('http') &&
            (latestContent.contains('.jpg') ||
                latestContent.contains('.png') ||
                latestContent.contains('qiktalk-media')))) {
      subtitle = '📷 Photo';
    } else if (effectiveMsg.isVideo ||
        (latestContent.startsWith('http') && latestContent.contains('.mp4'))) {
      subtitle = '🎥 Video';
    } else if (effectiveMsg.isDocument) {
      subtitle = '📄 Document';
    } else if (latestContent.startsWith('__CONTACT_SHARE__:')) {
      final parts = latestContent.split(':');
      final contactName = parts.length > 1 ? parts[1] : 'Contact';
      subtitle = '👤 $contactName';
    } else if (latestContent.startsWith('__MONEY-REQUEST__:')) {
      final parts = latestContent.split(':');
      final amount = parts.length > 1 ? double.tryParse(parts[1]) : null;
      subtitle = amount != null
          ? '🙏 Requested ₦${amount.toStringAsFixed(0)}'
          : '🙏 Money request';
    } else {
      subtitle = _buildPreviewText(latestContent);
    }

    final lastActiveTime = effectiveMsg?.createdAt != null
        ? _formatLastActive(effectiveMsg!.createdAt!)
        : '';

    // Finance-specific list tags/UI are temporarily disabled.
    // final isFinance = category == 'finance';
    // final tagLabel = isFinance ? 'Finance' : 'Family & Friends';
    // final tagBg = isFinance ? const Color(0xFF3D2A0A) : const Color(0xFF0D3320);
    // final tagFg = isFinance ? const Color(0xFFE8A838) : const Color(0xFF2ECC71);
    final tagLabel = 'Family & Friends';
    final tagBg = const Color(0xFF0D3320);
    final tagFg = const Color(0xFF2ECC71);

    return InkWell(
      onTap: () {
        // ✅ Only register as active — do NOT zero badge before messages are read.
        // Badge clears in .then() after group_chat_screen marks messages read.
        _activeGroupIds.add(chat.id);
        final nameToPass = _groupNameCache[chat.id] ?? displayTitle;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatScreen(
              groupId: chat.id,
              groupName: nameToPass,
              communityName: nameToPass,
              memberCount: chat.memberCount,
              groupImage: chat.groupImage,
            ),
          ),
        ).then((result) {
          if (result is String && result.isNotEmpty) {
            _groupNameCache[chat.id] = result;
          }
          _loadArchivedIds();
          _activeGroupIds.remove(chat.id);
          // ✅ Re-read Hive truth now that group_chat_screen marked msgs read.
          _refreshUnreadCountsFromCache();
          _refresh();
          _fetchUnreadCounts();
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 5, 16, 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? HexColor('#1A1A1A') : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar — now passes live status rings
            _buildGroupAvatar(chat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_mutedStates[chat.id] == true) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.volume_off,
                          size: 15,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tagLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: tagFg,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${chat.memberCount} members',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white54
                                : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (effectiveMsg != null &&
                          effectiveMsg.senderId == _myUserId) ...[
                        _buildListTick(effectiveMsg),
                        const SizedBox(width: 4),
                      ],
                      if (_typingTexts.containsKey(chat.id))
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 12,
                                color: const Color(0xFFFF6900),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  _typingTexts[chat.id]!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF6900),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.textSecondary(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Right column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      lastActiveTime,
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? Colors.white38
                            : AppTheme.textHint(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if ((_unreadCounts[chat.id] ?? 0) > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#FF6900'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_unreadCounts[chat.id]}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows Hive-cached group items while the API call is still in flight.
  Widget _buildHiveFallbackList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _hiveFallbackItems.length,
      itemBuilder: (context, index) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final chat = _hiveFallbackItems[index];
        final displayTitle = _groupNameCache[chat.id] ?? chat.title;
        final lastMessage = chat.lastMessage;
        String subtitle;
        if (lastMessage == null) {
          subtitle = 'No messages yet';
        } else if (lastMessage.isVoiceNote) {
          subtitle = '🎙️ Voice message';
        } else if (lastMessage.isAudio) {
          subtitle = '🎵 Audio';
        } else if (lastMessage.isImage ||
            (lastMessage.content.startsWith('http') &&
                (lastMessage.content.contains('.jpg') ||
                    lastMessage.content.contains('.png') ||
                    lastMessage.content.contains('qiktalk-media')))) {
          subtitle = '📷 Photo';
        } else if (lastMessage.isVideo ||
            (lastMessage.content.startsWith('http') &&
                lastMessage.content.contains('.mp4'))) {
          subtitle = '🎥 Video';
        } else if (lastMessage.isDocument) {
          subtitle = '📄 Document';
        } else if (lastMessage.content.startsWith('__CONTACT_SHARE__:')) {
          final parts = lastMessage.content.split(':');
          final contactName = parts.length > 1 ? parts[1] : 'Contact';
          subtitle = '👤 $contactName';
        } else {
          subtitle = _buildPreviewText(lastMessage.content);
        }
        final lastActiveTime = lastMessage != null
            ? _formatLastActive(lastMessage.createdAt)
            : '';

        return InkWell(
          onTap: () {
            // ✅ Only register as active — badge clears in .then() after read.
            _activeGroupIds.add(chat.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupChatScreen(
                  groupId: chat.id,
                  groupName: displayTitle,
                  communityName: displayTitle,
                  memberCount: chat.memberCount,
                  groupImage: chat.profilePicture,
                ),
              ),
            ).then((_) {
              _activeGroupIds.remove(chat.id);
              _refreshUnreadCountsFromCache();
              _refresh();
              _fetchUnreadCounts();
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                  child: GroupCompositeAvatar(
                    imageUrls: chat.membersAvatarUrls,
                    userIds: chat.memberUserIds,
                    totalMemberCount: chat.memberCount,
                    size: 55,
                    statusRings: const {},
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 60.0),
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? HexColor("#C8C9CA")
                                : AppTheme.textPrimary(isDark),
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (lastMessage != null &&
                              lastMessage.senderId == _myUserId) ...[
                            _buildListTick(lastMessage),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary(isDark),
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 16.0),
                  child: Text(
                    lastActiveTime,
                    style: GoogleFonts.poppins(
                      color: HexColor("#5F5F5F"),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupAvatar(ChatListItem chat) {
    final memberIds = chat.members.take(3).map((m) => m.id).toList();
    final imageUrls = chat.members
        .take(3)
        .map((m) => m.profilePicture)
        .toList();
    final totalCount = chat.members.length > chat.memberCount
        ? chat.members.length
        : chat.memberCount;

    // Check if any member has an active/unviewed status
    final bool anyUnviewed = memberIds.any(
      (id) => id != _myUserId && (_statusRings[id] ?? false),
    );
    final bool anyStatus = memberIds.any(
      (id) => id != _myUserId && _statusRings.containsKey(id),
    );

    final avatar = GroupCompositeAvatar(
      imageUrls: imageUrls,
      userIds: memberIds,
      totalMemberCount: totalCount,
      size: 55,
      statusRings: _statusRings,
    );

    // No status ring for any member — return plain avatar
    if (!anyStatus) return avatar;

    // Wrap with a coloured ring + tap to open statuses
    return GestureDetector(
      onTap: () async {
        // Find a member who has a status and open it
        final memberId = memberIds.firstWhere(
          (id) => id != _myUserId && _statusRings.containsKey(id),
          orElse: () => '',
        );
        if (memberId.isEmpty || !mounted) return;
        final allOthers = _cachedStatuses
            .where((s) => s.user.id != _myUserId)
            .toList();
        final idx = allOthers.indexWhere((s) => s.user.id == memberId);
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
          gradient: anyUnviewed
              ? const LinearGradient(
                  colors: [Color(0xFF65D2E9), Color(0xFF00A8CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: anyUnviewed ? null : Colors.grey.shade600,
          boxShadow: anyUnviewed
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF141414),
          ),
          child: avatar,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Finance-specific empty state is temporarily disabled.
    // final isFinance = category == 'finance';
    const isFinance = false;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/code_dot.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? HexColor('#1E1E1E') : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    isFinance
                        ? 'images/finance_group.png'
                        : 'images/family_group.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFinance ? 'No Finance Groups Yet' : 'No Groups Yet',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to create one',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white38 : AppTheme.textHint(isDark),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatUpdateSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    _messageBox.listenable().removeListener(_refreshUnreadCountsFromCache);

    // ✅ Remove socket listeners to prevent stacking / leaks.
    final socket = _globalSocket.socket;
    if (socket != null) {
      socket.off('typing');
      socket.off('stop typing');
      socket.off('group updated');
      socket.off('group created');
      socket.off('chat updated');
      socket.off('messages read');
      socket.off('messages delivered');
    }

    super.dispose();
  }
}

// ─── Category card widget ─────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final Color iconBgColor;
  final Widget iconWidget;
  final String label;
  final String tagLabel;
  final Color tagBg;
  final Color tagFg;
  final int groupCount;
  final String lastTime;
  final int unreadCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.iconBgColor,
    required this.iconWidget,
    required this.label,
    required this.tagLabel,
    required this.tagBg,
    required this.tagFg,
    required this.groupCount,
    required this.lastTime,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? HexColor('#1A1A1A') : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: iconWidget,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.white
                          : AppTheme.textPrimary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tagLabel,
                          style: GoogleFonts.poppins(
                            color: tagFg,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$groupCount group${groupCount == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.white54
                              : AppTheme.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (lastTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.textHint(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lastTime,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white38
                                : AppTheme.textHint(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Lock + unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#FF6900'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
