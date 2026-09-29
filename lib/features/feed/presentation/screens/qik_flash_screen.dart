import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/data/models/feed_extensions.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/screens/create_post_screen.dart';
import 'package:qik_talk/utilities/bottom_nav/provider/custom_bottom_nav_provider.dart';
import '../../../../quick_talk_app.dart';
import 'widget/vertical_engagement_bar.dart';

import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_bottom_content.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/features/feed/data/models/text_overlay_model.dart';
import 'widget/text_overlay_widget.dart';
import 'widget/video_player_alternative.dart';
import 'package:qik_talk/utilities/video_sync_controller.dart';

import 'package:qik_talk/features/feed/presentation/screens/widget/search_overlay.dart';

class QikFlashScreen extends ConsumerStatefulWidget {
  final List<GetFeedResponseData> posts;
  final int initialPostIndex;
  final int initialMediaIndex;

  /// When true, only the passed [posts] are used (e.g. from the profile grid).
  /// When false (default), the global feed state overrides the list.
  final bool usePassedPostsOnly;

  const QikFlashScreen({
    super.key,
    required this.posts,
    this.initialPostIndex = 0,
    this.initialMediaIndex = 0,
    this.usePassedPostsOnly = false,
  });

  @override
  ConsumerState<QikFlashScreen> createState() => _QikFlashScreenState();
}

class _QikFlashScreenState extends ConsumerState<QikFlashScreen> {
  late PageController _verticalController;
  late int _currentVerticalIndex;

  @override
  void initState() {
    super.initState();

    // When coming from outside the global feed (e.g. profile), all post types
    // are included so text-only posts can be shown.
    final rawPosts = widget.usePassedPostsOnly
        ? widget.posts
        : widget.posts.where((p) => p.media.isNotEmpty).toList();

    // Find the initial index in the (possibly filtered) list
    if (widget.usePassedPostsOnly) {
      _currentVerticalIndex = rawPosts.isEmpty
          ? 0
          : widget.initialPostIndex.clamp(0, rawPosts.length - 1);
    } else {
      _currentVerticalIndex = 0;
      if (rawPosts.isNotEmpty &&
          widget.initialPostIndex >= 0 &&
          widget.initialPostIndex < rawPosts.length) {
        // Try to find the post in the already-loaded feed state.
        final feedState = ref.read(feedProvider);
        final posts = [
          ...feedState.followingPosts,
          ...feedState.personalizedPosts,
        ];
        final postId = rawPosts[widget.initialPostIndex].id;
        int postIndex = posts.indexWhere((p) => p.id == postId);

        if (postIndex != -1) {
          _currentVerticalIndex = postIndex;
        } else {
          // Fallback to rawPosts if not found in live feed state
          final newIndex = rawPosts.indexWhere((p) => p.id == postId);
          if (newIndex != -1) {
            _currentVerticalIndex = newIndex;
          }
        }
      }
    }

    _verticalController = PageController(initialPage: _currentVerticalIndex);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void _onVerticalPageChanged(int index) {
    setState(() {
      _currentVerticalIndex = index;
    });

    // Handle pagination - if we're near the end of the provided list, load more
    if (index >= widget.posts.length - 2) {
      ref.read(feedProvider.notifier).loadMorePersonalizedFeed();
    }
  }

  Widget _buildTopBar(GetFeedResponseData post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "QikTalk",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                  );
                },
                child: SvgPicture.asset(
                  "assets/svgs/add.svg",
                  width: 24,
                  height: 24,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Switch feed to Following tab before popping
                      ref.read(feedTabIndexProvider.notifier).state = 0;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text(
                      "Following",
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "QikFlash",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(width: 30, height: 2, color: Colors.white),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => showSearchOverlay(context, tab: 'qikFlash'),
                child: SvgPicture.asset(
                  "assets/svgs/search.svg",
                  width: 28,
                  height: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This allows the reels to expand as more posts are loaded
    final feedState = ref.watch(feedProvider);

    final List<GetFeedResponseData> currentPosts;
    if (widget.usePassedPostsOnly) {
      // Merge live state into the passed posts so that toggles (bookmark, like)
      // are immediately reflected in the UI. The passed list defines ordering;
      // the live provider data provides up-to-date field values.
      final liveAll = [
        ...feedState.followingPosts,
        ...feedState.personalizedPosts,
      ];
      final liveMap = {for (final p in liveAll) p.id: p};

      // Merge bookmarkedPosts (they may not be in posts/filteredPosts)
      final bookmarkedData = feedState.bookmarkedPosts?.data ?? [];
      for (final b in bookmarkedData) {
        if (!liveMap.containsKey(b.id)) {
          // Build a minimal live entry from bookmark data with the updated bookmarks array
          liveMap[b.id] = GetFeedResponseData(
            id: b.id,
            user: FeedUser(
              id: b.user.id ?? '',
              username: b.user.username ?? '',
              profilePicture: b.user.profilePicture ?? '',
            ),
            content: b.content,
            media: b.media,
            likes: b.likes.map((e) => e.toString()).toList(),
            shares: b.shares.map((e) => e.toString()).toList(),
            bookmarks: b.bookmarks.map((e) => e.toString()).toList(),
            createdAt: DateTime.tryParse(b.createdAt) ?? DateTime.now(),
            updatedAt: DateTime.tryParse(b.updatedAt) ?? DateTime.now(),
          );
        }
      }

      // Rebuild ordered list, preferring live data when available
      currentPosts = widget.posts.map((p) => liveMap[p.id] ?? p).toList();
    } else {
      final source = feedState.personalizedPosts.isNotEmpty
          ? feedState.personalizedPosts
          : widget.posts;
      currentPosts = source.where((p) => p.media.isNotEmpty).toList();
    }

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _verticalController,
              itemCount: currentPosts.length,
              onPageChanged: _onVerticalPageChanged,
              itemBuilder: (context, index) {
                final post = currentPosts[index];
                final isInitialPost =
                    index == _currentVerticalIndex &&
                    widget.posts.isNotEmpty &&
                    widget.initialPostIndex >= 0 &&
                    widget.initialPostIndex < widget.posts.length &&
                    post.id == widget.posts[widget.initialPostIndex].id;

                return QikFlashItem(
                  key: ValueKey(post.id),
                  post: post,
                  initialMediaIndex: isInitialPost
                      ? widget.initialMediaIndex
                      : 0,
                  isActive: index == _currentVerticalIndex,
                  showTopBar: false, // Top bar is now global in this screen
                );
              },
            ),
          ),
          // Global Sticky Top Bar
          if (currentPosts.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildTopBar(currentPosts[_currentVerticalIndex]),
              ),
            ),
        ],
      ),
    );
  }
}

class QikFlashItem extends ConsumerStatefulWidget {
  final GetFeedResponseData post;
  final int initialMediaIndex;
  final bool isActive;
  final bool showTopBar;
  final VoidCallback? onTapContent;

  const QikFlashItem({
    super.key,
    required this.post,
    this.initialMediaIndex = 0,
    required this.isActive,
    this.showTopBar = true,
    this.onTapContent,
  });

  @override
  ConsumerState<QikFlashItem> createState() => _QikFlashItemState();
}

class _QikFlashItemState extends ConsumerState<QikFlashItem>
    with RouteAware, WidgetsBindingObserver {
  late PageController _horizontalController;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};
  AudioPlayer? _musicPlayer;
  final SaveValues _saveValues = SaveValues();
  String? currentUserId;
  bool isMuted = false;
  bool _isVideoPaused = false;
  late int _currentMediaIndex;
  final Map<int, VideoSyncController> _syncControllers = {};
  final Map<int, bool> _mediaLoading = {};
  double _startX = 0;
  double _startY = 0;
  bool _hasTriggeredSwipe = false;
  // Tracks whether the feed tab (bottom nav index 3) is currently the active
  // tab. Updated imperatively so the .then() callback in
  // _initializeControllerAtIndex always reads the freshest value even before
  // the widget tree has had a chance to rebuild.
  bool _isScreenVisible = true;
  bool _showLikeAnimation = false;

  @override
  void initState() {
    super.initState();
    _currentMediaIndex = widget.initialMediaIndex;
    _horizontalController = PageController(
      initialPage: widget.initialMediaIndex,
    );
    _loadCurrentUser();
    if (widget.post.music != null) {
      _musicPlayer = AudioPlayer();
      _initMusic();
    }
    WidgetsBinding.instance.addObserver(this);
    // Seed the visibility flag from the current provider state so that items
    // that are built while the tab is already hidden don't auto-play.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navIndex = ref.read(customBottomNavProvider).pageIndex;
      _isScreenVisible = (navIndex == 3);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoControllers.forEach((_, controller) => controller.pause());
      _musicPlayer?.pause();
    } else if (state == AppLifecycleState.resumed) {
      final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (widget.isActive && !_isVideoPaused && isCurrentRoute) {
        final controller = _videoControllers[_currentMediaIndex];
        if (controller != null) {
          controller.play();
        }
        _musicPlayer?.play();
      }
    }
  }

  Future<void> _initMusic() async {
    debugPrint("🎵 QikFlash _initMusic called for post: ${widget.post.id}");

    if (_musicPlayer == null || widget.post.music == null) return;

    final url = widget.post.music!.audioUrl.trim();
    if (url.isEmpty) {
      debugPrint("🎵 QikFlash music URL is empty, skipping");
      return;
    }

    try {
      await _musicPlayer!.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _musicPlayer!.setLoopMode(LoopMode.one);
      await _musicPlayer!.setVolume(1.0);

      if (mounted) {
        final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
        if (widget.isActive && _isScreenVisible && isCurrentRoute) {
          _musicPlayer!.play();
        }
      }
    } catch (e) {
      debugPrint("❌ QikFlash music error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _initializeControllerAtIndex(_currentMediaIndex);
  }

  /// Called by the ref.listen in build() to imperatively mark this item as
  /// hidden/visible. This is the fastest possible signal — faster than waiting
  /// for a widget rebuild to propagate [widget.isActive].
  void _onNavTabChanged(int navIndex) {
    _isScreenVisible = (navIndex == 3);
    if (!_isScreenVisible) {
      _videoControllers.forEach((_, c) => c.pause());
      _musicPlayer?.pause();
    }
  }

  @override
  void didPushNext() {
    // A new route was pushed on top — pause immediately.
    if (mounted) {
      setState(() {
        _isScreenVisible = false;
        _videoControllers.forEach((_, controller) => controller.pause());
        _musicPlayer?.pause();
      });
    }
  }

  @override
  void didPopNext() {
    // Returned to this screen — restore visibility flag before playing.
    if (mounted) {
      setState(() {
        _isScreenVisible = true;
        final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
        if (widget.isActive && isCurrentRoute) {
          _isVideoPaused = false;
          final controller = _videoControllers[_currentMediaIndex];
          if (controller != null) {
            controller.play();
          }
          _musicPlayer?.play();
        }
      });
    }
  }

  @override
  void didUpdateWidget(QikFlashItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    // Handle play/pause when vertical active status changes
    if (widget.isActive && !oldWidget.isActive && isCurrentRoute) {
      // Swiped back to this post
      _isVideoPaused = false;
      _initializeControllerAtIndex(_currentMediaIndex);
      final controller = _videoControllers[_currentMediaIndex];
      if (controller != null) {
        controller.play();
      }
      _musicPlayer?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Swiped away from this post
      _isVideoPaused = false;
      _videoControllers.forEach((_, controller) => controller.pause());
      _musicPlayer?.pause();
    }

    // NEW: Trigger like animation if status changed to liked
    if (widget.post.isLikedBy(currentUserId ?? '') &&
        !oldWidget.post.isLikedBy(currentUserId ?? '')) {
      _triggerLikeAnimation();
    }
  }

  void _triggerLikeAnimation() {
    if (!mounted) return;
    setState(() {
      _showLikeAnimation = true;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    });
  }

  void _initializeControllerAtIndex(int index) async {
    if (widget.post.media.isEmpty || index >= widget.post.media.length) return;

    final url = widget.post.media[index];
    if (MediaUtils.isVideo(url) && !_videoControllers.containsKey(index)) {
      final cacheService = MediaCacheService();
      final cachedPath = cacheService.getCachedPath(url);

      VideoPlayerController controller;
      if (cachedPath != null) {
        controller = VideoPlayerController.file(File(cachedPath));
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        // Start background download so it's cached for the next time it's played
        cacheService.cacheMedia(url: url, mediaType: 'video');
      }

      _videoControllers[index] = controller;

      // Initialize Sync Controller for this index if it has video overlays
      final videoOverlays =
          widget.post.overlays?.fold<int>(0, (count, overlayList) {
            // This is a bit complex since post.overlays is dynamic.
            // Based on QikFlashItem's current mapping logic:
            if (_currentMediaIndex < widget.post.overlays!.length) {
              final item = widget.post.overlays![_currentMediaIndex];
              if (item is List) {
                return item.where((o) => (o as Map)['type'] == 'video').length;
              }
            }
            return 0;
          }) ??
          0;

      if (videoOverlays > 0 && !_syncControllers.containsKey(index)) {
        final sync = VideoSyncController(
          expectedCount: videoOverlays + 1,
        ); // +1 for background
        _syncControllers[index] = sync;
        sync.addListener(() {
          if (sync.shouldPlay && mounted) {
            _handleSyncReady(index);
          }
        });
      }

      if (mounted) setState(() => _mediaLoading[index] = true);

      // Start initialization in background
      controller
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                // Update chewie controller with correct aspect ratio once initialized
                if (_chewieControllers.containsKey(index)) {
                  final oldChewie = _chewieControllers[index];
                  _chewieControllers[index] = oldChewie!.copyWith(
                    aspectRatio: controller.value.aspectRatio,
                  );
                }
              });

              // Notify sync controller for background video
              if (_syncControllers.containsKey(index)) {
                _syncControllers[index]!.markReady(0);
              } else {
                // No sync needed, proceed with normal playback trigger
                _handleSyncReady(index);
              }
            }
          })
          .catchError((e) {
            debugPrint("❌ Video initialization error: $e");
            if (mounted) setState(() => _mediaLoading[index] = false);
          });

      controller.setVolume(isMuted ? 0 : 1);

      final chewieController = ChewieController(
        videoPlayerController: controller,
        // Disable autoPlay in Chewie to avoid "stale state" playback.
        // We handle playback manually in the .then() block above.
        autoPlay: false,
        looping: true,
        showControls: false,
        aspectRatio: 9 / 16, // Default aspect ratio for vertical video
        allowFullScreen: false,
        allowMuting: true,
        autoInitialize: true,
      );

      _chewieControllers[index] = chewieController;
      if (mounted) setState(() {});
    }
  }

  void _handleSyncReady(int index) {
    if (!mounted) return;

    // Toggling _mediaLoading triggers a rebuild to remove CircularProgressIndicator
    setState(() => _mediaLoading[index] = false);

    // Use post-frame callback to ensure the builder has rendered the
    // FeedVideoPlayerAlternative widget before we issue the play command.
    // This solves the "sound while screen is black" issue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Re-verify all your original navigation/visibility guards as requested
      // to ensure we don't play if the user scrolled away during the build cycle.
      final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

      if (widget.isActive &&
          _isScreenVisible &&
          index == _currentMediaIndex &&
          !_isVideoPaused &&
          isCurrentRoute) {
        final controller = _videoControllers[index];
        if (controller != null && controller.value.isInitialized) {
          controller.play();
        }

        if (_musicPlayer != null && index == 0) {
          _musicPlayer!.play();
        }
      } else {
        debugPrint(
          "ℹ️ QikFlash sync ready (post-frame) but guards failed for index $index. Navigation prevented playback. "
          "Details: isActive=${widget.isActive}, _isScreenVisible=$_isScreenVisible, indexMatch=${index == _currentMediaIndex}, "
          "isVideoPaused=$_isVideoPaused, isCurrentRoute=$isCurrentRoute",
        );
      }
    });
  }

  void _onHorizontalPageChanged(int index) {
    setState(() {
      _currentMediaIndex = index;
    });

    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    // Pause all other videos in this horizontal PageView
    _videoControllers.forEach((key, controller) {
      if (key != index) {
        controller.pause();
      } else if (widget.isActive && isCurrentRoute) {
        controller.play();
      }
    });

    // Initialize next/previous to have them ready
    _initializeControllerAtIndex(index);
    if (index + 1 < widget.post.media.length) {
      _initializeControllerAtIndex(index + 1);
    }
    if (index - 1 >= 0) {
      _initializeControllerAtIndex(index - 1);
    }
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _saveValues.getString(AppPreferenceHelper.ID);
    if (mounted) {
      setState(() {
        currentUserId = userId;
      });
    }
  }

  /// Renders a solid-color full-screen background with the post's text
  /// centered — used when a text-only post is opened in QikFlash.
  Widget _buildTextBackground(GetFeedResponseData post) {
    // Generate a deterministic color from the post id (same as feed screen)
    final hashCode = post.id.codeUnits.fold(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF1A1A2E),
      const Color(0xFF16213E),
      const Color(0xFF0F3460),
      const Color(0xFF533483),
      const Color(0xFF2C3E50),
      const Color(0xFF8E44AD),
    ];
    final bg = colors[hashCode % colors.length];

    return Container(
      color: bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 80, 32),
          child: Text(
            post.content,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _toggleVideoPlayPause() {
    final controller = _videoControllers[_currentMediaIndex];
    if (controller == null) return;

    setState(() {
      if (_isVideoPaused) {
        controller.play();
        _isVideoPaused = false;
      } else {
        controller.pause();
        _isVideoPaused = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _horizontalController.dispose();
    _videoControllers.forEach((_, controller) => controller.dispose());
    _chewieControllers.forEach((_, controller) => controller.dispose());
    _syncControllers.forEach((_, controller) => controller.dispose());
    _musicPlayer?.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    final currentUserId = ref.read(
      feedProvider.select((s) => s.userInfo?.data.id),
    );
    final bool isCurrentUser = widget.post.user.id == currentUserId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(user: widget.post.user, isCurrentUser: isCurrentUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLiked = currentUserId != null && post.isLikedBy(currentUserId!);

    // Listen to bottom-nav changes and imperatively update _isScreenVisible.
    // This fires *before* the widget tree has a chance to rebuild with the new
    // isActive value, so the .then() guard in _initializeControllerAtIndex will
    // always see the correct visibility state.
    ref.listen(customBottomNavProvider.select((s) => s.pageIndex), (_, next) {
      _onNavTabChanged(next);
    });

    return Listener(
      onPointerDown: (event) {
        _startX = event.position.dx;
        _startY = event.position.dy;
      },
      onPointerMove: (event) {
        if (_hasTriggeredSwipe) return;

        final totalDeltaX = event.position.dx - _startX;
        final totalDeltaY = (event.position.dy - _startY).abs();

        final lastIndex = post.media.isEmpty ? 0 : post.media.length - 1;
        if (totalDeltaX < -50 &&
            totalDeltaX.abs() > totalDeltaY &&
            _currentMediaIndex == lastIndex) {
          _hasTriggeredSwipe = true;
          _navigateToProfile();
        }
      },
      onPointerUp: (event) {
        _hasTriggeredSwipe = false;
      },
      onPointerCancel: (event) {
        _hasTriggeredSwipe = false;
      },
      child: GestureDetector(
        onTap: widget.onTapContent,
        onDoubleTap: () {
          if (currentUserId != null) {
            ref.read(feedProvider.notifier).toggleLike(post.id, currentUserId!);
            _triggerLikeAnimation();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background: Media PageView OR text-only colored card
            Positioned.fill(
              child: post.media.isEmpty
                  ? _buildTextBackground(post)
                  : PageView.builder(
                      controller: _horizontalController,
                      itemCount: post.media.length,
                      onPageChanged: _onHorizontalPageChanged,
                      itemBuilder: (context, index) {
                        final url = post.media[index];
                        if (MediaUtils.isVideo(url)) {
                          final controller = _videoControllers[index];

                          final sync = _syncControllers[index];

                          // spinner should only be removed when:
                          // 1. Controller is initialized
                          // 2. _mediaLoading is false (set by _handleSyncReady)
                          // 3. IF a sync controller exists, it reports shouldPlay=true (meaning all overlays are ready)
                          final isSyncReady = sync == null || sync.shouldPlay;

                          if (controller != null &&
                              controller.value.isInitialized &&
                              isSyncReady &&
                              _mediaLoading[index] != true) {
                            return GestureDetector(
                              onTap: _toggleVideoPlayPause,
                              child: FeedVideoPlayerAlternative(
                                url: url,
                                existingController: controller,
                                existingChewieController:
                                    _chewieControllers[index],
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return SizedBox.expand(
                            child: OfflineCachedImage(
                              imageUrl: MediaUtils.getThumbnailUrl(url),
                              fit: BoxFit.cover,
                              onLoad: () {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  if (_syncControllers.containsKey(index)) {
                                    _syncControllers[index]!.markReady(0);
                                  } else {
                                    _handleSyncReady(index);
                                  }
                                });
                              },
                              placeholder: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: Container(color: Colors.black),
                            ),
                          );
                        }
                      },
                    ),
            ),

            // Render Text Overlays for the current media index
            if (post.overlays != null && post.overlays!.isNotEmpty)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine the correct overlay list for the current index
                    List<dynamic> currentOverlaysRaw = [];
                    if (_currentMediaIndex < post.overlays!.length) {
                      final item = post.overlays![_currentMediaIndex];
                      if (item is List) {
                        currentOverlaysRaw = item;
                      } else if (item is Map && _currentMediaIndex == 0) {
                        currentOverlaysRaw = post.overlays!;
                      }
                    }

                    if (currentOverlaysRaw.isEmpty)
                      return const SizedBox.shrink();

                    return Stack(
                      children: currentOverlaysRaw.map((json) {
                        try {
                          final overlay = TextOverlay.fromJson(
                            Map<String, dynamic>.from(json as Map),
                          );
                          final bool isCurrentRoute =
                              ModalRoute.of(context)?.isCurrent ?? false;

                          // NEW: Overlays are only "visible" (and allowed to play) when the background is ready.
                          final sync = _syncControllers[_currentMediaIndex];
                          final bool isBgReady =
                              _mediaLoading[_currentMediaIndex] != true &&
                              (sync == null || sync.shouldPlay);

                          final bool isVisible =
                              widget.isActive &&
                              _isScreenVisible &&
                              isCurrentRoute &&
                              !_isVideoPaused &&
                              isBgReady;

                          // Count video overlays to assign correct sync index
                          int videoOverlayIndex =
                              1; // Start from 1 because background is 0
                          for (
                            int i = 0;
                            i < currentOverlaysRaw.indexOf(json);
                            i++
                          ) {
                            if ((currentOverlaysRaw[i] as Map)['type'] ==
                                'video') {
                              videoOverlayIndex++;
                            }
                          }

                          return TextOverlayWidget(
                            overlay: overlay,
                            parentWidth: constraints.maxWidth,
                            parentHeight: constraints.maxHeight,
                            isVisible: isVisible,
                            syncController:
                                _syncControllers[_currentMediaIndex],
                            syncIndex: overlay.type == OverlayType.video
                                ? videoOverlayIndex
                                : null,
                          );
                        } catch (e) {
                          debugPrint("❌ Error parsing overlay in QikFlash: $e");
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    );
                  },
                ),
              ),

            // Play icon overlay when video is paused
            if (_isVideoPaused)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _isVideoPaused ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Like Animation Overlay (Centered)
            if (_showLikeAnimation)
              Positioned.fill(
                child: Center(
                  child: Image.asset(
                    'assets/svgs/like_animation.gif',
                    key: UniqueKey(),
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // Top Gradient Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // UI Content
            SafeArea(
              child: Column(
                children: [
                  if (post.media.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          post.media.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentMediaIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: _currentMediaIndex == index
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PostBottomContent(
                                  post: post,
                                  hasMedia: post.media.isNotEmpty,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildRightSidebar(post, isLiked),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSidebar(GetFeedResponseData post, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalEngagementBar(
            post: post,
            currentUserId: currentUserId,
            isQikFlash: true,
            isActive: widget.isActive,
          ),
        ],
      ),
    );
  }
}
