import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:qik_talk/features/feed/data/models/feed_extensions.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_detail/comment_bottom_sheet.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/share_bottom_sheet.dart';
import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_options_bottom_sheet.dart';
import 'animated_interaction_button.dart';
import 'music_disc_animation.dart';

class VerticalEngagementBar extends ConsumerWidget {
  final GetFeedResponseData post;
  final String? currentUserId;
  final VoidCallback? onCommentTap;
  final bool isQikFlash;
  final bool isActive;

  const VerticalEngagementBar({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onCommentTap,
    this.isQikFlash = false,
    this.isActive = true,
  });

  String _formatCount(int count) {
    if (count == 0) return '0';
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLiked =
        currentUserId != null && post.isLikedBy(currentUserId!);
    final bool isBookmarked =
        currentUserId != null && post.isBookmarkedBy(currentUserId!);

    final feedState = ref.watch(feedProvider);
    final privacy = feedState.fetchedPrivacySettings?.data.privacy;
    bool areCommentsAllowed = true;
    if (privacy != null && post.user.id == currentUserId) {
      final commentPerm = privacy.commentPermissions.toLowerCase();
      if (commentPerm == 'nobody' || commentPerm == 'no_one') {
        areCommentsAllowed = false;
      }
    }


    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // isQikFlash = always over dark video background → always white
    // Following tab (non-QikFlash) = theme-aware
    final Color iconColor = (isQikFlash || isDark)
        ? Colors.white
        : const Color(0xFF1A1008);

    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;
    final double itemSpacing = isQikFlash ? (isSmallScreen ? 8 : 12) : 7;
    final double avatarSpacing = isSmallScreen ? 12 : 18;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile avatar with follow/add button
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: GestureDetector(
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
                  radius: isSmallScreen ? 20 : 25,
                  backgroundColor: Colors.white10,
                  backgroundImage:
                      (post.user.profilePicture.isNotEmpty &&
                          post.user.profilePicture.startsWith('http'))
                      ? NetworkImage(
                          MediaUtils.getThumbnailUrl(post.user.profilePicture),
                        )
                      : null,
                  child:
                      (post.user.profilePicture.isEmpty ||
                          !post.user.profilePicture.startsWith('http'))
                      ? Text(
                          post.user.username.trim().isNotEmpty
                              ? post.user.username.trim()[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (post.user.id != currentUserId)
              Positioned(
                bottom: -6,
                child: GestureDetector(
                  onTap: () async {
                    final error = await ref
                        .read(feedProvider.notifier)
                        .toggleFollow(post.id, post.user.id);
                    if (error != null && context.mounted) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text(error),
                      //     backgroundColor: Colors.red,
                      //   ),
                      // );
                    }
                  },
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: post.isFollowing
                          ? Colors.grey
                          : HexColor("#FF00A8"),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      post.isFollowing ? Icons.check : Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: avatarSpacing),

        // Like Action
        AnimatedInteractionButton(
          isActive: isLiked,
          label: _formatCount(post.likes.length),
          mode: InteractionButtonMode.raw,
          showBackground: false,
          iconSize: isSmallScreen ? 26 : 30,
          svgAsset: 'assets/svgs/likes.svg',
          activeColor: Colors.red,
          inactiveColor: iconColor,
          onTap: () {
            if (currentUserId != null) {
              ref
                  .read(feedProvider.notifier)
                  .toggleLike(post.id, currentUserId!);
            }
          },
        ),
        SizedBox(height: itemSpacing),

        if (isQikFlash) ...[
          QikFlashStarButton(iconSize: isSmallScreen ? 26 : 30),
          SizedBox(height: itemSpacing),
        ],

        // Comment Action
        if (post.allowComment && areCommentsAllowed) ...[
          AnimatedInteractionButton(
            isActive: true,
            label: _formatCount(post.commentCount),
            mode: InteractionButtonMode.raw,
            showBackground: false,
            iconSize: isSmallScreen ? 26 : 30,
            svgAsset: 'assets/svgs/comment.svg',
            activeColor: iconColor,
            inactiveColor: iconColor,
            onTap:
                onCommentTap ??
                () {
                  showCommentBottomSheet(context, post: post);
                },
          ),
          SizedBox(height: itemSpacing),
        ],

        // Bookmark Action
        AnimatedInteractionButton(
          isActive: isBookmarked,
          label: _formatCount(post.bookmarks.length),
          mode: InteractionButtonMode.raw,
          showBackground: false,
          iconSize: isSmallScreen ? 26 : 30,
          svgAsset: 'assets/svgs/bookmark.svg',
          activeColor: HexColor("#FF00A8"),
          inactiveColor: iconColor,
          onTap: () {
            if (currentUserId != null) {
              ref
                  .read(feedProvider.notifier)
                  .toggleBookmark(post.id, currentUserId!);
            }
          },
        ),
        SizedBox(height: itemSpacing),

        // Share Action
        AnimatedInteractionButton(
          isActive: true,
          label: _formatCount(post.shares.length),
          mode: InteractionButtonMode.raw,
          showBackground: false,
          iconSize: isSmallScreen ? 26 : 30,
          svgAsset: 'assets/svgs/feed_screen_share.svg',
          activeColor: iconColor,
          inactiveColor: iconColor,
          onTap: () {
            final allMedia = [
              ...post.media,
              ...(post.overlayVideos ?? []),
            ].where((url) => url.isNotEmpty).toList().cast<String>();

            showShareBottomSheet(
              context,
              postId: post.id,
              mediaUrls: allMedia,
              overlayText: post.overlayText,
            );
          },
        ),
        SizedBox(height: itemSpacing),

        // More Options (3 dots)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showPostOptionsBottomSheet(
              context,
              postId: post.id,
              userId: post.user.id,
              username: post.user.username,
            );
          },
          child: Icon(
            Icons.more_horiz,
            color: Colors.white,
            size: isSmallScreen ? 26 : 30,
          ),
        ),
        SizedBox(height: itemSpacing),

        // Audio track disc
        if (post.music != null)
          MusicDiscAnimation(
            coverImage: post.music?.coverImage,
            isPlaying: isActive,
            size: isSmallScreen ? 30 : 35,
          ),
      ],
    );
  }
}

class QikFlashStarButton extends StatefulWidget {
  final double iconSize;

  const QikFlashStarButton({super.key, this.iconSize = 30});

  @override
  State<QikFlashStarButton> createState() => _QikFlashStarButtonState();
}

class _QikFlashStarButtonState extends State<QikFlashStarButton> {
  bool _isActive = false;
  double _scale = 1.0;

  void _onTap() {
    setState(() {
      _isActive = !_isActive;
      _scale = 1.4;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Column(
        children: [
          AnimatedScale(
            scale: _scale,
            duration: Duration(milliseconds: _scale == 1.4 ? 100 : 250),
            curve: _scale == 1.4 ? Curves.easeOutBack : Curves.easeOutCubic,
            child: SvgPicture.asset(
              _isActive
                  ? 'assets/svgs/emojione_star_color.svg'
                  : 'assets/svgs/emojione_star.svg',
              width: widget.iconSize,
              height: widget.iconSize,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
