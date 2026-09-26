import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/account/components/privacy_option_card.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/disappearing_message_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/last_seen_and_online_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/privacy_about_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/privacy_groups_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/privacy_profile_photo_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/live_location_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/status_privacy_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/provider/privacy_settings_provider.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/blocked_contacts_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/fingerprint_lock_screen.dart';
import 'package:qik_talk/utilities/components/switchs/custom_switch_one.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  // ── Cached display values — show last known while re-fetching ─────────────
  String? _cachedLastSeen;
  String? _cachedProfilePhoto;
  String? _cachedAbout;
  String? _cachedStatusVisibility;
  String? _cachedGroups;
  String? _cachedTimer;
  bool?   _cachedReadReceipts;

  void _handleReadRecipientSwitchToggle(bool value) {
    ref
        .read(privacySettingsProvider.notifier)
        .updatePrivacy(readReceipts: value);
  }

  /// Returns the best available value:
  /// - If fresh data is available, use it.
  /// - If still loading, use the last cached value.
  /// - If nothing is cached yet (true first load), use [fallback].
  String _resolve(String? cached, String fresh, String fallback) {
    if (fresh.isNotEmpty) return fresh;
    return cached ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final privacyState = ref.watch(privacySettingsProvider);
    final feedState = ref.watch(feedProvider);
    final blockedCount = feedState.userInfo?.data.blockedUsers.length ?? 0;

    // Persist fresh values into the cache the moment loading completes
    if (!privacyState.isLoading) {
      _cachedLastSeen         = privacyState.lastSeen;
      _cachedProfilePhoto     = privacyState.profilePhoto;
      _cachedAbout            = privacyState.about;
      _cachedStatusVisibility = privacyState.statusVisibility;
      _cachedGroups           = privacyState.groups;
      _cachedTimer            = privacyState.defaultMessageTimer;
      _cachedReadReceipts     = privacyState.readReceipts;
    }

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    // "..." only on the very first load — nothing cached yet
    final bool showPlaceholder =
        privacyState.isLoading && _cachedLastSeen == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : const Color(0xFFFAF5F0),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : const Color(0xFFFAF5F0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppColors.gradientColorsTwo),
                        Color(AppColors.gradientColorsOne),
                      ],
                    )
                  : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Privacy',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? Colors.white
                      : AppTheme.textPrimary(isDark),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── WHO CAN SEE MY PERSONAL INFO ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "WHO CAN SEE MY PERSONAL INFO",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                PrivacyOptionCard(
                  title: "Last Seen & Online",
                  value: showPlaceholder
                      ? "..."
                      : _capitalize(
                          _resolve(
                            _cachedLastSeen,
                            privacyState.lastSeen,
                            "Everyone",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LastSeenAndOnlineScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "Profile Photo",
                  value: showPlaceholder
                      ? "..."
                      : _capitalize(
                          _resolve(
                            _cachedProfilePhoto,
                            privacyState.profilePhoto,
                            "Everyone",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyProfilePhotoScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "About",
                  value: showPlaceholder
                      ? "..."
                      : _capitalize(
                          _resolve(
                            _cachedAbout,
                            privacyState.about,
                            "Everyone",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyAboutScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "Status",
                  value: showPlaceholder
                      ? "..."
                      : _capitalize(
                          _resolve(
                            _cachedStatusVisibility,
                            privacyState.statusVisibility,
                            "Everyone",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StatusPrivacyScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                // ── DISAPPEARING MESSAGES ──────────────────────────────
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "DISAPPEARING MESSAGES",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                PrivacyOptionCard(
                  title: "Default Message Timer",
                  value: showPlaceholder
                      ? "..."
                      : _formatTimer(
                          _resolve(
                            _cachedTimer,
                            privacyState.defaultMessageTimer,
                            "off",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DisappearingMessageScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                // ── OTHERS ─────────────────────────────────────────────
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "OTHERS",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ── Read Receipts toggle ───────────────────────────────
                Container(
                  height: 65,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        width: 0.5,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Read Recipients",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                "If turned off, you won't send or receive read receipts",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Use cached value to avoid toggling back to false
                        // during a re-fetch, then snapping to true once loaded
                        CustomSwitchOne(
                          value: _cachedReadReceipts ?? privacyState.readReceipts,
                          onChange: _handleReadRecipientSwitchToggle,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                PrivacyOptionCard(
                  title: "Groups",
                  value: showPlaceholder
                      ? "..."
                      : _capitalize(
                          _resolve(
                            _cachedGroups,
                            privacyState.groups,
                            "Everyone",
                          ),
                        ),
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyGroupsScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "Live Location",
                  value: "None",
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LiveLocationScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "Blocked Contact",
                  value: "$blockedCount",
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BlockedContactsScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                PrivacyOptionCard(
                  title: "Fingerprint Lock",
                  value: "",
                  onClick: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FingerprintLockScreen(),
                    ),
                  ),
                  isDark: isDark,
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatTimer(String value) {
    switch (value) {
      case '24_hours':
        return '24 Hours';
      case '7_days':
        return '7 Days';
      case '90_days':
        return '90 Days';
      default:
        return 'Off';
    }
  }
}