import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_list_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/utilities/media_utils.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String userId;
  final int initialTab; // 0 = Followers, 1 = Following

  const FollowListScreen({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    Future.microtask(() {
      ref.read(feedProvider.notifier).loadFollowers(widget.userId);
      ref.read(feedProvider.notifier).loadFollowing(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final feedState = ref.watch(feedProvider);
    final followers = feedState.followers;
    final following = feedState.following;
    final isLoading = feedState.isFollowListLoading;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary(isDark), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Connections",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HexColor("#FF00A8"),
          indicatorWeight: 3,
          dividerColor: Colors.white12,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelColor: AppTheme.textPrimary(isDark),
          unselectedLabelColor: AppTheme.textSecondary(isDark),
          tabs: [
            Tab(text: "Followers (${followers.length})"),
            Tab(text: "Following (${following.length})"),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: HexColor("#FF00A8")))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFollowersList(followers),
                _buildFollowingList(following),
              ],
            ),
    );
  }

  Widget _buildFollowersList(List<FollowerItem> followers) {
    if (followers.isEmpty) {
      return _buildEmptyState("No followers yet");
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final item = followers[index];
        return _buildUserTile(
          id: item.follower.id,
          username: item.follower.username,
          profilePicture: item.follower.profilePicture,
        );
      },
    );
  }

  Widget _buildFollowingList(List<FollowingItem> following) {
    if (following.isEmpty) {
      return _buildEmptyState("Not following anyone yet");
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: following.length,
      itemBuilder: (context, index) {
        final item = following[index];
        return _buildUserTile(
          id: item.following.id,
          username: item.following.username,
          profilePicture: item.following.profilePicture,
        );
      },
    );
  }

  Widget _buildUserTile({
    required String id,
    required String username,
    required String profilePicture,
  }) {
    return Builder(
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: ClipOval(
              child: profilePicture.isNotEmpty
                  ? Image.network(
                      MediaUtils.getThumbnailUrl(profilePicture),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsPlaceholder(username);
                      },
                    )
                  : _buildInitialsPlaceholder(username),
            ),
          ),
          title: Text(
            username,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            "@${username.toLowerCase().replaceAll(' ', '')}",
            style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 12),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: FeedUser(
                    id: id,
                    username: username,
                    profilePicture: profilePicture,
                  ),
                  isCurrentUser: false,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInitialsPlaceholder(String username) {
    final initials = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Container(
      color: HexColor("#FB8830"),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Builder(
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
