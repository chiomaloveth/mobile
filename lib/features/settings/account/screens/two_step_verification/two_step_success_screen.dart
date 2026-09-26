import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class TwoStepSuccessScreen extends ConsumerWidget {
  /// When provided (e.g. called from SecurityScreen toggle flow), tapping
  /// "Done" invokes this callback instead of popping to root.
  final VoidCallback? onDone;

  const TwoStepSuccessScreen({super.key, this.onDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (onDone != null) {
                            // Called from SecurityScreen toggle flow.
                            onDone!();
                          } else {
                            // Pop all 2FA screens and return to Account screen.
                            Navigator.of(context).popUntil((route) =>
                                route.settings.name == null ||
                                !route.settings.name!.contains('two_step'));
                          }
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
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10.0),
                        child: Text(
                          "All set!",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Checkmark icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF34C759),
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Two-Step Verification Enabled',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your account is now protected with two-step verification.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ll need to enter your PIN when you register your phone number with QikTalk again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Done button
              GestureDetector(
                onTap: () {
                  if (onDone != null) {
                    // Called from SecurityScreen toggle — let the caller handle navigation.
                    onDone!();
                  } else {
                    // Default: pop all 2FA setup screens back to the account/settings screen.
                    Navigator.of(context).popUntil(
                      (route) =>
                          route.isFirst ||
                          route.settings.name == '/account' ||
                          route.settings.name == '/settings',
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
