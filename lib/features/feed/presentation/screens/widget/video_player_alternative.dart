import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideoPlayerAlternative extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final VideoPlayerController? existingController;
  final ChewieController? existingChewieController;

  const FeedVideoPlayerAlternative({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.looping = true,
    this.existingController,
    this.existingChewieController,
  });

  @override
  State<FeedVideoPlayerAlternative> createState() => _FeedVideoPlayerAlternativeState();
}

class _FeedVideoPlayerAlternativeState extends State<FeedVideoPlayerAlternative> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.existingController != null) {
      _videoPlayerController = widget.existingController;
      _chewieController = widget.existingChewieController;
    } else {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final isLocal = !widget.url.startsWith('http');
    _videoPlayerController = isLocal
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      showControls: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowFullScreen: false,
      allowMuting: true,
      autoInitialize: true,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Only dispose if we created them
    if (widget.existingController == null) {
      _videoPlayerController?.dispose();
    }
    if (widget.existingChewieController == null) {
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final value = _videoPlayerController!.value;
    final aspectRatio = value.aspectRatio;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: aspectRatio > 1 ? 1280 : 720,
          height: aspectRatio > 1 ? 720 : 1280,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}
