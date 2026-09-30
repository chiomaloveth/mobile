import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final VideoPlayerController? controller;

  const FullscreenVideoPlayer({
    super.key,
    this.videoUrl,
    this.controller,
  }) : assert(videoUrl != null || controller != null);

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  double _dragOffset = 0;
  bool _ownsVideoController = false;

  @override
  void initState() {
    super.initState();

    // Hide system UI but keep natural orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.controller != null) {
        _videoController = widget.controller;
        _ownsVideoController = false;
      } else {
        final videoUrl = widget.videoUrl!;
        final String? cachedPath = videoUrl.startsWith('http')
            ? MediaCacheService().getCachedPath(videoUrl)
            : null;

        if (cachedPath != null && File(cachedPath).existsSync()) {
          _videoController = VideoPlayerController.file(File(cachedPath));
        } else {
          final isLocal = !videoUrl.startsWith('http');
          _videoController = isLocal
              ? VideoPlayerController.file(File(videoUrl))
              : VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        }
        _ownsVideoController = true;
      }

      if (!(_videoController?.value.isInitialized ?? false)) {
        await _videoController!.initialize();
      }

      if (!mounted) return;

      if (_ownsVideoController) {
        await _videoController!.play();
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: false, // We ARE fullscreen already
        allowMuting: true,
        showControls: true,
        showOptions: false,
        aspectRatio: _videoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white12,
        ),
        errorBuilder: (context, errorMessage) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Could not play video\n$errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _dismiss() {
    _videoController?.pause();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _chewieController?.dispose();
    if (_ownsVideoController) {
      _videoController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Swipe down to dismiss
        onVerticalDragUpdate: (details) {
          setState(() => _dragOffset += details.delta.dy);
        },
        onVerticalDragEnd: (details) {
          if (_dragOffset > 80 || (details.primaryVelocity ?? 0) > 400) {
            _dismiss();
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _dragOffset.clamp(0, 200), 0),
          child: Stack(
            children: [
              // ── Video or loading/error state ──
              Center(
                child: _hasError
                    ? _buildErrorWidget()
                    : _isInitialized
                    ? Chewie(controller: _chewieController!)
                    : _buildLoadingWidget(),
              ),

              // ── Back button always visible ──
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 26,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: const CircleBorder(),
                      ),
                      onPressed: _dismiss,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const ColoredBox(color: Colors.black);
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Could not play video',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initPlayer();
          },
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
