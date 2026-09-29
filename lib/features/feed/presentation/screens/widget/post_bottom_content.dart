import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';

class PostBottomContent extends ConsumerWidget {
  final GetFeedResponseData post;
  final bool hasMedia;

  const PostBottomContent({
    super.key,
    required this.post,
    this.hasMedia = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    final currentUserId = ref.watch(
      feedProvider.select((s) => s.userInfo?.data.id),
    );
    final bool isCurrentUser = post.user.id == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  user: post.user,
                  isCurrentUser: isCurrentUser,
                ),
              ),
            );
          },
          child: Text(
            post.user.username.trim().isEmpty ? 'User' : post.user.username,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        if (hasMedia && post.content.isNotEmpty)
          Text(
            post.content.replaceAll('"', ''),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        if (post.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              children: post.tags
                  .map(
                    (tag) => Text(
                      "#${tag.trim()}",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0, 0.5),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 4),
        // Show Translation text
        Row(
          children: [
            Icon(
              Icons.translate,
              color: Colors.white,
              size: isSmallScreen ? 12 : 14,
            ),
            const SizedBox(width: 4),
            Text(
              "Show translation",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Music Track
        if (post.music != null)
          Row(
            children: [
              SvgPicture.asset(
                'assets/svgs/music.svg',
                width: isSmallScreen ? 14 : 16,
                height: isSmallScreen ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${post.music!.title} - ${post.music!.artist}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
