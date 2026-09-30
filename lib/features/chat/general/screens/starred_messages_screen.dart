import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/audio_file_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/chat_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/document_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/image_message_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/multiple_image_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/video_bubble.dart';
import 'package:qik_talk/features/chat/general/components/chat_bubbles/voice_note_bubble.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_mapper.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class StarredMessagesScreen extends StatefulWidget {
  const StarredMessagesScreen({super.key});

  @override
  State<StarredMessagesScreen> createState() => _StarredMessagesScreenState();
}

class _StarredMessagesScreenState extends State<StarredMessagesScreen> {
  final SaveValues _saveValues = SaveValues();
  List<StarredMessageItem> starredMessages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStarredMessages();
  }

  Future<void> _loadStarredMessages() async {
    try {
      // Get all starred message IDs
      final starredIds = await _saveValues.getStringList(
        AppPreferenceHelper.STARRED_MESSAGES,
      );

      if (starredIds.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Load messages from all chat boxes
      final chatBox = Hive.box<List>('chat_messages');
      final List<StarredMessageItem> allStarred = [];

      for (final chatId in chatBox.keys) {
        final messagesData = chatBox.get(chatId);
        if (messagesData == null) continue;

        final messages = (messagesData as List<dynamic>)
            .map((e) => e as ChatMessageHive)
            .toList();

        for (final msg in messages) {
          if (starredIds.contains(msg.id)) {
            allStarred.add(
              StarredMessageItem(
                message: msg.toChat(),
                chatId: chatId.toString(),
              ),
            );
          }
        }
      }

      // Sort by timestamp (newest first)
      allStarred.sort(
        (a, b) => DateTime.parse(
          b.message.timestamp,
        ).compareTo(DateTime.parse(a.message.timestamp)),
      );

      setState(() {
        starredMessages = allStarred;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading starred messages: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeStarred(String messageId) async {
    try {
      final starredIds = await _saveValues.getStringList(
        AppPreferenceHelper.STARRED_MESSAGES,
      );
      starredIds.remove(messageId);
      await _saveValues.saveStringList(
        AppPreferenceHelper.STARRED_MESSAGES,
        starredIds,
      );

      setState(() {
        starredMessages.removeWhere((item) => item.message.id == messageId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message removed from starred'),
            backgroundColor: HexColor("#FF6B00"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error removing starred message: $e');
    }
  }

  Future<String> _getChatName(String chatId) async {
    try {
      final chatBox = Hive.box('chats');
      final chat = chatBox.get(chatId);
      if (chat != null) {
        return chat.title ?? 'Unknown Chat';
      }
    } catch (e) {
      print('Error getting chat name: $e');
    }
    return 'Unknown Chat';
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
            decoration: BoxDecoration(
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
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: topPadding, left: 16.0),
                      child: Text(
                        "Starred Messages",
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: HexColor("#1A7F4B")))
          : starredMessages.isEmpty
          ? _buildEmptyState()
          : _buildMessageList(isDark),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: HexColor("#7A7A7A")),
          SizedBox(height: 20),
          Text(
            "No starred messages",
            style: GoogleFonts.poppins(
              color: HexColor("#7A7A7A"),
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Long press any message and tap the star icon to save it here",
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

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: starredMessages.length,
      itemBuilder: (context, index) {
        final item = starredMessages[index];
        return _buildStarredMessageCard(item, isDark);
      },
    );
  }

  Widget _buildStarredMessageCard(StarredMessageItem item, bool isDark) {
    final msg = item.message;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with chat name and unstar button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<String>(
                    future: _getChatName(item.chatId),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading...',
                        style: GoogleFonts.poppins(
                          color: HexColor("#1A7F4B"),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: Colors.amber, size: 20),
                  onPressed: () => _removeStarred(msg.id),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: HexColor("#2E2E2E"), height: 1),

          // Message content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildMessageContent(msg),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg) {
    // Use the same bubble widgets as in MessageScreen
    if (msg.isVoiceNote) {
      return VoiceNoteBubble(
        audioUrl: msg.audioUrl!,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        isSaved: true,
        onLongPress: () {},
        onSwipe: (_) {},
      );
    }

    if (msg.isAudioFile) {
      return AudioFileBubble(
        audioUrl: msg.audioUrl!,
        fileName: msg.audioName!,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        isSaved: true,
        onLongPress: () {},
        onSwipe: (_) {},
      );
    }

    if (msg.isDocument) {
      return DocumentBubble(
        name: msg.documentName ?? "document.pdf",
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        documentUrl: msg.documentUrl,
      );
    }

    if (msg.isVideo) {
      return VideoBubble(
        videoUrl: msg.videoUrl!,
        thumbnail: msg.videoThumbnail,
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
      );
    }

    if (msg.isImage) {
      if (msg.imageUrls != null && msg.imageUrls!.length > 1) {
        return MultiImageBubble(
          images: msg.imageUrls!,
          text: msg.text,
          isMe: msg.isMe,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
          isSaved: true,
          onLongPress: () {},
          onSwipe: (_) {},
        );
      }

      return ImageMessageBubble(
        image: msg.imageUrls!.first,
        text: msg.text,
        isMe: msg.isMe,
        isRead: msg.isRead,
        timestamp: msg.timestamp,
        isSaved: true,
        onLongPress: () {},
        onSwipe: (_) {},
      );
    }

    return ChatMessageBubble(
      text: msg.text,
      isMe: msg.isMe,
      isRead: msg.isRead,
      isEdited: msg.isEdited,
      timestamp: msg.timestamp,
      isSaved: true,
      replyToText: msg.replyToText,
      replyToIsMe: msg.replyToIsMe,
      replyToMessageId: msg.replyToMessageId,
      onLongPress: () {},
      onSwipe: (_) {},
      onReplyTap: null,
    );
  }
}

class StarredMessageItem {
  final ChatMessage message;
  final String chatId;

  StarredMessageItem({required this.message, required this.chatId});
}
