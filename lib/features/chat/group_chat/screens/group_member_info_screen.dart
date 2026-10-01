import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/calls/call_permission_handler.dart';
import 'package:qik_talk/features/calls/ongoing_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

class MemberInfoScreen extends ConsumerStatefulWidget {
  final GroupMember member;
  final String groupId;
  final bool isCurrentUserAdmin;
  final bool isMemberAdmin;
  final bool isCurrentUser;
  final void Function(String userId) onMemberRemoved;
  final void Function(String userId) onAdminGranted;
  final void Function(String userId) onAdminRevoked;

  const MemberInfoScreen({
    super.key,
    required this.member,
    required this.groupId,
    required this.isCurrentUserAdmin,
    required this.isMemberAdmin,
    required this.isCurrentUser,
    required this.onMemberRemoved,
    required this.onAdminGranted,
    required this.onAdminRevoked,
  });

  @override
  ConsumerState<MemberInfoScreen> createState() => _MemberInfoScreenState();
}

class _MemberInfoScreenState extends ConsumerState<MemberInfoScreen> {
  final GroupApiService _apiService = GroupApiService();
  final SaveValues _saveValues = SaveValues();

  bool _isMemberAdmin = false;
  bool _isLoading = false;

  String _myUserId = '';
  String _myUsername = '';
  String _authToken = ''; // ✅ added to store auth token

  @override
  void initState() {
    super.initState();
    _isMemberAdmin = widget.isMemberAdmin;
    _loadCurrentUser();
    debugPrint('📱 member id: ${widget.member.id}');
    debugPrint('📱 member username: ${widget.member.username}');
    debugPrint('📱 member phone: ${widget.member.phoneNumber}');
    debugPrint('📱 member profilePic: ${widget.member.profilePicture}');
  }

  Future<void> _loadCurrentUser() async {
    _myUserId = await _saveValues.getString(AppPreferenceHelper.ID) ?? '';
    _myUsername =
        await _saveValues.getString(AppPreferenceHelper.USER_NAME) ?? '';
    // ✅ Load auth token alongside user info
    _authToken =
        await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
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

  void _showLoading() => setState(() => _isLoading = true);
  void _hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MESSAGE USER
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _messageUser() async {
    _showLoading();
    try {
      final chatId = await _getOrCreateDMChatId(widget.member.id);
      if (!mounted) return;
      _hideLoading();

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatId,
            userId: widget.member.id,
            username: widget.member.username,
            lastSeenActive: '',
            profilePicture: widget.member.profilePicture ?? '',
            about: '',
            isGroupChat: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _hideLoading();
      _showSnack('Could not open conversation: $e', color: Colors.red);
    }
  }

  Future<String> _getOrCreateDMChatId(String targetUserId) async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final listResp = await http.get(
        Uri.parse(ApiStrings.getAllChat),
        headers: headers,
      );
      if (listResp.statusCode == 200) {
        final List chats = jsonDecode(listResp.body) as List;
        for (final chat in chats) {
          final map = chat as Map<String, dynamic>;
          if (map['isGroupChat'] == true) continue;
          final chatId = map['_id'] as String?;
          if (chatId == null || chatId.isEmpty) continue;

          final otherUser = map['otherUser'];
          if (otherUser is Map && otherUser['_id'] == targetUserId)
            return chatId;

          final users = map['users'];
          if (users is List && _listContainsUser(users, targetUserId))
            return chatId;

          final members = map['members'];
          if (members is List && _listContainsUser(members, targetUserId))
            return chatId;
        }
      }
    } catch (e) {
      print('⚠️ Chat search error: $e — proceeding to create');
    }

    final r1 = await http.post(
      Uri.parse('${ApiStrings.baseUri}chat'),
      headers: headers,
      body: jsonEncode({
        'users': [targetUserId],
      }),
    );
    if (r1.statusCode == 200 || r1.statusCode == 201) {
      final id = _parseChatId(r1.body);
      if (id != null && id.isNotEmpty) return id;
    }

    final r2 = await http.post(
      Uri.parse('${ApiStrings.baseUri}chat'),
      headers: headers,
      body: jsonEncode({'userId': targetUserId}),
    );
    if (r2.statusCode == 200 || r2.statusCode == 201) {
      final id = _parseChatId(r2.body);
      if (id != null && id.isNotEmpty) return id;
    }

    String errMsg = 'Failed to open chat';
    try {
      errMsg = (jsonDecode(r1.body) as Map)['message'] as String? ?? errMsg;
    } catch (_) {}
    throw Exception(errMsg);
  }

  bool _listContainsUser(List list, String targetId) {
    return list.any((u) {
      if (u is Map) return u['_id'] == targetId;
      if (u is String) return u == targetId;
      return false;
    });
  }

  String? _parseChatId(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['_id'] as String? ??
          (data['data'] is Map
              ? (data['data'] as Map<String, dynamic>)['_id'] as String?
              : null) ??
          (data['chat'] is Map
              ? (data['chat'] as Map<String, dynamic>)['_id'] as String?
              : null);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INITIATE CALL
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _initiateCall({required bool isVideo}) async {
    try {
      final hasPermission = isVideo
          ? await CallPermissionHandler.requestVideoPermissions(context)
          : await CallPermissionHandler.requestAudioPermissions(context);

      if (!hasPermission) return;

      final globalSocket = GlobalSocketService();
      if (!globalSocket.isConnected) await globalSocket.connect();

      final socket = globalSocket.socket;
      if (socket == null) {
        _showSnack('Connection failed. Please try again.', color: Colors.red);
        return;
      }

      // ✅ FIX: pass authToken — it is required by initializeWithSocket
      // _authToken is loaded in _loadCurrentUser() during initState
      final callNotifier = ref.read(callStateProvider.notifier);
      callNotifier.initializeWithSocket(
        socket,
        myUserId: _myUserId,
        myUsername: _myUsername,
        authToken: _authToken, // ✅ was missing before
      );

      await callNotifier.startCall(
        userId: widget.member.id,
        userName: widget.member.username,
        userPhoto: widget.member.profilePicture ?? '',
        isVideo: isVideo,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OngoingCallScreen()),
        );
      }
    } catch (e) {
      debugPrint('❌ Call error: $e');
      if (mounted) _showSnack('Failed to start call: $e', color: Colors.red);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MAKE / REMOVE ADMIN
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _makeAdmin() async {
    final confirmed = await _showConfirmDialog(
      title: 'Make Admin',
      message:
          'Make ${widget.member.username} an admin? They will be able to add/remove members.',
      confirmLabel: 'Make Admin',
      confirmColor: HexColor('#1A7F4B'),
    );
    if (!confirmed) return;

    _showLoading();
    final res = await _apiService.makeUserAdmin(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    _hideLoading();

    if (res?.success == true) {
      setState(() => _isMemberAdmin = true);
      widget.onAdminGranted(widget.member.id);
      _showSnack('${widget.member.username} is now an admin');
    } else if (res?.statusCode == 403) {
      _showSnack("You don't have permission to do this", color: Colors.orange);
    } else {
      _showSnack(res?.message ?? 'Failed to make admin', color: Colors.red);
    }
  }

  Future<void> _removeAdmin() async {
    final confirmed = await _showConfirmDialog(
      title: 'Remove Admin',
      message: 'Remove admin role from ${widget.member.username}?',
      confirmLabel: 'Remove Admin',
      confirmColor: Colors.orange,
    );
    if (!confirmed) return;

    _showLoading();
    final res = await _apiService.removeAdmin(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    _hideLoading();

    if (res?.success == true) {
      setState(() => _isMemberAdmin = false);
      widget.onAdminRevoked(widget.member.id);
      _showSnack('Admin role removed from ${widget.member.username}');
    } else if (res?.statusCode == 403) {
      _showSnack("You don't have permission to do this", color: Colors.orange);
    } else {
      _showSnack(res?.message ?? 'Failed to remove admin', color: Colors.red);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REMOVE FROM GROUP
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _removeFromGroup() async {
    final confirmed = await _showConfirmDialog(
      title: 'Remove Member',
      message:
          'Remove ${widget.member.username} from this group? They will lose access to all group messages.',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
      isDangerous: true,
    );
    if (!confirmed) return;

    _showLoading();
    final res = await _apiService.removeUserFromGroup(
      groupId: widget.groupId,
      userId: widget.member.id,
    );
    _hideLoading();

    if (res?.success == true) {
      widget.onMemberRemoved(widget.member.id);
      _showSnack('${widget.member.username} removed from group');
      if (mounted) Navigator.pop(context);
    } else if (res?.statusCode == 403) {
      _showSnack('Only admins can remove members', color: Colors.orange);
    } else {
      _showSnack(res?.message ?? 'Failed to remove member', color: Colors.red);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CONFIRM DIALOG
  // ─────────────────────────────────────────────────────────────────────────────

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor('#2A2A2A'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
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
              confirmLabel,
              style: GoogleFonts.poppins(
                color: confirmColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getFullImageUrl(widget.member.profilePicture);

    return Scaffold(
      backgroundColor: HexColor('#1A1A1A'),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProfileSection(imageUrl),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  if (!widget.isCurrentUser) ...[
                    const SizedBox(height: 8),
                    _buildAdminActions(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          Text(
            'Member Info',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HexColor('#2A2A2A'),
              border: Border.all(
                color: _isMemberAdmin
                    ? HexColor('#1A7F4B')
                    : HexColor('#3A3A3A'),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarFallback(
                        widget.member.username,
                        size: 40,
                      ),
                    )
                  : _buildAvatarFallback(widget.member.username, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isCurrentUser
                ? '${widget.member.username} (You)'
                : widget.member.username,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (widget.member.phoneNumber != null &&
                    widget.member.phoneNumber!.isNotEmpty)
                ? widget.member.phoneNumber!
                : 'No phone number',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.isCurrentUser) ...[
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Message',
            onTap: _messageUser,
          ),
          const SizedBox(width: 32),
        ],
        _buildActionButton(
          icon: Icons.phone_outlined,
          label: 'Call',
          onTap: () => _initiateCall(isVideo: false),
        ),
        const SizedBox(width: 32),
        _buildActionButton(
          icon: Icons.videocam_outlined,
          label: 'Video',
          onTap: () => _initiateCall(isVideo: true),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Image.asset(
                'images/groupinfo_icon.png',
                width: 22,
                height: 22,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: HexColor('#2A2A2A'),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline,
            title: 'Username',
            value: widget.member.username,
          ),
          if (widget.member.phoneNumber != null &&
              widget.member.phoneNumber!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: widget.member.phoneNumber!,
            ),
          ],
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.shield_outlined,
            title: 'Role',
            value: _isMemberAdmin ? 'Group Admin' : 'Member',
            valueColor: _isMemberAdmin ? HexColor('#1A7F4B') : Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 1, color: HexColor('#3A3A3A'));

  Widget _buildAdminActions() {
    if (!widget.isCurrentUserAdmin) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: HexColor('#2A2A2A'),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (!_isMemberAdmin)
            _buildActionTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Make Admin',
              onTap: _makeAdmin,
              color: HexColor('#1A7F4B'),
            ),
          if (_isMemberAdmin)
            _buildActionTile(
              icon: Icons.remove_moderator_outlined,
              title: 'Remove Admin',
              onTap: _removeAdmin,
              color: Colors.orange,
            ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.person_remove_outlined,
            title: 'Remove from Group',
            onTap: _removeFromGroup,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String username, {double size = 24}) {
    return Container(
      color: HexColor('#3A3A3A'),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
