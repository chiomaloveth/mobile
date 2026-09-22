import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum MediaType { image, video }

enum _DownloadState { notDownloaded, downloading, downloaded }

class MediaDownloadWidget extends StatefulWidget {
  final String mediaUrl;
  final MediaType mediaType;
  final String? thumbnailUrl; // for video — shown as blurred preview bg
  final int? fileSizeBytes; // optional — shown on the download button
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap; // called when media is tapped after download
  final Widget Function(String localPath)?
  mediaBuilder; // custom post-download renderer

  const MediaDownloadWidget({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
    this.fileSizeBytes,
    this.width = 200,
    this.height = 200,
    this.borderRadius,
    this.onTap,
    this.mediaBuilder,
  });

  @override
  State<MediaDownloadWidget> createState() => _MediaDownloadWidgetState();
}

class _MediaDownloadWidgetState extends State<MediaDownloadWidget>
    with SingleTickerProviderStateMixin {
  _DownloadState _state = _DownloadState.notDownloaded;
  String? _localPath;
  double _progress = 0.0;
  CancelToken? _cancelToken;
  int? _resolvedFileSizeBytes;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Check cache synchronously on mount — no flicker for already-downloaded media
    _checkCache();
    _resolveFileSize();
  }

  Future<void> _resolveFileSize() async {
    if (widget.fileSizeBytes != null) return;
    try {
      final mediaCachePath = MediaCacheService().getCachedPath(widget.mediaUrl);
      if (mediaCachePath != null && File(mediaCachePath).existsSync()) {
        final size = await File(mediaCachePath).length();
        if (mounted) setState(() => _resolvedFileSizeBytes = size);
        return;
      }

      final localPath = await _buildLocalPath(widget.mediaUrl);
      if (await File(localPath).exists()) {
        final size = await File(localPath).length();
        if (mounted) setState(() => _resolvedFileSizeBytes = size);
        return;
      }

      if (!widget.mediaUrl.startsWith('http')) {
        final file = File(widget.mediaUrl);
        if (await file.exists()) {
          final size = await file.length();
          if (mounted) setState(() => _resolvedFileSizeBytes = size);
        }
        return;
      }

      final response = await Dio().head(widget.mediaUrl);
      final length = int.tryParse(
        response.headers.value(Headers.contentLengthHeader) ?? '',
      );
      if (length != null && length > 0 && mounted) {
        setState(() => _resolvedFileSizeBytes = length);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cancelToken?.cancel('widget disposed');
    _fadeController.dispose();
    super.dispose();
  }

  // ── Cache check ─────────────────────────────────────────────────────────────

  Future<void> _checkCache() async {
    if (!widget.mediaUrl.startsWith('http')) {
      if (await File(widget.mediaUrl).exists()) {
        if (!mounted) return;
        setState(() {
          _localPath = widget.mediaUrl;
          _state = _DownloadState.downloaded;
        });
        _fadeController.forward();
      }
      return;
    }

    final cachedPath = MediaCacheService().getCachedPath(widget.mediaUrl);
    if (cachedPath != null && await File(cachedPath).exists()) {
      if (!mounted) return;
      setState(() {
        _localPath = cachedPath;
        _state = _DownloadState.downloaded;
      });
      _fadeController.forward();
      return;
    }

    final path = await _buildLocalPath(widget.mediaUrl);
    final exists = await File(path).exists();

    if (!mounted) return;

    if (exists) {
      await MediaCacheService().registerCachedMedia(
        url: widget.mediaUrl,
        localPath: path,
        mediaType: widget.mediaType == MediaType.video ? 'video' : 'image',
      );
      setState(() {
        _localPath = path;
        _state = _DownloadState.downloaded;
      });
      _fadeController.forward();
    }
  }

  // ── Download ────────────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    if (_state == _DownloadState.downloading) return;

    setState(() {
      _state = _DownloadState.downloading;
      _progress = 0.0;
    });

    try {
      final savePath = await _buildLocalPath(widget.mediaUrl);
      _cancelToken = CancelToken();

      await Dio().download(
        widget.mediaUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          if (total > 0) {
            setState(() => _progress = received / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      await MediaCacheService().registerCachedMedia(
        url: widget.mediaUrl,
        localPath: savePath,
        mediaType: widget.mediaType == MediaType.video ? 'video' : 'image',
      );

      if (!mounted) return;

      setState(() {
        _localPath = savePath;
        _state = _DownloadState.downloaded;
      });
      _fadeController.forward();
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.type == DioExceptionType.cancel) {
        // User navigated away — reset silently
        if (mounted) setState(() => _state = _DownloadState.notDownloaded);
      } else {
        setState(() => _state = _DownloadState.notDownloaded);
        _showError(e.message ?? 'Download failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _DownloadState.notDownloaded);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download failed: $msg'),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Path helpers ────────────────────────────────────────────────────────────

  Future<String> _buildLocalPath(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'qiktalk_media'));
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);

    // Derive a stable filename from the URL
    final uri = Uri.tryParse(url);
    final fileName = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.hashCode.abs().toString();

    return p.join(mediaDir.path, fileName);
  }

  // ── File size label ─────────────────────────────────────────────────────────

  String _formatSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── Preview image URL ───────────────────────────────────────────────────────

  String get _previewUrl {
    if (widget.mediaType == MediaType.video && widget.thumbnailUrl != null) {
      return widget.thumbnailUrl!;
    }
    return widget.mediaUrl;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: Background media ──────────────────────────────────
            _buildBackground(),

            // ── Layer 2: Blur + overlay (hidden after download) ────────────
            if (_state != _DownloadState.downloaded) _buildBlurOverlay(),

            // ── Layer 3: UI controls (button / progress / play icon) ────────
            _buildControlLayer(),
          ],
        ),
      ),
    );
  }

  // ── Layer 1 — background ────────────────────────────────────────────────────

  Widget _buildBackground() {
    if (_state == _DownloadState.downloaded && _localPath != null) {
      // Post-download: show real media
      if (widget.mediaBuilder != null) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.mediaBuilder!(_localPath!),
        );
      }

      if (widget.mediaType == MediaType.image) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Image.file(
            File(_localPath!),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _errorPlaceholder(),
          ),
        );
      }

      // Video — caller must provide mediaBuilder for the player
      return FadeTransition(opacity: _fadeAnimation, child: _videoCover());
    }

    // Pre-download: cached network thumbnail as blurred background
    return CachedNetworkImage(
      imageUrl: _previewUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFF1A1A1A),
        child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
      ),
    );
  }

  Widget _videoCover() {
    // Shown after video download when no mediaBuilder provided —
    // typically caller should supply one with video_player
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.thumbnailUrl != null)
          CachedNetworkImage(
            imageUrl: widget.thumbnailUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A1A)),
          )
        else
          Container(color: const Color(0xFF1A1A1A)),
        const Center(
          child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
        ),
      ],
    );
  }

  Widget _errorPlaceholder() {
    return Container(
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

  // ── Layer 2 — blur + dark overlay ───────────────────────────────────────────

  Widget _buildBlurOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(color: Colors.black.withOpacity(0.45)),
      ),
    );
  }

  // ── Layer 3 — controls ───────────────────────────────────────────────────────

  Widget _buildControlLayer() {
    switch (_state) {
      case _DownloadState.notDownloaded:
        return _buildDownloadButton();

      case _DownloadState.downloading:
        return _buildProgressIndicator();

      case _DownloadState.downloaded:
        // When no onTap handler is set (e.g. video uses its own inline player),
        // return nothing so the media widget underneath receives touch events.
        if (widget.onTap == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(color: Colors.transparent),
        );
    }
  }

  Widget _buildDownloadButton() {
    final sizeLabel = _formatSize(widget.fileSizeBytes ?? _resolvedFileSizeBytes);

    return GestureDetector(
      onTap: _startDownload,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download circle button
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),

            if (sizeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sizeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],

            // Video badge
            if (widget.mediaType == MediaType.video) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      color: Colors.white70,
                      size: 12,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Video',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return GestureDetector(
      onTap: () {
        // Tap while downloading — cancel
        _cancelToken?.cancel('user cancelled');
        if (mounted) setState(() => _state = _DownloadState.notDownloaded);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    strokeWidth: 2.5,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                // Cancel icon in the center
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_progress > 0)
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
