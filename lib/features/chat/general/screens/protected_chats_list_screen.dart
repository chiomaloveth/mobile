import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/model/get_chat_model.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/protected_chats_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/helpers/chat_lock_auth_helper.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

/// Screen that shows all locked (protected) chats.
/// Opened via the "🔒 Locked Chats" tile in the main chat list —
/// the caller is responsible for authenticating before pushing this screen.
class ProtectedChatsListScreen extends StatefulWidget {
  const ProtectedChatsListScreen({super.key});

  @override
  State<ProtectedChatsListScreen> createState() =>
      _ProtectedChatsListScreenState();
}

class _ProtectedChatsListScreenState extends State<ProtectedChatsListScreen>
    with SingleTickerProviderStateMixin {
  final ProtectedChatsService _protectedSvc = ProtectedChatsService();
  final ChatSettingsPersistenceService _settingsSvc =
      ChatSettingsPersistenceService();

  late Box<ChatListItemHive> _chatBox;
  List<ChatListItemHive> _protectedChats = [];
  bool _isLoading = true;

  // Entry animation
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _chatBox = Hive.box<ChatListItemHive>('chats');

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _loadProtectedChats();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadProtectedChats() async {
    final ids = await _protectedSvc.getProtectedChatIds();
    if (!mounted) return;

    final chats = _chatBox.values
        .where((c) => ids.contains(c.id))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() {
      _protectedChats = chats;
      _isLoading = false;
    });

    _animCtrl.forward();
  }

  // ── Unprotect ─────────────────────────────────────────────────────────────

  Future<void> _unprotectChat(ChatListItemHive chat) async {
    final ok = await ChatLockAuthHelper.authenticate(
      context,
      reason: 'Authenticate to unprotect this chat',
    );
    if (!ok || !mounted) return;

    await _protectedSvc.removeProtectedChat(chat.id);
    await _settingsSvc.setProtected(chat.id, false);

    // Invalidate cache so ChatComponent/GroupComponent repaint
    _protectedSvc.invalidateCache();

    if (!mounted) return;
    setState(() => _protectedChats.remove(chat));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_capitalize(chat.title)} moved back to chats'),
        backgroundColor: HexColor('#1A7F4B'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(local.year, local.month, local.day);
    if (d == today) return DateFormat('h:mm a').format(local);
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MM/dd/yyyy').format(local);
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3A1D07),
              image: DecorationImage(
                image: AssetImage('images/app_bar_gredient.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPadding - MediaQuery.of(context).padding.top,
                  left: 8,
                  right: 16,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    // Lock icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Locked Chats',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'These chats are protected',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading(isDark)
                : _protectedChats.isEmpty
                    ? _buildEmptyState(isDark)
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 110,
                            ),
                            itemCount: _protectedChats.length,
                            itemBuilder: (_, i) =>
                                _buildChatTile(_protectedChats[i], isDark),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexColor('#1A7F4B').withOpacity(0.12),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: HexColor('#1A7F4B'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No locked chats',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Open a chat\'s info screen and enable "Protected Chat" to hide it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shimmer loading ───────────────────────────────────────────────────────

  Widget _buildShimmerLoading(bool isDark) {
    final shimmerBase =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E0D8);
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: shimmerBase,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: shimmerBase,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: shimmerBase,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chat tile ─────────────────────────────────────────────────────────────

  Widget _buildChatTile(ChatListItemHive chat, bool isDark) {
    final title = _capitalize(chat.title);
    final lastMsg = chat.lastMessage;
    final timeStr =
        lastMsg != null ? _formatTime(lastMsg.createdAt) : '';

    String subtitle;
    if (lastMsg == null) {
      subtitle = 'No messages yet';
    } else if (lastMsg.isImage) {
      subtitle = '📷 Photo';
    } else if (lastMsg.isVoiceNote) {
      subtitle = '🎙️ Voice message';
    } else if (lastMsg.isAudio) {
      subtitle = '🎵 Audio';
    } else if (lastMsg.isVideo) {
      subtitle = '🎥 Video';
    } else if (lastMsg.isDocument) {
      subtitle = '📄 Document';
    } else {
      subtitle = lastMsg.content;
    }

    return InkWell(
      onTap: () {
        if (chat.isGroupChat) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupChatScreen(
                groupId: chat.id,
                groupName: title,
                communityName: title,
                memberCount: chat.memberCount,
                groupImage: chat.profilePicture,
              ),
            ),
          ).then((_) {
            // Refresh list in case user changed protection status from group info
            ProtectedChatsService().invalidateCache();
            _loadProtectedChats();
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MessageScreen(
                chatId: chat.id,
                username: title,
                lastSeenActive: '',
                profilePicture: chat.profilePicture,
                about: chat.about,
                userId: chat.userId,
                isGroupChat: false,
              ),
            ),
          ).then((_) {
            // Refresh list in case user changed protection status from chat info
            ProtectedChatsService().invalidateCache();
            _loadProtectedChats();
          });
        }
      },
      onLongPress: () => _showUnprotectDialog(chat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CachedProfileAvatar(
                  imageUrl:
                      chat.profilePicture.isNotEmpty ? chat.profilePicture : null,
                  displayName: chat.title,
                  radius: 27,
                  backgroundColor: HexColor('#FB8830'),
                ),
                // Lock badge
                Positioned(
                  bottom: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppTheme.scaffoldBg(isDark),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: HexColor('#1A7F4B'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Long-press unprotect dialog ───────────────────────────────────────────

  void _showUnprotectDialog(ChatListItemHive chat) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? HexColor('#1E1E1E') : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.lock_open_rounded,
                  color: HexColor('#FF6B00'),
                ),
                title: Text(
                  'Unprotect "${_capitalize(chat.title)}"',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1A1008),
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _unprotectChat(chat);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.grey),
                title: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
