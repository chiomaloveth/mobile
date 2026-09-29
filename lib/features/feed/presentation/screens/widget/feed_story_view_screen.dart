import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/story_viewers_sheet.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/video_sync_controller.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/text_overlay_widget.dart';
import 'package:qik_talk/features/feed/data/models/text_overlay_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'dart:io';

class FeedStoryViewScreen extends ConsumerStatefulWidget {
  final List<Update> updates;
  final bool isMyStatus;

  const FeedStoryViewScreen({
    super.key,
    required this.updates,
    this.isMyStatus = false,
  });

  @override
  ConsumerState<FeedStoryViewScreen> createState() => _FeedStoryViewScreenState();
}

class _FeedStoryViewScreenState extends ConsumerState<FeedStoryViewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  VideoSyncController? _syncController;
  late AnimationController _progressController;

  // ── State flags ──
  final Set<String> _viewedThisSession = {};
  bool _isPaused = false;
  bool _videoError = false;
  bool _videoLoading = false;

  static const Duration imageDuration = Duration(seconds: 5);

  Update get _currentStatus => widget.updates[_currentIndex];

  List<StoryViewer> get _allViewers {
    final Map<String, StoryViewer> seen = {};
    for (final update in widget.updates) {
      if (update.viewers != null) {
        for (final v in update.viewers!) {
          seen[v.id ?? v.userId ?? ''] = v;
        }
      }
    }
    return seen.values.toList();
  }

  int get _totalViewCount {
    int count = 0;
    for (final update in widget.updates) {
      count += update.viewCount ?? 0;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: imageDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _goToNext();
            }
          });

    _loadCurrentStatus();
    if (!widget.isMyStatus) _markCurrentAsViewed();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // VIEW TRACKING
  // ─────────────────────────────────────────────

  Future<void> _markCurrentAsViewed() async {
    final statusId = _currentStatus.updateId ?? _currentStatus.id;
    if (statusId == null || _viewedThisSession.contains(statusId)) return;
    _viewedThisSession.add(statusId);

    // ✅ Persist locally so the ring turns grey immediately on back-press
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_status_ids') ?? [];
    if (!viewed.contains(statusId)) {
      viewed.add(statusId);
      await prefs.setStringList('viewed_status_ids', viewed);
    }

    // ✅ Tell the backend — adds current userId to viewers array
    try {
      ref.read(feedProvider.notifier).viewStory(statusId);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // MEDIA LOADING
  // ─────────────────────────────────────────────

  Future<void> _loadCurrentStatus() async {
    await _videoController?.dispose();
    _videoController = null;
    _syncController?.dispose();
    _syncController = null;
    _progressController.reset();
    _isPaused = false;
    _videoError = false;
    _videoLoading = false;

    final status = _currentStatus;
    debugPrint("Loading story update: ${status.mediaType} — ${status.media}");

    if (status.mediaType == 'text') {
      _progressController.duration = imageDuration;
      if (mounted) {
        setState(() {});
        _progressController.forward();
      }
      return;
    }

    if (status.mediaType == 'image') {
      _progressController.duration = imageDuration;
      if (mounted) {
        setState(() => _videoLoading = true);
      }
      
      if (status.overlays != null && status.overlays!.isNotEmpty) {
        final videoOverlays = status.overlays!.where((o) {
          try {
            return (o as Map)['type'] == 'video';
          } catch (_) {
            return false;
          }
        }).length;

        if (videoOverlays > 0) {
          _syncController = VideoSyncController(expectedCount: videoOverlays + 1);
          _syncController!.addListener(() {
            if (_syncController?.shouldPlay == true && mounted) {
              _handleSyncReady();
            }
          });
        }
      }
      return;
    }

    if (status.mediaType == 'video') {
      final mediaUrl = status.media;
      if (mediaUrl == null || mediaUrl.isEmpty) {
        _goToNext();
        return;
      }

      if (mounted) setState(() => _videoLoading = true);

      if (status.overlays != null && status.overlays!.isNotEmpty) {
        final videoOverlays = status.overlays!.where((o) {
          try {
            return (o as Map)['type'] == 'video';
          } catch (_) {
            return false;
          }
        }).length;

        if (videoOverlays > 0) {
          _syncController = VideoSyncController(expectedCount: videoOverlays + 1);
          _syncController!.addListener(() {
            if (_syncController?.shouldPlay == true && mounted) {
              _handleSyncReady();
            }
          });
        }
      }

      try {
        final cacheService = MediaCacheService();
        final cachedPath = cacheService.getCachedPath(mediaUrl);

        if (cachedPath != null && File(cachedPath).existsSync()) {
          _videoController = VideoPlayerController.file(File(cachedPath));
        } else {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
          // Start background caching
          cacheService.cacheMedia(url: mediaUrl, mediaType: 'video');
        }

        await _videoController!.initialize();

        final duration = _videoController!.value.duration;
        if (!mounted) return;

        _progressController.duration = duration == Duration.zero
            ? const Duration(seconds: 10)
            : duration;

        _videoController!.addListener(() {
          if (!mounted) return;
          final pos = _videoController!.value.position;
          final dur = _videoController!.value.duration;

          if (dur > Duration.zero && pos >= dur) _goToNext();

          if (_videoController!.value.hasError) {
            setState(() {
              _videoError = true;
              _videoLoading = false;
            });
          }
        });

        if (_syncController == null) {
          setState(() => _videoLoading = false);
          _handleSyncReady();
        } else {
          _syncController!.markReady(0);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _videoError = true;
            _videoLoading = false;
          });
        }
      }
    }
  }

  void _handleSyncReady() {
    if (!mounted) return;
    
    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isCurrentRoute || _isPaused) return;

    setState(() => _videoLoading = false);
    
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
    }
    
    _progressController.forward();
  }

  // ─────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────

  void _goToNext() {
    if (!mounted) return;
    if (_currentIndex < widget.updates.length - 1) {
      setState(() => _currentIndex++);
      _loadCurrentStatus();
      if (!widget.isMyStatus) _markCurrentAsViewed();
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPrevious() {
    if (!mounted) return;
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadCurrentStatus();
    }
  }

  // ─────────────────────────────────────────────
  // GESTURES
  // ─────────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isPaused = true);
    _progressController.stop();
    _videoController?.pause();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isPaused = false);
    _progressController.forward();
    _videoController?.play();
  }

  void _handleTap(TapUpDetails details) {
    if (_isPaused) return;
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < screenWidth / 2) {
      _goToPrevious();
    } else {
      _goToNext();
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _handleTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          children: [
            // ── Full-screen media ──
            Positioned.fill(child: _buildMedia()),

            // ── Text Overlays (Stories) ──
            if (_currentStatus.overlays != null && _currentStatus.overlays!.isNotEmpty)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: _currentStatus.overlays!.map((json) {
                        try {
                          final overlay = TextOverlay.fromJson(
                            Map<String, dynamic>.from(json),
                          );

                          // Count video overlays to assign correct sync index
                          int videoOverlayIndex = 1;
                          for (int i = 0; i < _currentStatus.overlays!.indexOf(json); i++) {
                            try {
                              final type = (_currentStatus.overlays![i] as Map)['type']?.toString().toLowerCase();
                              if (type == 'video' || type == '2') {
                                videoOverlayIndex++;
                              }
                            } catch (_) {}
                          }

                          return TextOverlayWidget(
                            key: ValueKey('${overlay.id}_$_currentIndex'),
                            overlay: overlay,
                            parentWidth: constraints.maxWidth,
                            parentHeight: constraints.maxHeight,
                            isVisible: !_isPaused,
                            syncController: _syncController,
                            syncIndex: overlay.type == OverlayType.video ? videoOverlayIndex : null,
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    );
                  },
                ),
              ),

            // ── Pause overlay ──
            if (_isPaused)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Icon(
                      Icons.pause_circle_outline,
                      color: Colors.white70,
                      size: 72,
                    ),
                  ),
                ),
              ),

            // ── Top bar ──
            Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

            // ── Bottom bar ──
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MEDIA WIDGET
  // ─────────────────────────────────────────────

  Widget _buildMedia() {
    final status = _currentStatus;

    if (status.mediaType == 'image') {
      final imageUrl = status.media;
      if (imageUrl == null || imageUrl.isEmpty) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
        );
      }
      return OfflineCachedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        onLoad: () {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_syncController != null) {
              _syncController!.markReady(0);
            } else if (_videoLoading) {
              setState(() => _videoLoading = false);
              _progressController.forward();
            }
          });
        },
        errorWidget: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
        ),
      );
    }

    if (status.mediaType == 'video') {
      if (_videoLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      if (_videoError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 60),
              const SizedBox(height: 12),
              const Text("Could not play video", style: TextStyle(color: Colors.white70)),
              TextButton(onPressed: _loadCurrentStatus, child: const Text("Retry", style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      }
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (status.mediaType == 'text') {
      final textContent = (status.media ?? status.caption ?? '').trim();
      if (textContent.isEmpty) {
        return const Center(
          child: Icon(Icons.notes, color: Colors.white54, size: 60),
        );
      }

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(status.backgroundColor ?? 0xFF1A1A1A),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          textContent,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 12,
        bottom: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBars(),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: (_currentStatus.user?.profilePicture ?? '').isNotEmpty
                    ? NetworkImage(_currentStatus.user!.profilePicture!)
                    : null,
                child: (_currentStatus.user?.profilePicture ?? '').isEmpty
                    ? Text(
                        (_currentStatus.user?.username ?? '').isNotEmpty
                            ? _currentStatus.user!.username![0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStatus.user?.username ?? 'Unknown',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      _timeAgo(_currentStatus.createdAt ?? DateTime.now()),
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStatus.mediaType != 'text' && (_currentStatus.caption ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentStatus.caption!,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
              ),
            ),

          GestureDetector(
            onTap: () async {
              _progressController.stop();
              _videoController?.pause();
              await showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.cardBg(Theme.of(context).brightness == Brightness.dark),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                isScrollControlled: true,
                builder: (_) => StoryViewersSheet(
                  viewers: widget.isMyStatus ? _allViewers : [],
                  totalUpdates: _totalViewCount,
                ),
              );
              if (mounted) {
                _progressController.forward();
                _videoController?.play();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white30)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text('$_totalViewCount', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars() {
    return Row(
      children: List.generate(widget.updates.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Stack(
              children: [
                Container(height: 3, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                if (index < _currentIndex)
                  Container(height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)))
                else if (index == _currentIndex)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(widthFactor: _progressController.value, child: Container(height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))));
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
