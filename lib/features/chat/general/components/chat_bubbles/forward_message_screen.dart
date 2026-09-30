import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/contact/services/contact_sync_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class ForwardMessageScreen extends StatefulWidget {
  final ChatMessage message;
  final String currentChatId;

  const ForwardMessageScreen({
    Key? key,
    required this.message,
    required this.currentChatId,
  }) : super(key: key);

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  List<RegisteredUser> registeredUsers = [];
  List<String> selectedUserIds = [];
  bool isLoading = true;
  bool isForwarding = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRegisteredContacts();
  }

  Future<void> _loadRegisteredContacts() async {
    try {
      final contactService = ContactSyncService();
      final response = await contactService.performFullContactSync();

      setState(() {
        registeredUsers = response.registeredUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to load contacts: $e");
      setState(() => isLoading = false);
    }
  }

  List<RegisteredUser> get filteredUsers {
    if (searchQuery.isEmpty) return registeredUsers;
    return registeredUsers.where((user) {
      final name = user.username.toLowerCase();
      final phone = user.phone.toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return ApiStrings.baseUriImage + imageUrl;
  }

  bool _isLikelyObjectId(String id) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id);
  }

  Future<void> _manualForwardToChats({
    required String token,
    required List<String> targetChatIds,
  }) async {
    final msg = widget.message;
    final String contentType = msg.isImage
        ? 'image'
        : msg.isVideo
        ? 'video'
        : (msg.isVoiceNote || msg.isAudioFile)
        ? 'audio'
        : msg.isDocument
        ? 'document'
        : msg.text.startsWith('__CONTACT__:')
        ? 'contact'
        : 'text';
    final List<String> attachmentUrls = [
      if (msg.isImage) ...(msg.imageUrls ?? const <String>[]),
      if (msg.isVideo && msg.videoUrl != null) msg.videoUrl!,
      if ((msg.isVoiceNote || msg.isAudioFile) && msg.audioUrl != null)
        msg.audioUrl!,
      if (msg.isDocument && msg.documentUrl != null) msg.documentUrl!,
    ].whereType<String>().where((e) => e.isNotEmpty).toList();

    for (final chatId in targetChatIds) {
      final response = await http.post(
        Uri.parse(ApiStrings.sendMessageToApi),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "chatId": chatId,
          "content": msg.text.isNotEmpty ? msg.text : " ",
          "contentType": contentType,
          if (attachmentUrls.isNotEmpty) "attachmentUrls": attachmentUrls,
          "isForwarded": true,
          "forwardCount": 1,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Manual forward failed (${response.statusCode})');
      }
    }
  }

  // ✅ FIX: Uses POST /api/v1/message/forward with the correct payload.
  // The endpoint accepts { messageId, chatIds[] } and handles forwarding
  // server-side, setting isForwarded: true automatically.
  Future<void> _forwardMessage() async {
    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one contact")),
      );
      return;
    }

    setState(() => isForwarding = true);

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      if (token == null || token.isEmpty) {
        throw Exception('Auth token missing');
      }

      // Step 1: Resolve each selected userId → chatId by accessing the chat
      final List<String> targetChatIds = [];

      for (final userId in selectedUserIds) {
        final user = registeredUsers.firstWhere((u) => u.id == userId);

        final chatResponse = await http.post(
          Uri.parse(ApiStrings.accessNewChat),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"phone": user.phone}),
        );

        if (chatResponse.statusCode == 200) {
          final chatData = jsonDecode(chatResponse.body);
          final chatId = chatData['_id']?.toString();
          if (chatId != null && chatId.isNotEmpty) {
            targetChatIds.add(chatId);
          }
        }
      }

      if (targetChatIds.isEmpty) {
        throw Exception("Could not resolve any chat IDs for selected contacts");
      }

      // Step 2: Forward with backend contract payload.
      http.Response? forwardResponse;
      if (_isLikelyObjectId(widget.message.id)) {
        forwardResponse = await http.post(
          Uri.parse(ApiStrings.forwardMessage),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "messageId": widget.message.id,
            "chatIds": targetChatIds,
            "isForwarded": true,
          }),
        );
      }
      // Backward-compat fallback for older backend payload contracts.
      if (forwardResponse != null && forwardResponse.statusCode == 400) {
        forwardResponse = await http.post(
          Uri.parse(ApiStrings.forwardMessage),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "messageIds": [widget.message.id],
            "targetChatIds": targetChatIds,
            "isForwarded": true,
          }),
        );
      }

      if (forwardResponse == null ||
          (forwardResponse.statusCode != 200 &&
              forwardResponse.statusCode != 201)) {
        await _manualForwardToChats(token: token, targetChatIds: targetChatIds);
      } else {
        debugPrint('✅ Forward response: ${forwardResponse.body}');
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Message forwarded to ${targetChatIds.length} "
            "${targetChatIds.length == 1 ? 'contact' : 'contacts'}",
          ),
          backgroundColor: HexColor("#1A7F4B"),
        ),
      );
    } catch (e) {
      debugPrint('❌ Forward error: $e');
      if (!mounted) return;
      setState(() => isForwarding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to forward message: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/app_bar_gredient.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Forward to...",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Forwarded message preview ────────────────────────────────────
          // ✅ NEW: shows the message being forwarded so the user knows what
          // they are sending before confirming.
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: HexColor("#2E2E2E"),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: HexColor("#FB8830"), width: 3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.forward, color: HexColor("#FB8830"), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forwarding",
                        style: GoogleFonts.poppins(
                          color: HexColor("#FB8830"),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getMessagePreview(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search contacts...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: HexColor("#2E2E2E"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Selected count badge ──────────────────────────────────────────
          if (selectedUserIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: HexColor("#1A7F4B"),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${selectedUserIds.length} selected",
                    style: GoogleFonts.poppins(
                      color: HexColor("#1A7F4B"),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // ── Contact list ──────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor("#FF6B00"),
                    ),
                  )
                : filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? "No registered contacts found"
                              : "No contacts match your search",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 16,
                          ),
                        ),
                        if (searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Sync your contacts to see who's on Qiktalk",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = selectedUserIds.contains(user.id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedUserIds.remove(user.id);
                            } else {
                              selectedUserIds.add(user.id);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? HexColor("#1A7F4B").withOpacity(0.2)
                                : HexColor("#2E2E2E"),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? HexColor("#1A7F4B")
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: HexColor("#FB8830"),
                                backgroundImage:
                                    user.profilePicture != null &&
                                        user.profilePicture!.isNotEmpty
                                    ? NetworkImage(
                                        _getFullImageUrl(user.profilePicture),
                                      )
                                    : null,
                                child:
                                    user.profilePicture == null ||
                                        user.profilePicture!.isEmpty
                                    ? Text(
                                        user.username.isNotEmpty
                                            ? user.username[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.username,
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textPrimary(isDark),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.phone,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? HexColor("#1A7F4B")
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? HexColor("#1A7F4B")
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ── Forward button ────────────────────────────────────────────────
          if (selectedUserIds.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: isForwarding ? null : _forwardMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#1A7F4B"),
                    disabledBackgroundColor: HexColor(
                      "#1A7F4B",
                    ).withOpacity(0.5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isForwarding
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.forward,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Forward",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns a short human-readable preview of the message being forwarded.
  String _getMessagePreview() {
    final msg = widget.message;
    if (msg.isVoiceNote) return "🎤 Voice message";
    if (msg.isAudioFile) return "🎵 Audio file";
    if (msg.isImage) return "🖼️ Photo";
    if (msg.isVideo) return "🎥 Video";
    if (msg.isDocument) return "📄 ${msg.documentName ?? 'Document'}";
    return msg.text.isNotEmpty ? msg.text : "Message";
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
