import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/composite_group_avatar.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

class AddToGroupsScreen extends StatefulWidget {
  final String username;
  final String userId;

  // ── New: when opened FROM a group to add contacts to it ──
  final String? targetGroupId;
  final String? targetGroupName;

  const AddToGroupsScreen({
    Key? key,
    required this.username,
    required this.userId,
    this.targetGroupId,
    this.targetGroupName,
  }) : super(key: key);

  /// Use this constructor when you want to add contacts TO a specific group.
  /// It opens the same screen but in reverse: pick contacts → add to group.
  const AddToGroupsScreen.forGroup({
    Key? key,
    required String groupId,
    required String groupName,
  }) : username = groupName,
       userId = '',
       targetGroupId = groupId,
       targetGroupName = groupName,
       super(key: key);

  @override
  State<AddToGroupsScreen> createState() => _AddToGroupsScreenState();
}

class _AddToGroupsScreenState extends State<AddToGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GroupApiService _groupApiService = GroupApiService();
  final SaveValues _saveValues = SaveValues();
  final GlobalSocketService _globalSocket = GlobalSocketService();

  String searchQuery = '';
  List<GroupModel> groups = [];
  List<GroupModel> filteredGroups = [];
  bool isLoading = true;
  String? currentUserId;
  // Tracks which member IDs were just added in forGroup mode
  final Set<String> _addedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadGroups();
    _setupSocketListeners();
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId = await _saveValues.getString(AppPreferenceHelper.ID);
    if (mounted) setState(() {});
  }

  void _setupSocketListeners() {
    _globalSocket.chatListUpdates.listen((_) {
      if (mounted) _loadGroups();
    });
  }

  Future<void> _loadGroups() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.get(
        Uri.parse(ApiStrings.getAllChat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📋 getAllChat status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);

        // Filter only group chats and parse them
        final groupChats = <GroupModel>[];
        for (final chat in decoded) {
          if (chat['isGroupChat'] != true) continue;

          final map = chat as Map<String, dynamic>;
          print(
            '📋 Group "${map["chatName"]}" users:${(map["users"] as List?)?.length ?? "null"} admins:${(map["groupAdmin"] as List?)?.length ?? "null"} memberCount:${map["memberCount"]}',
          );

          final group = GroupModel.fromJson(map);
          print('📋 Parsed memberCount: ${group.memberCount}');
          groupChats.add(group);
        }

        if (mounted) {
          setState(() {
            groups = groupChats;
            filteredGroups = groupChats;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading groups: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<GroupModel> get displayGroups {
    if (searchQuery.isEmpty) return filteredGroups;
    return filteredGroups.where((group) {
      return group.chatName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _addUserToGroup(GroupModel group) async {
    // ── MODE A: normal flow — add widget.userId to this group ──
    if (widget.targetGroupId == null) {
      final isAlreadyMember = group.users.any(
        (user) => user.id == widget.userId,
      );

      if (isAlreadyMember) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.username} is already in this group'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
          ),
        ),
      );

      try {
        final response = await _groupApiService.addUserToGroup(
          groupId: group.id,
          userId: widget.userId,
        );

        if (!mounted) return;
        Navigator.pop(context);

        if (response?.success == true) {
          if (response?.group != null) {
            setState(() {
              final index = groups.indexWhere((g) => g.id == group.id);
              if (index != -1) groups[index] = response!.group!;
              filteredGroups = groups;
            });
          } else {
            await _loadGroups();
          }

          _globalSocket.emit('group updated', {
            'groupId': group.id,
            'action': 'member_added',
            'userId': widget.userId,
            'addedBy': currentUserId,
          });

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response?.message ??
                      '${widget.username} added to ${group.chatName}',
                ),
                backgroundColor: const Color(0xFF1A7F4B),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response?.message ?? 'Failed to add user to group',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Error adding user: $e');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    // ── MODE B: reverse flow — add this group's member to widget.targetGroupId ──
    // In this mode `group` is actually a contact-group we show,
    // but we treat the group list as contacts list. This branch is not
    // used in forGroup mode — see _addContactToThisGroup() below.
  }

  // ── Called in forGroup mode: user tapped a contact row ──────────────────
  Future<void> _addContactToThisGroup(String userId, String username) async {
    if (widget.targetGroupId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: HexColor('#1A7F4B'))),
    );

    try {
      final response = await _groupApiService.addUserToGroup(
        groupId: widget.targetGroupId!,
        userId: userId,
      );

      if (!mounted) return;
      Navigator.pop(context); // close spinner

      if (response?.success == true) {
        _globalSocket.emit('group updated', {
          'groupId': widget.targetGroupId,
          'action': 'member_added',
          'userId': userId,
          'addedBy': currentUserId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$username added to ${widget.targetGroupName}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A7F4B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Refresh so the button shows "Added"
        await _loadGroups();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?.message ?? 'Failed to add $username',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Column(
        children: [
          // AppBar
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
                      color: Color(0xFF2A2A2A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.targetGroupId != null
                              ? 'Add Members'
                              : widget.username,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.targetGroupId != null)
                          Text(
                            widget.targetGroupName ?? '',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Video call feature'),
                            backgroundColor: HexColor("#FF6B00"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.videocam_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Voice call feature'),
                            backgroundColor: HexColor("#FF6B00"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.call_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.targetGroupId != null
                    ? 'Select contacts to add'
                    : 'Add to Groups',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (mounted) setState(() => searchQuery = value);
                },
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    color: Color(0xFF787880),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF787880),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Create New Group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateNewGroupScreen()),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF1A7F4B), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Create new group',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF1A7F4B),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // Groups List
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A7F4B)),
                  )
                : displayGroups.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.isEmpty ? 'No groups yet' : 'No groups found',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: displayGroups.length,
                    itemBuilder: (context, index) {
                      final group = displayGroups[index];
                      return _buildGroupItem(group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(GroupModel group) {
    // ── forGroup mode: show group members as contacts to add ────────────────
    // In this mode the list shows OTHER groups' members so you can
    // pick someone and add them to widget.targetGroupId.
    // But actually in forGroup mode we show the SAME groups list and
    // each row's "Add" button adds that group's first non-member to the target.
    // Simpler UX: show the group row and let user tap Add to add all members.

    if (widget.targetGroupId != null) {
      // In forGroup mode: each group row = "add all members of this group"
      // Instead show a flat member list from the groups already loaded.
      // We repurpose the group card to show members of each group.
      final members = group.users;
      if (members.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              group.chatName,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...members.map((member) {
            final alreadyAdded = _addedMemberIds.contains(member.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: HexColor('#2A2A2A'),
                    backgroundImage:
                        member.profilePicture != null &&
                            member.profilePicture!.isNotEmpty
                        ? NetworkImage(member.profilePicture!)
                        : null,
                    child:
                        member.profilePicture == null ||
                            member.profilePicture!.isEmpty
                        ? Text(
                            member.username.isNotEmpty
                                ? member.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      member.username,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: alreadyAdded
                        ? null
                        : () async {
                            await _addContactToThisGroup(
                              member.id,
                              member.username,
                            );
                            if (mounted) {
                              setState(() => _addedMemberIds.add(member.id));
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: alreadyAdded
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFF1A7F4B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        alreadyAdded ? 'Added' : 'Add',
                        style: GoogleFonts.poppins(
                          color: alreadyAdded
                              ? const Color(0xFF787880)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      );
    }

    // ── Normal mode: add widget.userId to this group ─────────────────────
    final isAlreadyMember = group.users.any((user) => user.id == widget.userId);
    final count = group.memberCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          group.users.isNotEmpty
              ? CompositeGroupAvatar(
                  members: group.users,
                  avatarRadius: 16,
                  overlap: 10,
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A2A2A),
                  ),
                  child: const Icon(Icons.group, color: Colors.white, size: 24),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.chatName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count > 0 ? '$count members' : 'Group',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF787880),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isAlreadyMember ? null : () => _addUserToGroup(group),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isAlreadyMember
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFF1A7F4B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAlreadyMember ? 'Added' : 'Add',
                style: GoogleFonts.poppins(
                  color: isAlreadyMember
                      ? const Color(0xFF787880)
                      : Colors.white,
                  fontSize: 14,
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
