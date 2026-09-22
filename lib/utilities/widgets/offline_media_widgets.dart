import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// OFFLINE CACHED IMAGE WIDGET
/// ═══════════════════════════════════════════════════════════════════════════
/// Automatically caches images and displays them when offline
class OfflineCachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final VoidCallback? onLoad;

  const OfflineCachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.onLoad,
  }) : super(key: key);

  @override
  State<OfflineCachedImage> createState() => _OfflineCachedImageState();
}

class _OfflineCachedImageState extends State<OfflineCachedImage> {
  final _cacheService = MediaCacheService();
  String? _cachedPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _primeCachedPath();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant OfflineCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _primeCachedPath();
      _loadImage();
    }
  }

  void _primeCachedPath() {
    if (widget.imageUrl.isEmpty) {
      _cachedPath = null;
      _isLoading = false;
      return;
    }

    if (!widget.imageUrl.startsWith('http')) {
      _cachedPath = File(widget.imageUrl).existsSync() ? widget.imageUrl : null;
      _isLoading = false;
      return;
    }

    _cachedPath = _cacheService.getCachedPath(widget.imageUrl);
    _isLoading = _cachedPath == null;
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!widget.imageUrl.startsWith('http')) {
      if (mounted) setState(() => _isLoading = false);
      if (_cachedPath != null) widget.onLoad?.call();
      return;
    }

    final cachedPath = _cacheService.getCachedPath(widget.imageUrl);
    if (cachedPath != null) {
      if (mounted) {
        setState(() {
          _cachedPath = cachedPath;
          _isLoading = false;
        });
      }
      widget.onLoad?.call();
      return;
    }

    try {
      final path = await _cacheService.cacheMedia(
        url: widget.imageUrl,
        mediaType: 'image',
      );

      if (mounted) {
        setState(() {
          _cachedPath = path;
          _isLoading = false;
        });
        if (path != null) widget.onLoad?.call();
      }
    } catch (e) {
      print('⚠️ Failed to cache image: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have a cached version, use it
    if (_cachedPath != null && File(_cachedPath!).existsSync()) {
      Widget image = Image.file(
        File(_cachedPath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );

      if (widget.borderRadius != null) {
        image = ClipRRect(borderRadius: widget.borderRadius!, child: image);
      }

      return image;
    }

    if (_isLoading && widget.placeholder != null) {
      Widget placeholder = widget.placeholder!;
      if (widget.borderRadius != null) {
        placeholder = ClipRRect(
          borderRadius: widget.borderRadius!,
          child: placeholder,
        );
      }
      return placeholder;
    }

    // Otherwise try network image with fallback
    Widget image = CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    if (widget.borderRadius != null) {
      image = ClipRRect(borderRadius: widget.borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 40,
          ),
        );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// OFFLINE CACHED VIDEO PLAYER
/// ═══════════════════════════════════════════════════════════════════════════
/// Caches videos and plays them offline
class OfflineCachedVideo extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool showControls;

  const OfflineCachedVideo({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.autoPlay = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<OfflineCachedVideo> createState() => _OfflineCachedVideoState();
}

class _OfflineCachedVideoState extends State<OfflineCachedVideo> {
  final _cacheService = MediaCacheService();
  VideoPlayerController? _controller;
  String? _cachedVideoPath;
  String? _cachedThumbnailPath;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Check if video is cached
    _cachedVideoPath = _cacheService.getCachedPath(widget.videoUrl);
    _cachedThumbnailPath = widget.thumbnailUrl != null
        ? _cacheService.getCachedPath(widget.thumbnailUrl!)
        : null;

    if (_cachedVideoPath != null) {
      // Use cached video
      await _initializePlayer(_cachedVideoPath!);
      return;
    }

    // Try to cache video
    try {
      final path = await _cacheService.cacheMedia(
        url: widget.videoUrl,
        mediaType: 'video',
        thumbnailUrl: widget.thumbnailUrl,
      );

      if (path != null && mounted) {
        _cachedVideoPath = path;
        _cachedThumbnailPath = _cacheService.getCachedPath(
          widget.thumbnailUrl ?? '',
        );
        await _initializePlayer(path);
      } else {
        // Try to play from network
        await _initializePlayer(widget.videoUrl);
      }
    } catch (e) {
      print('⚠️ Failed to cache video: $e');
      // Try network as fallback
      try {
        await _initializePlayer(widget.videoUrl);
      } catch (e) {
        print('❌ Failed to load video: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    }
  }

  Future<void> _initializePlayer(String source) async {
    try {
      // Determine if it's a file or network source
      final controller = source.startsWith('http')
          ? VideoPlayerController.network(source)
          : VideoPlayerController.file(File(source));

      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
          _hasError = false;
        });

        if (widget.autoPlay) {
          controller.play();
          setState(() => _isPlaying = true);
        }

        // Listen to player state
        controller.addListener(() {
          if (mounted && controller.value.isPlaying != _isPlaying) {
            setState(() => _isPlaying = controller.value.isPlaying);
          }
        });
      }
    } catch (e) {
      print('❌ Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildThumbnailWithLoader();
    }

    if (_hasError || _controller == null) {
      return _buildErrorWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          // Play/Pause overlay
          if (widget.showControls)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Progress indicator
          if (widget.showControls && _controller!.value.isPlaying)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailWithLoader() {
    if (_cachedThumbnailPath != null || widget.thumbnailUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail
          if (_cachedThumbnailPath != null)
            Image.file(
              File(_cachedThumbnailPath!),
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            )
          else if (widget.thumbnailUrl != null)
            OfflineCachedImage(
              imageUrl: widget.thumbnailUrl!,
              width: widget.width,
              height: widget.height,
            ),

          // Loading indicator
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 48, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text('Video unavailable', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PROFILE PICTURE WIDGET
/// ═══════════════════════════════════════════════════════════════════════════
class CachedProfilePicture extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool showBorder;

  const CachedProfilePicture({
    Key? key,
    required this.imageUrl,
    this.size = 50,
    this.showBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            )
          : null,
      child: ClipOval(
        child: imageUrl.isEmpty
            ? Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Colors.grey[600],
                ),
              )
            : OfflineCachedImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// MESSAGE MEDIA WIDGET (Images + Videos)
/// ═══════════════════════════════════════════════════════════════════════════
class CachedMessageMedia extends StatelessWidget {
  final String mediaUrl;
  final String mediaType; // 'image', 'video', 'audio', 'document'
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final bool autoPlayVideo;

  const CachedMessageMedia({
    Key? key,
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.autoPlayVideo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return OfflineCachedImage(
          imageUrl: mediaUrl,
          width: width,
          height: height,
          borderRadius: BorderRadius.circular(12),
        );

      case 'video':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: OfflineCachedVideo(
            videoUrl: mediaUrl,
            thumbnailUrl: thumbnailUrl,
            width: width,
            height: height,
            autoPlay: autoPlayVideo,
            showControls: true,
          ),
        );

      case 'audio':
        return Container(
          width: width,
          height: height ?? 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.audiotrack, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Audio file',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_present, size: 40),
                SizedBox(height: 8),
                Text('Document'),
              ],
            ),
          ),
        );
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// CACHED PROFILE AVATAR
/// ═══════════════════════════════════════════════════════════════════════════
/// Shows initials instantly, then replaces with cached photo silently.
/// Use everywhere you show user avatars — no placeholder flash.
class CachedProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double radius;
  final Color backgroundColor;

  const CachedProfileAvatar({
    Key? key,
    required this.imageUrl,
    required this.displayName,
    this.radius = 25,
    this.backgroundColor = const Color(0xFFFB8830),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';

    if (url.isEmpty) {
      return _initialsAvatar();
    }

    // Check cache synchronously — shows immediately with zero flash
    final cached = MediaCacheService().getCachedPath(url);

    if (cached != null && File(cached).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: FileImage(File(cached)),
        onBackgroundImageError: (_, __) {},
      );
    }

    // Not cached yet — show initials while downloading in background
    return _DownloadingAvatar(
      imageUrl: url,
      displayName: displayName,
      radius: radius,
      backgroundColor: backgroundColor,
    );
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _DownloadingAvatar extends StatefulWidget {
  final String imageUrl;
  final String displayName;
  final double radius;
  final Color backgroundColor;

  const _DownloadingAvatar({
    required this.imageUrl,
    required this.displayName,
    required this.radius,
    required this.backgroundColor,
  });

  @override
  State<_DownloadingAvatar> createState() => _DownloadingAvatarState();
}

class _DownloadingAvatarState extends State<_DownloadingAvatar> {
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    final path = await MediaCacheService().cacheMedia(
      url: widget.imageUrl,
      mediaType: 'image',
    );
    if (mounted && path != null && File(path).existsSync()) {
      setState(() => _localPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localPath != null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: widget.backgroundColor,
        backgroundImage: FileImage(File(_localPath!)),
        onBackgroundImageError: (_, __) {},
      );
    }

    // Show initials while downloading — no spinner, no flash
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor,
      child: Text(
        widget.displayName.isNotEmpty
            ? widget.displayName[0].toUpperCase()
            : 'U',
        style: TextStyle(
          fontSize: widget.radius * 0.85,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// CACHED DOCUMENT DOWNLOADER
/// ═══════════════════════════════════════════════════════════════════════════
/// Cache-first document download helper used by DocumentBubble.
class CachedDocumentDownloader {
  static Future<String?> getLocalPath({
    required String url,
    required String fileName,
  }) async {
    final cached = MediaCacheService().getCachedPath(url);
    if (cached != null && File(cached).existsSync()) return cached;

    return await MediaCacheService().cacheMedia(
      url: url,
      mediaType: 'document',
    );
  }
}
