import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/services/pinned_messages/pinned_message_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PinnedMessageBanner
//
// Shows a slim banner at the top of the chat screen when there are pinned
// messages. Tapping it opens the PinnedMessagesSheet.
//
// Usage (inside your chat screen's Stack, above the message list):
//
//   PinnedMessageBanner(
//     chatId: widget.chatId,
//     currentUserId: _currentUserId,
//     isAdmin: _isAdmin,
//     onUnpin: (messageId) { /* optional local refresh */ },
//   )
// ─────────────────────────────────────────────────────────────────────────────

class PinnedMessageBanner extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback? onChanged; // called after pin/unpin

  const PinnedMessageBanner({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.isAdmin = false,
    this.onChanged,
  });

  @override
  State<PinnedMessageBanner> createState() => PinnedMessageBannerState();
}

class PinnedMessageBannerState extends State<PinnedMessageBanner> {
  final PinnedMessageService _service = PinnedMessageService();
  List<PinnedMessage> _pinned = [];
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Public: call via GlobalKey after pin/unpin to refresh the banner.
  void reload() {
    _dismissed = false;
    _load();
  }

  Future<void> _load() async {
    final msgs = await _service.getPinnedMessages(widget.chatId);
    if (mounted) setState(() => _pinned = msgs);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || _pinned.isEmpty) return const SizedBox.shrink();

    final latest = _pinned.last;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PinnedMessagesSheet(
            chatId: widget.chatId,
            isAdmin: widget.isAdmin,
            onChanged: () {
              _load();
              widget.onChanged?.call();
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: HexColor('#1B1B1B'),
          border: Border(
            bottom: BorderSide(color: HexColor('#2A2A2A'), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Pin icon
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: HexColor('#FB8830').withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.push_pin_rounded,
                color: HexColor('#FB8830'),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),

            // Message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pinned Message',
                    style: GoogleFonts.poppins(
                      color: HexColor('#FB8830'),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    latest.previewText,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Count badge if more than one
            if (_pinned.length > 1) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: HexColor('#FB8830').withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_pinned.length}',
                  style: GoogleFonts.poppins(
                    color: HexColor('#FB8830'),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Dismiss
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: Icon(Icons.close, color: HexColor('#787880'), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PinnedMessagesSheet  (full list, with unpin option for admins)
// ─────────────────────────────────────────────────────────────────────────────

class PinnedMessagesSheet extends StatefulWidget {
  final String chatId;
  final bool isAdmin;
  final VoidCallback? onChanged;

  const PinnedMessagesSheet({
    super.key,
    required this.chatId,
    this.isAdmin = false,
    this.onChanged,
  });

  @override
  State<PinnedMessagesSheet> createState() => _PinnedMessagesSheetState();
}

class _PinnedMessagesSheetState extends State<PinnedMessagesSheet> {
  final PinnedMessageService _service = PinnedMessageService();
  List<PinnedMessage> _pinned = [];
  bool _loading = true;
  final Set<String> _unpinning = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final msgs = await _service.getPinnedMessages(widget.chatId);
    if (mounted)
      setState(() {
        _pinned = msgs;
        _loading = false;
      });
  }

  Future<void> _unpin(String messageId) async {
    setState(() => _unpinning.add(messageId));
    final ok = await _service.unpinMessage(
      chatId: widget.chatId,
      messageId: messageId,
    );
    if (ok) {
      await _load();
      widget.onChanged?.call();
    } else {
      setState(() => _unpinning.remove(messageId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: HexColor('#1B1B1B'),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HexColor('#3A3A3A'),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    color: HexColor('#FB8830'),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned Messages',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: HexColor('#2A2A2A'), height: 1),

            // List
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: HexColor('#FB8830'),
                      ),
                    )
                  : _pinned.isEmpty
                  ? Center(
                      child: Text(
                        'No pinned messages',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _pinned.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: HexColor('#242424'), height: 1),
                      itemBuilder: (_, i) => _buildItem(_pinned[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(PinnedMessage msg) {
    final isUnpinning = _unpinning.contains(msg.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: HexColor('#2A2A2A'),
            backgroundImage: msg.sender.profilePicture.isNotEmpty
                ? NetworkImage(msg.sender.profilePicture)
                : null,
            child: msg.sender.profilePicture.isEmpty
                ? Icon(Icons.person, color: HexColor('#787880'), size: 20)
                : null,
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.sender.username,
                      style: GoogleFonts.poppins(
                        color: HexColor('#FB8830'),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(msg.sentAt),
                      style: GoogleFonts.poppins(
                        color: HexColor('#787880'),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  msg.previewText,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Unpin button (admin only)
          if (widget.isAdmin) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isUnpinning ? null : () => _unpin(msg.id),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HexColor('#2A2A2A'),
                  shape: BoxShape.circle,
                ),
                child: isUnpinning
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HexColor('#FB8830'),
                        ),
                      )
                    : Icon(
                        Icons.push_pin_outlined,
                        color: HexColor('#787880'),
                        size: 16,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
