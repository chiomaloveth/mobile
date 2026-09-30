import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class ArchivedChatsScreen extends StatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  final SaveValues _saveValues = SaveValues();
  late Box<ChatListItemHive> chatBox;
  List<ChatListItemHive> archivedChats = [];

  @override
  void initState() {
    super.initState();
    chatBox = Hive.box<ChatListItemHive>('chats');
    _loadArchivedChats();
  }

  Future<void> _loadArchivedChats() async {
    final archivedIds = await _saveValues.getStringList(
      AppPreferenceHelper.archivedChats(),
    );

    if (mounted) {
      setState(() {
        archivedChats =
            chatBox.values
                .where((chat) => archivedIds.contains(chat.id))
                .toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    }
  }

  Future<void> _unarchiveChat(String chatId) async {
    try {
      final archivedIds = await _saveValues.getStringList(
        AppPreferenceHelper.archivedChats(),
      );
      archivedIds.remove(chatId);
      await _saveValues.saveStringList(
        AppPreferenceHelper.archivedChats(),
        archivedIds,
      );

      await _loadArchivedChats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat unarchived'),
            backgroundColor: HexColor("#1A7F4B"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error unarchiving chat: $e');
    }
  }

  String _formatLastActive(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    if (dateToCheck == today) {
      return DateFormat('h:mm a').format(localDateTime);
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd/yyyy').format(localDateTime);
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HexColor("#3A1D07"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/app_bar_gredient.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 16.0),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: topPadding, left: 16.0),
                      child: Text(
                        "Archived",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: archivedChats.isEmpty ? _buildEmptyState() : _buildChatList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_outlined, size: 80, color: HexColor("#7A7A7A")),
          const SizedBox(height: 20),
          Text(
            "No archived chats",
            style: GoogleFonts.poppins(
              color: HexColor("#7A7A7A"),
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Long press any chat and tap 'Archive' to move it here",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: HexColor("#7A7A7A"),
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: archivedChats.length,
      itemBuilder: (context, index) {
        final chat = archivedChats[index];
        return _buildChatTile(chat);
      },
    );
  }

  Widget _buildChatTile(ChatListItemHive chat) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final capitalisedTitle = _capitalize(chat.title);
    final lastMessage = chat.lastMessage;
    final lastMessageTime = chat.lastMessage != null
        ? _formatLastActive(chat.lastMessage!.createdAt)
        : '';

    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: HexColor("#1A7F4B"),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.unarchive, color: Colors.white),
      ),
      onDismissed: (_) => _unarchiveChat(chat.id),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MessageScreen(
                chatId: chat.id,
                username: capitalisedTitle,
                lastSeenActive: '',
                profilePicture: chat.profilePicture,
                about: chat.about,
                userId: chat.userId,
                isGroupChat: chat.isGroupChat, // ✅ FIXED
              ),
            ),
          );
        },
        onLongPress: () => _showUnarchiveDialog(chat),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: HexColor("#FB8830"),
                  backgroundImage: chat.profilePicture.isNotEmpty
                      ? NetworkImage(chat.profilePicture)
                      : null,
                  child: chat.profilePicture.isEmpty
                      ? Text(
                          chat.title.isNotEmpty
                              ? chat.title[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalisedTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 17.5,
                      ),
                    ),
                    _buildSubtitle(lastMessage),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastMessageTime,
                      style: GoogleFonts.poppins(
                        color: HexColor("#5F5F5F"),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.archive, color: HexColor("#7A7A7A"), size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(dynamic message) {
    if (message == null) {
      return Builder(
        builder: (context) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          return Text(
            'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 14),
          );
        },
      );
    }

    IconData? icon;
    String label;

    if (message.isImage) {
      icon = Icons.image;
      label = 'Photo';
    } else if (message.isVoiceNote) {
      icon = Icons.mic;
      label = 'Voice message';
    } else if (message.isAudio) {
      icon = Icons.audiotrack;
      label = 'Audio';
    } else if (message.isVideo) {
      icon = Icons.videocam;
      label = 'Video';
    } else if (message.isDocument) {
      icon = Icons.insert_drive_file;
      label = 'Document';
    } else if (message.isContact) {
      icon = Icons.person;
      label = 'Contact';
    } else {
      return Builder(
        builder: (context) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          return Text(
            message.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 15.0),
          );
        },
      );
    }

    return Builder(
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary(isDark)),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 14),
            ),
          ],
        );
      },
    );
  }

  void _showUnarchiveDialog(ChatListItemHive chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("#2E2E2E"),
        title: Text(
          'Unarchive Chat',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Move "${chat.title}" back to your chat list?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unarchiveChat(chat.id);
            },
            child: Text(
              'Unarchive',
              style: TextStyle(color: HexColor("#1A7F4B")),
            ),
          ),
        ],
      ),
    );
  }
}
