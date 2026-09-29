import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/features/feed/presentation/state/data/feed_user.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/screens/create_post_screen.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/story_bubble.dart';
import 'package:collection/collection.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/feed_story_view_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FeedStories extends ConsumerWidget {
  const FeedStories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(feedProvider.select((s) => s.userInfo?.data));
    final followingStories = ref.watch(
      feedProvider.select((s) => s.followingStories),
    );
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    // Find the current user's story in the followingStories list
    final myStory = followingStories.firstWhereOrNull(
      (s) => s.user?.id == userData?.id,
    );

    // Filter out the current user's story from the other stories
    final otherStories = followingStories
        .where((s) => s.user?.id != userData?.id)
        .toList();

    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      color: isDark ? HexColor("#141414") : AppTheme.scaffoldBg(isDark),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 6, right: 6, top: 0, bottom: 0),
        scrollDirection: Axis.horizontal,
        itemCount: otherStories.length + (myStory != null ? 2 : 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Create" story bubble
            return StoryBubble(
              username: 'Create',
              imageUrl: (userData?.profilePicture ?? '').isNotEmpty
                  ? userData!.profilePicture
                  : (userData?.fullName ?? '').isNotEmpty
                  ? userData!.fullName![0]
                  : (userData?.username ?? '').isNotEmpty
                  ? userData!.username![0]
                  : '',
              isLive: false,
              isCreate: true,
              onTap: () {
                if (userData == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      user: FeedUser(
                        id: userData.id,
                        username: userData.username ?? '',
                        profilePicture: userData.profilePicture,
                      ),
                      isCurrentUser: true,
                    ),
                  ),
                );
              },
              onPlusTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CreatePostScreen(initialPostType: 'Story'),
                  ),
                );
              },
            );
          }

          if (myStory != null && index == 1) {
            // "My Story" bubble
            return StoryBubble(
              username: 'My Story',
              imageUrl: myStory.user?.profilePicture ?? '',
              isLive: false,
              isCreate: false,
              onTap: () {
                if (myStory.updates == null || myStory.updates!.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedStoryViewScreen(
                      updates: myStory.updates!,
                      isMyStatus: true,
                    ),
                  ),
                );

                // Track view
                ref
                    .read(feedProvider.notifier)
                    .viewStory(myStory.updates!.first.updateId ?? myStory.updates!.first.id ?? '');
              },
            );
          }

          // Following stories
          final story = otherStories[index - (myStory != null ? 2 : 1)];
          return StoryBubble(
            username: story.user?.username ?? '',
            imageUrl: story.user?.profilePicture ?? '',
            isLive: false,
            isCreate: false,
            onTap: () {
              if (story.updates == null || story.updates!.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeedStoryViewScreen(
                    updates: story.updates!,
                    isMyStatus: false,
                  ),
                ),
              );

              // Track view
              ref
                  .read(feedProvider.notifier)
                  .viewStory(story.updates!.first.updateId ?? story.updates!.first.id ?? '');
            },
          );
        },
      ),
    );
  }
}
