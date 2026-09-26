import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qik_talk/features/settings/screen/notification/notification_settings_screen.dart';
import 'package:qik_talk/features/feed/presentation/screens/settings/security/security_screen.dart';
import 'package:qik_talk/features/settings/account/screens/account_screen.dart';
import 'package:qik_talk/features/settings/account/screens/add_profile_info/screens/edit_profile_screen.dart';
import 'package:qik_talk/features/settings/general/components/settings_option_card.dart';
import 'package:qik_talk/features/settings/screen/backup_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/help_screen.dart';
import 'package:qik_talk/features/settings/screen/premium_screen.dart';
import 'package:qik_talk/features/settings/theme/screens/theme_screen.dart';
import 'package:qik_talk/features/wallet/screens/settings_wallet/settings_wallet_screen.dart';
import 'package:qik_talk/utilities/components/dialogs/logout_confirm_dialog.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_icons.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../ai/screens/ai_send_message_screen.dart';
import '../account/screens/data_and_storage/screens/data_and_storage_screen.dart';
import '../../authentication/provider/user_provider.dart';
import '../../feed/presentation/state/provider/feed_provider.dart';
import '../theme/provider/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _handleLogout() async {
    await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const LogoutConfirmDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // 1. Load from local prefs first (instant, no flicker)
    await ref.read(userProfileProvider.notifier).loadUser();

    // 2. Then fetch fresh data from backend in background
    await ref.read(feedProvider.notifier).loadUserInfo(silent: true);

    if (mounted) {
      final info = ref.read(feedProvider).userInfo?.data;
      if (info != null) {
        // Always keep the locally-stored picture URL — never let a
        // potentially-stale backend response overwrite the one we just
        // uploaded. The local URL is always the source of truth.
        final preservedPicture = ref.read(userProfileProvider).profilePicture;
        await ref.read(userProfileProvider.notifier).updateFromUserInfo(
              username: info.username ?? '',
              about: info.about,
              fullName: info.fullName ?? '',
              profilePicture: preservedPicture.isNotEmpty
                  ? preservedPicture
                  : (info.profilePicture ?? ''),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final feedState = ref.watch(feedProvider);
    final about = feedState.userInfo?.data.about ?? user.about;
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : const Color(0xFFFAF5F0),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : const Color(0xFFFAF5F0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark
                ? HexColor("#3A1D07")
                : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark
                    ? const DecorationImage(
                        image: AssetImage("images/app_bar_gredient.png"),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 40.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10.0),
                        child: Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                        child: _ProfileAvatar(
                          imageUrl: user.profilePictureUrl,
                        ),
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 0.0,
                              ),
                              child: Text(
                                      user.username.isNotEmpty
                                          ? user.username
                                          : "User",
                                      style: GoogleFonts.poppins(
                                        color: isDark ? Colors.white : null,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                            ),
                            Text(
                                    about.isNotEmpty
                                        ? about
                                        : "Hey there! I am using QikTalk.",
                                    style: GoogleFonts.poppins(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.8),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Account",
                value: "Privacy, Security, Change Number",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AccountScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.profileIconOne,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Theme",
                value: "Light, Dark, System Default",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ThemeScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.themeIcon,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Notifications",
                value: "Message, Groups, Calls",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NotificationSettingsScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.notificationIcons,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark
                    ? Colors.black
                    : Colors.grey.withValues(alpha: 0.2),
              ),

              SettingsOptionCard(
                title: "Security and Permission",
                value: "Two-step verification, Change Password",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const SecurityScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.shieldIcon,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Data and Storage",
                value: "Network Usage, Auto Download",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return DataAndStorageScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.databaseIcon,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),
              SettingsOptionCard(
                title: "Wallet",
                value: "Balance, Transaction, Payments",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SettingsWalletScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.walletIcons,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Backups",
                value: "Cloud Sync, Restore Data",
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BackupScreen()),
                  );
                },
                icon: AppIcons.backupIcon,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "AI Assistant",
                value: "Chat with AI",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AISendMessageScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.aiIcons,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Premium",
                value: "Unlock Exclusive Features",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PremiumScreen();
                      },
                    ),
                  );
                },
                icon: AppIcons.premiumIcon,
                isDark: isDark,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              SettingsOptionCard(
                title: "Help",
                value: "Contact Support, Report a Bug",
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
                icon: AppIcons.helpIcon,
                isDark: isDark,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20.0),
                height: 2,
                color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
              ),

              // ── Logout ──────────────────────────────────────────────────
              GestureDetector(
                onTap: _handleLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE53935),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE53935),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile avatar widget ──────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFF2C2C2E),
        child: Icon(Icons.person, color: Colors.white54, size: 34),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,      // ← no fade flash on cache hit
        fadeOutDuration: Duration.zero,
        // imageBuilder fires instantly when the image is already cached
        imageBuilder: (context, imageProvider) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Only shown on true first-ever load (nothing in cache yet)
        placeholder: (context, url) => Container(
          width: 60,
          height: 60,
          color: const Color(0xFF2C2C2E),
          child: const Icon(Icons.person, color: Colors.white54, size: 34),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 60,
          color: const Color(0xFF2C2C2E),
          child: const Icon(Icons.person, color: Colors.white54, size: 34),
        ),
      ),
    );
  }
}
