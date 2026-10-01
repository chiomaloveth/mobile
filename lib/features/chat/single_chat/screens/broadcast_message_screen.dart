import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BroadcastMessageScreen extends StatefulWidget {
  final String broadcastId;
  final String broadcastName;
  final int memberCount;
  final List<BroadcastMember> members;

  const BroadcastMessageScreen({
    super.key,
    required this.broadcastId,
    required this.broadcastName,
    required this.memberCount,
    required this.members,
  });

  @override
  State<BroadcastMessageScreen> createState() => _BroadcastMessageScreenState();
}

class _BroadcastMessageScreenState extends State<BroadcastMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  List<BroadcastMember> _broadcastMembers = [];

  bool _isLoading = true;
  bool _isSending = false;
  String _myUserId = '';

  // ── Socket ──────────────────────────────────────────────────────────────────
  IO.Socket? _socket;

  // ── Hive ────────────────────────────────────────────────────────────────────
  late Box<String> _msgBox;

  @override
  void initState() {
    super.initState();
    // Use the already-loaded members passed from the broadcast list —
    // no need for a redundant API call that was reading the wrong field.
    _broadcastMembers = List.from(widget.members);
    _init();
  }

  Future<void> _init() async {
    final id = await SaveValues().getString(AppPreferenceHelper.ID);
    _myUserId = id ?? '';

    _msgBox = await Hive.openBox<String>('broadcast_messages');

    // Show cached messages instantly, then load fresh history + socket
    _loadFromHive();

    await _connectSocket();
    await _loadHistory();
  }

  // ── Socket ──────────────────────────────────────────────────────────────────
  IO.Socket? _listeningSocket;
  bool _socketListenersAttached = false;

  Future<void> _connectSocket() async {
    final gs = GlobalSocketService();
    if (gs.socket == null || !gs.isConnected) {
      await gs.connect();
      int attempts = 0;
      while (!gs.isConnected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
    }
    _socket = gs.socket;
    if (_socket == null) return;

    if (_socket!.connected) {
      _socket!.emit('join chat', widget.broadcastId);
      _setupSocketListeners();
    } else {
      _socket!.onConnect((_) {
        _socket?.emit('join chat', widget.broadcastId);
        _setupSocketListeners();
      });
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;
    if (_socketListenersAttached && _listeningSocket == _socket) return;
    _socketListenersAttached = true;
    _listeningSocket = _socket;

    _socket!.on('message received', (data) async {
      if (!mounted) return;
      if (!mounted) return;
      try {
        // Filter to this broadcast's chatId only
        final chatId = (data['chat']?['_id'] ?? data['chatId'] ?? '')
            .toString();
        if (chatId != widget.broadcastId) return;

        final messageId = data['_id']?.toString();
        if (messageId == null || messageId.isEmpty) return;

        final senderId = (data['sender']?['_id'] ?? data['sender'] ?? '')
            .toString();
        final isMe = senderId == _myUserId;
        final tempId = data['tempId']?.toString();

        setState(() {
          if (isMe) {
            // Replace temp optimistic bubble with server-confirmed message
            int idx = -1;
            if (tempId != null) {
              idx = _messages.indexWhere((m) => m['_id'] == tempId);
            }
            if (idx == -1) {
              idx = _messages.indexWhere(
                (m) =>
                    m['_isTemp'] == true &&
                    m['content'] == (data['content'] ?? '').toString(),
              );
            }
            if (idx != -1) {
              _messages[idx] = {
                ...Map<String, dynamic>.from(data as Map),
                '_isTemp': false,
                '_id': messageId,
              };
            }
            // Do NOT add a second copy — we already showed the optimistic bubble
          } else {
            // ── Incoming from a recipient ──
            if (!_messages.any((m) => m['_id'] == messageId)) {
              _messages.add(Map<String, dynamic>.from(data as Map));
            }
          }
        });

        _scrollToBottom();
        await _saveToHive();

        // Mark as read
        if (_socket?.connected == true) {
          _socket!.emit('mark as read', {
            'chatId': widget.broadcastId,
            'userId': _myUserId,
            'messageIds': [messageId],
          });
        }
      } catch (e) {
        debugPrint('❌ BroadcastMessageScreen: message received parse — $e');
      }
    });
    // Delivery tick: message delivered/read
    _socket!.on('message delivered', (data) {
      if (!mounted) return;
      final messageId = (data['messageId'] ?? '').toString();
      if (messageId.isEmpty) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == messageId);
        if (idx != -1) _messages[idx]['_delivered'] = true;
      });
    });
  }

  // ── Hive cache ───────────────────────────────────────────────────────────────
  void _loadFromHive() {
    try {
      final raw = _msgBox.get(widget.broadcastId);
      if (raw == null || raw.isEmpty) return;
      final List decoded = jsonDecode(raw) as List;
      final msgs = decoded.cast<Map<String, dynamic>>();
      if (msgs.isNotEmpty && mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ _loadFromHive: $e');
    }
  }

  Future<void> _saveToHive() async {
    try {
      final encoded = jsonEncode(
        _messages.where((m) => m['_isTemp'] != true).toList(),
      );
      await _msgBox.put(widget.broadcastId, encoded);
    } catch (e) {
      debugPrint('⚠️ _saveToHive: $e');
    }
  }

  // ── History ──────────────────────────────────────────────────────────────────
  Future<void> _loadHistory() async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http
          .get(
            Uri.parse('${ApiStrings.getChatHistory}${widget.broadcastId}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List msgs = decoded['messages'] ?? decoded;
        setState(() {
          _messages = msgs.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        await _saveToHive();
        _scrollToBottom();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('⚠️ _loadHistory: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Send message ─────────────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = <String, dynamic>{
      '_id': tempId,
      'content': text,
      'sender': {'_id': _myUserId},
      'createdAt': DateTime.now().toIso8601String(),
      '_isTemp': true,
    };

    setState(() {
      _messages.add(tempMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      // ── Get unique recipient IDs (excluding self) ────────────────────────
      final recipientIds = _broadcastMembers
          .map((m) => m.id)
          .where((id) => id.isNotEmpty && id != _myUserId)
          .toSet()
          .toList();

      if (recipientIds.isEmpty) {
        _removeTempAndShowError(tempId, 'No recipients in this broadcast');
        return;
      }

      // ── Send broadcast via single API request ────────────────────────────
      // Backend automatically fan-outs to individual 1-to-1 chats for each recipient
      final requestBody = {
        'chatId': widget.broadcastId,
        'content': text,
        'userIds': recipientIds,
      };

      final response = await http
          .post(
            Uri.parse('${ApiStrings.baseUri}message'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final serverId = (data['_id'] ?? data['data']?['_id'] ?? tempId)
            .toString();

        setState(() {
          final idx = _messages.indexWhere((m) => m['_id'] == tempId);
          if (idx != -1) {
            _messages[idx] = {
              ...Map<String, dynamic>.from(data is Map ? data : {}),
              '_id': serverId,
              'content': text,
              'sender': {'_id': _myUserId},
              'createdAt': tempMsg['createdAt'],
              '_isTemp': false,
              '_delivered': true,
            };
          }
          _isSending = false;
        });
        await _saveToHive();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Broadcast sent to ${recipientIds.length} recipient(s)',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: HexColor("#1A7F4B"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _removeTempAndShowError(tempId, 'Failed to send broadcast');
      }
    } catch (e) {
      debugPrint('❌ _sendMessage: $e');
      _removeTempAndShowError(tempId, 'Network error');
    }
  }

  void _removeTempAndShowError(String tempId, String msg) {
    if (!mounted) return;
    setState(() {
      _messages.removeWhere((m) => m['_id'] == tempId);
      _isSending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/app_bar_gredient.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: HexColor("#FB8830"),
                    child: const Icon(
                      Icons.campaign,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.broadcastName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.memberCount} recipients',
                          style: GoogleFonts.poppins(
                            color: HexColor("#FB8830"),
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

          // ── Info banner ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppTheme.cardBg(isDark),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: HexColor("#FB8830"), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Messages are delivered as private DMs to each recipient.',
                    style: GoogleFonts.poppins(
                      color: HexColor("#9A9A9A"),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor("#FB8830"),
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: HexColor("#5F5F5F"),
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Send a message to all ${widget.memberCount} recipients',
                          style: GoogleFonts.poppins(
                            color: HexColor("#7A7A7A"),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(_messages[index]),
                  ),
          ),

          // ── Input ────────────────────────────────────────────────────────────
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isTemp = msg['_isTemp'] == true;
    final isDelivered = msg['_delivered'] == true;
    final content = (msg['content'] ?? '').toString();
    final timeStr = _formatTime((msg['createdAt'] ?? '').toString());

    // Determine if the message is from me
    final senderId = (msg['sender']?['_id'] ?? msg['sender'] ?? '').toString();
    final isMe = senderId == _myUserId || isTemp;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? (isTemp
                    ? HexColor("#1A7F4B").withOpacity(0.5)
                    : HexColor("#1A7F4B"))
              : AppTheme.cardBg(
                  Theme.of(context).brightness == Brightness.dark,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: GoogleFonts.poppins(
                color: isMe
                    ? Colors.white
                    : AppTheme.textPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isTemp
                        ? Icons.access_time
                        : (isDelivered ? Icons.done_all : Icons.done),
                    color: isDelivered && !isTemp
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                    size: 12,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("images/app_bar_gredient.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Send to ${widget.memberCount} recipients...',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _isSending ? null : _sendMessage,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: HexColor("#1A7F4B"),
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Image.asset(
                        'images/send_chat.png',
                        width: 22,
                        height: 22,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dispose ──────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    if (_socket?.connected == true) {
      _socket!.emit('leave chat', widget.broadcastId);
    }
    _socketListenersAttached = false;
    _listeningSocket = null;
    _messageController.dispose();
    _scrollController.dispose();
    _msgBox.close();
    super.dispose();
  }
}
