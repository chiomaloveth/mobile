import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

// ✅ Import the new media download widget
import 'package:qik_talk/utilities/widgets/media_download_widget.dart';

class ImageMessageBubble extends StatefulWidget {
  final String image;
  final String text;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToMessageId;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyTap;
  final Function(String direction)? onSwipe;
  final String? senderName;
  final MessageStatus? status;

  // ✅ Optional file size in bytes — shown on the download button (e.g. "2.4 MB")
  // Pass msg.fileSizeBytes from your ChatMessage model if available, or leave null.
  final int? fileSizeBytes;

  const ImageMessageBubble({
    super.key,
    required this.image,
    required this.text,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.onLongPress,
    this.replyToMessageId,
    this.onSwipe,
    this.onReplyTap,
    this.senderName,
    this.status,
    this.fileSizeBytes,
  });

  @override
  State<ImageMessageBubble> createState() => _ImageMessageBubbleState();
}

class _ImageMessageBubbleState extends State<ImageMessageBubble> {
  bool isExpanded = false;
  final int truncateLength = 50;
  double _swipeOffset = 0;
  static const double _swipeThreshold = 50;

  String _formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _openFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrl: widget.image),
      ),
    );
  }

  // ── Determines if URL is a local file path or a remote URL ────────────────
  bool get _isLocal => !widget.image.startsWith('http');

  // ── For local files (just sent by user) we skip the download widget entirely
  // since the file is already on device. Only remote URLs get the blur/download flow.
  bool get _needsDownload => !_isLocal;

  @override
  Widget build(BuildContext context) {
    final bool needTruncate = widget.text.length > truncateLength;
    final String displayText = (!isExpanded && needTruncate)
        ? '${widget.text.substring(0, truncateLength)}...'
        : widget.text;

    final bubbleWidth = MediaQuery.of(context).size.width * 0.65;

    return GestureDetector(
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
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          // ── Swipe reply icon ──────────────────────────────────────────────
          if (_swipeOffset.abs() > 10)
            Positioned(
              left: widget.isMe ? null : 10,
              right: widget.isMe ? 10 : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_swipeOffset.abs() / _swipeThreshold).clamp(0.0, 1.0),
                child: Icon(Icons.reply, color: HexColor('#1A7F4B'), size: 24),
              ),
            ),

          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Builder(
                builder: (context) {
                  final bool isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final Color bubbleBg = isDark
                      ? (widget.isMe
                            ? HexColor('#1B1B1B')
                            : HexColor('#232323'))
                      : Colors.white;
                  final Color textColor = isDark
                      ? Colors.white
                      : (widget.isMe
                            ? const Color(0xFF2A1A0A)
                            : const Color(0xFF1A1008));
                  const List<BoxShadow> shadows = [];

                  return Container(
                    constraints: BoxConstraints(maxWidth: bubbleWidth),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: bubbleBg,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
                        bottomRight: Radius.circular(widget.isMe ? 4 : 18),
                      ),
                      boxShadow: shadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Sender name (group chats) ───────────────────────────
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

                        // ── Reply preview ───────────────────────────────────────
                        if (widget.replyToText != null &&
                            widget.replyToText!.isNotEmpty)
                          GestureDetector(
                            onTap: widget.onReplyTap,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black26
                                    : Colors.black.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color: widget.replyToIsMe == true
                                        ? HexColor('#FB8830')
                                        : HexColor('#1A7F4B'),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.replyToIsMe == true
                                        ? 'You'
                                        : 'Other',
                                    style: TextStyle(
                                      color: widget.replyToIsMe == true
                                          ? HexColor('#FB8830')
                                          : HexColor('#1A7F4B'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.replyToText!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF8A7060),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // ── IMAGE — core media area ─────────────────────────────
                        if (_isLocal)
                          GestureDetector(
                            onTap: _openFullScreenImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(widget.image),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _errorBox(bubbleWidth),
                              ),
                            ),
                          )
                        else
                          MediaDownloadWidget(
                            mediaUrl: widget.image,
                            mediaType: MediaType.image,
                            fileSizeBytes: widget.fileSizeBytes,
                            width: bubbleWidth - 24,
                            height: (bubbleWidth - 24) * 0.75,
                            borderRadius: BorderRadius.circular(12),
                            onTap: _openFullScreenImage,
                            mediaBuilder: (localPath) => Image.file(
                              File(localPath),
                              fit: BoxFit.cover,
                              width: bubbleWidth - 24,
                              height: (bubbleWidth - 24) * 0.75,
                              errorBuilder: (_, __, ___) =>
                                  _errorBox(bubbleWidth),
                            ),
                          ),

                        // ── Caption ─────────────────────────────────────────────
                        if (widget.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          RichText(
                            textScaleFactor: MediaQuery.of(
                              context,
                            ).textScaleFactor,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: displayText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                if (needTruncate)
                                  TextSpan(
                                    text: isExpanded
                                        ? ' Read less'
                                        : ' Read more',
                                    style: TextStyle(
                                      color: Colors.orange[200],
                                      fontSize:
                                          12 *
                                          MediaQuery.of(
                                            context,
                                          ).textScaleFactor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => setState(
                                        () => isExpanded = !isExpanded,
                                      ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildTimeAndTick(isDark),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAndTick(bool isDark) {
    final Color subtleColor = isDark ? Colors.white70 : const Color(0xFF8A7060);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isSaved) ...[
            const Icon(Icons.star, size: 11, color: Colors.amber),
            const SizedBox(width: 3),
          ],
          Text(
            _formatTime(widget.timestamp),
            style: TextStyle(
              letterSpacing: 0.2,
              color: isDark ? Colors.white : const Color(0xFF2A1A0A),
              fontSize: 10,
              height: 1.0,
            ),
          ),
          if (widget.isMe) ...[const SizedBox(width: 3), _buildTicks()],
        ],
      ),
    );
  }

  Widget _buildTicks() {
    // ── 1. Still sending ──────────────────────────────────────────────────────
    if (widget.status == MessageStatus.sending) {
      return const Icon(
        Icons.access_time_rounded,
        size: 12,
        color: Colors.white54,
      );
    }
    // ── 2. Failed ─────────────────────────────────────────────────────────────
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }
    // ── 3. Read → blue double tick ────────────────────────────────────────────
    if (widget.status == MessageStatus.read || widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    // ── 4. Delivered → grey double tick ───────────────────────────────────────
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: Colors.white54);
    }
    // ── 5. Sent → single grey tick (WhatsApp style) ────────────────────────────
    if (widget.status == MessageStatus.sent) {
      return const SizedBox(
        width: 13,
        height: 13,
        child: Icon(Icons.check, size: 13, color: Colors.white54),
      );
    }
    // ── 6. Fallback: Single grey tick ──────────────────────────────────────────
    return const SizedBox(
      width: 13,
      height: 13,
      child: Icon(Icons.check, size: 13, color: Colors.white54),
    );
  }

  Widget _doubleTick({required Color color}) {
    return SizedBox(
      width: 18,
      height: 13,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
        ],
      ),
    );
  }

  Widget _errorBox(double bubbleWidth) {
    return Container(
      width: bubbleWidth - 24,
      height: (bubbleWidth - 24) * 0.75,
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 32,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FullScreenImageViewer — unchanged from your original
// ─────────────────────────────────────────────────────────────────────────────
class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) =>
      _doubleTapDetails = details;

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = !widget.imageUrl.startsWith('http');
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 4.0,
                child: isLocal
                    ? Image.file(
                        File(widget.imageUrl),
                        gaplessPlayback: true,
                      )
                    : OfflineCachedImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: const ColoredBox(
                          color: Colors.black,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: const ColoredBox(
                          color: Colors.black,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white24,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
