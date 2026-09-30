import 'dart:io'; // ✅ BUG1 FIX: needed for Image.file() in reply preview
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/group_chat/screens/join_group_screen.dart';

class ChatMessageBubble extends StatefulWidget {
  final String text;
  final bool isMe;
  final bool isRead;
  final bool isEdited;
  final String timestamp;
  final String? replyToMessageId;
  final VoidCallback? onLongPress;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName;
  final String? replyToMediaType;
  final String? replyToThumbnailUrl;
  final Function(String direction)? onSwipe;
  final VoidCallback? onReplyTap;
  final MessageStatus? status;
  final bool isRecipientOnline;
  final String? senderName;
  final Color? bubbleColor; // sender bubble fill override
  final Color? receiverBubbleColor; // receiver bubble fill override
  final Color? senderGlowColor; // vivid glow for sender (always visible)
  final Color? receiverGlowColor; // vivid glow for receiver (always visible)

  // ✅ Forwarded message flag
  final bool isForwarded;

  // ✅ Mentions
  final List<String> mentionedUserIds;
  final String myUserId;

  // privacy
  final bool readReceiptsEnabled;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isEdited = false,
    this.onLongPress,
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.replyToMessageId,
    this.onSwipe,
    this.onReplyTap,
    this.status,
    this.isRecipientOnline = false,
    this.senderName,
    this.bubbleColor,
    this.receiverBubbleColor,
    this.senderGlowColor,
    this.receiverGlowColor,
    this.isForwarded = false,
    this.mentionedUserIds = const [],
    this.myUserId = '',
    this.readReceiptsEnabled = true,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool isExpanded = false;
  final int truncateLength = 100;
  double _swipeOffset = 0;

  static final _urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);

  static final _mentionRegex = RegExp(r'@\S+');

  List<_TextSegment> _parseSegments(String text) {
    final segments = <_TextSegment>[];
    // Merge URL and mention matches, sorted by position
    final allMatches = [
      ..._urlRegex
          .allMatches(text)
          .map((m) => _Match(m.start, m.end, m.group(0)!, _SegmentType.url)),
      ..._mentionRegex
          .allMatches(text)
          .map(
            (m) => _Match(m.start, m.end, m.group(0)!, _SegmentType.mention),
          ),
    ]..sort((a, b) => a.start.compareTo(b.start));

    int lastEnd = 0;
    for (final match in allMatches) {
      if (match.start < lastEnd) continue; // skip overlaps
      if (match.start > lastEnd) {
        segments.add(
          _TextSegment(
            text.substring(lastEnd, match.start),
            _SegmentType.plain,
          ),
        );
      }
      segments.add(_TextSegment(match.text, match.type));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      segments.add(_TextSegment(text.substring(lastEnd), _SegmentType.plain));
    }
    if (segments.isEmpty) segments.add(_TextSegment(text, _SegmentType.plain));
    return segments;
  }

  void _handleUrlTap(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (uri.host == 'qiktalk.app' && uri.path == '/join') {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JoinGroupScreen(inviteCode: code)),
        );
        return;
      }
    }

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool get _isEmojiOnly {
    final emojiRegex = RegExp(
      r'^[\s\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}\u{FE00}-\u{FEFF}'
      r'\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA9F}'
      r'\u{200D}\u{FE0F}]+$',
      unicode: true,
    );
    return emojiRegex.hasMatch(widget.text.trim()) &&
        widget.text.trim().isNotEmpty;
  }

  double get _emojiFontSize {
    final text = widget.text.trim();
    final runeCount = text.runes.length;
    if (runeCount <= 2) return 48;
    if (runeCount <= 6) return 36;
    return 28;
  }

  String _formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getBubbleColor(bool isDark) {
    if (_isEmojiOnly) return Colors.transparent;

    if (widget.isMe) {
      // Sender bubble — use custom color or theme sender color
      if (widget.bubbleColor != null) return widget.bubbleColor!;
      if (isDark) return HexColor("#1B1B1B");
      return Colors.white;
    } else {
      // Receiver bubble — use theme receiver color if provided
      if (widget.receiverBubbleColor != null)
        return widget.receiverBubbleColor!;
      if (isDark) return HexColor("#232323");
      return Colors.white;
    }
  }

  /// Always returns a vivid, visible glow color.
  /// Priority: explicit glow param → derive from bubble color → default accent.
  Color _resolvedGlow({required bool isSender}) {
    // 1. Use the explicitly passed vivid glow color if available
    final explicit = isSender
        ? widget.senderGlowColor
        : widget.receiverGlowColor;
    if (explicit != null) return explicit;

    // 2. Derive from the bubble fill color — boost if too dark
    final base = isSender
        ? (widget.bubbleColor ?? HexColor("#FB8830"))
        : (widget.receiverBubbleColor ?? HexColor("#1A7F4B"));

    final hsl = HSLColor.fromColor(base);
    if (hsl.lightness < 0.28) {
      // Too dark — use default accents
      return isSender ? HexColor("#FB8830") : HexColor("#1A7F4B");
    }
    // Boost saturation and lightness for a vivid glow
    return hsl
        .withSaturation((hsl.saturation + 0.25).clamp(0.5, 1.0))
        .withLightness((hsl.lightness + 0.18).clamp(0.38, 0.78))
        .toColor();
  }

  List<BoxShadow> _getBoxShadow(bool isDark) {
    if (_isEmojiOnly) return [];

    final Color glow = _resolvedGlow(isSender: widget.isMe);

    return [
      BoxShadow(
        color: glow.withValues(alpha: isDark ? 0.60 : 0.45),
        offset: const Offset(2, 4),
        blurRadius: isDark ? 14 : 18,
        spreadRadius: isDark ? -1 : 0,
      ),
    ];
  }

  Widget _buildStatusTicks(bool isDark) {
    final Color subtleColor = isDark ? Colors.white38 : const Color(0xFF9E8070);
    final Color deliveredColor = isDark
        ? Colors.white54
        : const Color(0xFF8A7060);

    // ── 1. Still uploading / in flight ──────────────────────────────────────
    if (widget.status == MessageStatus.sending) {
      return Icon(Icons.access_time_rounded, size: 12, color: subtleColor);
    }

    // ── 2. Send/upload failed ────────────────────────────────────────────────
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }

    // privacy check: if read receipts are disabled, show grey ticks only
    if (!widget.readReceiptsEnabled) {
      if (widget.status == MessageStatus.delivered ||
          widget.status == MessageStatus.read ||
          widget.isRead) {
        return _doubleTick(color: deliveredColor); // always grey
      }
      return Icon(Icons.check, size: 13, color: deliveredColor);
    }

    // Blue double tick = read
    if (widget.status == MessageStatus.read || widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB)); // WhatsApp blue
    }

    // Grey double tick = delivered to recipient's device (2 grey ticks)
    // isRecipientOnline alone does NOT trigger this — delivery must be confirmed
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: deliveredColor);
    }

    // Single grey tick = sent to server only
    if (widget.status == MessageStatus.sent) {
      return Icon(Icons.check, size: 13, color: deliveredColor);
    }

    // ── 6. Fallback: Single grey tick ──────────────────────────────────────────
    return Icon(Icons.check, size: 13, color: deliveredColor);
  }

  Widget _doubleTick({required Color color}) {
    return SizedBox(
      width: 18,
      height: 13,
      child: Stack(
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
        ],
      ),
    );
  }

  Widget _buildMessageText(String displayText, bool isDark) {
    final double baseFontSize = _isEmojiOnly ? _emojiFontSize : 15;
    final Color plainTextColor = isDark
        ? Colors.white
        : (widget.isMe ? const Color(0xFF2A1A0A) : const Color(0xFF1A1008));
    final segments = _parseSegments(displayText);
    final spans = <InlineSpan>[];

    for (final seg in segments) {
      if (seg.type == _SegmentType.url) {
        final url = seg.text;
        final isInviteLink = url.contains('qiktalk.app/join');
        spans.add(
          TextSpan(
            text: url,
            style: TextStyle(
              color: isInviteLink
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF82B4FF),
              fontSize: baseFontSize,
              height: 1.4,
              decoration: TextDecoration.underline,
              decorationColor: isInviteLink
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF82B4FF),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _handleUrlTap(url),
          ),
        );
      } else if (seg.type == _SegmentType.mention) {
        // Highlight @mention — green if it's mentioning the current user, orange otherwise
        final isMentioningMe =
            widget.mentionedUserIds.isNotEmpty &&
            widget.mentionedUserIds.any((id) => id == widget.myUserId);
        spans.add(
          TextSpan(
            text: seg.text,
            style: TextStyle(
              color: isMentioningMe
                  ? const Color(0xFF1A7F4B)
                  : const Color(0xFFFF6900),
              fontSize: baseFontSize,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: seg.text,
            style: TextStyle(
              color: plainTextColor,
              fontSize: baseFontSize,
              height: 1.4,
            ),
          ),
        );
      }
    }

    return RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool needTruncate = widget.text.length > truncateLength;
    final String displayText = (!isExpanded && needTruncate)
        ? "${widget.text.substring(0, truncateLength)}..."
        : widget.text;

    // Adaptive colors
    final Color subtleTextColor = isDark
        ? Colors.white54
        : const Color(0xFF8A7060);
    final Color replyBgColor = isDark
        ? Colors.black26
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipeOffset += details.delta.dx;
          if (_swipeOffset > 80) _swipeOffset = 80;
          if (_swipeOffset < -80) _swipeOffset = -80;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_swipeOffset.abs() > 50) {
          widget.onSwipe?.call(_swipeOffset > 0 ? 'right' : 'left');
        }
        setState(() => _swipeOffset = 0);
      },
      child: Transform.translate(
        offset: Offset(_swipeOffset, 0),
        child: Stack(
          children: [
            if (_swipeOffset.abs() > 20)
              Positioned(
                right: widget.isMe ? null : 10,
                left: widget.isMe ? 10 : null,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.reply,
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: _swipeOffset.abs() / 80,
                  ),
                  size: 24,
                ),
              ),

            Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _getBubbleColor(isDark),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(widget.isMe ? 16 : 0),
                          bottomRight: Radius.circular(widget.isMe ? 0 : 16),
                        ),
                        boxShadow: _getBoxShadow(isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sender name — only for received group messages
                          if (widget.senderName != null && !widget.isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.senderName!,
                                style: GoogleFonts.poppins(
                                  color: HexColor('#1A7F4B'),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // Forwarded label
                          if (widget.isForwarded)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .shortcut, // ← WhatsApp-style forward arrow
                                    size: 13,
                                    color: subtleTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Forwarded",
                                    style: GoogleFonts.poppins(
                                      color: subtleTextColor,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Reply preview
                          if (widget.replyToText != null)
                            GestureDetector(
                              onTap: widget.onReplyTap,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: replyBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: widget.replyToIsMe == true
                                          ? HexColor("#1A7F4B")
                                          : HexColor("#FF6B00"),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.replyToSenderName ??
                                          (widget.replyToIsMe == true
                                              ? "You"
                                              : "Them"),
                                      style: TextStyle(
                                        color: widget.replyToIsMe == true
                                            ? HexColor("#1A7F4B")
                                            : HexColor("#FF6B00"),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (widget.replyToMediaType !=
                                            null) ...[
                                          // ✅ BUG1 FIX: show thumbnail for image (local OR remote)
                                          if (widget.replyToMediaType ==
                                                  'image' &&
                                              widget.replyToThumbnailUrl !=
                                                  null &&
                                              widget
                                                  .replyToThumbnailUrl!
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child:
                                                    widget.replyToThumbnailUrl!
                                                        .startsWith('http')
                                                    ? Image.network(
                                                        widget
                                                            .replyToThumbnailUrl!,
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              _,
                                                              __,
                                                              ___,
                                                            ) => Icon(
                                                              Icons
                                                                  .image_outlined,
                                                              color:
                                                                  subtleTextColor,
                                                              size: 16,
                                                            ),
                                                      )
                                                    : Image.file(
                                                        File(
                                                          widget
                                                              .replyToThumbnailUrl!,
                                                        ),
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              _,
                                                              __,
                                                              ___,
                                                            ) => Icon(
                                                              Icons
                                                                  .image_outlined,
                                                              color:
                                                                  subtleTextColor,
                                                              size: 16,
                                                            ),
                                                      ),
                                              ),
                                            )
                                          else
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: Icon(
                                                widget.replyToMediaType ==
                                                        'video'
                                                    ? Icons.videocam_outlined
                                                    : widget.replyToMediaType ==
                                                          'voice_note'
                                                    ? Icons.graphic_eq
                                                    : widget.replyToMediaType ==
                                                          'audio'
                                                    ? Icons.audiotrack
                                                    : widget.replyToMediaType ==
                                                          'document'
                                                    ? Icons.description_outlined
                                                    : Icons.image_outlined,
                                                color: subtleTextColor,
                                                size: 14,
                                              ),
                                            ),
                                        ],
                                        Flexible(
                                          child: Text(
                                            widget.replyToText!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: subtleTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Message body + Read more/less + time + ticks
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMessageText(displayText, isDark),
                                if (needTruncate)
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => isExpanded = !isExpanded,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        isExpanded ? 'Read less' : 'Read more',
                                        style: TextStyle(
                                          color: Colors.orange[300],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (widget.isSaved) ...[
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                    if (widget.isEdited)
                                      Text(
                                        "edited \u00b7 ",
                                        style: TextStyle(
                                          color: subtleTextColor,
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    Text(
                                      _formatTime(widget.timestamp),
                                      style: TextStyle(
                                        letterSpacing: 0.2,
                                        color: subtleTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                    if (widget.isMe) ...[
                                      const SizedBox(width: 3),
                                      _buildStatusTicks(isDark),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SegmentType { plain, url, mention }

class _TextSegment {
  final String text;
  final _SegmentType type;
  const _TextSegment(this.text, this.type);
  bool get isUrl => type == _SegmentType.url;
}

class _Match {
  final int start;
  final int end;
  final String text;
  final _SegmentType type;
  const _Match(this.start, this.end, this.text, this.type);
}
