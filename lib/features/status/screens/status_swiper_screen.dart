import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../components/status_cached_avatar.dart';
import '../model/my_status_model.dart';
import '../services/status_cache_service.dart';
import '../services/status_service.dart';
import '../screens/status_viewers_sheet.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StatusSwiperScreen
//
// WhatsApp-style status viewer.
//
// Navigation model:
//   • Swipe LEFT / RIGHT  → move between users  (PageView, horizontal slide)
//   • Tap LEFT half       → previous update for this user
//   • Tap RIGHT half      → next update for this user (or advance to next user)
//   • Long press          → pause / resume
//
// Key fixes over original:
//   1. WhatsApp slide transition — adjacent user pages are visible during swipe
//      using a custom TransformPageCallback so they slide in/out naturally.
//   2. Tap vs swipe conflict resolved — single GestureDetector with onTapUp
//      position check; horizontal drags fall cleanly to PageView.
//   3. Progress controller properly stopped & reset on user swipe via
//      _onPageChanged, with a microtask delay so the new page renders first.
//   4. _horizontalSwipeInProgress actually blocks tap handling during swipes.
//   5. Smooth bar fill animation on completed bars (200 ms tween).
// ─────────────────────────────────────────────────────────────────────────────

class StatusSwiperScreen extends StatefulWidget {
  final List<MyStatusModel> allStatuses;
  final int initialIndex;
  final bool isMyStatus;

  const StatusSwiperScreen({
    super.key,
    required this.allStatuses,
    this.initialIndex = 0,
    this.isMyStatus = false,
  });

  @override
  State<StatusSwiperScreen> createState() => _StatusSwiperScreenState();
}

class _StatusSwiperScreenState extends State<StatusSwiperScreen>
    with TickerProviderStateMixin {
  // ── Page / update tracking ──────────────────────────────────────────────────
  late PageController _pageController;
  int _userIndex = 0;
  int _updateIndex = 0;

  // ── Video ───────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoController;
  bool _videoLoading = false;
  bool _videoError = false;

  // ── Progress animation ──────────────────────────────────────────────────────
  late AnimationController _progressController;
  bool _isPaused = false;

  // ── Swipe guard — set true while PageView is being dragged ─────────────────
  bool _horizontalSwipeInProgress = false;

  // ── Viewed tracking ─────────────────────────────────────────────────────────
  final Set<String> _viewedThisSession = {};

  // ── Reply / reshare ─────────────────────────────────────────────────────────
  final TextEditingController _replyController = TextEditingController();
  bool _isSendingReply = false;
  bool _isResharing = false;

  final SaveValues _saveValues = SaveValues();
  static const Duration _imageDuration = Duration(seconds: 5);

  // ── Convenience getters ─────────────────────────────────────────────────────
  MyStatusModel get _currentUser => widget.allStatuses[_userIndex];
  Update get _currentUpdate => _currentUser.updates[_updateIndex];
  int get _totalViewCount =>
      _currentUser.updates.fold(0, (s, u) => s + u.viewCount);

  List<Viewer> get _allViewers {
    final Map<String, Viewer> seen = {};
    for (final u in _currentUser.updates) {
      for (final v in u.viewers) seen[v.id] = v;
    }
    return seen.values.toList();
  }

  // ── Init / dispose ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _userIndex = widget.initialIndex.clamp(0, widget.allStatuses.length - 1);
    _pageController = PageController(initialPage: _userIndex);

    _progressController =
        AnimationController(vsync: this, duration: _imageDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) _nextUpdate();
          });

    _loadUpdate();
    if (!widget.isMyStatus) _markViewed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    super.dispose();
  }

  // ── Viewed tracking ─────────────────────────────────────────────────────────

  Future<void> _markViewed() async {
    final id = _currentUpdate.id;
    if (_viewedThisSession.contains(id)) return;
    _viewedThisSession.add(id);

    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_status_ids') ?? [];
    if (!viewed.contains(id)) {
      viewed.add(id);
      await prefs.setStringList('viewed_status_ids', viewed);
    }

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token != null) await StatusService.markAsViewed(token, id);
    } catch (_) {}
  }

  // ── Media loading ────────────────────────────────────────────────────────────

  Future<void> _loadUpdate() async {
    // Tear down any existing video controller cleanly
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    // Reset progress bar
    _progressController.stop();
    _progressController.reset();
    _isPaused = false;
    _videoError = false;
    _videoLoading = false;

    if (!mounted) return;
    setState(() {}); // redraw with clean state before starting

    final u = _currentUpdate;

    // ── Image / text / reshare — fixed 5 s timer ────────────────────────────
    if (u.mediaType == 'image' ||
        u.mediaType == 'text' ||
        u.mediaType == 'reshare') {
      _progressController.duration = _imageDuration;
      if (mounted) {
        setState(() {});
        _progressController.forward();
      }
      return;
    }

    // ── Video ────────────────────────────────────────────────────────────────
    if (u.mediaType == 'video') {
      if (u.media.isEmpty) {
        _nextUpdate();
        return;
      }

      if (mounted) setState(() => _videoLoading = true);

      try {
        final cachedPath = await StatusCacheService.localMediaPath(u.media);
        final controller = cachedPath != null && File(cachedPath).existsSync()
            ? VideoPlayerController.file(File(cachedPath))
            : VideoPlayerController.networkUrl(Uri.parse(u.media));
        await controller.initialize();

        if (!mounted) {
          controller.dispose();
          return;
        }

        _videoController = controller;

        final videoDuration = controller.value.duration;
        _progressController.duration = videoDuration == Duration.zero
            ? const Duration(seconds: 10)
            : videoDuration;

        // Auto-advance when video ends
        controller.addListener(() {
          if (!mounted) return;
          final pos = controller.value.position;
          final dur = controller.value.duration;
          if (dur > Duration.zero && pos >= dur) _nextUpdate();
          if (controller.value.hasError) {
            if (mounted) setState(() => _videoError = true);
          }
        });

        setState(() => _videoLoading = false);
        controller.play();
        _progressController.forward();
        StatusCacheService.cacheMediaNow(u.media, mediaType: 'video');
      } catch (_) {
        if (mounted) {
          setState(() {
            _videoError = true;
            _videoLoading = false;
          });
        }
      }
    }
  }

  // ── Update navigation (within same user) ────────────────────────────────────

  void _nextUpdate() {
    if (!mounted) return;
    // ✅ Stop animation before state changes to prevent double-firing
    _progressController.stop();
    if (_updateIndex < _currentUser.updates.length - 1) {
      setState(() => _updateIndex++);
      _loadUpdate();
      if (!widget.isMyStatus) _markViewed();
    } else {
      _nextUser();
    }
  }

  void _prevUpdate() {
    if (!mounted) return;
    // ✅ Stop animation before state changes
    _progressController.stop();
    if (_updateIndex > 0) {
      setState(() => _updateIndex--);
      _loadUpdate();
    } else {
      _prevUser();
    }
  }

  // ── User navigation (PageView) ───────────────────────────────────────────────

  void _nextUser() {
    if (!mounted) return;
    if (_userIndex < widget.allStatuses.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ Defer pop to avoid '!_debugLocked' when called from animation listener
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _prevUser() {
    if (_userIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Called by PageView when the user completes a swipe to a new user
  void _onPageChanged(int page) {
    if (!mounted) return;

    // Stop current media immediately
    _progressController.stop();
    _videoController?.pause();

    setState(() {
      _userIndex = page;
      _updateIndex = 0;
      _horizontalSwipeInProgress = false;
    });

    // Delay one frame so the new page is fully laid out before starting timer
    Future.microtask(() {
      if (!mounted) return;
      _loadUpdate();
      if (!widget.isMyStatus) _markViewed();
    });
  }

  // ── Tap handling (single GestureDetector, position-based) ───────────────────
  //
  // Using onTapUp instead of split left/right GestureDetectors eliminates the
  // gesture arena conflict with PageView's horizontal drag recogniser.

  void _handleTapUp(TapUpDetails details) {
    // Ignore tap if a horizontal swipe is in progress
    if (_horizontalSwipeInProgress) return;
    if (_isPaused) return;

    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < screenWidth / 2) {
      _prevUpdate();
    } else {
      _nextUpdate();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NotificationListener<ScrollNotification>(
        // Track whether the PageView is mid-swipe so taps are blocked
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            setState(() => _horizontalSwipeInProgress = true);
          } else if (notification is ScrollEndNotification) {
            setState(() => _horizontalSwipeInProgress = false);
          }
          return false;
        },
        child: PageView.builder(
          controller: _pageController,
          // ✅ PageScrollPhysics gives the natural WhatsApp slide snap feel.
          // It does NOT compete with the internal GestureDetector because we
          // use a single onTapUp handler instead of split GestureDetectors.
          physics: const PageScrollPhysics(),
          itemCount: widget.allStatuses.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            // ✅ WhatsApp slide: neighbouring pages slide in/out alongside the
            // current page. We render all adjacent pages (not just current) so
            // the swipe transition shows real content, not a black box.
            return _StatusPage(
              statusModel: widget.allStatuses[index],
              isActive: index == _userIndex,
              child: index == _userIndex
                  ? _buildActivePage()
                  : _buildInactivePage(index),
            );
          },
        ),
      ),
    );
  }

  // ── Active page (current user) ───────────────────────────────────────────────

  Widget _buildActivePage() {
    return Stack(
      children: [
        // ── Full-screen media ────────────────────────────────────────────────
        Positioned.fill(child: _buildMedia()),

        // ── Pause overlay ────────────────────────────────────────────────────
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

        // ── Single GestureDetector covering the whole page ───────────────────
        // onTapUp: checks position → prev or next update
        // onLongPress: pause / resume
        // Horizontal drags naturally fall through to the parent PageView
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: _handleTapUp,
            onLongPressStart: (_) {
              setState(() => _isPaused = true);
              _progressController.stop();
              _videoController?.pause();
            },
            onLongPressEnd: (_) {
              setState(() => _isPaused = false);
              _progressController.forward();
              _videoController?.play();
            },
          ),
        ),

        // ── Top bar (progress bars + user info) ──────────────────────────────
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

        // ── Bottom bar (caption + reply / viewers) ────────────────────────────
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
      ],
    );
  }

  // ── Inactive page (neighbouring users shown during swipe) ───────────────────
  // Shows the first update's media blurred & dimmed so the slide feels real.

  Widget _buildInactivePage(int index) {
    final user = widget.allStatuses[index];
    if (user.updates.isEmpty) return Container(color: Colors.black);

    final firstUpdate = user.updates.first;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Media preview (image only — no video init for neighbours)
        if (firstUpdate.mediaType == 'image' && firstUpdate.media.isNotEmpty)
          FutureBuilder<String?>(
            future: StatusCacheService.localMediaPath(firstUpdate.media),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                );
              }
              return Image.network(
                firstUpdate.media,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null) {
                    StatusCacheService.cacheMediaNow(
                      firstUpdate.media,
                      mediaType: 'image',
                    );
                  }
                  return child;
                },
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              );
            },
          )
        else if (firstUpdate.mediaType == 'text')
          Container(
            color: Color(firstUpdate.backgroundColor),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              firstUpdate.media.isNotEmpty
                  ? firstUpdate.media
                  : (firstUpdate.caption ?? ''),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(color: Colors.black87),

        // Dark scrim so neighbour pages look clearly "behind"
        Container(color: Colors.black54),

        // User label centred — gives context during the swipe
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusCachedAvatar(
                imageUrl: user.user.profilePicture,
                fallbackText: user.user.username,
                radius: 32,
              ),
              const SizedBox(height: 10),
              Text(
                user.user.username,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                '${user.updates.length} update${user.updates.length == 1 ? '' : 's'}',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Media renderer (active page only) ───────────────────────────────────────

  Widget _buildMedia() {
    final u = _currentUpdate;

    if (u.mediaType == 'image') {
      return FutureBuilder<String?>(
        future: StatusCacheService.localMediaPath(u.media),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            );
          }

          return Image.network(
            u.media,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null) {
                StatusCacheService.cacheMediaNow(u.media, mediaType: 'image');
              }
              return child;
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
            ),
          );
        },
      );
    }

    if (u.mediaType == 'video') {
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
              TextButton(
                onPressed: _loadUpdate,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (u.mediaType == 'text') {
      final text = u.media.trim().isNotEmpty ? u.media : (u.caption ?? '');
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(u.backgroundColor),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (u.mediaType == 'reshare' || u.isReshare) {
      final ref = u.resharedFrom;
      if (ref == null) {
        return const Center(
          child: Icon(Icons.repeat, color: Colors.white54, size: 60),
        );
      }

      Widget media;
      if (ref.mediaType == 'image') {
        media = FutureBuilder<String?>(
          future: StatusCacheService.localMediaPath(ref.media),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.file(
                File(snapshot.data!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
            return Image.network(
              ref.media,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null) {
                  StatusCacheService.cacheMediaNow(
                    ref.media,
                    mediaType: 'image',
                  );
                }
                return child;
              },
            );
          },
        );
      } else if (ref.mediaType == 'text') {
        media = Container(
          color: const Color(0xFF1A1A1A),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            ref.media,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        media = Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white54,
              size: 72,
            ),
          ),
        );
      }

      return Stack(
        children: [
          Positioned.fill(child: media),
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.repeat, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Originally from ${ref.ownerUsername}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  // ── Top bar ──────────────────────────────────────────────────────────────────

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
          // ── Progress bars ────────────────────────────────────────────────
          Row(
            children: List.generate(
              _currentUser.updates.length,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ProgressBar(
                    state: i < _updateIndex
                        ? _BarState.completed
                        : i == _updateIndex
                        ? _BarState.active
                        : _BarState.pending,
                    controller: i == _updateIndex ? _progressController : null,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── User info row ────────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 10),
              StatusCachedAvatar(
                imageUrl: _currentUpdate.user.profilePicture,
                fallbackText: _currentUpdate.user.username,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUpdate.user.username,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _timeAgo(_currentUpdate.createdAt),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // User position dots (max 8 shown)
              if (widget.allStatuses.length > 1)
                Row(
                  children: List.generate(
                    widget.allStatuses.length.clamp(0, 8),
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _userIndex ? 8 : 5,
                      height: i == _userIndex ? 8 : 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _userIndex ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────────

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
          // Caption
          if (_currentUpdate.mediaType != 'text' &&
              _currentUpdate.caption != null &&
              _currentUpdate.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentUpdate.caption!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),

          // My status — viewer count button
          if (widget.isMyStatus)
            GestureDetector(
              onTap: () async {
                _progressController.stop();
                _videoController?.pause();
                await showModalBottomSheet(
                  context: context,
                  backgroundColor: HexColor('#1E1E1E'),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  builder: (_) => StatusViewersSheet(
                    viewers: _allViewers,
                    totalUpdates: _totalViewCount,
                    statusId: _currentUpdate.id,
                    socket: GlobalSocketService().socket,
                  ),
                );
                if (mounted) {
                  _progressController.forward();
                  _videoController?.play();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_totalViewCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Viewer — reply + reshare row
          if (!widget.isMyStatus)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openReply,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.reply,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reply',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isResharing ? null : _reshare,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: _isResharing
                          ? Colors.grey.shade700
                          : const Color(0xFF1A7F4B).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isResharing
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.repeat,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reshare',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Reply sheet ──────────────────────────────────────────────────────────────

  void _openReply() {
    _progressController.stop();
    _videoController?.pause();
    _replyController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildReplyPreviewCard(),
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextField(
                          controller: _replyController,
                          autofocus: true,
                          maxLines: null,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Reply to ${_currentUpdate.user.username}…',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isSendingReply
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              await _sendReply();
                            },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A7F4B),
                          shape: BoxShape.circle,
                        ),
                        child: _isSendingReply
                            ? const Padding(
                                padding: EdgeInsets.all(11),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
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
    ).whenComplete(() {
      if (mounted && !_isSendingReply) {
        _progressController.forward();
        _videoController?.play();
      }
    });
  }

  Widget _buildReplyPreviewCard() {
    final s = _currentUpdate;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.reply, color: Color(0xFF1A7F4B), size: 14),
                const SizedBox(width: 6),
                Text(
                  "Replying to ${s.user.username}'s status",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A7F4B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (s.mediaType == 'image' && s.media.isNotEmpty)
            Image.network(
              s.media,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 40),
            )
          else if (s.mediaType == 'text')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Color(s.backgroundColor),
              child: Text(
                s.media.isNotEmpty ? s.media : (s.caption ?? ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 8),
          if (s.caption != null &&
              s.caption!.isNotEmpty &&
              s.mediaType != 'text')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                s.caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSendingReply = true);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) throw Exception('Not authenticated');
      final owner = _currentUpdate.user;
      final chatId = await StatusService.ensureChat(
        token: token,
        otherUserId: owner.id,
      );
      if (chatId == null) throw Exception('Could not open chat');
      final messageId = await StatusService.replyToStatus(
        token: token,
        chatId: chatId,
        replyText: text,
        statusId: _currentUpdate.id,
        statusOwnerName: owner.username,
        statusMediaType: _currentUpdate.mediaType,
        statusMedia: _currentUpdate.media,
        statusCaption: _currentUpdate.caption ?? '',
      );
      if (!mounted) return;
      setState(() => _isSendingReply = false);
      _replyController.clear();
      _progressController.forward();
      _videoController?.play();
      if (messageId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reply sent to ${owner.username}'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingReply = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Reshare ──────────────────────────────────────────────────────────────────

  Future<void> _reshare() async {
    if (_isResharing) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: HexColor('#1E1E1E'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reshare to your status?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This will add ${_currentUpdate.user.username}'s status to yours.",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7F4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reshare',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isResharing = true);
    _progressController.stop();
    _videoController?.pause();

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) throw Exception('Not authenticated');
      final originalId = _currentUpdate.isReshare
          ? (_currentUpdate.resharedFrom?.statusId ?? _currentUpdate.id)
          : _currentUpdate.id;
      final success = await StatusService.reshareStatus(
        token: token,
        originalStatusId: originalId,
      );
      if (!mounted) return;
      setState(() => _isResharing = false);
      if (success) {
        _progressController.forward();
        _videoController?.play();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reshared!'),
            backgroundColor: Color(0xFF1A7F4B),
          ),
        );
      } else {
        throw Exception('Reshare failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResharing = false);
        _progressController.forward();
        _videoController?.play();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusPage
//
// Thin wrapper that gives each PageView item a black background.
// The `isActive` flag is available for any future per-page logic.
// ─────────────────────────────────────────────────────────────────────────────
class _StatusPage extends StatelessWidget {
  final MyStatusModel statusModel;
  final bool isActive;
  final Widget child;

  const _StatusPage({
    required this.statusModel,
    required this.isActive,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black, child: child);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProgressBar
//
// A single segment in the top progress bar row.
//
// Three visual states:
//   completed  → full white bar (200 ms animated fill on first render)
//   active     → AnimatedBuilder driven by the parent's AnimationController
//   pending    → empty (white24 track only)
// ─────────────────────────────────────────────────────────────────────────────

enum _BarState { completed, active, pending }

class _ProgressBar extends StatefulWidget {
  final _BarState state;
  final AnimationController? controller; // only supplied when state == active

  const _ProgressBar({super.key, required this.state, this.controller});

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  // Used only for the 200 ms fill animation on completed bars
  AnimationController? _fillController;
  Animation<double>? _fillAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.state == _BarState.completed) {
      _fillController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
      _fillAnimation = CurvedAnimation(
        parent: _fillController!,
        curve: Curves.easeOut,
      );
      _fillController!.forward();
    }
  }

  @override
  void dispose() {
    _fillController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          // Track
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Fill
          if (widget.state == _BarState.completed)
            // Animated fill for smooth look when tapping quickly
            AnimatedBuilder(
              animation: _fillAnimation ?? const AlwaysStoppedAnimation(1.0),
              builder: (_, __) => FractionallySizedBox(
                widthFactor: _fillAnimation?.value ?? 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            )
          else if (widget.state == _BarState.active &&
              widget.controller != null)
            AnimatedBuilder(
              animation: widget.controller!,
              builder: (_, __) => FractionallySizedBox(
                widthFactor: widget.controller!.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          // pending → no fill, just the white24 track
        ],
      ),
    );
  }
}
