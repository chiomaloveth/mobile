import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/feed/data/models/text_overlay_model.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/utilities/video_sync_controller.dart';

class TextOverlayWidget extends StatefulWidget {
  final TextOverlay overlay;
  final bool isVisible;
  final double? parentWidth;
  final double? parentHeight;
  final VideoSyncController? syncController;
  final int? syncIndex;

  const TextOverlayWidget({
    super.key,
    required this.overlay,
    this.isVisible = true,
    this.parentWidth,
    this.parentHeight,
    this.syncController,
    this.syncIndex,
  });

  @override
  State<TextOverlayWidget> createState() => _TextOverlayWidgetState();
}

class _TextOverlayWidgetState extends State<TextOverlayWidget> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.overlay.type == OverlayType.video) {
      _initializePlayer();
      widget.syncController?.addListener(_onSyncChanged);
    }
  }

  void _onSyncChanged() {
    final bool shouldPlay = widget.syncController?.shouldPlay == true;
    debugPrint("🔄 [TextOverlayWidget] _onSyncChanged for ${widget.overlay.id}: shouldPlay=$shouldPlay, isVisible=${widget.isVisible}, controllerExists=${_betterPlayerController != null}");
    if (shouldPlay &&
        widget.isVisible &&
        _betterPlayerController != null) {
      
      // Delay playback until post-frame to match the background video's 
      // synchronized start timing.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isVisible && _betterPlayerController!.isPlaying() != true) {
          debugPrint("📹 [TextOverlayWidget] Playing overlay ${widget.overlay.id} from sync listener");
          _betterPlayerController!.play();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TextOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 1. Detect source change and re-initialize if needed
    final oldSource = oldWidget.overlay.videoUrl ?? oldWidget.overlay.localVideoPath;
    final newSource = widget.overlay.videoUrl ?? widget.overlay.localVideoPath;
    
    if (oldSource != newSource) {
      debugPrint("🔄 Video source changed for overlay ${widget.overlay.id}. Re-initializing.");
      _betterPlayerController?.dispose();
      _betterPlayerController = null;
      if (widget.overlay.type == OverlayType.video) {
        _initializePlayer();
      }
    }

    // 2. Handle visibility and playback
    if (widget.overlay.type == OverlayType.video &&
        _betterPlayerController != null) {
      if (oldWidget.isVisible != widget.isVisible) {
        final canPlay = widget.syncController == null ||
            widget.syncController!.shouldPlay;
        debugPrint("📹 [TextOverlayWidget] Visibility changed for ${widget.overlay.id}: oldIsVisible=${oldWidget.isVisible}, newIsVisible=${widget.isVisible}, canPlay=$canPlay");
        if (widget.isVisible) {
          // Only play if synchronization is already complete or no controller exists
          if (canPlay) {
            debugPrint("📹 [TextOverlayWidget] Playing overlay ${widget.overlay.id} from visibility update");
            _betterPlayerController!.play();
          }
        } else {
          debugPrint("📹 [TextOverlayWidget] Pausing overlay ${widget.overlay.id} from visibility update");
          _betterPlayerController!.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    widget.syncController?.removeListener(_onSyncChanged);
    _betterPlayerController?.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    final source = widget.overlay.videoUrl ?? widget.overlay.localVideoPath;
    
    if (source == null || source.isEmpty || !MediaUtils.isVideo(source)) {
      debugPrint("⚠️ Invalid video source skipped for overlay ${widget.overlay.id}: $source");
      if (widget.syncController != null && widget.syncIndex != null) {
        widget.syncController!.markReady(widget.syncIndex!);
      }
      return;
    }

    try {
      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
        aspectRatio: widget.overlay.aspectRatio,
        fit: BoxFit.cover,
        autoPlay: (widget.syncController == null) && widget.isVisible,
        looping: true,
            placeholder: const SizedBox.shrink(),
            showPlaceholderUntilPlay: false,
            controlsConfiguration: const BetterPlayerControlsConfiguration(
              showControls: false,
              loadingWidget: SizedBox.shrink(),
            ),
          );

      debugPrint("✅ Initializing video source for overlay ${widget.overlay.id}: $source");

      BetterPlayerDataSource dataSource = widget.overlay.videoUrl != null
          ? BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              widget.overlay.videoUrl!,
              cacheConfiguration: const BetterPlayerCacheConfiguration(
                useCache: true,
              ),
            )
          : BetterPlayerDataSource(
              BetterPlayerDataSourceType.file,
              widget.overlay.localVideoPath!,
            );

      _betterPlayerController =
          BetterPlayerController(betterPlayerConfiguration);
      _betterPlayerController!.setupDataSource(dataSource).catchError((e) {
        debugPrint("❌ BetterPlayer async setupDataSource error: $e");
        if (widget.syncController != null && widget.syncIndex != null) {
          widget.syncController!.markReady(widget.syncIndex!);
        }
      });

      // Notify synchronization controller when initialized
      _betterPlayerController!.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          if (widget.syncController != null && widget.syncIndex != null) {
            widget.syncController!.markReady(widget.syncIndex!);
          }
          if (widget.isVisible &&
              (widget.syncController == null || widget.syncController!.shouldPlay)) {
            if (_betterPlayerController?.isPlaying() != true) {
              _betterPlayerController!.play();
            }
          }
        }
      });
    } catch (e) {
      debugPrint(
          "❌ Error initializing video player for overlay ${widget.overlay.id}: $e");
      // Still mark as ready so the overall view can play even if this overlay fails
      if (widget.syncController != null && widget.syncIndex != null) {
        widget.syncController!.markReady(widget.syncIndex!);
      }
      _betterPlayerController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = widget.overlay;

    double left = overlay.position.dx;
    double top = overlay.position.dy;

    // DENORMALIZE COORDINATES:
    // If the overlay is marked as normalized, we multiply by the container's
    // dimensions to get the absolute pixel position for this specific device.
    if (overlay.isNormalized) {
      final screenWidth = widget.parentWidth ?? MediaQuery.of(context).size.width;
      final screenHeight = widget.parentHeight ?? MediaQuery.of(context).size.height;
      left = left * screenWidth;
      top = top * screenHeight;
    }

    return Positioned(
      left: left,
      top: top,
      child: Visibility(
        visible: widget.isVisible,
        maintainState: true, // Keep the player alive but hidden
        child: overlay.type == OverlayType.video
            ? _buildVideoPlayer(overlay)
            : Container(
                padding: overlay.isEmoji ? EdgeInsets.zero : const EdgeInsets.all(8),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: null,
                child: Text(
                  overlay.text,
                  textAlign: overlay.textAlign,
                  style: GoogleFonts.getFont(
                    overlay.fontFamily,
                    color: Colors.white,
                    fontSize: overlay.fontSize,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black87,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildVideoPlayer(TextOverlay overlay) {
    return SizedBox(
      height: overlay.fontSize,
      child: AspectRatio(
        aspectRatio: overlay.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _betterPlayerController != null
              ? BetterPlayer(controller: _betterPlayerController!)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
