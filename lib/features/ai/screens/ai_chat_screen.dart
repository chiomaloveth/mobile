import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/ai/services/ai_service.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String initialMessage;
  final String? chatId; // ✅ ADD THIS - for loading previous chats

  const AIChatScreen({super.key, required this.initialMessage, this.chatId});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final SaveValues _saveValues = SaveValues();
  AIService? _aiService;
  bool _isTyping = false;
  bool _stopGenerating = false;
  bool _isInitialized = false;

  late AnimationController _thinkingAnimationController;
  late Animation<double> _thinkingAnimation;

  String? _currentChatId; // ✅ Track current chat session
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // ✅ ADD THIS

  @override
  void initState() {
    super.initState();
    _initializeAIService();

    _thinkingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _thinkingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _thinkingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeAIService() async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

    setState(() {
      _aiService = AIService(baseUrl: ApiStrings.aiChat, token: token ?? '');
      _isInitialized = true;
    });

    // ✅ LOAD PREVIOUS CHAT OR START NEW
    if (widget.chatId != null) {
      await _loadChatHistory(widget.chatId!);
    } else {
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    if (widget.initialMessage.isNotEmpty) {
      _messages.add(
        ChatMessage(
          text: widget.initialMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      _getAIResponse(widget.initialMessage);
    }
  }

  // ✅ LOAD CHAT HISTORY FROM LOCAL STORAGE
  Future<void> _loadChatHistory(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final chatData = prefs.getString('ai_chat_$chatId');

    if (chatData != null) {
      final List<dynamic> decoded = json.decode(chatData);
      setState(() {
        _messages.addAll(
          decoded.map(
            (e) => ChatMessage(
              text: e['text'],
              isUser: e['isUser'],
              timestamp: DateTime.parse(e['timestamp']),
            ),
          ),
        );
        _currentChatId = chatId;
      });
    }
  }

  // ✅ SAVE CHAT HISTORY TO LOCAL STORAGE
  Future<void> _saveChatHistory() async {
    if (_currentChatId == null || _messages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final chatData = json.encode(
      _messages
          .map(
            (e) => {
              'text': e.text,
              'isUser': e.isUser,
              'timestamp': e.timestamp.toIso8601String(),
            },
          )
          .toList(),
    );

    await prefs.setString('ai_chat_$_currentChatId', chatData);

    // Save chat metadata
    List<String> chatIds = prefs.getStringList('ai_chat_ids') ?? [];
    if (!chatIds.contains(_currentChatId)) {
      chatIds.insert(0, _currentChatId!);
      await prefs.setStringList('ai_chat_ids', chatIds);
    }

    // Save chat title (first user message)
    final firstMessage = _messages.firstWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage(
        text: 'New Chat',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    await prefs.setString(
      'ai_chat_title_$_currentChatId',
      firstMessage.text.length > 30
          ? '${firstMessage.text.substring(0, 30)}...'
          : firstMessage.text,
    );
  }

  // ✅ GET ALL CHAT HISTORY
  Future<List<Map<String, String>>> _getAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatIds = prefs.getStringList('ai_chat_ids') ?? [];

    List<Map<String, String>> chats = [];
    for (String chatId in chatIds) {
      final title = prefs.getString('ai_chat_title_$chatId') ?? 'New Chat';
      chats.add({'id': chatId, 'title': title});
    }

    return chats;
  }

  Future<void> _getAIResponse(String userMessage) async {
    if (_aiService == null) {
      _handleError("AI Service not initialized");
      return;
    }

    setState(() {
      _isTyping = true;
      _stopGenerating = false;
    });

    _thinkingAnimationController.repeat(reverse: true);

    try {
      final aiResponse = await _aiService!.sendMessage(userMessage);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      _thinkingAnimationController.stop();
      _thinkingAnimationController.value = 1.0;

      if (aiResponse.success) {
        _messages.add(
          ChatMessage(text: "", isUser: false, timestamp: DateTime.now()),
        );

        _typeMessage(aiResponse.content);
      } else {
        _handleError(aiResponse.error ?? "Unknown error");
      }
    } catch (e) {
      if (!mounted) return;
      _thinkingAnimationController.stop();
      _thinkingAnimationController.value = 1.0;
      _handleError("Network error: $e");
    }
  }

  void _handleError(String error) {
    setState(() {
      _isTyping = false;
    });

    _messages.add(
      ChatMessage(
        text: "Sorry, I encountered an error. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    print("AI Chat Error: $error");
  }

  void _typeMessage(String fullText) {
    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_stopGenerating || charIndex >= fullText.length) {
        timer.cancel();
        setState(() {
          _stopGenerating = false;
        });
        _saveChatHistory(); // ✅ SAVE AFTER MESSAGE COMPLETE
        return;
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _messages.last.text = fullText.substring(0, charIndex + 1);
      });

      charIndex++;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    _getAIResponse(text);
    _saveChatHistory(); // ✅ SAVE AFTER SENDING
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ START NEW CHAT
  void _startNewChat() {
    Navigator.pop(context); // Close drawer
    setState(() {
      _messages.clear();
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  // ✅ LOAD PREVIOUS CHAT
  void _loadPreviousChat(String chatId) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatScreen(initialMessage: "", chatId: chatId),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _thinkingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return Scaffold(
      key: _scaffoldKey, // ✅ ADD THIS
      backgroundColor: AppTheme.scaffoldBg(isDark),
      // ✅ ADD DRAWER
      drawer: Drawer(
        backgroundColor: AppTheme.cardBg(isDark),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        colors: [HexColor("#2A1810"), HexColor("#1A1A1A")],
                      )
                    : null,
                color: isDark ? null : const Color(0xFFE8DDD0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "images/robot.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Grey AI",
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Chat History",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ NEW CHAT BUTTON
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: isDark ? HexColor("#FF6B9D") : const Color(0xFFFF8C00),
              ),
              title: Text(
                "New Chat",
                style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
              ),
              onTap: _startNewChat,
            ),

            Divider(color: isDark ? HexColor("#3A3A3A") : const Color(0xFFD9CFC4)),

            // ✅ CHAT HISTORY LIST
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _getAllChats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No previous chats",
                        style: GoogleFonts.poppins(
                          color: AppTheme.textHint(isDark),
                          fontSize: 14.0,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final chat = snapshot.data![index];
                      final isCurrentChat = chat['id'] == _currentChatId;

                      return ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: isCurrentChat
                              ? (isDark ? HexColor("#FF6B9D") : const Color(0xFFFF8C00))
                              : AppTheme.iconColorSubtle(isDark),
                        ),
                        title: Text(
                          chat['title']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: isCurrentChat
                                ? AppTheme.textPrimary(isDark)
                                : AppTheme.textSecondary(isDark),
                            fontWeight: isCurrentChat
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isCurrentChat,
                        selectedTileColor: isDark ? HexColor("#2A2A2A") : const Color(0xFFE8DDD0),
                        onTap: () => _loadPreviousChat(chat['id']!),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: isDark ? HexColor("#2A1810") : const Color(0xFFFAF5F0),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            // ✅ OPEN DRAWER INSTEAD OF BACK
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Icon(
            Icons.menu,
            color: AppTheme.textPrimary(isDark),
            size: 24,
          ), // ✅ CHANGED TO MENU ICON
        ),
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _thinkingAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _isTyping ? _thinkingAnimation.value : 1.0,
                  child: ClipOval(
                    child: Image.asset(
                      "images/robot.png",
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grey",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isTyping ? "Thinking..." : "Online",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // ✅ WRAP BODY IN GESTUREDETECTOR TO DISMISS KEYBOARD
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [HexColor("#2A1810"), Colors.black],
                  )
                : null,
            color: isDark ? null : AppTheme.scaffoldBg(isDark),
          ),
          child: Column(
            children: [
              // Messages List
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          "Start a conversation with Grey",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textHint(isDark),
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
              ),

              // Stop Generating Button
              if (_isTyping ||
                  (_messages.isNotEmpty &&
                      !_messages.last.isUser &&
                      _messages.last.text.isNotEmpty &&
                      !_stopGenerating))
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _stopGenerating = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? HexColor("#2A2A2A") : const Color(0xFFE8DDD0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? HexColor("#3A3A3A") : const Color(0xFFCFC4B5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : const Color(0xFF1A1008),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Stop generating...",
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Input Field
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill(isDark),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.border(isDark), width: 1),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 14.0,
                            ),
                            decoration: InputDecoration(
                              hintText: "Send a message.",
                              hintStyle: GoogleFonts.poppins(
                                color: AppTheme.textHint(isDark),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                              ),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppTheme.iconColorSubtle(isDark),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            ClipOval(
              child: Image.asset(
                "images/robot.png",
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border(isDark), width: 1),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (!message.isUser && message.text.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.content_copy,
                          size: 16,
                          color: AppTheme.iconColorSubtle(isDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.share,
                          size: 16,
                          color: AppTheme.iconColorSubtle(isDark),
                        ),
                      ),
                    ],
                  ),
                if (message.isUser)
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textHint(isDark),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
