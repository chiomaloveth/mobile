import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/services/community_api_service/community_api_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/message_sound_service.dart';

class _AMsg {
  final String id;
  final String content;
  final String senderName;
  final String senderAvatar;
  final DateTime createdAt;
  final bool isMe;

  _AMsg({
    required this.id,
    required this.content,
    required this.senderName,
    required this.senderAvatar,
    required this.createdAt,
    required this.isMe,
  });
}

/// Announcement channel for a community.
/// - Admins can POST messages via POST /chat/community/:id/announcement
/// - All members see the message history (loaded via GET chat history)
/// - Non-admins see a read-only banner and cannot send
class CommunityAnnouncementScreen extends StatefulWidget {
  final String communityId;
  final String communityName;
  final bool isAdmin;

  const CommunityAnnouncementScreen({
    super.key,
    required this.communityId,
    required this.communityName,
    required this.isAdmin,
  });

  @override
  State<CommunityAnnouncementScreen> createState() =>
      _CommunityAnnouncementScreenState();
}

class _CommunityAnnouncementScreenState
    extends State<CommunityAnnouncementScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _api = CommunityApiService();
  final _save = SaveValues();

  List<_AMsg> _msgs = [];
  bool _loading = true;
  bool _sending = false;
  String _myId = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _myId = await _save.getString(AppPreferenceHelper.ID) ?? '';
    await _loadMsgs();
  }

  // ── Load history — reuse GET chat/history/:chatId ─────────────────────────

  Future<void> _loadMsgs() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http
          .get(
            Uri.parse('${ApiStrings.getChatHistory}${widget.communityId}'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List raw = body is Map
            ? (body['messages'] as List? ?? body['data'] as List? ?? [])
            : (body as List);

        final parsed = raw.map((m) {
          final map = m as Map<String, dynamic>;
          final sender = map['sender'];
          final sid = sender is Map
              ? sender['_id'] as String? ?? ''
              : sender as String? ?? '';
          final sname = sender is Map
              ? sender['username'] as String? ?? 'Admin'
              : 'Admin';
          final savatar = sender is Map
              ? sender['profilePicture'] as String? ?? ''
              : '';
          return _AMsg(
            id: map['_id'] as String? ?? '',
            content: map['content'] as String? ?? '',
            senderName: sname,
            senderAvatar: savatar,
            createdAt:
                DateTime.tryParse(map['createdAt'] as String? ?? '') ??
                DateTime.now(),
            isMe: sid == _myId,
          );
        }).toList();

        setState(() {
          _msgs = parsed;
          _loading = false;
        });
        _scrollBottom();
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('❌ loadAnnouncements: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Send (admin) ───────────────────────────────────────────────────────────

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    MessageSoundService().playSendSound();

    setState(() => _sending = true);
    _controller.clear();

    // Optimistic
    final temp = _AMsg(
      id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
      content: text,
      senderName: 'You',
      senderAvatar: '',
      createdAt: DateTime.now(),
      isMe: true,
    );
    setState(() => _msgs.add(temp));
    _scrollBottom();

    final result = await _api.postAnnouncement(
      communityId: widget.communityId,
      content: text,
    );

    if (!mounted) return;
    setState(() => _sending = false);

    if (result['success'] == true) {
      await _loadMsgs();
    } else {
      setState(() {
        _msgs.removeWhere((m) => m.id == temp.id);
        _controller.text = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _imgUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#141414'),
      body: Column(
        children: [
          _appBar(),
          // Read-only banner for non-admins
          if (!widget.isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: HexColor('#FB8830').withOpacity(0.12),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: HexColor('#FB8830'),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Only admins can send messages here',
                    style: GoogleFonts.poppins(
                      color: HexColor('#FB8830'),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor('#FB8830'),
                    ),
                  )
                : _msgs.isEmpty
                ? _empty()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) => _bubble(_msgs[i]),
                  ),
          ),

          if (widget.isAdmin) _inputBar(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HexColor('#3A1D07'), HexColor('#171516')],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark)),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HexColor('#FB8830').withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: HexColor('#FB8830'),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Announcements',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.communityName,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: HexColor('#FB8830').withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.poppins(
                      color: HexColor('#FB8830'),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_outlined, color: HexColor('#3A3A3A'), size: 64),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: GoogleFonts.poppins(
              color: HexColor('#787880'),
              fontSize: 15,
            ),
          ),
          if (widget.isAdmin) ...[
            const SizedBox(height: 8),
            Text(
              'Send a broadcast to all members',
              style: GoogleFonts.poppins(
                color: HexColor('#5A5A5A'),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bubble(_AMsg msg) {
    final time = DateFormat('hh:mm a').format(msg.createdAt.toLocal());
    final avatarUrl = _imgUrl(msg.senderAvatar);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HexColor('#FB8830').withOpacity(0.2),
              image: avatarUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                  : null,
            ),
            child: avatarUrl.isEmpty
                ? Icon(
                    Icons.admin_panel_settings_outlined,
                    color: HexColor('#FB8830'),
                    size: 18,
                  )
                : null,
          ),

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: HexColor('#FB8830').withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: HexColor('#FB8830').withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        color: HexColor('#FB8830'),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        msg.senderName,
                        style: GoogleFonts.poppins(
                          color: HexColor('#FB8830'),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.content,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#2A2A2A'),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Write an announcement...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.campaign_outlined,
                      color: HexColor('#FB8830'),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _sending ? HexColor('#3A1D07') : HexColor('#FB8830'),
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
