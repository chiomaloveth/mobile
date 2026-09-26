import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';
import '../../components/last_seen_and_online_option_card.dart';
import '../../components/privacy_option_card.dart';
import 'contacts_except_screen.dart';
import 'provider/privacy_settings_provider.dart';

class PrivacyGroupsScreen extends ConsumerWidget {
  const PrivacyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final privacyState = ref.watch(privacySettingsProvider);

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    void select(String value) {
      ref.read(privacySettingsProvider.notifier).updatePrivacy(groups: value);
    }

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
        backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Groups',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
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
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Who can add me to groups",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                      ),
                      LastSeenAndOnlineOptionCard(
                        title: "Everyone",
                        value: privacyState.groups,
                        onClick: () => select("everyone"),
                        isDark: isDark,
                      ),
                      LastSeenAndOnlineOptionCard(
                        title: "Contacts",
                        value: privacyState.groups,
                        onClick: () => select("contacts"),
                        isDark: isDark,
                      ),
                      LastSeenAndOnlineOptionCard(
                        title: "Contacts Except",
                        value: privacyState.groups,
                        onClick: () {
                          select("contacts except");
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ContactsExceptScreen(
                              title: 'Group Exceptions',
                              subtitle: 'Contacts who cannot add you to groups',
                            ),
                          ));
                        },
                        isDark: isDark,
                      ),
                      PrivacyOptionCard(
                        title: "Nobody",
                        value: "You'll receive an invite link instead",
                        onClick: () => select("nobody"),
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
                            "If you choose \"Nobody\", people will need to send you a group invite link for you to join",
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
