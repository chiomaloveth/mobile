import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/media_placeholder_widgets.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:qik_talk/utilities/widgets/media_download_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MultiImageBubble
//
// WhatsApp-style multi-image grid inside a chat bubble.
//
// Layout rules:
//   1 image  → full width
//   2 images → 2 equal columns side by side
//   3 images → 1 full-width top + 2 equal columns bottom
//   4+ images → 2×2 grid, last cell shows "+N more" overlay
//
// Sender (isMe=true)  → Image.file() for local paths, Image.network() for remote
//                       NO download button ever shown to sender
// Receiver (isMe=false) → MediaDownloadWidget (blur → download → display)
// ─────────────────────────────────────────────────────────────────────────────

class MultiImageBubble extends StatefulWidget {
  final List<String> images;
  final String text;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName;
  final String? replyToMediaType;
  final String? replyToThumbnailUrl;
  final bool isForwarded;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyTap;
  final Function(String direction)? onSwipe;
  final String? senderName;
  final MessageStatus? status;

  /// null = not uploading. 0.0–1.0 = upload in progress.
  final double? uploadProgress;

  const MultiImageBubble({
    super.key,
    required this.images,
    required this.text,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.isForwarded = false,
    this.onLongPress,
    this.onReplyTap,
    this.onSwipe,
    this.senderName,
    this.status,
    this.uploadProgress,
  });

  @override
  State<MultiImageBubble> createState() => _MultiImageBubbleState();
}

class _MultiImageBubbleState extends State<MultiImageBubble> {
  bool isExpanded = false;
  final int truncateLength = 50;
  double _swipeOffset = 0;
  static const double _swipeThreshold = 50;

  String _formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiImageViewer(
          images: widget.images, // ALL images for full gallery swipe
          initialIndex: index.clamp(0, widget.images.length - 1),
        ),
      ),
    );
  }

  bool _isLocal(String url) => !url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    // Show max 4 in the grid but pass ALL images to the viewer
    final visibleImages = widget.images.take(4).toList();
    final overflow = widget.images.length - 4;

    final bool needTruncate = widget.text.length > truncateLength;
    final String displayText = (!isExpanded && needTruncate)
        ? '${widget.text.substring(0, truncateLength)}...'
        : widget.text;

    final bubbleWidth = MediaQuery.of(context).size.width * 0.65;
    final contentWidth = bubbleWidth - 24;

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
                  final Color subtleColor = isDark
                      ? Colors.white70
                      : const Color(0xFF8A7060);
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sender name
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

                        if (widget.isForwarded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shortcut,
                                  size: 13,
                                  color: subtleColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Forwarded',
                                  style: GoogleFonts.poppins(
                                    color: subtleColor,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Reply preview
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
                                    widget.replyToSenderName ??
                                        (widget.replyToIsMe == true
                                            ? 'You'
                                            : 'Them'),
                                    style: TextStyle(
                                      color: widget.replyToIsMe == true
                                          ? HexColor('#FB8830')
                                          : HexColor('#1A7F4B'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (widget.replyToMediaType != null) ...[
                                        // ✅ BUG1 FIX: support local thumbnails
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
                                                          (_, __, ___) => Icon(
                                                            Icons
                                                                .image_outlined,
                                                            color: subtleColor,
                                                            size: 14,
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
                                                            Icons
                                                                .image_outlined,
                                                            color: subtleColor,
                                                            size: 14,
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
                          ),

                        // ── IMAGE GRID + upload progress ──────────────────────
                        Stack(
                          children: [
                            _buildGrid(visibleImages, overflow, contentWidth),
                            // WhatsApp-style subtle upload overlay
                            if (widget.uploadProgress != null)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.38),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 38,
                                            height: 38,
                                            child: CircularProgressIndicator(
                                              value: widget.uploadProgress! > 0
                                                  ? widget.uploadProgress
                                                  : null,
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                              backgroundColor: Colors.white24,
                                            ),
                                          ),
                                          if (widget.uploadProgress! > 0) ...[
                                            const SizedBox(height: 5),
                                            Text(
                                              '${(widget.uploadProgress! * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Caption
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
                          child: _timeAndTick(isDark),
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

  // ── Grid layout ───────────────────────────────────────────────────────────

  Widget _buildGrid(List<String> imgs, int overflow, double w) {
    const g = 4.0;
    // ✅ FIX: compute half from screen width directly, not from passed `w`
    // so images never overflow the bubble regardless of padding nesting
    final maxBubbleContent = MediaQuery.of(context).size.width * 0.65 - 24;
    final half = (maxBubbleContent - g) / 2;

    switch (imgs.length) {
      case 1:
        return _cell(imgs[0], maxBubbleContent, maxBubbleContent * 0.75, 0, 0);

      case 2:
        return Row(
          children: [
            _cell(imgs[0], half, half, 0, 0),
            const SizedBox(width: g),
            _cell(imgs[1], half, half, 1, 0),
          ],
        );

      case 3:
        return Column(
          children: [
            _cell(imgs[0], maxBubbleContent, maxBubbleContent * 0.55, 0, 0),
            const SizedBox(height: g),
            Row(
              children: [
                _cell(imgs[1], half, half * 0.75, 1, 0),
                const SizedBox(width: g),
                _cell(imgs[2], half, half * 0.75, 2, 0),
              ],
            ),
          ],
        );

      default: // 4+
        return Column(
          children: [
            Row(
              children: [
                _cell(imgs[0], half, half, 0, 0),
                const SizedBox(width: g),
                _cell(imgs[1], half, half, 1, 0),
              ],
            ),
            const SizedBox(height: g),
            Row(
              children: [
                _cell(imgs[2], half, half, 2, 0),
                const SizedBox(width: g),
                _cell(imgs[3], half, half, 3, overflow > 0 ? overflow : 0),
              ],
            ),
          ],
        );
    }
  }

  // ── Single image cell ─────────────────────────────────────────────────────

  Widget _cell(String url, double w, double h, int idx, int overflow) {
    Widget media;

    // ✅ FIX 1: Sender (isMe=true) NEVER uses MediaDownloadWidget.
    // Show local file OR remote URL directly — no download button ever.
    if (_isLocal(url)) {
      // ✅ Local file path (just sent, not yet uploaded) — show instantly
      media = GestureDetector(
        onTap: () => _openViewer(idx),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(url),
            width: w,
            height: h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errBox(w, h),
          ),
        ),
      );
    } else if (widget.isMe) {
      // ✅ Sender with remote URL — silently cache to disk, show immediately.
      // If the URL already points to MinIO it means upload is done.
      // Show MediaPlaceholder while the _SilentCachedImage loads from disk.
      media = _SilentCachedImage(
        url: url,
        width: w,
        height: h,
        onTap: () => _openViewer(idx),
        errorWidget: _errBox(w, h),
        // Pass local path so placeholder shows blurred preview during load
        localPreviewPath: url.startsWith('http') ? null : url,
      );
    } else {
      // ✅ Receiver: remote URL — blur preview → tap to download → display
      media = MediaDownloadWidget(
        mediaUrl: url,
        mediaType: MediaType.image,
        width: w,
        height: h,
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openViewer(idx),
        mediaBuilder: (localPath) => GestureDetector(
          onTap: () => _openViewer(idx),
          child: Image.file(
            File(localPath),
            width: w,
            height: h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errBox(w, h),
          ),
        ),
      );
    }

    if (overflow <= 0) return media;

    // "+N more" overlay on the 4th cell
    return Stack(
      children: [
        media,
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _openViewer(idx),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black.withOpacity(0.55),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeAndTick(bool isDark) {
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
    if (widget.status == MessageStatus.sending) {
      return const Icon(
        Icons.access_time_rounded,
        size: 12,
        color: Colors.white54,
      );
    }
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }
    if (widget.status == MessageStatus.read || widget.isRead) {
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

  Widget _errBox(double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Center(
      child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 24),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MultiImageViewer — full screen swipeable viewer
// ─────────────────────────────────────────────────────────────────────────────
class MultiImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const MultiImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<MultiImageViewer> createState() => _MultiImageViewerState();
}

// ─────────────────────────────────────────────────────────────────────────────
// _SilentCachedImage
//
// For sender's remote images: no blur, no download button.
// Checks disk cache first → shows instantly offline.
// Downloads silently in background on first load only.
// ─────────────────────────────────────────────────────────────────────────────
class _SilentCachedImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Widget errorWidget;
  final String? localPreviewPath; // ✅ local file for blurred placeholder

  const _SilentCachedImage({
    required this.url,
    required this.width,
    required this.height,
    this.onTap,
    required this.errorWidget,
    this.localPreviewPath,
  });

  @override
  State<_SilentCachedImage> createState() => _SilentCachedImageState();
}

class _SilentCachedImageState extends State<_SilentCachedImage> {
  String? _localPath;
  bool _loading = true;
  bool _error = false;
  bool _useNetworkFallback = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/qiktalk_img_cache');
      if (!await cacheDir.exists()) await cacheDir.create(recursive: true);

      final uri = Uri.tryParse(widget.url);
      String name = widget.url.hashCode.abs().toString();
      if (uri != null) {
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) name = segments.last;
      }
      if (!name.contains('.')) name = '$name.jpg';

      final filePath = '${cacheDir.path}/$name';
      final file = File(filePath);

      debugPrint('🖼️ Checking cache: $name');

      // ✅ Cache hit — show instantly, zero network
      if (await file.exists() && await file.length() > 0) {
        debugPrint('✅ Cache hit: $filePath');
        if (mounted)
          setState(() {
            _localPath = filePath;
            _loading = false;
          });
        return;
      }

      if (widget.url.isEmpty || uri == null || !widget.url.startsWith('http')) {
        if (mounted)
          setState(() {
            _loading = false;
            _error = true;
          });
        return;
      }

      // ✅ Download the image directly
      String downloadUrl = widget.url;

      debugPrint('⬇️ Downloading: $downloadUrl');

      // ✅ Use Dio with proper headers — reliable with longer timeout for slow connections.
      final dio = Dio();
      final response = await dio.get<List<int>>(
        downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'image/*', 'User-Agent': 'QikTalk/1.0'},
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data!.isNotEmpty) {
        await file.writeAsBytes(response.data!);
        debugPrint('✅ Saved: $filePath (${response.data!.length} bytes)');
        if (mounted)
          setState(() {
            _localPath = filePath;
            _loading = false;
          });
      } else {
        debugPrint('❌ Download failed: ${response.statusCode}');
        if (mounted)
          setState(() {
            _loading = false;
            _error = true;
          });
      }
    } catch (e) {
      debugPrint('❌ _SilentCachedImage error: $e');
      // On 403/4xx the URL may require auth — fall back to direct network render
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
          _useNetworkFallback = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Loaded successfully — show the cached file
    if (_localPath != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(_localPath!),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            // ✅ If file.read fails after path was set, try re-downloading
            errorBuilder: (_, __, ___) {
              debugPrint('❌ Image.file failed for $_localPath — retrying');
              // Reset and re-trigger download
              Future.microtask(() {
                if (mounted)
                  setState(() {
                    _localPath = null;
                    _loading = true;
                    _error = false;
                  });
                _load();
              });
              return _placeholder();
            },
          ),
        ),
      );
    }

    // Network fallback — URL returned 403, render directly without caching
    if (_error && _useNetworkFallback) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.url,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorBox(),
          ),
        ),
      );
    }

    // Generic error — tap to retry
    if (_error) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _error = false;
            _loading = true;
            _useNetworkFallback = false;
          });
          _load();
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white38, size: 24),
                SizedBox(height: 4),
                Text(
                  'Tap to retry',
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Still loading — show neutral placeholder (no broken icon)
    return _placeholder();
  }

  Widget _placeholder() {
    return GestureDetector(
      onTap: widget.onTap,
      child: MediaPlaceholder(
        width: widget.width,
        height: widget.height,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 24,
        ),
      ),
    );
  }
}

class _MultiImageViewerState extends State<MultiImageViewer> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _precacheAround(currentIndex);
    });
  }

  void _precacheAround(int index) {
    final start = index > 0 ? index - 1 : index;
    final end = index < widget.images.length - 1 ? index + 1 : index;

    for (int i = start; i <= end; i++) {
      final image = widget.images[i];
      if (!image.startsWith('http')) {
        final file = File(image);
        if (file.existsSync()) {
          precacheImage(FileImage(file), context);
        }
        continue;
      }

      final cached = MediaCacheService().getCachedPath(image);
      if (cached != null && File(cached).existsSync()) {
        precacheImage(FileImage(File(cached)), context);
        continue;
      }

      MediaCacheService().cacheMedia(url: image, mediaType: 'image');
    }
  }

  ImageProvider _providerFor(String imageUrl) {
    if (!imageUrl.startsWith('http')) {
      return FileImage(File(imageUrl));
    }

    final cached = MediaCacheService().getCachedPath(imageUrl);
    if (cached != null && File(cached).existsSync()) {
      return FileImage(File(cached));
    }

    return NetworkImage(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (i) {
              setState(() => currentIndex = i);
              _precacheAround(i);
            },
            builder: (context, index) {
              final imageUrl = widget.images[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: _providerFor(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: '${imageUrl}_$index'),
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                    size: 60,
                  ),
                ),
              );
            },
            loadingBuilder: (context, event) {
              final imageUrl = widget.images[currentIndex];
              final cached = imageUrl.startsWith('http')
                  ? MediaCacheService().getCachedPath(imageUrl)
                  : imageUrl;
              if (cached != null && File(cached).existsSync()) {
                return const ColoredBox(color: Colors.black);
              }
              return const ColoredBox(
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
              );
            },
          ),
          Positioned(
            top: topPad + 6,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentIndex + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: bottomPad + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length.clamp(0, 10),
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentIndex ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentIndex ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
