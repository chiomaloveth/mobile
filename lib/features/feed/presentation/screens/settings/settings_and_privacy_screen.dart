import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'comments_and_interactions_screen.dart';
import 'who_can_see_content_screen.dart';
import 'blocked_accounts_screen.dart';
//import 'permission_detail_screen.dart';
//import 'activity_grid_screen.dart';
import 'delete_account_screen.dart';
import 'notification/notification_settings_screen.dart';
//import '../../state/provider/app_permissions_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import '../../state/provider/feed_provider.dart';
import '../../../data/models/update_privacy_settings_dto.dart';
//import '../../../../../utilities/components/switchs/custom_switch_one.dart';

class SettingsAndPrivacyScreen extends ConsumerStatefulWidget {
  const SettingsAndPrivacyScreen({super.key});

  @override
  ConsumerState<SettingsAndPrivacyScreen> createState() =>
      _SettingsAndPrivacyScreenState();
}

class _SettingsAndPrivacyScreenState
    extends ConsumerState<SettingsAndPrivacyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(feedProvider.notifier).getPrivacySettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final feedState = ref.watch(feedProvider);
    final isPrivateAccount =
        feedState.fetchedPrivacySettings?.data.isPrivateAccount ?? false;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings And Privacy",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Private Account Card
            _buildPrivateAccountSection(isDark, isPrivateAccount),

            const SizedBox(height: 24),
            _buildSectionHeader("PRIVACY", isDark),
            _buildSettingsItem(
              icon: "assets/svgs/views_eye.svg",
              title: "Who can see your content",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhoCanSeeContentScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: "assets/svgs/comment.svg",
              title: "Comments and interactions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommentsAndInteractionsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: "assets/svgs/shield_lock.svg",
              title: "Blocked accounts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockedAccountsScreen(),
                  ),
                );
              },
            ),

            /*
            const SizedBox(height: 24),
            _buildSectionHeader("PERMISSIONS", isDark),
            _buildPermissionItem(
              icon: "assets/svgs/create_camera.svg",
              title: "Camera",
              status: ref.watch(appPermissionsProvider).camera,
              onToggle: () => ref
                  .read(appPermissionsProvider.notifier)
                  .togglePermission(Permission.camera),
              isDark: isDark,
            ),
            _buildPermissionItem(
              icon: "assets/svgs/mic.svg",
              title: "Microphone",
              status: ref.watch(appPermissionsProvider).microphone,
              onToggle: () => ref
                  .read(appPermissionsProvider.notifier)
                  .togglePermission(Permission.microphone),
              isDark: isDark,
            ),
            _buildPermissionItem(
              icon: "assets/svgs/create_image.svg",
              title: "Photos and videos",
              status: ref.watch(appPermissionsProvider).photos,
              onToggle: () => ref
                  .read(appPermissionsProvider.notifier)
                  .togglePermission(Permission.photos),
              isDark: isDark,
            ),
            _buildPermissionItem(
              icon: "assets/svgs/location.svg",
              title: "Location",
              status: ref.watch(appPermissionsProvider).location,
              onToggle: () => ref
                  .read(appPermissionsProvider.notifier)
                  .togglePermission(Permission.location),
              isDark: isDark,
            ),
            */

            /*
            const SizedBox(height: 24),
            _buildSectionHeader("CONTENT & ACTIVITY", isDark),
            _buildSettingsItem(
              icon: "assets/svgs/likes.svg",
              title: "Liked videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityGridScreen(
                      title: "Liked Videos",
                      description:
                          "Videos you've liked will appear here. This list is private and only visible to you.",
                      items: [
                        GridItem(
                          imageUrl: "https://picsum.photos/id/237/200/300",
                          views: "253",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/238/200/300",
                          views: "100",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/239/200/300",
                          views: "93",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/240/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/241/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/242/200/300",
                          views: "98",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: "assets/svgs/saved.svg",
              title: "Saved videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityGridScreen(
                      title: "Saved Videos",
                      description:
                          "Videos you've saved will appear here. You can access your saved videos anytime from this page.",
                      items: [
                        GridItem(
                          imageUrl: "https://picsum.photos/id/243/200/300",
                          views: "253",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/244/200/300",
                          views: "15",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/247/200/300",
                          views: "93",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/248/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/249/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/250/200/300",
                          views: "98",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: "assets/svgs/share.svg",
              title: "Shared videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityGridScreen(
                      title: "Shared Videos",
                      description:
                          "See all the content you've shared with others. This includes videos shared via direct message or external apps.",
                      items: [
                        GridItem(
                          imageUrl: "https://picsum.photos/id/251/200/300",
                          views: "253",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/252/200/300",
                          views: "100",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/253/200/300",
                          views: "93",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/254/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/255/200/300",
                          views: "24",
                        ),
                        GridItem(
                          imageUrl: "https://picsum.photos/id/256/200/300",
                          views: "98",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            */
            const SizedBox(height: 24),
            _buildSectionHeader("NOTIFICATIONS", isDark),
            _buildSettingsItem(
              icon: "assets/svgs/notification_filter.svg",
              title: "Push notifications",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: "assets/svgs/notification_filter.svg",
              title: "Delete Account",
              titleColor: HexColor("#FF0000"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),
            // Footer
            Center(
              child: Text(
                "QikTalk v2.4.1",
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPrivateAccountSection(bool isDark, bool isPrivateAccount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              "assets/svgs/shield_lock.svg",
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Private account",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Only followers can see your posts",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPrivateAccount,
            onChanged: (value) {
              ref
                  .read(feedProvider.notifier)
                  .updatePrivacySettings(
                    UpdatePrivacySettingsDto(isPrivateAccount: value),
                  );
            },
            activeThumbColor: Colors.white,
            activeTrackColor: HexColor("#EA4359"),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  // Widget _buildPermissionItem({
  //   required String icon,
  //   required String title,
  //   required PermissionStatus status,
  //   required VoidCallback onToggle,
  //   required bool isDark,
  // }) {
  //   final bool isGranted = status.isGranted || status.isLimited;
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: AppTheme.cardBg(isDark),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //       leading: Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: SvgPicture.asset(
  //           icon,
  //           width: 20,
  //           height: 20,
  //           colorFilter: ColorFilter.mode(
  //             isDark ? Colors.white : AppTheme.textPrimary(isDark),
  //             BlendMode.srcIn,
  //           ),
  //         ),
  //       ),
  //       title: Text(
  //         title,
  //         style: GoogleFonts.poppins(
  //           color: AppTheme.textPrimary(isDark),
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       subtitle: Text(
  //         isGranted
  //             ? "Granted"
  //             : (status.isPermanentlyDenied ? "Permanently Denied" : "Denied"),
  //         style: GoogleFonts.poppins(
  //           color: isGranted ? Colors.green : Colors.redAccent,
  //           fontSize: 12,
  //         ),
  //       ),
  //       trailing: CustomSwitchOne(
  //         value: isGranted,
  //         onChange: (_) => onToggle(),
  //         isDark: isDark,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSettingsItem({
    required String icon,
    required String title,
    Color? titleColor,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final bool isDarkLocal =
            Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(isDarkLocal),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkLocal
                    ? Colors.white10
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDarkLocal
                      ? Colors.white
                      : AppTheme.textPrimary(isDarkLocal),
                  BlendMode.srcIn,
                ),
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: titleColor ?? AppTheme.textPrimary(isDarkLocal),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDarkLocal),
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary(isDarkLocal),
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
