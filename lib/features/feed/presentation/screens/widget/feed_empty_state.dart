import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FeedEmptyState extends StatelessWidget {
  final bool isSearching;

  const FeedEmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rss_feed,
            size: 64,
            color: AppTheme.textSecondary(isDark).withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No posts found' : 'No posts yet',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(isDark),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Be the first to share something!',
            style: GoogleFonts.poppins(
              color: AppTheme.textHint(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
