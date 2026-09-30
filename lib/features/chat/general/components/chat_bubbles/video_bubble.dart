import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/media_placeholder_widgets.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:video_player/video_player.dart';

// ✅ Import the new media download widget
import 'package:qik_talk/utilities/widgets/media_download_widget.dart';

import '../../screens/full_screen_video_player.dart';

class VideoBubble extends StatefulWidget {
  final String videoUrl;
  final String? thumbnail;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final String text;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName;
  final String? replyToMediaType;
  final String? replyToThumbnailUrl;
  final bool isForwarded;
  final VoidCallback? onReplyTap;
  final VoidCallback? onLongPress;
  final Function(String direction)? onSwipe;
  final MessageStatus? status;
  final bool isRecipientOnline;
  final int? fileSizeBytes;

  const VideoBubble({
    super.key,
    required this.videoUrl,
    this.thumbnail,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.text = '',
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.isForwarded = false,
    this.onReplyTap,
    this.onLongPress,
    this.onSwipe,
    this.status,
    this.isRecipientOnline = false,
    this.fileSizeBytes,
  });

  @override
  State<VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble> {
  double _swipeOffset = 0;
  int? _resolvedFileSizeBytes;

  @override
  void initState() {
    super.initState();
    _resolveFileSize();
  }

  Future<void> _resolveFileSize() async {
    if (widget.fileSizeBytes != null) return;
    try {
      if (!widget.videoUrl.startsWith('http')) {
        final file = File(widget.videoUrl);
        if (file.existsSync()) {
          final size = await file.length();
          if (mounted) setState(() => _resolvedFileSizeBytes = size);
        }
        return;
      }

      final cached = MediaCacheService().getCachedPath(widget.videoUrl);
      if (cached != null && File(cached).existsSync()) {
        final size = await File(cached).length();
        if (mounted) setState(() => _resolvedFileSizeBytes = size);
        return;
      }

      final response = await Dio().head(widget.videoUrl);
      final length = int.tryParse(
        response.headers.value(Headers.contentLengthHeader) ?? '',
      );
      if (length != null && length > 0 && mounted) {
        setState(() => _resolvedFileSizeBytes = length);
      }
    } catch (_) {}
  }

  // ✅ FIX 2: Sender NEVER downloads. isMe=true → always play directly.
  // isLocal is only used as a secondary check for local file paths.
  bool get _isLocal => !widget.videoUrl.startsWith('http');

  // ✅ Sender should never see download UI:
  // - Local path (just recorded/picked) → play directly
  // - Remote URL (after server processes) → still play directly for sender
  bool get _shouldPlayDirectly => widget.isMe || _isLocal;

  String _formatTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  void _openFullscreenPlayer(
    BuildContext context, {
    String? localPath,
    VideoPlayerController? controller,
  }) {
    final playUrl = localPath ?? widget.videoUrl;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPlayer(
          videoUrl: playUrl,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildStatusTicks() {
    if (widget.status == MessageStatus.sending) {
      return const SizedBox(
        width: 13,
        height: 13,
        child: Icon(Icons.access_time_rounded, size: 12, color: Colors.white38),
      );
    }
    if (widget.status == MessageStatus.failed) {
      return const SizedBox(
        width: 13,
        height: 13,
        child: Icon(Icons.error_outline, size: 13, color: Colors.redAccent),
      );
    }
    if (widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: Colors.white54);
    }
    // ✅ Explicit case for sent status (WhatsApp style)
    if (widget.status == MessageStatus.sent) {
      return const SizedBox(
        width: 13,
        height: 13,
        child: Icon(Icons.check, size: 13, color: Colors.white54),
      );
    }
    // Fallback: Single grey tick
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

  // ── Sender video: play directly (local file OR remote URL) ─────────────────
  Widget _buildSenderVideo(double bubbleWidth) {
    final thumbH = (bubbleWidth - 24) * 9 / 16;

    // For sender: always show the inline player directly — no download needed
    return _InlineVideoPlayer(
      videoUrl: widget.videoUrl,
      isLocal: _isLocal,
      thumbnailUrl: widget.thumbnail,
      bubbleWidth: bubbleWidth,
      onFullscreen: (controller) =>
          _openFullscreenPlayer(context, controller: controller),
    );
  }

  Widget _placeholder(double bubbleWidth) {
    final w = bubbleWidth - 24;
    return Container(
      width: w,
      height: w * 9 / 16,
      color: Colors.black87,
      child: const Icon(Icons.videocam, color: Colors.white38, size: 40),
    );
  }

  Widget _playButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
    );
  }

  Widget _buildInlinePlayer(String localPath, double bubbleWidth) {
    return _InlineVideoPlayer(
      videoUrl: localPath,
      isLocal: true,
      thumbnailUrl: widget.thumbnail,
      bubbleWidth: bubbleWidth,
      onFullscreen: (controller) => _openFullscreenPlayer(
        context,
        localPath: localPath,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleWidth = MediaQuery.of(context).size.width * 0.65;
    final thumbH = (bubbleWidth - 24) * 9 / 16;

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
                  color: Colors.white.withOpacity(_swipeOffset.abs() / 80),
                  size: 24,
                ),
              ),

            Align(
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
                        if (widget.isForwarded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shortcut,
                                  size: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8A7060),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Forwarded",
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF8A7060),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                        ? HexColor('#1A7F4B')
                                        : HexColor('#FF6B00'),
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
                                            ? 'You'
                                            : 'Them'),
                                    style: TextStyle(
                                      color: widget.replyToIsMe == true
                                          ? HexColor('#1A7F4B')
                                          : HexColor('#FF6B00'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (widget.replyToMediaType != null) ...[
                                        if (widget.replyToMediaType ==
                                                'image' &&
                                            widget.replyToThumbnailUrl !=
                                                null &&
                                            widget.replyToThumbnailUrl!
                                                .startsWith('http'))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                widget.replyToThumbnailUrl!,
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        else
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: Icon(
                                              widget.replyToMediaType == 'video'
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
                                              color: isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF8A7060),
                                              size: 14,
                                            ),
                                          ),
                                      ],
                                      Expanded(
                                        child: Text(
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (_shouldPlayDirectly)
                          _buildSenderVideo(bubbleWidth)
                        else
                          MediaDownloadWidget(
                            mediaUrl: widget.videoUrl,
                            mediaType: MediaType.video,
                            thumbnailUrl: widget.thumbnail,
                            fileSizeBytes:
                                widget.fileSizeBytes ?? _resolvedFileSizeBytes,
                            width: bubbleWidth - 24,
                            height: thumbH,
                            borderRadius: BorderRadius.circular(12),
                            onTap: null,
                            mediaBuilder: (localPath) =>
                                _buildInlinePlayer(localPath, bubbleWidth),
                          ),

                        if (widget.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.text,
                            style: TextStyle(color: textColor, fontSize: 15),
                          ),
                        ],

                        const SizedBox(height: 4),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.isSaved) ...[
                                  const Icon(
                                    Icons.star,
                                    size: 11,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  _formatTime(widget.timestamp),
                                  style: const TextStyle(
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                    fontSize: 10,
                                    height: 1.0,
                                  ),
                                ),
                                if (widget.isMe) ...[
                                  const SizedBox(width: 3),
                                  _buildStatusTicks(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InlineVideoPlayer
//
// ✅ FIX: Accepts either a local file path OR a remote URL.
// Supports both File and network sources so sender's remote URLs play inline.
// Tap anywhere on video → toggle play/pause (fixed: was not responding).
// ─────────────────────────────────────────────────────────────────────────────
class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;
  final String? thumbnailUrl;
  final double bubbleWidth;
  final ValueChanged<VideoPlayerController> onFullscreen;

  const _InlineVideoPlayer({
    required this.videoUrl,
    required this.isLocal,
    this.thumbnailUrl,
    required this.bubbleWidth,
    required this.onFullscreen,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      VideoPlayerController controller;

      final cachedPath = !widget.isLocal
          ? MediaCacheService().getCachedPath(widget.videoUrl)
          : null;

      if (widget.isLocal) {
        controller = VideoPlayerController.file(File(widget.videoUrl));
      } else if (cachedPath != null && File(cachedPath).existsSync()) {
        controller = VideoPlayerController.file(File(cachedPath));
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      }

      _controller = controller;
      await controller.initialize();

      if (!mounted) return;

      setState(() => _initialized = true);

      // ✅ FIX: Listen to playback state changes to update play/pause icon
      controller.addListener(() {
        if (!mounted) return;
        final playing = controller.value.isPlaying;
        if (playing != _isPlaying) {
          setState(() => _isPlaying = playing);
        }
      });
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ✅ FIX: Toggle play/pause correctly — was missing setState causing no UI update
  void _togglePlay() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    setState(() {
      if (ctrl.value.isPlaying) {
        ctrl.pause();
        _isPlaying = false;
      } else {
        // If video ended, restart from beginning
        if (ctrl.value.position >= ctrl.value.duration) {
          ctrl.seekTo(Duration.zero);
        }
        ctrl.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.bubbleWidth - 24;
    final h = w * 9 / 16;

    if (_hasError) {
      return GestureDetector(
        // ✅ On error: tap to open fullscreen player as fallback
        onTap: () {
          final ctrl = _controller;
          if (ctrl != null) {
            widget.onFullscreen(ctrl);
          }
        },
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white54,
                size: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to play',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized || _controller == null) {
      // ✅ Show shimmer + thumbnail placeholder while video player initialises
      return VideoThumbnailPlaceholder(
        width: w,
        height: h,
        borderRadius: BorderRadius.circular(12),
        thumbnailPath:
            widget.thumbnailUrl != null &&
                !widget.thumbnailUrl!.startsWith('http')
            ? widget.thumbnailUrl
            : null,
        thumbnailUrl:
            widget.thumbnailUrl != null &&
                widget.thumbnailUrl!.startsWith('http')
            ? widget.thumbnailUrl
            : null,
      );
    }

    final ctrl = _controller!;
    final position = ctrl.value.position;
    final duration = ctrl.value.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video frame ──────────────────────────────────────────────
            // ✅ FIX: GestureDetector wraps AspectRatio so entire video area is tappable
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlay,
              child: Center(
                child: AspectRatio(
                  aspectRatio: ctrl.value.aspectRatio > 0
                      ? ctrl.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(ctrl),
                ),
              ),
            ),

            // ── Play/pause overlay ────────────────────────────────────────
            // ✅ FIX: Use _isPlaying state variable (not ctrl.value.isPlaying directly)
            // to ensure the icon updates reliably on tap
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom bar: progress + fullscreen ─────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                // Absorb taps on the bar so they don't toggle play
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: Colors.white24,
                            color: const Color(0xFF1A7F4B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ctrl.pause();
                          setState(() => _isPlaying = false);
                          widget.onFullscreen(ctrl);
                        },
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
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
    );
  }
}
