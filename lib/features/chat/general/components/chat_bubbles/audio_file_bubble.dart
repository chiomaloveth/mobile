import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

class AudioFileBubble extends StatefulWidget {
  final String audioUrl;
  final String fileName;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName; // ✅ BUG1 FIX: added
  final String? replyToMediaType; // ✅ BUG1 FIX: added
  final String? replyToThumbnailUrl; // ✅ BUG1 FIX: added
  final VoidCallback? onLongPress;
  final Function(String direction)? onSwipe;
  final MessageStatus? status;
  final String? senderName;

  const AudioFileBubble({
    super.key,
    required this.audioUrl,
    required this.fileName,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName, // ✅ BUG1 FIX
    this.replyToMediaType, // ✅ BUG1 FIX
    this.replyToThumbnailUrl, // ✅ BUG1 FIX
    this.onLongPress,
    this.onSwipe,
    this.status,
    this.senderName,
  });

  @override
  State<AudioFileBubble> createState() => _AudioFileBubbleState();
}

class _AudioFileBubbleState extends State<AudioFileBubble> {
  late final AudioPlayer _player;
  bool isPlaying = false; // retained for UI state if needed
  double _swipeOffset = 0;
  static const double _swipeThreshold = 50;
  bool isUploading = false;
  double uploadProgress = 0;
  String? _localPath;
  late int _fileSize; // ✅ File size in bytes
  late String _fileExtension; // ✅ File extension

  /// Return real filename, extracting from URL if backend sent "attachment"
  String get _resolvedFileName {
    if (widget.fileName.isNotEmpty &&
        widget.fileName.toLowerCase() != 'attachment' &&
        widget.fileName.toLowerCase() != 'audio') {
      return widget.fileName;
    }
    try {
      final uri = Uri.parse(widget.audioUrl);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (last.isNotEmpty) return last;
      }
    } catch (_) {}
    return widget.fileName.isNotEmpty ? widget.fileName : 'audio_file';
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(); // kept for potential future use

    _fileExtension = _extractExtension(_resolvedFileName);
    _fileSize = 0;
    _prepareLocalAudio();
  }

  // ✅ Extract file extension from file name
  String _extractExtension(String fileName) {
    final ext = p.extension(fileName).replaceAll('.', '').toUpperCase();
    return ext.isEmpty ? 'AUDIO' : ext;
  }

  // ✅ Format file size to human-readable format
  String _formatFileSize(int bytes) {
    if (bytes == 0) return 'calculating...';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ✅ Format timestamp to display date and time
  String _formatDateTime(String isoTime) {
    try {
      final date = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      String dateStr;
      if (messageDate == today) {
        dateStr = 'Today';
      } else if (messageDate == yesterday) {
        dateStr = 'Yesterday';
      } else {
        dateStr = '${date.day}/${date.month}/${date.year}';
      }

      final timeStr =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$dateStr · $timeStr';
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<void> _prepareLocalAudio() async {
    final url = widget.audioUrl;

    try {
      String? filePath;

      // If already cached on disk, always prefer that for offline playback.
      if (url.startsWith('http')) {
        final cachedPath = MediaCacheService().getCachedPath(url);
        if (cachedPath != null && File(cachedPath).existsSync()) {
          _localPath = cachedPath;
          filePath = cachedPath;
        }
      } else {
        // For local file paths, just use them directly.
        if (File(url).existsSync()) {
          _localPath = url;
          filePath = url;
        }
      }

      // ✅ Get file size from local file/cache, otherwise HEAD the remote URL
      try {
        if (filePath != null) {
          final fileSize = await File(filePath).length();
          if (mounted) setState(() => _fileSize = fileSize);
        } else if (url.startsWith('http')) {
          final response = await Dio().head(url);
          final length = int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? '',
          );
          if (length != null && length > 0 && mounted) {
            setState(() => _fileSize = length);
          }
        }
      } catch (_) {
        // File size fetch failed, keep default
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _openWithExternalApp() async {
    try {
      final pathToOpen = _localPath ?? widget.audioUrl;
      if (pathToOpen == null || pathToOpen.isEmpty) return;

      // If it's a remote URL and not cached, download first
      if (pathToOpen.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading audio to open…'),
            duration: Duration(seconds: 2),
          ),
        );
        // Cache it then open
        final cached = await MediaCacheService().cacheMedia(
          url: pathToOpen,
          mediaType: 'audio',
        );
        if (cached != null) {
          final result = await OpenFilex.open(cached);
          _handleOpenResult(result);
        }
        return;
      }

      final result = await OpenFilex.open(pathToOpen);
      _handleOpenResult(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open audio: $e')));
      }
    }
  }

  Widget _buildStatusTicks(Color subtleColor) {
    if (widget.status == MessageStatus.sending) {
      return Icon(Icons.access_time_rounded, size: 12, color: subtleColor);
    }
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }
    if (widget.status == MessageStatus.read || widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: subtleColor);
    }
    // ✅ Explicit case for sent status (WhatsApp style)
    if (widget.status == MessageStatus.sent) {
      return Icon(Icons.check, size: 13, color: subtleColor);
    }
    // Fallback: Single grey tick
    return Icon(Icons.check, size: 13, color: subtleColor);
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

  void _handleOpenResult(OpenResult result) {
    switch (result.type) {
      case ResultType.done:
        break;
      case ResultType.noAppToOpen:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No app installed can open this audio file.\nTry installing a music player.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
        break;
      case ResultType.fileNotFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio file not found on device.')),
        );
        break;
      case ResultType.permissionDenied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Check app storage permissions.'),
          ),
        );
        break;
      case ResultType.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'Could not open audio.',
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (_swipeOffset.abs() > 10)
            Positioned(
              left: widget.isMe ? null : 10,
              right: widget.isMe ? 10 : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_swipeOffset.abs() / _swipeThreshold).clamp(0.0, 1.0),
                child: Icon(Icons.reply, color: HexColor("#1A7F4B"), size: 24),
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
                            ? HexColor("#1B1B1B")
                            : HexColor("#232323"))
                      : Colors.white;
                  final Color textColor = isDark
                      ? Colors.white
                      : (widget.isMe
                            ? const Color(0xFF2A1A0A)
                            : const Color(0xFF1A1008));
                  final Color subtleColor = isDark
                      ? Colors.white70
                      : const Color(0xFF8A7060);
                  const List<BoxShadow> shadows = [];

                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
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

                        // ✅ BUG1 FIX: full reply preview with media icon/thumbnail
                        if (widget.replyToText != null &&
                            widget.replyToText!.isNotEmpty) ...[
                          Container(
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
                                      ? HexColor("#FB8830")
                                      : HexColor("#1A7F4B"),
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
                                        ? HexColor("#FB8830")
                                        : HexColor("#1A7F4B"),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    // ── Media type icon / thumbnail ──────────
                                    if (widget.replyToMediaType != null) ...[
                                      if (widget.replyToMediaType == 'image' &&
                                          widget.replyToThumbnailUrl != null &&
                                          widget
                                              .replyToThumbnailUrl!
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child:
                                                widget.replyToThumbnailUrl!
                                                    .startsWith('http')
                                                ? Image.network(
                                                    widget.replyToThumbnailUrl!,
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                          Icons.image_outlined,
                                                          color: subtleColor,
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
                                                        (_, __, ___) => Icon(
                                                          Icons.image_outlined,
                                                          color: subtleColor,
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
                                            color: subtleColor,
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
                                          color: subtleColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        Row(
                          children: [
                            Icon(Icons.audiotrack, color: textColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ File name
                                  Text(
                                    _resolvedFileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  // ✅ File size and type
                                  Row(
                                    children: [
                                      Text(
                                        _formatFileSize(_fileSize),
                                        style: TextStyle(
                                          color: subtleColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.isMe
                                              ? HexColor(
                                                  '#FB8830',
                                                ).withOpacity(0.2)
                                              : HexColor(
                                                  '#1A7F4B',
                                                ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Text(
                                          _fileExtension,
                                          style: TextStyle(
                                            color: widget.isMe
                                                ? HexColor('#FB8830')
                                                : HexColor('#1A7F4B'),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isUploading)
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CircularProgressIndicator(
                                      value: uploadProgress,
                                      color: Colors.orange,
                                      strokeWidth: 3,
                                      backgroundColor: Colors.grey[800],
                                    ),
                                  ),
                                if (!isUploading)
                                  IconButton(
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: textColor,
                                    ),
                                    onPressed: _openWithExternalApp,
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        // ✅ Date, Time, and Status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isSaved) ...[
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              _formatDateTime(widget.timestamp),
                              style: TextStyle(
                                color: subtleColor,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (widget.isMe) _buildStatusTicks(subtleColor),
                          ],
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
}
