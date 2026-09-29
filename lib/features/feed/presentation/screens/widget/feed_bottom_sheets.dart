import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import '../bookmarked_posts_screen.dart';
import 'feed_menu_sheet.dart';

import 'post_options_sheet.dart';

void showFeedMenu(BuildContext context, {required VoidCallback onRefresh}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FeedMenuSheet(
        onRefresh: () {
          Navigator.pop(context);
          onRefresh();
        },
        onFilter: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookmarkedPostsScreen(),
            ),
          );
        },

        onSettings: () {
          Navigator.pop(context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Settings feature coming soon'),
          //     backgroundColor: HexColor("#FF6B00"),
          //   ),
          // );
        },
      );
    },
  );
}

void showPostOptions(
  BuildContext context, {
  required GetFeedResponseData post,
  required String currentUserId,
  required Function(GetFeedResponseData) onDelete,
}) {
  final isMyPost = post.user.id == currentUserId;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return PostOptionsSheet(
        post: post,
        isMyPost: isMyPost,
        onDelete: () {
          Navigator.pop(context);
          showDeletePostDialog(context, post, onDelete);
        },
        onFollow: () {
          Navigator.pop(context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Follow feature coming soon'),
          //     backgroundColor: HexColor("#FF6B00"),
          //   ),
          // );
        },
        onReport: () {
          Navigator.pop(context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Post reported'),
          //     backgroundColor: Colors.red,
          //   ),
          // );
        },
      );
    },
  );
}

void showDeletePostDialog(
  BuildContext context,
  GetFeedResponseData post,
  Function(GetFeedResponseData) onConfirmDelete,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: HexColor("#2A2A2A"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Post',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      ),
      content: Text(
        'Are you sure you want to delete this post?',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmDelete(post);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text('Post deleted'),
            //     backgroundColor: HexColor("#1A7F4B"),
            //   ),
            // );
          },
          child: Text(
            'Delete',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
