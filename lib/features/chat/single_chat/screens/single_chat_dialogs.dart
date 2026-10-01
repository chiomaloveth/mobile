import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BUTTON WIDGET — used by all dialogs (Cancel / Action)
// Matches the exact Figma pill button with optional gradient border glow
// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary; // true = gradient border glow (right button)
  final Color? labelColor;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: labelColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    if (!isPrimary) return button;

    // Primary button = gradient border glow (pink/orange — matches Figma)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2), // border thickness
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF2D55), Color(0xFFFF6B00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: labelColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MUTE DIALOG  (Images 3 & 4)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatMuteDialog extends StatefulWidget {
  final String username;
  final String chatId;
  final VoidCallback? onMuted;

  const SingleChatMuteDialog({
    super.key,
    required this.username,
    required this.chatId,
    this.onMuted,
  });

  @override
  State<SingleChatMuteDialog> createState() => _SingleChatMuteDialogState();
}

class _SingleChatMuteDialogState extends State<SingleChatMuteDialog> {
  int? _selected; // 0=1h, 1=8h, 2=1wk, 3=always

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Text(
                  'Mute  message notifications',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Other members will not see that you muted this chat. You will still be notified if you are mentioned',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _muteOption(Icons.access_time_outlined, '1 Hour', 0),
                _muteOption(Icons.access_time_outlined, '8 Hours', 1),
                _muteOption(Icons.calendar_today_outlined, '1 Week', 2),
                _muteOption(Icons.notifications_off_outlined, 'Always', 3),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'OK',
                        isPrimary: true,
                        onTap: () async {
                          Navigator.pop(context, _selected);
                          debugPrint(
                            '🔇 [MUTE] Attempting to mute chat: ${widget.chatId}',
                          );
                          final result = await ChatActionsService().muteChat(
                            widget.chatId,
                          );
                          debugPrint(
                            '🔇 [MUTE] Result: success=${result.success}, message=${result.message}',
                          );
                          widget.onMuted?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _muteOption(IconData icon, String label, int idx) {
    final bool active = _selected == idx;
    return GestureDetector(
      onTap: () => setState(() => _selected = idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOCK DIALOG  (Image 5)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatBlockDialog extends StatelessWidget {
  final String username;
  final String userId; // the other person's userId
  final VoidCallback onBlock;

  const SingleChatBlockDialog({
    super.key,
    required this.username,
    required this.userId,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                // Icon circle — dark red
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D0A0A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    color: Color(0xFFFF3B30),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Block $username',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Blocked contacts will no longer be able to call you or send you messages. This contact will not be notified.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Warning row
                _warningRow(
                  icon: Icons.warning_amber_rounded,
                  text:
                      'You can unblock this contact anytime from your blocked contacts list in settings.',
                ),
                const SizedBox(height: 10),
                // Checkbox row
                _checkRow(
                  text:
                      'The last 5 messages in this chat will be sent to QikTalk',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'Block',
                        isPrimary: true,
                        onTap: () async {
                          Navigator.pop(context);
                          debugPrint('🚫 [BLOCK] Blocking userId: $userId');
                          final result = await ChatActionsService().blockUser(
                            userId,
                          );
                          debugPrint(
                            '🚫 [BLOCK] Status: success=${result.success}, msg=${result.message}',
                          );

                          // Mark chat as blocked in Hive so it disappears from chat list
                          try {
                            final chatBox =
                                await Hive.openBox<ChatListItemHive>('chats');
                            final entry = chatBox.values
                                .where((c) => c.userId == userId)
                                .firstOrNull;
                            if (entry != null) {
                              await chatBox.put(
                                entry.id,
                                entry.copyWith(isBlocked: true),
                              );
                              debugPrint(
                                '🚫 [BLOCK] Hive updated: chat ${entry.id} marked blocked',
                              );
                            }
                            // ✅ Pop back to chat list so the blocked chat disappears immediately
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            debugPrint('🚫 [BLOCK] Hive update error: $e');
                          }

                          onBlock();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _warningRow({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow({required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REPORT DIALOG  (Image 6)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatReportDialog extends StatefulWidget {
  final String username;
  final String userId;
  final VoidCallback onReport;

  const SingleChatReportDialog({
    super.key,
    required this.username,
    required this.userId,
    required this.onReport,
  });

  @override
  State<SingleChatReportDialog> createState() => _SingleChatReportDialogState();
}

class _SingleChatReportDialogState extends State<SingleChatReportDialog> {
  int? _selectedReason;
  bool _blockContact = false;

  static const List<String> _reasons = [
    'Spam',
    'Harassment or bullying',
    'Scam or Fraud',
    'Inappropriate content',
    'Impersonation',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D0A0A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF3B30),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Report ${widget.username}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Help us understand what's happening. Your report is anonymous.",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SELECT A REASON',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_reasons.length, (i) => _reasonRow(i)),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Block this contact',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Switch(
                      value: _blockContact,
                      onChanged: (v) => setState(() => _blockContact = v),
                      activeColor: HexColor('#FF6B00'),
                      activeTrackColor: HexColor('#FF6B00').withOpacity(0.4),
                      inactiveThumbColor: const Color(0xFF787880),
                      inactiveTrackColor: const Color(0xFF39393D),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'Block',
                        isPrimary: true,
                        onTap: () async {
                          Navigator.pop(context);
                          final reasons = [
                            'spam',
                            'harassment',
                            'scam',
                            'inappropriate',
                            'impersonation',
                            'other',
                          ];
                          final reason = _selectedReason != null
                              ? reasons[_selectedReason!]
                              : 'other';
                          await ChatActionsService().reportContact(
                            reportedUserId: widget.userId,
                            reason: reason,
                            block: _blockContact,
                          );
                          widget.onReport();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reasonRow(int idx) {
    final bool active = _selectedReason == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _reasons[idx],
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLEAR CHAT DIALOG  (Image 7)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatClearDialog extends StatefulWidget {
  final String username;
  final String chatId;
  final VoidCallback onClear;

  const SingleChatClearDialog({
    super.key,
    required this.username,
    required this.chatId,
    required this.onClear,
  });

  @override
  State<SingleChatClearDialog> createState() => _SingleChatClearDialogState();
}

class _SingleChatClearDialogState extends State<SingleChatClearDialog> {
  int _selected = 0;
  String _totalSize = 'calculating...';
  String _mediaSize = 'calculating...';

  @override
  void initState() {
    super.initState();
    _computeSizes();
  }

  Future<void> _computeSizes() async {
    try {
      final box = Hive.box<List>('chat_messages');
      final cached = box.get(widget.chatId);
      if (cached == null) {
        if (mounted)
          setState(() {
            _totalSize = '0 KB';
            _mediaSize = '0 KB';
          });
        return;
      }
      int totalBytes = 0;
      int mediaBytes = 0;
      for (final raw in cached) {
        try {
          final hive = raw as dynamic;
          // count text bytes
          final text = (hive.text ?? '') as String;
          totalBytes += text.length * 2;
          // count local media files
          for (final field in [
            hive.audioUrl,
            hive.videoUrl,
            hive.documentUrl,
          ]) {
            if (field != null &&
                field.toString().isNotEmpty &&
                !field.toString().startsWith('http')) {
              final f = File(field.toString());
              if (await f.exists()) {
                final sz = await f.length();
                totalBytes += sz;
                mediaBytes += sz;
              }
            }
          }
          final imageUrls = hive.imageUrls as List<dynamic>?;
          if (imageUrls != null) {
            for (final url in imageUrls) {
              if (url.toString().isNotEmpty &&
                  !url.toString().startsWith('http')) {
                final f = File(url.toString());
                if (await f.exists()) {
                  final sz = await f.length();
                  totalBytes += sz;
                  mediaBytes += sz;
                }
              }
            }
          }
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _totalSize = _fmt(totalBytes);
          _mediaSize = _fmt(mediaBytes);
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _totalSize = 'unknown';
          _mediaSize = 'unknown';
        });
    }
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clear chat with ${widget.username}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'All messages in this chat will be deleted. This action cannot be undone.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Messages will only be removed from your device. ${widget.username} will still have their copy of the conversation.',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _clearOption(0, 'All messages ($_totalSize)'),
                _clearOption(
                  1,
                  'Media files only ($_mediaSize)',
                  hasArrow: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Media files you have saved from QikTalk will remain in your device gallery',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: _selected == 0
                            ? 'Clear ($_totalSize)'
                            : 'Clear ($_mediaSize)',
                        isPrimary: true,
                        onTap: () async {
                          Navigator.pop(context);
                          await ChatActionsService().clearChat(widget.chatId);
                          widget.onClear();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _clearOption(int idx, String label, {bool hasArrow = false}) {
    final bool active = _selected == idx;
    return GestureDetector(
      onTap: () => setState(() => _selected = idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
            if (hasArrow)
              const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT CHAT DIALOG  (Image 8)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatExportDialog extends StatelessWidget {
  final String chatId;
  final String username;
  final VoidCallback onWithoutMedia;
  final VoidCallback onIncludeMedia;

  const SingleChatExportDialog({
    super.key,
    required this.chatId,
    required this.username,
    required this.onWithoutMedia,
    required this.onIncludeMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Including media will increase the size of the chat export',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Without media',
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await ChatActionsService().exportChat(
                            chatId,
                          );
                          if (result.success && result.content != null) {
                            // Save to temp file and share as text
                            final dir = await getTemporaryDirectory();
                            final file = File(
                              '${dir.path}/qiktalk_chat_$username.txt',
                            );
                            await file.writeAsString(result.content!);
                            await Share.shareXFiles([
                              XFile(file.path),
                            ], text: 'Chat export with $username');
                          }
                          onWithoutMedia();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'Include media',
                        isPrimary: true,
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await ChatActionsService().exportChat(
                            chatId,
                          );
                          if (result.success && result.content != null) {
                            final dir = await getTemporaryDirectory();
                            final file = File(
                              '${dir.path}/qiktalk_chat_with_media_$username.txt',
                            );
                            await file.writeAsString(result.content!);
                            await Share.shareXFiles(
                              [XFile(file.path)],
                              text:
                                  'Chat export with $username (including media)',
                            );
                          }
                          onIncludeMedia();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE CHAT DIALOG  (Image 9)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatDeleteDialog extends StatefulWidget {
  final String username;
  final String chatId;
  final VoidCallback onDelete;

  const SingleChatDeleteDialog({
    super.key,
    required this.username,
    required this.chatId,
    required this.onDelete,
  });

  @override
  State<SingleChatDeleteDialog> createState() => _SingleChatDeleteDialogState();
}

class _SingleChatDeleteDialogState extends State<SingleChatDeleteDialog> {
  int _selected = 0;
  String _totalSize = 'calculating...';
  String _mediaSize = 'calculating...';

  @override
  void initState() {
    super.initState();
    _computeSizes();
  }

  Future<void> _computeSizes() async {
    try {
      final box = Hive.box<List>('chat_messages');
      final cached = box.get(widget.chatId);
      if (cached == null) {
        if (mounted)
          setState(() {
            _totalSize = '0 KB';
            _mediaSize = '0 KB';
          });
        return;
      }
      int totalBytes = 0;
      int mediaBytes = 0;
      for (final raw in cached) {
        try {
          final hive = raw as dynamic;
          final text = (hive.text ?? '') as String;
          totalBytes += text.length * 2;
          for (final field in [
            hive.audioUrl,
            hive.videoUrl,
            hive.documentUrl,
          ]) {
            if (field != null &&
                field.toString().isNotEmpty &&
                !field.toString().startsWith('http')) {
              final f = File(field.toString());
              if (await f.exists()) {
                final sz = await f.length();
                totalBytes += sz;
                mediaBytes += sz;
              }
            }
          }
          final imageUrls = hive.imageUrls as List<dynamic>?;
          if (imageUrls != null) {
            for (final url in imageUrls) {
              if (url.toString().isNotEmpty &&
                  !url.toString().startsWith('http')) {
                final f = File(url.toString());
                if (await f.exists()) {
                  final sz = await f.length();
                  totalBytes += sz;
                  mediaBytes += sz;
                }
              }
            }
          }
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _totalSize = _fmt(totalBytes);
          _mediaSize = _fmt(mediaBytes);
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _totalSize = 'unknown';
          _mediaSize = 'unknown';
        });
    }
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D0A0A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF3B30),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete chat with ${widget.username}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'This chat and all messages will be permanently deleted from your device. This action cannot be undone.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will remove the conversation from your chat list permanently. ${widget.username} will still have their copy.',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _deleteOption(0, 'All messages ($_totalSize)'),
                _deleteOption(
                  1,
                  'Media files only ($_mediaSize)',
                  hasArrow: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Media files you have saved from QikTalk will remain in your device gallery',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: _selected == 0
                            ? 'Delete ($_totalSize)'
                            : 'Delete ($_mediaSize)',
                        isPrimary: true,
                        labelColor: const Color(0xFFFF3B30),
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await ChatActionsService().deleteChat(
                            widget.chatId,
                          );
                          if (result.success) {
                            widget.onDelete();
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteOption(int idx, String label, {bool hasArrow = false}) {
    final bool active = _selected == idx;
    return GestureDetector(
      onTap: () => setState(() => _selected = idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
            if (hasArrow)
              const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE MEDIA DIALOG  (Image 10)
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatDeleteMediaDialog extends StatefulWidget {
  final String username;
  final VoidCallback onDelete;

  const SingleChatDeleteMediaDialog({
    super.key,
    required this.username,
    required this.onDelete,
  });

  @override
  State<SingleChatDeleteMediaDialog> createState() =>
      _SingleChatDeleteMediaDialogState();
}

class _SingleChatDeleteMediaDialogState
    extends State<SingleChatDeleteMediaDialog> {
  bool _photos = false;
  bool _videos = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF3D0A0A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF3B30),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete chat media of ${widget.username}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _mediaOption(
              label: 'Photos (100MB)',
              active: _photos,
              onTap: () => setState(() => _photos = !_photos),
            ),
            _mediaOption(
              label: 'Videos (250 MB)',
              active: _videos,
              onTap: () => setState(() => _videos = !_videos),
            ),
            const SizedBox(height: 8),
            Text(
              'Media files you have saved from QikTalk will remain in your device gallery',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'Delete (350 mb)',
                    isPrimary: true,
                    labelColor: const Color(0xFFFF3B30),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDelete();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaOption({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
