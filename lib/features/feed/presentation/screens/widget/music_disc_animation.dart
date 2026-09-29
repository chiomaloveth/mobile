import 'package:flutter/material.dart';

class MusicDiscAnimation extends StatefulWidget {
  final String? coverImage;
  final bool isPlaying;
  final double size;

  const MusicDiscAnimation({
    super.key,
    required this.coverImage,
    this.isPlaying = true,
    this.size = 35,
  });

  @override
  State<MusicDiscAnimation> createState() => _MusicDiscAnimationState();
}

class _MusicDiscAnimationState extends State<MusicDiscAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MusicDiscAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double borderSize = widget.size * 0.2;

    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.5),
            width: borderSize,
          ),
        ),
        child: ClipOval(
          child: widget.coverImage != null && widget.coverImage!.isNotEmpty
              ? Image.network(
                  widget.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(Icons.music_note, color: Colors.white, size: 14),
                ),
        ),
      ),
    );
  }
}
