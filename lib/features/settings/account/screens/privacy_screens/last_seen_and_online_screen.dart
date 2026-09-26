import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/contact_except_picker_screen.dart';
import 'package:qik_talk/features/settings/account/components/last_seen_and_online_option_card.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/contacts_except_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/provider/privacy_settings_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';

class LastSeenAndOnlineScreen extends ConsumerStatefulWidget {
  const LastSeenAndOnlineScreen({super.key});

  @override
  ConsumerState<LastSeenAndOnlineScreen> createState() =>
      _LastSeenAndOnlineScreenState();
}

class _LastSeenAndOnlineScreenState
    extends ConsumerState<LastSeenAndOnlineScreen> {

  void _select(String value) {
    ref
        .read(privacySettingsProvider.notifier)
        .updatePrivacy(lastSeen: value);
  }

  Future<void> _openExceptPicker() async {
    final currentExcluded =
        ref.read(privacySettingsProvider).lastSeenExcludedIds;

    final result = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => ContactExceptPickerScreen(
          title: 'My Contacts Except...',
          preselectedIds: currentExcluded,
        ),
      ),
    );

    if (result == null) return; // user cancelled

    ref.read(privacySettingsProvider.notifier).updatePrivacy(
          lastSeen: 'contacts_except',
          lastSeenExcludedIds: result,
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final privacyState = ref.watch(privacySettingsProvider);

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightNavBar,
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
                'Last Seen & Online',
                style: GoogleFonts.poppins(
                  color:
                      isDark ? Colors.white : AppTheme.textPrimary(isDark),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Who can see my last seen time".toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                ),
                LastSeenAndOnlineOptionCard(
                  title: "Everyone",
                  value: privacyState.lastSeen,
                  onClick: () => _select("everyone"),
                  isDark: isDark,
                ),
                LastSeenAndOnlineOptionCard(
                  title: "Contacts",
                  value: privacyState.lastSeen,
                  onClick: () => _select("contacts"),
                  isDark: isDark,
                ),
                LastSeenAndOnlineOptionCard(
                  title: "My Contacts Except...",
                  value: privacyState.lastSeen,
                  onClick: _openExceptPicker,   // ← async nav, no () =>
                  isDark: isDark,
                ),
                LastSeenAndOnlineOptionCard(
                  title: "Nobody",
                  value: privacyState.lastSeen,
                  onClick: () => _select("nobody"),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Text(
                      "If you don't share your last seen, you won't be able to see other people's last seen",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}