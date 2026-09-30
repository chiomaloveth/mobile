import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/group_chat/widgets/group_composite_avatar.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class _GroupRow {
  final String id;
  final String chatName;
  final String? chatImage;
  final int memberCount;
  final List<String> membersAvatarUrls;

  const _GroupRow({
    required this.id,
    required this.chatName,
    this.chatImage,
    required this.memberCount,
    this.membersAvatarUrls = const [],
  });
}

/// Bottom sheet that shows the user's existing groups that are NOT already
/// in this community, so they can be linked via PUT /chat/community/add-group.
class AddGroupToCommunitySheet extends StatefulWidget {
  final String communityId;
  final List<String> alreadyAddedIds;
  final Future<void> Function(String groupId) onGroupAdded;

  const AddGroupToCommunitySheet({
    super.key,
    required this.communityId,
    required this.alreadyAddedIds,
    required this.onGroupAdded,
  });

  @override
  State<AddGroupToCommunitySheet> createState() =>
      _AddGroupToCommunitySheetState();
}

class _AddGroupToCommunitySheetState extends State<AddGroupToCommunitySheet> {
  final _save = SaveValues();
  final _searchCtrl = TextEditingController();

  List<_GroupRow> _all = [];
  List<_GroupRow> _filtered = [];
  bool _loading = true;
  String _addingId = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
    try {
      final res = await http
          .get(
            Uri.parse(ApiStrings.getAllChat),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final List raw = jsonDecode(res.body) as List;

        // Only show: real groups (not communities, not broadcasts)
        // that aren't already in this community
        final groups = raw
            .whereType<Map<String, dynamic>>()
            .where((c) {
              final isGroup = c['isGroupChat'] == true;
              final isCom =
                  c['isCommunity'] == true || c['isCommunity'] == 'true';
              final isBroadcast = // ← exclude broadcasts
                  c['isBroadcast'] == true || c['isBroadcast'] == 'true';
              final id = c['_id'] as String? ?? '';
              return isGroup &&
                  !isCom &&
                  !isBroadcast && // ← added
                  id.isNotEmpty &&
                  !widget.alreadyAddedIds.contains(id);
            })
            .map((c) {
              final users = c['users'];
              final count = users is List ? users.length : 0;

              // Extract avatar URLs from membersPreview or users array
              List<String> avatarUrls = [];
              final preview = c['membersPreview'] ?? c['membersAvatar'];
              if (preview is List) {
                avatarUrls = (preview as List)
                    .take(3)
                    .where((m) => m is Map)
                    .map((m) => (m['profilePicture'] ?? '') as String)
                    .where((url) => url.isNotEmpty)
                    .toList();
              }
              if (avatarUrls.isEmpty && users is List) {
                avatarUrls = (users as List)
                    .take(3)
                    .where((u) => u is Map)
                    .map((u) => (u['profilePicture'] ?? '') as String)
                    .where((url) => url.isNotEmpty)
                    .toList();
              }

              return _GroupRow(
                id: c['_id'] as String? ?? '',
                chatName: c['chatName'] as String? ?? 'Group',
                chatImage:
                    c['chatImage'] as String? ?? c['groupImage'] as String?,
                memberCount: count,
                membersAvatarUrls: avatarUrls,
              );
            })
            .toList();

        if (mounted) {
          setState(() {
            _all = groups;
            _filtered = groups;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('❌ AddGroupSheet loadGroups: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
                .where(
                  (g) => g.chatName.toLowerCase().contains(q.toLowerCase()),
                )
                .toList();
    });
  }

  String _imgUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Existing Group',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: HexColor('#2A2A2A'),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search your groups...',
                  hintStyle: GoogleFonts.poppins(
                    color: HexColor('#5A5A5A'),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor('#1A7F4B'),
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _searchCtrl.text.isEmpty
                            ? 'All your groups are already in this community'
                            : 'No groups found',
                        style: GoogleFonts.poppins(
                          color: HexColor('#787880'),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildRow(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(_GroupRow group) {
    final imgUrl = _imgUrl(group.chatImage);
    final isAdding = _addingId == group.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HexColor('#2A2A2A'),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Group Composite Avatar
          group.membersAvatarUrls.isNotEmpty
              ? GroupCompositeAvatar(
                  imageUrls: group.membersAvatarUrls,
                  totalMemberCount: group.memberCount,
                  size: 55,
                )
              : Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HexColor('#3A3A3A'),
                  ),
                  child: const Icon(
                    Icons.group,
                    color: Colors.white60,
                    size: 22,
                  ),
                ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.chatName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (group.memberCount > 0)
                  Text(
                    '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(
                      color: HexColor('#787880'),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Add button
          GestureDetector(
            onTap: isAdding
                ? null
                : () async {
                    setState(() => _addingId = group.id);
                    try {
                      await widget.onGroupAdded(group.id);
                    } finally {
                      if (mounted) {
                        setState(() => _addingId = '');
                        Navigator.pop(context);
                      }
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: HexColor('#1A7F4B'),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isAdding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Add',
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
}
