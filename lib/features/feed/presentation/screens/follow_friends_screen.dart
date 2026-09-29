import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_by_preference.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';

class FollowFriendsScreen extends ConsumerStatefulWidget {
  const FollowFriendsScreen({super.key});

  @override
  ConsumerState<FollowFriendsScreen> createState() =>
      _FollowFriendsScreenState();
}

class _FollowFriendsScreenState extends ConsumerState<FollowFriendsScreen> {
  final Set<String> _dismissedUserIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch matching users on screen initialization
    Future.microtask(() {
      ref.read(feedProvider.notifier).getUserByPreference();
    });
  }

  void _finishAndClose() {
    ref.read(feedProvider.notifier).refreshFeed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final matchingUsers = feedState.matchingUsers;
    final isLoading = feedState.isMatchingUsersLoading;

    // Filter out dismissed users
    final visibleUsers = matchingUsers
        .where((u) => !_dismissedUserIds.contains(u.id))
        .toList();

    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(feedProvider.notifier).refreshFeed();
        }
      },
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                // Top Drag Handle & Optional Skip
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Drag handle indicator (visual only)
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      // Added a Skip/Done button so users aren't trapped
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _finishAndClose,
                          child: Text(
                            "Close",
                            style: GoogleFonts.poppins(
                              color: HexColor('#ADADAD'),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEE1D52),
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 24.0),
                                    Text(
                                      "Follow your\nfriends to view\ntheir posts",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      visibleUsers.isEmpty && !isLoading
                                          ? "No matching users found based on your preferences."
                                          : "Follow people you might know\nor people who know you.",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 32.0),
                                  ],
                                ),
                              ),
                            ),
                            if (visibleUsers.isNotEmpty)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final user = visibleUsers[index];
                                    return _buildUserItem(user);
                                  }, childCount: visibleUsers.length),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 40.0),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(MatchingUser user) {
    final followingIds = ref
        .watch(feedProvider)
        .following
        .map((f) => f.following.id)
        .toSet();
    final isFollowing = followingIds.contains(user.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child:
                (user.profilePicture.isNotEmpty &&
                    user.profilePicture.startsWith('http'))
                ? ClipOval(
                    child: Image.network(
                      user.profilePicture,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          (user.username != null && user.username!.isNotEmpty)
                              ? user.username![0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      (user.username != null && user.username!.isNotEmpty)
                          ? user.username![0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12.0),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${user.matchCount} common interests",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Follow Button
          GestureDetector(
            onTap: () {
              ref
                  .read(feedProvider.notifier)
                  .toggleFollowUser(user.id, !isFollowing);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isFollowing ? Colors.grey.shade200 : HexColor("#EE1D52"),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                isFollowing ? "Following" : "Follow",
                style: GoogleFonts.poppins(
                  color: isFollowing ? Colors.black87 : Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Dismiss 'x'
          GestureDetector(
            onTap: () {
              setState(() {
                _dismissedUserIds.add(user.id);
              });
            },
            child: Icon(Icons.close, color: Colors.black, size: 20.0),
          ),
        ],
      ),
    );
  }
}
