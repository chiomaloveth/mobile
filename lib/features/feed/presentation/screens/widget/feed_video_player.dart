import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

/// A pro-active video layout widget that ensures videos fill the screen (BoxFit.cover)
/// without excessive zooming by using the actual video aspect ratio once initialized.
class FeedVideoPlayer extends StatefulWidget {
  final BetterPlayerController controller;

  const FeedVideoPlayer({super.key, required this.controller});

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  @override
  void initState() {
    super.initState();
    // Listen for initialization to update the aspect ratio
    widget.controller.addEventsListener(_onPlayerEvent);
  }

  @override
  void dispose() {
    widget.controller.removeEventsListener(_onPlayerEvent);
    super.dispose();
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (mounted) {
        // Use Future.microtask to avoid "setState() called during build" errors
        Future.microtask(() {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewW = constraints.maxWidth;
        final double viewH = constraints.maxHeight;

        if (viewW <= 0 || viewH <= 0) return const SizedBox.shrink();

        // 1. Return the video player

        // 2. Simply return BetterPlayer wrapped in a Container that fills the space.
        // We use SizedBox.expand to force the player to take all available space,
        // trusting the BetterPlayer fit: BoxFit.cover config to fill it properly.
        return Container(
          width: viewW,
          height: viewH,
          color: Colors.black,
          child: widget.controller.isVideoInitialized() == true
              ? SizedBox.expand(
                  child: BetterPlayer(controller: widget.controller),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        );
      },
    );
  }
}
