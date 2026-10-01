import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MembersListScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const MembersListScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  final GroupApiService _apiService = GroupApiService();
  final SaveValues _saveValues = SaveValues();

  List<GroupMember> _members = [];
  List<String> _adminIds = [];
  String _currentUserId = '';
  bool _isCurrentUserAdmin = false;
  bool _isLoading = false; // never block — load from cache first
  String? _error;

  static const String _membersCachePrefix = 'group_members_cache_';

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  List<GroupMember> get _filteredMembers => _searchQuery.isEmpty
      ? _members
      : _members
            .where(
              (m) =>
                  m.username.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  (m.phoneNumber ?? '').contains(_searchQuery),
            )
            .toList();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCachedMembers(); // instant, no network
    _fetchMembers(); // silent background refresh
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  /// Load members from SharedPreferences cache — works fully offline.
  Future<void> _loadCachedMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_membersCachePrefix${widget.groupId}');
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final membersJson = data['members'] as List<dynamic>? ?? [];
      final adminIds = List<String>.from(data['adminIds'] as List? ?? []);

      // Reconstruct GroupMember from cached simple map
      final members = membersJson
          .map((m) {
            final map = m as Map<String, dynamic>;
            return GroupMember(
              id: map['id'] as String? ?? '',
              username: map['username'] as String? ?? '',
              profilePicture: map['profilePicture'] as String?,
              phoneNumber: map['phoneNumber'] as String?,
              isOnline: map['isOnline'] as bool? ?? false,
            );
          })
          .where((m) => m.id.isNotEmpty)
          .toList();

      if (members.isNotEmpty && mounted) {
        setState(() {
          _members = members;
          _adminIds = adminIds;
          _isCurrentUserAdmin = adminIds.contains(_currentUserId);
        });
        debugPrint('✅ Loaded ${members.length} members from cache');
      }
    } catch (e) {
      debugPrint('❌ _loadCachedMembers: $e');
    }
  }

  /// Save members to SharedPreferences for offline access.
  Future<void> _saveMembersToCache(
    List<GroupMember> members,
    List<String> adminIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store each member as a simple map — no dependency on toJson()
      final membersData = members
          .map(
            (m) => {
              'id': m.id,
              'username': m.username,
              'profilePicture': m.profilePicture ?? '',
              'phoneNumber': m.phoneNumber ?? '',
              'isOnline': m.isOnline ?? false,
            },
          )
          .toList();

      final data = jsonEncode({
        'members': membersData,
        'adminIds': adminIds,
        'cachedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString('$_membersCachePrefix${widget.groupId}', data);
    } catch (e) {
      debugPrint('❌ _saveMembersToCache: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _saveValues.getString(AppPreferenceHelper.ID) ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _fetchMembers() async {
    if (!mounted) return;
    // Don't set _isLoading = true if we already have cached members
    // Only show loading if we have absolutely nothing to display
    if (_members.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _apiService.getGroupMembers(groupId: widget.groupId);

      if (!mounted) return;

      if (result != null) {
        List<String> adminIds = result.adminIds;

        if (adminIds.isEmpty) {
          final group = await _apiService.getGroupProfile(
            groupId: widget.groupId,
          );
          if (group != null) {
            adminIds = group.groupAdmins.map((a) => a.id).toList();
          }
        }

        setState(() {
          _members = result.members;
          _adminIds = adminIds;
          _isCurrentUserAdmin = adminIds.contains(_currentUserId);
          _isLoading = false;
          _error = null;
        });

        // ── Save to cache for next offline visit ──────────────────────────
        await _saveMembersToCache(result.members, adminIds);
      } else {
        // API failed — keep showing cached data, only show error if empty
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (_members.isEmpty) {
              _error = 'Failed to load members. Tap to retry.';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_members.isEmpty) {
            _error = 'Failed to load members. Tap to retry.';
          }
        });
      }
    }
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  bool _isAdmin(String userId) => _adminIds.contains(userId);

  // ─── Called by bottom sheet on success to update state locally ───
  void _onMemberRemoved(String userId) {
    setState(() {
      _members.removeWhere((m) => m.id == userId);
      _adminIds.remove(userId);
    });
  }

  void _onAdminGranted(String userId) {
    if (!_adminIds.contains(userId)) {
      setState(() => _adminIds.add(userId));
    }
  }

  void _onAdminRevoked(String userId) {
    setState(() => _adminIds.remove(userId));
  }

  // ─── Show member info as bottom sheet ───────────────────────────
  void _openMemberBottomSheet(GroupMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MemberBottomSheet(
        member: member,
        groupId: widget.groupId,
        isCurrentUserAdmin: _isCurrentUserAdmin,
        isMemberAdmin: _isAdmin(member.id),
        isCurrentUser: member.id == _currentUserId,
        getFullImageUrl: _getFullImageUrl,
        onMemberRemoved: (uid) {
          _onMemberRemoved(uid);
          Navigator.pop(context);
        },
        onAdminGranted: _onAdminGranted,
        onAdminRevoked: _onAdminRevoked,
        saveValues: _saveValues,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#1A1A1A'),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HexColor('#2A2A2A'),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!_isLoading)
                  Text(
                    '${_filteredMembers.length} member${_filteredMembers.length == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            child: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: Colors.white54,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_showSearch) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#2A2A2A'),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          cursorColor: HexColor('#1A7F4B'),
          decoration: InputDecoration(
            hintText: 'Search members...',
            hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _members.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: HexColor('#1A7F4B'),
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: GestureDetector(
          onTap: _fetchMembers,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white38, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredMembers.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No members found'
              : 'No results for "$_searchQuery"',
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMembers,
      color: HexColor('#1A7F4B'),
      backgroundColor: HexColor('#2A2A2A'),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredMembers.length,
        itemBuilder: (context, index) {
          return _buildMemberTile(_filteredMembers[index]);
        },
      ),
    );
  }

  Widget _buildMemberTile(GroupMember member) {
    final isAdmin = _isAdmin(member.id);
    final isMe = member.id == _currentUserId;
    final imageUrl = _getFullImageUrl(member.profilePicture);

    // Determine role label — first admin in list is treated as Creator
    String? roleLabel;
    if (_adminIds.isNotEmpty && _adminIds.first == member.id) {
      roleLabel = 'Creator';
    } else if (isAdmin) {
      roleLabel = 'Moderator';
    }

    return GestureDetector(
      onTap: () => _openMemberBottomSheet(member),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HexColor('#2A2A2A'),
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarFallback(member.username),
                          )
                        : _buildAvatarFallback(member.username),
                  ),
                ),
                // Online indicator
                if (member.isOnline == true)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: HexColor('#1A7F4B'),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#1A1A1A'),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Name
            Expanded(
              child: Text(
                isMe ? '${member.username} (You)' : member.username,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Role badge + chevron
            if (roleLabel != null) ...[
              Text(
                roleLabel,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ] else
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String username) {
    return Container(
      color: HexColor('#3A3A3A'),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER BOTTOM SHEET
// Shown instead of navigating to MemberInfoScreen
// ─────────────────────────────────────────────────────────────────────────────

class _MemberBottomSheet extends StatefulWidget {
  final GroupMember member;
  final String groupId;
  final bool isCurrentUserAdmin;
  final bool isMemberAdmin;
  final bool isCurrentUser;
  final String Function(String?) getFullImageUrl;
  final void Function(String) onMemberRemoved;
  final void Function(String) onAdminGranted;
  final void Function(String) onAdminRevoked;
  final SaveValues saveValues;

  const _MemberBottomSheet({
    required this.member,
    required this.groupId,
    required this.isCurrentUserAdmin,
    required this.isMemberAdmin,
    required this.isCurrentUser,
    required this.getFullImageUrl,
    required this.onMemberRemoved,
    required this.onAdminGranted,
    required this.onAdminRevoked,
    required this.saveValues,
  });

  @override
  State<_MemberBottomSheet> createState() => _MemberBottomSheetState();
}

class _MemberBottomSheetState extends State<_MemberBottomSheet> {
  final GroupApiService _apiService = GroupApiService();
  bool _isMemberAdmin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isMemberAdmin = widget.isMemberAdmin;
  }

  void _showSnack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color ?? HexColor('#1A7F4B'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _messageUser() async {
    setState(() => _isLoading = true);
    try {
      final token = await widget.saveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Try to find existing DM
      String? chatId;
      final listResp = await http.get(
        Uri.parse(ApiStrings.getAllChat),
        headers: headers,
      );
      if (listResp.statusCode == 200) {
        final List chats = jsonDecode(listResp.body) as List;
        for (final chat in chats) {
          final map = chat as Map<String, dynamic>;
          if (map['isGroupChat'] == true) continue;
          final id = map['_id'] as String?;
          if (id == null) continue;
          final otherUser = map['otherUser'];
          if (otherUser is Map && otherUser['_id'] == widget.member.id) {
            chatId = id;
            break;
          }
          final users = map['users'];
          if (users is List &&
              users.any(
                (u) =>
                    (u is Map && u['_id'] == widget.member.id) ||
                    u == widget.member.id,
              )) {
            chatId = id;
            break;
          }
        }
      }

      // Create DM if not found
      if (chatId == null) {
        final r = await http.post(
          Uri.parse('${ApiStrings.baseUri}chat'),
          headers: headers,
          body: jsonEncode({
            'users': [widget.member.id],
          }),
        );
        if (r.statusCode == 200 || r.statusCode == 201) {
          final data = jsonDecode(r.body) as Map<String, dynamic>;
          chatId =
              data['_id'] as String? ??
              (data['data'] is Map
                  ? (data['data'] as Map)['_id'] as String?
                  : null);
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (chatId != null) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageScreen(
              chatId: chatId!,
              userId: widget.member.id,
              username: widget.member.username,
              lastSeenActive: '',
              profilePicture: widget.member.profilePicture ?? '',
              about: '',
              isGroupChat: false,
            ),
          ),
        );
      } else {
        _showSnack('Could not open conversation', color: Colors.red);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnack('Error: $e', color: Colors.red);
    }
  }

  Future<void> _makeAdmin() async {
    setState(() => _isLoading = true);
    final res = await _apiService.makeUserAdmin(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res?.success == true) {
      setState(() => _isMemberAdmin = true);
      widget.onAdminGranted(widget.member.id);
      _showSnack('${widget.member.username} is now a moderator');
    } else if (res?.statusCode == 403) {
      _showSnack("You don't have permission to do this", color: Colors.orange);
    } else {
      _showSnack(res?.message ?? 'Failed', color: Colors.red);
    }
  }

  Future<void> _removeAdmin() async {
    setState(() => _isLoading = true);
    final res = await _apiService.removeAdmin(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res?.success == true) {
      setState(() => _isMemberAdmin = false);
      widget.onAdminRevoked(widget.member.id);
      _showSnack('Moderator role removed from ${widget.member.username}');
    } else {
      _showSnack(res?.message ?? 'Failed', color: Colors.red);
    }
  }

  Future<void> _removeFromGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor('#2A2A2A'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Member',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove ${widget.member.username} from this group?',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Remove',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final res = await _apiService.removeUserFromGroup(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res?.success == true) {
      _showSnack('${widget.member.username} removed');
      widget.onMemberRemoved(widget.member.id);
    } else if (res?.statusCode == 403) {
      _showSnack('Only admins can remove members', color: Colors.orange);
    } else {
      _showSnack(res?.message ?? 'Failed to remove', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.getFullImageUrl(widget.member.profilePicture);

    return Container(
      decoration: BoxDecoration(
        color: HexColor('#1E1E1E'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Close button ──
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: HexColor('#2A2A2A'),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Avatar ──
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HexColor('#2A2A2A'),
                  border: Border.all(color: HexColor('#2A2A2A'), width: 3),
                ),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _avatarFallback(widget.member.username, 28),
                        )
                      : _avatarFallback(widget.member.username, 28),
                ),
              ),

              const SizedBox(height: 12),

              // ── Name ──
              Text(
                widget.member.username,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // ── Phone ──
              if (widget.member.phoneNumber != null &&
                  widget.member.phoneNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.member.phoneNumber!,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Quick action buttons ──
              if (!widget.isCurrentUser)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(
                      icon: Icons.message_outlined,
                      label: 'Message',
                      onTap: _messageUser,
                    ),
                    const SizedBox(width: 24),
                    _actionButton(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onTap: () {
                        Navigator.pop(context);
                        // Initiate audio call
                      },
                    ),
                    const SizedBox(width: 24),
                    _actionButton(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        // Initiate video call
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // ── Menu items ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: HexColor('#2A2A2A'),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Info row
                    _menuRow(
                      label: 'Info',
                      icon: Icons.info_outline,
                      iconColor: Colors.white70,
                      onTap: () {
                        // Navigate to full info screen if needed
                        Navigator.pop(context);
                      },
                    ),

                    // Admin actions (only shown to admins, not for current user)
                    if (widget.isCurrentUserAdmin && !widget.isCurrentUser) ...[
                      _divider(),
                      if (!_isMemberAdmin)
                        _menuRow(
                          label: 'Make group moderator',
                          icon: Icons.person_add_alt_1_outlined,
                          iconColor: Colors.white70,
                          onTap: _makeAdmin,
                        ),
                      if (_isMemberAdmin)
                        _menuRow(
                          label: 'Remove moderator role',
                          icon: Icons.remove_moderator_outlined,
                          iconColor: Colors.orange,
                          labelColor: Colors.orange,
                          onTap: _removeAdmin,
                        ),
                      _divider(),
                      _menuRow(
                        label: 'Remove from group',
                        icon: Icons.remove_circle_outline,
                        iconColor: Colors.red,
                        labelColor: Colors.red,
                        onTap: _removeFromGroup,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: HexColor('#2A2A2A'),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required String label,
    required IconData icon,
    Color? iconColor,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: labelColor ?? Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(icon, color: iconColor ?? Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: HexColor('#3A3A3A'));

  Widget _avatarFallback(String username, double fontSize) {
    return Container(
      color: HexColor('#3A3A3A'),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
