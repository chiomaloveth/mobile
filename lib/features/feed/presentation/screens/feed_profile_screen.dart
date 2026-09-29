import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/features/feed/presentation/screens/follow_list_screen.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/features/feed/presentation/screens/create_post_screen.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'qik_flash_screen.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'edit_profile/add_link_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings/settings_and_privacy_screen.dart';
//import 'settings/security/security_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final FeedUser user;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.isCurrentUser,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _mainScrollController = ScrollController();
  final SaveValues _saveValues = SaveValues();
  bool _isLoadingChat = false;

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;

    // Basic sanitization: ensure there's a scheme
    String finalUrl = urlString;
    if (!finalUrl.startsWith('http')) {
      finalUrl = 'https://$finalUrl';
    }

    final Uri url = Uri.parse(finalUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onMainScroll);

    // Fetch user info, user posts, and bookmarks when the screen loads
    if (widget.isCurrentUser) {
      Future.microtask(() {
        ref.read(feedProvider.notifier).loadUserInfo(silent: true);
        ref.read(feedProvider.notifier).loadUserPostsForProfile();
        ref.read(feedProvider.notifier).loadBookmarkedPosts();
      });
    } else {
      Future.microtask(() {
        ref.read(feedProvider.notifier).loadOtherUserInfo(widget.user.id);
        ref
            .read(feedProvider.notifier)
            .loadOtherUserPostsForProfile(widget.user.id);
      });
    }
  }

  String? _getDisplayLink(dynamic userData) {
    if (userData == null) return null;
    if (userData.link != null && userData.link!.isNotEmpty) {
      return userData.link;
    } else if (userData.youtube != null && userData.youtube!.isNotEmpty) {
      return userData.youtube;
    } else if (userData.instagram != null && userData.instagram!.isNotEmpty) {
      return userData.instagram;
    }
    return null;
  }

  void _onMainScroll() {
    if (_mainScrollController.position.pixels >=
        _mainScrollController.position.maxScrollExtent - 400) {
      if (widget.isCurrentUser) {
        ref.read(feedProvider.notifier).loadMoreUserPostsForProfile();
      } else {
        ref
            .read(feedProvider.notifier)
            .loadMoreOtherUserPostsForProfile(widget.user.id);
      }
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final userPosts = widget.isCurrentUser
        ? feedState.userProfilePosts
        : feedState.otherUserProfilePosts;
    final isLoadingInfo = widget.isCurrentUser
        ? feedState.isUserInfoLoading
        : feedState.isOtherUserInfoLoading;
    final isLoadingPosts = widget.isCurrentUser
        ? feedState.isUserProfilePostsLoading
        : feedState.isOtherUserProfilePostsLoading;

    final userData = widget.isCurrentUser
        ? feedState.userInfo
        : feedState.otherUserInfo;

    return DefaultTabController(
      length: widget.isCurrentUser ? 3 : 2,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        floatingActionButton: widget.isCurrentUser
            ? _buildFloatingCreateButton()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: isLoadingInfo && userData == null && widget.isCurrentUser
            ? Center(
                child: CircularProgressIndicator(color: HexColor("#FF00A8")),
              )
            : SafeArea(
                child: NestedScrollView(
                  controller: _mainScrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: SvgPicture.asset(
                                      "assets/svgs/add_account.svg",
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        isDark
                                            ? Colors.white
                                            : AppTheme.textPrimary(isDark),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _getUsername(),
                                        style: GoogleFonts.poppins(
                                          color: isDark
                                              ? Colors.white
                                              : AppTheme.textPrimary(isDark),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      SvgPicture.asset(
                                        "assets/svgs/dropdown_icon.svg",
                                        width: 9,
                                        height: 9,
                                        fit: BoxFit.scaleDown,
                                        colorFilter: ColorFilter.mode(
                                          isDark
                                              ? Colors.white
                                              : AppTheme.textPrimary(isDark),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: PopupMenuButton<int>(
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.85)
                                            : AppTheme.textPrimary(isDark),
                                        size: 24,
                                      ),
                                      color: AppTheme.popupBg(isDark),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      offset: const Offset(0, 40),
                                      itemBuilder: (context) => [
                                        if (widget.isCurrentUser) ...[
                                          PopupMenuItem(
                                            value: 1,
                                            child: Text(
                                              "Settings & Privacy",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.popupText(
                                                  isDark,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          /*
                                          PopupMenuItem(
                                            value: 2,
                                            child: Text(
                                              "Security  & Permission",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.popupText(isDark),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          */
                                        ] else ...[
                                          PopupMenuItem(
                                            value: 3,
                                            child: Text(
                                              "Report User",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.popupText(
                                                  isDark,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 4,
                                            child: Text(
                                              "Block User",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.popupText(
                                                  isDark,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                      onSelected: (value) {
                                        debugPrint(
                                          "Profile menu selected: $value",
                                        );
                                        if (value == 1) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SettingsAndPrivacyScreen(),
                                            ),
                                          );
                                        } else if (value == 2) {
                                          /*
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SecurityScreen(),
                                            ),
                                          );
                                          */
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: isDark
                                  ? Colors.white30
                                  : Colors.grey.withOpacity(0.3),
                              thickness: 1,
                            ),
                            const SizedBox(height: 20),

                            // Avatar
                            Builder(
                              builder: (context) {
                                final pictureUrl = _getProfileImageUrl();
                                final username = _getUsername();
                                final initials = username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?';

                                return Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        pictureUrl != null &&
                                            pictureUrl.isNotEmpty &&
                                            pictureUrl.startsWith('http')
                                        ? Image.network(
                                            MediaUtils.getThumbnailUrl(
                                              pictureUrl,
                                            ),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return _buildInitialsPlaceholder(
                                                    initials,
                                                  );
                                                },
                                          )
                                        : _buildInitialsPlaceholder(initials),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            // Handle
                            Center(
                              child: Text(
                                "@${_getUsername().toLowerCase().replaceAll(' ', '_')}",
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.textPrimary(isDark),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Stats Row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FollowListScreen(
                                            userId: widget.user.id,
                                            initialTab: 1,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildStatItem(
                                      _formatCount(
                                        widget.isCurrentUser
                                            ? (feedState
                                                      .userInfo
                                                      ?.data
                                                      .followingCount ??
                                                  0)
                                            : (feedState
                                                      .otherUserInfo
                                                      ?.data
                                                      .followingCount ??
                                                  0),
                                      ),
                                      "Following",
                                    ),
                                  ),
                                  const SizedBox(width: 37),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FollowListScreen(
                                            userId: widget.user.id,
                                            initialTab: 0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildStatItem(
                                      _formatCount(
                                        widget.isCurrentUser
                                            ? (feedState
                                                      .userInfo
                                                      ?.data
                                                      .followersCount ??
                                                  0)
                                            : (feedState
                                                      .otherUserInfo
                                                      ?.data
                                                      .followersCount ??
                                                  0),
                                      ),
                                      "Followers",
                                    ),
                                  ),
                                  const SizedBox(width: 37),
                                  _buildStatItem(
                                    "${widget.isCurrentUser ? (feedState.userInfo?.data.postsCount ?? 0) : (feedState.otherUserInfo?.data.postsCount ?? 0)}",
                                    "Posts",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Action Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.isCurrentUser
                                      ? _buildEditProfileButton()
                                      : _buildFollowButton(),
                                  const SizedBox(width: 8),
                                  _buildSquareIconButton(
                                    SvgPicture.asset(
                                      "assets/svgs/edit_profile_share.svg",
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        isDark
                                            ? Colors.white
                                            : AppTheme.textPrimary(isDark),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Bio & Social
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  if (widget.isCurrentUser &&
                                      feedState.userInfo?.data.about != null &&
                                      feedState.userInfo!.data.about.isNotEmpty)
                                    Text(
                                      feedState.userInfo!.data.about,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: isDark
                                            ? Colors.white70
                                            : AppTheme.textSecondary(isDark),
                                        fontSize: 13,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final dynamic userData =
                                          widget.isCurrentUser
                                          ? feedState.userInfo?.data
                                          : feedState.otherUserInfo?.data;

                                      if (userData == null) {
                                        return const SizedBox.shrink();
                                      }

                                      String? displayLink;
                                      Widget? iconWidget;
                                      bool showLinkText = true;

                                      // Priority: Website (Text) > YouTube (Logo) > Instagram (Logo)
                                      if (userData.link != null &&
                                          userData.link!.isNotEmpty) {
                                        displayLink = userData.link;
                                        iconWidget = Icon(
                                          Icons.link,
                                          color: HexColor('#A26743'),
                                          size: 16,
                                        );
                                        showLinkText = true;
                                      } else if (userData.youtube != null &&
                                          userData.youtube!.isNotEmpty) {
                                        displayLink = userData.youtube;
                                        iconWidget = SvgPicture.asset(
                                          'assets/svgs/youtube.svg',
                                          width: 16,
                                          height: 16,
                                        );
                                        showLinkText = false;
                                      } else if (userData.instagram != null &&
                                          userData.instagram!.isNotEmpty) {
                                        displayLink = userData.instagram;
                                        iconWidget = SvgPicture.asset(
                                          'assets/svgs/color_instagram.svg',
                                          width: 16,
                                          height: 16,
                                        );
                                        showLinkText = false;
                                      }

                                      if (displayLink == null ||
                                          displayLink.isEmpty) {
                                        if (widget.isCurrentUser) {
                                          return GestureDetector(
                                            onTap: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddLinkScreen(),
                                                ),
                                              );
                                              // Refresh profile info when returning from add link screen
                                              if (context.mounted &&
                                                  widget.isCurrentUser) {
                                                ref
                                                    .read(feedProvider.notifier)
                                                    .loadUserInfo();
                                              }
                                            },
                                            child: Text(
                                              "tap to add link",
                                              style: GoogleFonts.poppins(
                                                color: HexColor('#A26743'),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }

                                      return GestureDetector(
                                        onTap: () => _launchURL(displayLink),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (iconWidget != null) iconWidget,
                                            if (iconWidget != null &&
                                                showLinkText)
                                              const SizedBox(width: 4),
                                            if (showLinkText)
                                              Text(
                                                displayLink,
                                                style: GoogleFonts.poppins(
                                                  color: HexColor('#A26743'),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  Builder(
                                    builder: (context) {
                                      final dynamic userData =
                                          widget.isCurrentUser
                                          ? feedState.userInfo?.data
                                          : feedState.otherUserInfo?.data;

                                      if (userData == null) {
                                        return const SizedBox.shrink();
                                      }

                                      final displayLink = _getDisplayLink(
                                        userData,
                                      );
                                      final hasInstagram =
                                          userData.instagram != null &&
                                          userData.instagram!.isNotEmpty &&
                                          userData.instagram != displayLink;
                                      final hasYoutube =
                                          userData.youtube != null &&
                                          userData.youtube!.isNotEmpty &&
                                          userData.youtube != displayLink;

                                      if (!hasInstagram && !hasYoutube) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (hasInstagram)
                                              GestureDetector(
                                                onTap: () => _launchURL(
                                                  userData.instagram,
                                                ),
                                                child: _buildSocialIcon(
                                                  SvgPicture.asset(
                                                    'assets/svgs/color_instagram.svg',
                                                  ),
                                                ),
                                              ),
                                            if (hasInstagram && hasYoutube)
                                              const SizedBox(width: 15),
                                            if (hasYoutube)
                                              GestureDetector(
                                                onTap: () => _launchURL(
                                                  userData.youtube,
                                                ),
                                                child: _buildSocialIcon(
                                                  SvgPicture.asset(
                                                    'assets/svgs/youtube.svg',
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      // Pinned TabBar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            indicatorColor: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            indicatorWeight: 2,
                            dividerColor: Colors.transparent,
                            labelColor: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            unselectedLabelColor: isDark
                                ? Colors.white38
                                : AppTheme.textSecondary(isDark),
                            tabs: [
                              Tab(
                                icon: SvgPicture.asset(
                                  "assets/svgs/tab.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    isDark
                                        ? Colors.white
                                        : AppTheme.textPrimary(isDark),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              Tab(
                                icon: SvgPicture.asset(
                                  "assets/svgs/love_icon.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    isDark
                                        ? Colors.white
                                        : AppTheme.textPrimary(isDark),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              if (widget.isCurrentUser)
                                Tab(
                                  icon: SvgPicture.asset(
                                    "assets/svgs/bookmark.svg",
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      isDark
                                          ? Colors.white
                                          : AppTheme.textPrimary(isDark),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          backgroundColor: AppTheme.scaffoldBg(isDark),
                        ),
                      ),
                    ];
                  },
                  body: isLoadingPosts && userPosts.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? Colors.white54
                                : AppTheme.accent(isDark),
                          ),
                        )
                      : TabBarView(
                          children: [
                            // ── Tab 1: All Posts ──
                            _buildAllPostsTab(userPosts),
                            // ── Tab 2: Saved Posts ──
                            _buildMediaPostsTab([], "No saved posts yet"),
                            // ── Tab 3: Bookmarks ──
                            if (widget.isCurrentUser) _buildBookmarksTab(),
                          ],
                        ),
                ),
              ),
      ),
    );
  }

  // ---------- tab content builders ----------

  /// Converts a profile post to a feed post for navigation.
  GetFeedResponseData _toFeedPost(dynamic post) {
    if (post is GetUserPostProfleResponseData) {
      return GetFeedResponseData(
        id: post.id,
        user: FeedUser(
          id: post.user.id ?? '',
          username: post.user.username ?? 'Unknown',
          profilePicture: post.user.profilePicture ?? '',
        ),
        content: post.content,
        media: post.media,
        likes: post.likes,
        shares: post.shares,
        views: post.views,
        commentCount: post.commentCount,
        music: post.music,
        allowComment: post.allowComment,
        bookmarks: post.bookmarks,
        privacy: post.privacy,
        createdAt: DateTime.tryParse(post.createdAt) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(post.updatedAt) ?? DateTime.now(),
      );
    } else if (post is GetOtherUserProfilePostData) {
      return GetFeedResponseData(
        id: post.id,
        user: FeedUser(
          id: post.user.id ?? '',
          username: post.user.username ?? 'Unknown',
          profilePicture: post.user.profilePicture ?? '',
        ),
        content: post.content ?? '',
        media: post.media.whereType<String>().toList(),
        likes: post.likes,
        shares: post.shares,
        views: post.views,
        commentCount: 0, // Not provided in new model
        music: null, // Not provided in new model
        allowComment: post.allowComment,
        bookmarks: post.bookmarks,
        privacy: post.privacy,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );
    }
    return GetFeedResponseData.empty();
  }

  Widget _buildAllPostsTab(List<dynamic> posts) {
    // Convert all posts for QikFlash navigation (text + media)
    final feedPosts = posts.map((p) => _toFeedPost(p)).toList();
    final isLoadingMore = ref.watch(
      feedProvider.select(
        (s) => widget.isCurrentUser
            ? (s.isUserProfilePostsLoading && s.userProfilePosts.isNotEmpty)
            : (s.isOtherUserProfilePostsLoading &&
                  s.otherUserProfilePosts.isNotEmpty),
      ),
    );

    return GridView.builder(
      // No independent controller anymore for unified scroll
      physics:
          const AlwaysScrollableScrollPhysics(), // Let NestedScrollView handle it
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 137 / 182,
      ),
      itemCount: posts.length + (isLoadingMore ? 3 : 0),
      itemBuilder: (context, index) {
        // Loading placeholders at the bottom while fetching the next page
        if (index >= posts.length) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }

        final post = posts[index];
        return GestureDetector(
          onTap: () {
            if (feedPosts.isEmpty) return;
            // Pass ALL posts to QikFlash (text + media).
            // QikFlash shows text posts as colored cards when usePassedPostsOnly=true.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QikFlashScreen(
                  posts: feedPosts,
                  initialPostIndex: index,
                  usePassedPostsOnly: true,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                ((post is GetUserPostProfleResponseData &&
                        post.media.isNotEmpty) ||
                    (post is GetOtherUserProfilePostData &&
                        post.media.isNotEmpty))
                ? _buildMediaGridItem(post)
                : _buildTextPostTile(post),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Bookmarks tab (Tab 3)
  // ------------------------------------------------------------------

  /// Converts a bookmark entry to a [GetFeedResponseData] for QikFlash.
  GetFeedResponseData _mapBookmarkToFeed(GetBookmarkResponseData bookmark) {
    return GetFeedResponseData(
      id: bookmark.id,
      user: FeedUser(
        id: bookmark.user.id ?? '',
        username: bookmark.user.username ?? 'Unknown',
        profilePicture: bookmark.user.profilePicture ?? '',
      ),
      content: bookmark.content,
      media: bookmark.media,
      likes: bookmark.likes.map((e) => e.toString()).toList(),
      shares: bookmark.shares.map((e) => e.toString()).toList(),
      bookmarks: bookmark.bookmarks.map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(bookmark.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(bookmark.updatedAt) ?? DateTime.now(),
    );
  }

  Widget _buildBookmarksTab() {
    final feedState = ref.watch(feedProvider);
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    if (feedState.isBookmarkedLoading &&
        (feedState.bookmarkedPosts == null ||
            feedState.bookmarkedPosts!.data.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }

    final bookmarks = feedState.bookmarkedPosts?.data ?? [];

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Convert all bookmarks to feed posts once so QikFlash gets the full list
    final List<GetFeedResponseData> feedPosts = bookmarks
        .map(_mapBookmarkToFeed)
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).loadBookmarkedPosts(),
      color: Colors.white,
      backgroundColor: HexColor('#FF6B00'),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 137 / 182,
        ),
        itemCount: feedPosts.length,
        itemBuilder: (context, index) {
          final post = feedPosts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QikFlashScreen(
                    posts: feedPosts,
                    initialPostIndex: index,
                    usePassedPostsOnly: true,
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                post.media.isNotEmpty
                    ? Image.network(
                        MediaUtils.getThumbnailUrl(post.media.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: HexColor('#1A1A1A'),
                          child: const Icon(
                            Icons.videocam,
                            color: Colors.white54,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: HexColor('#1A1A1A'),
                          border: Border.all(color: Colors.white10, width: 0.5),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              post.content,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                // View Count Overlay for Bookmarks
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/views_eye.svg",
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(post.views),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingCreateButton() {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.only(bottom: 20, right: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? HexColor("#0F0F0F").withValues(alpha: 0.8)
              : AppTheme.cardBg(isDark),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? HexColor("#FFF500").withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 1.46,
              offset: const Offset(0, 2.8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gradient Border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent, width: 1),
              ),
              child: CustomPaint(
                painter: _GradientCirclePainter(
                  strokeWidth: 1,
                  gradient: LinearGradient(
                    colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                  ),
                ),
                child: const SizedBox(width: 70, height: 70),
              ),
            ),
            Icon(
              Icons.add,
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  /// Tile for text-only posts in the grid.
  Widget _buildTextPostTile(dynamic post) {
    String content = '';
    int views = 0;
    if (post is GetUserPostProfleResponseData) {
      content = post.content;
      views = post.views;
    }
    if (post is GetOtherUserProfilePostData) {
      content = post.content ?? '';
      views = post.views;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: HexColor("#1A1A1A"),
            border: Border.all(color: Colors.white10, width: 0.5),
          ),
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ),
        // View Count Overlay for Text Posts
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/svgs/views_eye.svg",
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(views),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPostsTab(List<dynamic> posts, String emptyMessage) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QikFlashScreen(
                  posts: posts.map((p) => _toFeedPost(p)).toList(),
                  initialPostIndex: index,
                ),
              ),
            );
          },
          child:
              ((post is GetUserPostProfleResponseData &&
                      post.media.isNotEmpty) ||
                  (post is GetOtherUserProfilePostData &&
                      post.media.isNotEmpty))
              ? _buildMediaGridItem(post)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  String? _getProfileImageUrl() {
    final feedState = ref.watch(feedProvider);
    String? pictureUrl;

    if (widget.isCurrentUser) {
      pictureUrl = feedState.userInfo?.data.profilePicture;
    } else {
      pictureUrl = feedState.otherUserInfo?.data.profilePicture;
    }

    return (pictureUrl != null && pictureUrl.isNotEmpty)
        ? pictureUrl
        : widget.user.profilePicture;
  }

  Widget _buildInitialsPlaceholder(String initials) {
    return Container(
      color: HexColor("#FB8830"),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Returns the username from userInfo (if loaded) or the FeedUser.
  String _getUsername() {
    final feedState = ref.watch(feedProvider);
    String? username;

    if (widget.isCurrentUser) {
      username = feedState.userInfo?.data.username;
    } else {
      username = feedState.otherUserInfo?.data.username;
    }

    // fallback if both are empty or null
    if (username == null || username.trim().isEmpty) {
      username = widget.user.username;
    }

    return username.trim().isEmpty ? 'User' : username;
  }

  /// Formats follower/following counts (e.g. 12500 → "12.5K").
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Builds one grid tile for a media post (image or video).
  Widget _buildMediaGridItem(dynamic post) {
    String url = '';
    int views = 0;

    if (post is GetUserPostProfleResponseData && post.media.isNotEmpty) {
      url = post.media.first;
      views = post.views;
    } else if (post is GetOtherUserProfilePostData && post.media.isNotEmpty) {
      url = post.media.first ?? '';
      views = post.views;
    }

    if (url.isEmpty) return const SizedBox.shrink();

    final isVideo = MediaUtils.isVideo(url);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Always try to load the thumbnail — works for both images and videos.
        Image.network(
          MediaUtils.getThumbnailUrl(url),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white12,
            child: Center(
              child: Icon(
                isVideo ? Icons.videocam : Icons.image_outlined,
                color: Colors.white24,
                size: 40,
              ),
            ),
          ),
        ),
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/svgs/views_eye.svg",
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                //Icon(Icons.play_arrow, color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text(
                  _formatCount(views),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Play-button overlay for videos
        if (isVideo)
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  // ---------- unchanged widgets ----------

  Widget _buildStatItem(String value, String label) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSquareIconButton(Widget icon) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: isDark ? HexColor("#1A1A1A") : AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(
          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
        ),
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildSocialIcon(SvgPicture icon) {
    return icon;
  }

  Widget _buildEditProfileButton() {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
        // Refresh profile info when returning from edit screen
        if (mounted && widget.isCurrentUser) {
          ref.read(feedProvider.notifier).loadUserInfo();
        }
      },
      child: Container(
        height: 45,
        width: 164,
        decoration: BoxDecoration(
          color: isDark ? HexColor("#1A1A1A") : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(1),
          border: Border.all(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          ),
        ),
        child: Center(
          child: Text(
            "Edit profile",
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    final feedState = ref.watch(feedProvider);
    bool isFollowing = feedState.following.any(
      (f) => f.following.id == widget.user.id,
    );

    return GestureDetector(
      onTap: () async {
        if (isFollowing) {
          // If following, it should initiate a message/chat
          await _messageUser(
            widget.user.id,
            _getUsername(),
            _getProfileImageUrl() ?? '',
          );
        } else {
          // Toggle follow state
          await ref
              .read(feedProvider.notifier)
              .toggleFollowUser(widget.user.id, !isFollowing);
        }
      },
      child: Container(
        height: 45,
        width: 164,
        decoration: BoxDecoration(
          color: HexColor("#EA4359"),
          borderRadius: BorderRadius.circular(1),
          //border: isFollowing ? Border.all(color: Colors.white) : null,
        ),
        child: Center(
          child: _isLoadingChat
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isFollowing ? "Message" : "Follow",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MESSAGE USER
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _messageUser(
    String userId,
    String username,
    String profilePicture,
  ) async {
    setState(() => _isLoadingChat = true);
    try {
      final chatId = await _getOrCreateDMChatId(userId);
      if (!mounted) return;
      setState(() => _isLoadingChat = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatId,
            userId: userId,
            username: username,
            lastSeenActive: '',
            profilePicture: profilePicture,
            about: '',
            isGroupChat: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingChat = false);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Could not open conversation: $e',
      //       style: GoogleFonts.poppins(color: Colors.white),
      //     ),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //   ),
      // );
    }
  }

  Future<String> _getOrCreateDMChatId(String targetUserId) async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final listResp = await http.get(
        Uri.parse(ApiStrings.getAllChat),
        headers: headers,
      );
      if (listResp.statusCode == 200) {
        final List chats = jsonDecode(listResp.body) as List;
        for (final chat in chats) {
          final map = chat as Map<String, dynamic>;
          if (map['isGroupChat'] == true) continue;
          final chatId = map['_id'] as String?;
          if (chatId == null || chatId.isEmpty) continue;

          final otherUser = map['otherUser'];
          if (otherUser is Map && otherUser['_id'] == targetUserId) {
            return chatId;
          }

          final users = map['users'];
          if (users is List && _listContainsUser(users, targetUserId)) {
            return chatId;
          }

          final members = map['members'];
          if (members is List && _listContainsUser(members, targetUserId)) {
            return chatId;
          }
        }
      }
    } catch (e) {
      // print('⚠️ Chat search error: $e — proceeding to create');
    }

    final r1 = await http.post(
      Uri.parse('${ApiStrings.baseUri}chat'),
      headers: headers,
      body: jsonEncode({
        'users': [targetUserId],
      }),
    );
    if (r1.statusCode == 200 || r1.statusCode == 201) {
      final id = _parseChatId(r1.body);
      if (id != null && id.isNotEmpty) return id;
    }

    final r2 = await http.post(
      Uri.parse('${ApiStrings.baseUri}chat'),
      headers: headers,
      body: jsonEncode({'userId': targetUserId}),
    );
    if (r2.statusCode == 200 || r2.statusCode == 201) {
      final id = _parseChatId(r2.body);
      if (id != null && id.isNotEmpty) return id;
    }

    String errMsg = 'Failed to open chat';
    try {
      errMsg = (jsonDecode(r1.body) as Map)['message'] as String? ?? errMsg;
    } catch (_) {}
    throw Exception(errMsg);
  }

  bool _listContainsUser(List list, String targetId) {
    return list.any((u) {
      if (u is Map) return u['_id'] == targetId;
      if (u is String) return u == targetId;
      return false;
    });
  }

  String? _parseChatId(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['_id'] as String? ??
          (data['data'] is Map
              ? (data['data'] as Map<String, dynamic>)['_id'] as String?
              : null) ??
          (data['chat'] is Map
              ? (data['chat'] as Map<String, dynamic>)['_id'] as String?
              : null);
    } catch (_) {
      return null;
    }
  }
}

class _GradientCirclePainter extends CustomPainter {
  final double strokeWidth;
  final Gradient gradient;

  _GradientCirclePainter({required this.strokeWidth, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Delegate to keep the TabBar pinned at the top when scrolling.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
