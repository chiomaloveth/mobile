import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'feed_menu_option.dart';

class PostOptionsSheet extends StatelessWidget {
  final GetFeedResponseData post;
  final bool isMyPost;
  final VoidCallback onDelete;
  final VoidCallback onFollow;
  final VoidCallback onReport;

  const PostOptionsSheet({
    super.key,
    required this.post,
    required this.isMyPost,
    required this.onDelete,
    required this.onFollow,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HexColor("#2A2A2A"),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (isMyPost) ...[
            FeedMenuOption(
              icon: Icons.delete,
              title: 'Delete Post',
              color: Colors.red,
              onTap: onDelete,
            ),
          ] else ...[
            FeedMenuOption(
              icon: Icons.person_add,
              title: 'Follow ${post.user.username}',
              onTap: onFollow,
            ),
            Divider(color: Colors.white12, height: 1),
            FeedMenuOption(
              icon: Icons.report,
              title: 'Report Post',
              color: Colors.red,
              onTap: onReport,
            ),
          ],
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
