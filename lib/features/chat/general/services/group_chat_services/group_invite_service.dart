import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';

/// Service that handles all group invite link logic.
/// Usage:
///   GroupInviteService.generateAndShare(context, groupId: ..., groupName: ...);
///   GroupInviteService.handleIncomingLink(context, inviteCode: ...);
class GroupInviteService {
  // ─────────────────────────────────────────────────────────────────────────────
  // GENERATE & SHARE INVITE LINK
  // Shows a bottom sheet with the link and a copy button.
  // ─────────────────────────────────────────────────────────────────────────────

  static Future<void> generateAndShare(
    BuildContext context, {
    required String groupId,
    required String groupName,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: HexColor('#1A7F4B'))),
    );

    final result = await GroupApiService().generateGroupInviteLink(
      groupId: groupId,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (result == null || !result.success || result.link.isEmpty) {
      _showSnack(
        context,
        result?.message ?? 'Failed to generate invite link',
        isError: true,
      );
      return;
    }

    _showInviteLinkSheet(context, link: result.link, groupName: groupName);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HANDLE INCOMING INVITE LINK
  // Extracts inviteCode from a deep link URL, calls join endpoint,
  // and navigates appropriately.
  // ─────────────────────────────────────────────────────────────────────────────

  static Future<void> handleIncomingLink(
    BuildContext context, {
    required String inviteCode,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: HexColor('#1A7F4B'))),
    );

    final result = await GroupApiService().joinGroupViaInviteLink(
      inviteCode: inviteCode,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (result == null) {
      _showSnack(context, 'Unable to process invite link', isError: true);
      return;
    }

    if (!result.success) {
      _showSnack(context, result.message, isError: true);
      return;
    }

    final group = result.group;

    if (result.alreadyMember) {
      // Already a member → show message and navigate to group chat
      _showSnack(context, 'You are already a member of this group');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!context.mounted) return;
      _navigateToGroupChat(context, group: group);
    } else {
      // Just joined → navigate to group chat
      _showSnack(context, 'You joined the group!');
      await Future.delayed(const Duration(milliseconds: 400));
      if (!context.mounted) return;
      _navigateToGroupChat(context, group: group);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PARSE INVITE CODE FROM DEEP LINK URL
  // E.g. https://qiktalk.app/join?code=abc123  →  'abc123'
  // ─────────────────────────────────────────────────────────────────────────────

  static String? extractInviteCode(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['code'] ??
          uri.queryParameters['invite'] ??
          uri.pathSegments.lastOrNull;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INTERNAL HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  static void _navigateToGroupChat(BuildContext context, {GroupModel? group}) {
    if (group == null) {
      _showSnack(context, 'Could not find group details', isError: true);
      return;
    }

    Navigator.pushAndRemoveUntil(
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
      // Keep the bottom nav / home screen in the stack
      (route) => route.isFirst,
    );
  }

  static void _showSnack(
    BuildContext context,
    String msg, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red : HexColor('#1A7F4B'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void _showInviteLinkSheet(
    BuildContext context, {
    required String link,
    required String groupName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InviteLinkSheet(link: link, groupName: groupName),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVITE LINK BOTTOM SHEET WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _InviteLinkSheet extends StatelessWidget {
  final String link;
  final String groupName;

  const _InviteLinkSheet({required this.link, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#2A2A2A'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: HexColor('#1A7F4B').withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.link, color: HexColor('#1A7F4B'), size: 28),
          ),
          const SizedBox(height: 16),

          Text(
            'Group Invite Link',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            groupName,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Link box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HexColor('#1A1A1A'),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A7F4B'),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.copy, color: Colors.white, size: 18),
              label: Text(
                'Copy Link',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invite link copied!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: HexColor('#1A7F4B'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
