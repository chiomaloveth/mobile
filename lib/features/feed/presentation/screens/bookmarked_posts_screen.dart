import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/data/models/feed_extensions.dart';
import 'widget/feed_media_grid.dart';
//import 'widget/post_engagement_bar.dart';
import 'qik_flash_screen.dart';
import 'feed_profile_screen.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';

class BookmarkedPostsScreen extends ConsumerStatefulWidget {
  const BookmarkedPostsScreen({super.key});

  @override
  ConsumerState<BookmarkedPostsScreen> createState() =>
      _BookmarkedPostsScreenState();
}

class _BookmarkedPostsScreenState extends ConsumerState<BookmarkedPostsScreen> {
  final SaveValues _saveValues = SaveValues();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    Future.microtask(
      () => ref.read(feedProvider.notifier).loadBookmarkedPosts(),
    );
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _saveValues.getString(AppPreferenceHelper.ID);
    setState(() {
      currentUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: HexColor("#3A1D07"),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bookmarked Posts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/app_bar_gredient.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: HexColor("#C0B3B3")),
            onPressed: () {
              // Standard search functionality if needed, for now just ui match
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: feedState.isBookmarkedLoading
          ? Center(child: CircularProgressIndicator(color: HexColor("#FF6B00")))
          : (feedState.bookmarkedPosts == null ||
                feedState.bookmarkedPosts!.data.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked posts yet',
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(feedProvider.notifier).loadBookmarkedPosts(),
              color: Colors.white,
              backgroundColor: HexColor("#FF6B00"),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: feedState.bookmarkedPosts?.data.length ?? 0,
                itemBuilder: (context, index) {
                  final bookmarks = feedState.bookmarkedPosts!.data;
                  final post = _mapBookmarkToFeed(bookmarks[index]);
                  return _buildPostCard(
                    post,
                    index,
                    bookmarks.map((b) => _mapBookmarkToFeed(b)).toList(),
                  );
                },
              ),
            ),
    );
  }

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

  Widget _buildPostCard(
    GetFeedResponseData post,
    int postIndex,
    List<GetFeedResponseData> allPosts,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          user: post.user,
                          isCurrentUser: post.user.id == currentUserId,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: HexColor("#FB8830"),
                    backgroundImage: post.user.profilePicture.isNotEmpty
                        ? NetworkImage(
                            MediaUtils.getThumbnailUrl(
                              post.user.profilePicture,
                            ),
                          )
                        : null,
                    child: post.user.profilePicture.isEmpty
                        ? Text(
                            post.user.username.isNotEmpty
                                ? post.user.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                user: post.user,
                                isCurrentUser: post.user.id == currentUserId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          post.user.username,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            post.getTimeAgo(),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.public,
                            size: 14,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (currentUserId != null) {
                      ref
                          .read(feedProvider.notifier)
                          .toggleBookmark(post.id, currentUserId!);
                    }
                  },
                  child: Icon(
                    Icons.bookmark,
                    size: 24,
                    color: post.isBookmarkedBy(currentUserId ?? '')
                        ? HexColor("#FF00A8")
                        : Colors.white70,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Follow',
                  style: GoogleFonts.poppins(
                    color: HexColor('#0088FF'),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (post.content.isNotEmpty)
            GestureDetector(
              onTap: () {
                if (post.media.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QikFlashScreen(
                        posts: allPosts,
                        initialPostIndex: postIndex,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QikFlashScreen(
                        posts: allPosts,
                        initialPostIndex: postIndex,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  post.content.replaceAll('"', ''),
                  style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
                ),
              ),
            ),

          // Media
          if (post.media.isNotEmpty)
            FeedMediaGrid(
              media: post.media,
              onMediaTap: (index) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QikFlashScreen(
                      posts: allPosts,
                      initialPostIndex: postIndex,
                      initialMediaIndex: index,
                    ),
                  ),
                );
              },
            ),

          // Action buttons
          //PostEngagementBar(post: post, currentUserId: currentUserId ?? ''),
          const Divider(color: Colors.white12, height: 1),
        ],
      ),
    );
  }
}
