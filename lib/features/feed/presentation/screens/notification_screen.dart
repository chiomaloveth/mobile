import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../state/provider/feed_provider.dart';
import '../state/feed_state.dart';
import 'feed_profile_screen.dart';
import 'friends_feed_screen.dart';
import '../state/data/get_feed_response_data.dart';
import 'widget/notification_item.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadNotifications();
    });
  }

  void _markAllAsRead() {
    ref.read(feedProvider.notifier).readAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final allNotifications = feedState.notifications;
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    final filteredNotifications = _selectedTabIndex == 0
        ? allNotifications
        : allNotifications
              .where((n) => !(n.isRead ?? n.read ?? false))
              .toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        stops: const [0.01, 1.8],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [HexColor("#171516"), HexColor("#3A1D07")],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFFE8DDD0), AppTheme.scaffoldBg(isDark)],
                      ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? HexColor("#2A2A2A") : AppTheme.border(isDark),
                    width: 1.42,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(feedState, isDark),
                  _buildTabs(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child:
                  feedState.isNotificationsLoading && allNotifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(feedProvider.notifier).loadNotifications(),
                      child: filteredNotifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedTabIndex == 0
                                        ? Icons.notifications_none_outlined
                                        : Icons.done_all_outlined,
                                    color: isDark ? Colors.white24 : Colors.black26,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedTabIndex == 0
                                        ? "No notifications yet"
                                        : "All caught up! No unread notifications",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredNotifications.length +
                                  (feedState.notificationsHasReachedMax ||
                                          (_selectedTabIndex == 1 &&
                                              feedState
                                                      .notificationsUnreadCount ==
                                                  0)
                                      ? 0
                                      : 1),
                              itemBuilder: (context, index) {
                                if (index == filteredNotifications.length) {
                                  if (!feedState.notificationsHasReachedMax) {
                                    ref
                                        .read(feedProvider.notifier)
                                        .loadMoreNotifications();
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                }
                                return NotificationItem(
                                  notification: filteredNotifications[index],
                                  onTap: () async {
                                    final notification =
                                        filteredNotifications[index];
                                    final notifier = ref.read(
                                      feedProvider.notifier,
                                    );

                                    // 1. Mark as read immediately
                                    notifier.markNotificationAsRead(
                                      notification.id,
                                    );

                                    // 2. Handle Navigation based on onModel and relatedId
                                    if (notification.relatedId == null ||
                                        notification.relatedId!.isEmpty) {
                                      return;
                                    }

                                    if (notification.onModel == 'User') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProfileScreen(
                                                user: FeedUser(
                                                  id: notification.relatedId!,
                                                  username: '',
                                                  profilePicture: '',
                                                ),
                                                isCurrentUser:
                                                    notification.relatedId ==
                                                    feedState.userInfo?.data.id,
                                              ),
                                        ),
                                      );
                                    } else if (notification.onModel == 'Post') {
                                      // Show loading indicator or fetch post
                                      final post = await notifier.getPostById(
                                        notification.relatedId!,
                                      );
                                      if (post != null && context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => FriendsFeedScreen(
                                                  posts: [post],
                                                  initialPostIndex: 0,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FeedState feedState, bool isDark) {
    final unreadCount = feedState.notificationsUnreadCount;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$unreadCount unread",
                style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _markAllAsRead,
            child: Container(
              width: 49,
              height: 33,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? HexColor("#1F1F1F") : AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(4),
                border: isDark ? null : Border.all(color: AppTheme.border(isDark)),
              ),
              child: Icon(Icons.check, color: HexColor("#FF6B00"), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildTabItem("All", 0),
          const SizedBox(width: 12),
          _buildTabItem("Unread", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? HexColor("#FF6B00")
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (index == 1) ...[
              SvgPicture.asset(
                'assets/svgs/notification_filter.svg',
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
