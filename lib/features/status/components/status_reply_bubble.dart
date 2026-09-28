import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class StatusReplyBubble extends StatefulWidget {
  final String rawContent;
  final bool isMe;
  final String timestamp;
  final bool isRead;
  final VoidCallback? onLongPress;
  final Function(String direction)? onSwipe;

  const StatusReplyBubble({
    super.key,
    required this.rawContent,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    this.onLongPress,
    this.onSwipe,
  });

  static bool isStatusReply(String text) =>
      text.startsWith('__STATUS_REPLY__:');

  static String extractReplyText(String raw) {
    if (!isStatusReply(raw)) return raw;
    final withoutPrefix = raw.substring('__STATUS_REPLY__:'.length);
    final pipeIndex = withoutPrefix.indexOf('|');
    if (pipeIndex == -1) return raw;
    return withoutPrefix.substring(pipeIndex + 1).replaceAll('[pipe]', '|');
  }

  static _StatusReplyData? parse(String raw) {
    if (!raw.startsWith('__STATUS_REPLY__:')) return null;
    final withoutPrefix = raw.substring('__STATUS_REPLY__:'.length);
    final pipeIndex = withoutPrefix.indexOf('|');
    if (pipeIndex == -1) return null;

    final meta = withoutPrefix.substring(0, pipeIndex);
    final replyText = withoutPrefix
        .substring(pipeIndex + 1)
        .replaceAll('[pipe]', '|');

    final parts = meta.split(':');
    if (parts.length < 3) return null;

    final statusId = parts[0];
    final mediaType = parts[1];
    final urlAndCaption = parts.sublist(2).join(':');

    String mediaUrl;
    String caption;

    int lastSafeColon = -1;
    for (int i = urlAndCaption.length - 1; i >= 0; i--) {
      if (urlAndCaption[i] == ':') {
        final nextChar = i + 1 < urlAndCaption.length
            ? urlAndCaption[i + 1]
            : '';
        if (nextChar != '/') {
          lastSafeColon = i;
          break;
        }
      }
    }

    if (lastSafeColon == -1) {
      mediaUrl = urlAndCaption;
      caption = '';
    } else {
      mediaUrl = urlAndCaption.substring(0, lastSafeColon);
      caption = urlAndCaption
          .substring(lastSafeColon + 1)
          .replaceAll('[pipe]', '|');
    }

    return _StatusReplyData(
      statusId: statusId,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      caption: caption,
      replyText: replyText,
    );
  }

  @override
  State<StatusReplyBubble> createState() => _StatusReplyBubbleState();
}

class _StatusReplyBubbleState extends State<StatusReplyBubble> {
  double _swipeOffset = 0;
  static const double _swipeThreshold = 50;

  @override
  Widget build(BuildContext context) {
    final data = StatusReplyBubble.parse(widget.rawContent);
    if (data == null) {
      return _PlainBubble(
        text: widget.rawContent,
        isMe: widget.isMe,
        timestamp: widget.timestamp,
      );
    }

    final bubbleColor = widget.isMe
        ? const Color(0xFF005C4B)
        : const Color(0xFF1F2C34);
    final align = widget.isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(widget.isMe ? 12 : 2),
      bottomRight: Radius.circular(widget.isMe ? 2 : 12),
    );

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipeOffset += details.delta.dx;
          _swipeOffset = _swipeOffset.clamp(-80.0, 80.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_swipeOffset.abs() > _swipeThreshold && widget.onSwipe != null) {
          widget.onSwipe!(_swipeOffset > 0 ? 'right' : 'left');
        }
        setState(() => _swipeOffset = 0);
      },
      child: Stack(
        children: [
          if (_swipeOffset.abs() > 10)
            Positioned(
              left: widget.isMe ? null : 4,
              right: widget.isMe ? 4 : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_swipeOffset.abs() / _swipeThreshold).clamp(0.0, 1.0),
                child: Icon(Icons.reply, color: HexColor("#1A7F4B"), size: 24),
              ),
            ),
          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.isMe ? 60 : 8,
                right: widget.isMe ? 8 : 60,
                top: 3,
                bottom: 3,
              ),
              child: Column(
                crossAxisAlignment: align,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewCard(data),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                          child: Text(
                            data.replyText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 6),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(widget.timestamp),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                if (widget.isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    widget.isRead ? Icons.done_all : Icons.done,
                                    size: 14,
                                    color: widget.isRead
                                        ? const Color(0xFF53BDEB)
                                        : Colors.white54,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPreviewCard(_StatusReplyData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: Border(
          left: BorderSide(
            color: widget.isMe
                ? const Color(0xFF00A884)
                : const Color(0xFF53BDEB),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: [
                Icon(
                  Icons.photo_camera,
                  size: 13,
                  color: widget.isMe
                      ? const Color(0xFF00A884)
                      : const Color(0xFF53BDEB),
                ),
                const SizedBox(width: 5),
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    color: widget.isMe
                        ? const Color(0xFF00A884)
                        : const Color(0xFF53BDEB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (data.mediaType == 'image' && data.mediaUrl.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 8, 10),
                    child: Text(
                      data.caption.isNotEmpty ? data.caption : 'Photo',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  child: Image.network(
                    data.mediaUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.white10,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white38,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (data.mediaType == 'video')
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 8, 10),
                    child: Text(
                      data.caption.isNotEmpty ? data.caption : 'Video',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
              ],
            )
          else if (data.mediaType == 'text')
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                data.mediaUrl.isNotEmpty ? data.mediaUrl : data.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                'Status',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }
}

class _StatusReplyData {
  final String statusId;
  final String mediaType;
  final String mediaUrl;
  final String caption;
  final String replyText;

  const _StatusReplyData({
    required this.statusId,
    required this.mediaType,
    required this.mediaUrl,
    required this.caption,
    required this.replyText,
  });
}

class _PlainBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String timestamp;

  const _PlainBubble({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
