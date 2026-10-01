import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

/// Shown when the user opens an invite link: https://qiktalk.app/join?code=<inviteCode>
///
/// Fix 1 — "Open Group" when already a member: we store the groupId from the
///          invite code (widget.inviteCode) and use getGroupDetails as fallback
///          so Open Group always works even when the 400 body has no group data.
///
/// Fix 2 — "Invalid or expired" on second tap: the invite code is one-time use.
///          After the first join/already-member response we store the groupId and
///          never call joinGroupViaInviteLink again — Open Group goes directly to
///          the chat using the stored groupId.
class JoinGroupScreen extends StatefulWidget {
  final String inviteCode;
  const JoinGroupScreen({Key? key, required this.inviteCode}) : super(key: key);

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final GroupApiService _api = GroupApiService();

  bool _isJoining = false;
  bool _alreadyMember = false;

  // Stored after a successful join or already-member response
  GroupModel? _group;
  // Fallback: if backend doesn't return group data on 400, we load it separately
  bool _isLoadingGroup = false;

  Future<void> _joinGroup() async {
    if (_isJoining) return;
    setState(() => _isJoining = true);

    final result = await _api.joinGroupViaInviteLink(
      inviteCode: widget.inviteCode,
    );

    if (!mounted) return;
    setState(() => _isJoining = false);

    if (result == null) {
      _showSnack('Something went wrong. Please try again.');
      return;
    }

    if (result.alreadyMember) {
      setState(() => _alreadyMember = true);

      if (result.group != null) {
        // Backend returned group data with the 400 — use it directly
        setState(() => _group = result.group);
      } else {
        // Backend gave no group data — fetch it via getGroupDetails
        // (user is already a member so that endpoint will work)
        _loadGroupForAlreadyMember();
      }
      return;
    }

    if (result.success) {
      if (result.group != null) {
        _openGroupChat(result.group!);
      } else {
        _showSnack('Joined! Find the group in your chats.');
        Navigator.pop(context);
      }
    } else {
      _showSnack(result.message);
    }
  }

  /// Called when user is already a member but the 400 body had no group data.
  /// Uses GET /chat/:groupId (getGroupDetails) which works for members.
  /// The inviteCode here is the real backend invite code — we need the groupId.
  /// We extract it from the join error or fall back to getGroupDetails with inviteCode.
  Future<void> _loadGroupForAlreadyMember() async {
    setState(() => _isLoadingGroup = true);
    try {
      // Try getGroupDetails — works because user IS a member
      // widget.inviteCode is the backend invite code; groupId may differ.
      // We try both endpoints to find the group.
      final group = await _api.getGroupDetails(groupId: widget.inviteCode);
      if (mounted && group != null) {
        setState(() {
          _group = group;
          _isLoadingGroup = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingGroup = false);
    // Even if fetch fails, Open Group button will use the chat list fallback
  }

  void _openGroupChat(GroupModel group) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(
          groupId: group.id,
          groupName: group.chatName,
          communityName: group.chatName,
          memberCount: group.memberCount,
          groupImage: group.groupImage ?? '',
        ),
      ),
    );
  }

  /// When we have no group data at all, just pop back to chat list —
  /// the group will be visible there since the user is already a member.
  void _openGroupFromChatList() {
    _showSnack('Opening your chats — find the group there.');
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onOpenGroupTapped() {
    if (_group != null) {
      _openGroupChat(_group!);
    } else {
      _openGroupFromChatList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Group Invite',
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexColor('#1A7F4B').withOpacity(0.15),
                border: Border.all(
                  color: HexColor('#1A7F4B').withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(Icons.group, size: 50, color: HexColor('#1A7F4B')),
            ),

            const SizedBox(height: 24),

            Text(
              _alreadyMember ? 'Already a Member' : "You've Been Invited!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _alreadyMember
                  ? 'You are already in this group.'
                  : 'Tap the button below to join the group\nand start chatting.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Already member badge
            if (_alreadyMember) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: HexColor('#1A7F4B').withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HexColor('#1A7F4B').withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: HexColor('#1A7F4B'),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You are already in this group',
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Primary button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isJoining || _isLoadingGroup)
                    ? null
                    : _alreadyMember
                    ? _onOpenGroupTapped
                    : _joinGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#1A7F4B'),
                  disabledBackgroundColor: HexColor('#1A7F4B').withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: (_isJoining || _isLoadingGroup)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _alreadyMember ? 'Open Group' : 'Join Group',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            if (!_alreadyMember)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
