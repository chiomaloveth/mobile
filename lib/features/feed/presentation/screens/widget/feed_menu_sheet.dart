import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'feed_menu_option.dart';

class FeedMenuSheet extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onFilter;
  final VoidCallback onSettings;

  const FeedMenuSheet({
    super.key,
    required this.onRefresh,
    required this.onFilter,
    required this.onSettings,
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
          FeedMenuOption(
            icon: Icons.refresh,
            title: 'Refresh Feed',
            onTap: onRefresh,
          ),
          Divider(color: Colors.white12, height: 1),
          FeedMenuOption(
            icon: Icons.bookmark,
            title: 'Bookmarked Posts',
            onTap:
                onFilter, // Keep the existing onFilter callback name but it will be reused for bookmarks
          ),
          Divider(color: Colors.white12, height: 1),

          FeedMenuOption(
            icon: Icons.settings,
            title: 'Feed Settings',
            onTap: onSettings,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
