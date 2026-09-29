import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:marquee/marquee.dart';

import 'package:qik_talk/features/feed/presentation/state/feed_state.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/feed_empty_state.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/feed_error_state.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/bottom_nav/provider/custom_bottom_nav_provider.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'choose_interests_screen.dart';
import 'create_post_screen.dart';
import 'qik_flash_screen.dart';
import 'friends_feed_screen.dart';
import 'widget/feed_stories.dart';
import 'widget/search_overlay.dart';
import 'notification_screen.dart';

class FeedFragment extends ConsumerStatefulWidget {
  const FeedFragment({super.key});

  @override
  ConsumerState<FeedFragment> createState() => _FeedFragmentState();
}

class _FeedFragmentState extends ConsumerState<FeedFragment>
    with AutomaticKeepAliveClientMixin {
  final SaveValues _saveValues = SaveValues();
  final ScrollController _scrollController = ScrollController();
  final List<String> _trendingSearches = [
    "Olamide Baddo gifts Naira Marley a car",
    "Burna Boy's new album release",
    "Davido's world tour announcement",
    "Wizkid's latest single trending",
    "QikTalk: The new social experience",
    "Trending music and videos",
  ];
  int _currentSearchIndex = 0;
  final Set<String> _viewedPostIds = <String>{};
  Timer? _viewTimer;
  String? _pendingViewPostId;

  String? currentUserId;
  late int _selectedTabIndex;
  int _currentReelIndex = 0;
  final PageController _reelPageController = PageController();
  final PageController _followingPageController = PageController();
  int _currentFollowingIndex = 0;

  @override
  void initState() {
    super.initState();
    // Read the shared tab index (may have been set by QikFlash before popping)
    _selectedTabIndex = ref.read(feedTabIndexProvider);
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
    // Load feeds from API via provider
    Future.microtask(() {
      ref.read(feedProvider.notifier).loadUserInfo(silent: true);
      ref.read(feedProvider.notifier).loadNotifications();
      ref.read(feedProvider.notifier).loadFollowingStories();
      _loadFeedForActiveTab();
    });

    // Check if new user needs to see interests screen BUT only if "Discover" tab (index 3) is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeNavIndex = ref.read(customBottomNavProvider).pageIndex;
      if (activeNavIndex == 3) {
        _checkAndShowInterestsScreen();
      }
    });
  }

  Future<void> _checkAndShowInterestsScreen() async {
    final feedState = ref.read(feedProvider);

    // If use info is still loading or not yet available, skip for now.
    // The listener in build() will re-trigger this once userInfo is loaded.
    if (feedState.isUserInfoLoading || feedState.userInfo == null) return;

    final bool isPreferenceSetBackend =
        feedState.userInfo?.data.preferences?.isPreferenceSet ?? false;

    final hasSeenLocal =
        await _saveValues.getBool(AppPreferenceHelper.HAS_SEEN_INTERESTS) ??
        false;

    if (!isPreferenceSetBackend && !hasSeenLocal && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ChooseInterestsScreen(),
      ).then((_) {
        // Optional: refresh if needed after modal close
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(feedProvider.notifier);
      switch (_selectedTabIndex) {
        case 0:
          notifier.loadMoreFollowingFeed();
          break;
        case 1:
          notifier.loadMorePersonalizedFeed();
          break;
      }
    }
  }

  void _loadFeedForActiveTab() {
    final notifier = ref.read(feedProvider.notifier);
    final state = ref.read(feedProvider);
    switch (_selectedTabIndex) {
      case 0:
        if (state.followingPosts.length < 2) notifier.loadFollowingFeed();
        break;
      case 1:
        if (state.personalizedPosts.length < 2) notifier.loadPersonalizedFeed();
        break;
    }
  }

  void _onTabTapped(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
    });
    // Keep the shared provider in sync so other screens can read it
    ref.read(feedTabIndexProvider.notifier).state = index;
    _loadFeedForActiveTab();
    // Scroll to top when switching tabs
    if (_selectedTabIndex == 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reelPageController.dispose();
    _followingPageController.dispose();
    _viewTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _saveValues.getString(AppPreferenceHelper.ID);
    setState(() {
      currentUserId = userId;
    });
  }

  void _scheduleView(String postId) {
    if (postId.isEmpty) return;
    if (_viewedPostIds.contains(postId)) return;
    if (_pendingViewPostId == postId && (_viewTimer?.isActive ?? false)) return;

    _viewTimer?.cancel();
    _pendingViewPostId = postId;
    _viewTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_viewedPostIds.contains(postId)) return;

      _viewedPostIds.add(postId);
      // Fire-and-forget: this is a background signal for the algorithm.
      unawaited(ref.read(feedProvider.notifier).viewPost(postId));
    });
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(initialPostType: 'Post'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double topPadding = MediaQuery.of(context).padding.top + 10;
    final feedState = ref.watch(feedProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for errors from the feed provider
    ref.listen(feedProvider.select((s) => s.error), (previous, next) {
      if (next != null && next.isNotEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(next), backgroundColor: Colors.redAccent),
        // );
      }
    });

    // Listen for external tab-index changes (e.g. QikFlash → Following)
    ref.listen(feedTabIndexProvider, (previous, next) {
      if (next != _selectedTabIndex) {
        _onTabTapped(next);
      }
    });

    // Listen for user info to arrive from backend to trigger interest selection
    // This handles the case where the app was just reinstalled and userInfo isn't ready yet.
    ref.listen(feedProvider.select((s) => s.userInfo), (previous, next) {
      if (next != null && previous == null) {
        final activeNavIndex = ref.read(customBottomNavProvider).pageIndex;
        if (activeNavIndex == 3) {
          _checkAndShowInterestsScreen();
        }
      }
    });

    // Listen for tab changes in the bottom navigation
    ref.listen(customBottomNavProvider.select((s) => s.pageIndex), (
      previous,
      next,
    ) {
      if (next == 3) {
        _checkAndShowInterestsScreen();
      } else {
        // When leaving the Discover tab, we want to ensure any playing video pauses.
        // Rebuilding the fragment with isAppTabActive=false will trigger pause
        // in child items (QikFlashItem/FriendsFeedItem).
        if (mounted) setState(() {});
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Stack(
        children: [
          // 1. The main feed content (Full screen for Reels, Offset with Radius for Following)
          Positioned.fill(
            top: _selectedTabIndex == 0 ? (topPadding + 185) : 0,
            child: _buildFeedContent(feedState),
          ),

          // 2. The custom header overlay (Single Source of Truth)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
              decoration: BoxDecoration(
                gradient: _selectedTabIndex == 1
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      )
                    : null,
                color: _selectedTabIndex == 0
                    ? AppTheme.scaffoldBg(isDark)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "QikTalk",
                        style: GoogleFonts.poppins(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : AppTheme.textPrimary(isDark),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Search - ",
                              style: GoogleFonts.poppins(
                                color: _selectedTabIndex == 1
                                    ? Colors.white
                                    : AppTheme.textSecondary(isDark),
                                fontSize: 12.0,
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 20,
                                child: Marquee(
                                  text:
                                      _trendingSearches[_currentSearchIndex %
                                          _trendingSearches.length],
                                  style: GoogleFonts.poppins(
                                    color: _selectedTabIndex == 1
                                        ? Colors.white
                                        : AppTheme.textSecondary(isDark),
                                    fontSize: 12.0,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 30.0,
                                  pauseAfterRound: const Duration(seconds: 2),
                                  accelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _openCreatePost,
                        child: SvgPicture.asset(
                          "assets/svgs/add.svg",
                          width: 24,
                          height: 24,
                          colorFilter: _selectedTabIndex == 0 && !isDark
                              ? const ColorFilter.mode(
                                  Color(0xFF1A1008),
                                  BlendMode.srcIn,
                                )
                              : null,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                        child: Badge(
                          label: Text(
                            feedState.notificationsUnreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          isLabelVisible:
                              feedState.notificationsUnreadCount > 0,
                          backgroundColor: HexColor("#FF6B00"),
                          child: SvgPicture.asset(
                            "assets/svgs/saved.svg",
                            width: 24,
                            height: 24,
                            colorFilter: _selectedTabIndex == 0 && !isDark
                                ? const ColorFilter.mode(
                                    Color(0xFF1A1008),
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      _buildTabItem("Following", 0),
                      _buildTabItem("QikFlash", 1),
                      GestureDetector(
                        onTap: () => showSearchOverlay(context),
                        child: SvgPicture.asset(
                          "assets/svgs/search.svg",
                          width: 28,
                          height: 28,
                          colorFilter: _selectedTabIndex == 0 && !isDark
                              ? const ColorFilter.mode(
                                  Color(0xFF1A1008),
                                  BlendMode.srcIn,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTabIndex == 0) ...[
                    const SizedBox(height: 5),
                    const FeedStories(),
                  ],
                ],
              ),
            ),
          ),

          // 3. Upload progress indicator
          Positioned(
            top: topPadding + 70 + (_selectedTabIndex == 0 ? 140 : 0),
            left: 0,
            right: 0,
            child: _buildUploadProgressBar(feedState),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressBar(FeedState feedState) {
    final status = feedState.postUploadStatus;

    if (status == PostUploadStatus.idle) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: status != PostUploadStatus.failed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: status == PostUploadStatus.uploading
              ? Colors.transparent
              : status == PostUploadStatus.success
              ? Colors.green
              : Colors.red,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (status == PostUploadStatus.uploading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  )
                else if (status == PostUploadStatus.success)
                  Icon(Icons.check_circle, color: Colors.green, size: 18)
                else
                  Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status == PostUploadStatus.uploading
                        ? 'Posting... ${(feedState.postUploadProgress * 100).toInt()}%'
                        : status == PostUploadStatus.success
                        ? 'Post published!'
                        : 'Failed to post',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (status == PostUploadStatus.failed)
                  GestureDetector(
                    onTap: () =>
                        ref.read(feedProvider.notifier).resetUploadStatus(),
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (status == PostUploadStatus.uploading) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: feedState.postUploadProgress > 0 ? feedState.postUploadProgress : null,
                  minHeight: 3,
                  backgroundColor: HexColor("#2A2A2A"),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    HexColor("#FF00A8"),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    // On QikFlash tab (index 1), always use white since it's over dark video
    // On Following tab (index 0), use theme-aware colors
    final bool alwaysWhite = _selectedTabIndex == 1;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isActive
                  ? (alwaysWhite || isDark
                        ? Colors.white
                        : const Color(0xFF1A1008))
                  : (alwaysWhite || isDark
                        ? Colors.white54
                        : const Color(0xFF6B5A4A)),
              fontSize: 18,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 2,
              color: alwaysWhite || isDark
                  ? Colors.white
                  : const Color(0xFF1A1008),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedContent(FeedState feedState) {
    final List<GetFeedResponseData> posts;
    final bool isLoading;
    final String? error;
    final int currentIndex;

    switch (_selectedTabIndex) {
      case 0:
        posts = feedState.followingPosts;
        isLoading = feedState.isFollowingFeedLoading;
        error = feedState.followingFeedError;
        currentIndex = _currentFollowingIndex;
        break;
      case 1:
        posts = feedState.personalizedPosts;
        isLoading = feedState.isPersonalizedFeedLoading;
        error = feedState.personalizedFeedError;
        currentIndex = _currentReelIndex;
        break;
      default:
        posts = [];
        isLoading = false;
        error = null;
        currentIndex = 0;
    }

    // Filter out empty posts (no text and no media)
    final filteredPosts = posts.where((post) {
      return post.content.trim().isNotEmpty || post.media.isNotEmpty;
    }).toList();

    if (filteredPosts.isNotEmpty) {
      final safeIndex = currentIndex.clamp(0, filteredPosts.length - 1);
      _scheduleView(filteredPosts[safeIndex].id);
    }

    if (isLoading && filteredPosts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: HexColor("#FF6B00")),
      );
    }

    if (error != null && filteredPosts.isEmpty) {
      return FeedErrorState(
        error: error,
        onRetry: () => _loadFeedForActiveTab(),
      );
    }

    if (filteredPosts.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: const FeedEmptyState(isSearching: false),
          ),
        ],
      );
    }

    final bool isAppTabActive =
        ref.watch(customBottomNavProvider).pageIndex == 3;

    // Special view for QikFlash (Reels style)
    if (_selectedTabIndex == 1) {
      return PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _reelPageController,
        itemCount: filteredPosts.length,
        onPageChanged: (index) {
          setState(() {
            _currentReelIndex = index;
            _currentSearchIndex = index;
          });
          _scheduleView(filteredPosts[index].id);
          if (index >= filteredPosts.length - 2) {
            ref.read(feedProvider.notifier).loadMorePersonalizedFeed();
          }
        },
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return QikFlashItem(
            key: ValueKey('reel_${post.id}'),
            post: post,
            isActive: index == _currentReelIndex && isAppTabActive,
            showTopBar: false,
          );
        },
      );
    }

    // Following tab - immersive vertical PageView with rounded corners
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _followingPageController,
        itemCount: filteredPosts.length,
        onPageChanged: (index) {
          setState(() {
            _currentFollowingIndex = index;
            _currentSearchIndex = index;
          });
          _scheduleView(filteredPosts[index].id);
          if (index >= filteredPosts.length - 2) {
            ref.read(feedProvider.notifier).loadMoreFollowingFeed();
          }
        },
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return FriendsFeedItem(
            key: ValueKey('following_${post.id}'),
            post: post,
            isActive: index == _currentFollowingIndex && isAppTabActive,
            showTopBar: false,
            onTapContent: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsFeedScreen(
                    posts: filteredPosts,
                    initialPostIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
