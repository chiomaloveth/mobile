import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:video_player/video_player.dart';

const _kOrange = Color(0xFFFF6B00);
const _kBg = Color(0xFF1A1A1A);
const _kSurface = Color(0xFF2C2C2C);

class EnhancedVideoPreviewScreen extends StatefulWidget {
  final File videoFile;
  final Function(File video, String caption) onSend;

  const EnhancedVideoPreviewScreen({
    super.key,
    required this.videoFile,
    required this.onSend,
  });

  @override
  State<EnhancedVideoPreviewScreen> createState() =>
      _EnhancedVideoPreviewScreenState();
}

class _EnhancedVideoPreviewScreenState
    extends State<EnhancedVideoPreviewScreen> {
  late VideoPlayerController _controller;
  final TextEditingController _captionController = TextEditingController();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    try {
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) setState(() => _isPlaying = _controller.value.isPlaying);
      });
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load video'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  void _sendVideo() {
    widget.onSend(widget.videoFile, _captionController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
        child: Column(
          children: [
            // ── app bar ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _sendVideo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── video area ──────────────────
            Expanded(
              child: !_isInitialized
                  ? const Center(
                      child: CircularProgressIndicator(color: _kOrange),
                    )
                  : GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                            // Play button overlay
                            AnimatedOpacity(
                              opacity: _isPlaying ? 0 : 1,
                              duration: const Duration(milliseconds: 250),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // ── video controls ──────────────
            if (_isInitialized)
              Container(
                color: _kBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Progress bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _kOrange,
                        inactiveTrackColor: _kSurface,
                        thumbColor: _kOrange,
                        trackHeight: 3,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: _controller,
                        builder: (_, value, __) {
                          final pos = value.position.inMilliseconds.toDouble();
                          final dur = value.duration.inMilliseconds.toDouble();
                          return Slider(
                            value: dur > 0 ? pos.clamp(0, dur) : 0,
                            min: 0,
                            max: dur > 0 ? dur : 1,
                            onChanged: (v) => _controller.seekTo(
                              Duration(milliseconds: v.toInt()),
                            ),
                          );
                        },
                      ),
                    ),

                    Row(
                      children: [
                        // Play/pause
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: _kSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time
                        ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller,
                          builder: (_, value, __) => Text(
                            '${_fmt(value.position)} / ${_fmt(value.duration)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Duration badge
                        ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller,
                          builder: (_, value, __) {
                            final ok = value.duration.inSeconds <= 180;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ok
                                    ? _kOrange.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ok ? _kOrange : Colors.orange,
                                ),
                              ),
                              child: Text(
                                ok ? 'Ready to send' : 'Max 3 min',
                                style: TextStyle(
                                  color: ok ? _kOrange : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ── caption bar ─────────────────
            Container(
              color: _kBg,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: _kSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendVideo,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: _kOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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
    );
  }
}
