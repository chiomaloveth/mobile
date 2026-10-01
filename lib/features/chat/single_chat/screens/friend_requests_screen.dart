import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/friend_request_model.dart';
import 'package:qik_talk/features/chat/general/services/message_request_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

class FriendRequestsScreen extends StatefulWidget {
  final VoidCallback? onRequestAccepted;
  const FriendRequestsScreen({super.key, this.onRequestAccepted});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> _requests = [];
  bool _isLoading = true;

  // IDs currently being acted on (to show per-tile loading)
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _subscribeToSocket();
  }

  @override
  void dispose() {
    _unsubscribeFromSocket();
    super.dispose();
  }

  // ── Socket ───────────────────────────────────────────────────
  void _subscribeToSocket() {
    try {
      final socket = GlobalSocketService().socket;
      socket?.on('new_message_request', _onNewRequest);
      socket?.on('message_request_accepted', _onRequestHandled);
      socket?.on('message_request_rejected', _onRequestHandled);
    } catch (e) {
      debugPrint('FriendRequests socket subscribe error: $e');
    }
  }

  void _unsubscribeFromSocket() {
    try {
      final socket = GlobalSocketService().socket;
      socket?.off('new_message_request', _onNewRequest);
      socket?.off('message_request_accepted', _onRequestHandled);
      socket?.off('message_request_rejected', _onRequestHandled);
    } catch (_) {}
  }

  void _onNewRequest(dynamic data) {
    debugPrint('📩 new_message_request: $data');
    _loadRequests(); // refresh list
  }

  void _onRequestHandled(dynamic data) {
    final messageId = data?['messageId']?.toString();
    if (messageId != null && mounted) {
      setState(() => _requests.removeWhere((r) => r.id == messageId));
    }
  }

  // ── Data ─────────────────────────────────────────────────────
  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final list = await MessageRequestService.fetchRequests();
    if (!mounted) return;
    setState(() {
      _requests = list;
      _isLoading = false;
    });
  }

  // ── Actions ──────────────────────────────────────────────────
  Future<void> _handleAccept(FriendRequest request) async {
    // Show the "with / without contact" bottom sheet
    final choice = await _showAcceptOptionsSheet(request);
    if (choice == null || !mounted) return;

    final addContact = choice == 'with_contact';

    setState(() => _processingIds.add(request.id));

    final ok = await MessageRequestService.acceptRequest(
      messageId: request.id,
      chatId: request.chatId,
      addContact: addContact,
    );

    if (!mounted) return;
    setState(() => _processingIds.remove(request.id));

    if (ok) {
      setState(() => _requests.removeWhere((r) => r.id == request.id));
      widget.onRequestAccepted?.call();

      // Navigate into the chat
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageScreen(
              chatId: request.chatId,
              userId: request.userId,
              username: request.username,
              profilePicture: request.profilePicture,
              lastSeenActive: '',
              about: '',
              isGroupChat: false,
              isContact: addContact, // pass contact status
            ),
          ),
        );
      }
    } else {
      _showSnack('Failed to accept request. Please try again.', isError: true);
    }
  }

  Future<void> _handleReject(FriendRequest request) async {
    setState(() => _processingIds.add(request.id));

    final ok = await MessageRequestService.rejectRequest(messageId: request.id);

    if (!mounted) return;
    setState(() => _processingIds.remove(request.id));

    if (ok) {
      setState(() => _requests.removeWhere((r) => r.id == request.id));
      _showSnack('Request declined.');
    } else {
      _showSnack('Failed to decline request.', isError: true);
    }
  }

  // ── Accept Options Sheet (Figma Image 2) ─────────────────────
  Future<String?> _showAcceptOptionsSheet(FriendRequest request) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + Confirm
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'with_contact'),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(
                      color: HexColor('#CC0033'),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Would you like to share your phone\nnumber with this contact?',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            // Share Phone Number toggle row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Phone Number',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                _PhoneShareToggle(
                  onConfirm: (share) => Navigator.pop(
                    ctx,
                    share ? 'with_contact' : 'without_contact',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red : HexColor('#1A7F4B'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: HexColor('#FB8830')),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_chat_unread_outlined,
              color: HexColor('#5F5F5F'),
              size: 60,
            ),
            const SizedBox(height: 12),
            Text(
              'No pending requests',
              style: GoogleFonts.poppins(
                color: HexColor('#7A7A7A'),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: HexColor('#FB8830'),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _requests.length,
        itemBuilder: (ctx, i) => _buildRequestTile(_requests[i]),
      ),
    );
  }

  Widget _buildRequestTile(FriendRequest request) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isProcessing = _processingIds.contains(request.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ────────────────────────────────────────────
          CachedProfileAvatar(
            imageUrl: request.profilePicture.isNotEmpty
                ? request.profilePicture
                : null,
            displayName: request.username,
            radius: 26,
            backgroundColor: HexColor('#FB8830'),
          ),
          const SizedBox(width: 12),

          // ── Name + preview + buttons ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(request.username),
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.messagePreview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),

                // Buttons
                isProcessing
                    ? SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HexColor('#CC0033'),
                        ),
                      )
                    : Row(
                        children: [
                          _actionButton(
                            label: 'Accept Request',
                            color: HexColor('#CC0033'),
                            onTap: () => _handleAccept(request),
                          ),
                          const SizedBox(width: 8),
                          _actionButton(
                            label: 'Deny Request',
                            color: Colors.transparent,
                            borderColor: HexColor('#5F5F5F'),
                            textColor: AppTheme.textSecondary(isDark),
                            onTap: () => _handleReject(request),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    Color? borderColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Toggle widget used in the accept sheet ────────────────────
class _PhoneShareToggle extends StatefulWidget {
  final void Function(bool share) onConfirm;
  const _PhoneShareToggle({required this.onConfirm});

  @override
  State<_PhoneShareToggle> createState() => _PhoneShareToggleState();
}

class _PhoneShareToggleState extends State<_PhoneShareToggle> {
  bool _share = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _share,
      onChanged: (v) {
        setState(() => _share = v);
        widget.onConfirm(v);
      },
      activeColor: HexColor('#CC0033'),
    );
  }
}
